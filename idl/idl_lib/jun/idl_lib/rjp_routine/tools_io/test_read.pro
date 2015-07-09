
 openr, il, 'data.data', /get
 
 a = fltarr(3,2)
 readf, il, a
 free_lun, il

 end
