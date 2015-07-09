PRO Ch5_5bHw

Precip = [4.17, 5.61, 3.88, 1.55, 2.30, 5.58, 5.58, 5.14, 4.52, $
1.53, 4.24, 1.18, 3.17, 4.72, 2.17, 2.17, 3.94, 0.95, 1.48, $
5.68, 4.25, 3.66, 2.12, 1.24, 3.64, 8.44, 5.20, 2.33, 2.18, 3.43]

mu = mean(Precip)
sd = stddev(Precip)

bin_lt2 = Where(Precip lt 2, count_lt2)
bin_2_3 = Where(Precip ge 2 AND Precip lt 3, count_2_3)
bin_3_4 = Where(Precip ge 3 AND Precip lt 4, count_3_4)
bin_4_5 = Where(Precip ge 4 AND Precip lt 5, count_4_5)
bin_ge5 = Where(Precip ge 5, count_ge5)

Print, "Class = [<2, 2-3, 3-4, 4-5, <= 5]"
Print, "Observed #:"
Print, count_lt2, count_2_3, count_3_4, count_4_5, count_ge5

z_2 = (2 - mu)/sd	;value: -0.865878, z-table lookup: 0.193
z_3 = (3 - mu)/sd	;value: -0.301788, z-table lookup: 0.382
z_4 = (4 - mu)/sd	;value: 0.262302, z-table lookup: 0.603
z_5 = (5 - mu)/sd	;value: 0.826392, z-table lookup: 0.795

;less than 2 = Prob(2) = 0.193
;from 2-3 = Prob(3) - Prob(2) = 0.382 - 0.193 = 0.189
;from 3-4 = Prob(4) - Prob(3) = 0.603 - 0.382 = 0.221
;from 5-4 = Prob(5) - Prob(4) = 0.795 - 0.603 = 0.192
;5 or greater = 1 - Prob(5) = 0.205

Print, "Probability: "
Print, 0.193, 0.189, 0.221, 0.192, 0.205

E_bin_lt2 = Mean(Precip(bin_lt2))
E_bin_2_3 = Mean(Precip(bin_2_3))
E_bin_3_4 = Mean(Precip(bin_3_4))
E_bin_4_5 = Mean(Precip(bin_4_5))
E_bin_ge5 = Mean(Precip(bin_ge5))

Print, "Expected #:"
Print, E_bin_lt2, E_bin_2_3, E_bin_3_4, E_bin_4_5, E_bin_ge5

Chi_bin_lt2 = ((count_lt2 - E_bin_lt2)^(2.0))/(E_bin_lt2)
Chi_bin_2_3 = ((count_2_3 - E_bin_2_3)^(2.0))/(E_bin_2_3)
Chi_bin_3_4 = ((count_3_4 - E_bin_3_4)^(2.0))/(E_bin_3_4)
Chi_bin_4_5 = ((count_4_5 - E_bin_4_5)^(2.0))/(E_bin_4_5)
Chi_bin_ge5 = ((count_ge5 - E_bin_ge5)^(2.0))/(E_bin_ge5)

chi = Chi_bin_lt2 + Chi_bin_2_3 + Chi_bin_3_4 + Chi_bin_4_5 + Chi_bin_ge5
Print, chi, " lookup at the Chi squared table: 0.33, fail to reject"

END
