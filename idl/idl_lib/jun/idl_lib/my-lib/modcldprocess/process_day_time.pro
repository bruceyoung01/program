PRO process_day, infile, Nday, AllFileName, StartInx, EndInx, $
                  DAYNAME, DAYNUM
    
    AllFileName = strarr(5000)
    OneLine = ' '
    i = 0
   
   ; check out how many files
    openr, 1, infile
    while ( not eof(1) ) do begin
       readf, 1, oneline
       AllFileName(i) = OneLine
       i = i +1
    endwhile
    close, 1
    NFile = i


   ; decode day and night
   Days = [0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334, 365]
   NM = 12    ; total 12 months per year

   StartInx = intarr(80)
   EndInx = intarr(80)
   DayName = strarr(80)
   DayNUM = intarr(80)
   
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
	     DayNum(DI) = tmpday  
	     SSINX = i+1
	     DI = DI + 1
	  endif
    endfor	 

    NDAY = DI 

 END  
    




