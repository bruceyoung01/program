;  $ID: read_asc4_bruce.ncl V01 05/11/2012 11:49 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE read_asc4_bruce READ ASCII FILE WITH THE FOLLOWING FEATURES:
;  (1 ) THE FIRST FEW LINES ARE CHARACTER, WHICH ARE NOT TO BE READ. (HEADER)
;  (2 ) THE DATA ARE A MIX OF NUMERIC DATA, WITH DIFFERENT DATA TYPES.
;  (3 ) THE LAST FEW LINES ARE ALSO CHARACTER, WHICH ARE NOT TO BE READ. (FOOTER)
;
;  VARIABLES:
;  ============================================================================
;  (1 ) dir       (string) : DIRECTORY OF READING DATA                   [---]
;  (2 ) filename  (string) : FILE NAME OF READING DATA                   [---]
;  (3 ) nheader   (integer): # OF HEADER LINES                           [---]
;  (4 ) nfooter   (integer): # OF FOOTER LINES                           [---]
;  (5 ) sitename  (string) : AERONET SITE NAME                           [---]
;  (6 ) cdata1    (numeric): THE FIRST COLUMN DATA                       [---]
;  (7 ) cdata2    (numeric): THE SECOND COLUMN DATA                      [---]
;  (8 ) cdata3    (numeric): THE THIRD COLUMN DATA                       [---]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (05/11/2012)
;******************************************************************************

undef("read_asc4_bruce")
procedure read_asc4_bruce \
           (dir      :string,   filename      :string,  \ ; INPUT
            nheader  :integer,  nfooter       :integer, \ ; INPUT
            sitename :string,                           \ ; OUTPUT
            cdata1   :numeric,  cdata2        :numeric, \ ; OUTPUT
            cdata3   :numeric)                            ; OUTPUT

begin

;  GET SITE NAME
   sitename= str_get_cols(filename, 8, 50)
;  READ THE DATA INTO AN ARRAY OF STRINGS, AND REMOVING THE FIRST FEW LINES AND 
;  THE LAST FEW LINES (HEADER AND FOOTER)
   data    = readAsciiTable(dir + filename, 1, "string", (/nheader, nfooter/))

;  CONVERT THE DIFFERENT COLUMN DATA INTO SPECIFIED DATA TYPE
   cdata1  = stringtointeger(str_get_field(data, 1, " "))
   cdata2  = stringtofloat(str_get_field(data, 2, " "))
   cdata3  = stringtofloat(str_get_field(data, 3, " "))

return
end
