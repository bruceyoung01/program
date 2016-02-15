;  $ID: select_modis_mod08_filename.ncl V01 06/16/2015 17:58 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE select_modis_mod08_filename SELECTS MOD08/MYD08 FILE NAME BASED 
;  ON THE YEAR, MONTH, AND DAY.
;  MODIS MOD08_M3/MYD08_M3 FILE NAME:
;  MYD08_M3.A2013001.006.2014272180603.hdf
;
;  VARIABLES:
;  ============================================================================
;  (1 ) dir       (a string):DIRECTORY OF MODIS FILES                    [   ]
;  (2 ) filelist  (a string):FILE NAME CONTAINS ALL THE MODIS FILE NAMES [   ]
;  (3 ) year      (scalar)  :YEAR OF MODIS DATA                          [   ]
;  (4 ) month     (scalar)  :MONTH OF MODIS DATA                         [   ]
;  (5 ) day       (scalar)  :DAY OF MODIS DATA                           [   ]
;  (6 ) sfilename (1-D)     :SELECTED MODIS FILE NAMES                   [   ]
;  (7 ) logic_filename (a logical scalar):TURE IF IT HAS MODIS FILE NAME(S) ON 
;                                         THIS DAY, FALSE IF IT HAS NO ANY 
;                                         FILE NAME(S) ON THIS DAY       [   ]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (06/16/2015)
;******************************************************************************
undef("select_modis_mod08_filename")
procedure select_modis_mod08_filename \
          (dir       :string,    filelist       :string,   \ ;INPUT
           year      :integer,   month          :integer,  \ ;INPUT
           day       :integer,                             \ ;INPUT
           sfilename :string,    logic_filename :logical)    ;OUTPUT
begin

;  READ FILENAME LIST OF MODIS MOD08/MYD08
   filename  = asciiread(dir + filelist, -1, "string")
   nfilename = dimsizes(filename)

;  EXTRACT YEAR, MONTH, AND DAY INFO FROM MOD08/MYD08 FILE NAME
   myear   = stringtoint(str_get_cols(filename, 10, 13))
   mjulian = stringtoint(str_get_cols(filename, 14, 16))

;  CONVERT JULIAN DAY TO MONTH AND DAY
   md      = monthday(myear, mjulian)
   smd     = int2string(md)
   mmonth  = stringtoint(str_get_cols(smd, -4, -3))
   mday    = stringtoint(str_get_cols(smd, -2, -1))

;  SELECT FILE NAME BASED ON YEAR, MONTH, AND DAY INFO
   index   = ind(myear  .eq. year  .and. \
                 mmonth .eq. month .and. \
                 mday   .eq. day)
   if (.not.all(ismissing(index))) then
      sfilename = filename(index)
   else if (all(ismissing(index))) then
      logic_filename = False
   end if
   end if
return
end
