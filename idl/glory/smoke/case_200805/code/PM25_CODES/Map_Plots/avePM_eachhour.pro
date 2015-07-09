; $id: avgPM_eachhour.pro  v1.1 2010/03/15 xxu $
;**********************************************************************
;  Calculate the PM25 average for each hour ...
;  
;   Routines referenced by code "avgPM_eachhour.pro"
;   ===================================================================
;    (1) 
;    (2)
;**********************************************************************
;

   @./pm25_map_plot.pro
   @./colorbar.pro
   @./plot_clock_v2.pro


;;;From what I can tell, this only prints out the average for hour 0, for year
;;;2008


;  Some directory & constents
   data_root = '/mnt/sdc/data/epa/epa_data/PM25_DATA/PM25_Simplified_Data/'

   nhour = 24
   nyear = 1  ; 1999 - 2009
   YSYART = 2008

;======================================================================
; Read Station info: State, County, and Station code, and location
;======================================================================

;  site code file: "Simple_new_site_monitor.txt"
   file_site_code = data_root+'Simple_new_site_monitor.txt'

   ; read site info
   readcol, file_site_code, class, STATE_LABL, COUNTY_LABL,SITE_LABL, $
            SITE_LAT, SITE_LON,  $
            FORMAT = 'A, A, A, A, F, F', skipline = 1

   ; convert string to LONG integer
   STATE_CODE  = LONG(STATE_LABL)
   COUNTY_CODE = LONG(COUNTY_LABL)
   SITE_CODE   = LONG(SITE_LABL)
   ;;;Should the number of sites be equal to the number of states???
   NSITE = N_ELEMENTS(STATE_CODE)

;  define average PM
;   avg_PM = fltarr(NSITE,NHOUR) - 999.
;   avg_PM_l2 = fltarr(NSITE,NHOUR) - 999.
;   avg_PM_l2_mean = fltarr(NSITE) - 999.
;   avg_PM_l2_stdv = fltarr(NSITE) - 999.
;   avg_PM_l2_min = fltarr(NSITE) - 999.
;   avg_PM_l2_max = fltarr(NSITE) - 999.
;   min_hour = fltarr(NSITE) - 999.
;   max_hour = fltarr(NSITE) - 999.


;  Start the site loop: isite
   for isite = 0, nsite-1 do begin

     yearly_PM = fltarr(NYEAR, NHOUR) - 999.

;  Start year loop: iyear
;;;wouldn't this start at 2008 and then not increment at all, since nyear=1???
     for iyear = 0, nyear-1 do begin

       ;===============================================================
       ;  Read hourly data for each site
       ;===============================================================

       THIS_YEAR = YSYART - iyear
       sitely_filename = 'EPAAIRS_PM_'+strtrim(THIS_YEAR,1) +   $
                         '_'+class[isite]+'_'+STATE_LABL[isite]+$
                         '_'+COUNTY_LABL[isite]+'_'+SITE_LABL[isite]+'.DAT'
       sitely_filename = data_root+'sitely/'+sitely_filename

       if ( file_exist(sitely_filename) ) then begin

         print, sitely_filename
         readcol, sitely_filename, month, day, hour, PM_sitely, format='I,I,I,F'

         ; start hour loop
         for ihour = 0, nhour-1 do begin

           idx_hour = where(hour eq ihour, count_hour)
           if ( count_hour gt 0) then begin   
             yearly_PM[iyear,ihour] = mean(PM_sitely[idx_hour])
           endif

         endfor ; ihour

       endif 

     endfor ; finish year loop: iyear

     ;=========================================================================
     ; Average over each hour
     ;=========================================================================

     ;for ihour = 0, nhour-1 do begin
     ;  idx_year = where(yearly_PM[*,ihour] gt 0., count_year)
     ;  if (count_year gt 0) then begin
     ;  ;;;is this actually finding the mean over the total ten year period?  or 
     ;  ;;;just the mean for each hour for a single year?
     ;    avg_PM[isite,ihour] = mean(yearly_PM[idx_year,ihour])
     ;  endif
     ;endfor

     ; level 2 data only for stations having all 24 hour values
     ;idx_l2_hour = where(avg_PM[isite,*] gt 0, count_l2_hour)
     ;if (count_l2_hour eq 24) then begin

    ;;;I am assuming that this here is now taking the average over the total
    ;;;ten year period???
     ;  avg_PM_l2[isite,*] = avg_PM[isite,*]
     ;  avg_PM_l2_mean[isite] = mean(avg_PM_l2[isite,*])
     ;  avg_PM_l2_stdv[isite] = stddev(avg_PM_l2[isite,*])
     ;  avg_PM_l2_min[isite] = min(avg_PM_l2[isite,*],index_min)
     ;  avg_PM_l2_max[isite] = max(avg_PM_l2[isite,*],index_max)
     ;  min_hour[isite]      = index_min
     ;  max_hour[isite]      = index_max

     ;endif

   endfor ; finish site loop: isite

;  start to plot

   ;===========================================================================
   ;  Plot for each hour, using routine "PM25_map_plot"
   ;===========================================================================

;;;How do you get it to plot 24 separate plots???   
   

   for ihour = 0, nhour-1 do begin

;    ps_filename = './figures/avg_pm25_hourly'+ '_' + strtrim(ihour,1)
    ps_filename = './figures/pm25_hourly'+ '_' + strtrim(ihour,1)
    SET_PLOT, 'PS'
    DEVICE,FILENAME= ps_filename+'.ps', $
          XSIZE=8.5, YSIZE=10, $
          XOFFSET=0.5, YOFFSET=0.5,$
          /INCHES,/color,BITS=8
    LOADCT, 33, ncolor = 50, bottom = 20 


     idx_site = where(avg_PM_l2[*,ihour] gt 0., count_site)
     if (count_site gt 0) then begin

       title = '!6Average PM!d2.5!n @ hour ' + strtrim(ihour,1) $
               + '   N!dsite!n: ' + strtrim(count_site,1)
       PM25_map_plot, SITE_LAT[idx_site], SITE_LON[idx_site], $
                      avg_PM_l2[idx_site,ihour], title

     endif

    device, /close	
    
   endfor

   

   ;===========================================================================
   ;  Clock plot, using "plot_clock"
   ;===========================================================================


;;;which version of "plot_clock" should be used here???
   idx_clock = where(avg_PM_l2_mean gt 0, count_clock)
   if (count_clock gt 0) then begin
     plot_clock_v2, SITE_LAT[idx_clock], SITE_LON[idx_clock], $
                 avg_PM_l2_mean[idx_clock], avg_PM_l2_stdv[idx_clock], $
                 avg_PM_l2_min[idx_clock], avg_PM_l2_max[idx_clock], $
                 min_hour[idx_clock], max_hour[idx_clock], '  '

   endif

;  end of the program

   end
