;+
;Program 
;      gridgen.pro
;PURPOSE:
;      Generate model horizontal grid according to its type
;
;DATE:
;      4 December 2000
;
;-

function gridgen, ilmm, ijmm, gtype

if n_elements(ilmm) eq 0 then return, 0
if n_elements(ijmm) eq 0 then return, 0
if n_elements(gtype) eq 0 then gtype = 'A'
gtype = strupcase(gtype)

; setup grid for output
; Center
lonc = fltarr(ilmm, ijmm)
latc = lonc

; Boundary
lonb = fltarr(ilmm+1,ijmm+1) 
latb = lonb

 Case gtype of

;...A grid 
  'A' : begin
        dx = 360./ilmm 
	  dy = 180./(ijmm-1)

;...Y direction
;...Note model starts from 90 S that is center of lowest model grid box and
;...also the lower boundary of that box.
;...Same thing is applied for upper boundary at 90 N

   for i = 0, ilmm   do latb(i,1:ijmm-1) = -90.+0.5*dy+findgen(ijmm-1)*dy ; Boundary grid
                        latb(*,0) = -90. 
			      latb(*,ijmm) = 90.

   for i = 0, ilmm-1 do latc(i,*) = -90.+findgen(ijmm)*dy  ; Center grid

;...X direction
;....Note the center of leftmost model box is always 180 W...

   for j = 0, ijmm   do lonb(*,j) = -180.-0.5*dx+findgen(ilmm+1)*dx  ; Boundary grid

   for j = 0, ijmm-1 do lonc(*,j) = -180.+findgen(ilmm)*dx  ; Center grid
   
         end
;...C grid
   'C' : begin
         dx = 360./ilmm
	   dy = 180./ijmm
	   
;...Y direction
;...Note model southern most boundary starts from 90 S and the center of the south-most
;...box is located at the half degree of grid spacing north to its lowest boundary.

   for i = 0, ilmm   do latb(i,*) = -90.+findgen(ijmm+1)*dy  ; Boundary
    
   for i = 0, ilmm-1 do latc(i,*) = -90.+0.5*dy+findgen(ijmm)*dy ; Center
   
;...X direction
;...Note the west most boundary start from -180.
;...Center is located at the half of one grid size right to its boundary

   for j = 0, ijmm   do lonb(*,j) = -180. + findgen(ilmm+1)*dx ; Boundary
   
   for j = 0, ijmm-1 do lonc(*,j) = -180.+0.5*dx+findgen(ilmm)*dx ; Center
          end
   else : begin
          print, 'Grid type is not matched with current input available'
	    return, 0
	    end
   endCase

   grid = {latc:latc,lonc:lonc,latb:latb,lonb:lonb}

return, grid

end
