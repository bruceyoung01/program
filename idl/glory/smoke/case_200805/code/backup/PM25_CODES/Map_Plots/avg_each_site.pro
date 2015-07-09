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

;  Some directory & constents
   data_root = '/home/npothier/Assistanceship/EPAAIRS/'

   nhour = 24
   nyear = 1  ; 1999 - 2009
   YSYART = 2008

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

;  define average PM
   avg_PM = fltarr(NSITE,NHOUR) - 999.
   avg_PM_l2 = fltarr(NSITE,NHOUR) - 999.
   avg_PM_l2_mean = fltarr(NSITE) - 999.
   avg_PM_l2_stdv = fltarr(NSITE) - 999.
   avg_PM_l2_min = fltarr(NSITE) - 999.
   avg_PM_l2_max = fltarr(NSITE) - 999.
   min_hour = fltarr(NSITE) - 999.
   max_hour = fltarr(NSITE) - 999.
   
  ; avg_PM = fltarr(NSITE,NHOUR) 
  ; avg_PM_l2 = fltarr(NSITE,NHOUR) 
  ; avg_PM_l2_mean = fltarr(NSITE)
  ; avg_PM_l2_stdv = fltarr(NSITE)
  ; avg_PM_l2_min = fltarr(NSITE)
  ; avg_PM_l2_max = fltarr(NSITE) 
  ; min_hour = fltarr(NSITE)
  ; max_hour = fltarr(NSITE) 


; =====================================================================
;  open an ps file for ploting daily & yearly variation
; =====================================================================

   SET_PLOT, 'PS'
   DEVICE,FILENAME= './figures_each_site/variation.ps', $
          XSIZE=8.5, YSIZE=10, $
          XOFFSET=0.5, YOFFSET=0.5,$
          /INCHES,/color,BITS=8

;  Start the site loop: isite
   for isite = 0, nsite-1 do begin

     yearly_PM = fltarr(NYEAR, NHOUR) - 999.

;  Start year loop: iyear

     for iyear = 0, nyear-1 do begin

       ;===============================================================
       ;  Read hourly data for each site
       ;===============================================================

       THIS_YEAR = YSYART + iyear
       
       ; is THIS_YEAR leap year?
        case leapyr(THIS_YEAR) of
          1: nday_THIS_YEAR = 366L
          0: nday_THIS_YEAR = 355L
        endcase

       sitely_filename = 'EPAAIRS_PM_'+strtrim(THIS_YEAR,1) +   $
                         '_'+class[isite]+'_'+STATE_LABL[isite]+$
                         '_'+COUNTY_LABL[isite]+'_'+SITE_LABL[isite]+'.DAT'
       sitely_filename = data_root+'sitely/'+sitely_filename

       if ( file_exist(sitely_filename) ) then begin

         print, sitely_filename
         readcol, sitely_filename, month, day, hour, PM_sitely, format='I,I,I,F'

         all_available_PM = fltarr(nday_THIS_YEAR, nhour)

         for ihour = 0, nhour-1 do begin

           idx_hour = where(hour eq ihour and PM_sitely gt 0, count_hour)
           if ( count_hour gt 0) then begin

             ; temp data for iday loop use
             PM_temp = PM_sitely[idx_hour]
             mon_temp = month[idx_hour]
             day_temp = day[idx_hour]

             ; ================================================================
             ; find value for each day
             ; ================================================================

             for iday = 0, nday_THIS_YEAR - 1 do begin

               ; convert iday to month and day
               ydn2md, THIS_YEAR, iday+1, THIS_MONTH, THIS_DAY

               idx_iday = where(mon_temp eq THIS_MONTH and $
                                day_temp eq THIS_DAY, count_iday)
               if (count_iday ge 1) then begin
                  all_available_PM(iday,ihour) = PM_temp[idx_iday[0]]
               endif else begin
                  all_available_PM(iday,ihour) = -999.
               endelse

             endfor ; iday

           endif

         endfor ; ihour

         for iday = 0, nday_THIS_YEAR - 1 do begin
           idx_24hr = where(all_available_PM(iday,*) gt 0, count_24hr)
           ;if ( count_24hr lt nhour) then all_available_PM(iday,*) = -999.
         endfor

         for ihour = 0, nhour-1 do begin
           idx_365dy = where(all_available_PM(*,ihour) gt 0, count_365dy)
           if (count_365dy gt 0) then begin
             yearly_PM[iyear,ihour] = mean(all_available_PM[idx_365dy,ihour])
           endif
         endfor

         ;=====================================================================
         ; plot (1) whole year PM; (2) diurnal variation
         ;=====================================================================
         @plot_whole_year_PM.pro
  
       endif 

     endfor ; finish year loop: iyear

     ;=========================================================================
     ; Average over each hour
     ;=========================================================================

     for ihour = 0, nhour-1 do begin
       idx_year = where(yearly_PM[*,ihour] gt 0., count_year)
       if (count_year gt 0) then begin
         avg_PM[isite,ihour] = mean(yearly_PM[idx_year,ihour])
       endif
     endfor
    	;omaha=where(STATE_LABL[isite] eq 31 and COUNTY_LABL[isite] eq 055 and SITE_LABL[isite] eq 0019)
     ; level 2 data only for stations having all 24 hour values
     idx_l2_hour = where(avg_PM[isite,*] gt 0, count_l2_hour)
     ;if (count_l2_hour eq 24) then begin

       avg_PM_l2[isite,*] = avg_PM[isite,*]
       ;avg_PM_l2_mean[isite]= 
       avg_PM_l2_mean[isite] = mean(avg_PM_l2[isite,*])
       
       avg_PM_l2_stdv[isite] = stddev(avg_PM_l2[isite,*])
       avg_PM_l2_min[isite] = min(avg_PM_l2[isite,*],index_min)
       avg_PM_l2_max[isite] = max(avg_PM_l2[isite,*],index_max)
       min_hour[isite]      = index_min
       max_hour[isite]      = index_max

     ;endif

   endfor ; finish site loop: isite
