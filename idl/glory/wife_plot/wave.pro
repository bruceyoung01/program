; plot wave

; read file
  openr, lun, '1_weld_trianglar_3.2mm-picture.txt', /get_lun
  data = fltarr(2,1000)
  readf, lun,data
  free_lun, lun

  tvscl, data
  print, data


;  set_plot, 'ps'
;  device, filename = 'weld_5mm', xoffset = 0.5, yoffset = 0.5, $
;          xsize = 8.5, ysize = 11, /inches
  !p.background = 255
  !p.color = 0  
  !p.multi = [0,1,2,0,0]
  plot, data(0,*),data(1,*), $
        xstyle = 1, ystyle = 1, $
        xtitle = 'Time (10^-3 s)', ytitle = 'Displacement (10^-5 m)', $
        title = '1_weld_trianglar_3.2mm-picture', position = [0.35, 0.3, 0.65,0.7]
  oplot, data(0,*),data(1,*)
  plot, data(0,250:450),data(1,250:450), $
        xstyle = 1, ystyle = 1, $
        position = [0.45, 0.55, 0.60,0.68]

;  device, /close

  img = tvrd()
  write_png, '1_weld_trianglar_3.2mm-picture.png',img
end
