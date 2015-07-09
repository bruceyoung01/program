; plot linear knowing some points

; read data
  x = [41, 45]
  y = [0.4, -0.4]
  y1= [0,0]
  !p.background = 255
  !p.color = 0
  plot, x,y, $
        xstyle = 1, ystyle = 1, $
        xtitle = 'r/mm', ytitle = 'standard displacement', $
        title = 'a', $
        xrange = [41,45], yrange = [-1,1], $
        position = [0.35, 0.3, 0.75, 0.8]
  oplot, x,y1
  img=tvrd()
  write_png, 'a.png',img
end
