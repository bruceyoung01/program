  Pro map2d_annual, Dname, $
                    Modelinfo=Modelinfo, data=data, range=range, $
                    time=time, lat=lat, lon=lon, spec=spec, $
                    min_valid=min_valid, maxdata=maxdata, mindata=mindata, $
                    positived=positived, cbar=cbar, margin=margin, $
                    nogxlabel=nogxlabel, nogylabel=nogylabel, title=title, $
                    limit=limit
;+
; pro plot2d, data=data
;    data should be 2D matrix [nsite,12month]
;
; right now, this routine is hardwired for annual plot
;-

   If N_elements(Modelinfo) eq 0 then Modelinfo = CTM_TYPE('GEOS3', res=2)

   grid = ctm_grid(modelinfo)

   Nmon = N_elements(time)
   YYMM = time
   Mon  = YYMM-(YYMM/100L)*100L
   Ndim = size(Data)
   NSITE= Ndim[1]
   If NDIM[0] eq 2 then NTIME = NDIM[2] else NTIME = 1L

   Color = [1,1,1]

   @define_plot_size

   Sea_str = ['DJF','MAM','JJA','SON']
   Mon_str = ['JAN','FEB','MAR','APR', $
              'MAY','JUN','JUL','AUG', $
              'SEP','OCT','NOV','DEC']

   fd2d = fltarr(grid.imx,grid.jmx)
   divi = replicate(0.,grid.imx,grid.jmx)

   MinD = 100.
   MaxD = -100.

   For IM = 0, NMON-1 do begin    ; taken average over a whole month
       print, 'Colleting data of '+mon_str[MON[IM]-1]

       if NMON eq NTIME then X = reform(Data[*, IM]) $
       else X = Reform(Data[*, MON[IM]-1])    

       for N = 0, N_elements(X)-1 do begin
           CTM_INDEX, ModelInfo, I, J, center = [lat(N),lon(N)], $
                      /non_interactive

           If Keyword_set(PositiveD) then begin
              If X[N] gt 0. then begin
                 FD2D[I-1,J-1] = FD2D[I-1,J-1] + X[N]
                 DIVI[I-1,J-1] = DIVI[I-1,J-1] + 1.
              Endif
           End Else begin
              If X[N] ne -999. and Finite(X[N]) eq 1 then begin
                 FD2D[I-1,J-1] = FD2D[I-1,J-1] + X[N]
                 DIVI[I-1,J-1] = DIVI[I-1,J-1] + 1.
              Endif
           End
       endfor
   Endfor  ; IM

   for J = 0, grid.jmx-1 do begin
   for I = 0, grid.imx-1 do begin
       IF DIVI[I,J] gt 0. then begin
          FD2D[I,J] = FD2D[I,J]/float(DIVI[I,J]) 
          MinD = MinD < FD2D[I,J]
          MaxD = MaxD > FD2D[I,J]
       end else FD2D[I,J] = 'NaN'
   endfor
   endfor
   
   if N_elements(mindata) eq 0 then mindata = MinD
   if N_elements(maxdata) eq 0 then maxdata = MaxD

   plot_region, fd2d, /sample, divis=5, unit=unit, maxdata=maxdata, $
     mindata=mindata, min_valid=min_valid, cbar=cbar, margin=margin,$
     nogxlabel=nogxlabel, nogylabel=nogylabel, title=title, limit=limit

 End

