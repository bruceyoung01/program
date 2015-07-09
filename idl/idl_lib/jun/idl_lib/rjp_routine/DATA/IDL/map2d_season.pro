 Pro map2d_season,  Dname, $
                    Modelinfo=Modelinfo, data=data, range=range, $
                    time=time, lat=lat, lon=lon, spec=spec, $
                    min_valid=min_valid, maxdata=maxdata, mindata=mindata, $
                    positived=positived, unit=unit

   If N_elements(Color) eq 0 then Color  = [1,4]
   If N_elements(Data) ne 0 then Dim = size(Data) else return

   If N_elements(Modelinfo) eq 0 then Modelinfo = CTM_TYPE('GEOS3', res=4)
   grid = ctm_grid(modelinfo)

   Nmon = N_elements(time)
   YYMM = time
   Mon  = YYMM-(YYMM/100L)*100L

   multipanel, col=2, row=2

   @define_plot_size

   Align = 0.5

   Sea_str = ['DJF','MAM','JJA','SON']
   Mon_str = ['JAN','FEB','MAR','APR', $
              'MAY','JUN','JUL','AUG', $
              'SEP','OCT','NOV','DEC']

   ; Define Usersymbol
   A = FINDGEN(33) * (!PI*2/32.)
   USERSYM, COS(A), SIN(A) ; , /FILL

   Color = [1,1,1]
   MSEA = [[12,1,2],[3,4,5],[6,7,8],[9,10,11]]

 ; Looping for four seasons
   for D = 0, 3 do begin

         fd2d = fltarr(grid.imx,grid.jmx)
         divi = replicate(0.,grid.imx,grid.jmx)

         ; choose corresponding month for each season
         For IM = 0, NMON-1 do begin  
            res = where(MON(IM) eq MSEA[*,D])
            if (res[0] ne -1) then begin
                print, 'Colleting data of '+mon_str[MON[IM]-1]+' for '+sea_str[D]
                X = Reform(Data[*, MON[IM]-1])
                
                for N = 0, N_elements(X)-1 do begin
                    CTM_INDEX, ModelInfo, I, J, center = [lat(N),lon(N)], $
                               /non_interactive

                   If Keyword_set(PositiveD) then begin
                      If X[N] gt 0. then begin
                         FD2D[I-1,J-1] = FD2D[I-1,J-1] + X[N]
                         DIVI[I-1,J-1] = DIVI[I-1,J-1] + 1.
                      Endif
                   End Else begin
                      FD2D[I-1,J-1] = FD2D[I-1,J-1] + X[N]
                      DIVI[I-1,J-1] = DIVI[I-1,J-1] + 1.
                   End

                endfor
            endif ; res
         Endfor  ; IM

         for J = 0, grid.jmx-1 do begin
         for I = 0, grid.imx-1 do begin
             IF DIVI[I,J] gt 0. then $
                FD2D[I,J] = FD2D[I,J]/float(DIVI[I,J])
         endfor
         endfor

        Plot_region, FD2D, /sample, /cbar, divis=5, maxdata=maxdata, $
         min_valid=min_valid, title=Sea_str[D], mindata=mindata, unit=unit
      
   endfor ; sea


   xyouts, 0.5, 0.96, Dname, /normal, color=1, charsize=tcharsize, $
   charthick=charthick, alignment=0.5

;  free_lun, jj

 End
