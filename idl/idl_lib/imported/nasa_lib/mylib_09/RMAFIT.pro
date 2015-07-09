FUNCTION RMAFIT, X, Y, SERROR=s_err, CONF95=conf_95, R2=r2, RANK_R=rank_r
;+
;NAME:
;		RMAFIT

;PURPOSE:
;		Parameter estimation using reduced-major axis regression (Model II) method

;SYNTAX:
; 	Result = RMAFIT ( X, Y [,SERROR=variable] [,CONF95=variable] [,R2=variable [,RANK_R=variable])

;INPUTS:
; 	X, Y: 1D arrays of any type except string

;OUTPUTS:
; 	a 2-element array containing the intercept (c) <Result[0]> and slope (m) <Result[1]> of the fit

;KEYWORDS:
;		SERROR: a named variable (2-element) to store standard errors for c <var[0]> and m <var[1]>
;		CONF95: a named variable (4-element) to store 95% confidence limits for c <var[0,1]> and m <var[2,3]>
;		R2: a named variable to store the coefficient of determination using Pearson's correlation coefficient
;		RANK_R2: a named variable (2-element) to store the correlation coefficient and significance of its deviation from 0,  using Rank correlation coefficient

;EXAMPLE:
;	IDL> x=[14, 17, 24, 25, 27, 33, 34, 37, 40,  41, 42]
;	IDL> y=[61, 37, 65, 69, 54, 93, 87, 89, 100, 90, 97]
;	IDL> print, rmafit(x, y [,SERROR=se] [,CONF95=cl] [,R2=rsq] [,RANK_R=rank] )
;			12.193785       2.1193664
;	IDL> print,se
;       10.549750      0.33249586
;	IDL> print,cl
;      -11.671420       36.058990       1.3672081       2.8715247

;	IDL> print,rsq, rank
;      0.77848511     0.836364   0.00133318



;REFERENCE:
;	Sokal, R. R., and F. J. Rohlf. 1981. Biometry. 2nd edition. Freeman, NY.

;	$Id: RMAFIT.pro,v 1.0 18/07/2007 18:47:01 yaswant Exp $
; RMAFIT.pro	Yaswant Pradhan	University of Plymouth
;	Last modification:
;	Yaswant.Pradhan@plymouth.ac.uk
;
;-


	if( n_params() lt 2) then stop,'Syntax: Result = RMAFIT ( X, Y [,SERROR=variable] [,CONF95=variable] [,R2=variable [,RANK_R=variable])'
	if( n_elements(X) NE n_elements(Y) ) then stop,'X and Y must be of equal length'

	n = n_elements(X)
	n1 = n-1
	df = n-2	;Degrees of freedom
	if( correlate(X,Y) GT 0.) then sign=1 else sign=-1


	slope     = sign*sqrt( variance(Y,/double)/variance(X,/double) )
	intercept = mean(Y,/double) - slope*mean(X,/double)
        Z         = slope*X + intercept
        rmse      = sqrt( mean( (X-Y)^2, /double) )


;Mean squared error
	MSE = (variance(Y,/double) - correlate(X, Y, /double, /covariance)^2. / variance(X,/double)) * n1/df

;Standard error and 95% confidence limits for intercept
 	SEintercept =  sqrt( MSE*((1./n)+mean(X,/double)^2. / variance(X,/double)/n1) )
	intercept95 = intercept + [-1, 1]*t_cvf(0.025, df)*SEintercept

;Standard error and 95% confidence limits for slope
  	SEslope = sqrt(MSE/variance(X,/double)/n1)
	slope95 = slope + [-1, 1]*t_cvf(0.025, df)*SEslope

  	s_err = [SEintercept, SEslope]
  	conf_95 = [intercept95, slope95]
	r2 = correlate(X,Y,/double)^2.			;see IDL help on CORRELATE for more information
	rank_r = r_correlate(X,Y)		;see IDL help on R_CORRELATE for more information

	return,[intercept, slope, rmse]

END
