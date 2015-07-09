; StatsHW7

;******************;
;	7.7a	   ;
;******************;

print, '7.7'
print, 'PART A)'
BS = 0.0
BSf = 0.0
BSo = 0.0

f = FLTARR(11)
o = FLTARR(11)

y = [.00, .10, .20, .30, .40, .50, .60, .70, .80, .90, 1.00]
f = [293., 237., 162., 98., 64., 36., 39., 26., 21., 14., 10.] 
o = [9., 21., 34., 31., 25., 18., 23., 18., 17., 12., 9.]

; Calculates the BS of the forecasted events and observed events separately.
FOR i=0, 10 DO BEGIN
  BSf = BSf + (f[i]-o[i])*((y[i] - 0)^2)
  BSo = BSo + o[i]*((y[i] - 1)^2)
ENDFOR

; Sum of the calculated BS over the sample size.
BS = (BSf + BSo) / TOTAL(f,1)

print, 'BS =', BS
print, ''


;*************;
;      b      ;
;*************;

print,'PART B)'

BSref = 0.0

;BS of the observations based on the climatological forecast.
  BSOref = 0.0; no, 
  

;relfrequency = 0.0
;pOgivenY = FLTARR(11)
;pY = FLTARR(11) 


;FOR i=0, 10 DO BEGIN
;  ; p(o|y)
;  IF (i EQ 0) THEN BEGIN
;    pOgivenY[i] = o[i] / 1000
;  ENDIF ELSE BEGIN
;    pOgivenY[i] = pOgivenY[i-1] + (o[i] / 1000)
;  ENDELSE
;  ; p(y)
;  pY[i] = f[i] / 1000
  
;  relfrequency = relfrequency + (pY[i] * pOgivenY[i])
;ENDFOR

;print, 'p(o1)=', relfrequency

; Oref is an array which holds the number of observed events found from
  ; the relative frequency of previous observations.
;Oref = FLTARR(11)
;FOR i=0, 10 DO BEGIN
;  Oref[i] = f[i]*relfrequency
;ENDFOR

;print, '[',[y,f,Oref],']'

; JW
BSclim = TOTAL(O)*1.0/TOTAL(F) ; obs. probability of rain
BSfclim = 0.
BSOclim = 0.
FOR i=0, 10 DO BEGIN
  BSfclim = BSfclim + (f[i]-o[i])*((BSclim - 0)^2)
  BSoclim = BSoclim + o[i]*((BSclim - 1)^2)
;  BSOref = BSOref + Oref[i]*((y[i] - 1)^2)
ENDFOR

BSref = (BSfclim + BSOclim) / TOTAL(f,1) 
print, ''
print, 'BS of the climatological forecast =', BSref
print, ''

;************;
;     c      ;
;************;
print, 'PART C)'

BSS = 0.0

BSS = (1 - (BS / BSref)) * 100
print, 'BSS = (1 - (BS/BSref)) * 100% =', BSS


;************;
;     d      ;
;************;

; JW
PY = o/f   ; for given yi, what is observed prob. of rain

print, 'PART D)'
print, 'p(o|y) =', pOgivenY
print, 'p(y) =', pY

PLOT, y, pY, $
  XRANGE = [0,1], $
  YRANGE = [0,1], $
  XTICKS = 2, $
  YTICKS = 2, $
  TITLE = 'Reliability diagram', $
  XTITLE = 'ybar', $
  YTITLE = 'p(y)'

oplot, [0., 1], [0, 1], linestyle=2 ; perfect 1:1 ; JW

END

