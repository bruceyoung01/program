;  $ID: select_modis_mod08_filename.ncl V01 06/16/2015 17:58 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE select_modis_mod08_filename SELECTS MOD08/MYD08 FILE NAME BASED 
;  ON THE YEAR, MONTH, AND DAY.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
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
