
;====================================================================================
 pro choose, obs=obs, calc=calc, spec=spec, data=data, conc=conc, range=range, $
             gdat=gdat

  if n_elements(spec) eq 0 then spec = 'SO4'

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
            if N_elements(calc.so4_conc_globe) ne 0 then $
               gdat = calc.so4_conc_globe*96.
            end
    'NH4' : begin
            data = obs.nh4
            conc = calc.nh4_conc*18.
            range=[0.,5.]
            if N_elements(calc.nh4_conc_globe) ne 0 then $
               gdat = calc.nh4_conc_globe*18.
            end
    'NO3' : begin
            data = obs.no3
            conc = calc.nit_conc*62.
            range=[0.,10.]
            if N_elements(calc.nit_conc_globe) ne 0 then $
               gdat = calc.nit_conc_globe*62.
            end
    'HNO3': begin
            data = obs.hno3
            conc = calc.hno3_conc*63.
            range=[0.,15.]
            end
    'EC'  : begin
            data = obs.ec
            conc = (calc.ecpi_conc+calc.ecpo_conc)*12.
            range= [0.,1.0]
            if N_elements(calc.ecpi_conc_globe) ne 0 then $
               gdat = (calc.ecpi_conc_globe+calc.ecpo_conc_globe)*12.
            end
    'OMC' : begin
            data = obs.oc * 1.4
            conc = (calc.ocpi_conc+calc.ocpo_conc)*12.*1.4 $
                 + (calc.soa1_conc)*150.                   $
                 + (calc.soa2_conc)*160.                   $
                 + (calc.soa3_conc)*220.
            range=[0.,6.]
            if N_elements(calc.ocpi_conc_globe) ne 0 then $
               gdat = (calc.ocpi_conc_globe+calc.ocpo_conc_globe)*12.*1.4 $
                    + (calc.soa1_conc_globe)*150.                   $
                    + (calc.soa2_conc_globe)*160.                   $
                    + (calc.soa3_conc_globe)*220.
            end
    'THNO3': begin
            data = obs.hno3 + obs.no3
            conc = calc.hno3_conc*63. + calc.nit_conc*62.
            range=[0.,10.]
            Unit = ' [!4l!3g/m!u3!n]'
            if N_elements(calc.nit_conc_globe) ne 0 then $
               gdat = calc.hno3_conc_globe*63. + calc.nit_conc_globe*62.

            end

    'DUST': begin
            data = obs.soil
            conc = (calc.dst1_conc + calc.dst2_conc*0.38)*29.
            range= [0.,5.0]
            Unit = ' [!4l!3g/m!u3!n]'
            if N_elements(calc.dst1_conc_globe) ne 0 then $
               gdat = (calc.dst1_conc_globe + calc.dst1_conc_globe*0.38)*29.

            end
  endcase


 end

;=====================================================================

 function process,  $
               Modelinfo=Modelinfo, data=data, range=range, $
               time=time, lat=lat, lon=lon, spec=spec, gdat=gdat, $
               OFFSET=OFFSET
               

   If N_elements(Modelinfo) eq 0 then Modelinfo = CTM_TYPE('GEOS3', res=2)

   grid = ctm_grid(modelinfo)

   Nmon = N_elements(time)
   YYMM = time
   Mon  = YYMM-(YYMM/100L)*100L

   OFFSET = OFFSET

   fd2d_glb = fltarr(grid.imx, grid.jmx)

   If N_elements(gdat)      ne 0 then begin
      fld = total(gdat,3)/float(Nmon)
      DIM = size(fld)

      X1 = OFFSET[0]
      X2 = X1+DIM[1]-1L
      Y1 = OFFSET[1]
      Y2 = Y1+DIM[2]-1L
      fd2d_glb[X1:X2,Y1:Y2] = fld
      Undefine, fld
   end

