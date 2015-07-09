 function month_mean, obs=obs, cal=cal, spec=spec, Jday0=Jday0, time=time, $
    badsite=badsite, range=range, sync=sync

 if n_elements(badsite) eq 0 then badsite = ' '
 If N_elements(Jday0) ne 0 then begin
    Jday  = obs[0].jday
    sot   = Fix(Jday0 - jday[0])
 endif
            
 if n_elements(sot) ne 0 then jday = obs[0].jday[sot] $
 else jday = obs[0].jday

 case spec of 
   'SO4' : begin
           Data = obs.so4[sot] 
           conc = cal.so4
           range = [0.,15.]
           end
   'NH4' : begin
           Data = obs.nh4[sot] 
           conc = cal.nh4
           range = [0.,10.]
           end
   'OMC' : begin
           Data = obs.omc[sot] 
           conc = cal.omc
           range = [0.,10.]
           end
   'NO3' : begin
           Data = obs.nit[sot]
           conc = cal.nit
           range=[0.,10.]
           end
   'EC'  : begin
           Data = obs.ec[sot] 
           conc = cal.ec
           range = [0.,4]
           end
   'SOIL' :begin 
           Data = obs.soil[sot]
           conc = obs.DST1 + obs.DST2*0.38 
           end
 endcase

 check, data
 check, conc

 Nsite= n_elements(obs)

 jmon = jday2month(jday, base=20040101L)
 mm   = jmon(uniq(jmon)) & time=mm
 nmon = n_elements(mm)
 mobs = fltarr(Nsite, nmon)
 mcal = mobs
 ID   = ' '

 DDIM = size(data, /dim)
 if DDIM[0] ne N_elements(JMON) then message, 'dimension does not match'

 For D = 0, Nsite - 1L do begin

    p = where(obs[D].siteid eq badsite)
    if p[0] ne -1 then begin
       mobs[D, *] = -999.
       mcal[D, *] = -999.
       goto, bad
    end

    For M = 0, nmon-1L do begin
        pm = where(jmon eq mm[M])  ; search for the same month

        ; there is no data for corresponding months
        if pm[0] eq -1 then begin
           mobs[D, M] = -999.
           mcal[D, M] = -999.
           goto, jump
        end

        so = reform(Data[PM, D])    ; sample data for the same month        
        sm = reform(Conc[PM, D])

        p  = where(so gt 0.)        ; find positive values from observations

        ; if there is no positive values then -999
        if p[0] eq -1L then              $
           mobs[D, M] = -999.       else $
           mobs[D, M] = mean(so[p]) 

        if keyword_set(sync) and p[0] ne -1L then $
           mcal[D, M] = mean(sm[p])      else $
           mcal[D, M] = mean(sm)

        jump:
    end

    bad: ID = [ID, obs[D].siteid]
 end

 return, {data:mobs, conc:mcal}

 end

;=====================================================================

 pro scatter, spec, obs=obs, cal=cal, pos=pos, Jday0=Jday0

 RES = 2
 MTYPE  = 'GEOS4_30L'
 Modelinfo = CTM_TYPE(MTYPE, RES=RES)

 sync = 1L
 str = month_mean(obs=obs, cal=cal, spec=spec, time=time, range=range, $
                  Jday0=Jday0, sync=sync)

 lat  = obs.lat
 lon  = obs.lon
 Site = obs.siteid
 data = str.data
 conc = str.conc

 Unit = ' [!4l!3g/m!u3!n]'

 print, time

 if N_elements(time) gt 1 then begin
  scatter_season, 'AIRNOW', $
                  Modelinfo=Modelinfo, data=data, conc=conc, range=range, $
                  time=time, lat=lat, lon=lon, spec=ospec,                $
                  /subgridoff, bdlon=[-160.,-95.,-50.], Unit=Unit,        $
                  /regress
 end else begin
  scatter_annual, 'AIRNOW', $
                  Modelinfo=Modelinfo, data=data, conc=conc, range=range, $
                  time=time, lat=lat, lon=lon, spec=spec,                $
                  ID=site, bdlon=[-160.,-95.,-50.], Unit=Unit, /regress, $
                  /subgridoff, pos=pos
 end

 end

;===================================================================

 pro map, spec, obs=obs, cal=cal, Jday0=Jday0


 str = month_mean(obs=obs, cal=cal, spec=spec, time=time, range=range, $
                  Jday0=Jday0, sync=sync)

 lat  = obs.lat
 lon  = obs.lon
 Site = obs.siteid
 data = str.data
 conc = str.conc

    mindata = 0.
    maxdata = 10.
    cbar = 1L

    multipanel, row=2, col=2

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
    obs = airnow_datainfo()
 if N_elements(cal) eq 0 then $
    cal = get_model_airnow()

   @define_plot_size

 if (!D.NAME eq 'PS') then $
    Open_device, file='so4_icartt.ps', /PS, /landscape, /color

   !P.multi=[0,1,1,0,0]

   Pos = cposition(1,1,xoffset=[0.15,0.1],yoffset=[0.15,0.1], $
         xgap=0.1,ygap=0.1,order=0)

   ide  = where(obs.lon gt -95. and obs.lat gt 35.)

   ; Plotting day as Julian day
   JdayB = fix(nymd2tau(20040501L)-nymd2tau(20040101L))/24L
   JdayE = fix(nymd2tau(20040831L)-nymd2tau(20040101L))/24L
   Jday0 = Indgen(JdayE-JdayB+1L) + JdayB[0] + 1L


   scatter, 'SO4', obs=obs, cal=cal, pos=pos[*,0], Jday0=Jday0
;    comp, 'NIT', obs=obs, cal=cal, pos=pos[*,1]
;    comp, 'NH4', obs=obs, cal=cal, pos=pos[*,2]
;    comp, 'OMC', obs=obs, cal=cal, pos=pos[*,3]

halt
  map, 'SO4', obs=obs, cal=cal, Jday0=Jday0

halt

 erase
 spec='SO4'
 RES = 2
 MTYPE  = 'GEOS4_30L'
 Modelinfo = CTM_TYPE(MTYPE, RES=RES)


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

  if (!D.NAME eq 'PS') then Close_device

 End
