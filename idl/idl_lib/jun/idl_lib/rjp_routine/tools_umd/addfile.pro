function addfile, infile, outfile=outfile, ndim=ndim, type=type

;+
; NAME:
;  ADDFILE
;
; PURPOSE:
;  ADD SEVERAL FILES INTO ONE FILE
;
;
;-

IF N_ELEMENTS(INFILE) LE 1 THEN RETURN, 0
IF N_ELEMENTS(OUTFILE) EQ 0 THEN OUTFILE = 'outfile.dat'
IF N_ELEMENTS(TYPE)   EQ 0 THEN TYPE = 'xdr'

nfile = n_elements(infile)
CASE TYPE OF
'xdr' : begin
        if n_elements(ndim) eq 0 then ndim = 100
        data = fltarr(ndim) 
        openw,jlun,outfile,/xdr,/get
        for i = 0 , nfile-1 do begin
         print, i, infile(i)
         openr,ilun,infile(i),/xdr,/get
         while( not eof(ilun)) do begin
         readu,ilun,data
         writeu,jlun,data
         end
         free_lun,ilun
        end
        end
'f77' : begin
        if n_elements(ndim) eq 0 then return,0
        data = fltarr(ndim) 
        openw,jlun,outfile,/f77,/get
        for i = 0 , nfile-1 do begin
         print, i, infile(i)
         openr,ilun,infile(i),/f77,/get
         while( not eof(ilun)) do begin
         readu,ilun,data
         writeu,jlun,data
         end
         free_lun,ilun
        end
        end
else :  begin
        if n_elements(ndim) eq 0 then ndim = 100
        data = fltarr(ndim) 
        openw,jlun,outfile,/get
        for i = 0 , nfile-1 do begin
         print, i, infile(i)
         openr,ilun,infile(i),/get
         while( not eof(ilun)) do begin
         readu,ilun,data
         writeu,jlun,data
         end
         free_lun,ilun
        end
        end
endcase

free_lun, jlun

return, data

end
        
         
       
