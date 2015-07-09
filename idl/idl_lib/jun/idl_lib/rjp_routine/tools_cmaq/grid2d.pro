function grid2d, ilmm, ijmm, lonc=lon, latc=lat, lonb=lonb, latb=latb

if n_elements(ilmm) eq 0 then return, 0
if n_elements(ijmm) eq 0 then return, 0


; setup grid for output
; Center
lon = fltarr(ilmm, ijmm)
lat = lon

; Boundary
lonb = fltarr(ilmm+1,ijmm+1) 
latb = lonb

dx = 360./ilmm & dy = 180./(ijmm-1)

;...Y direction
;...Note model starts from 90 S that is center of lowest model grid box and
;...also the lower boundary of that box.
;...Same thing is applied for upper boundary at 90 N

for i = 0, ilmm do latb(i,1:ijmm-1) = -90.+0.5*dy+findgen(ijmm-1)*dy ; Boundary grid
latb(*,0) = -90. & latb(*,ijmm) = 90.

for i = 0, ilmm-1 do lat(i,*) = -90.+findgen(ijmm)*dy  ; Center grid

;...X direction
;....Note the center of leftmost model box is always 180 W...

for j = 0, ijmm do lonb(*,j) = -180.-0.5*dx+findgen(ilmm+1)*dx  ; Boundary grid

for j = 0, ijmm-1 do lon(*,j) = -180.+findgen(ilmm)*dx  ; Center grid


return, lon
end
