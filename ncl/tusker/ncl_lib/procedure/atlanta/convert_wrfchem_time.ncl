;  $ID: convert_wrfchem_time.ncl V01 11/07/2012 10:54 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE convert_wrfchem_time READS wrfchem FILE NAME AND CONVERTS IT TO TIME, 
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

undef("convert_wrfchem_time")
procedure convert_wrfchem_time \
          (wrfchem_filename :string,   ndim  :integer, \ ; INPUT
           year             :integer,  month :integer, \ ; OUTPUT
           day              :integer,  hour  :integer)   ; OUTPUT

begin
;  DO # OF FILE NAME LOOP TO GET DATE AND TIME
   do i = 0, ndim-1
    year(i)  = stringtoint(str_get_cols(wrfchem_filename(i), 11, 14))
    month(i) = stringtoint(str_get_cols(wrfchem_filename(i), 16, 17))
    day(i)   = stringtoint(str_get_cols(wrfchem_filename(i), 19, 20))
    hour(i)  = stringtoint(str_get_cols(wrfchem_filename(i), 22, 23))
   end do
return
end
