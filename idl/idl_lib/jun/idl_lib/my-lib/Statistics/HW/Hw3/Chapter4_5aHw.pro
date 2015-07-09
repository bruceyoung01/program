PRO Chapter4_5aHw

x = (FindGen(100)/10) + 20

Temp = [26.1, 24.5, 24.8, 24.5, 24.1, 24.3, 26.4, 24.9, 23.7, 23.5, 24.0, $
24.1, 23.7, 24.3, 26.6, 24.6, 24.8, 24.4, 26.8, 25.2]

mu = mean(Temp)
sd = stddev(Temp)

;PDF for the Gaussian Distribution
f = (1/(sd*(2*!pi)^(0.5)))*(2.71828^((-(x-mu)^2.0)/(2*sd^2.0)))

;setting plot device to ps
SET_PLOT, 'PS'

;Here is the filename for the graph
DEVICE, Filename ="Gaussian.ps"

Plot, x, f, title = "Gaussian Distribution for Table A.3", $
	xtitle = "Temperature, in degrees C", $
	ytitle = "Probability of Occurence"

;Closing device
DEVICE, /CLOSE

END
