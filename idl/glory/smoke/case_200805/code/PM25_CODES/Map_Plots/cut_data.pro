;
;
;   Routines referenced by code "cut_data.pro"
;   ===========================================
;   (1) readcol.pro
;   (2) leapyr.pro
;

;  Some directory

   data_root = '/fs1/EPA/EPAAIRS_DATA/'


;======================================================================
; Read Station info: State, County, and Station code, and location
;======================================================================

;  site code file: "Simple_new_site_monitor.txt"
   file_site_code = data_root+'site_info/Simple_new_site_monitor.txt'

   ; read site info
   readcol, file_site_code, class, STATE_LABL, COUNTY_LABL,SITE_LABL, $
            SITE_LAT, SITE_LON,  $
            FORMAT = 'A, A, A, A, F, F', skipline = 1

   ; convert string to LONG integer
   STATE_CODE  = LONG(STATE_LABL)
   COUNTY_CODE = LONG(COUNTY_LABL)
   SITE_CODE   = LONG(SITE_LABL)
   NSITE = N_ELEMENTS(STATE_CODE)

   STOP

;======================================================================
; Read row data: "Simple_New_RD_501_88502_YYYY-0.txt"
;======================================================================

   ; define the data file name
   THIS_YEAR = 2008L
   row_data_file = 'Simple_New_RD_501_88502_'+strtrim(THIS_YEAR,1)+'-0.txt'
   row_data_file = data_root + 'rowdata/'+row_data_file
   print, 'Read row data from: '
   print, '   -- ', row_data_file

   ; read data from file
   readcol, row_data_file, all_state_id, all_county_id, all_site_id, $
            all_year, all_mon, all_day, all_time, all_pm25,          $
            FORMAT = 'I, I, I, I, I, I, I, F', skipline = 1 

;======================================================================
; Extract data for each hour, each station
;======================================================================

   case leapyr(THIS_YEAR) of 
     1: nday = [31L, 29L, 31L, 30L, 31L, 30L, 31L, 31L, 30L, 31L, 30L, 31L]
     0: nday = [31L, 28L, 31L, 30L, 31L, 30L, 31L, 31L, 30L, 31L, 30L, 31L]
   endcase
   
   print, nday
   ; start mohth loop: imon
   for imon = 0L, 11L do begin

     THIS_MONTH = imon + 1L

     ; start day loop: iday
     for iday = 0L, nday[imon] - 1L do begin
       
       THIS_DAY = iday + 1L
       THIS_DYN = YMD2DN(THIS_YEAR, THIS_MONTH, THIS_DAY)

       ; start hour loop: ihr
       for ihr = 0L, 23L do begin

         THIS_HOUR = ihr
         THIS_DATE_HR = [THIS_YEAR, THIS_DYN, THIS_HOUR, 0, 0]
         YYYYMMDDHH = DATE_CONV(THIS_DATE_HR, 'F')
         
         ; output file name
         FILENAME_HOURLY = 'EPAARIS_PM26_HR_'+STRMID(YYYYMMDDHH,0, 13)+'.TXT'
         FILENAME_HOURLY = data_root+'hourly/'+FILENAME_HOURLY
         print, FILENAME_HOURLY
         
         ; define one array
         PM25_hr = fltarr(NSITE)

         ; start site loop: isite
         for isite = 0, NSITE-1 do begin

            ; find the exact time-space point
            idx_match_site = where( all_state_id  eq STATE_CODE[isite]  $
                               and  all_county_id eq COUNTY_CODE[isite] $
                               and  all_site_id   eq SITE_CODE[isite]   $
                               and  all_year      eq THIS_YEAR          $
                               and  all_mon       eq THIS_MONTH         $
                               and  all_day       eq THIS_DAY           $
                               and  all_time      eq THIS_HOUR*100L,    $
                               count_match_site )     

            if ( count_match_site eq 0) then begin
              pm25_hr[isite] = -999
            endif else begin
              pm25_hr[isite] = all_pm25[idx_match_site[0]]
            endelse

         ; finish site loop: isite
         endfor 
         
         ; save the hourly data
         openw, 11, FILENAME_HOURLY
         for isite = 0, nsite-1 do begin
           printf, 11, pm25_hr[isite]
         endfor
         close, 11

       ; finish hour loop: ihr
       endfor
    
     ; finish day loop: iday
     endfor

   ; finish mohth loop: imon 
   endfor

   
         

   END
