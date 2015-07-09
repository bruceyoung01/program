 ;
 ; illustrate how to use PCA
 ;

 TOMA = [85, 87, 72, 70, 82, 87, 87, 87, 83, 84, 82, 84, 84, 82, $
         79, 87, 82, 77, 82, 71, 79, 84, 86, 94, 84, 84, 83, 77, $
         81, 78, 87]
 
 TLNK = [86, 87, 78, 74, 84, 87, 88, 88, 86, 87, 84, 84, 85, 92, $
         86, 78, 79, 80, 85, 75, 80, 88, 88, 96, 86, 87, 83, 76, $
         78, 79, 87]


 ; compute anomaly
 TOMAA = TOMA - mean(TOMA)
 TLNKA = TLNK - mean(TLNK)

 ; compute covariance matrix
 ; put anomaly in a matrix format
 A =  [[TOMAA],[TLNKA]]     
 cov = correlate(transpose(A), /covariance)
 print, 'cov = '
 print, cov
 
 ; find eigen values
 eigenvalues = eigenql(cov, eigenvectors = evecs)
 print, 'eigenvalues = ', eigenvalues

 ; be consistent with our textbook
 evecs = transpose(evecs)
 print, 'evectors = '
 print, evecs
 
 ; compute PCs, no need to transpose evecs, see above
 PCS = transpose(A) ## evecs
 print, 'PCS = '
 print, PCS
 
 ; use IDL built in function pcomp to cocnduct 
 ; principal component analysis
 result = pcomp(transpose(A),coefficients = evectors, $
        /covariance, eigenvalues = evalues, $
        variances = variances)

 ; note the evectors and evalues returned from pcomp 
 ; has the same structure as eigenql, i.e., the ith rows 
 ; ith eigen vector. To be consistent with textbook and what
 ; is often used in the meteorology, we need ith column 
 ; represents ith eigen vectors. In addition, the evectors
 ; is scaled up by sqrt of eigenvalues. so, need to normalize 
 ; it and thus be consistent with the textbook.
 ; Below, the rebin is create an array with certain # of columns
 ; and # of rows 
 evalues = transpose(evalues)
 evectors = transpose(evectors)/$
          rebin([sqrt(evalues(0)), sqrt(evalues(1))],2, 2) 
 print, 'evalues from pcomp ...'
 print, evalues
 print, 'evectors from pcomp ...'
 print, evectors
 print, 'transformed results from pcomp'

 ; note result returned from pcomp is scaled up by the
 ; squre root of eigenvalues., to recover back, 
 ; we need to divided squre of eigenvalues 
 print, result/rebin([sqrt(evalues(0)), sqrt(evalues(1))], 2, n_elements(TOMA))

 ; plot result
 set_plot, 'x'
 Device, Decomposed=0
 window, xsize=500, ysize=450
 !p.background=255
 !p.color = 1
 !p.charsize = 2
 !p.multi = [0, 1, 1]
 plot, TOMAA, TLNKA, /nodata, xtitle ='T anomaly in Omaha in July 2009', $
       ytitle = 'T anomaly in Lincoln in July 2009', xrange =[-13, 13], $
       yrange = [-13, 13], xstyle=1, ystyle=1 
 plots, TOMAA, TLNKA, psym = 4
 
 ; plot the direction of two new coordinates for each PCs.
 ; use np = 33 data points to represent a line
 np = 33 
 e1axis = transpose( [[findgen(np)-np/2], [fltarr(np)] ] ) 
 e1inOld = e1axis ## transpose(evecs) 

 e2axis = transpose( [[fltarr(np)], [findgen(np)-np/2] ] ) 
 e2inOld = e2axis ## transpose(evecs) 
 oplot, transpose(e1inOld(0,*)), $
        transpose(e1inOld(1,*)), color=1 

 oplot, transpose(e2inOld(0,*)), $
        transpose(e2inOld(1,*)), color=1 

;define direction of e1, here outplot is for anomaly, so 
;no need to add mean values  
arrow, e1inOld(0,np-2), e1inOld(1,np-2) , $
       e1inOld(0,np-1), e1inOld(1,np-1) , $
       hsize=10, /data, color=1

xyouts, e1inOld(0,np-1), e1inOld(1,np-1) , 'e1',$
        color=1

;define direction of e2 
arrow, e2inOld(0,np-2), e2inOld(1,np-2), $
       e2inOld(0,np-1), e2inOld(1,np-1), $
       hsize=10, /data, color=1
xyouts, e2inOld(0,np-1), e2inOld(1,np-1) , 'e2', $
        color=1

 ; compute the new transformed data to test if they are perpecticular
 print, 'correlation between new transformed data:`'
 print, correlate(pcs(0,*), pcs(1,*))

 ; print convrance matrix of new data
 print, 'conariance matrix of new data'
 print, correlate(pcs,  /covariance)

; locate one data point to show the values in new and old 
; coordinate
 plots, TOMAA(2), TLNKA(2), psym = 2
 print, 'star in old coordinate (', TOMAA(2), ', ', TLNKA(2), ')'
 print, 'star in new coordinate (', PCS(0,2), ', ', PCS(1,2), ')'
 print, 'the first PC explains ', eigenvalues(0)/total(eigenvalues)*100, ' variability'
 
; save image
 img = tvrd()
 write_png, 'Fig121.png', img 

; reconstruct the old values using first component only, let second component as zero
reconstruct = [ [pcs(0, *)], [pcs(1, *) ]*0] ## transpose(evecs)

; plot result
!P.multi = [0, 1, 2]
window, 1
plot, findgen(31)+1, TOMA, xtitle = 'day in July 2009', $
      ytitle = 'T in Omaha', yrange=[60, 100], xrange=[0, 32], $
      xstyle=1, ystyle=1, color=1
Oplot,  findgen(31)+1, reconstruct(0,*)+mean(TOMA), linestyle=3
print, 'R^2 after reconstruction = ', correlate(reconstruct(0,*)+mean(TOMA), TOMA)^2

plot, findgen(31)+1, TLNK, xtitle = 'day in July 2009', $
      ytitle = 'T in Lincoln', yrange=[60, 100], xrange=[0, 32], $
      xstyle=1, ystyle=1
Oplot,  findgen(31)+1, reconstruct(1,*)+mean(TLNK), linestyle=3
print, 'R^2 after reconstruction = ', correlate(reconstruct(1,*)+mean(TLNK), TLNK)^2


 ; save image
 img = tvrd()
 write_png, 'Fig122.png', img 

 END
 

