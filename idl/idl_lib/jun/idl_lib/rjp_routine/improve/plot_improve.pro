 pro choose, obs=obs, calc=calc, spec=spec, data=data, conc=conc, range=range, $
     Unit=Unit, sites=sites, ID=ID, add_conc=add_conc, fac=fac, $
     lon=lon, lat=lat, alt=alt

  if n_elements(spec)  eq 0 then spec  = 'SO4'
  if n_elements(sites) eq 0 then sites = obs.siteid
  if n_elements(fac)   eq 0 then fac   = 1.

  case spec of
    'SO2' : begin
            data = obs.so2
            conc = calc.so2_conc*64.
            range= [0.,40.]
            end
    'SO4' : begin
            data = obs.so4
            conc = calc.so4_conc*96.
            range=[0.,12.]
            Unit = ' [!4l!3g/m!u3!n]'
            end
    'NH4' : begin
            data = obs.nh4
            conc = calc.nh4_conc*18.
            range=[0.,8.]
            Unit = ' [!4l!3g/m!u3!n]'
            end
    'NO3' : begin
            data = obs.no3
            conc = calc.nit_conc*62.
            range=[0.,5.]
            Unit = ' [!4l!3g/m!u3!n]'
            end
    'HNO3': begin
            data = obs.hno3
            conc = calc.hno3_conc*63.
            range=[0.,15.]
            end
    'EC'  : begin
            data = obs.ec
            conc = (calc.ecpi_conc+calc.ecpo_conc)*12.
            range=[0.,2.]
            Unit = ' [!4l!3g/m!u3!n]'
            end
    'OMC' : begin
            data = obs.oc * 1.4
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

            range=[0.,8.]
            Unit = ' [!4l!3g/m!u3!n]'
            end

    'DUST': begin
            data = obs.soil
            conc = (calc.dst1_conc + calc.dst2_conc*0.38)*29.
            range= [0.,10]
            Unit = ' [!4l!3g/m!u3!n]'
            end

  endcase

  ; Sort out for siteID
  ND = Size(data, /dim)
  NSITE = ND[0]
  NDATA = ND[1]
  Newdata = fltarr(N_elements(Sites), NDATA)

  ND = Size(conc, /dim)
  IF N_elements(ND) eq 2 then NDATA = ND[1] else NDATA = 1L
  Newconc = fltarr(N_elements(Sites), NDATA)

  if n_elements(add_conc) ne 0 then Newadd  = Newconc

  Siteid  = strarr(N_elements(Sites))
  Lon     = fltarr(N_elements(Sites))
  Lat     = Lon
  Alt     = Lon
  ict     = -1L
  For D = 0, N_elements(Sites)-1 Do begin
      n = where(Sites[D] eq obs.siteid)
      if n[0] ne -1 then begin
         ict = ict + 1L
         Newdata[ict,*] = Data[N[0],*]
         Newconc[ict,*] = Conc[N[0],*] * FAC
         if n_elements(add_conc) ne 0 then Newadd[ict,*]  = add_conc[N[0],*]
         Siteid[ict]    = Obs.siteid[n[0]]
         Lon[ict]       = Obs.lon[n[0]]
         Lat[ict]       = Obs.lat[n[0]]
         Alt[ict]       = Obs.elev[n[0]]*1.e-3
      end
  Endfor

  Data = Reform(Newdata[0:ict,*])
  Conc = Reform(Newconc[0:ict,*])
  if n_elements(add_conc) ne 0 then Add_conc = Reform(Newadd[0:ict,*])
  ID   = Reform(Siteid[0:ict])
  Lon  = Reform(Lon[0:ict])
  Lat  = Reform(Lat[0:ict])
  Alt  = Reform(Alt[0:ict])

 end