;   multipanel, col=1, row=3
   Color = [1,1,1]

   Sea_str = ['DJF','MAM','JJA','SON']
   Mon_str = ['JAN','FEB','MAR','APR', $
              'MAY','JUN','JUL','AUG', $
              'SEP','OCT','NOV','DEC']

   fd2d_obs = fltarr(grid.imx,grid.jmx)
   divi     = replicate(0.,grid.imx,grid.jmx)

   For IM = 0, NMON-1 do begin    ; hardwired for 12 months
       print, 'Colleting data of '+mon_str[MON[IM]-1]

       X = Reform(Data[*, MON[IM]-1])    
       for N = 0, N_elements(X)-1 do begin
           CTM_INDEX, ModelInfo, I, J, center = [lat(N),lon(N)], $
                      /non_interactive
           If X[N] gt 0. then begin
              FD2D_obs[I-1,J-1] = FD2D_obs[I-1,J-1] + X[N]
              DIVI[I-1,J-1]     = DIVI[I-1,J-1] + 1.
           Endif
       endfor
   Endfor  ; IM

   for J = 0, grid.jmx-1 do begin
   for I = 0, grid.imx-1 do begin
       IF DIVI[I,J] gt 0. then begin
          FD2D_obs[I,J] = FD2D_obs[I,J]/float(DIVI[I,J])
       endif
   endfor
   endfor

   Maxdata = -999.
   for J = 0, grid.jmx-1 do begin
   for I = 0, grid.imx-1 do begin
       IF (grid.ymid[j] ge   20. and grid.ymid[j] le  55.) and $
          (grid.xmid[i] ge -125. and grid.xmid[i] le -60.) then begin
          MAXDATA       = MAXDATA > (fd2d_obs[I,J] > fd2d_glb[I,J])
       Endif
   endfor
   endfor


   fld = {globe:fd2d_glb, obs:fd2d_obs, maxdata:maxdata}

   return, fld   

 End

;============================================================================

 pro makeplot, spec, improve_obs, castnet_obs, castnet_calc, modelinfo, $
     NoGXLabels=NoGXLabels, NoGYLabels=NoGYLabels, unit=unit, margin=margin, $
     cbar=cbar

  @define_plot_size

  if spec eq 'SO4' or spec eq 'OMC' or spec eq 'EC' or spec eq 'DUST' or $
     spec eq 'NO3' then begin

  choose, obs=improve_obs, calc=castnet_calc, spec=spec, $
          data=data, conc=conc, gdat=gdat

  fd2d_impr = process(Modelinfo=Modelinfo, data=data, $
                  time=castnet_calc.time,  $
                  lat= improve_obs.lat,    $ 
                  lon= improve_obs.lon,    $
                  spec=spec, gdat=gdat, OFFSET=castnet_calc.offset)
  endif

  if spec eq 'NH4' then begin

  choose, obs=castnet_obs, calc=castnet_calc, spec=spec, $
          data=data, conc=conc, gdat=gdat

  fd2d_cast = process(Modelinfo=Modelinfo, data=data, $
                  time=castnet_calc.time, $
                  lat= castnet_obs.lat,    $ 
                  lon= castnet_obs.lon,    $
                  spec=spec, gdat=gdat, OFFSET=castnet_calc.offset)
  ENDIF

  case spec of
    'SO4' : begin
            Name  = 'SO!d4!u2-!n'
            Maxd  = 6.0
            Maxo  = Maxd
            geos2d= fd2d_impr.globe
            annot = ['0','2','4','6','8']
            end
    'NH4' : begin
            Name  = 'NH!d4!u+!n'
            Maxd  = 6.0
            Maxo  = Maxd
            geos2d= fd2d_cast.globe
            annot = ['0','1','2','3','4']
            end
    'NO3' : begin
            Name  = 'NO!d3!u-!n'
            Maxd  = 6.0
            Maxo  = Maxd 
		geos2d= fd2d_impr.globe
            annot = ['0','1.5','3','4.5','6']
            end
    'EC'  : begin
            Name  = 'EC'
            Maxd  = 1.
            Maxo  = Maxd
            geos2d= fd2d_impr.globe
            end           
    'OMC'  : begin
            Name  = 'OMC'
            Maxd  = 6
            Maxo  = Maxd
            geos2d= fd2d_impr.globe
            end  

     'DUST': BEGIN
            Name  = 'SOIL DUST'
            Maxd  = 6
            Maxo  = Maxd
            end  

     else : begin
            Print, 'There is no such case'
            stop
            end
  endcase

   
   Limit   = [ 25., -130., 50., -60.]

   Ndiv = 4
   csfac=charsize
   CBformat = '(F4.1)'
   C_size  = 1.5
   C_thick = 4
   !P.charthick=4

   multipanel, position=p

  ; Model
   plot_region, geos2d, /sample, divis=Ndiv, unit=unit, $
     maxdata=maxd, mindata=0., min_valid=0.0001, csfac=csfac, $
     margin=margin, cbformat=cbformat, position=[0.,0.,1.,1.], $
     NoGXLabels=NoGXLabels[0], NoGYLabels=NoGYLabels[0], limit=limit

  if spec eq 'SO4' or spec eq 'OMC' or spec eq 'EC' or spec eq 'DUST' or $
     spec eq 'NO3' then begin
  ; IMPROVE
   Plot_region, fd2d_impr.obs, /sample, divis=Ndiv, unit=unit, $
     maxdata=maxo, mindata=0., min_valid=0.0001,  $
     margin=margin, cbformat=cbformat, position=[0.,0.,1.,1.],$
     NoGXLabels=NoGXLabels[1], NoGYLabels=NoGYLabels[1], limit=limit

  endif

  if spec eq 'NH4' then begin
  ; CASTNET
   Plot_region, fd2d_cast.obs, /sample, divis=Ndiv, unit=unit, $
     maxdata=maxo, mindata=0., min_valid=0.0001,  $
     margin=margin, cbformat=cbformat, position=[0.,0.,1.,1.], $
     NoGXLabels=NoGXLabels[1], NoGYLabels=NoGYLabels[1], limit=limit
  endif

  if keyword_set(cbar) then begin
  ; Color bar

   C = MYCT_Defaults()
   Bottom  = C.BOTTOM
   NColors = 255L-Bottom
   CBColor   = C.BLACK

   dp = p[2]-p[0]
   CBPosition = [P[0]+0.1*dp,0.1,P[2]-0.1*dp,0.12]
   CBPosition = [0.2,0.07,0.7,0.11]

   ColorBar, Max=maxo,      Min=0., NColors=NColors,     $
            Bottom=Bottom, Color=CBColor, Position=CBPosition, $
            Unit=Unit,      Divisions=NDiv, Log=Log,             $
            Format=CBFormat,  Charsize=charsize,       $
            C_Colors=CC_Colors, C_Levels=C_Levels, Charthick=charthick;, $
