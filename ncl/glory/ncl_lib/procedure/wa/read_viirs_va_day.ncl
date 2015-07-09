; ID: read_viirs_va_day.ncl V01 05/07/2012 10:10 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE read_viirs_va_day READS OUT DATA AND INFO FROM ALL THE NPP VIIRS EDR 
;  VAOOO DATA AND EDR GEOLOCATION DATA INTO COORESPONDING ARRARY, RESPECTIVELY.
;  INCLUDING YEAR, MONTH, DAY, HOUR, LATITUDE, LONGITUDE, AND AOD. THE 
;  DIMENSIONS OF THE 3-D ARRAY FROM LEFTMOST TO RIGHTMOST ARE LATITUDE, 
;  LONGITUDE, AND DAY.
;  EDR AEROSOL VAOOO FILENAME SAMPLE:
;  VAOOO_npp_d20120331_t2032472_e2034114_b02206_c20120401030451240471_noaa_ops.h5
;  EDR GEOLOCATION FILENAME SAMPLE:
;  GAERO_npp_d20120201_t0909467_e0911109_b01362_c20120202145305252816_noaa_ops.h5
;
;  VARIABLES:
;  ============================================================================
;  (1 ) bv1       (integer) : BAD VALUE OF INTEGER                        [---]
;  (2 ) bv2       (float)   : BAD VALUE OF FLOAT                          [---]
;  (2 ) bv3       (float)   : BAD VALUE OF FLOAT                          [---]
;  (3 ) bv4       (float)   : BAD VALUE OF FLOAT                          [---]
;  (4 ) dir       (string)  : VIIRS DATA DIRECTORY                        [---]
;  (5 ) new_vfname(string)  : SELECTED VAOOO FILE NAME BASED ON GAERO 
;                             FILE NAME                                   [---]
;  (6 ) new_gfname(string)  : SELECTED GAERO FILE NAME BASED ON VAOOO 
;                             FILE NAME                                   [---]
;  (7 ) nvgfname  (integer) : # OF SELETED FILE NAME(VAOOO OR GAERO)      [---]
;  (8 ) year      (integer) : YEAR OF AERONET DATA                        [---]
;  (9 ) month     (integer) : MONTH OF AERONET DATA                       [---]
;  (10) day       (integer) : DAY OF AERONET DATA                         [---]
;  (11) hour      (integer) : HOUR OF AERONET DATA                        [---]
;  (12) lat       (float)   : VIIRS LATITUDE                              [deg]
;  (13) lon       (float)   : VIIRS LONGITUDE                             [deg]
;  (14) aod       (float)   : VIIRS AOD DATA                              [---]
;  (15) aod_qf    (integer) : VIIRS AOD DATA QUALITY FLAG                 [---]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (05/07/2012)
;  (2 ) MODIFIED FROM read_viirs_va.ncl. (05/07/2012)
;******************************************************************************

undef("read_viirs_va_day")
procedure read_viirs_va_day \
                       (bv1        :integer, bv2         :float,   \ ; INPUT
                        bv3        :float,   bv4         :float,   \ ; INPUT
                        dir        :string,  new_vfname  :string,  \ ; INPUT
                        new_gfname :string,  nvgfname    :integer, \ ; INPUT
                        year       :integer, month       :integer, \ ; INPUT
                        day        :integer, hour        :integer, \ ; INPUT
                        lat        :float,   lon         :float,   \ ; OUTPUT
                        aod        :float,   aod_qf      :integer)   ; OUTPUT

begin
;  READ LATITUDE, LONGITUDE, AND AOD DATA FROM EDR AEROSOL DATA AND 
;  GEOLOCATION DATA, RESPECTIVELY
   tem_day     = new(nvgfname, integer)
   j           = 0
   do i = 0, nvgfname-1
    print("# OF READ VIIRS FILES : " + i)
;  GET YEAR, MONTH, DAY, AND HOUR FROM FILE NAME
    tem_year   = stringtoint(str_get_cols(new_gfname(i), 11, 14))
    tem_month  = stringtoint(str_get_cols(new_gfname(i), 15, 16))
    tem_day(i) = stringtoint(str_get_cols(new_gfname(i), 17, 18))
    tem_hour   = stringtoint(str_get_cols(new_gfname(i), 21, 22))
