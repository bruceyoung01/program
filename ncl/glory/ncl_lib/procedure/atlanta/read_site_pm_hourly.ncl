;  $ID: read_site_pm_hourly.ncl V01 11/08/2012 08:32 BRUEC EXP$
;
;******************************************************************************
;  PROCEDURE read_site_pm_hourly READS SITES OBSERVED HOURLY AVERAGED PM 
;  FROM LIU.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (11/08/2012)
;******************************************************************************

undef("read_site_pm_hourly")
procedure read_site_pm_hourly \
          (dir       :string,  filename   :string,     \ ;INPUT
           date      :integer, aod_ang    :float)      \ ;OUTPUT

begin
;  READ ALL THE DATA
   delimiter1  = "	"
   all_data    = asciiread(dir + filename, -1, "string")
   header      = all_data(0)
   data        = all_data(1:)
   nrows       = dimsizes(data)
   nfields     = str_fields_count(header, delimiter1)

;  DO nrow LOOP TO READ DATA
   do i = 0, nrows-1
    date(i, 0)    = stringtoint(str_get_field(data(i), 3, delimiter1))
    date(i, 1)    = stringtoint(str_get_field(data(i), 1, delimiter1))
    date(i, 2)    = stringtoint(str_get_field(data(i), 2, delimiter1))
    date(i, 3)    = stringtoint(str_get_field(data(i), 4, delimiter1))
    aod_ang(i, 0) = stringtofloat(str_get_field(data(i), 6, delimiter1))
    aod_ang(i, 1) = stringtofloat(str_get_field(data(i), 7, delimiter1))
    aod_ang(i, 2) = stringtofloat(str_get_field(data(i), 8, delimiter1))
    aod_ang(i, 3) = stringtofloat(str_get_field(data(i), 9, delimiter1))
   end do

return
end
