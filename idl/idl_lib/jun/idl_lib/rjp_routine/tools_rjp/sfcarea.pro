function sfcarea,swlat=swlat,ilmm=ilmm,ijmm=ijmm,grid_type=grid_type

if n_elements(swlat) eq 0 then swlat = -!pi/2.
if n_elements(ilmm) eq 0 then ilmm = 360.
if n_elements(ijmm) eq 0 then ijmm = 180.
if n_elements(grid_type) eq 0 then grid_type = 'A'

; there are two calculations of surface area accoring to grid types
;...1) A grid [all variables defined at the same point from south
;              pole (j=1) to north pole (j=JM) ]
;...2) C grid  GEOS-GCM C-Grid (Max Suarez's center difference dynamical core)
;      Vector fields (U,V wind) are defined at the boundary 
;      Scalar fields (temperature, mixing ratio) are defined at the center
; 

 A = 6.371220e8 ; Earth's radius in cm
 area = fltarr(ilmm,ijmm)
 dyarea = fltarr(ijmm)
 grid_type = strupcase(grid_type)
 
 Case grid_type of 
   'C' : begin
         dlat = !pi/ijmm & dy = !pi*A/ijmm
         lat = swlat+findgen(ijmm)*dlat+0.5*dlat
         dyarea = dy * (2.*!pi*A*cos(lat)) / ilmm
         end
   'A' : begin
         dlat = !pi/(ijmm-1) & dy = !pi*A/(ijmm-1)
         lat  = swlat+findgen(ijmm)*dlat
         dyarea(1:ijmm-2) = dy * (2.*!pi*A*cos(lat(1:ijmm-2)))/ilmm
         dyarea(0) = 0.5*dy*(2.*!pi*A*cos(lat(0)+0.5*dlat))/ilmm
         dyarea(ijmm-1) =  0.5*dy*(2.*!pi*A*cos(lat(ijmm-1)-0.5*dlat))/ilmm
         end
   else: print, 'You need to specify grid type of area calculation'
  endcase

 for j = 0 , ijmm-1 do begin
  area(*,j) = dyarea(j)
 end

 EA = 4*!pi*A*A
; print, total(area), EA, (total(area)-EA)/EA

 return, area
 end