;===============================================================================

 Pro makeplot, obs=obs, calc=calc, spec=spec,       $
     month=month, season=season, annual=annual,     $
     subgridoff=subgridoff, ratiomap=ratiomap,      $
     pos=pos, modelinfo=modelinfo, tseries=tseries, $
     sites=sites, fac=fac, map2d=map2d

  choose, obs=obs, calc=calc, spec=spec, data=data, conc=conc, range=range, $
    Unit=Unit, sites=sites, ID=ID, add_conc=add_conc, fac=fac, $
    lon=lon, lat=lat, alt=alt

 if keyword_set(annual) then begin
  scatter_annual, 'IMPROVE', $
                  Modelinfo=Modelinfo, data=data, conc=conc, range=range, $
                  time=calc.time, lat=lat, lon=lon, spec=spec, $
                  subgridoff=subgridoff, bdlon=[-160.,-95.,-50.], pos=pos, $
                  Unit=Unit, ID=ID
 endif

 If keyword_set(season) then begin
;  if (!D.name ne 'PS') then panel, 0, title='Seasonal scatterplot [IMPROVE]'
  scatter_season, 'IMPROVE', $
                  Modelinfo=Modelinfo, data=data, conc=conc, range=range, $
                  time=calc.time, lat=lat, lon=lon, spec=spec, $
                  subgridoff=subgridoff, bdlon=[-160.,-95.,-50.], Unit=Unit,$
                  /regress
 endif

 if keyword_set(month) then begin
;  if (!D.name ne 'PS') then panel, 2, title='Monthly scatterplot [IMPROVE]'
  scatter_month, 'IMPROVE', $
                  Modelinfo=Modelinfo, data=data, conc=conc, range=range, $
                  time=calc.time, lat=lat, lon=lon, spec=spec, $
                  bdlon=[-160.,-95.,-60.], color=color, Unit=Unit
 endif

 if keyword_set(map2d) then begin
  if (!D.name ne 'PS') then panel, 0, title='Monthly scatterplot [IMPROVE]'
  map2d_annual, 'IMPROVE', $
                    Modelinfo=Modelinfo, data=data, range=range, $
                    time=calc.time, lat=lat, lon=lon, spec=spec, $
                    min_valid=1.e-6, maxdata=maxdata, mindata=0., $
                    /positived 

  map2d_annual, 'IMPROVE', $
                    Modelinfo=Modelinfo, data=conc, range=range, $
                    time=calc.time, lat=lat, lon=lon, spec=spec, $
                    min_valid=1.e-6, maxdata=maxdata, mindata=0., $
                    /positived 

 endif

 if keyword_set(tseries) then begin
  timeseries, 'IMPROVE', conc=conc, data=data, spec=spec, $
               time=calc.time, siteid=ID, lat=lat, lon=lon, alt=alt, $
               range=range, add_conc=add_conc, /n2s
 endif

 End

;====================================================================
 Pro plotso4nh4_scatter, so4=so4, nh4=nh4, lon=lon

