PRO Hw4_Prob3

;z = (citical value - mu)/sigma
;z = (N*p*(1-p)) - N*p)/sqrt(Np(1-p))
;critical value = N*0.857*(1-0.857)
;mu = Np
;sigma = sqrt(Np(1-p))

;Generates values between 0.01 and 0.4
p = (FindGen(40)+1) * 0.01

;we calculate p by taking 0.857 and subtracting deltaP
deltaP = 0.857 - p

;size parameter, stays the same.
N = 25.0

;Equations
mu = N * deltaP
sigma = sqrt(N * deltaP *(1 - deltaP))
x = 18.5			;critical value
z = (x-mu)/sigma

;setting plot device to ps
SET_PLOT, 'PS'

;Here is the filename for the graph
DEVICE, Filename ="PowerOfTest.ps"

Plot, p, gauss_pdf(z), xstyle=1, ystyle=1, $
	title = "Power Function", $
	xtitle = "Delta p = 0.857 - p", $
	ytitle = "Power, 1-Beta"

;Closing device
DEVICE, /CLOSE

END
