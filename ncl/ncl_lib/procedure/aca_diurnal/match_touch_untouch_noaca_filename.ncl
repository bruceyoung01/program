;  $ID: match_touch_untouch_noaca_filename.ncl V01 07/06/2015 23:23 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE match_touch_untouch_noaca_filename.ncl MATCHES OUTPUT FILES OF TOUCH, 
;  UNTOUCH, AND NO ACA CASES, SO THAT THEY HAPPEN AT THE SAME TIME.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (07/06/2015)
;******************************************************************************
undef("match_touch_untouch_noaca_filename")
procedure match_touch_untouch_noaca_filename \
          (dir                 :string,                             \;INPUT
           start_year          :integer, end_year         :integer, \;INPUT
           start_month         :integer, end_month        :integer, \;INPUT
           start_day           :integer,                            \;INPUT
           start_hour          :integer, end_hour         :integer, \;INPUT
           start_min           :integer, end_min          :integer, \;INPUT
           min_interval        :integer,                            \;INPUT
           method              :string,  case             :string,  \;INPUT
           sday_or_night       :string,                             \;INPUT
           filelist            :string)                              ;OUTPUT
begin

;  DELETE filelist IF IT EXISTS
   if (fileexists(dir + filelist)) then
      system("rm " + dir + filelist)
   end if
   nmethod       = dimsizes(method)
   ncase         = dimsizes(case)
   nday_or_night = dimsizes(sday_or_night)
;  MATCH ALL THE FILES WITH THE SAME YEAR, MONTH, DAY, AND HOUR
;  CASE, METHOD, AND DAYTIME OR NIGHTTIME.
   do iyear = start_year, end_year
      do imonth = start_month, end_month
;  CALCULATE THE NUMBER OF DAYS IN THIS MONTH
         nday_month = days_in_month(iyear, imonth)
         do iday = start_day, nday_month
            siyear  = sprinti("%0.4i", iyear)
            simonth = sprinti("%0.2i", imonth)
            siday   = sprinti("%0.2i", iday)
            symd1   = siyear + "_" + simonth + "_" + siday
print("-----------" + symd1 + "-------------")
            do ihour = start_hour, end_hour
               do imin = start_min, end_min, min_interval
                  sihour = sprinti("%0.2i", ihour)
                  simin  = sprinti("%0.2i", imin)
                  stime  = sihour + "-" + simin + "-00"
                  do iday_or_night = 0, nday_or_night-1
                     do imethod = 0, nmethod-1
                        filename_touch     = "touch" + "_" + method(imethod) + "_"  +     \
                                             sday_or_night(iday_or_night) + "_" + symd1 + \
                                             "_" + stime + "_ESMF.txt"
                        filename_untouch   = "untouch" + "_" + method(imethod) + "_"  +   \
                                             sday_or_night(iday_or_night) + "_" + symd1 + \
                                             "_" + stime + "_ESMF.txt"
                        filename_uncertain = "uncertain" + "_" + method(imethod) + "_"  + \
                                             sday_or_night(iday_or_night) + "_" + symd1 + \
                                             "_" + stime + "_ESMF.txt"
;  CHECK WHETHER ACA CASES EXIST, INCLUDING TOUCH, UNTOUCH, AND UNCERTAIN
                        if (fileexists(dir + filename_touch)   .or. \
                            fileexists(dir + filename_untouch) .or. \
                            fileexists(dir + filename_uncertain)) then
                           if (imethod .eq. 0) then
                              ncase = 4
                           else if (imethod .eq. 1) then
                              ncase = 5
                           end if
                           end if
                           filelist_tmp   = new((/ncase/), string)
                           do icase = 0, ncase-1
                              filelist_tmp(icase) = case(icase) + "_" + method(imethod) + "_" +  \
                                                    sday_or_night(iday_or_night) + "_" + symd1 + \
                                                    "_" + stime + "_ESMF.txt"
;  WRITE DOWN FILE NAMES INTO A FILELIST
                              if (fileexists(dir + filelist_tmp(icase))) then
                                 filelist_tmp_list = [/filelist_tmp(icase)/]
                                 print_table(filelist_tmp_list, "%s")
                                 write_table(dir + filelist, "a", filelist_tmp_list, "%s")
                              end if
                           end do
                           delete([/filelist_tmp/])
                        end if
                     end do ;imethod
                  end do ;iday_or_night
               end do ;imin
            end do ;ihour
         end do ;iday
      end do ;imonth
   end do ;iyear
print("----------------------------------------")
print("Complete to match file name ")
print("----------------------------------------")

return
end