;print, avg_PM_l2_mean[omaha]
   DEVICE, /CLOSE

;  start to plot

   ;===========================================================================
   ;  plot hour histogram for min & max value
   ;===========================================================================

   hist_min_hour = histogram(min_hour[where(min_hour ge 0)])
   hist_max_hour = histogram(max_hour[where(max_hour ge 0)])

   n_min_hour = n_elements(hist_min_hour)
   n_max_hour = n_elements(hist_max_hour)

   SET_PLOT, 'PS'
   DEVICE,FILENAME= './figures_each_site/histogram_hour.ps', $
          XSIZE=8.5, YSIZE=10, $
          XOFFSET=0.5, YOFFSET=0.5,$
          /INCHES,/color,BITS=8

   plot, [10], [10], /nodata, color=1, $
         xrange = [-0.9, 24.9], xstyle = 1, $
         yrange = [0,100], ystyle = 1, $
         xtitle = '!6Hour', ytitle = '!6No. of Sites', $
         title = '!6Histogram for Hours of Daily PM!d2.5!n Max & Min, N!dsites!n:'+$
         STRING(total(hist_min_hour), format='(I4)'), $
         position = [0.2,0.4,0.8,0.7] 
  
   for i_min = 0, n_min_hour-1 do begin
     plots, [i_min-0.05,i_min-0.05], [0,hist_min_hour[i_min]], color = 4, thick=3
   endfor
  
   for i_max = 0, n_max_hour-1 do begin
     plots, [i_max+0.05,i_max+0.05], [0,hist_max_hour[i_max]], color = 2, thick=3
   endfor

   plots, [0,2],[90,90], color = 2, thick=3
   xyouts, 2.2, 89, '!6Hour for Max', color =1 
   plots, [0,2],[80,80], color = 4, thick=3
   xyouts, 2.2, 79, '!6Hour for Min', color =1

   DEVICE, /close


   ;===========================================================================
   ;  Plot  for each hour
   ;===========================================================================
   
   ps_filename = './figures_each_site/avg_pm25_hourly_v2'
   SET_PLOT, 'PS'
   DEVICE,FILENAME= ps_filename+'.ps', $
          XSIZE=8.5, YSIZE=10, $
          XOFFSET=0.5, YOFFSET=0.5,$
          /INCHES,/color,BITS=8
   LOADCT, 33, ncolor = 50, bottom = 20 

   for ihour = 0, nhour-1 do begin

     idx_site = where(avg_PM_l2[*,ihour] ge 0., count_site)
     if (count_site gt 0) then begin

       title = '!6Average PM!d2.5!n @ hour ' + strtrim(ihour,1) $
               + '   N!dsite!n: ' + strtrim(count_site,1)
       PM25_map_plot, SITE_LAT[idx_site], SITE_LON[idx_site], $
                      avg_PM_l2[idx_site,ihour], title

     endif

   endfor

   device, /close

   ;===========================================================================
   ;  Clock plot
   ;===========================================================================

   idx_clock = where(avg_PM_l2_mean gt 0, count_clock)
   if (count_clock gt 0) then begin
     plot_clock_v2, SITE_LAT[idx_clock], SITE_LON[idx_clock], $
                 avg_PM_l2_mean[idx_clock], avg_PM_l2_stdv[idx_clock], $
                 avg_PM_l2_min[idx_clock], avg_PM_l2_max[idx_clock], $
                 min_hour[idx_clock], max_hour[idx_clock], '  '

   endif

;  end of the program

   end
