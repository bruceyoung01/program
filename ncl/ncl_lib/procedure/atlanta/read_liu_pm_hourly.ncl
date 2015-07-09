;  $ID: read_liu_pm_hourly.ncl V01 11/08/2012 08:32 BRUEC EXP$
;
;******************************************************************************
;  PROCEDURE read_liu_pm_hourly READS SITES OBSERVED HOURLY AVERAGED PM 
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

undef("read_liu_pm_hourly")
procedure read_liu_pm_hourly \
          (dir       :string,  filename   :string,     \ ;INPUT
           date      :integer, pm         :float)      \ ;OUTPUT

begin
;  READ ALL THE DATA
   delimiter1  = "	"
   delimiter2  = ","
   all_data    = asciiread(dir + filename, -1, "string")
   header      = all_data(0)
   data        = all_data(1:)
   nfields1    = str_fields_count(header, delimiter1)
   nfields2    = str_fields_count(header, delimiter2)
   if (nfields1 .eq. 9) then
    nrows      = dimsizes(data)
;  DO nrow LOOP TO READ DATA
    do i = 0, nrows-1
     date(i, 0)    = stringtoint(str_get_field(data(i), 3, delimiter1))
     date(i, 1)    = stringtoint(str_get_field(data(i), 1, delimiter1))
     date(i, 2)    = stringtoint(str_get_field(data(i), 2, delimiter1))
     date(i, 3)    = stringtoint(str_get_field(data(i), 4, delimiter1))
     pm(i, 0)      = stringtofloat(str_get_field(data(i), 6, delimiter1))
     pm(i, 1)      = stringtofloat(str_get_field(data(i), 7, delimiter1))
     pm(i, 2)      = stringtofloat(str_get_field(data(i), 8, delimiter1))
     pm(i, 3)      = stringtofloat(str_get_field(data(i), 9, delimiter1))
    end do
   else if (nfields2 .eq. 5) then
    nrows      = dimsizes(data)
    do i = 0, nrows-1
     date(i, 0)    = stringtoint(str_get_field(data(i), 1, delimiter2))
     date(i, 1)    = stringtoint(str_get_field(data(i), 2, delimiter2))
     date(i, 2)    = stringtoint(str_get_field(data(i), 3, delimiter2))
     date(i, 3)    = stringtoint(str_get_field(data(i), 4, delimiter2))
     pm(i, 0)      = stringtofloat(str_get_field(data(i), 5, delimiter2))
    end do
   end if
   end if
return
end
