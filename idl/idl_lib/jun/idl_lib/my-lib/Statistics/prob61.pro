
  ; do problem 6.1
  T = [26.1, 24.5, 24.8, 24.5, $
       24.1, 24.3, 26.4, 24.9, $
       23.7, 23.5, 24.0, 24.1, $
       23.7, 24.3, 26.6, 24.6, $
       24.8, 24.4, 26.8, 25.2]
  P = 1000 + $
      [ 9.5, 10.9, 10.7, 11.2, $
       11.9, 11.2,  9.3, 11.1, $
       12.0, 11.4, 10.9, 11.5, $
       11.0, 11.2,  9.9, 12.5, $ 
       11.1, 11.8,  9.3, 10.6 ]
 
  X = P
  Y = T 
  ; regression
  result = regress(X, Y, sigma = sigma, $
           Const=const, Ftest=ftest, $
           correlation=correlation, $ 
           Yfit = yfit, chisq = chisq)

  set_plot, 'x'

  ; print regression function
    !p.background=255L+ 256L*(255L + 256L*255)
    !p.charsize=2
    plot, X, Y, /nodata, yrange=[23, 28], $
         xrange = [1008, 1015], xstyle=1, ystyle=1, $
         xtitle = 'P', ytitle = 'T', color=0

    ; plot x and y points
    plots, X, Y, psym=2, color=0

    ; plot regress line
    oplot, X, yfit, color=0

    ; plot regression equation
    ConstS = string(Const)
    SlopeS = string(result(0))
    if (result(0) ge 0) then SlopeS='+'+SlopeS

    xyouts, 0.2, 0.85, ' Y = ' + ConstS +' ' + SlopeS+' *X',color=0, /normal
    xyouts, 0.2, 0.80, 'R^2 = ' + string(correlation^2), color=0, /normal

    ; save into png
    img = tvrd()
    write_png, 'regression_example.png', img

    ; print sigma
    print, 'sigma = ', sigma
    print, 'Z for slope if b=0', (0-result(0))/sigma

    ; print sy^2
    n = n_elements(X)
    sesquare = chisq/(n-2)
    sysquare = sesquare*(1+1./n + $
              (1013-mean(x))^2/total( (x-mean(x))^2)) 
    xi = consts + result(0) * 1013
    print, 'xi = ', xi
    print, 'sysquare = ', sysquare 
    print, 'z for 1C = ', 1/sqrt(sysquare)
   
    ; from Gaussion table, find G value corresponding to 
    ; to z  
    print, 'probability ', 1 - 2 * 0.06178

    ; problem f.
    print, 'z for in prob f = ', 1/sqrt(sesquare)
    print, 'probability = ', 1- 2 * 0.03754 


    END 
