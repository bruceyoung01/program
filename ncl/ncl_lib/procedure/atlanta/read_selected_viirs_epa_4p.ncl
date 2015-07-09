;  $ID: read_selected_viirs_epa_4p.ncl V01 02/27/2013 09:37 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE read_selected_viirs_epa_4p READS OUTPUT OF SELECTED VIIRS AND EPA 
;  DATABASE (TXT FILE).
;
;  VARIABLES:
;  ============================================================================
;  (1 ) dir       (string, 1-D):                                         [---] 
;       DATABASE DIRECTORY.
;  (2 ) filename1 (string, 1-D):                                         [---]
;       FIRST PART OF DATABASE, INCLUDING YEAR, MONTH, DAY, HOUR, LATITUDE, 
;       LONGITUDE, SATELLITE ZENITH ANGLE, SATELLITE AZIMUTH ANGLE, MOON PHASE,
;       LUNAR ZENITH ANGLE, LUNAR AZIMUTH ANGLE, PM2.5A, PM2.5B. PM2.5A AND 
;       PM2.5B ARE PM2.5 MASS CONCENTRATIONS FOR SATELLITE PASSING HOUR AND 
;       THE HOUR AFTER SATELLITE PASSING.
;  (3 ) filename2 (string, 1-D):                                         [---]
;       SECOND PART OF DATABASE, INCLUDING VIIRS 16 PIXELS RADIANCE DATA.
;  (4 ) filename3 (string, 1-D):                                         [---]
;       THIRD PART OF DATABASE, INCLUDING VIIRS 9 PIXELS RADIANCE DATA. 
;       (SEE THE NOTES2 (BELOW) WHY DATEBASE IS SEPERATED).
;  (5 ) date      (integer, 2-D, (:, 4)):                                [---]
;       DATE FROM AUG/2012 TO JAN/2013, INCLUDING YEAR, MONTH, DAY, HOUR.
;  (6 ) info_data (float, 2-D, (:, 7)):                                  [---]
;       GEOLOCATION AND SATELLITE INFO, INCLUDING EPA SITE LATITUDE, LONGITUDE, 
;       SATELLITE ZENITH ANGLE, SATELLITE AZIMUTH ANGLE, MOON PHASE, LUNAR 
;       ZENITH ANGLE, LUNAR AZIMUTH ANGLE, PM2.5A, AND PM2.5B.
;  (7 ) pm_data   (float, 2-D, (:, 4)):                                [ug/m3]
;       EPA PM2.5 MASS CONCENTRATION.
;  (8 ) rad_data  (float, 2-D, (:, 25)):                       [Wm-2str-1um-1]  
;       SELECTED 5*5 PIXELS VIIRS RADIANCE DATA FOR EACH EPA SITE.
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (02/27/2013)
;  (2 ) DUE TO THE LIMITATION OF NCL ACSII OUTPUT FUNCTION (write_matrix) CAN 
;       ONLY WRITE DATA WITH MAXIMUM COLUMNS OF 16 AT ONE TIME. THE TOTAL 
;       COLUMNS FOR THIS DATABASE IS 38. SO IT IS SEPERATED INTO THREE FILES.
;  (3 ) ADD COMMENTS TO READ IT EASIER BY BRUCE. (04/05/2013)
;  (4 ) MODIFIED FROM read_selected_viirs_epa.ncl BY ADDING 2 MORE PM DATA.
;       pm_data(:, 2)->pm_data(:, 4). (01/24/2014)
;******************************************************************************
undef("read_selected_viirs_epa_4p")
procedure read_selected_viirs_epa_4p \
         (dir       :string,       filename1     :string,  \; INPUT
          filename2 :string,       filename3     :string,  \; INPUT
          date      :integer,      info_data     :float,   \; OUTPUT
          pm_data   :float,        rad_data      :float)    ; OUTPUT

begin
   delimiter   = ","
;  READ FILENAME1
   all_data1   = asciiread(dir + filename1, -1, "string")
   all_data1   = str_sub_str(all_data1, ",,", ",data@_FillValue,")
   header1     = all_data1(0)
   data1       = all_data1(1:)
   nrow        = dimsizes(data1)

;  READ FILENAME2
   all_data2   = asciiread(dir + filename2, -1, "string")
   all_data2   = str_sub_str(all_data2, ",,", ",data@_FillValue,")
   header2     = all_data2(0)
   data2       = all_data2(1:)

