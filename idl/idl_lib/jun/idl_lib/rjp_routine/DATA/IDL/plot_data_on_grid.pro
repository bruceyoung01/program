  pro plot_data_on_grid,                                      $
                    Modelinfo=Modelinfo, data=data, range=range,           $
                    lat=lat, lon=lon, spec=spec,                           $
                    min_valid=min_valid, maxdata=maxdata, mindata=mindata, $
                    positived=positived, cbar=cbar, margin=margin,         $
                    nogxlabel=nogxlabel, nogylabel=nogylabel, title=title, $
                    limit=limit
;+
; pro plot_data_on_grid, data=data
;    data should be 1D matrix [nsite]
;-

   If N_elements(Modelinfo) eq 0 then Modelinfo = CTM_TYPE('GEOS3', res=2)

   grid = ctm_grid(modelinfo)

   NSITE = N_elements(Data)

   Color = [1,1,1]

   @define_plot_size
 
   IMX      = Long(grid.imx)
   JMX      = Long(grid.jmx)
   fd1d     = fltarr(IMX*JMX)
   divi     = replicate(0.,imx*jmx)

   ; data sorting
   If Keyword_set(PositiveD) then P = where(Data gt 0.) else $
                                  P = where(finite(Data) eq 1.)
   If P[0] eq -1. then stop ; return, -1.

   sample = data[P]
   XMID   = Lon[P]
   YMID   = LAT[P]

   ID     = mapid(Modelinfo, LON=XMID, LAT=YMID)
   SID    = ID  ; SAVE ID for future use

   While (ID[0] ne -1.) do begin

     S        = sort(ID)
     Q        = ID[S]
     indi     = where(q ne shift(q,-1), complement=comp)
     CURR     = S[indi]
     fd1d[ID[CURR]] = fd1d[ID[CURR]] + sample[CURR]
     divi[ID[CURR]] = divi[ID[CURR]] + 1.

     if comp[0] eq -1 then goto, jump

     if n_elements(comp) eq 1 then begin
        CURR     = S[comp]
        fd1d[ID[CURR]] = fd1d[ID[CURR]] + sample[CURR]
        divi[ID[CURR]] = divi[ID[CURR]] + 1.
        goto, jump
     end

     LEFT     = S[comp]
     ID       = ID[LEFT]
     sample   = sample[LEFT]

   End

   jump:
  
   fd1d[SID]  = fd1d[SID] / divi[SID]

   MinD = min(fd1d[SID])
   MaxD = max(fd1d[SID])
   

   fd2d       = reform(fd1d, imx, jmx)
   fd2d[where(fd2d eq 0.)] = 'NaN'
;   divi       = reform(divi, grid.imx, grid.jmx)
   if N_elements(mindata) eq 0 then mindata = MinD
   if N_elements(maxdata) eq 0 then maxdata = MaxD
   if N_elements(Min_valid) eq 0 then Min_valid = MIND

   plot_region, fd2d, /sample, divis=5, unit=unit, maxdata=maxdata, $
     mindata=mindata, min_valid=mindata, cbar=cbar, margin=margin,$
     nogxlabel=nogxlabel, nogylabel=nogylabel, title=title, limit=limit

 End

