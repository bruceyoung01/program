PRO process_day, infile, Nday, AllFileName, StartInx, EndInx, $
                  DAYNAME, JDAYNUM, MonNum = MonNum, Daynum = daynum
    
   readcol, infile, allfilename, format='A' 
   NFile = n_elements(allfilename) 


   ; decode day and night
   Days = [0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334, 365]
   NM = 12    ; total 12 months per year

   StartInx = intarr(366)
   EndInx = intarr(366)
   DayName = strarr(366)
   JDayNUM = intarr(366)
   MonNUM = intarr(366)
   DayNUM = intarr(366)

   
   SSINX = 0
   DI  = 0
   for i = 0, Nfile-2 do begin
         
      ; from file name to julian day	 
	 OneF = AllFileName(i)                       ; current day
         JulianD = fix(strmid (OneF, 14, 3))

         NxF = AllFileName(i+1)                           ; next day
	 NxJD = fix ( strmid ( NxF, 14, 3))
	 
       ; get the month correct
         for k = 0, NM-1 do begin
	 if ( JulianD ge Days(k)+1 and JulianD lt Days(k+1)+1 ) then  begin
	    Month = string ( k+1, format = '(I2)')
	    Day = string (JulianD - Days(k), format = '(I2)')
	    tmpday = (k+1)*100 + (JulianD - Days(k)) 
	 endif  
	 endfor
       
       ; judget if on the same day
          if ( JulianD ne NxJD  ) then begin
             ENDINX(DI)  = I
	     STARTINX(DI) = SSINX
	     DAYNAME(DI) = Month + '' + Day + $
	                   ' Julian Day ' + string(JulianD, format =  '(I3)')
	     JDayNum(DI) = tmpday 
             MonNum(DI) = Month 
             DayNum(DI) = float(day) 
	     SSINX = i+1
	     DI = DI + 1
	  endif
    endfor	 

    NDAY = DI

   StartInx = reform(startInx(0:NDAY-1)) 
   EndInx =  reform(EndInx(0:NDAY-1)) 
   DayName = reform(DayName(0:NDAY-1)) 
   JDayNUM = reform(JDayNUM(0:NDAY-1))
   if( Keyword_Set( Daynum) ) then Daynum = reform(daynum(0:NDAY-1)) 
   if( Keyword_Set(MonNum) ) then MonNUM = reform(MonNum(0:NDAY-1))
     

 END  
    




