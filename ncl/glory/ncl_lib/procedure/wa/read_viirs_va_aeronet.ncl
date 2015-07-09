; ID: read_viirs_va_aeronet.ncl V01 04/23/2012 09:57 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE read_viirs_va_aeronet READS OUT DATA AND INFO FROM NPP VIIRS EDR 
;  VAOOO DATA AND EDR GEOLOCATION DATA DEPENDING ON AERONET SITE LATITUDE AND 
;  LONGITUDE, RESPECTIVELY. THIS SUBROUTINE JUST COLLECTS THE NOT MISSING DATA 
;  WHICH LOCATE AROUND THE AERONET SITE WITHIN 0.5 DEGREE.
;  EDR AEROSOL VAOOO FILENAME SAMPLE:
;  VAOOO_npp_d20120331_t2032472_e2034114_b02206_c20120401030451240471_noaa_ops.h5
;  EDR GEOLOCATION FILENAME SAMPLE:
;  GAERO_npp_d20120201_t0909467_e0911109_b01362_c20120202145305252816_noaa_ops.h5
;
;  VARIABLES:
;  ============================================================================
;  (1 ) dir       (string)  : VIIRS DATA DIRECTORY                        [---]
;  (2 ) new_vfname(string)  : SELECTED VAOOO FILE NAME BASED ON GAERO 
;                             FILE NAME                                   [---]
;  (3 ) new_gfname(string)  : SELECTED GAERO FILE NAME BASED ON VAOOO 
;                             FILE NAME                                   [---]
;  (4 ) nvgfname  (integer) : # OF SELETED FILE NAME(VAOOO OR GAERO)      [---]
;  (5 ) bv3       (float)   : MISSING VALUE OF FLOAT                      [---]
;  (6 ) bv4       (float)   : MISSING VALUE OF FLOAT                      [---]
;  (7 ) alatitude (float)   : AERONET SITE LATITUDE                       [deg]
;  (8 ) alongitude(float)   : AERONET SITE LONGITUDE                      [deg]
;  (0 ) thre_lat  (float)   : THRESHOLD LATITUDE                          [deg]
;  (10) thre_lon  (float)   : THRESHOLD LONGITUDE                         [deg] 
;  (11) year      (integer) : YEAR OF VIIRS DATA                          [---]
;  (12) month     (integer) : MONTH OF VIIRS DATA                         [---]
;  (13) day       (integer) : DAY OF VIIRS DATA                           [---]
;  (14) hour      (integer) : HOUR OF VIIRS DATA                          [---]
;  (15) lat       (float)   : VIIRS LATITUDE                              [deg]
;  (16) lon       (float)   : VIIRS LONGITUDE                             [deg]
;  (17) aod       (float)   : VIIRS AOD DATA                              [---]
;  (18) aod_qf    (integer) : VIIRS AOD DATA QUALITY FLAG                 [---]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (04/23/2012)
;  (2 ) MODIFIED FROM read_viirs_va.ncl. (05/02/2012)
;******************************************************************************

undef("read_viirs_va_aeronet")
procedure read_viirs_va_aeronet \
                       (dir        :string,  new_vfname  :string,  \ ; INPUT
                        new_gfname :string,  nvgfname    :integer, \ ; INPUT
                        bv3        :float,   bv4         :float,   \ ; INPUT
                        alatitude  :float,   alongitude  :float,   \ ; INPUT
                        thre_lat   :float,   thre_lon    :float,   \ ; INPUT
                        year       :integer, month       :integer, \ ; OUTPUT
                        day        :integer, hour        :integer, \ ; OUTPUT
                        lat        :float,   lon         :float,   \ ; OUTPUT
                        aod        :float,   aod_qf      :integer)   ; OUTPUT

begin
;  READ LATITUDE, LONGITUDE, AND AOD DATA FROM EDR AEROSOL DATA AND 
;  GEOLOCATION DATA, RESPECTIVELY
   np   = 0
   do i = 0, nvgfname-1
;  GET YEAR, MONTH, DAY, AND HOUR FROM FILE NAME
    tem_year = stringtoint(str_get_cols(new_gfname(i), 11, 14))
    tem_month= stringtoint(str_get_cols(new_gfname(i), 15, 16))
    tem_day  = stringtoint(str_get_cols(new_gfname(i), 17, 18))
    tem_hour = stringtoint(str_get_cols(new_gfname(i), 21, 22))
;  READ LATITUDE, LONGITUDE, AND AOD
    a        = addfile(dir + new_gfname(i), "r")
    b        = addfile(dir + new_vfname(i), "r")
    tem_lat  = a->Latitude
    tem_lon  = a->Longitude
    tem_factor = b->AerosolOpticalDepthFactors
    tem_aod_qf = b->QF1_VIIRSAEROEDR
    tem_aod  = b->AerosolOpticalDepth_at_550nm
;  CONVERT 2-D ARRAY INTO 1-D ARRAY
    oned_tem_lat    = ndtooned(tem_lat)
    oned_tem_lon    = ndtooned(tem_lon)
    if(typeof(tem_aod_qf) .eq. "character")then
     oned_tem_aod_qf = ndtooned(chartoint(tem_aod_qf))
    else if(typeof(tem_aod_qf) .eq. "byte" .or. \
            typeof(tem_aod_qf) .eq. "ubyte")then
     oned_tem_aod_qf = ndtooned(floattoint(byte2flt(tem_aod_qf)))
    end if
    end if
    oned_tem_aod    = ndtooned(tem_aod)
    index    = ind(oned_tem_lat .ge. alatitude -thre_lat .and. \
                   oned_tem_lat .le. alatitude +thre_lat .and. \
                   oned_tem_lon .ge. alongitude-thre_lon .and. \
                   oned_tem_lon .le. alongitude+thre_lon .and. \
                   oned_tem_aod .ne. bv3                 .and. \
                   oned_tem_aod .ne. bv4)
    if(.not.all(ismissing(index)))then
     ntem_lat = dimsizes(index)
     year(np:np+ntem_lat-1)  = tem_year
     month(np:np+ntem_lat-1) = tem_month
     day(np:np+ntem_lat-1)   = tem_day
     hour(np:np+ntem_lat-1)  = tem_hour
     lat(np:np+ntem_lat-1)   = oned_tem_lat(index)
     lon(np:np+ntem_lat-1)   = oned_tem_lon(index)
     aod_qf(np:np+ntem_lat-1)= oned_tem_aod_qf(index)
     aod(np:np+ntem_lat-1)   = oned_tem_aod(index)*tem_factor(0) + tem_factor(1)
     np = np + ntem_lat
    end if
    delete(index)
   end do
return
end
