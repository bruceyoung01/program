
; purpose of this program : plot the period function

  a = 2.0
  x = FINDGEN(5000)
  y = SQRT(COS(a*x)+2) * ABS(SIN(a*x))

  SET_PLOT, 'ps'
  DEVICE, filename ='plot_period.ps', /portrait, xsize = 7.5, ysize=9, $
          xoffset = 0.5, yoffset = 1, /inches, /color, bits=8
  PLOT, x, y, color = 1, symsize=0.01, $
        xrange = [-10, 5000], yrange = [0, 2], position = [0.1, 0.2, 0.9, 0.7], $
        xtitle = 'X', ytitle = 'Y'

    
  DEVICE, /close 
  CLOSE, 2
 

END 
