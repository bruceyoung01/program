;  ID: select_seviri_modis_filename.ncl 07/21/2015 14:46 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE select_seviri_modis_filename.ncl SELECTS SEVIRI FILE NAME BASED ON 
;  MODIS FILE NAME.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) m6dir            (a string):MODIS DATA DIRECTORY                  [   ]
;  (2 ) sm6filename      (a string):MODIS FILE NAME                       [   ]
;  (3 ) sdir             (a string):SEVIRI DATA DIRECTORY                 [   ]
;  (4 ) ssfilename       (a string):SEVIRI FILE NAME                      [   ]
;  (5 ) logic_ssfilename (a string):LOGICAL VARIABLE TO CHECK IF FILE EXISTS[ ]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (07/21/2015)
;******************************************************************************
undef("select_seviri_modis_filename")
procedure select_seviri_modis_filename \
          (m6dir      :string,  sm6filename      :string, \;INPUT
           sdir       :string,                            \;INPUT
           ssfilename :string,  logic_ssfilename :logical) ;OUTPUT

begin
;  EXTRACT YEAR, MONTH, DAY, HOUR, AND MIN FROM MODIS MOD06_L2/MYD06_L2
   myear   = stringtoint(str_get_cols(sm6filename, 10, 13))
   mjulian = stringtoint(str_get_cols(sm6filename, 14, 16))
   mhr     = stringtoint(str_get_cols(sm6filename, 18, 19))
   mmin    = stringtoint(str_get_cols(sm6filename, 20, 21))

;  CONVERT JULIAN DAY TO MONTH AND DAY
   md      = monthday(myear, mjulian)
   smd     = sprinti("%4.4i", md)
   mmonth  = str_get_cols(smd, -4, -3)
   mday    = str_get_cols(smd, -2, -1)

;  SINCE WE ONLY CONSIDER DAYTIME DATA OF MODIS/AQUA AND SEVIRI. FOR MODIS, ITS 
;  PASSING TIME IS ABOUT 13:30 LOCAL TIME. SO WE ONLY CONSIDER MODIS HOUR 10~18
;  IF MODIS HOUR IS 10~18, THEN WE WILL CONTINUE TO SELECT SEVIRI DATA, OTHERWISE, 
;  WE WILL IGNORE THIS MODIS FILE AND CONTINUE TO THE NEXT FILE
;  ALSO CONSIDER SEVIRI MINUTE IS 00, 15, 30, 45.
   if (mhr .ge. 10 .and. mhr .le. 18) then
      if (mmin .ge. 0 .and. mmin .le. 5) then
         shr  = mhr
         smin = sprinti("%0.2i", 0)
      else if (mmin .ge. 10 .and. mmin .le. 20) then
         shr  = mhr
         smin = sprinti("%0.2i", 15)
      else if (mmin .ge. 25 .and. mmin .le. 35) then
         shr  = mhr
         smin = sprinti("%0.2i", 30)
      else if (mmin .ge. 40 .and. mmin .le. 50) then
         shr  = mhr
         smin = sprinti("%0.2i", 45)
      else if (mmin .ge. 55) then
         shr  = mhr + 1
         smin = sprinti("%0.2i", 0)
      end if
      end if
      end if
      end if
      end if

;  DEPEND ON YEAR, MONTH, DAY, HOUR, AND MIN TO BUILD SEVIRI FILE NAME
      symd       = myear + "-" + mmonth + "-" + mday
      stime      = shr   + "-" + smin   + "-00"
      ssfilename = "SEV_06-CLD-L2_" + symd + "T" + stime + "_V1-03.hdf"
   else
      logic_ssfilename = False
   end if

end