;            annotation=annot

  end

  xyouts, 0.5*(p[0]+p[2]), 0.71, Name, alignment=0.5, color=1, $
     charsize=charSize, charthick=charthick, /normal

 End

;============================================================================

 function a_mean, data, lat=lat

 dim = size(data,/dim)
 avg = fltarr(dim[0])

 for n = 0, dim[0]-1 do begin

   fld = reform(data[n,*])
   iii = where(fld gt 0.)
   if iii[0] ne -1 then avg[n] = mean(fld[iii]) else avg[n] = 'NaN'
   if lat[n] lt 25. then avg[n] = 'NaN'

 end

 return, avg

 end

;=====================================

 pro drawplot, spec, improve_obs, castnet_obs, castnet_calc, modelinfo, $
     NoGXLabels=NoGXLabels, NoGYLabels=NoGYLabels, unit=unit, margin=margin, $
     cbar=cbar

  @define_plot_size

  if spec eq 'SO4' or spec eq 'OMC' or spec eq 'EC' or spec eq 'DUST' or $
     spec eq 'NO3' then begin

  choose, obs=improve_obs, calc=castnet_calc, spec=spec, $
          data=data, conc=conc, gdat=gdat

  fd2d_impr = process(Modelinfo=Modelinfo, data=data, $
                  time=castnet_calc.time,  $
                  lat= improve_obs.lat,    $ 
                  lon= improve_obs.lon,    $
                  spec=spec, gdat=gdat, OFFSET=castnet_calc.offset)

  lat = improve_obs.lat
  lon = improve_obs.lon
  fld = a_mean( data, lat=lat )

  id  = where(finite(fld) eq 1)
  fld = fld[id]
  lat = lat[id]
  lon = lon[id]

  endif

  if spec eq 'NH4' then begin

  choose, obs=castnet_obs, calc=castnet_calc, spec=spec, $
          data=data, conc=conc, gdat=gdat

  fd2d_cast = process(Modelinfo=Modelinfo, data=data, $
                  time=castnet_calc.time, $
                  lat= castnet_obs.lat,    $ 
                  lon= castnet_obs.lon,    $
                  spec=spec, gdat=gdat, OFFSET=castnet_calc.offset)

  lat = castnet_obs.lat
  lon = castnet_obs.lon
  fld = a_mean( data, lat=lat )

  id  = where(finite(fld) eq 1)
  fld = fld[id]
  lat = lat[id]
  lon = lon[id]

  ENDIF

  case spec of
    'SO4' : begin
            Name  = 'SO!d4!u2-!n'
            Maxd  = 6.0
            Maxo  = Maxd
            geos2d= fd2d_impr.globe
            annot = ['0','2','4','6','8']
            end
    'NH4' : begin
            Name  = 'NH!d4!u+!n'
            Maxd  = 6.0
            Maxo  = Maxd
            geos2d= fd2d_cast.globe
            annot = ['0','1','2','3','4']
            end
    'NO3' : begin
            Name  = 'NO!d3!u-!n'
            Maxd  = 6.0
            Maxo  = Maxd 
		geos2d= fd2d_impr.globe
            annot = ['0','1.5','3','4.5','6']
            end
    'EC'  : begin
            Name  = 'EC'
            Maxd  = 1.
            Maxo  = Maxd
            geos2d= fd2d_impr.globe
            end           
    'OMC'  : begin
            Name  = 'OMC'
            Maxd  = 6
            Maxo  = Maxd
            geos2d= fd2d_impr.globe
            end  

     'DUST': BEGIN
            Name  = 'SOIL DUST'
            Maxd  = 6
            Maxo  = Maxd
            end  

     else : begin
            Print, 'There is no such case'
            stop
            end
  endcase

   
   Limit   = [ 25., -130., 50., -60.]
  LatRange = [ Limit[0], Limit[2] ]
  LonRange = [ Limit[1], Limit[3] ]

   Ndiv = 4
   csfac=charsize
   CBformat = '(F4.1)'
   C_size  = 1.5
   C_thick = 4
   !P.charthick=4

   multipanel, position=p

  ; Model
   plot_region, geos2d, /sample, divis=Ndiv, unit=unit, $
     maxdata=maxd, mindata=0., min_valid=0.0001, csfac=csfac, $
     margin=margin, cbformat=cbformat, position=[0.,0.,1.,1.], $
     NoGXLabels=NoGXLabels[0], NoGYLabels=NoGYLabels[0], limit=limit

  ; IMPROVE or Castnet

   multipanel, position=p
   ;---- observation----
   map_set, 0, 0, color=1, /contine, limit=limit, /usa,$
   position=p, /noerase

 
   C      = Myct_defaults()
   Bottom = C.Bottom
   Ncolor = 255L-Bottom
   csfac  = 1.2

   C_colors = bytscl( fld, Min=0, Max=Maxd, $
        	          Top = Ncolor) + Bottom

   Map_Labels, LatLabel, LonLabel,              $
         Lats=Lats,         LatRange=LatRange,     $
         Lons=Lons,         LonRange=LonRange,     $
         NormLats=NormLats, NormLons=NormLons,     $
         /MapGrid,          _EXTRA=e


  Gylabel = 1L-NoGYLabels[1]
  if (Gylabel) then $
    XYOutS, NormLats[0,*], NormLats[1,*], LatLabel, $
            Align=1.0, Color=1, /Normal, charsize=csfac, charthick=charthick

  Gxlabel = 1L-NoGXLabels[1]
  if (Gxlabel) then $
    XYOutS, NormLons[0,*], NormLons[1,*], LonLabel, $
            Align=0.5, Color=1, /Normal, charsize=csfac, charthick=charthick


  plots, lon, Lat, color=c_colors, psym=8, symsize=symsize