; Monthly mean scatter plots
   Nmon = 12
   Mon  = Indgen(12)+1L

  !P.multi=[0,2,2,0,0]
   Pos = cposition(2,2,xoffset=[0.1,0.02],yoffset=[0.05,0.1], $
         xgap=0.15,ygap=0.12,order=0)

 If !D.name eq 'PS' then begin
   charthick=4. 
   charsize=1.5
 end else begin
   charthick=2. 
   charsize=1.2
 end

   Align = 0.5
 
   Sea_str = ['DJF','MAM','JJA','SON']

   sz = {sym:1.0,lthick:2}
   If (!D.name eq 'PS') then sz = {sym:0.8,lthick:4.}
   ; Define Usersymbol
   A = FINDGEN(33) * (!PI*2/32.)
   USERSYM, COS(A), SIN(A) ; , /FILL

    Color = [1,4,1]
    sym   = [1,8]
   Lonb = [-150.,-95.,-60.]
   MSEA = [[12,1,2],[3,4,5],[6,7,8],[9,10,11]]
   range = [0.,0.2]

   for IS = 0, 3 do begin
         XAX = 0.
         YAX = 0.    
         BIAS= 0.
     for D = 0, 1 do begin

         XDA = 0.
         YDA = 0.

        POT = where(lon gt Lonb[D] and lon le Lonb[D+1])

        FOR IM = 0, NMON-1 DO BEGIN
            res = where(Mon[IM] eq MSEA[*,is])
            if (res[0] ne -1) then begin
                YDA = [YDA,Reform(NH4[Mon[IM]-1,POT])]
                XDA = [XDA,Reform(SO4[Mon[IM]-1,POT])]
            endif            
        Endfor

        XX = 0.
        YY = 0.

        For np = 0, N_elements(XDA)-1 do begin
           if (XDA[np] gt 0.) then begin
               XX = [XX, XDA[np]]
               YY = [YY, YDA[np]]
           endif
        endfor

        XDA = XX[1:*]
        YDA = YY[1:*]

      If D eq 0 then $
       plot, XDA, YDA, $
       color=color[D], psym=sym[D], $
       xrange=range,yrange=range, $
       xtitle='SO4 [!4l!3mole/m!u3!n]', $
       ytitle='NH4 [!4l!3mole/m!u3!n]', $
       symsize=sz.sym, xstyle=2, ystyle=2, position=pos[*,IS], $
       charsize=charsize, charthick=charthick, title=sea_str[is] $
      else $
       oplot, XDA, YDA, $
       color=color[D], psym=sym[D], symsize=sz.sym

       XAX = [XAX, XDA]
       YAX = [YAX, YDA]
     endfor

;    oplot, [0,range[1]], [0,range[1]], color=1
;    oplot, [0,range[1]], [0,range[1]*0.5], color=1, line=1
    oplot, [0,range[1]*0.5], [0,range[1]], color=1, line=0

    Y = YAX[1:*]
    X = XAX[1:*]

    reg = regress_rma(X, Y, Yfit, R2)
    slope = reg[1]

    R2 = strmid(strtrim(R2,2),0,4)
    al = strmid(strtrim(slope,2),0,4)

    wid = range[1]-range[0]
    Xyouts, wid*0.7, range[1]-wid*0.1, 'R!u2!n = '+R2, color=1, alignment=0.,charthick=charthick
    Xyouts, wid*0.7, range[1]-wid*0.2, 'a = '+al, color=1, alignment=0.,charthick=charthick

    XXX = Findgen(101)*Max(X)/100.
    oplot, XXX, reg[0]+slope*XXX, color=1, line=0, thick=sz.lthick

   endfor

 End



 ;=========================================================================;
  @define_plot_size

  spec = 'SO4'

  Tracer = [26,27,29,30,31,32,33,34,35,42,43,44,45,46,47,48,49,50]

  Year   = 2001L
  RES    = 4
  TYPE   = 'S' ; 'A', 'S', 'T'
  YYMM   = Year*100L + Lindgen(12)+1L
  MTYPE  = 'GEOS3_30L'
  CATEGORY = 'IJ-AVG-$'
;  CATEGORY = 'IJ-24H-$'

  Comment = '1x1 Nested NA run for 2001'
;  Comment = 'Cooke et al. emission'

  FAC  = 1.
 ;=========================================================================;
  CASE RES of
   1 : DXDY = '1x1'
   2 : DXDY = '2x25'
   4 : DXDY = '4x5' 
  END

  Modelinfo = CTM_TYPE(MTYPE, RES=RES)
  Gridinfo  = CTM_GRID(MODELINFO)

  CYear = Strtrim(Year,2)
;  file_aird = '~rjp/Asim/DATA/aird_'+DXDY+'_'+Cyear+'.bpch'
;  file_pres = '~rjp/Asim/DATA/ps-ptop_'+DXDY+'_'+Cyear+'.bpch'

