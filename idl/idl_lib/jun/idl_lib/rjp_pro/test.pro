 temp = fltarr(360,181)
 temp[40:140,100:150] = anthsrc
 DIM = SIZE(temp)

; File = '/users/ctm/rjp/Data/MAP/Canada.map_1x1.bin'
; FLAG = fltarr(dim[1],dim[2])    
; Openr,il,file,/f77,/get
; readu,il,flag
; free_lun,il

 for i = 0, dim[1]-1 do begin
 for j = 0, dim[2]-1 do begin
     if flag(i,j) eq 1. then begin
        flag(i,j) = 0.
        goto, jump
     end
 endfor
   jump:
 endfor

 for j = 0, dim[2]-1 do begin
 for i = 0, dim[1]-1 do begin
     if flag(i,j) ne 1. then TEMP(i,j) = 0.
 endfor
 endfor

 multipanel, row=2, col=1

 plot_region, flag, /conti, /sample
 plot_region, temp, /conti, $
                 /sample, $
                 /cbar, divis=5

 print, total(temp)*1.e-9
 print, total(temp)/total(anthsrc)*100.

end
