;
; Purpose: for a specified modis file, find the fire file name
;          from the list, and then output fire location
;

PRO   process_fire_only, firefiledir= firefiledir, $
                 firefiles= firefiles, firelat = firelat, firelon = firelon
      nfirefile = n_elements(firefiles)
      maxfirenum = 100000
      firelat = fltarr(maxFireNum)      
      firelon = fltarr(maxFireNum)
      totfirenum = 0 
 
      for k = 0, nfirefile-1 do begin
        firemod_reader, firefiledir,  firefiles(k), lat=flat, $
                        lon = flon, nfire = nfire
          if nfire gt 0 then begin
            firelat(totfirenum:totfirenum+nfire-1) = flat(0:nfire-1)
            firelon(totfirenum:totfirenum+nfire-1) = flon(0:nfire-1)
            totfirenum = totfirenum + nfire  
          endif 
      endfor
    
    print, 'Total Fire Files : ', totfirenum 
    if ( totfirenum gt 0 ) then begin
     firelat = reform(firelat(0:totfirenum-1))  
     firelon = reform(firelon(0:totfirenum-1))
    endif else begin
     firelat = -999  
     firelon = -999 
    endelse 


END
   

