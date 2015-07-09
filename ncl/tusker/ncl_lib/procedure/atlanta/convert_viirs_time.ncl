;  $ID: convert_viirs_time.ncl V01 11/07/2012 09:54 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE convert_viirs_time READS VIIRS FILE NAME AND CONVERTS IT TO TIME, 
;  INCLUDING YEAR, MONTH, DAY, HOUR
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORGINALLY WRITTEN BY BRUCE. (11/07/2012)
;******************************************************************************

undef("convert_viirs_time")
procedure convert_viirs_time \
          (viirs_filename :string,   ndim  :integer, \ ; INPUT
           year           :integer,  month :integer, \ ; OUTPUT
           day            :integer,  hour  :integer)   ; OUTPUT

begin
;  DO # OF FILE NAME LOOP TO GET DATE AND TIME
   do i = 0, ndim-1
    year(i)  = stringtoint(str_get_cols(viirs_filename(i), 11, 14))
    month(i) = stringtoint(str_get_cols(viirs_filename(i), 15, 16))
    day(i)   = stringtoint(str_get_cols(viirs_filename(i), 17, 18))
    hour(i)  = stringtoint(str_get_cols(viirs_filename(i), 21, 22))
   end do
return
end
