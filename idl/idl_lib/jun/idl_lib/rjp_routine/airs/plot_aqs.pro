 function month_mean, Dinfo=Dinfo, spec=spec, Jday0=Jday0, time=time, $
    badsite=badsite, range=range

 if n_elements(badsite) eq 0 then badsite = ' '
 If N_elements(Jday0) ne 0 then begin
    Jday  = Dinfo[0].jday
    sot   = Fix(Jday0 - jday[0])
 endif
            
 if n_elements(sot) ne 0 then jday = Dinfo[0].jday[sot] $
 else jday = Dinfo[0].jday

 case spec of 
   'SO4' : begin
           if n_elements(sot) ne 0 then Data = Dinfo.so4[sot] $
           else Data = Dinfo.so4
           range = [0.,15.]
           end
   'NH4' : begin
           if n_elements(sot) ne 0 then Data = Dinfo.nh4[sot] $
           else Data = Dinfo.nh4
           range = [0.,10.]
           end
   'OMC' : begin
           if n_elements(sot) ne 0 then Data = Dinfo.omc[sot] $
           else Data = Dinfo.omc
           range = [0.,10.]
           end
   'NO3' : Data = Dinfo.no3
   'NIT' : begin
           if n_elements(sot) ne 0 then Data = Dinfo.nit[sot] $
           else Data = Dinfo.nit
           range=[0.,10.]
           end
   'EC'  : begin
           if n_elements(sot) ne 0 then Data = Dinfo.ec[sot] $
           else Data = Dinfo.ec
           range = [0.,4]
           end
   'SOIL' : Data = Dinfo.soil
   'DUST' : if n_elements(sot) ne 0 then Data = Dinfo.DST1[sot] + Dinfo.DST2[sot]*0.38 $
           else Data = Dinfo.DST1 + Dinfo.DST2*0.38
 end

 Nsite= n_elements(Dinfo)

 jmon = jday2month(jday, base=20040101L)
 mm   = jmon(uniq(jmon)) & time=mm
 nmon = n_elements(mm)
 mobs = fltarr(Nsite, nmon)
 ID   = ' '

 DDIM = size(data, /dim)
 if DDIM[0] ne N_elements(JMON) then message, 'dimension does not match'

 For D = 0, Nsite - 1L do begin
     p = where(Dinfo[D].siteid eq badsite)
     if p[0] ne -1 then begin
        mobs[D, *] = -999.
        goto, bad
     end

     For M = 0, nmon - 1L do begin
        pm = where(jmon eq mm[M])  ; search for the same month

        if pm[0] eq -1 then begin
           mobs[D, M] = -999.
           goto, jump
        end

        ; sample data for the same month
        s = reform(Data[PM, D])    

        ; sample only positive values
        p = where(s gt 0.)        

        if p[0] eq -1 then begin
           mobs[D, M] = -999.
           goto, jump
        end

        ; calculate monthly mean
        mobs[D, M] = mean(s[p]) ; taking mean

        jump:
     end
     ID = [ID, Dinfo[D].siteid]
   bad:
 end

 return, mobs

 end

;=====================================================================

 pro scatter, spec, obs=obs, cal=cal, pos=pos, Jday0=Jday0

 RES = 2
 MTYPE  = 'GEOS4_30L'
 Modelinfo = CTM_TYPE(MTYPE, RES=RES)

 data = month_mean(Dinfo=obs, spec=spec, time=time, Jday0=Jday0)
 conc = month_mean(Dinfo=cal, spec=spec, time=mtime, range=range, Jday0=Jday0)

 lat  = obs.lat
 lon  = obs.lon
 Site = obs.siteid

 Unit = ' [!4l!3g/m!u3!n]'

 print, time

 if N_elements(time) gt 1 then begin
  scatter_season, 'AQS', $
                  Modelinfo=Modelinfo, data=data, conc=conc, range=range, $
                  time=time, lat=lat, lon=lon, spec=ospec,                $
                  /subgridoff, bdlon=[-160.,-95.,-50.], Unit=Unit,        $
                  /regress
 end else begin
  scatter_annual, 'AQS', $
                  Modelinfo=Modelinfo, data=data, conc=conc, range=range, $
                  time=time, lat=lat, lon=lon, spec=spec,                $
                  ID=site, bdlon=[-160.,-95.,-50.], Unit=Unit, /regress, $
                  /subgridoff, pos=pos
 end

 end

