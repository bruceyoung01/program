PRO Chapter4_12Hw

rankTemp = FltArr(20)

Temp = [26.1, 24.5, 24.8, 24.5, 24.1, 24.3, 26.4, 24.9, 23.7, 23.5, 24.0, $
24.1, 23.7, 24.3, 26.6, 24.6, 24.8, 24.4, 26.8, 25.2]

Result = Sort(Temp)			;Sorting the values
SortTemp = Temp[Sort(Temp)]		;Putting the sorted values into an array
SizeTemp = Size(Temp)			;Implementing the size function of the array
n = SizeTemp[1]				;Getting the size of the array

;Print, SortTemp

FOR i = 0, n-1 DO BEGIN
	IF (i EQ 0) THEN BEGIN
		rankTemp(i) = 1
	ENDIF ELSE BEGIN
		IF (SortTemp(i) EQ SortTemp(i-1)) THEN BEGIN
			rankTemp(i) = (i+(i+1))/2.0
			rankTemp(i-1) = (i+(i+1))/2.0
		ENDIF ELSE BEGIN
			rankTemp(i) = i+1
		ENDELSE
	ENDELSE
ENDFOR



END


