;  $ID: read_visualized_cloudmask_date.ncl V01 01/24/2014 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE read_visualized_cloudmask_date.ncl READS VISUALIZED CLOUD MASK 
;  FILE, INCLUDING DATE, CLOUDMASK.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (01/24/2014)
;******************************************************************************

undef("read_visualized_cloudmask_date")
procedure read_visualized_cloudmask_date \
         (dir      :string,   filename     :string, \; INPUT
          date     :integer,  cmask        :integer) ; OUTPUT

begin

   delimiter = "	"

;  READ FILENAME
   all_data = asciiread(dir + filename, -1, "string")
   header   = all_data(0)
   data     = all_data(1:)
   nrow     = dimsizes(data)

   tmpdate      = str_get_field(data(0::), 1, delimiter)
   date(:, 0)   = stringtointeger(str_get_cols(tmpdate(0::), 0, 3))
   date(:, 1)   = stringtointeger(str_get_cols(tmpdate(0::), 4, 5))
   date(:, 2)   = stringtointeger(str_get_cols(tmpdate(0::), 6, 7))
   cmask(:)     = stringtoint(str_get_field(data(0::),   2,  delimiter))
end