;  map_continents, /usa, color=1


  if keyword_set(cbar) then begin
  ; Color bar

   C = MYCT_Defaults()
   Bottom  = C.BOTTOM
   NColors = 255L-Bottom
   CBColor   = C.BLACK

   dp = p[2]-p[0]
   CBPosition = [P[0]+0.1*dp,0.1,P[2]-0.1*dp,0.12]
   CBPosition = [0.2,0.07,0.7,0.11]

   ColorBar, Max=maxo,      Min=0., NColors=NColors,     $
            Bottom=Bottom, Color=CBColor, Position=CBPosition, $
            Unit=Unit,      Divisions=NDiv, Log=Log,             $
            Format=CBFormat,  Charsize=charsize,       $
            C_Colors=CC_Colors, C_Levels=C_Levels, Charthick=charthick;, $
;            annotation=annot

  end

  xyouts, 0.5*(p[0]+p[2]), 0.71, Name, alignment=0.5, color=1, $
     charsize=charSize, charthick=charthick, /normal

 End

 ;=========================================================================;
  @define_plot_size
  erase

  spec = 'SO4'

  Tracer = [26,27,29,30,31,32,33,34,35,42,43,44,45,46,47,48,49,50]

  Year   = 2001L
  RES    = 1
  TYPE   = 'D' ; 'A', 'S', 'T'
  YYMM   = Year*100L + Lindgen(12)+1L
  MTYPE  = 'GEOS3_30L'
  CATEGORY = 'IJ-24H-$'

  Comment = '1x1 Nested NA run for 2001'

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