; Observations are in ug/m3
  if N_elements(improve_Obs) eq 0 then $
     improve_Obs  = improve_datainfo(year=Year)

  sites = improve_obs.siteid

  if N_elements(Improve_calc) eq 0 then begin

     ; Calculation output is in umoles/m3
     if !D.name ne 'WIN' then filter = '/users/ctm/rjp/Asim/' 

     If N_elements(file_calc) eq 0 then $
     file_calc = dialog_pickfile(filter=filter)

     read_model          ,  $
                file_calc,  $
                CATEGORY,  $
                file_aird=file_aird, $
                file_pres=file_pres, $
                YYMM=YYMM, $               
                Modelinfo=Modelinfo, $
                calc=Improve_calc, $
                obs=Improve_obs,      $
                Tracer=Tracer

  endif

  CASE TYPE OF
  'A' : Begin
  ;========================
  ; Annual plot
  ;========================
   !P.multi=[0,1,2,0,0]

   Pos = cposition(1,2,xoffset=[0.1,0.1],yoffset=[0.05,0.1], $
         xgap=0.1,ygap=0.15,order=0)

   if (!D.NAME eq 'PS') then $
       Open_device, file=SPEC+'_IMPR_'+DXDY+'_annual_'+CYEAR+'.ps', /PS, /Portrait, $
       Xoffset=0.5, yoffset=1., xsize=7.5, ysize=9

       makeplot, obs=Improve_obs, calc=Improve_calc, spec=spec, /annual, $
                 Modelinfo=Modelinfo, pos=pos[*,0],    $
                 sites=sites, fac=fac
       makeplot, obs=Improve_obs, calc=Improve_calc, spec=spec, /annual, $
                 Modelinfo=Modelinfo, /subgridoff, pos=pos[*,1],    $
                 sites=sites, fac=fac
   End

  'S' : Begin
  ;=======================
  ; Seasonal scatter plot
  ;=======================
  if (!D.NAME eq 'PS') then $
      Open_device, file=SPEC+'_IMPR_'+DXDY+'_season_'+CYEAR+'.ps', /PS, /landscape

      makeplot, obs=Improve_obs, calc=Improve_calc, spec=spec, $
                Modelinfo=Modelinfo, /season,     $
                sites=sites, fac=fac, /subgridoff
  END


  'T' : Begin
  ;=======================
  ; Timeseries plot
  ;=======================
  if (!D.NAME eq 'PS') then $
      Open_device, file=SPEC+'_IMPR_'+DXDY+'_tseries_'+CYEAR+'.ps', /PS, /landscape

      makeplot, obs=Improve_obs, calc=Improve_calc, spec=spec, $
                Modelinfo=Modelinfo, /tseries, /subgridoff,    $
                sites=sites
  END

  'D' : Begin
  ;==========================
  ; 2D map plot
  ;==========================
  if (!D.NAME eq 'PS') then $
      Open_device, file=SPEC+'_IMPR_'+DXDY+'_map_'+CYEAR+'.ps', /PS, /color, $
        /portrait, xoffset=0.5, xsize=8, ysize=10.5

      multipanel, col=1, row=2, omargin=[0.1,0.1,0.1,0.1]
      makeplot, obs=Improve_obs, calc=Improve_calc, spec=spec, $
                Modelinfo=Modelinfo, /map2d, /subgridoff,    $
                sites=sites
 
;      conc = (total(improve_calc.ocpi_conc_globe,3)           $
;           +  total(improve_calc.ocpo_conc_globe,3))*12.*1.4  $
;           + (total(improve_calc.soa1_conc_globe,3))*150.     $
;           + (total(improve_calc.soa2_conc_globe,3))*160.     $
;           + (total(improve_calc.soa3_conc_globe,3))*220.
;      conc = conc/12.
             
;      plot_region, conc, /sample, /cbar, divis=4, maxdata=3.67
        End

  ENDCASE

;  plotmonthly, obs=Improve_obs, calc=Improve_calc, spec=spec

;  makeplot, obs=improve_obs, calc=improve_calc, spec=spec, /ratiomap, /subgrid
   
;   plot2d, data=improve_obs.soil, lat=improve_obs.lat, $
;           lon=improve_obs.lon, maxdata=3, unit='!4l!3g m!u-3!n'

  xyouts, 0.95, 0.98, Comment, /normal, color=1, charsize=charsize, $
          charthick=charthick, alignment=1.

  if (!D.NAME eq 'PS') then Close_device

 End
