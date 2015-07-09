;+
; NAME:  extractpts
;   
; PURPOSE:  Extract value of fd at desired points. 
;            
;   
; CALLING SEQUENCE:
;   
; INPUT PARAMETERS (POSITIONAL):
;  fd1:    Input quantity as a function of longitude and latitude
;   
; INPUT PARAMETERS (KEYWORD) 
;  lons:  Array containing longitudes of measurements
;  lats:  Array containing latitudes of measurements
;  dloncen: Array containing model longitudes
;  dlatcen: Array containing model latitudes
;   
; OUTPUTS
;  fd2:  Value of fd1 at desired locations
;
; OUTPUT PARAMETERS (KEYWORD)
;     
;       
; MODIFICATION HISTORY: 
;First version  October 5, 1998 
;- 
function extractpts,fd1,lons=lons,lats=lats,dloncen=dloncen,$
 dlatcen=dlatcen

if n_elements(lons) eq 0 then lons = [0] 
if n_elements(lats) eq 0 then lats = [0] 
if n_elements(dloncen) eq 0 then dloncen = -180. + findgen(144)*2.5
if n_elements(dlatcen) eq 0 then dlatcen = -90. + findgen(91)*2. 

ilon = ilonlat2(lonpt=lons,latpt=lats,ilat=ilat,dloncen=dloncen,$
 dlatcen=dlatcen) 

bb = size(ilon) & npts = bb(1) 
aa = size(fd1)
case aa(0) of 
2: fd2 = fd1(ilon,ilat)
3: begin
    ikmm = aa(3)
    fd2 = fltarr(npts,ikmm) 
    for ik=0,ikmm-1 do begin
       fd1b = fd1(*,*,ik)
       fd2(0,ik) = fd1b(ilon,ilat) 
    endfor
   end
4: begin
    ikmm = aa(3) & ncon = aa(4) 
    fd2 = fltarr(npts,ikmm,ncon)
    for ic=0,ncon-1 do begin
    for ik=0,ikmm-1 do begin
       fd1b = fd1(*,*,ik,ic)
       fd2(0,ik,ic) = fd1b(ilon,ilat)
    endfor
    endfor
   end
else:
endcase  
    
fd2 = reform(fd2) 
return,fd2
end  


