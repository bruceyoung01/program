PRO Chapter3_12Hw

newPrecip = FltArr(19)
newTemp = FltArr(19)
newPres = FltArr(19)

Temp = [26.1, 24.5, 24.8, 24.5, 24.1, 24.3, 26.4, 24.9, 23.7, 23.5, 24.0, $
24.1, 23.7, 24.3, 26.6, 24.6, 24.8, 24.4, 26.8, 25.2]

Precip = [43, 10, 4, 0, 2, -999, 31, 0, 0, 0, 2, 3, 0, 4, 15, 2, 0, 1, 127, 2]

Pres = [1009.5, 1010.9, 1010.7, 1011.2, 1011.9, 1011.2, 1009.3, 1011.1, 1012.0, $
1011.4, 1010.9, 1011.5, 1011.0, 1011.2, 1009.9, 1012.5, 1011.1, 1011.8, 1009.3, 1010.6]

;Missing data point
;"R" will index all the values in the array except the missing data point
R = Where(Precip GE 0)
;We will use this indexing for all arrays to remove the corresponding point

;How the matrix will be structured.
;	Temp 	Precip	Pres
;Temp
;Precip
;Pres

Print, "Problem #3.12"
;----------------------------------------------------------------------------------------
;PEARSON

;Calculating the data for the matrix			;(row,column)
TempTemp_a = Correlate(Temp(R), Temp(R))		;(1,1)
TempPrecip_a = Correlate(Temp(R), Precip(R))		;(1,2)
TempPres_a = Correlate(Temp, Pres)			;(1,3)
PrecipTemp_a = Correlate(Precip(R), Temp(R))		;(2,1)
PrecipPrecip_a = Correlate(Precip(R), Precip(R))	;(2,2)
PrecipPres_a = Correlate(Precip(R), Pres(R))		;(2,3)
PresTemp_a = Correlate(Pres, Temp)			;(3,1)
PresPrecip_a = Correlate(Pres(R), Precip(R))		;(3,2)
PresPres_a = Correlate(Pres(R), Pres(R))		;(3,3)

;Printing out the matrix
Print, "a. The Pearson Correlation"
Print, TempTemp_a, TempPrecip_a, TempPres_a
Print, PrecipTemp_a, PrecipPrecip_a, PrecipPres_a
Print, PresTemp_a, PresPrecip_a, PresPres_a

;----------------------------------------------------------------------------------------
;SPEARMAN

;Calculating the data for the matrix			;(row,column)
TempTemp_b = R_Correlate(Temp(R), Temp(R))		;(1,1)
TempPrecip_b = R_Correlate(Temp(R), Precip(R))		;(1,2)
TempPres_b = R_Correlate(Temp, Pres)			;(1,3)
PrecipTemp_b = R_Correlate(Precip(R), Temp(R))		;(2,1)
PrecipPrecip_b = R_Correlate(Precip(R), Precip(R))	;(2,2)
PrecipPres_b = R_Correlate(Precip(R), Pres(R))		;(2,3)
PresTemp_b = R_Correlate(Pres, Temp)			;(3,1)
PresPrecip_b = R_Correlate(Pres(R), Precip(R))		;(3,2)
PresPres_b = R_Correlate(Pres(R), Pres(R))		;(3,3)

;Printing out the data results.
Print, "b. The Spearman Rank Correlation"
Print, TempTemp_b[0], TempPrecip_b[0], TempPres_b[0]
Print, PrecipTemp_b[0], PrecipPrecip_b[0], PrecipPres_b[0]
Print, PresTemp_b[0], PresPrecip_b[0], PresPres_b[0]

END

