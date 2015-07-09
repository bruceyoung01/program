; ID: read_modis_aod.ncl V01 05/06/2012 23:06 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE read_modis_aod READS OUT DATA AND INFO FROM MODIS MOD04 AND
;  MYD04 DATA.
;  MODIS MOD04/MYD04 FILENAME SAMPLE:
;  MOD04_L2.A2012071.1720.051.2012072013351.hdf
;  MYD04_L2.A2012091.2155.051.2012092164526.hdf
;
;  VARIABLES:
;  ============================================================================
;  (1 ) dir       (string)  : MODIS DATA DIRECTORY                        [---]
;  (2 ) fname     (string)  : MODIS MOD04/MYD04 FILE NAMES                [---]
;  (3 ) nfname    (integer) : # OF MODIS MOD04/MYD04 FILE NAMES           [---]
;  (4 ) bv1       (integer) : MISSING VALUE OF INTEGER                    [---]
;  (5 ) year      (integer) : YEAR OF AERONET DATA                        [---]
;  (6 ) month     (integer) : MONTH OF AERONET DATA                       [---]
;  (7 ) day       (integer) : DAY OF AERONET DATA                         [---]
;  (8 ) hour      (integer) : HOUR OF AERONET DATA                        [---]
;  (9 ) lat       (float)   : MODIS LATITUDE                              [deg]
;  (10) lon       (float)   : MODIS LONGITUDE                             [deg]
;  (11) aod       (float)   : MODIS AOD DATA                              [---]
;  (12) aod_qf    (integer) : MODIS AOD DATA QUALITY FLAG                 [---]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (05/06/2012)
;  (2 ) MODIFIED FROM read_viirs_va_aeronet.ncl. (05/06/2012)
;******************************************************************************

undef("read_modis_aod")
procedure read_modis_aod \
                       (dir        :string,  fname       :string,  \ ; INPUT
                        nfname     :integer, bv1         :integer, \ ; INPUT
                        bv2        :float,                         \ ; INPUT
                        year       :integer, month       :integer, \ ; OUTPUT
                        day        :integer, hour        :integer, \ ; OUTPUT
                        lat        :float,   lon         :float,   \ ; OUTPUT
                        aod        :float,   aod_qf      :integer)   ; OUTPUT

begin
;  READ LATITUDE, LONGITUDE, AND AOD DATA FROM MODIS DATA
   tem_month = new(1, integer, bv1)
   tem_day   = new(1, integer, bv1)
   do i = 0, nfname-1
;  GET YEAR, MONTH, DAY, AND HOUR FROM FILE NAME
    tem_year = stringtoint(str_get_cols(fname(i), 10, 13))
    tem_dn   = stringtoint(str_get_cols(fname(i), 14, 16))
;  CONVERT THE DAY NUMBER TO GREGORIAN DATE
    ydn2md(tem_year, tem_dn, tem_month, tem_day)
    tem_hour = stringtoint(str_get_cols(fname(i), 18, 19))
;  READ LATITUDE, LONGITUDE, AND AOD
    a        = addfile(dir + fname(i), "r")
    tem_lat  = a->Latitude
    tem_lon  = a->Longitude
    tem_aod  = a->Optical_Depth_Land_And_Ocean
    tem_aod_qf = a->Quality_Assurance_Land
    tem_aod_scale  = tem_aod@scale_factor
    tem_aod_offset = tem_aod@add_offset
    tem_aod_qf_scale  = tem_aod_qf@scale_factor
    tem_aod_qf_offset = tem_aod_qf@add_offset

;  COLLECT ALL THE DATA INTO ONE 2-D ARRAY
     ntem_lat = dimsizes(tem_lat)
     nl       = ntem_lat(0)
     np       = ntem_lat(1)
     year(0:nl-1, (nl*i):(nl*(i+1)-1))  = tem_year
     month(0:nl-1, (nl*i):(nl*(i+1)-1)) = tem_month
     day(0:nl-1, (nl*i):(nl*(i+1)-1))   = tem_day
     hour(0:nl-1, (nl*i):(nl*(i+1)-1))  = tem_hour
     lat(0:nl-1, (nl*i):(nl*(i+1)-1))   = tem_lat
     lon(0:nl-1, (nl*i):(nl*(i+1)-1))   = tem_lon
     aod_qf(0:nl-1, (nl*i):(nl*(i+1)-1))= tem_aod_qf(:, :, 0)*doubletointeger(tem_aod_qf_scale) + \
                                          doubletointeger(tem_aod_qf_offset)
     aod(0:nl-1, (nl*i):(nl*(i+1)-1))   = short2flt(tem_aod)
    end if
    delete([/tem_lat, tem_lon, tem_aod, tem_aod_qf/])
   end do
return
end
