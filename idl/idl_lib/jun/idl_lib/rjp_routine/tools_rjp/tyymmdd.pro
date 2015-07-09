pro tyymmdd, yymmdd, hhmmss, time, ntdt=ntdt

; yymmdd is long integer (851231L)
; ntdt is sec [time increment]

  Year  = Long( yymmdd / 10000L )
  month = (yymmdd - (Year * 10000L)) / 100L
  day   =  yymmdd - (Year * 10000L + Month * 100L)

  hour  = Long( hhmmss / 10000L )
  min   = (hhmmss - (hour * 10000L)) / 100L
  sec   =  hhmmss - (hour * 10000L + min * 100L)

  if N_elements(ntdt) ne 0 then begin
    sec = sec + ntdt
    add = sec mod 60

  time = {year:year,month:month,day:day,hour:hour,min:min,sec:sec}
