
  ; example of using linear regression in IDL
  ; Jun Wang @ UNL, Oct 27, 2009.

  ; specify x and y
    X = [1.0, 2.0, 4.0, 8.0, 16.0, 32.0]
    Y = [0.0, 1.0, 2.0, 3.0, 4.0, 5.0] 

  ; regressio function
    result = regress(X, Y, sigma = sigma, $
             Const=const, Ftest=ftest, $
             correlation=correlation, $
             Yfit = yfit, chisq = chisq)

  ; show the result
    !p.background=255
    !p.charsize=2
    plot, X, Y, /nodata, xrange=[0, 35], $
         yrange = [0, 6], xstyle=1, ystyle=1, $
         xtitle = 'X', ytitle = 'Y', color=0

    ; plot x and y points
    plots, X, Y, psym=2, color=0   
      
    ; plot regress line
    oplot, X, yfit, color=0

    ; plot regression equation
    ConstS = string(Const)
    SlopeS = string(result(0))
    if (result(0) ge 0) then SlopeS='+'+SlopeS

    xyouts, 1, 5, ' Y = ' + ConstS +' ' + SlopeS+' *X',color=0 
    xyouts, 1, 4.5, 'R^2 = ' + string(correlation^2), color=0    
 
    ; verify chisq is the SSE defined in our class
    print, 'chisq = ', chisq
    print, 'SSE definition = ', total( (y-yfit)^2)
   
    ; since MSE = Sesqure = SSE/(n-2), and F = SSR/Se
    ; Table 6.1 in the text book
    ; SSR = Se * F  = SSE/(n-2) * F
    ; verify SSR
    Sesqure = chisq/(n_elements(y)-2)
    SSR = Sesqure* Ftest
    print, 'SSR from F calcultion: '
    print, SSR 
    print, 'SSR from defintion:'
    print, total( (yfit - mean(y))^2 )
   
    ; total SST = SST + SSR
    SST = chisq/(n_elements(y)-2)* Ftest + chisq
    print, 'SST = ', SST 

    ; verify R^2
    print, 'R^2=SSR/SST= ', chisq/(n_elements(y)-2)* Ftest/SST 
    print, 'R^2 = ', correlation^2

    ; verify standard error for returned coefficient
    print, 'sigma = :', sigma
    print, 'sigma from book :',  sqrt(sesqure)/sqrt( total ( (x-mean(x) ) ^2 ) )


    ; save into png
    img = tvrd()
    write_png, 'regression_example.png', img
    END
       

  




    



    

 
