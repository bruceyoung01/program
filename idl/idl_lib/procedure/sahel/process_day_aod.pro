;
; Purpose: read the list of MODIS granule names, and
;          find out how many days are these granules 
;          collected. the start name index and ending index
;          for each day. 
;

; INPUT:   infile, input file name that lists granuel filenames
; Output:  
;          nday, number of days
;   allfilename, array that saves all granule filenames
;   startinx,   array that the dimension of nday, index 
;               where allfilename starts have the granules
;               names for that day
;   endinx,     same as startinx but for ends graduale names
;               for that day         
;   dayname,    array has the dimension of nday, save names for
;               each day.
;   daynum,     array pointing to the Julian day.

PRO process_day_aod, infile, Nday, AllFileName, StartInx, EndInx, $
                  YEAR=year, Mon=mon, Date=Date, TimeS = TimeS, $
                  TimeE = TimeE, Dayname, DAYNUM
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
;   Days = [0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334, 365]
    Days = [0, 31, 60, 91, 121, 152, 182, 213, 244, 274, 305, 335, 366]
   NM = 12    ; total 12 months per year

  nday_max = 366

   StartInx = intarr(nday_max)
   EndInx = intarr(nday_max)
   DayName = strarr(nday_max)
   DayNUM = intarr(nday_max)
   YEAR = intarr(nday_max)
   MON = intarr(nday_max)
   Date = intarr(nday_max)
   TimeS = strarr(nday_max) 
   TimeE = strarr(nday_max) 



   SSINX = 0
   DI  = 0
   for i = 0, Nfile-1 do begin

      ; from file name to julian day
         OneF = AllFileName(i)                       ; current day
         JulianD = fix(strmid (OneF, 14, 3))
;         print, 'oneF = ', oneF  
         YearC = fix(strmid (OneF, 10, 4))

         NxF = AllFileName(i+1)                           ; next day
         NxJD = fix ( strmid ( NxF, 14, 3))

       ; get the month correct
         for k = 0, NM-1 do begin
         if ( JulianD ge Days(k)+1 and JulianD lt Days(k+1)+1 ) then  begin
         
            if ( k+1 ge 10 ) then begin 
            Month = string ( k+1, format = '(I2)')
            endif else begin
            Month = '0' + string ( k+1, format = '(I1)')
            endelse

            if ( JulianD - Days(k) ge 10 ) then begin
            Day = string (JulianD - Days(k), format = '(I2)')
            endif else begin
            Day = '0' + string (JulianD - Days(k), format = '(I1)')
            endelse

            tmpday = (k+1)*100 + (JulianD - Days(k))
         endif
         endfor

       ; judget if on the same day
          if ( JulianD ne NxJD  ) then begin
             ENDINX(DI)  = I
             STARTINX(DI) = SSINX
             YEAR(DI) = YearC 
             MON(DI) = fix(Month)
             Date(DI) = fix(Day) 
             TimeS(DI) = strmid(AllFileName(SSINX), 18, 4) 
             TimeE(DI) = strmid(AllFileName(I), 18, 4)
             DayNum(DI) = tmpday
             DAYNAME(DI) = Month + Day + $
                           'JD' + strmid (AllFileName(SSINX), 14, 3)
             SSINX = i+1
             DI = DI + 1
          endif
    endfor

    NDAY = DI
    
 END

