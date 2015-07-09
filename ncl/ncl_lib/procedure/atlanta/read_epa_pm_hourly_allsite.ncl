;  $ID: read_epa_pm_hourly_allsite.ncl V01 02/06/2012 21:26 BRUEC EXP$
;
;******************************************************************************
;  PROCEDURE read_epa_pm_hourly_allsite READS EPA OBSERVED HOURLY AVERAGED PM.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (02/06/2012)
;******************************************************************************

undef("read_epa_pm_hourly_allsite")
procedure read_epa_pm_hourly_allsite \
          (dir       :string,  filename   :string,     \ ;INPUT
           site_name :string,  site_geo   :float,      \ ;OUTPUT
           date      :integer, pm         :float)      \ ;OUTPUT

begin
;  READ ALL THE DATA
   delimiter1  = "	 "
   all_data    = asciiread(dir + filename, -1, "string")
   all_data    = str_sub_str(all_data, ",,", ",data@_FillValue,")
   header      = all_data(0)
   data        = all_data(1:)
   nrows       = dimsizes(data)
   nfields     = str_fields_count(header, delimiter1)

;  DO nrow LOOP TO READ DATA
   do i = 0, nrows-1
    tmp_date        = str_get_field(data(i), 1, delimiter1)
    date(i, 0)      = stringtoint(str_get_cols(tmp_date, 0, 3))
    date(i, 1)      = stringtoint(str_get_cols(tmp_date, 5, 6))
    date(i, 2)      = stringtoint(str_get_cols(tmp_date, 8, 9))
    date(i, 3)      = stringtoint(str_get_cols(tmp_date, 11, 12))
    pm(i, 0)        = stringtofloat(str_get_field(data(i), 5, delimiter1))
    site_name(i, 0) = str_get_field(data(i), 4, delimiter1)
    site_geo(i, 0)  = stringtofloat(str_get_field(data(i), 3, delimiter1))
    site_geo(i, 1)  = stringtofloat(str_get_field(data(i), 2, delimiter1))
   end do
return
end
