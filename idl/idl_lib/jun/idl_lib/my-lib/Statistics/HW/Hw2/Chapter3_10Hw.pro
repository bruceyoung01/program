PRO Chapter3_10Hw

Temp = [26.1, 24.5, 24.8, 24.5, 24.1, 24.3, 26.4, 24.9, 23.7, 23.5, 24.0, $
24.1, 23.7, 24.3, 26.6, 24.6, 24.8, 24.4, 26.8, 25.2]

IthacaTemp = [19.0, 25.0, 22.0, -1.0, 4.0, 14.0, 21.0, 22.0, 23.0, 27.0, $
29.0, 25.0, 29.0, 15.0, 29.0, 24.0, 0.0, 2.0, 26.0, 17.0, 19.0, 9.0, 20.0, $
-6.0, -13.0, -13.0, -11.0, -4.0, -4.0, 11.0 ,23.0]

Print, "Problem #3.10"

;Using the lag function to calculate the lag of 3
lag = [0,1,2,3]

;Correlate this lag.
result = A_Correlate(IthacaTemp, lag)

;Print result
Print, "r(0) =", result[0]
Print, "r(1) =", result[1]
Print, "r(2) =", result[2]
Print, "r(3) =", result[3]

End
