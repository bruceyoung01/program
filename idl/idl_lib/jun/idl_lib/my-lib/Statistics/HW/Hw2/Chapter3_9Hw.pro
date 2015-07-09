PRO Chapter3_9Hw

Temp = [26.1, 24.5, 24.8, 24.5, 24.1, 24.3, 26.4, 24.9, 23.7, 23.5, 24.0, $
24.1, 23.7, 24.3, 26.6, 24.6, 24.8, 24.4, 26.8, 25.2]

Print, "Problem #3.9"

;June 1951 Temp  = 26.1 degrees C
;Calculate the Standard Anomaly using the equation in the book
StdAnom = (26.1 - Mean(Temp)) / Stddev(Temp)

;Print out the result
Print, StdAnom

END
