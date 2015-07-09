 pro draw, X, Y, X1, Y1, range, R2, slope, const, pos, ytag, xtag


   If !D.name eq 'PS' then begin
     charthick=3. 
     charsize=1.7
     cfac  = 0.7
     sz = {sym:0.8,lthick:4.}
     symsize=[1.0,1.0]
   end else begin
     charthick=1.9
     charsize=1.2
     cfac   = 1.2
     sz = {sym:1.0,lthick:2}
     symsize=[1.0,1.0]
   end


   ; Define Usersymbol
   A = FINDGEN(33) * (!PI*2/32.)
   USERSYM, COS(A), SIN(A) ; , /FILL

   Sea_str = ['DJF','MAM','JJA','SON']
   sym = [1,8]

   yst    = strarr(N_elements(ytag))
   yst(*) = ' '
   Ylabel = ytag
   Xlabel = xtag

       plot, X, Y, color=1, psym=1, xrange=range, yrange=range, $
         symsize=symsize[0], xstyle=1, ystyle=1, position=pos, $
         charsize=charsize, charthick=charthick, ycharsize=2, xcharsize=2, $
         YTickName=ylabel, yticks=n_elements(ytag)-1,  $
         XTickName=xlabel, xticks=n_elements(xtag)-1 

       oplot, X1, Y1, psym=8, symsize=symsize[1], color=1

       oplot, [range[0],range[1]], [range[0],range[1]], color=1
;       oplot, [range[0],range[1]], [range[0]*0.5,range[1]*0.5], color=1, line=1
;       oplot, [range[0]*0.5,range[1]*0.5], [range[0],range[1]], color=1, line=1

       if R2 gt 0.01 then R2 = strmid(strtrim(R2,2),0,4) else $
          R2 = '0.0'
       al = strmid(strtrim(slope,2),0,4)
       ab = strmid(strtrim(abs(const),2),0,4)
       if const lt 0.0 then XX = 'x-' else XX = 'x+'

       wid = range[1]-range[0]
       Xyouts, wid*0.45,  range[1]-wid*0.9, 'R!u2!n = '+R2,    color=1,  $
         alignment=0.,charthick=charthick,charsize=charsize*cfac
       Xyouts, wid*0.05, range[1]-wid*0.2, 'y = '+al+XX+ab, color=1,  $
         alignment=0.,charthick=charthick,charsize=charsize*cfac

       XA = (Max(X) > MAx(X1))*1.3
       XXX = Findgen(101)*Max(XA)/100.
;       XXX = Findgen(101)*10./100.
       oplot, XXX, const+slope*XXX, color=1, line=0, thick=sz.lthick

  ratio1 = Y/X
  ratio2 = Y1/X1
  num1 = where(ratio1 gt 2 or ratio1 lt 0.5)
  num2 = where(ratio2 gt 2 or ratio2 lt 0.5)
;  print, float(N_elements(num1)+N_elements(num2))
;  print, float(N_elements(ratio1)+N_elements(ratio2))
  print, R2, float(N_elements(num1)+N_elements(num2))/ $
         float(N_elements(ratio1)+N_elements(ratio2)) * 100.


 end


;==========================================================================