;  READ LATITUDE, LONGITUDE, AND AOD
    a          = addfile(dir + new_gfname(i), "r")
    b          = addfile(dir + new_vfname(i), "r")
    tem_lat    = a->Latitude
    tem_lon    = a->Longitude
    tem_factor = b->AerosolOpticalDepthFactors
    tem_aod    = b->AerosolOpticalDepth_at_550nm
    tem_aod_qf = b->QF1_VIIRSAEROEDR
    ntem_lat   = dimsizes(tem_lat)
    np         = ntem_lat(0)
    nl         = ntem_lat(1)
    oned_tem_aod = ndtooned(ushorttoint(tem_aod))
    index      = ind(oned_tem_aod .eq. bv3  .or. \
                     oned_tem_aod .eq. bv4)
    if(.not.all(ismissing(index)))then
     oned_tem_aod(index) = bv1
     ntem_aod   = onedtond(oned_tem_aod, (/np, nl/))
     if(.not.all(ismissing(ntem_aod)))then
      if(i .eq. 0)then
       k = 0
       year(0:np-1, (nl*k):(nl*(k+1)-1), 0)  = tem_year
       month(0:np-1, (nl*k):(nl*(k+1)-1), 0) = tem_month
       day(0:np-1, (nl*k):(nl*(k+1)-1), 0)   = tem_day(i)
       hour(0:np-1, (nl*k):(nl*(k+1)-1), 0)  = tem_hour
       lat(0:np-1, (nl*k):(nl*(k+1)-1), 0)   = tem_lat
       lon(0:np-1, (nl*k):(nl*(k+1)-1), 0)   = tem_lon
       aod_qf(0:np-1, (nl*k):(nl*(k+1)-1), 0)= tem_aod_qf
       aod(0:np-1, (nl*k):(nl*(k+1)-1), 0)   = ntem_aod*tem_factor(0) + tem_factor(1)
       k = k + 1
      else if(i .gt. 0 .and. tem_day(i) .eq. tem_day(i-1))then
       year(0:np-1, (nl*k):(nl*(k+1)-1), j)  = tem_year
       month(0:np-1, (nl*k):(nl*(k+1)-1), j) = tem_month
       day(0:np-1, (nl*k):(nl*(k+1)-1), j)   = tem_day(i)
       hour(0:np-1, (nl*k):(nl*(k+1)-1), j)  = tem_hour
       lat(0:np-1, (nl*k):(nl*(k+1)-1), j)   = tem_lat
       lon(0:np-1, (nl*k):(nl*(k+1)-1), j)   = tem_lon
       aod_qf(0:np-1, (nl*k):(nl*(k+1)-1), j)= tem_aod_qf
       aod(0:np-1, (nl*k):(nl*(k+1)-1), j)   = ntem_aod*tem_factor(0) + tem_factor(1)
       k = k + 1
      else if(i .gt. 0 .and. tem_day(i) .ne. tem_day(i-1))then
       j = j + 1
       k = 0
       year(0:np-1, (nl*k):(nl*(k+1)-1), j)  = tem_year
       month(0:np-1, (nl*k):(nl*(k+1)-1), j) = tem_month
       day(0:np-1, (nl*k):(nl*(k+1)-1), j)   = tem_day(i)
       hour(0:np-1, (nl*k):(nl*(k+1)-1), j)  = tem_hour
       lat(0:np-1, (nl*k):(nl*(k+1)-1), j)   = tem_lat
       lon(0:np-1, (nl*k):(nl*(k+1)-1), j)   = tem_lon
       aod_qf(0:np-1, (nl*k):(nl*(k+1)-1), j)= tem_aod_qf
       aod(0:np-1, (nl*k):(nl*(k+1)-1), j)   = ntem_aod*tem_factor(0) + tem_factor(1)
      end if
      end if
      end if
     end if
    end if
    delete([/index, tem_lat, tem_lon, tem_factor, tem_aod/])
   end do

;  REMOVE BAD VALUE
   oned_aod = ndtooned(aod)
   index1   = ind(oned_aod .eq. 9991002 .or. \
                  oned_aod .le. 0.0)
   oned_aod(index1) = bv2
   nd_aod   = dimsizes(aod)
   aod      = onedtond(oned_aod, (/nd_aod(0), nd_aod(1), nd_aod(2)/))
return
end
