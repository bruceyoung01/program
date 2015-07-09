function Sarea, latb=latb, lonb=lonb

ilmm = n_elements(lonb)-1
ijmm = n_elements(latb)-1

mcor = fltarr(ilmm,ijmm)

 dlat = latb*!pi/180. & dlon = lonb*!pi/180.

 a = 6.371220e8 ; Earth's radius in cm

 for j = 0, ijmm-1 do begin
 for i = 0, ilmm-1 do begin
   mcor(i,j) = a*a*(sin(dlat(j+1))-sin(dlat(j)))*(dlon(i+1)-dlon(i))
 end
 end

 EA = 4.*!pi*a*a
 print, total(mcor), EA, (total(mcor)-EA)/EA

return, mcor

end



