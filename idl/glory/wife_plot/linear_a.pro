; plot linear knowing some points

; read data
  x = [35.8, 40]
  x1 = [35, 40]
  y = [0.4, -0.4]
  y1= [0,0]
  y2= [0.9, 0.9]

set_plot, 'ps'
device, filename = 'aa.ps', xoffset = 0.5, yoffset = 0.5, $
        xsize = 3.5, ysize = 3, /inches

  !p.background = 255
  !p.color = 0
  plot, x,y, $
        xstyle = 1, ystyle = 1, $
        xtitle = 'r/mm', ytitle = 'standardized displacement', $
        title = 'a', $
        xticks = 5, xtickv = [35,36,37,38,39,40], $
        yticks = 3, ytickv = [-1,0,1], $
        position = [0.35, 0.3, 0.75, 0.7]

  xyouts, 0.6, 0.63, 'u!dr!n', /normal, alignment = 1.0
  xyouts, 0.52, 0.52, 'u!dz!n', /normal, alignment = 1.0
  oplot, x1, y1
  oplot, x, y2
;  img=tvrd()
;  write_png, 'a.png',img
device ,/close


end
