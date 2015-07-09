; plot wave

; read file
  openr, lun, 'weld_3.2mm_tuqi.txt', /get_lun
  data = fltarr(2,1000)
  readf, lun,data
  free_lun, lun

  tvscl, data
  print, data


;  set_plot, 'ps'
;  device, filename = 'weld_3.2mm_tuqi', xoffset = 0.5, yoffset = 0.5, $
;          xsize = 8.5, ysize = 11, /inches
  !p.background = 255
  !p.color = 0  
  !p.multi = [0,1,3,0,0]
  plot, data(0,*),data(1,*), $
;        yticks = 2, ytickv = [-1, 0, 1], $
;        xticks = 4, xtickv = [0.4, 0.6, 0.8, 1.0, 1.2], $
        xstyle = 1, ystyle = 1, $
        xtitle = 'Time (10^-3 s)', ytitle = 'Displacement (10^-5 m)', $
        title = 'weld_3.2mm_tuqi', position = [0.35, 0.3, 0.65,0.7]
  oplot, data(0,*),data(1,*)
  plot, data(0,280:400),data(1,280:400), $
        xticks = 2, xtickv = [0.35, 0.40, 0.45], $
        yticks = 2, ytickv = [0.04, 0, 0.04], $
        xstyle = 1, ystyle = 1, $
        position = [0.4, 0.55, 0.48,0.68]

  plot, data(0,401:520),data(1,401:520), $
        xticks = 2, xtickv = [0.5, 0.55, 0.6], $
        yticks = 2, ytickv = [0.02, 0, 0.02], $
        xstyle = 1, ystyle = 1, $
        position = [0.5, 0.55, 0.6,0.68]

;  device, /close

  img = tvrd()
  write_png, 'weld_3.2mm_tuqi.png',img
end
