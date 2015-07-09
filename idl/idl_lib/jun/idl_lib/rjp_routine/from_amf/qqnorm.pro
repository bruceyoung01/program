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

