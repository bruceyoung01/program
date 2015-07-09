; $ID read_epa_sites.ncl V01 02/23/2013 09:50 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE read_epa_sites IS USED TO READ AERONET SITES INFO, INCLUDING 
;  SITE NAME, LONGITUDE, LATITUDE, AND ELEVATION.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) dir          (string) : AERONET SITES INFO FILE DIRECTORY  [---]
;  (2 ) filename     (string) : AERONET SITES INFO FILE NAME       [---]
;  (3 ) sitename     (string) : AERONET SITES NAME                 [---]
;  (4 ) longitude    (float)  : AERONET SITE LONGITUDE             [deg]
;  (5 ) latitude     (float)  : AERONET SITE LATITUDE              [deg]
;  (6 ) elevation    (float)  : AERONET SITE ELEVATION             [m  ]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (02/23/2013)
;******************************************************************************

undef("read_epa_sites")
procedure read_epa_sites(dir     :string, filename :string, \ ; INPUT
                         sitename:string, longitude:float,  \ ; OUTPUT
                         latitude:float,  elevation:float)    ; OUTPUT
begin
;  READ THE WHOLE FILE NAME LIST
   sdata     = asciiread(dir + filename, -1, "string")
;  FIELD DELIMITER
   delimiter = ","
;  HEADER, USE FOR VARIABLE NAMES
   header    = sdata(0)
;  READ THE REST OF THE DATA EXCLUDING HEADER
   data      = sdata(1:)
;  NUMBER OF ROWS
   nrows     = dimsizes(data)
;  NUMBER OF FIELDS
   nfields   = str_fields_count(data(0), delimiter)

;  GET DIFFERENT COLUMNS INTO DIFFERENT VARIABLES
   sitename  = str_get_field(data(0::), 1, delimiter)
   longitude = stringtofloat(str_get_field(data(0::), 2, delimiter))
   latitude  = stringtofloat(str_get_field(data(0::), 3, delimiter))
   elevation = stringtofloat(str_get_field(data(0::), 4, delimiter))
return
end
