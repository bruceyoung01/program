;+
; NAME:  ilonlat2
;   
; PURPOSE:  Determine model grid point that includes (longitude and latitude of)
;            "measurement" locations (defined by latpt and lonpt)
;   
; CALLING SEQUENCE:
;   
; INPUT PARAMETERS (POSITIONAL):
;   
; INPUT PARAMETERS (KEYWORD) 
;  lonpt:  Array containing longitudes of measurements
;  latpt:  Array containing latitudes of measurements
;  dloncen: Array containing model longitudes
;  dlatcen: Array containing model latitudes
;   
; OUTPUTS
;
; OUTPUT PARAMETERS (KEYWORD)
;     
;       
; MODIFICATION HISTORY: 
;-
function ilonlat2,lonpt=lonpt,latpt=latpt,ilat=ilat,$
 dloncen=dloncen,dlatcen=dlatcen,badval=badval

if n_elements(badval) eq 0 then badval = -999. 
if n_elements(lonpt) eq 0 then lonpt = [0] 
if n_elements(latpt) eq 0 then latpt = [0] 

aaa = where(lonpt eq badval,badcount) 

if n_elements(dloncen) eq 0 then dloncen = -180. + findgen(144)*2.5
if n_elements(dlatcen) eq 0 then dlatcen = -90. + findgen(91)*2.

ilmm = size(dloncen) & ilmm = ilmm(1)
ijmm = size(dlatcen) & ijmm = ijmm(1) 

npts = size(lonpt) & npts = npts(1) 
ilon = lonarr(npts) & ilat = ilon 

dloncen2 = [dloncen,dloncen(0)+360.] 
dlonedge = (dloncen2 + shift(dloncen2,-1))*0.5
dlonedge(ilmm) =0.5* (dloncen(143) + dloncen(0) + 360.)

dlatedge = (dlatcen + shift(dlatcen,-1))*0.5
dlatedge(ijmm-1) = 90. 

for i=0,npts-1 do begin
   aa = where(dlonedge gt lonpt(i),count) 
   if (count ne 0) then ilon(i) = aa(0) else ilon(i) = 0 
   aa = where(dlatedge gt latpt(i),count)
   if (count ne 0) then ilat(i) = aa(0) else ilat(i) = ijmm-1 
endfor   

if (badcount gt 0) then ilon(aaa) = -999 
if (badcount gt 0) then ilat(aaa) = -999 

return,ilon 
end 
