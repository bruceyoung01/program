hb = find_prob(0.6) ; high value of 80%
; compute mean between 80% to 100%, this should be equal to
; the x value of 90% or whatever
xx = qromb('f_x_gauss', hb, 6.)/qromb('f_gauss',hb,6.)
yy = qromb('f_gauss',-xx,xx)*100.
zz = 100.-(100.-yy)/2.

print, ' '
print, 'In normal distribution with mean=0 and stddev = 1'
print, 'we got ', xx, ' as a mean value from 80% to 100% of distribution'
print, 'The value ',xx,' corresponds to upper ', zz, '% of distribution'
print, 'in other words, value of upper',zz,'% should be equivalent to'
print, 'the mean of worst 20% of normal distribution'


end
