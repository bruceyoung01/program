; ID: read_viirs_va.ncl V01 04/23/2012 09:57 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE read_viirs_va READS OUT DATA AND INFO FROM ALL THE NPP VIIRS EDR 
;  VAOOO DATA AND EDR GEOLOCATION DATA INTO COORESPONDING ARRARY, RESPECTIVELY.
;  INCLUDING YEAR, MONTH, DAY, HOUR, LATITUDE, LONGITUDE, AND AOD.
;  EDR AEROSOL VAOOO FILENAME SAMPLE:
;  VAOOO_npp_d20120331_t2032472_e2034114_b02206_c20120401030451240471_noaa_ops.h5
;  EDR GEOLOCATION FILENAME SAMPLE:
;  GAERO_npp_d20120201_t0909467_e0911109_b01362_c20120202145305252816_noaa_ops.h5
;
;  VARIABLES:
;  ============================================================================
;  (1 ) dir       (graphic) : WORK STATION                                [---]
;  (2 ) new_vfname(string)  : SELECTED VAOOO FILE NAME BASED ON GAERO 
;                             FILE NAME                                   [---]
;  (3 ) new_gfname(string)  : SELECTED GAERO FILE NAME BASED ON VAOOO 
;                             FILE NAME                                   [---]
;  (4 ) nvgfname  (integer) : # OF SELETED FILE NAME(VAOOO OR GAERO)      [---]
;  (5 ) year      (integer) : YEAR OF AERONET DATA                        [---]
;  (6 ) month     (integer) : MONTH OF AERONET DATA                       [---]
;  (7 ) day       (integer) : DAY OF AERONET DATA                         [---]
;  (8 ) hour      (integer) : HOUR OF AERONET DATA                        [---]
;  (9 ) lat       (float)   : VIIRS LATITUDE                              [deg]
;  (10) lon       (float)   : VIIRS LONGITUDE                             [deg]
;  (11) aod       (float)   : VIIRS AOD DATA                              [---]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (04/23/2012)
;******************************************************************************

undef("read_viirs_va")
procedure read_viirs_va(dir        :string,  new_vfname  :string,  \ ; INPUT
                        new_gfname :string,  nvgfname    :integer, \ ; INPUT
                        year       :integer, month       :integer, \ ; INPUT
                        day        :integer, hour        :integer, \ ; INPUT
                        lat        :float,   lon         :float,   \ ; OUTPUT
                        aod        :float)

begin
;  READ LATITUDE, LONGITUDE, AND AOD DATA FROM EDR AEROSOL DATA AND 
;  GEOLOCATION DATA, RESPECTIVELY
   do i = 0, nvgfname-1
    print("# OF READ FILES : " + i)
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
    tem_aod  = b->AerosolOpticalDepth_at_550nm
    ntem_lat = dimsizes(tem_lat)
    np       = ntem_lat(0)
    nl       = ntem_lat(1)
    year(0:np-1, (nl*i):(nl*(i+1)-1))  = tem_year
    month(0:np-1, (nl*i):(nl*(i+1)-1)) = tem_month
    day(0:np-1, (nl*i):(nl*(i+1)-1))   = tem_day
    hour(0:np-1, (nl*i):(nl*(i+1)-1))  = tem_hour
    lat(0:np-1, (nl*i):(nl*(i+1)-1))   = tem_lat
    lon(0:np-1, (nl*i):(nl*(i+1)-1))   = tem_lon
    aod(0:np-1, (nl*i):(nl*(i+1)-1))   = tem_aod*tem_factor(0) + tem_factor(1)
    delete([/tem_lat, tem_lon, tem_factor, tem_aod/])
   end do
return
end
