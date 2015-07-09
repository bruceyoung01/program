; function read, file=file,ilun=ilun,idim=idim,jdim=jdim,kdim=kdim,loop=loop
; 
; file : File name to be read and should be given at first.
; ilun : will be obtained in this routine and must be specified 
; idim : Firstly  varying dimension (x axis)
; jdim : Secondly varying dimension (y axis)
; kdim : thirdly  varying dimension (z axis)
; loop : Looping dimension (t)
;
; if n_elements(file) eq 0 then return, 0
; if n_elements(idim) eq 0 then idim = 1
; if n_elements(jdim) eq 0 then jdim = 1
; if n_elements(kdim) eq 0 then kdim = 1
; if n_elements(loop) eq 0 then loop = 1
; if n_elements(ilun) eq 0 then openr,ilun,file,/get,/f77

function read, file=file,ilun=ilun,idim=idim,jdim=jdim,kdim=kdim,loop=loop

if n_elements(file) eq 0 then return, 0
if n_elements(idim) eq 0 then idim = 1
if n_elements(jdim) eq 0 then jdim = 1
if n_elements(kdim) eq 0 then kdim = 1
if n_elements(loop) eq 0 then loop = 1
if n_elements(ilun) eq 0 then openr,ilun,file,/get,/f77

 print, ilun
 dat = fltarr(idim,jdim,kdim)
 field = fltarr(idim,jdim,kdim,loop)

 for it = 0 , loop-1 do begin
     readu, ilun, dat 
     field(*,*,*,it) = dat
 end

return, field
end
 