; Observations are in ug/m3
  If N_elements(IMPROVE_Obs) eq 0 then $
     improve_Obs  = improve_datainfo(year=Year)

  If N_elements(Castnet_Obs) eq 0 then $
     Castnet_Obs  = castnet_datainfo(year=Year)

  If N_elements(castnet_calc) eq 0 then begin

     ; Calculation output is in umoles/m3
     if !D.name ne 'WIN' then filter = '/users/ctm/rjp/Asim/' 

     file_calc = '~rjp/Asim/run_v7-02-01_NA_nested_1x1/STDNEW_2001_01-12.1x1.bpch'

     read_model,             $
        file_calc,           $
        CATEGORY,            $
        Tracer=Tracer,       $
        file_aird=file_aird, $
        file_pres=file_pres, $
        YYMM = YYMM,         $               
        Modelinfo=Modelinfo, $
        calc=castnet_calc,   $
        obs=castnet_obs,     $
        /all, fixz=0L

  endif

  if (!D.Name eq 'PS') then $
      Open_device, file='fig01_ioa_2dplot.ps', /ps, /color, /landscape, $
       encapsulated=0

   omargin = [ 0.05, 0.25, 0.17, 0.3 ]
   Margin  = [ 0.01, 0.01, 0.01, 0.01 ]
   !p.multi[4] = 1  ; column major
   multipanel, row=2, col=3, omargin=omargin, margin=margin


  drawplot, 'SO4', improve_obs, castnet_obs, castnet_calc, modelinfo, $
    NoGXLabels=[1,0], NoGYLabels=[0,0], margin=margin

  multipanel, /advance
  drawplot, 'NO3', improve_obs, castnet_obs, castnet_calc, modelinfo, $
    NoGXLabels=[1,0], NoGYLabels=[1,1], margin=margin

  multipanel, /advance
  drawplot, 'NH4', improve_obs, castnet_obs, castnet_calc, modelinfo, $
    NoGXLabels=[1,0], NoGYLabels=[1,1], unit='!C[!4l!3g m!u-3!n]',    $
    margin=margin

   Ndiv = 4
   csfac=charsize
   CBformat = '(I3)'
   C_size  = 1.5
   C_thick = 4
   !P.charthick=4
   maxo = 6
   unit='!C[!4l!3g m!u-3!n]'

   C = MYCT_Defaults()
   Bottom  = C.BOTTOM
   NColors = 255L-Bottom
   CBColor   = C.BLACK

   CBPosition = [0.2,0.18,0.7,0.21]

   ColorBar, Max=maxo,      Min=0., NColors=NColors,     $
             Bottom=Bottom, Color=CBColor, Position=CBPosition, $
             Unit=Unit,      Divisions=NDiv, Log=Log,             $
             Format=CBFormat,  Charsize=charsize,       $
             C_Colors=CC_Colors, C_Levels=C_Levels, Charthick=charthick

;;;;;;;;;;;;;;;;;;;;;
; labelling 
;;;;;;;;;;;;;;;;;;;

   Xloc = 0.832
   YLOC = [0.58, 0.35]
   TAG  = ['GEOS-Chem','OBSERVATIONS']

   FOR D = 0, N_elements(YLOC)-1 DO $
     xyouts, Xloc, YLOC[D], TAG[D], color=1, /normal, $
     charsize=CharSize, charthick=Charthick

  if (!D.NAME eq 'PS') then Close_device
 End
