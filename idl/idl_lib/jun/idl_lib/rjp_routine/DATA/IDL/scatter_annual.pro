 Pro scatter_annual, Dname, $
                     Modelinfo=Modelinfo, data=data, conc=conc, range=range, $
                     time=time, lat=lat, lon=lon, spec=spec, $
                     Subgridoff=subgridoff, bdlon=bdlon, pos=pos, Unit=Unit, $
                     ID=ID, regress=regress, check_bias=check_bias, title=title, $
                     mtitle=mtitle

   ; Data dimensons for both observations and simulations should be consistent
   
   If N_elements(pos)  eq 0 then pos  = [0.1,0.1,0.9,0.9]
   If N_elements(Spec) eq 0 then spec = ''
   if n_elements(unit) eq 0 then unit = ' '
   if n_elements(mtitle) eq 0 then mtitle = spec

   If N_elements(Bdlon) eq 0 then begin
      bdLon  = [-180., 180.]
      sym    = 8
   end else if N_elements(Bdlon) eq 2 then begin
      sym    = 8 
   end else sym = [1,8]

   If N_elements(Color) eq 0 then Color  = [1,4]

   ; Dimensions of observations
   If N_elements(Data) ne 0  then Dim = size(Data) else return

   If N_elements(Modelinfo) eq 0 then return
   grid = ctm_grid(modelinfo)

   ; how many months of data?
   Nmon = N_elements(time)
   YYMM = time
   Mon  = YYMM-(YYMM/100L)*100L

   if Dim[0] eq 1 then dim2 = 1L 
   if Dim[0] eq 2 then dim2 = Dim[2]

   Align = 0.5

   Mon_str = ['JAN','FEB','MAR','APR', $
              'MAY','JUN','JUL','AUG', $
              'SEP','OCT','NOV','DEC']

   @define_plot_size

   ; Define Usersymbol
   A = FINDGEN(33) * (!PI*2/32.)
   USERSYM, COS(A), SIN(A) ; , /FILL

   Color = [1,1,1]
   MSEA = [[12,1,2],[3,4,5],[6,7,8],[9,10,11]]

    BIAS = 0.
    XAX = 0.
    YAX = 0.
    First = 1L

    For L = 0, N_elements(bdlon)-2 do begin

      POT = where(lon ge bdLon[L] and lon lt bdLon[L+1])

      If POT[0] eq -1 then goto, next

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

             if NMON eq DIM2 then begin
                X = Reform(Data[POT, IM]) 
             end else begin
                X = Reform(Data[POT, MON[IM]-1])    
             end

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

             if NMON eq DIM2 then XTEMP = Reform(DATA[POT, IM]) $
             else XTEMP = Reform(Data[POT, MON[IM]-1])

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

         SITE = ID[POT]

      Endelse

        BIAS = Y/X
    
        If First eq 1L then begin
           plot, X, Y, $
           color=1, psym=sym[L], $
           xrange=range, yrange=range, $
           xtitle=DName+' '+SPEC+UNIT, $
           ytitle='Model '+SPEC+UNIT, $
           symsize=symsize, xstyle=2, ystyle=2, position=pos[*], $
           charsize=charsize, charthick=charthick, title=title
           
           First = 0L
        end else $
        oplot, X, Y, psym=sym[L], symsize=symsize, color=1

        oplot, [0,range[1]], [0,range[1]], color=1
        oplot, [0,range[1]], [0,range[1]*0.5], color=1, line=1
        oplot, [0,range[1]*0.5], [0,range[1]], color=1, line=1

        If ( Keyword_set(subgridoff) eq 0L ) and keyword_set(check_bias) then begin
           For dd = 0, n_elements(bias)-1 do begin
               if bias[dd] gt 2. or bias[dd] lt 0.5 then begin
                  xyouts, X[dd],y[dd],SITE[dd], color=1,charsize=charsize,$
                  charthick=charthick, alignment=0.5
                  print, site[dd]
               end
           Endfor
        Endif

        XAX = [XAX, X]
        YAX = [YAX, Y]

      next:
    Endfor ; L

       X = XAX[1:*]
       Y = YAX[1:*]

       rma   = lsqfitgm(X, Y)
       slope = rma[0]
       const = rma[1]
       R2    = rma[2]^2
    
       if R2 gt 0.05 then R2 = strmid(strtrim(R2,2),0,4) else $
          R2 = '0.0'
       al = strmid(strtrim(slope,2),0,4)
       ab = strmid(strtrim(const,2),0,4)

       wid = range[1]-range[0]
       Xyouts, wid*0.1, range[1]-wid*0.1, 'R!u2!n = '+R2,    color=1,  $
         alignment=0.,charthick=charthick,charsize=charsize
       Xyouts, wid*0.1, range[1]-wid*0.2, 'y = '+al+'x+'+ab, color=1,  $
         alignment=0.,charthick=charthick,charsize=charsize

       if keyword_set(regress) then begin
          XXX = Findgen(101)*Max(X)/100.
          oplot, XXX, const+slope*XXX, color=1, line=0, thick=dthick
       end

  ; Model bias calculations following Balkanski et al. [1993]

;      for nd = 0, N_elements(Y)-1 do $
;         bias = bias + ((Y[nd] - X[nd])/(Y[nd] > X[nd]))
      
;      bias = bias / float(N_elements(Y)) * 100.

;      print, bias, '  Model bias [%] of '+spec
;      bs = strmid(strtrim(bias,2),0,4)

;      Xyouts, wid*0.7, range[1]-wid*0.3, 'bias = '+bs, color=1, $
;      alignment=0.,charthick=charthick



   xyouts, pos[0], pos[3]+0.03, mtitle, /normal, color=1, charsize=charsize, $
   charthick=charthick

 End
