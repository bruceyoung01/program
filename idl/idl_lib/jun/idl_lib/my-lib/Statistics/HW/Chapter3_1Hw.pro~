PRO Chapter3_1Hw

newPrecip = FltArr(19)

Precip = [43, 10, 4, 0, 2, -999, 31, 0, 0, 0, 2, 3, 0, 4, 15, 2, 0, 1, 127, 2]

;Missing data point
;"R" will index all the values in the array except the missing data point
R = Where(Precip GE 0)

;For simplicity's sake, we will just make this a new array.
newPrecip = Precip(R)

;3.1 
Print, "Problem #3.1"

;I used the "median" function to compute the median.
med = Median(newPrecip)
Print, "Median = ", med, " mm"
;----------------------------------------------------------------------------------------

ResultPrecip = Sort(NewPrecip)		;Sorting the values
SortPrecip = newPrecip[Sort(newPrecip)]	;Putting the sorted values into an array
SizePrecip = Size(newPrecip)		;Implementing the size function of the array
n = SizePrecip[1]			;Getting the size of the array

;Compute the quantiles. We can round up and down by using ceiling and floor functions
q025 = ((n-1)*0.25)+1
quantile25 = (SortPrecip[Ceil(q025-1)] + SortPrecip[Floor(q025-1)])/2.

q075 = ((n-1)*0.75)+1
quantile75 = (SortPrecip[Ceil(q075-1)] + SortPrecip[Floor(q075-1)])/2.

;Calculating trimean, as stated in the book.
trimean = (quantile25 + 2*med + quantile75)/4

Print, "Trimean  = ", trimean, " mm"
;----------------------------------------------------------------------------------------

;I used the "mean" function to compute the mean.
Print, "Mean = ", Mean(newPrecip), " mm"


END
