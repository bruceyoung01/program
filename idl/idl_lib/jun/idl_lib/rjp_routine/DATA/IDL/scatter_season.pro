 Pro scatter_season, Dname, $
                     Modelinfo=Modelinfo, data=data, conc=conc, range=range, $
                     time=time, lat=lat, lon=lon, spec=spec, $
                     Subgridoff=subgridoff, bdlon=bdlon, Unit=Unit, $
                     regress=regress

;+
; NAME:
;       SCATTER_SEASON
;
; PURPOSE:
;         PLOT SCATTER DIAGRAM USING 2-D MONTHLY DATA SET
;
;-
;
   If N_elements(Bdlon) eq 0 then begin
      bdLon  = [-180., 180.]
      sym    = 8
   Endif else sym = [1,8]

   If N_elements(Color) eq 0 then Color  = [1,4]
   If N_elements(Data) ne 0 then Dim = size(Data) else return

   If N_elements(Modelinfo) eq 0 then Modelinfo = CTM_TYPE('GEOS3', res=2)
   grid = ctm_grid(modelinfo)

   if N_elements(Range) eq 0 then Range = [0., Max(data)>Max(conc)]
   if N_elements(time)  eq 0 then return
   if N_elements(lat)   eq 0 then return
   if N_elements(lon)   eq 0 then return
   if N_elements(Spec)  eq 0 then Spec = ' '
   if N_elements(Unit)  eq 0 then Unit = ' '
   
   Nmon = N_elements(time)
   YYMM = time
   Mon  = YYMM-(YYMM/100L)*100L
   Ndim = size(Data)
   NSITE= Ndim[1]
   If NDIM[0] eq 2 then NTIME = NDIM[2] else NTIME = 1L

   Npt = 7.
   Tag = float(Range[1]-Range[0])/(Npt-1.)*findgen(Npt) + float(Range[0])
   ntg = strarr(Npt)
   reads, strtrim(tag,2), ntg, format='(A3)'

   Tag = NTG
   Nul = Replicate(' ', N_elements(Tag))

   !P.multi=[0,2,2,0,0]

   Pos = cposition(2,2,xoffset=[0.1,0.1],yoffset=[0.1,0.1], $
         xgap=0.06,ygap=0.06,order=0)


   Align = 0.5

   Sea_str = ['DJF','MAM','JJA','SON']
   Mon_str = ['JAN','FEB','MAR','APR', $
              'MAY','JUN','JUL','AUG', $
              'SEP','OCT','NOV','DEC']

   @define_plot_size
   ; Define Usersymbol of open circle
   A = FINDGEN(33) * (!PI*2/32.)
   USERSYM, COS(A), SIN(A)

   Color = [1,1,1]
   MSEA = [[12,1,2],[3,4,5],[6,7,8],[9,10,11]]


 ; Looping for four seasons
   for D = 0, 3 do begin

    First = 1L

    if D eq 2 or D eq 3 then begin
       xtitle = DName+' '+SPEC+UNIT 
       xlabel = Tag
    end else begin
       xtitle = ''
       xlabel = Nul
    end
    if D eq 0 or D eq 2 then begin
       ytitle = 'Model '+SPEC+UNIT  
       ylabel = Tag
    end else begin
       ytitle= ''
       ylabel = Nul
    end

    BIAS = 0.
    XAX = 0.
    YAX = 0.

    For L = 0, N_elements(bdlon)-2 do begin
      POT = where(lon ge bdLon[L] and lon lt bdLon[L+1])
      if POT[0] eq -1 then goto, next

      If Keyword_set(subgridoff) then begin

         ; Rebin the data on model grid to remove sub-grid variability that 
         ; can be resolved in the model properly.     

         ; Declare array containing data for seasonal mean over model grid
         XX = 0. & YY = 0.
         fd2d_obs = fltarr(grid.imx,grid.jmx)
         fd2d_cal = fd2d_obs
         divi     = replicate(0.,grid.imx,grid.jmx)

         ; choose corresponding month for each season
         For IM = 0, NMON-1 do begin  

         ; Find correct month for each season
            res = where(MON(IM) eq MSEA[*,D])
            if (res[0] ne -1) then begin
                print, 'Colleting data of '+mon_str[MON[IM]-1]+' for '+sea_str[D]

                if NMON eq NTIME then X = Reform(Data[POT, IM]) $
                else X = Reform(Data[POT, MON[IM]-1])    

                Y = Reform(Conc[POT, IM])
                
                for SN = 0, N_elements(POT)-1 do begin
                     N = POT[SN]
                    CTM_INDEX, ModelInfo, I, J, center = [lat(N),lon(N)], $
                               /non_interactive

                    ; Missing observation check
                    If X[SN] gt 0. then begin
                       FD2D_obs[I-1,J-1] = FD2D_obs[I-1,J-1] + X[SN]
                       FD2D_cal[I-1,J-1] = FD2D_cal[I-1,J-1] + Y[SN]
                       DIVI[I-1,J-1]     = DIVI[I-1,J-1] + 1.
                    Endif
                endfor
            endif ; res
         Endfor  ; IM

         ; Take an average over season and grid
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

                if NMON eq NTIME then XDA = [XDA, Reform(DATA[POT, IM])] $
                  else XDA = [XDA, Reform(Data[POT, MON[IM]-1])]    

                YDA = [YDA, Reform(CONC[POT, IM])]

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
    
      If First eq 1L then begin
        plot, X, Y, color=1, psym=sym[L], $
        xrange=range, yrange=range, $
        xtitle=xtitle, ytitle=ytitle, $
        symsize=symsize, xstyle=2, ystyle=2, position=pos[*,D], $
        charsize=charsize, charthick=charthick 
