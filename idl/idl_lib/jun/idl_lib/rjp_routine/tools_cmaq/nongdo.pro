pro nongdo,file,lfile,byymmdd=byymmdd,eyymmdd=eyymmdd,pout=pout,gas=gas, $
    ilmm=ilmm,ijmm=ijmm,ikmm=ikmm,ncon=ncon

;+
; pro nongdo,file,byymmdd=byymmdd,eyymmdd=eyymmdd,pout=pout,gas=gas, $
;    ilmm=ilmm,ijmm=ijmm,ikmm=ikmm,ncon=ncon
;
; if n_elements(file) eq 0 then file = pickfile()
; if n_elements(byymmdd) eq 0 then return
; if n_elements(eyymmdd) eq 0 then return
; if n_elements(pout) eq 0 then pout = [200.,250.,300.,350.,400.,500.,600.,700.,800.,900.,1000.]
; if n_elements(gas) eq 0 then gas  = ['NO','NO2','HNO3','O3','CO','CH3CO3NO2','ISOP','OH']
; if n_elements(ilmm) eq 0 then ilmm=72
; if n_elements(ijmm) eq 0 then ijmm=46
; if n_elements(ikmm) eq 0 then ikmm=20
; if n_elements(ncon) eq 0 then return
;
;-
 if n_elements(file) eq 0 then file = pickfile()
 if n_elements(lfile) eq 0 then lfile = pickfile()
 if n_elements(byymmdd) eq 0 then return
 if n_elements(eyymmdd) eq 0 then return
 if n_elements(pout) eq 0 then pout = [100.,200.,250.,300.,350.,400.,500.,600.,700.,800.,900.,1000.]
 if n_elements(gas) eq 0 then gas  = spec(indgen(25),ncon=25)
 if n_elements(ilmm) eq 0 then ilmm=72
 if n_elements(ijmm) eq 0 then ijmm=46
 if n_elements(ikmm) eq 0 then ikmm=20
 if n_elements(ncon) eq 0 then return

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Control parameter for interpolation and parameter setup
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
G0 = 9.80665
btime = byymmdd & etime = eyymmdd
tstep = (etime-btime+1)*4
imon = byymmdd/10000
imon = (byymmdd-(imon*10000))/100

bt = string(strtrim(btime,1)) & et = string(strtrim(etime,1))
ttag = '('+bt+'-'+et+')'

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Declare the variables
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
igas = n_elements(gas)
inz  = n_elements(pout)

burden_out = fltarr(tstep,ncon+2) ; for species burden
tlinox = fltarr(tstep) ; for lightning nox production in Tg N/month
gas_avg = fltarr(ilmm,ijmm,inz,igas) 
ohout = fltarr(ijmm,inz)
oh_avg = fltarr(ijmm,inz)
co_avg = fltarr(ilmm,ijmm,ikmm)
aird_avg = fltarr(ilmm,ijmm,inz)
temp_avg = fltarr(ilmm,ijmm,inz)

for i = 0, tstep-1 do begin
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; call routine to read 3dctm output at every time step
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 conc = rd3dctm(file,ilun=ilun,ilmm=ilmm,ijmm=ijmm,ikmm=ikmm, $
        press=press,temp=temp,aird=aird,ncon=ncon)
 co_avg = co_avg + conc(*,*,*,spec('CO',ncon=ncon))/aird
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; call routine to calculate average of speceis concentrations over certain period
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 gas_conc = sig2pr(conc,aird,press,temp,pout,ohout=ohout,gas=gas,tout=tout,adout=adout)
 gas_avg  = gas_avg + gas_conc
 oh_avg   = oh_avg  + ohout
 temp_avg = temp_avg + tout
 aird_avg = aird_avg + adout
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; call routine to write out a time-series of species concentration at each level
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; ios = wrconc(gas_conc,tout,jlun=jlun)
; if ios eq 0 then return
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; call routine to calculate species total burden 
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 dp  = gridinv(ilmm=ilmm,ijmm=ijmm,ikmm=ikmm,press=press,mass=mass,mcor=mcor,psf=psf)

 for n=0, ncon-1 do begin
   burden_out(i,n) = total(total(100.*(conc(*,*,*,n)/aird)*dp/G0,3)*mcor)/1.e9 ; in Tg
 end
   burden_out(i,ncon) = total(mass)/1.e9

   linox = rdlightnox(file=lfile,ilun=ilnox,ilmm=ilmm,ijmm=ijmm,ikmm=ikmm)

   burden_out(i,ncon+1) = (14./28.97)*total(total(100.*linox*dp/G0,3)*mcor)/1.e9  ; in Tg
 
end
 print, 'total lightning NOx production is', total(burden_out(*,ncon+1)), 'Tg N/month'
; free_lun, jlun

 gas_avg = gas_avg / float(tstep)
 oh_avg  = oh_avg / float(tstep)
 oh_avg  = reverse(oh_avg,2)
 co_avg  = co_avg / float(tstep) 
 temp_avg = temp_avg / float(tstep)
 aird_avg = aird_avg / float(tstep)
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; call routine to compare calcualted CO to CMDL CO
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 plotcmdl, co_avg, imon
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
; call routine to plot 3D concentration field
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; plot_3d_ctmout,ttag=ttag,gas=gas,out=gas_avg,pout=pout,ohavg=oh_avg,ilmm=ilmm,ijmm=ijmm
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; call routine to plot total burden of gas species
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 agas = spec(indgen(ncon),ncon=ncon)
 agas = [agas,'AIR','LNOx']      
 plotburden, out=burden_out,mon=imon,gas=agas,graph='ps'

 wfile = 'cavg.b'+strtrim(string(byymmdd),1)+'.e'+strtrim(string(eyymmdd),1)+'.dat_grads'
 openw, klun,wfile, /get_lun
  writeu, klun, reverse(temp_avg,3)
  writeu, klun, reverse(aird_avg,3)
  for ic = 0, igas-1 do begin
   writeu, klun, reverse(gas_avg(*,*,*,ic),3)
  end
 free_lun, klun

return
end
