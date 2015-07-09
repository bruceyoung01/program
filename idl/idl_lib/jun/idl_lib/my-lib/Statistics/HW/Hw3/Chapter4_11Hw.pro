PRO Chapter4_11Hw

minTemp = [28.0, 28.0, 26.0, 19.0, 16.0, 24.0, 26.0, 24.0, 24.0, $
29.0, 29.0, 27.0, 31.0, 26.0, 38.0, 23.0, 13.0, 14.0, 28.0, 19.0, $
19.0, 17.0, 22.0, 2.0, 4.0, 5.0, 7.0, 8.0, 14.0, 14.0, 23.0 ]

maxTemp = [34.0, 36.0, 30.0, 29.0, 30.0, 35.0, 44.0, 38.0, 31.0, $
33.0, 39.0, 33.0, 34.0, 39.0, 51.0, 44.0, 25.0, 34.0, 36.0, 29.0, $
27.0, 29.0, 27.0, 24.0, 11.0, 21.0, 19.0, 26.0, 28.0, 31.0, 38.0 ]

;x = maxTemp
;y = minTemp

muX = Mean(maxTemp)
muY = Mean(minTemp)

sigmaX = Stddev(maxTemp)
sigmaY = Stddev(minTemp)

rho = Correlate(maxTemp, minTemp)

print, "Mean:   max = ", muX, "    min = ", muY
print, "StdDev: max = ", sigmaX, "    min = ", sigmaY
print, "Rho = ", rho

mu = muX + (rho*sigmaX)*((0.0-muY)/sigmaY)

print, "mu x|y = ", mu

sigma = sigmaX*sqrt(1-(rho^(2.0)))

print, "sigma x|y = ", sigma

f = (1/(sqrt(2*!pi)*sigma))*(2.7187^(-((20.0-mu)^(2.0))/(2*(sigma^(2.0)))))

print, "f = ", f

END
