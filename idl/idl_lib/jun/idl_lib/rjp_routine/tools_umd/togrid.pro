;+
; NAME: togrid
;   
; PURPOSE:  Ungridded lon/lat data is gridded and returned in fd1  
;      
; KEYWORD PARAMETERS:
; INPUT: fd0 --> 1-d ungridded data 
; INPUT: dlon0 --> input longitudes (degrees) assumes cyclical bc 
; INPUT: dlat0 --> input latitudes (degrees)
; INPUT: dlon1 --> ordered output longitudes (degrees)
; INPUT: dlat1 --> ordered output latitudes (degrees)
;
; OUTPUT:  Function returns gridded data.  
;   
;-
function togrid,fd0=fd0,dlon0=dlon0,dlat0=dlat0,dlon1=dlon1,dlat1=dlat1

if n_elements(dlon1) eq 0 then dlon1 = -179.5 + findgen(360) 
if n_elements(dlat1) eq 0 then dlat1 = -89.5 + findgen(180) 

nobs = size(fd0) & nobs = nobs(1) 
ilmm = size(dlon1) & ilmm = ilmm(1)
ijmm = size(dlat1) & ijmm = ijmm(1) 

fd1 = fltarr(ilmm,ijmm) 

lon1 = [dlon1(ilmm-1)-360.,dlon1,dlon1(0)+360.] 
lon1 = 0.5*(lon1+shift(lon1,1))
lon1 = lon1(2:ilmm+1) 

lat1 = 0.5*(dlat1 + shift(dlat1,1)) 
lat1 = [lat1(1:ijmm-1),90.]

ijj = fltarr(nobs) & ill = ijj 

for iobs=0,nobs-1 do begin
   ij = where(dlat0(iobs) le lat1) & ij = ij(0) & ijj(iobs) = ij
   il = where(dlon0(iobs) le lon1) & il = il(0) & ill(iobs) = il
   fd1(il,ij) = fd1(il,ij)+fd0(iobs)
endfor

return,fd1 
end
