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


 ; let's start to use variance first
 A =  [[TmaxOMA-mean(TmaxOMA)], [TminOMA-mean(TminOMA)], $
        [PrecOMA-mean(PrecOMA)], [TmaxLNK-mean(TmaxLNK)], $
        [TminLNK-mean(TminLNK)], [PrecLNK-mean(PrecLNK)] ]     
 ; use IDL built in function pcomp to cocnduct 
 ; principal component analysis
 ; pcomp default is useing correlation
 ; other than covariance
 result = pcomp(transpose(a),coefficients = evectors, $
        eigenvalues = evalues, $
        variances = variances, /covariance)
 print, 'results from pcomp'
 ; note result and eigenvectors returned from pcomp are scaled up
 ; by the squre root of eigenvalues. Ro recover back, 
 ; we need to divided squre of eigenvalues
 print, 'PC results based upon covariance: '
 PCS = result/rebin([sqrt(evalues(0:5))], 6, n_elements(TmaxOMA))
 print, 'eigenvectors '
 evecs = transpose(evectors/rebin(sqrt(evalues), 6, 6))
 print, evecs 
 print, 'eigenvalues'
 evalues= transpose(evalues) 
 print, 'the first 4 PC explains ', $
         total(evalues(0:3))/total(evalues)*100, ' variability'

; reconstruct the old values using first 4 components only
; let other component as zero
pcs45zero = [ [pcs(0, *)], [pcs(1, *)], [pcs(2, *)], [pcs(3, *)],$
      [ pcs(4, *)]*0,  [pcs(5, *)]*0 ]

reconstruct_cov = pcs45zero ## evecs + $ 
     transpose ( rebin([mean(TmaxOMA), mean(TminOMA), mean(PrecOMA), $
     mean(TmaxLNK), mean(TminLNK),  mean(PrecLNK)], 6, n_elements(TmaxOMA)) ) 
                   
;
; use pcomp based upon correlation matrix and standarlize 
;

; A =  [ [TmaxOMA], [TminOMA], $
;        [PrecOMA], [TmaxLNK], $
;        [TminLNK], [PrecLNK] ]     
stop
end
