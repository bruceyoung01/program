function sfcarea,swlat=swlat,ilmm=ilmm,ijmm=ijmm

if n_elements(swlat) eq 0 then swlat = -!pi/2.
if n_elements(ilmm) eq 0 then ilmm = 360.
if n_elements(ijmm) eq 0 then ijmm = 180.

 area = fltarr(ilmm,ijmm)
 dyarea = fltarr(ijmm)
 
 a = 6.371220e8 ; Earth's radius in cm
 dlat = !pi/ijmm & dy = !pi*a/ijmm
 lat = swlat+findgen(ijmm)*dlat+0.5*dlat

 dyarea = dy * (2.*!pi*a*cos(lat)) / ilmm

 for j = 0 , ijmm-1 do begin
  area(*,j) = dyarea(j)
 end

 EA = 4*!pi*a*a
; print, total(area), EA, (total(area)-EA)/EA

 return, area
 end