;===================================================================

 pro map, spec, obs=obs, cal=cal


 data = month_mean(Dinfo=obs, spec=spec, time=time)
 conc = month_mean(Dinfo=cal, spec=spec, range=range)
 lat  = obs.lat
 lon  = obs.lon
 Site = obs.siteid

    mindata = 0.
    maxdata = 10.
    cbar = 1L

;   multipanel, row=2, col=2

    map2d_annual, Dname, $
                    Modelinfo=Modelinfo, data=data, range=range, $
                    time=time, lat=lat, lon=lon, spec=spec,      $
                    min_valid=min_valid, maxdata=maxdata, mindata=mindata, $
                    positived=positived, cbar=cbar, margin=margin, $
                    nogxlabel=nogxlabel, nogylabel=nogylabel, title='AIRNOW (sulfate)'

    map2d_annual, Dname, $
                    Modelinfo=Modelinfo, data=conc, range=range, $
                    time=time, lat=lat, lon=lon, spec=spec,      $
                    min_valid=min_valid, maxdata=maxdata, mindata=mindata, $
                    positived=positived, cbar=cbar, margin=margin, $
                    nogxlabel=nogxlabel, nogylabel=nogylabel, title='MODEL (sulfate)'

 end

;===================================================================

 function composite, data

  ndim = size(data, /dim)

  newdata = fltarr(Ndim[0])

  for D = 0L, ndim[0]-1 do begin
      val = make_zero(reform(data[D,*]),val='NaN')
      newdata[D] = mean(val,/NaN)
      if newdata[d] eq 0 then newdata[d] = 'NaN'
  end

  return, newdata

 end
;===================================================================

 if N_elements(obs) eq 0 then $
    obs = aqs_datainfo()
 if N_elements(cal) eq 0 then $
    cal = get_model_aqs()

   @define_plot_size

 spec = 'EC'

 if (!D.NAME eq 'PS') then $
    Open_device, file=spec+'_aqs.ps', /PS, /landscape, /color

   !P.multi=[0,1,1,0,0]

   Pos = cposition(1,1,xoffset=[0.15,0.1],yoffset=[0.15,0.1], $
         xgap=0.1,ygap=0.1,order=0)

   ; Plotting day as Julian day
   JdayB = fix(nymd2tau(20040501L)-nymd2tau(20040101L))/24L
   JdayE = fix(nymd2tau(20040831L)-nymd2tau(20040101L))/24L
   Jday0 = Indgen(JdayE-JdayB+1L) + JdayB[0] + 1L


   scatter, spec, obs=obs, cal=cal, pos=pos[*,0], Jday0=Jday0
;    comp, 'NIT', obs=obs, cal=cal, pos=pos[*,1]
;    comp, 'NH4', obs=obs, cal=cal, pos=pos[*,2]
;    comp, 'OMC', obs=obs, cal=cal, pos=pos[*,3]


  if (!D.NAME eq 'PS') then Close_device
 stop

 halt

 RES = 2
 MTYPE  = 'GEOS4_30L'
 Modelinfo = CTM_TYPE(MTYPE, RES=RES)

   ide  = where(obs.lon gt -95. and obs.lat gt 35.)

   data = obs[ide].so4
   data = composite( data )
   conc = total(cal[ide].so4,2)/float(N_elements(ide))

   jday = cal[0].jday
   plot, jday, conc, color=1, xtitle='Julian days', $
         ytitle='Concentraions (!4l!3g m!u-3!n)',   $
         title='Daily sulfate concentration in the US East', $
         charsize=charsize, charthick=charthick, xstyle=1, position=pos

   jday = obs[0].jday
   oplot, jday, data, psym=8, color=1
;   xyouts, 185, 18, '(July-August, 2004)', color=1, charsize=charsize, charthick=charthick



 End
