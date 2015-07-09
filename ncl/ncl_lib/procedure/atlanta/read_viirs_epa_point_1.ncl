;  $ID: read_viirs_epa_read_1.ncl V01 01/30/2014 10:07 BRUEC EXP$
;
;******************************************************************************
;  PROCEDURE read_viirs_epa_read_1 READS SELECTED VIIRS AND EPA DATA INFO.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (01/30/2014)
;******************************************************************************

undef("read_viirs_epa_read_1")
procedure read_viirs_epa_read_1 \
          (dir       :string,  filename   :string,     \ ;INPUT
           date      :integer, site_lat   :float,      \ ;OUTPUT
           site_lon  :float,   sza        :float,      \ ;OUTPUT
           saa       :float,   mp         :float,      \ ;OUTPUT
           lza       :float,   laa        :float,      \ ;OUTPUT
           pm        :float)                           \ ;OUTPUT

begin
;  READ ALL THE DATA
   delimiter1  = ","
   all_data    = asciiread(dir + filename, -1, "string")
   header      = all_data(0)
   data        = all_data(1:)
   nrows       = dimsizes(data)
;  DO nrow LOOP TO READ DATA
   do i = 0, nrows-1
      date(0, i)    = stringtoint(str_get_field(data(i), 1, delimiter1))
      date(1, i)    = stringtoint(str_get_field(data(i), 2, delimiter1))
      date(2, i)    = stringtoint(str_get_field(data(i), 3, delimiter1))
      date(3, i)    = stringtoint(str_get_field(data(i), 4, delimiter1))
      site_lat(i)   = stringtofloat(str_get_field(data(i), 5, delimiter1))
      site_lon(i)   = stringtofloat(str_get_field(data(i), 6, delimiter1))
      sza(i)        = stringtofloat(str_get_field(data(i), 7, delimiter1))
      saa(i)        = stringtofloat(str_get_field(data(i), 8, delimiter1))
      mp(i)         = stringtofloat(str_get_field(data(i), 9, delimiter1))
      lza(i)        = stringtofloat(str_get_field(data(i), 10, delimiter1))
      laa(i)        = stringtofloat(str_get_field(data(i), 11, delimiter1))
      pm(0, i)      = stringtofloat(str_get_field(data(i), 12, delimiter1))
      pm(1, i)      = stringtofloat(str_get_field(data(i), 13, delimiter1))
      pm(2, i)      = stringtofloat(str_get_field(data(i), 14, delimiter1))
      pm(3, i)      = stringtofloat(str_get_field(data(i), 15, delimiter1))
   end do
return
end

