
PRO grid_sum, tmpcldreff, tmpcldwtph, tmpcldopt, tmpflat, tmpflon, np, nl,  gcldreff, $
           gcldwtph, gcldopt, gcldreffn, latb, latt, lonl, lonr, gridsize 
     
       print, 'max cld opt is ', max( tmpcldopt), 'min cld opt is', min(tmpcldopt)
       print, 'max reff opt is ', max( tmpcldreff), 'min reff opt is',   min(tmpcldreff)
       print, 'max liquid wpth is ', max( tmpcldwtph), 'min liquid path is', min(tmpcldwtph)

       for ii = 0, np-1 do begin
         for jj = 0, nl-1 do begin

	    if ( tmpcldreff(ii, jj) gt 0 and $
	         tmpflat(ii, jj) ge latb and $
		 tmpflat(ii, jj) le latT and $
		 tmpflon(ii, jj) ge lonL and $
		 tmpflon(ii, jj) lt LonR and $
		 tmpcldopt(ii, jj) gt 0  and $
		 tmpcldwtph(ii, jj) gt 0  ) then begin
	         
		 jjnx = fix( (tmpflat(ii, jj) - latb)/gridsize) 
		 iinx = fix ( (tmpflon(ii, jj) - lonL)/gridsize) 
            
	         gcldreff(iinx, jjnx) = gcldreff(iinx, jjnx) + $
		                        tmpcldreff(ii, jj)
	         
		 gcldwtph(iinx, jjnx) = gcldwtph(iinx, jjnx) + $
		                        tmpcldwtph(ii, jj)
		 
		 gcldopt(iinx, jjnx) = gcldopt(iinx, jjnx) + $
		                        tmpcldopt(ii, jj)
		
	         gcldreffn(iinx, jjnx) = gcldreffn(iinx, jjnx) + 1
	      endif

	    endfor
	  endfor
END	  




