 d1 = convert_daily_monthly(dat01)
 d2 = convert_daily_monthly(dat02)
 d3 = convert_daily_monthly(dat03)
 d4 = convert_daily_monthly(dat04)

 save, filename='monthly_2001.sav', d1
 save, filename='monthly_2002.sav', d2
 save, filename='monthly_2003.sav', d3
 save, filename='monthly_2004.sav', d4


 end
