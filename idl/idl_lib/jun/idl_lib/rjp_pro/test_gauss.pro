
; 7/26/00 bdf & amf - code to mimic qqnorm plots in Splus
; Input: data set to plot against quantiles of standard normal
; data must be a vector

pro qqnorm, data, pos, qqpos

;put elements of data in numerical order
qqpos = sort(data)
data = data[sort(data)]

;divide standard normal probability distribution function into equal
;area (total area = 1)
adiv =  1./(n_elements(data))

;loop through to get positions - use gauss_cvf function which
;                                calculates the cutoff position, at which the
;                                area under the Gaussian to the right
;                                of the cutoff is equal to the input
;                                value.
;We want to plot at the midpoint, so start with adiv/2

for i=0, n_elements(data)-1 do begin
   pos[i] = -gauss_cvf(adiv/2.+adiv*i)
;   print,  i,  pos[i],  adiv/2.+adiv*i   
endfor

end

@define_plot_size
; X = RANDOMN(seed, 1000, GAMMA=1) 
 X = randomn(seed, 1000) + 4.
  X =[ -1.30720134, 15.90649344, 14.08796719, -3.75091608,-10.10086141, $
      -11.81796064,-14.73266923,  3.10064613,-10.28319701, 18.63332083, $
       -4.95486593,  7.99262369, 13.38073259,  9.02073999,  8.73134620,$
        7.52309985, 17.69909624, 12.52485627, 31.84629132,  0.20278178,$
       14.23211414,  1.88095003, 26.53597427, 44.25727934,  4.17468710,$
       17.08749531, 24.47754667, -3.02651307, 19.37696538, 41.67834269,$
        7.88795185, -5.27098080,-13.94036094, -0.56188418, -9.10312290,$
      -17.15609787,-11.65569991,-22.98020112,-17.07353329, 10.78345590,$
      -16.81598469, 12.03951165, 28.68997156, 17.55286052,  6.40910291,$
       18.80184324, 26.22955296, 35.08651010,  4.05637902, -4.37304637,$
      -14.56029341, 13.24260385, -0.38358315, 11.75906946, 17.27734169,$
       -0.41078059, -1.99729618, -2.36371041,  6.83975082, 28.94961851,$
        2.68648064, 14.13674951, -0.67423675, 17.51565712, 30.48157123,$
        3.71725174, 22.97050869, 30.01392444, 15.29677806, 41.87127096,$
       35.35236937,  9.10582431,  7.37600842, 21.12497725, -3.50316256,$
       16.36613577,  9.49855886,  7.96268474, 24.03101319, 37.12362009,$
       12.35940076, 29.72642053,  5.97733305,  8.29289690,  2.99348810,$
       11.19683300,-28.95146088,-12.28736165,-10.92123629, 30.72996553,$
       16.07836751, 14.86991392, 28.53077588, 25.81123593, 20.91947985,$
        5.71501532,  0.03457777, 47.35280254, 40.58250741, 21.53150476]


 X = X[sort(X)]             ; sorting sample data

 pos = fltarr(N_elements(X))
 qqnorm, X, pos, qqpos
;
 plot, pos, x, color=1, psym=8

 XP = median(x)+15.*pos
 oplot, pos, xp, color=1

stop
;
; halt

 P = fltarr(N_elements(X))
 M = P

 N = N_elements(M)
 M[N-1] = 0.5^(1./N)
 M[0]   = 1 - M(N-1) 
 For I = 2, N-1 do M[I-1] = (I - 0.3175)/(N + 0.365) 

 For D = 0, N-1 do P[D]= GAUSS_CVF(1.-M[D])  ; percent point function

 Plot, P, X, xrange=[-3,3],xstyle=1, ystyle=1, color=1, psym=1
 oplot, !x.crange, !y.crange, color=1
stop

; PLOT, X, Y, COLOR=1
; xlab = ['1','2.5', '16', '50', '84', '97.5', '99'] 
; xlab = [' ', ' ', ' ', ' ', ' ', ' ', ' ']

 xval = [-3,-2.,-1,0.,1.,2.,3.]
 pval = fltarr(N_elements(xval))
 aaa  = pval
 for i = 0, n_elements(xval)-1 do begin
    dx = abs(P - xval[i])
    ip = where(dx eq min(dx))
    if ip[0] ne -1 then pval[i] = m[ip]
    aaa[i] = ip[0]
 end

 xlab = strtrim(round(pval*100.),2)
 xlab = ['1',xlab[1:5],'99']

 PLOT, P, X, COLOR=4, xticks=6, xrange=[-3,3], yrange=[min(x),max(x)], $
  xstyle=1, xtickname=xlab, psym=1, ystyle=1
 Oplot, [0,0],[min(x),x[aaa[3]]], color=1
 oplot, [1,1],[min(x),x[aaa[4]]], color=1
 oplot, [-3,0],[x[aaa[3]],x[aaa[3]]],color=1
 oplot, [-3,1],[x[aaa[4]],x[aaa[4]]],color=1

stop

 halt

 PLOT, HISTOGRAM(X, BINSIZE=0.1) 

 halt
 Y = GAUSSINT(X)

 PLOT, X, Y, COLOR=1

 halt
; The GAUSS_PDF function computes the probability P that, 
; in a standard Gaussian (normal) distribution with a mean of 0.0 
; and a variance of 1.0, 
; a random variable X is less than or equal to a user-specified cutoff value V. 


 PLOT, M, X, color=1

End