;        YTickName=ylabel, yticks=n_elements(tag)-1,  $
;        XTickName=xlabel, xticks=n_elements(tag)-1   $
        
        First = 0L
      end else $
        oplot, X, Y, psym=sym[L], symsize=symsize, color=1

        oplot, [0,range[1]], [0,range[1]], color=1
        oplot, [0,range[1]], [0,range[1]*0.5], color=1, line=1
        oplot, [0,range[1]*0.5], [0,range[1]], color=1, line=1

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
    
       print, R2
       if R2 gt 0.01 then R2 = strmid(strtrim(R2,2),0,4) else $
          R2 = '0.0'
       al = strmid(strtrim(slope,2),0,4)
       ab = strmid(strtrim(abs(const),2),0,4)
       if const lt 0.0 then XX = 'x-' else XX = 'x+'

       wid = range[1]-range[0]
       Xyouts, wid*0.5, range[1]-wid*0.8, 'R!u2!n = '+R2,    color=1,  $
         alignment=0.,charthick=charthick,charsize=charsize
       Xyouts, wid*0.5, range[1]-wid*0.9, 'y = '+al+XX+ab, color=1,  $
         alignment=0.,charthick=charthick,charsize=charsize

       if keyword_set(regress) then begin
          XXX = Findgen(101)*Max(X)/100.
          oplot, XXX, const+slope*XXX, color=1, line=0, thick=dthick
       end

       Xyouts, wid*0.05, range[1]-wid*0.1, sea_str[D], color=1, $
         alignment=0.,charthick=charthick,charsize=tcharsize

  ; Model bias calculations following Balkanski et al. [1993]

;      for nd = 0, N_elements(Y)-1 do $
;         bias = bias + ((Y[nd] - X[nd])/(Y[nd] > X[nd]))
      
;      bias = bias / float(N_elements(Y)) * 100.

;      print, bias, '  Model bias [%] of '+spec
;      bs = strmid(strtrim(bias,2),0,4)

;      Xyouts, wid*0.7, range[1]-wid*0.3, 'bias = '+bs, color=1, $
;      alignment=0.,charthick=charthick

   endfor ; sea


   xyouts, 0.1, 0.92, SPEC, /normal, color=1, charsize=tcharsize, $
   charthick=charthick

 End
