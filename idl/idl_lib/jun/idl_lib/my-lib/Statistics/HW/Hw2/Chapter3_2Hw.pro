PRO Chapter3_2Hw

Pres = [1009.5, 1010.9, 1010.7, 1011.2, 1011.9, 1011.2, 1009.3, 1011.1, 1012.0, $
1011.4, 1010.9, 1011.5, 1011.0, 1011.2, 1009.9, 1012.5, 1011.1, 1011.8, 1009.3, 1010.6]

;3.2
Print, "Problem #3.2"

MAD = FltArr(20)

ResultPres = Sort(Pres)		;Sorting the values
SortPres = Pres[Sort(Pres)]	;Putting the sorted values into an array
SizePres = Size(Pres)		;Implementing the size function of the array
m = SizePres[1]			;Getting the size of the array

;We need to take the positive difference of each number and the median
FOR i = 0, m-1 DO BEGIN
	;Make a new array to easily access the MAD.
	MAD[i] = Abs(Pres[i]-Median(Pres))
ENDFOR

;The MAD is computed by taking the median of our array created in the for loop.
Print, "MAD = ", Median(MAD), " mb"
;----------------------------------------------------------------------------------------

;Compute the quantiles. We can round up and down by using ceiling and floor functions
q025 = ((m-1)*0.25)+1
quantile25 = (SortPres[Ceil(q025-1)] + SortPres[Floor(q025-1)])/2.

q075 = ((m-1)*0.75)+1
quantile75 = (SortPres[Ceil(q075-1)] + SortPres[Floor(q075-1)])/2.

;Computing IQR
IQR = quantile75 - quantile25
Print, "IQR = ", IQR
;----------------------------------------------------------------------------------------

;Compute the standard deviation by using the given function in idl.
Print, "Standard Deviation = ", Stddev(Pres), " mb"

END
