; $ID: read_aeronet_data.ncl V01 01/06/2011 16:28 BRUCE EXP$
;
;******************************************************************************
;  SUBROUTINE read_aeronet_data IS USED TO READ AERONET DATASETS DOWNLOADED 
;  FROM AERONET WEBSITE : http://aeronet.gsfc.nasa.gov/.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) dir        (string) : AERONET SITE DATA DIRECTORY             [---]
;  (2 ) filename   (string) : AEROENT SITE FILE NAME                  [---]
;  (3 ) year       (integer): AERONET OBSERVATION YEAR                [---]
;  (4 ) month      (integer): AERONET OBSERVATION MONTH               [---]
;  (5 ) day        (integer): AEROENT OBSERVATION DAY                 [---]
;  (6 ) hour       (integer): AERONET OBSERVATION HOUR                [---]
;  (7 ) sitename   (string) : AEROENT SITE NAME                       [---]
;  (8 ) longitude  (float)  : AERONET SITE LONGITUDE                  [deg]
;  (9 ) latitude   (float)  : AEROENT SITE LATITUDE                   [deg]
;  (10) elevation  (float)  : AEROENT SITE ELEVATION                  [m  ]
;  (11) header     (string) : VARIABLE NAMES ARRAY                    [---]
;  (12) aod_raw    (float)  : VARIABLE DATA ARRAY                     [---]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (12/28/2011)
;******************************************************************************
;
undef("read_aeronet_data")
procedure read_aeronet_data(dir      :string, filename  :string, \ ; INPUT
                            year     :integer,month     :integer,\ ; OUTPUT
                            day      :integer,hour      :integer,\ ; OUTPUT
                            sitename :string, longitude :float,  \ ; OUTPUT
                            latitude :float,  elevation :float,  \ ; OUTPUT
                            header   :string, aod_raw   :float)    ; OUTPUT

begin

;  READ THE WHOLE FILE NAME LIST
   sdata      = asciiread(dir + filename, -1, "string")
   nline      = dimsizes(sdata)-5
   nitem      = dimsizes(header)
;  DEFINE MISSING VALUE
   bv         = -999.
;  FIELD DELIMITER
   delimiter1 = ","
   delimiter2 = "="
   delimiter3 = ":"
;  HEADER, USE FOR VARIABLE NAMES
   info       = sdata(2)
;  READ OUT THE KIND OF DATA FROM AERONET FILE NAME
   kdata      = str_get_cols(filename, -5, -1)
;  READ OUT LOCATION NAME, LONGTITUDE, LATITUDE
   ssitename  = str_get_field(info(0::), 1, delimiter1)
   sitename   = str_get_field(ssitename(0), 2, delimiter2)
   if (kdata .eq. "lev10" .or. \
       kdata .eq. "lev15" .or. \
       kdata .eq. "lev20") then
    slongitude = str_get_field(info(0), 2, delimiter1)
    longitude  = stringtofloat(str_get_field(slongitude, 2, delimiter2))
    slatitude  = str_get_field(info(0), 3, delimiter1)
    latitude   = stringtofloat(str_get_field(slatitude, 2, delimiter2))
   end if
   if (kdata .eq. "LL_10" .or. \
       kdata .eq. "LL_15" .or. \
       kdata .eq. "LL_20") then
    slatitude  = str_get_field(info(0), 2, delimiter1)
    latitude   = stringtofloat(str_get_field(slatitude, 2, delimiter2))
    slongitude = str_get_field(info(0), 3, delimiter1)
    longitude  = stringtofloat(str_get_field(slongitude, 2, delimiter2))
   end if
   selevation = str_get_field(info(0), 4, delimiter1)
   elevation  = stringtofloat(str_get_field(selevation, 2, delimiter2))
;  READ HEADER
   sheader    = sdata(4)
   do i = 3, nitem-1
    header(i) = str_get_field(sheader(0::), i+1, delimiter1)
   end do
;  READ THE REST OF THE DATA
   data       = sdata(5::)
   date       = str_get_field(data(0::), 1, delimiter1)
   year       = stringtoint(str_get_field(date(0::), 3, delimiter3))
   month      = stringtoint(str_get_field(date(0::), 2, delimiter3))
   day        = stringtoint(str_get_field(date(0::), 1, delimiter3))
   ahour      = str_get_field(data(0::), 2, delimiter1)
   hour       = stringtoint(str_get_field(ahour(0::), 1, delimiter3))
   julian     = stringtofloat(str_get_field(data(0::), 3, delimiter1))
   do i = 3, nitem-1
    do j = 0, nline-1
     sstring = str_get_field(data(j), i+1, delimiter1)
     if (sstring .eq. "N/A" .or. \
         sstring .eq. "") then
      aod_raw(j, i) = bv
     else
      aod_raw(j, i) = stringtofloat(sstring)
     end if
    end do
   end do
return
end
