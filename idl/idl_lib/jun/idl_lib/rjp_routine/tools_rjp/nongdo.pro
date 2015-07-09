pro nongdo,file,lfile=lfile,byymmdd=byymmdd,eyymmdd=eyymmdd,pout=pout, $
    gas=gas,ilmm=ilmm,ijmm=ijmm,ikmm=ikmm,ncon=ncon

 if n_elements(ncon) eq 0 then begin
    print, 'Please give me the number of gas species'
    return
 endif
 if n_elements(file) eq 0 then file = pickfile()
    light = 'true'
 if n_elements(lfile) eq 0 then light = 'false'
 if n_elements(byymmdd) eq 0 then return
 if n_elements(eyymmdd) eq 0 then return
 if n_elements(pout) eq 0 then $
    pout = [100.,200.,250.,300.,350.,400.,500.,600.,700.,800.,900.,1000.]
 if n_elements(gas ) eq 0 then gas  = spec(indgen(ncon),ncon=ncon)
 
 if n_elements(ilmm) eq 0 then ilmm=72
 if n_elements(ijmm) eq 0 then ijmm=46
 if n_elements(ikmm) eq 0 then ikmm=20

 undef = -999.
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Control parameter for interpolation and parameter setup
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
G0 = 9.80665
btime = byymmdd & etime = eyymmdd
tstep = (etime-btime+1)*4
imon = byymmdd/10000
imon = (byymmdd-(imon*10000))/100

bt = strtrim(btime,1) & et = strtrim(etime,1)
ttag = '('+bt+'-'+et+')'

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Declare the variables
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 igas = n_elements(gas)

 burden_out = fltarr(tstep,ncon+2) ; for species burden
 tlinox = fltarr(tstep) ; for lightning nox production in Tg N/month


 conc_avg = fltarr(ilmm,ijmm,ikmm,ncon) 
 aird_avg = fltarr(ilmm,ijmm,ikmm)
 temp_avg = fltarr(ilmm,ijmm,ikmm)
 pres_avg = temp_avg

 Dconc_avg = conc_avg
 Daird_avg = aird_avg
 Dtemp_avg = temp_avg
 Dpres_avg = pres_avg
 div = fltarr(ilmm,ijmm)

for it = 0, tstep-1 do begin
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; call routine to read 3dctm output at every time step
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 conc = rd3dctm(file,ilun=ilun,ilmm=ilmm,ijmm=ijmm,ikmm=ikmm, $
        press=press,temp=temp,aird=aird,ncon=ncon,hdr=hdr)

;...call routine to write out a time-series of species concentration at each level
; ios = wrconc(gas_conc,tout,jlun=jlun)
; if ios eq 0 then return

;...First calculate monthly average of files at sigma layer and
;...then interpolate them onto pressure levels...

 conc_avg = conc_avg + conc/float(tstep)
 temp_avg = temp_avg + temp/float(tstep)
 aird_avg = aird_avg + aird/float(tstep)
 pres_avg = pres_avg + press/float(tstep)
 

;...Calculation for concentrations for daylight only

 mtime = long(hdr)
 year = mtime(0)/10000
 month = (mtime(0)-(year*10000))/100
 day = mtime(0) - (year*10000+month*100)
 year = year + 1900
 hour = mtime(1)/10000

 julian = julday(month,day,year,hour)
 julian = julian - 0.5 ; -12 hours for local time at model south-west grid
 caldat, julian, month, day, year, hour

 month = float(month)
 day = float(day)
 year = float(year)
 hour = float(hour)

 zen = solarzen(year,month,day,hour,0.,0.,ilmm=ilmm,ijmm=ijmm)

  for j = 0, ijmm-1 do begin
  for i = 0, ilmm-1 do begin
    if (zen(i,j) gt 0.) then begin
      Dconc_avg(i,j,*,*) = Dconc_avg(i,j,*,*) + conc(i,j,*,*)
	Daird_avg(i,j,*)   = Daird_avg(i,j,*)   + aird(i,j,*)
	Dtemp_avg(i,j,*)   = Dtemp_avg(i,j,*)   + temp(i,j,*)
	Dpres_avg(i,j,*)   = Dpres_avg(i,j,*)   + press(i,j,*)
      div(i,j) = div(i,j) + 1.
    end
  end
  end

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; call routine to calculate species total burden 
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 dp  = gridinv(ilmm=ilmm,ijmm=ijmm,ikmm=ikmm,press=press,mass=mass, $
       mcor=mcor,psf=psf)

 for n=0, ncon-1 do begin
   burden_out(it,n) = total(total(100.*(conc(*,*,*,n)/aird)*dp/G0,3)*mcor)/1.e9 
    ; in Tg
 end
   burden_out(it,ncon) = total(mass)/1.e9

  if (light eq 'true') then begin
   linox = rdlightnox(file=lfile,ilun=ilnox,ilmm=ilmm,ijmm=ijmm,ikmm=ikmm)
   burden_out(it,ncon+1) =  $
      (14./28.97)*total(total(100.*linox*dp/G0,3)*mcor)/1.e9     ; in Tg
  endif
 
