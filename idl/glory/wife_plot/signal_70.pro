; plot signal 

; read data
;  x =fltarr(10000)
;  a = -(findgen(5000)*0.01+50)
;  x(0:4999) = a
;  b = findgen(5000)*0.01+50
;  x(5000:9999) = b
  x = findgen(500000)*0.0001+50
  x1 = findgen(500000)*0.0001-50
  y = (0.23*cos(0.2*x-95)+0.23)/2.
  y1 = (0.23*cos(0.2*x1-95)+0.23)/2.
;  y = -(((x-70)^2)/0.23)+0.23
;  yr = ['0','0.05','0.10','0.15','0.20','0.25']
; plot signal
set_plot, 'ps'
device, filename = 'signal_70.ps', xoffset = 0.5, yoffset = 0.5, $
        xsize = 7.5, ysize = 11, /inches
;  !p.background = 255
;  !p.color = 0
  plot, x,y, $
        xtitle = 'f/HZ', ytitle = 'Displacement', $
        title = 'Frequency signal', $
;        yrange = [0, 0.25], $
        xticks = 3, $
        xtickv = [0,100, 200], $
        yticks = 6, $
        ytickv = [0,0.05,0.10,0.15,0.20,0.25]
  oplot, x1, y1
;  img = tvrd()
;  write_png, 'signal_70.png',img
device, /close
end
