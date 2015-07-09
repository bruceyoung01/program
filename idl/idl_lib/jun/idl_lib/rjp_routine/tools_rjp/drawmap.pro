pro drawmap, resol=resol,lon=lon,lat=lat,limit=limit,point=point, $
             noerase=noerase

 if N_elements(resol) eq 0 then resol = 4.
 if N_elements(limit) eq 0 then limit=[20.,-132.5,72.,-57.5]
  Modelinfo = CTM_TYPE('GEOS1',res=resol)
  GridInfo  = CTM_GRID(ModelInfo)

 if Keyword_set(noerase) then $
   map_set,0,0,color=1,/contine,limit=limit,/noerase $
 else map_set,0,0,color=1,/contine,limit=limit,/usa
 
;  map_grid, color=1


   for j = 0, N_elements(gridinfo.yedge)-1 do begin
     Yval = gridinfo.yedge(j)
     plots, gridinfo.xedge, replicate(Yval,73), color=3,thick=2.0   
   endfor

   for i = 0, N_elements(gridinfo.xedge)-1 do begin
     Xval = gridinfo.xedge(i)
     plots, replicate(Xval,73), gridinfo.yedge, color=3,thick=2.0
   endfor

;Area 1        -122.0 -117.0          62.0 66.0   Northwest Territories
;Area 2        -117.0 -110.0          55.0 60.0   Alberta
;Area 3        -110.0 -102.0          54.0 59.0   Saskatchewan
;Area 4        -102.0 - 94.0          54.0 59.0   Manitoba
;Area 5        - 93.0 - 83.0          51.0 54.0   Ontario (*)

    Lon = [[-122.,-117],[-117.0,-110],[-110.0,-102.0], $
           [-102.0,-94.0],[-93.0, -83.0]]
    Lat = [[62.,66.],[55.,60.],[54.,59.],[54.,59.],[51.,54]]

   for i = 0, 4 do begin
   xcoord = [Lon[0,i],lon[1,i],lon[1,i],lon[0,i],lon[0,i]]
   ycoord = [lat[0,i],lat[0,i],lat[1,i],lat[1,i],lat[0,i]]

   polyfill, xcoord, ycoord, color=2
   plots, xcoord, ycoord, color=4
   endfor

   if Keyword_set(point) then begin
     for j = 0, N_elements(gridinfo.ymid)-1 do begin
     for i = 0, N_elements(gridinfo.xmid)-1 do begin
       if (gridinfo.xmid(i) ge limit[1] and gridinfo.xmid(i) le limit[3] $
      and  gridinfo.ymid(j) ge limit[0] and gridinfo.ymid(j) le limit[2] ) $
      then begin
       xyouts, gridinfo.xmid(i), gridinfo.ymid(j), strtrim(i+1,2), color=1, $
       charsize=1.0, alignment=1.
       xyouts, gridinfo.xmid(i), gridinfo.ymid(j), strtrim(j+1,2), color=1, $
       charsize=1.0, alignment=0.
      endif
     endfor
     endfor
   endif

end
