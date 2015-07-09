; $ID: read_aeronet_data_monthly.ncl V01 04/03/2013 10:12 BRUCE EXP$
;
;******************************************************************************
;  SUBROUTINE read_aeronet_data_monthly READS AERONET MONTHLY DATASETS 
;  DOWNLOADED FROM AERONET WEBSITE : http://aeronet.gsfc.nasa.gov/.
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
;  (2 ) PREVIOUSLY IT'S CALLED read_aeronet_data.ncl. MODIFIED ITS NAME 
;       BASED ON THE SPECIFIC DATA, WHICH IS AERONET ALL POINTS DATA.
;       (04/03/2013)
;  (3 ) MODIFIED FROM read_aeronet_data_allpoints.ncl. (04/03/2013)
;******************************************************************************
;
undef("read_aeronet_data_monthly")
procedure read_aeronet_data_monthly \
         (dir      :string,  filename  :string, \ ; INPUT
          year     :integer, month     :integer,\ ; OUTPUT
          sitename :string,  longitude :float,  \ ; OUTPUT
          latitude :float,   elevation :float,  \ ; OUTPUT
          header   :string,  aod_raw   :float)    ; OUTPUT

begin

;  READ THE WHOLE FILE NAME LIST
   sdata      = asciiread(dir + filename, -1, "string")
   nline      = dimsizes(sdata)-5
   nitem      = dimsizes(header)
;  DEFINE MISSING VALUE
   bv         = aod_raw@_FillValue
;  FIELD DELIMITER
   delimiter1 = ","
   delimiter2 = "="
   delimiter3 = "-"
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
   year       = stringtoint(str_get_field(date(0::), 1, delimiter3))
   smonth     = str_get_field(date(0::), 2, delimiter3)
   nmonth     = (/ 1,  2,  3,  4,  5,  6, \
                   7,  8,  9, 10, 11, 12/)
   lmonth     = (/"JAN", "FEB", "MAR", "APR", "MAY", "JUN", \
                  "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"/)
   index1     = ind(lmonth .eq. smonth)
   if (.not.all(ismissing(index1)))
    month      = nmonth(index1)
   else
    print("smonth = " + smonth)
    print("AN ERROR WHILE READING MONTH(smonth) FROM AERONET MONTHLY DATA")
   end if
   do i = 0, nitem-1
    do j = 0, nline-1
     sstring = str_get_field(data(j), i+2, delimiter1)
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
