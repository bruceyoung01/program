; Kalman filte test
; code developed based upon Dell Monache , 2006, 
; Dell Monache, L., T. Nipen, X. Deng, Y. Zhou, and R. Stull (2006), 
; Ozone ensemble forecasts: 2. A Kalman filter predictor bias correction, 
; J. Geophys. Res., 111, D05308, doi:10.1029/2005JD006311. 


; generate nt white noise
 ; with mean of 0 and standard devation of 1.
 seed = 5L 
 nt = 201
 e = randomn (seed1,  nt, /normal)

 ; with stndard devaition of 2.
 e = 0.05 * e

 ; true data
 A = findgen(nt)
 X = cos(A * 2 * !pi/(nt-1))
 
 ; create observation data
 y = x + e

 ; create model data
  seed = 7L 
  e = randomn (seed2,  nt, /normal)
  Xt = x + 0.15*e - 0.1

; define variable
 xthat = fltarr(nt)
 xmodel = fltarr(nt) 
 sigma_eta_sq = fltarr(nt)
 sigma_eplon_sq = fltarr(nt)
 betat = fltarr(nt)
 pt = fltarr(nt)
psigma_eplon_sq = fltarr(nt) 
betat_sigma_eplon_sq = fltarr(nt)

 ; start Kalman filter
 ; use the first two datasets to constrain Kalman gain
 ; compute the standard deviation of errors relative 
 ; to the errors in the previous steps.
; P(0) = abs( Xt(0) - y(0) )^2     ;first step RMSE
; eta1 = xt(1) - y(1) - ( xt(0) - y(0) ) 
; eta2 = xt(2) - y(2) - ( xt(1) - y(1) ) 
; meaneta = (eta1 + eta2)/2.
; sigma_eta_sq(1) =  (eta1 - meaneta)^2 + (eta2-meaneta)^2
; initial value
  r = 0.02 

; first step
;  sigma_eplon_sq(1) = sigma_eta_sq(1) / r 
;  betat(1) = (P(0) + sigma_eta_sq(1)) / (P(0) + sigma_eta_sq(1) + sigma_eplon_sq(1))

; second step
; update p
sigma_sigma_eta_sq = 0.0005
sigma_sigma_eplon_sq   = 1.0 
xthat(2) =  xt(2) - x(2)
xmodel(2) = xt(2) 
sigma_eta_sq(0:1) = sigma_sigma_eta_sq
sigma_eplon_sq(0:1) = sigma_eta_sq(0:1)/r 

; pt should be expected mean squre error; abs( Xt(0) - y(0) )^2 
pt(0:1) = 0.5 

for t = 2, nt-2 do begin

; equation 1 in the appendix
psigma_eplon_sq(t-1) = (psigma_eplon_sq(t-2) + sigma_sigma_eta_sq) * (1 - betat_sigma_eplon_sq(t-1)) 

; second equation in the appendix
betat_sigma_eplon_sq(t) = ( psigma_eplon_sq(t-1) + sigma_sigma_eta_sq ) / (psigma_eplon_sq(t-1) + sigma_sigma_eplon_sq + sigma_sigma_eta_sq)


; bias in the current time
yt2 = xt(t) - y(t)

; bias in the previous time
yt1 = xt(t-1) - y(t-1)

; third equation in the appendix
sigma_eplon_sq(t) = sigma_eplon_sq(t-1) + betat_sigma_eplon_sq(t-1) * ( (yt2-yt1)^2 / (2+r) - sigma_eplon_sq(t-1)) 
sigma_eta_sq(t) = sigma_eplon_sq(t) * r

print,  sigma_eta_sq(t) ,  sigma_eplon_sq(t)

; equation 4 in the paper, weighting factor or Kalman filter
betat(t) = (pt(t-1) + sigma_eta_sq(t)) / (pt(t-1) +  sigma_eta_sq(t) +  sigma_eplon_sq(t))

; equation 5 in the paper, expected mean squre error
; in the next step
pt(t) = ( pt(t-1) + sigma_eta_sq(t) ) * ( 1 - betat(t))

; equation 3 in the paper. the bias estiamte for the forecast
xthat(t+1) = xthat(t) + betat(t) * (yt2 - xthat(t))

; correcting bias
xmodel(t+1) = xt(t+1) - xthat(t+1)                     

endfor


; all errors are based RMSE
print, 'observation error:'
print, sqrt(total ( ( y(35:nt-1) - x(35:nt-1) )^2 )/ (nt-1-35+1))

print, 'original model error respective to truth:'
print,  sqrt( total ( ( xt(35:nt-1) - x(35:nt-1) )^2 ) / (nt-1-35+1))

print, 'original model error respect to the observatin'
print, sqrt(total ( ( xt(35:nt-1) - y(35:nt-1) )^2 )/(nt-1-35+1))

print, 'model error after kalman respective to obs:'
print,   sqrt(total ( ( xmodel(35:nt-1) - y(35:nt-1) )^2 )/(nt-1-35+1))

print, 'model error after kalman respective to truth:'
print,  sqrt(total ( ( xmodel(35:nt-1) - x(35:nt-1) )^2 )/  (nt-1-35+1))


plot, [10, 50], [-1, 1], /nodata, xrange = [10, 50], yrange = [-1, 1], xstyle=1, ystyle=1
oplot, findgen(nt), y                       ; observation 
;oplot, findgen(nt), x
oplot, findgen(nt), xt, linestyle=2,  thick=5 ;pure model data 
oplot, findgen(nt), xmodel, linestyle=3  ; prediction after using kalman filter

END









   
 