function  process, $
          Modelinfo=Modelinfo, data=data, conc=conc, range=range, $
          time=time, lat=lat, lon=lon, spec=spec, $
          Subgridoff=subgridoff, bdlon=bdlon

   If N_elements(Bdlon) eq 0 then begin
      bdLon  = [-180., 180.]
      sym    = 8
   Endif else sym = [1,8]

   If N_elements(Color) eq 0 then Color  = [1,4]
   If N_elements(Data) ne 0 then Dim = size(Data) else return, 0

   If N_elements(Modelinfo) eq 0 then Modelinfo = CTM_TYPE('GEOS3', res=2)
   grid = ctm_grid(modelinfo)

   Nmon = N_elements(time)
   YYMM = time
   Mon  = YYMM-(YYMM/100L)*100L

   If !D.name eq 'PS' then begin
     charthick=4. 
     charsize= 1.
   end else begin
     charthick=1. 
     charsize=1.2
   end

   Align = 0.5

   Sea_str = ['DJF','MAM','JJA','SON']
   region  = ['West','East']
   Mon_str = ['JAN','FEB','MAR','APR', $
              'MAY','JUN','JUL','AUG', $
              'SEP','OCT','NOV','DEC']

   sz = {sym:1.0,lthick:2}
   If (!D.name eq 'PS') then sz = {sym:0.8,lthick:4.}

   ; Define Usersymbol
   A = FINDGEN(33) * (!PI*2/32.)
   USERSYM, COS(A), SIN(A) ; , /FILL

   Color = [1,1,1]
   MSEA = [[12,1,2],[3,4,5],[6,7,8],[9,10,11]]


 ; Looping for four seasons
   for D = 0, 3 do begin

    BIAS = 0.
    XAX = 0.
    YAX = 0.

    For L = 0, N_elements(bdlon)-2 do begin
      POT = where(lon ge bdLon[L] and lon lt bdLon[L+1])

      If Keyword_set(subgridoff) then begin

         ; Rebin the data on model grid to remove sub-grid variability that 
         ; can be resolved in the model properly.     

         XX = 0. & YY = 0.

                fd2d_obs = fltarr(grid.imx,grid.jmx)
                fd2d_cal = fd2d_obs
                divi     = replicate(0.,grid.imx,grid.jmx)

         ; choose corresponding month for each season
         For IM = 0, NMON-1 do begin  

            res = where(MON(IM) eq MSEA[*,D])
            if (res[0] ne -1) then begin
                print, 'Colleting data of '+mon_str[MON[IM]-1]+' for '+sea_str[D]
                X = Reform(Data[POT, MON[IM]-1])
                Y = Reform(Conc[POT, IM])
                

                for SN = 0, N_elements(POT)-1 do begin
                     N = POT[SN]
                    CTM_INDEX, ModelInfo, I, J, center = [lat(N),lon(N)], $
                               /non_interactive
                    If X[SN] gt 0. then begin
                       FD2D_obs[I-1,J-1] = FD2D_obs[I-1,J-1] + X[SN]
                       FD2D_cal[I-1,J-1] = FD2D_cal[I-1,J-1] + Y[SN]
                       DIVI[I-1,J-1]     = DIVI[I-1,J-1] + 1.
                    Endif
                endfor


            endif ; res
         Endfor  ; IM

                ; Seasonal mean
               for J = 0, grid.jmx-1 do begin
               for I = 0, grid.imx-1 do begin
                   IF DIVI[I,J] gt 0. then begin
                   XX = [XX, FD2D_obs[I,J]/float(DIVI[I,J])]
                   YY = [YY, FD2D_cal[I,J]/float(DIVI[I,J])]
                   endif
               endfor
               endfor

        If N_elements(XX) gt 1 then begin
           X = XX[1:*]  &  Y = YY[1:*] 
        end else begin
           Print, 'No mathching data found for '+sea_str[D]
           X = Replicate(0., 5)  &  Y = X  
        end

      Endif Else begin  ; Not subgridoff

       ; Dumping all data for each season
         XDA = 0.  &  YDA = 0.
         FOR IM = 0, NMON-1 DO BEGIN
            res = where(MON(IM) eq MSEA[*,D])
            if (res[0] ne -1) then begin
                print, 'Colleting data of '+mon_str[MON[IM]-1]+' for '+sea_str[D]
                YDA = [YDA, Reform(CONC[POT, IM])]
                XDA = [XDA, Reform(DATA[POT, MON[IM]-1])]
            endif            
         Endfor

      ; Check missing data and remove it

        If N_elements(XDA) gt 1 then Begin
           XX = 0.
           YY = 0.
           For np = 0, N_elements(XDA)-1 do begin
              if (XDA[np] gt 0.) then begin
                  XX = [XX, XDA[np]]
                  YY = [YY, YDA[np]]
              endif
           endfor
           X = XX[1:*]  &  Y = YY[1:*]
        End Else begin
           Print, 'No mathching data found for '+sea_str[D]
           X = Replicate(0., 5)  &  Y = X        
        End

      Endelse

      If ( D eq 0 ) and ( L eq 0 ) then $
          result = create_struct('Obs_'+sea_str[D]+'_'+region[L], X, $
                                 'Cal_'+sea_str[D]+'_'+region[L], Y  ) else $
          result = create_struct(result, $
                                 'Obs_'+sea_str[D]+'_'+region[L], X, $
                                 'Cal_'+sea_str[D]+'_'+region[L], Y  )
    
        XAX = [XAX, X]
        YAX = [YAX, Y]

    Endfor ; L

       X = XAX[1:*]
       Y = YAX[1:*]

       rma   = lsqfitgm(X, Y)
       slope = rma[0]
       const = rma[1]
       R2    = rma[2]^2
    
       print, R2


       result = create_struct(result, $
                              'r2_'+sea_str[D], r2,    $
                              'slope_'+sea_str[D], slope, $
                              'const_'+sea_str[D], const  )
    
   endfor ; sea


    XAX = 0.
    YAX = 0.

    For L = 0, N_elements(bdlon)-2 do begin
      POT = where(lon ge bdLon[L] and lon lt bdLon[L+1])

      If Keyword_set(subgridoff) then begin

         ; Rebin the data on model grid to remove sub-grid variability that 
         ; can be resolved in the model properly.     

         XX = 0. & YY = 0.
         fd2d_obs = fltarr(grid.imx,grid.jmx)
         fd2d_cal = fd2d_obs
         divi     = replicate(0.,grid.imx,grid.jmx)

         ; make annual or average concentrations for whatever months 
         For IM = 0, NMON-1 do begin  

             print, 'Colleting data of '+mon_str[MON[IM]-1]
             X = Reform(Data[POT, MON[IM]-1])
             Y = Reform(Conc[POT, IM])
                
             ; Find the nearby grid and put data in 
             for SN = 0, N_elements(POT)-1 do begin
                  N = POT[SN]
                 CTM_INDEX, ModelInfo, I, J, center = [lat(N),lon(N)], $
                            /non_interactive
                 If X[SN] gt 0. then begin
                    FD2D_obs[I-1,J-1] = FD2D_obs[I-1,J-1] + X[SN]
                    FD2D_cal[I-1,J-1] = FD2D_cal[I-1,J-1] + Y[SN]
                    DIVI[I-1,J-1]     = DIVI[I-1,J-1] + 1.
                 Endif
             endfor
         Endfor  ; IM

         for J = 0, grid.jmx-1 do begin
         for I = 0, grid.imx-1 do begin
             IF DIVI[I,J] gt 0. then begin
                XX = [XX, FD2D_obs[I,J]/float(DIVI[I,J])]
                YY = [YY, FD2D_cal[I,J]/float(DIVI[I,J])]
             endif
         endfor
         endfor

        If N_elements(XX) gt 1 then begin
           X = XX[1:*]  &  Y = YY[1:*] 
        end else begin
           Print, 'No mathching data found' 
           X = Replicate(0., 5)  &  Y = X  
        end

      Endif Else begin  ; Not subgridoff

       ; Average all data over 12 months or whatever months interval given
         XDA = Fltarr(N_elements(POT))
         YDA = XDA
         DIV = XDA

         FOR IM = 0, NMON-1 DO BEGIN
             print, 'Colleting data of '+mon_str[MON[IM]-1]
             XTEMP = Reform(DATA[POT, MON[IM]-1])
             YTEMP = Reform(CONC[POT, IM])
             For ND = 0, N_elements(POT)-1 do begin               
                 IF ( XTEMP[ND] gt 0.) then begin
                     XDA[ND] = XDA[ND] + XTEMP[ND]
                     YDA[ND] = YDA[ND] + YTEMP[ND]
                     DIV[ND] = DIV[ND] + 1.
                 Endif
             Endfor
         Endfor

         For ND = 0, N_elements(POT)-1 do begin
             IF (DIV[ND] gt 0.) then begin
                 XDA[ND] = XDA[ND]/DIV[ND]
                 YDA[ND] = YDA[ND]/DIV[ND]
             End
         Endfor

         X = XDA
         Y = YDA

      Endelse
    
       XAX = [XAX, X]
       YAX = [YAX, Y]

       result = create_struct(result, $
                              'Obs_annual_'+region[L], X, $
                              'Cal_annual_'+region[L], Y  )
    Endfor ; L

       X = XAX[1:*]
       Y = YAX[1:*]

       rma   = lsqfitgm(X, Y)
       slope = rma[0]
       const = rma[1]
       R2    = rma[2]^2

       result = create_struct(result, $
                              'r2_annual', r2,    $
                              'slope_annual', slope, $
                              'const_annual', const  )
    
   return, result

 End

