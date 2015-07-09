PRO Chapter4_7Hw

Precip = [4.17, 5.61, 3.88, 1.55, 2.30, 5.58, 5.58, 5.14, 4.52, $
1.53, 4.24, 1.18, 3.17, 4.72, 2.17, 2.17, 3.94, 0.95, 1.48, $
5.68, 4.25, 3.66, 2.12, 1.24, 3.64, 8.44, 5.20, 2.33, 2.18, 3.43]

avg = mean(Precip)
SizePrecip = Size(Precip)		;Implementing the size function of the array
n = SizePrecip[1]			;Getting the size of the array

;Adding up all the values in the array Precip
Sum = Total(alog(Precip))

;Applying the sample statistic (equation 4.40)
D = alog(avg) - (1/float(n))*float(Sum)

;Thom estimator for the shape parameter
alpha = (1+((1+(4*D/3))^(0.5)))/(4*D)

;Equation for beta
beta = avg/alpha

Print, "Alpha = ", alpha
Print, "Beta = ", beta

END
