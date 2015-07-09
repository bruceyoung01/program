;  $ID: read_epa_pm_daily.ncl V01 02/06/2012 21:26 BRUEC EXP$
;
;******************************************************************************
;  PROCEDURE read_epa_pm_daily READS EPA OBSERVED DAILY AVERAGED PM.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (02/06/2012)
;******************************************************************************

undef("read_epa_pm_daily")
procedure read_epa_pm_daily \
          (dir       :string,  filename   :string,     \ ;INPUT
           site_name :string,  site_geo   :float,      \ ;OUTPUT
           date      :integer, pm         :float)      \ ;OUTPUT

begin
;  READ ALL THE DATA
   delimiter1  = ","
   delimiter2  = "/"
   all_data    = asciiread(dir + filename, -1, "string")
   header      = all_data(0)
   data        = all_data(1:)
   nrows       = dimsizes(data)
   nfields     = str_fields_count(header, delimiter1)

;  DO nrow LOOP TO READ DATA
   do i = 0, nrows-1
    date(i, 0)      = stringtoint(str_get_field(data(i), 3, delimiter2))
    date(i, 1)      = stringtoint(str_get_field(data(i), 1, delimiter2))
    date(i, 2)      = stringtoint(str_get_field(data(i), 2, delimiter2))
    pm(i, 0)        = stringtofloat(str_get_field(data(i), 4, delimiter1))
    site_name(i, 0) = str_get_field(data(i), 2,  delimiter1)
    site_name(i, 1) = str_get_field(data(i), 20, delimiter1)
    site_geo(i, 0)  = stringtofloat(str_get_field(data(i), 21, delimiter1))
    site_geo(i, 1)  = stringtofloat(str_get_field(data(i), 22, delimiter1))
   end do

return
end
