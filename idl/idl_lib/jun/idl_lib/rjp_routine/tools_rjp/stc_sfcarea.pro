function stc_sfcarea,lat2b,lon2b

 dim = size(lat2b,/dim)
 ilmm = dim(0)-1
 ijmm = dim(1)-1
 
 mcor = fltarr(ilmm,ijmm)

 lat = lat2b * !pi/180.
 lon = lon2b * !pi/180.

 A = 6.371220e8 ; Earth's radius in cm

 for j = 0, ijmm-1 do begin
 for i = 0, ilmm-1 do begin
   mcor(i,j) = A*A*(lat(i,j+1)-lat(i,j))*(lon(i+1,j)-lon(i,j))*cos(0.5*(lat(i,j+1)+lat(i,j)))
 end
 end

; EA = 4.*!pi*A*A
; print, total(mcor), EA, (total(mcor)-EA)/EA

return, mcor

end



