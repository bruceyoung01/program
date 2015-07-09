
; processing all water phase
; if not water, set it equal to -999. 

; notice, the phase classification only tells the phase, it doesn't
; ensure that a valid retrieval will occur. Possible values, 0-6, and
;127 

PRO water_processing, cldopt, cldreff, cldwtph, cldphase, cldpress, $
                      cldtemp, np, nl, nnp, nnl
     for i = 0, nnp-1 do begin
     for j = 0, nnl-1 do begin
	   if ( cldtemp(i, j) ge 273.15 ) then begin
	   cldopt(2+5*i:2+5*(i+1)-1,  5*j:5*(j+1)-1 ) = -999 
	   cldreff(2+5*i:2+5*(i+1)-1, 5*j:5*(j+1)-1 ) = -999 
	   cldwtph(2+5*i:2+5*(i+1)-1, 5*j:5*(j+1)-1 ) = -999 
        endif
     endfor
     endfor
END     






