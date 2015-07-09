
; processing all water phase
; if not water, set it equal to -999. 

PRO water_processing_for_ploting, cldopt, cldreff, cldwtph, cldphase, $
    cldpress, cldtemp, np, nl, nnp, nnl
     for i = 0, nnp-1 do begin
     for j = 0, nnl-1 do begin
;        if ( cldphase(i, j) eq 0 or cldphase(i, j) eq 2 or $
;	      cldphase(i, j) eq 3 or  cldphase(i, j) eq 4  or $
;	      cldphase(i,j) eq 6) then begin 

;         if ( cldphase(i,j) eq 6 or cldphase(i,j) eq 0 ) then begin 
         if ( cldphase(i,j) ne 1 and cldphase(i,j) ne 5 ) then begin 
           cldopt(1+5*i:1+5*(i+1)-1, 5*j:5*(j+1)-1 ) = -999 
	   cldreff(1+5*i:1+5*(i+1)-1, 5*j:5*(j+1)-1 ) = -999 
	   cldwtph(1+5*i:1+5*(i+1)-1, 5*j:5*(j+1)-1 ) = -999
	endif
     endfor
     endfor

END     

