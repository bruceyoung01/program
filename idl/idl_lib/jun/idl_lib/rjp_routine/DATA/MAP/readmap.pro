
 function readmap, file=file, res=res

  if n_elements(file) eq 0 then file = pickfile()

  Case res of
     1 : map = fltarr(360,181)
     2 : map = fltarr(144,91)
     4 : map = fltarr(72,46)
   else: stop
  Endcase

   Openr,il,file,/f77,/get
   readu,il,map
   free_lun,il

 Free_lun, il

 tvmap, map, /conti, maxdata=2, /cbar, divis=4, /sample,/grid

 return, map

 end
