 Function covariance, X, Y

  Mean_X = Replicate(Mean(X),N_elements(X))
  Mean_Y = Replicate(Mean(Y),N_elements(Y))
  Cov    = total((X-Mean_X)*(Y-Mean_Y)) / float(N_elements(X)-1)

 Return, Cov
 End


 Function regress_rma, X, Y, YFIT, R2, OLS=OLS

 If Keyword_set(OLS) then begin
    Slope = Covariance(X,Y) / Variance(X)
    Const = Mean(Y) - ( slope * Mean(X) )
    SST   = Variance(Y) * float(N_elements(Y)-1)
    SSR   = Variance(X) * float(N_elements(X)-1) * slope^2
    R2    = SSR / SST
 Endif else begin
    Slope = STDDEV(Y) / STDDEV(X)
    Const = Mean(Y) - ( slope * Mean(X) )
    R2    = (covariance(x,y)/(stddev(x)*stddev(y)))^2
 End

 YFIT  = slope * X + Const
 Return, [Const,slope]

 End
