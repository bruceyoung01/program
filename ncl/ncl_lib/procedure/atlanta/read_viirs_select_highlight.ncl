; $ID read_viirs_select_highlight.ncl V01 01/23/2014 19:50 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE read_viirs_select_highlight.ncl READS SELECTED VIIRS HIGHLIGHT 
;  PIXEL RADIANCES, INCLUDING DATE, PIXEL INDICES, AND RADIANCE.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) dir          (string) : FILE DIRECTORY                     [---]
;  (2 ) filename     (string) : NAME                               [---]
;  (3 ) sitename     (string) : SITES NAME                         [---]
;  (4 ) date         (integer): DATE OF SELECTED DATA              [---]
;  (5 ) pindex       (integer): INDEX OF SELECTED DATA             [---]
;  (6 ) prad         (float)  : RADIANCE OF SELECTED PIXELS        [---]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (01/23/2014)
;******************************************************************************

undef("read_viirs_select_highlight")
procedure read_viirs_select_highlight \
         (dir     :string, filename :string, \ ; INPUT
          sitename:string,                   \ ; INPUT
          date    :integer,                  \ ; OUTPUT
          pindex  :integer, prad    :float)    ; OUTPUT
begin
;  READ THE WHOLE FILE NAME LIST
   sdata     = asciiread(dir + filename, -1, "string")
;  FIELD DELIMITER
   delimiter = "	"
;  READ THE DATA
   data      = sdata(:)
;  NUMBER OF ROWS
   nrows     = dimsizes(data)

;  GET DIFFERENT COLUMNS INTO DIFFERENT VARIABLES
   tmpdate      = str_get_field(data(0::), 1, delimiter)
   date(:, 0)   = stringtointeger(str_get_cols(tmpdate(0::), 0, 3))
   date(:, 1)   = stringtointeger(str_get_cols(tmpdate(0::), 4, 5))
   date(:, 2)   = stringtointeger(str_get_cols(tmpdate(0::), 6, 7))
   date(:, 3)   = stringtointeger(str_get_cols(tmpdate(0::), 8, 9))
   pindex(:, 0) = stringtointeger(str_get_field(data(0::), 2, delimiter))
   pindex(:, 1) = stringtointeger(str_get_field(data(0::), 3, delimiter))
   prad(:, 0)   = stringtofloat(str_get_field(data(0::),   4, delimiter))
   prad(:, 1)   = stringtofloat(str_get_field(data(0::),   5, delimiter))
   prad(:, 2)   = stringtofloat(str_get_field(data(0::),   6, delimiter))
   prad(:, 3)   = stringtofloat(str_get_field(data(0::),   7, delimiter))
   prad(:, 4)   = stringtofloat(str_get_field(data(0::),   8, delimiter))
return
end
