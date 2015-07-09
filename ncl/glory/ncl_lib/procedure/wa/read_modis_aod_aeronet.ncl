; ID: read_modis_aod_aeronet.ncl V01 05/06/2012 10:47 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE read_modis_aod_aeronet READS OUT DATA AND INFO FROM MODIS MOD04 
;  MYD04 DATA DEPENDING ON AERONET SITE LATITUDE AND 
;  LONGITUDE, RESPECTIVELY. THIS SUBROUTINE JUST COLLECTS THE NOT MISSING DATA 
;  WHICH LOCATE AROUND THE AERONET SITE WITHIN 0.5 DEGREE.
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
;  (5 ) alatitude (float)   : AERONET SITE LATITUDE                       [deg]
;  (6 ) alongitude(float)   : AERONET SITE LONGITUDE                      [deg]
;  (7 ) thre_lat  (float)   : THRESHOLD LATITUDE                          [deg]
;  (8 ) thre_lon  (float)   : THRESHOLD LONGITUDE                         [deg] 
;  (9 ) year      (integer) : YEAR OF AERONET DATA                        [---]
;  (10) month     (integer) : MONTH OF AERONET DATA                       [---]
;  (11) day       (integer) : DAY OF AERONET DATA                         [---]
;  (12) hour      (integer) : HOUR OF AERONET DATA                        [---]
;  (13) lat       (float)   : MODIS LATITUDE                              [deg]
;  (14) lon       (float)   : MODIS LONGITUDE                             [deg]
;  (15) aod       (float)   : MODIS AOD DATA                              [---]
;  (16) aod_qf    (integer) : MODIS AOD DATA QUALITY FLAG                 [---]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (05/06/2012)
;  (2 ) MODIFIED FROM read_viirs_va_aeronet.ncl. (05/06/2012)
;******************************************************************************

undef("read_modis_aod_aeronet")
procedure read_modis_aod_aeronet \
                       (dir        :string,  fname       :string,  \ ; INPUT
                        nfname     :integer, bv1         :integer, \ ; INPUT
                        bv2        :float,                         \ ; INPUT
                        alatitude  :float,   alongitude  :float,   \ ; INPUT
                        thre_lat   :float,   thre_lon    :float,   \ ; INPUT
                        year       :integer, month       :integer, \ ; OUTPUT
                        day        :integer, hour        :integer, \ ; OUTPUT
                        lat        :float,   lon         :float,   \ ; OUTPUT
                        aod        :float,   aod_qf      :integer)   ; OUTPUT

begin
;  READ LATITUDE, LONGITUDE, AND AOD DATA FROM MODIS DATA
   np   = 0
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

;  CONVERT 2-D ARRAY INTO 1-D ARRAY
    oned_tem_lat    = ndtooned(tem_lat)
    oned_tem_lon    = ndtooned(tem_lon)
    if(typeof(tem_aod_qf) .eq. "character")then
     oned_tem_aod_qf = ndtooned(chartoint(tem_aod_qf(:, :, 0)))
    else if(typeof(tem_aod_qf) .eq. "byte")then
     oned_tem_aod_qf = ndtooned(floattoint(byte2flt(tem_aod_qf(:, :, 0))))
    end if
    end if
    oned_tem_aod    = ndtooned(tem_aod)
    index    = ind(oned_tem_lat .ge. alatitude -thre_lat .and. \
                   oned_tem_lat .le. alatitude +thre_lat .and. \
                   oned_tem_lon .ge. alongitude-thre_lon .and. \
                   oned_tem_lon .le. alongitude+thre_lon .and. \
                   oned_tem_aod .gt. 0                   .and. \
                   oned_tem_aod .ne. bv2)
    if(.not.all(ismissing(index)))then
     ntem_lat = dimsizes(index)
     year(np:np+ntem_lat-1)  = tem_year
     month(np:np+ntem_lat-1) = tem_month
     day(np:np+ntem_lat-1)   = tem_day
     hour(np:np+ntem_lat-1)  = tem_hour
     lat(np:np+ntem_lat-1)   = oned_tem_lat(index)
     lon(np:np+ntem_lat-1)   = oned_tem_lon(index)
     aod_qf(np:np+ntem_lat-1)= oned_tem_aod_qf(index)*doubletointeger(tem_aod_qf_scale) + \
                               doubletointeger(tem_aod_qf_offset)
     aod(np:np+ntem_lat-1)   = short2flt(oned_tem_aod(index))*doubletofloat(tem_aod_scale) + \
                               doubletofloat(tem_aod_offset)
     np = np + ntem_lat
    end if
    delete([/index, tem_lat, tem_lon, tem_aod, tem_aod_qf, \
             oned_tem_lat, oned_tem_lon, oned_tem_aod,     \
             oned_tem_aod_qf/])
   end do
return
end