;  READ FILENAME3
   all_data3   = asciiread(dir + filename3, -1, "string")
   all_data3   = str_sub_str(all_data3, ",,", ",data@_FillValue,")
   header3     = all_data3(0)
   data3       = all_data3(1:)

;  DO nrow LOOP TO READ DATA
   do i = 0, nrow-1
    date(i, 0)      = stringtoint(str_get_field(data1(i),   1,  delimiter))
    date(i, 1)      = stringtoint(str_get_field(data1(i),   2,  delimiter))
    date(i, 2)      = stringtoint(str_get_field(data1(i),   3,  delimiter))
    date(i, 3)      = stringtoint(str_get_field(data1(i),   4,  delimiter))
    info_data(i, 0) = stringtofloat(str_get_field(data1(i), 5,  delimiter))
    info_data(i, 1) = stringtofloat(str_get_field(data1(i), 6,  delimiter))
    info_data(i, 2) = stringtofloat(str_get_field(data1(i), 7,  delimiter))
    info_data(i, 3) = stringtofloat(str_get_field(data1(i), 8,  delimiter))
    info_data(i, 4) = stringtofloat(str_get_field(data1(i), 9,  delimiter))
    info_data(i, 5) = stringtofloat(str_get_field(data1(i), 10, delimiter))
    info_data(i, 6) = stringtofloat(str_get_field(data1(i), 11, delimiter))
    pm_data(i, 0)   = stringtofloat(str_get_field(data1(i), 12, delimiter))
    pm_data(i, 1)   = stringtofloat(str_get_field(data1(i), 13, delimiter))
    pm_data(i, 2)   = stringtofloat(str_get_field(data1(i), 14, delimiter))
    pm_data(i, 3)   = stringtofloat(str_get_field(data1(i), 15, delimiter))
    rad_data(i, 0)  = stringtofloat(str_get_field(data2(i), 1,  delimiter))
    rad_data(i, 1)  = stringtofloat(str_get_field(data2(i), 2,  delimiter))
    rad_data(i, 2)  = stringtofloat(str_get_field(data2(i), 3,  delimiter))
    rad_data(i, 3)  = stringtofloat(str_get_field(data2(i), 4,  delimiter))
    rad_data(i, 4)  = stringtofloat(str_get_field(data2(i), 5,  delimiter))
    rad_data(i, 5)  = stringtofloat(str_get_field(data2(i), 6,  delimiter))
    rad_data(i, 6)  = stringtofloat(str_get_field(data2(i), 7,  delimiter))
    rad_data(i, 7)  = stringtofloat(str_get_field(data2(i), 8,  delimiter))
    rad_data(i, 8)  = stringtofloat(str_get_field(data2(i), 9,  delimiter))
    rad_data(i, 9)  = stringtofloat(str_get_field(data2(i), 10, delimiter))
    rad_data(i, 10) = stringtofloat(str_get_field(data2(i), 11, delimiter))
    rad_data(i, 11) = stringtofloat(str_get_field(data2(i), 12, delimiter))
    rad_data(i, 12) = stringtofloat(str_get_field(data2(i), 13, delimiter))
    rad_data(i, 13) = stringtofloat(str_get_field(data2(i), 14, delimiter))
    rad_data(i, 14) = stringtofloat(str_get_field(data2(i), 15, delimiter))
    rad_data(i, 15) = stringtofloat(str_get_field(data2(i), 16, delimiter))
    rad_data(i, 16) = stringtofloat(str_get_field(data3(i), 1,  delimiter))
    rad_data(i, 17) = stringtofloat(str_get_field(data3(i), 2,  delimiter))
    rad_data(i, 18) = stringtofloat(str_get_field(data3(i), 3,  delimiter))
    rad_data(i, 19) = stringtofloat(str_get_field(data3(i), 4,  delimiter))
    rad_data(i, 20) = stringtofloat(str_get_field(data3(i), 5,  delimiter))
    rad_data(i, 21) = stringtofloat(str_get_field(data3(i), 6,  delimiter))
    rad_data(i, 22) = stringtofloat(str_get_field(data3(i), 7,  delimiter))
    rad_data(i, 23) = stringtofloat(str_get_field(data3(i), 8,  delimiter))
    rad_data(i, 24) = stringtofloat(str_get_field(data3(i), 9,  delimiter))
   end do
return
end
