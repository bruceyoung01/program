

function qqnorm,data

; mgs, 12/14/98, extracted from w_calc.pro
; procedure: sort the data, assign actual "probability" and calculate
; the expected deviation from the mean

   ; compute mean and standard deviation
   bla = moment(data)
   mean = bla[0]
   sigma = sqrt(bla[1])

   ; make working copy to store result and compute sort index
   tmp = data
   tmpind = sort(tmp)
   N = n_elements(tmp)
   for i=0,n-1 do tmp[tmpind[i]] = gauss_cvf( 1.-(i+0.5)/N )

   return,tmp
end
