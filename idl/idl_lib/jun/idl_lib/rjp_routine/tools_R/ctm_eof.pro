 function ctm_eof, array=array, M=M, anomal=anomal, sample=sample

; Author, Rokjin J. Park

; Keep in mind that IDL treats matrix as row-major format.
; So conventional matrix notation is always in transposed 
; in IDL.
; I will follow IDL matrix definition.

; Assume that we have a data set Data = F(h,t)
; As a matrix K x N ( K col of variables F(h) )
;                   ( N row of sample observations F(t) )
; For example (4 x 3 matrix in idl)
;   4 differnt sites and 3 daily observations
;   [Data] =   A1,A2,A3,A4
;              B1,B2,B3,B4
;              C1,C2,C3,C4
;    

   If N_elements(M) eq 0 then M = 2
      
    If Keyword_set(sample) then begin
      ithaca = [19.,25.,22.,-1., 4.,14.,21.,22.,23.,27.,$
                29.,25.,29.,15.,29.,24.,0. ,2. ,26.,17.,$
                19., 9.,20.,-6.,-13,-13,-11,-4.,-4.,11.,$
                23.]
      canan  = [28.,28.,26.,19.,16.,24.,26.,24.,24.,29.,$
                29.,27.,31.,26.,38.,23.,13.,14.,28.,19.,$
                19.,17.,22., 2., 4., 5., 7., 8.,14.,14.,$
                23.]
      Array =  [Transpose(ithaca),Transpose(canan)]
    Endif

    Data   = array ; K X N array (N observation by K variables)
  ; 1) Calculate Anomaly matrix

    Dim    = size(Data,/dim)
    K      = Dim(0) ; Number of variables (location)
    N      = Dim(1) ; Number of observation (sample)
    M      = M < K  ; Number of new variables to explain
                    ; total sample variances 

   If Keyword_set(anomal) then begin
    A1     = Replicate(1., N, N)
    X_mean = ( Data # A1 ) / float(N)
    X_anom = Data - X_mean  ; K x N
    Data   = X_anom         ; K x N
    Undefine, X_anom
   Endif

  ; 2) Calculate variance-covariance matrix
    print, '## Make variance-covariance matrix ##'
    X_tras = Transpose(Data) ; N x K
    X_var  = (Data # X_tras) / float(N-1) ; K x K

  ; 3) Calculate correlation matrix
    print, '## Make correlation matrix ##'
    D_dia  = sqrt( Identity(K) * X_var )
    D_inv  = Invert( D_dia )
    X_corr = D_inv # X_var # D_inv

    print, '## Pull eigen value and vector ##'
    EigVal = EIGENQL(X_var,Eigenvectors=EigVec)
    EigVEc = Transpose(EigVec) ; K x K 
    ; First mode  = Eigvec(0,*)
    ; Second mode = Eigvec(1,*)

  ; 4) Calculate variances of each PC
    variance = EigVal / Total(Eigval)

  ; 5) Calculate Principal component
    PC = EigVec # Data 

    funcT = PC(0:M-1,*)
    Mode  = EigVec(0:M-1,*)

    eof = {mode:Mode, time:funcT, variance:variance(0:M-1)}

   Return, eof

 End
