;  $ID: bin_sum_modis_aod_1day.ncl V01 12:47 04/06/2013 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE bin_sum_modis_aod_1day READS MODIS AOD (MOD04/MYD04) AND USES 
;  bin_sum TO SUM THEM.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (04/06/2013)
;******************************************************************************
undef("bin_sum_modis_aod_1day")
procedure bin_sum_modis_aod_1day \
          (dir       :string,  filename  :string,    \; INPUT
           bv0       :string,                        \; INPUT
           iday      :integer, loro      :string,    \; INPUT
           startinx  :integer, endinx    :integer,   \; INPUT
           lat       :float,   lon       :float,     \; INPUT
           aod       :float,   aod_ct    :integer)    ; OUTPUT
;          aod_qf    :integer, aod_qf_ct :integer)    ; OUTPUT

begin
;  ECHO SYSTEM TIME AT THE BEGINNING OF THE PROCEDURE
   tstrt = systemfunc("date")

;  GET ALL THE FILENAME IN ONE DAY
   ninx = endinx(iday) - startinx(iday) + 1
   tmpfilename = new(ninx, string, bv0)
   tmpfilename = filename(startinx(iday):endinx(iday))

;  DO # OF FILES IN 1 DAY TO SUM ALL THE DATA
   do i = 0, ninx-1
    print("NOW READING MODIS FILE : " + tmpfilename(i))
;  READ LATITUDE, LONGITUDE, AND AOD
    a          = addfile(dir + tmpfilename(i), "r")
    tem_lat    = a->Latitude
    tem_lon    = a->Longitude
    tem_aod_qf = a->Quality_Assurance_Land
;  JUDGE THE INPUT DATA IS LAND, OCEAN OR BOTH
    if (loro .eq. "land_ocean") then
     tem_aod  = short2flt_hdf(a->Optical_Depth_Land_And_Ocean)
    else if (loro .eq. "land") then
     tem_aod  = short2flt_hdf(a->dim_avg_n_Wrap(Optical_Depth_Small_Land, 0))
    else if (loro .eq. "ocean") then
     tem_aod  = short2flt_hdf(a->dim_avg_n_Wrap(Optical_Depth_Small_Best_Ocean, 0))
    else if (loro .eq. "deep_blue_550_land") then
     tem_aod  = short2flt_hdf(a->Deep_Blue_Aerosol_Optical_Depth_550_Land)
;  DEEP BLUE AOD LAND AT 412nm, 470nm, 660nm
;  ALL OF THESE REFERED TO MOD04/MYD04 DATA PROPERTIES
    else if (loro .eq. "deep_blue_land") then
     tem_aod  = short2flt_hdf(a->Deep_Blue_Aerosol_Optical_Depth_Land(0, :, :))
    end if
    end if
    end if
    end if
    end if
    
;  USE bin_sum TO SUM ALL THE DATA IN ONE DAY
    bin_sum(aod, aod_ct, lon, lat, ndtooned(tem_lon), \
            ndtooned(tem_lat), ndtooned(tem_aod))
    delete([/tem_lat, tem_lon, tem_aod, tem_aod_qf/])
   end do
;  ============================================================================
;  CALCULATE AOD AVERAGE
   aod_ct    = where(aod_ct .eq. 0, aod_ct@_FillValue, aod_ct)
   aod       = aod/aod_ct
   lat@units = "degrees_north"
   lon@units = "degrees_east"
   aod!0     = "lat"
   aod!1     = "lon"
   aod_ct!0  = "lat"
   aod_ct!1  = "lon"
   copy_VarCoords(aod, aod_ct)

;  ECHO USED TIME FOR THIS PROCEDURE
   wallClockElapseTime(tstrt, "bin_sum_modis_aod_1day.ncl", 0)

return
end