;
; Panel starts
;

 ;=========================================================================;
  @define_plot_size

  Tracer   = [26,27,29,30,31,32,33,34,35,42,43,44,45,46,47,48,49,50]
  Year     = 2001L
  RES      = 1
  YYMM     = Year*100L + Lindgen(12)+1L
  MTYPE    = 'GEOS3_30L'
  CATEGORY = 'IJ-24H-$'
  Comment  = '1x1 Nested NA run for 2001'
  bdlon    = [-120.,-95.,-50.]
  FAC  = 1.

 ; LYE145, VOY413 are found to have outliers and so correctted. 
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

  file_calc = '~rjp/Asim/run_v7-02-01_NA_nested_1x1/STDNEW_2001_01-12.1x1.bpch'

  If N_elements(improve_calc) eq 0 then begin

     read_model,             $
        file_calc,           $
        CATEGORY,            $
        Tracer=Tracer,       $
        file_aird=file_aird, $
        file_pres=file_pres, $
        YYMM = YYMM,         $               
        Modelinfo=Modelinfo, $
        calc=improve_calc,   $
        obs=improve_obs

  endif

  If N_elements(castnet_calc) eq 0 then begin

     read_model,             $
        file_calc,           $
        CATEGORY,            $
        Tracer=Tracer,       $
        file_aird=file_aird, $
        file_pres=file_pres, $
        YYMM = YYMM,         $               
        Modelinfo=Modelinfo, $
        calc=castnet_calc,   $
        obs=castnet_obs

  endif

  if N_elements(imp_so4) eq 0 then begin
     data    = improve_obs.so4
     conc    = improve_calc.so4_conc*96.
     time    = improve_calc.time
     lat     = improve_obs.lat  
     lon     = improve_obs.lon
     imp_so4 = process(Modelinfo=Modelinfo, data=data, conc=conc, $
            time=time, lat=lat, lon=lon, /subgridoff,         $
            bdlon=bdlon)
  end

  if N_elements(imp_no3) eq 0 then begin
     data    = improve_obs.no3
     conc    = improve_calc.nit_conc*62.
     time    = improve_calc.time
     lat     = improve_obs.lat  
     lon     = improve_obs.lon
     imp_no3 = process(Modelinfo=Modelinfo, data=data, conc=conc, $
            time=time, lat=lat, lon=lon, /subgridoff,         $
            bdlon=bdlon)
  end

  if n_elements(cas_nh4) eq 0 then begin
     data    = castnet_obs.nh4
     conc    = castnet_calc.nh4_conc*18.
     time    = castnet_calc.time
     lat     = castnet_obs.lat  
     lon     = castnet_obs.lon
     cas_nh4 = process(Modelinfo=Modelinfo, data=data, conc=conc, $
            time=time, lat=lat, lon=lon, /subgridoff,         $
            bdlon=bdlon)
  end

  conrange = [0.1,12.]
  cytag1  = ['0','4','8','12  ']
  cytag2  = [' 0','4','8','12']
  cytag   = ['0','4','8','12']
  cynul   = [' ',' ',' ',' ']
  cxtag   = cytag
  cxnul   = cynul

  no3range = [0., 4.]
  no3tag   = ['0','2','4']
  no3nul   = [' ',' ',' ']

  nh4range = [0., 4.]
  nh4tag   = ['0','2','4']
  nh4nul   = [' ',' ',' ']

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;Plotting begins;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  !X.THICK=4
  !Y.THICK=4

   !P.multi=[0,3,5,0,0]

   Pos = cposition(3,5,xoffset=[0.1,0.08],yoffset=[0.05,0.07], $
         xgap=0.05,ygap=0.01,order=1)

   Dx = 0.0


   if (!D.NAME eq 'PS') then $
       Open_device, file='ioa_us_'+DXDY+'_scatter.ps', /PS, /Portrait, $
       xoffset=0.5, yoffset=0.5, xsize=7.5, ysize=10, encapsulated=0

       N = -1
   ;==================================================
   ; IMPROVE sulfate
   ;==================================================
   ;1) Annual scatter
       X     = imp_so4.obs_annual_west
       y     = imp_so4.cal_annual_west
       x1    = imp_so4.obs_annual_east
       y1    = imp_so4.cal_annual_east
       R2    = imp_so4.r2_annual
       slope = imp_so4.slope_annual
       const = imp_so4.const_annual
       range = conrange
       ytag  = cytag
       xtag  = cxnul

       draw, X, Y, X1, Y1, range, R2, slope, const, pos[*,0], ytag, xtag

    ;2) DJF
       X     = imp_so4.obs_djf_west
       y     = imp_so4.cal_djf_west
       x1    = imp_so4.obs_djf_east
       y1    = imp_so4.cal_djf_east
       R2    = imp_so4.r2_djf
       slope = imp_so4.slope_djf
       const = imp_so4.const_djf
       range = conrange
       ytag  = cytag
       xtag  = cxnul

       draw, X, Y, X1, Y1, range, R2, slope, const, pos[*,1], ytag, xtag     

    ;3) MAM
       X     = imp_so4.obs_mam_west
       y     = imp_so4.cal_mam_west
       x1    = imp_so4.obs_mam_east
       y1    = imp_so4.cal_mam_east
       R2    = imp_so4.r2_mam
       slope = imp_so4.slope_mam
       const = imp_so4.const_mam
       range = conrange
       ytag  = cytag
       xtag  = cxnul

       draw, X, Y, X1, Y1, range, R2, slope, const, pos[*,2], ytag, xtag

    ;4) JJA
       X     = imp_so4.obs_jja_west
       y     = imp_so4.cal_jja_west
       x1    = imp_so4.obs_jja_east
       y1    = imp_so4.cal_jja_east
       R2    = imp_so4.r2_jja
       slope = imp_so4.slope_jja
       const = imp_so4.const_jja
       range = conrange
       ytag  = cytag
       xtag  = cxnul

       draw, X, Y, X1, Y1, range, R2, slope, const, pos[*,3], ytag, xtag

    ;5) SON
       X     = imp_so4.obs_son_west
       y     = imp_so4.cal_son_west
       x1    = imp_so4.obs_son_east
       y1    = imp_so4.cal_son_east
       R2    = imp_so4.r2_son
       slope = imp_so4.slope_son
       const = imp_so4.const_son
       range = conrange
       ytag  = cytag
       xtag  = cxtag

       draw, X, Y, X1, Y1, range, R2, slope, const, pos[*,4], ytag, xtag

       ;===========================================
       ; improve nitrate
       ;===========================================
       ;1) annual
       X     = imp_no3.obs_annual_west
       y     = imp_no3.cal_annual_west
       x1    = imp_no3.obs_annual_east
       y1    = imp_no3.cal_annual_east
       R2    = imp_no3.r2_annual
       slope = imp_no3.slope_annual
       const = imp_no3.const_annual
       range = no3range
       ytag  = no3tag
       xtag  = no3nul

       MPOS = POS[*,5]
       MPOS = [MPOS[0]+dx, MPOS[1], MPOS[2]+dx, MPOS[3]]
       draw, X, Y, X1, Y1, range, R2, slope, const, Mpos, ytag, xtag     

       ;2) djf
       X     = imp_no3.obs_djf_west
       y     = imp_no3.cal_djf_west
       x1    = imp_no3.obs_djf_east
       y1    = imp_no3.cal_djf_east
       R2    = imp_no3.r2_djf
       slope = imp_no3.slope_djf
       const = imp_no3.const_djf
       range = no3range
       ytag  = no3tag
       xtag  = no3nul

       MPOS = POS[*,6]
       MPOS = [MPOS[0]+dx, MPOS[1], MPOS[2]+dx, MPOS[3]]
       draw, X, Y, X1, Y1, range, R2, slope, const, Mpos, ytag, xtag

       ;3) mam
       X     = imp_no3.obs_mam_west
       y     = imp_no3.cal_mam_west
       x1    = imp_no3.obs_mam_east
       y1    = imp_no3.cal_mam_east
       R2    = imp_no3.r2_mam
       slope = imp_no3.slope_mam
       const = imp_no3.const_mam
       range = no3range
       ytag  = no3tag
       xtag  = no3nul

       MPOS = pos[*,7]
       MPOS = [MPOS[0]+dx, MPOS[1], MPOS[2]+dx, MPOS[3]]
       draw, X, Y, X1, Y1, range, R2, slope, const, MPOS, ytag, xtag

       ;4) jja
       X     = imp_no3.obs_jja_west
       y     = imp_no3.cal_jja_west
       x1    = imp_no3.obs_jja_east
       y1    = imp_no3.cal_jja_east
       R2    = imp_no3.r2_jja
       slope = imp_no3.slope_jja
       const = imp_no3.const_jja
       range = no3range
       ytag  = no3tag
       xtag  = no3nul

       MPOS = pos[*,8]
       MPOS = [MPOS[0]+dx, MPOS[1], MPOS[2]+dx, MPOS[3]]
       draw, X, Y, X1, Y1, range, R2, slope, const, MPOS, ytag, xtag

       ;5) son
       X     = imp_no3.obs_son_west
       y     = imp_no3.cal_son_west
       x1    = imp_no3.obs_son_east
       y1    = imp_no3.cal_son_east
       R2    = imp_no3.r2_son
       slope = imp_no3.slope_son
       const = imp_no3.const_son
       range = no3range
       ytag  = no3tag
       xtag  = no3tag

       MPOS = pos[*,9]
       MPOS = [MPOS[0]+dx, MPOS[1], MPOS[2]+dx, MPOS[3]]
       draw, X, Y, X1, Y1, range, R2, slope, const, MPOS, ytag, xtag        


      ;=====================================================
      ; Castnet ammonium
      ;=====================================================
      ;1) Annual
       X     = cas_nh4.obs_annual_west
       y     = cas_nh4.cal_annual_west
       x1    = cas_nh4.obs_annual_east
       y1    = cas_nh4.cal_annual_east
       R2    = cas_nh4.r2_annual
       slope = cas_nh4.slope_annual
       const = cas_nh4.const_annual
       range = nh4range
       ytag  = nh4tag
       xtag  = nh4nul

       draw, X, Y, X1, Y1, range, R2, slope, const, pos[*,10], ytag, xtag

       ;2) DJF
       X     = cas_nh4.obs_djf_west
       y     = cas_nh4.cal_djf_west
       x1    = cas_nh4.obs_djf_east
       y1    = cas_nh4.cal_djf_east
       R2    = cas_nh4.r2_djf
       slope = cas_nh4.slope_djf
       const = cas_nh4.const_djf
       range = nh4range
       ytag  = nh4tag
       xtag  = nh4nul

       draw, X, Y, X1, Y1, range, R2, slope, const, pos[*,11], ytag, xtag

       ;3) MAM
       X     = cas_nh4.obs_mam_west
       y     = cas_nh4.cal_mam_west
       x1    = cas_nh4.obs_mam_east
       y1    = cas_nh4.cal_mam_east
       R2    = cas_nh4.r2_mam
       slope = cas_nh4.slope_mam
       const = cas_nh4.const_mam
       range = nh4range
       ytag  = nh4tag
       xtag  = nh4nul

       draw, X, Y, X1, Y1, range, R2, slope, const, pos[*,12], ytag, xtag

       ;4) JJA
       X     = cas_nh4.obs_jja_west
       y     = cas_nh4.cal_jja_west
       x1    = cas_nh4.obs_jja_east
       y1    = cas_nh4.cal_jja_east
       R2    = cas_nh4.r2_jja
       slope = cas_nh4.slope_jja
       const = cas_nh4.const_jja
       range = nh4range
       ytag  = nh4tag
       xtag  = nh4nul

       draw, X, Y, X1, Y1, range, R2, slope, const, pos[*,13], ytag, xtag

       ;5) SON
       X     = cas_nh4.obs_son_west
       y     = cas_nh4.cal_son_west
       x1    = cas_nh4.obs_son_east
       y1    = cas_nh4.cal_son_east
       R2    = cas_nh4.r2_son
       slope = cas_nh4.slope_son
       const = cas_nh4.const_son
       range = nh4range
       ytag  = nh4tag
       xtag  = nh4tag

       draw, X, Y, X1, Y1, range, R2, slope, const, pos[*,14], ytag, xtag


   If !D.name eq 'PS' then begin
     charthick=3. 
     charsize=1.5
     cfac  = 0.7
     sz = {sym:0.8,lthick:4.}
   end else begin
     charthick=1.9
     charsize=1.2
     cfac   = 1.2
     sz = {sym:1.0,lthick:2}
   end

  xyouts, 0.98, 0.86, 'Annual', /normal, color=1, charsize=charsize,$
          charthick=charthick, alignment=0.5
  xyouts, 0.99, 0.68, 'DJF', /normal, color=1, charsize=charsize,$
          charthick=charthick, alignment=1
  xyouts, 0.99, 0.50, 'MAM', /normal, color=1, charsize=charsize,$
          charthick=charthick, alignment=1
  xyouts, 0.99, 0.33, 'JJA', /normal, color=1, charsize=charsize,$
          charthick=charthick, alignment=1
  xyouts, 0.99, 0.15, 'SON', /normal, color=1, charsize=charsize,$
          charthick=charthick, alignment=1

  xyouts, 0.22, 0.97, 'SO!d4!u2-!n', /normal, color=1, charsize=charsize,$
          charthick=charthick, alignment=0.5
  xyouts, 0.50, 0.97, 'NO!d3!u-!n', /normal, color=1, charsize=charsize,$
          charthick=charthick, alignment=0.5
  xyouts, 0.79, 0.97, 'NH!d4!u+!n', /normal, color=1, charsize=charsize,$
          charthick=charthick, alignment=0.5

  xyouts, 0.50, 0.01, 'OBSERVATION [!4l!3g m!u-3!n]', /normal, color=1, $
          charsize=charsize, charthick=charthick, alignment=0.5

  xyouts, 0.04, 0.4, 'MODEL [!4l!3g m!u-3!n]', $
          /normal, color=1, alignment=0., $
          charsize=charsize, charthick=charthick, orientation=90.

;  xyouts, 0.635, 0.4, 'MODEL [kg/10!u4!nm!u2!n month]', $
;  xyouts, 0.635, 0.4, 'MODEL [kg ha!u-1!n mon!u-1!n]', $
;          /normal, color=1, alignment=0, $
;          charsize=charsize, charthick=charthick, orientation=90.

;  xyouts, 0.81, 0.01, 'OBSERVATION !C[kg/10!u4!nm!u2!n month]', 

;  xyouts, 0.50, 0.01, 'OBSERVATION !C[kg ha!u-1!n mon!u-1!n]', $
;          /normal, color=1, alignment=0.5, $
;          charsize=charsize, charthick=charthick 

  if (!D.NAME eq 'PS') then Close_device

 End
