;  $ID: read_viirs_epa_read_2.ncl V01 01/30/2014 10:07 BRUEC EXP$
;
;******************************************************************************
;  PROCEDURE read_viirs_epa_read_1 READS SELECTED VIIRS INFO.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (01/30/2014)
;******************************************************************************

undef("read_viirs_epa_read_2")
procedure read_viirs_epa_read_2 \
          (dir       :string,  filename   :string,     \ ;INPUT
           data      :float)                           \ ;OUTPUT

begin
;  READ ALL THE DATA
   delimiter1  = ","
   all_data    = asciiread(dir + filename, -1, "string")
   header      = all_data(0)
   sdata       = all_data(1:)
   nrows       = dimsizes(sdata)
;  DO nrow LOOP TO READ DATA
   do i = 0, nrows-1
      data(0, i)      = stringtofloat(str_get_field(sdata(i), 1, delimiter1))
      data(1, i)      = stringtofloat(str_get_field(sdata(i), 2, delimiter1))
      data(2, i)      = stringtofloat(str_get_field(sdata(i), 3, delimiter1))
      data(3, i)      = stringtofloat(str_get_field(sdata(i), 4, delimiter1))
      data(4, i)      = stringtofloat(str_get_field(sdata(i), 5, delimiter1))
      data(5, i)      = stringtofloat(str_get_field(sdata(i), 6, delimiter1))
      data(6, i)      = stringtofloat(str_get_field(sdata(i), 7, delimiter1))
      data(7, i)      = stringtofloat(str_get_field(sdata(i), 8, delimiter1))
      data(8, i)      = stringtofloat(str_get_field(sdata(i), 9, delimiter1))
      data(9, i)      = stringtofloat(str_get_field(sdata(i), 10, delimiter1))
      data(10, i)     = stringtofloat(str_get_field(sdata(i), 11, delimiter1))
      data(11, i)     = stringtofloat(str_get_field(sdata(i), 12, delimiter1))
      data(12, i)     = stringtofloat(str_get_field(sdata(i), 13, delimiter1))
      data(13, i)     = stringtofloat(str_get_field(sdata(i), 14, delimiter1))
      data(14, i)     = stringtofloat(str_get_field(sdata(i), 15, delimiter1))
      data(15, i)     = stringtofloat(str_get_field(sdata(i), 16, delimiter1))
   end do
return
end

