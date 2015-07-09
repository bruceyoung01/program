pro daytimeconc, file, byymmdd=byymmdd,eyymmdd=eyymmdd,ilmm=ilmm,ijmm=ijmm,ikmm=ikmm,ncon=ncon,gas=gas

 if n_elements(file) eq 0 then file = pickfile()
 if n_elements(byymmdd) eq 0 then return
 if n_elements(eyymmdd) eq 0 then return
 if n_elements(pout) eq 0 then pout = [100.,200.,250.,300.,350.,400.,500.,600.,700.,800.,900.,1000.]
 if n_elements(gas) eq 0 then gas  = spec(indgen(25),ncon=25)
 if n_elements(ilmm) eq 0 then ilmm=72
 if n_elements(ijmm) eq 0 then ijmm=46
 if n_elements(ikmm) eq 0 then ikmm=20
 if n_elements(ncon) eq 0 then return

btime = byymmdd & etime = eyymmdd
tstep = (etime-btime+1)*4
igas = n_elements(gas)
inz  = n_elements(pout)
gas_avg = fltarr(ilmm,ijmm,inz,igas) 
div = fltarr(ilmm,ijmm)

for it = 0, tstep-1 do begin
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; call routine to read 3dctm output at every time step
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 conc = rd3dctm(file,ilun=ilun,ilmm=ilmm,ijmm=ijmm,ikmm=ikmm,press=press, $
                temp=temp,aird=aird,ncon=ncon,hdr=hdr)
 
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

 gas_conc = sig2pr(conc,aird,press,temp,pout,gas=gas)

  for j = 0, ijmm-1 do begin
  for i = 0, ilmm-1 do begin
    if (zen(i,j) gt 0.) then begin
      gas_avg(i,j,*,*) = gas_avg(i,j,*,*) + gas_conc(i,j,*,*)
      div(i,j) = div(i,j) + 1.
    end
  end
  end

end

  div = float(div)

  for j = 0, ijmm-1 do begin
  for i = 0, ilmm-1 do begin
    if (div(i,j) ne 0.) then gas_avg(i,j,*,*) = gas_avg(i,j,*,*)/div(i,j)
  end
  end

  openw,klun,'noavg_daylight.b'+strtrim(string(byymmdd),1)+'.dat_grads',/get
  for ic = 0, igas-1 do begin
   writeu, klun, reverse(gas_avg(*,*,*,ic),3)
  end
  free_lun, klun
end
