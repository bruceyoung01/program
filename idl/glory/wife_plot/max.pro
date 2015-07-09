; plot wave

; read file
  openr, lun, '0.55mmH2mmL_all.txt', /get_lun
  data = fltarr(2,1000)
  readf, lun,data
  free_lun, lun

  tvscl, data
;  print, data
  
  a = fltarr(1,1)
  b = fltarr(1,1)
  c = max(data(1,0:250))
  a = max(data(1,250:420))
  b = max(data(1,550:710))
  print, 'c'
  print,c
  print, 'a'
  print,a
  print, 'b'
  print, b

end
