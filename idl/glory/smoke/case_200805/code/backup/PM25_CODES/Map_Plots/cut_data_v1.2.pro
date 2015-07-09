; $id: cut_data.pro  v1.2  2010/03/14 xxu $
;********************************************************************** 
;  Cut the data "Simple_New_RD_501_88502_YYYY-0.txt"
;  reform them sitely...
;
;   Routines referenced by code "cut_data.pro"
;  ====================================================================
;   (1) readcol.pro
;   (2) leapyr.pro
;********************************************************************** 

;  Some directory

   data_root = '/home/npothier/Assistanceship/EPAAIRS/'

;======================================================================
; Read Station info: State, County, and Station code, and location
;======================================================================

;  site code file: "Simple_new_site_monitor.txt"
   file_site_code = data_root+'SimplifiedData/Simple_new_site_monitor.txt'

   ; read site info
   readcol, file_site_code, class, STATE_LABL, COUNTY_LABL,SITE_LABL, $
            SITE_LAT, SITE_LON,  $
            FORMAT = 'A, A, A, A, F, F', skipline = 1

   ; convert string to LONG integer
   STATE_CODE  = LONG(STATE_LABL)
   COUNTY_CODE = LONG(COUNTY_LABL)
   SITE_CODE   = LONG(SITE_LABL)
   NSITE = N_ELEMENTS(STATE_CODE)

;  Start the year loop here ...
;  ----------------------------
   for iyear = 1999L, 2009L do begin

;======================================================================
; Read row data: "Simple_New_RD_501_88502_YYYY-0.txt"
;======================================================================

   ; define the data file name
   THIS_YEAR = iyear
   row_data_file = 'Simple_New_RD_501_88502_'+strtrim(THIS_YEAR,1)+'-0.txt'
   row_data_file = data_root + 'SimplifiedData/'+row_data_file
   print, 'Read row data from: '
   print, '   -- ', row_data_file

   ; read data from file
   readcol, row_data_file, all_state_id, all_county_id, all_site_id, $
            all_year, all_mon, all_day, all_time, all_pm25,          $
            FORMAT = 'I, I, I, I, I, I, I, F', skipline = 1 

   ; open a file to store the data count
   coount_file ='EPAAIRS_PM25_DATA_COUNT_HOURLY_'+strtrim(THIS_YEAR,1) +'.txt'
   coount_file =data_root+'sitely/'+coount_file

   openw, 21, coount_file

;======================================================================
; Extract data for  each station
;======================================================================

   ; start site loop: isite
   for isite = 0, NSITE-1 do begin

     ; find the exact time-space point
     idx_match_site = where( all_state_id  eq STATE_CODE[isite]  $
                        and  all_county_id eq COUNTY_CODE[isite] $
                        and  all_site_id   eq SITE_CODE[isite]   $
                             , count_match_site ) 

     if ( count_match_site ne 0) then begin

       ; write to the data count file
       printf, 21, STATE_LABL[isite], COUNTY_LABL[isite], SITE_LABL[isite], $
                   count_match_site, format = '(A2,1X,A3,1X,A4,1X,I6)'

       new_mon = all_mon[idx_match_site]
       new_day = all_day[idx_match_site]
       new_time = all_time[idx_match_site]
       new_pm25 = all_pm25[idx_match_site]

       ; write to the reformed new data file
       sitely_filename = 'EPAAIRS_PM_'+strtrim(THIS_YEAR,1) +   $
                         '_'+class[isite]+'_'+STATE_LABL[isite]+$
                         '_'+COUNTY_LABL[isite]+'_'+SITE_LABL[isite]+'.DAT'
       sitely_filename = data_root+'sitely/'+sitely_filename
       openw, 11, sitely_filename

       for i = 0, count_match_site-1 do begin
         printf, 11, new_mon[i], new_day[i], new_time[i]/100, new_pm25[i], $
                     format = '(I2, 1X, I2, 1X, I4, 1X, F6.1)'
       endfor
       close,11
       
     endif else begin
       print, '** No data available --> state: '+ STATE_LABL[isite]  $
                                    +' county: '+ COUNTY_LABL[isite] $ 
                                    +  ' site: '+ SITE_LABL[isite] 
     endelse

   ; finish site loop: isite
   endfor 
 
   ; close the data count file
   close, 21

   ; finish the year loop: iyear
   endfor
        

   END
