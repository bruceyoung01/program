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

;===================================================================================

 function choose, spec, calc=calc, range=range

  case spec of
    'SO4' : begin
            conc = calc.so4_conc*96.
            range=[0.,12.]
            Unit = ' [!4l!3g/m!u3!n]'
            end
    'NH4' : begin
            conc = calc.nh4_conc*18.
            range=[0.,6.]
            Unit = ' [!4l!3g/m!u3!n]'
            end
    'NO3' : begin
            conc = calc.nit_conc*62.
            range=[0.,5.]
            Unit = ' [!4l!3g/m!u3!n]'
            end
    'HNO3': begin
            conc = calc.hno3_conc*63.
            range=[0.,15.]
            end
    'EC'  : begin
            conc = (calc.ecpi_conc+calc.ecpo_conc)*12.
            range=[0.,2.]
            Unit = ' [!4l!3g/m!u3!n]'
            end
    'OMC' : begin
            TAG  = strupcase(tag_names(calc))
            P    = where('SOA1_CONC' eq TAG)
            
            if P[0] ne -1. then begin
               print, TAG
               conc = (calc.ocpi_conc+calc.ocpo_conc)*12.*1.4 $
                    + (calc.soa1_conc)*150.                   $
                    + (calc.soa2_conc)*160.                   $
                    + (calc.soa3_conc)*220.
               add_conc = (calc.soa1_conc)*150.               $
                        + (calc.soa2_conc)*160.               $
                        + (calc.soa3_conc)*220.

;               conc = (calc.ocpi_conc+calc.ocpo_conc)*12.*1.4 
            end else begin
               conc = (calc.ocpi_conc+calc.ocpo_conc)*12.*1.4 
            end

            range=[0.,10.]
            Unit = ' [!4l!3g/m!u3!n]'
            end

    'DUST': begin
            conc = (calc.dst1_conc + calc.dst2_conc*0.38)*29.
            range= [0.,10]
            Unit = ' [!4l!3g/m!u3!n]'
            end

  endcase

  return, conc

 end
;=====================================================================

 pro scatter, spec, obs=obs, calc=calc, pos=pos, Jday0=Jday0

 RES = 2
 MTYPE  = 'GEOS4_30L'
 Modelinfo = CTM_TYPE(MTYPE, RES=RES)

 ; observations are daily so make it month mean
 data = month_mean(Dinfo=obs, spec=spec, time=time, Jday0=Jday0)
 conc = choose( spec, calc=calc, range=range )

 lat  = obs.lat
 lon  = obs.lon
 Site = obs.siteid

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

 pro map, spec, obs=obs, calc=calc, Jday0=Jday0


 data = month_mean(Dinfo=obs, spec=spec, time=time, Jday0=Jday0)
 conc = choose( spec, calc=calc, range=range )

 lat  = obs.lat
 lon  = obs.lon
 Site = obs.siteid

    mindata = 0.
    maxdata = 4.
    cbar = 1L

    multipanel, row=2, col=1

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

  spec = 'NH4'

  @define_plot_size

  Tracer = [26,27,29,30,31,32,33,34,35]

  Year   = 2004L
  RES    = 2
  TYPE   = 'S' ; 'A', 'S', 'T'
  YYMM   = Year*100L + Lindgen(1) + 7L
  MTYPE  = 'GEOS4_30L'
  CATEGORY = 'IJ-AVG-$'

 ;=========================================================================;
  CASE RES of
   1 : DXDY = '1x1'
   2 : DXDY = '2x25'
   4 : DXDY = '4x5' 
  END

  Modelinfo = CTM_TYPE(MTYPE, RES=RES)
  Gridinfo  = CTM_GRID(MODELINFO)

  CYear = Strtrim(Year,2)

 if N_elements(obs) eq 0 then $
    obs = aqs_datainfo()

 if N_elements(calc) eq 0 then begin

     ; Calculation output is in umoles/m3
     if !D.name ne 'WIN' then filter = '/users/ctm/rjp/Asim/' 

     If N_elements(file_calc) eq 0 then $
     file_calc = dialog_pickfile(filter=filter)

     read_model,                      $
                file_calc,            $
                CATEGORY,             $
                file_aird=file_aird,  $
                file_pres=file_pres,  $
                YYMM=YYMM,            $               
                Modelinfo=Modelinfo,  $
                calc=calc,            $
                obs=obs,              $
                Tracer=Tracer, fixz=0L

 endif

 if (!D.NAME eq 'PS') then $
    Open_device, file='so4.ps', /PS, /landscape, /color

   !P.multi=[0,1,1,0,0]

   Pos = cposition(1,1,xoffset=[0.15,0.1],yoffset=[0.15,0.1], $
         xgap=0.1,ygap=0.1,order=0)

   ; Plotting day as Julian day
   JdayB = fix(nymd2tau(20040701L)-nymd2tau(20040101L))/24L
   JdayE = fix(nymd2tau(20040731L)-nymd2tau(20040101L))/24L
   Jday0 = Indgen(JdayE-JdayB+1L) + JdayB[0] + 1L

;   scatter, spec, obs=obs, calc=calc, pos=pos[*,0], Jday0=Jday0
   map, spec, obs=obs, calc=calc, Jday0=Jday0

  if (!D.NAME eq 'PS') then Close_device

 End
