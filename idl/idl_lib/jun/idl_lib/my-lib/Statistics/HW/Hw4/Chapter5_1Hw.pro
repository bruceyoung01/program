PRO Chapter5_1Hw

Temp = [26.1, 24.5, 24.8, 24.5, 24.1, 24.3, 26.4, 24.9, 23.7, 23.5, 24.0, $
24.1, 23.7, 24.3, 26.6, 24.6, 24.8, 24.4, 26.8, 25.2]

WhereArr = [1, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 1, 0]

ElNino = Where(WhereArr EQ 1)
LaNina = Where(WhereArr EQ 0)

;ElNino = x1, LaNina = x2

mean_x1 = Mean(Temp(ElNino))
mean_x2 = Mean(Temp(LaNina))

std_x1 = Stddev(Temp(ElNino))
std_x2 = Stddev(Temp(LaNina))

var_x1 = Variance(Temp(ElNino))
var_x2 = Variance(Temp(LaNina))

size_x1 = Size(Temp(ElNino))
size_x2 = Size(Temp(LaNina))

n = size_x1[1]
m = size_x2[1]

z = (mean_x1 - mean_x2)/(((var_x1)/(n)+(var_x2)/(m))^(0.5))

Print, std_x1, std_x2
Print, "z = ", z, "  So alpha = 0.03 < 0.05, Reject Ho"

;Confidence interval of alpha =0.05
;Two-tailed test:  (1-alpha)/2, alpha/2
;0.975, 0.025
;Table indicates z = +/-1.96

Print, "For a confidence leve of 95%, z values must fall between +/-1.96"

x1 = (std_x1 - std_x2) * (-1.96) + mean_x1-mean_x2
x2 = (std_x1 - std_x2) * (1.96) + mean_x1-mean_x2

Print, x1, x2



END
