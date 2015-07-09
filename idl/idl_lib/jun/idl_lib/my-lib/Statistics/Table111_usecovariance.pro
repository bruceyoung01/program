 ;
 ; illustrate the importance of using correlation maxtrix
 ; to conduct the PCA for variables have different units.  
 ;

 TmaxOMA = [85, 87, 72, 70, 82, 87, 87, 87, 83, 84, 82, 84, 84, 82, $
         79, 87, 82, 77, 82, 71, 79, 84, 86, 94, 84, 84, 83, 77, $
         81, 78, 87]
 
 TminOMA = [57, 61, 65, 63, 61, 65, 67, 63, 69, 74, 66, 67, 66, 70, $
            64, 57, 53, 53, 53, 64, 62, 57, 60, 67, 66, 59, 65, 60, $
            58, 58, 55]
 PrecOMA = [0, 0, 0.56, 0.16, 0, 0, 0, 1.83, 0, 0, 0, 0.1, 0, 0, 0, $
         0.19, 0, 0, 0, 0.43, 0.08, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.3] 

 TmaxLNK = [86, 87, 78, 74, 84, 87, 88, 88, 86, 87, 84, 84, 85, 92, $
         86, 78, 79, 80, 85, 75, 80, 88, 88, 96, 86, 87, 83, 76, $
         78, 79, 87]

 TminLNK = [55, 67, 67, 66, 62, 60, 63, 65, 71, 73, 72, 68, 67, 70, $
            65, 59, 49, 50, 51, 63, 60, 56, 59, 64, 64, 58, 63, 56, $
            53, 55, 51]

 PrecLNK = [0, 0, 0.47, 0, 0, 0, 0, 0.01, 0, 0, 0, 0, 0,  0.21, 0, 0.19, $
           0, 0, 0, 0.5, 0, 0, 0, 0.12, 0, 0, 0, 0, 0.02, 0, 0.32]


 ; compute anomaly
 TmaxOMAA = TmaxOMA - mean(TmaxOMA)
 TminOMAA = TminOMA - mean(TminOMA)
 PrecOMAA = PrecOMA - mean(PrecOMA)

 TmaxLNKA = TmaxLNK - mean(TmaxLNK)
 TminLNKA = TminLNK - mean(TminLNK)
 PrecLNkA = PrecLNk - mean(PrecLNk)



 ; compute covariance matrix
 ; put anomaly in a matrix format
 A =  [[TmaxOMAA], [TminOMAA], [PrecOMAA], [TmaxLNKA], [TminLNKA], [PrecLNKA] ]     
 cov = correlate(transpose(A), /covariance)
 print, 'cov = ', cov
 
 ; find eigen values
 ; note: The ith row of the returned array evecs contains 
 ; the ith vector corresponding to ith eigenvalue
 ; hence eigenvector matrix from eigenql routine is the tranpose of
 ; eigenvector matrix defined in the book, where jth row
 ; corresponding to jth eigenvalue. 
 eigenvalues = eigenql(cov, eigenvectors = evecs)
 print, 'eigenvalues = ', eigenvalues
 print, 'eigenvectors = ', transpose(evecs)

 ; compute PCs, no need to transpose evecs, see above
 PCS = evecs ## A
 print, 'PCS = '
 print, transpose(PCS)

 ; use IDL built in function pcomp to cocnduct 
 ; principal component analysis
 result = pcomp(transpose(a),coefficients = evectors, $
        /covariance, eigenvalues = evalues, $
        variances = variances)
 print, 'results from pcomp'
 ; not result returned from pcomp is scaled by the
 ; squre root of eigenvalues., to recover back, 
 ; we need to divided squre of eigenvalues 
 print, result/rebin([sqrt(evalues(0:5))], 6, n_elements(TmaxOMA))
 print, 'the first PC explains ', total(eigenvalues(0:3))/total(eigenvalues)*100, ' variability'


; reconstruct the old values using first component only, let second component as zero
 reconstruct = transpose(evecs) ## [ [pcs(*, 0)], [pcs(*, 1)], [pcs(*, 2)], [pcs(*, 3)],$
                           [ pcs(*, 4)*0],  [pcs(*, 5)*0] ] 

 ; plot result
 set_plot, 'x'
 Device, Decomposed=0

; plot result
!P.multi = [0, 1, 2]
window, 1
 !p.background=255
 !p.color = 0
 !p.charsize = 2
plot, findgen(31)+1, TmaxOMA, xtitle = 'day in July 2009', $
      ytitle = 'T in Omaha', yrange=[60, 100], xrange=[0, 32], $
      xstyle=1, ystyle=1
Oplot,  findgen(31)+1, reconstruct(*,0)+mean(TmaxOMA), linestyle=3

plot, findgen(31)+1, PrecOMA, xtitle = 'day in July 2009', $
      ytitle = 'Precip. in Omaha', yrange=[0, 3], xrange=[0, 32], $
      xstyle=1, ystyle=1
Oplot,  findgen(31)+1, reconstruct(*,2)+mean(PrecOMA), linestyle=3

 ; save image
 img = tvrd()
 write_png, 'table111.png', img 

 END
 

