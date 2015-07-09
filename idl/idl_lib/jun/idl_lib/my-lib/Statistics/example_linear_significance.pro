
 ; example of using linear signficance test 
 ; signficance 
 A = [207, 180, 220, 205, 190] 
 B = [6907, 5991, 6810, 6553, 6190]

 plot, A, B,/nodata, xrange=[100, 300], yrange=[5000, 7000], $
       xstyle=1, ystyle=1 
 linear_significance, A, B, 0.2, 0.4
 end
 