end

  print, 'total lightning NOx production is', total(burden_out(*,ncon+1)),  $
         'Tg N/month'
; free_lun, jlun


;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
; call routine to plot 3D concentration field
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; ohout = reverse(ohout,2)
; plot_3d_ctmout,ttag=ttag,gas=gas,out=gas_conc,pout=pout,ohavg=ohout,ilmm=ilmm,ijmm=ijmm


;...call routine to plot total burden of gas species

    agas = spec(indgen(ncon),ncon=ncon)
    agas = [agas,'AIR','LNOx']      
    fburden = 'bd.b'+bt+'.e'+et
    plotburden,fburden,out=burden_out,mon=imon,gas=agas,graph='ps'
    
    
;...write out the average concentration at sigma level
    
    wfile = 'cavg_sig.b'+bt+'.e'+et+'.dat_grads'
    openw, klun, wfile, /get_lun
      writeu, klun, reverse(temp_avg,3)
      writeu, klun, reverse(pres_avg,3)
	writeu, klun, reverse(aird_avg,3)
    for ic = 0, igas-1 do begin
      writeu, klun, reverse(conc_avg(*,*,*,ic)/aird_avg,3)
    end
    free_lun, klun

;...write out the average concentration at specific presssure level
;...Call interpolation routine to calculate average field on pressure surface.

    gas_conc = sig2pr(conc_avg,aird_avg,pres_avg,temp_avg,pout, $
                      gas=gas,tout=tout,adout=adout,undef=undef)
 
    wfile = 'cavg_prs.b'+bt+'.e'+et+'.dat_grads'
    openw, klun, wfile, /get_lun
      writeu, klun, reverse(tout,3)
      writeu, klun, reverse(adout,3)
    for ic = 0, igas-1 do begin
      writeu, klun, reverse(gas_conc(*,*,*,ic),3)
    end
    free_lun, klun
    
    
;; Daylight concentrations

  div = float(div)

  for j = 0, ijmm-1 do begin
  for i = 0, ilmm-1 do begin
    if (div(i,j) ne 0.) then Dconc_avg(i,j,*,*) = Dconc_avg(i,j,*,*)/div(i,j)
    if (div(i,j) ne 0.) then Daird_avg(i,j,*) = Daird_avg(i,j,*)/div(i,j)
    if (div(i,j) ne 0.) then Dtemp_avg(i,j,*) = Dtemp_avg(i,j,*)/div(i,j)
    if (div(i,j) ne 0.) then Dpres_avg(i,j,*) = Dpres_avg(i,j,*)/div(i,j)
  end
  end
;...write out the average concentration for daylight only at sigma level
    
    wfile = 'cavg_sig_dayonly.b'+bt+'.e'+et+'.dat_grads'
    openw, klun, wfile, /get_lun
      writeu, klun, reverse(Dtemp_avg,3)
      writeu, klun, reverse(Dpres_avg,3)
	writeu, klun, reverse(Daird_avg,3)
    for ic = 0, igas-1 do begin
      writeu, klun, reverse(Dconc_avg(*,*,*,ic)/Daird_avg,3)
    end
    free_lun, klun
    
;...write out the average concentrations for daylight only at specific pressure
;...level
  
   Dgas_conc = sig2pr(Dconc_avg,Daird_avg,Dpres_avg,Dtemp_avg,pout,gas=gas,$
                      tout=Dtout,adout=Dadout,undef=undef)

  openw,klun,'cavg_prs_dayonly.b'+bt+'.e'+et+'.dat_grads',/get
    writeu, klun, reverse(Dtout,3)
    writeu, klun, reverse(Dadout,3)
  for ic = 0, igas-1 do begin
    writeu, klun, reverse(Dgas_conc(*,*,*,ic),3)
  end
  free_lun, klun    

 return
 end
