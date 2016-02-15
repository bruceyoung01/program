;  $ID: build_ncep_fnl_filename.ncl V01 08/07/2015 17:15 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE build_ncep_fnl_filename.ncl BUILDS NCEP FNL FILE NAMES BASED ON 
;  THE YEAR, MONTH, DAY, AND HOUR, AND GRIB1 & GRIB2 EXTENSION.
;
;  BUILD FNL FILE NAME BASED ON THE YEAR, MONTH, DAY, AND HOUR
;  GRIB1 IS 19990730_18_00~20071206_06_00;
;  GRIB2 IS 20071206_12_00~CURRENT;
;  SO WE NEED TO CONSIDER THIS WHILE WE BUILD FILE NAMES.
;  VARIABLES:
;  ============================================================================
;  (1 ) iyear    (a scalar):YEAR FOR THE FNL FILE                         [   ]
;  (2 ) imonth   (a scalar):MONTH FOR THE FNL FILE                        [   ]
;  (3 ) iday     (a scalar):DAY FOR THE FNL FILE                          [   ]
;  (4 ) ihour    (a scalar):HOUR FOR THE FNL FILE                         [   ]
;  (5 ) filename (a string):THE BUILT FNL FILE NAME                       [   ]
;  (6 ) extension(a string):FNL FILE NAME EXTENSION                       [   ]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (08/07/2015)
;******************************************************************************
undef("build_ncep_fnl_filename")
procedure build_ncep_fnl_filename \
          (iyear     :integer,       imonth      :integer, \;INPUT
           iday      :integer,       ihour       :integer, \;INPUT
           filename  :string,        extension   :string)   ;OUTPUT

begin

;  CONVERT YEAR, MONTH, DAY, AND HOUR TO STRING
   siyear     = sprinti("%0.4i", iyear)
   simonth    = sprinti("%0.2i", imonth)
   siday      = sprinti("%0.2i", iday)
   sihour     = sprinti("%0.2i", ihour)
   extension1 = "grib1"
   extension2 = "grib2"

;  DISTINGUISH THE GRIB1 AND GRIB2 BASED ON TIME
   if (iyear  .lt. 2007) then
      filename = "fnl_" + siyear + simonth + siday + "_" + \
                 sihour + "_00." + extension1
      extension= extension1
   else if (iyear .eq. 2007) then
      if (imonth .lt. 12) then
         filename = "fnl_" + siyear + simonth + siday + "_" + \
                    sihour + "_00." + extension1
         extension= extension1
      else if (imonth .eq. 12) then
         if (iday .lt. 6) then
            filename = "fnl_" + siyear + simonth + siday + "_" + \
                       sihour + "_00." + extension1
            extension= extension1
         else if (iday .eq. 6)
            if (ihour .le. 6) then
               filename = "fnl_" + siyear + simonth + siday + "_" + \
                          sihour + "_00." + extension1
               extension= extension1
            else
               filename = "fnl_" + siyear + simonth + siday + "_" + \
                          sihour + "_00." + extension2
               extension= extension2
            end if
         else
            filename = "fnl_" + siyear + simonth + siday + "_" + \
                       sihour + "_00." + extension2
            extension= extension2
         end if
         end if
      else
         filename = "fnl_" + siyear + simonth + siday + "_" + \
                    sihour + "_00." + extension2
         extension= extension2
      end if
      end if
   else
      filename = "fnl_" + siyear + simonth + siday + "_"  + \
                 sihour + "_00." + extension2
      extension= extension2
   end if
   end if

return
end
