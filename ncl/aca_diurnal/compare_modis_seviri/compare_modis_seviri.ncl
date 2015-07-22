;  $ID: compare_modis_seviri.ncl V01 07/21/2015 08:48 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM compare_modis_seviri.ncl READS MODIS AND SEVIRI DATA, AND REGRIDS 
;  THEM INTO GRIDDED DATA, AND COMPARE THEIR DIFFERENCE GIVEN THE SAME PLACE 
;  AND TIME. 
;  MODIS DATA SAMPLE FILE NAME:
;  MYD06_L2.A2008197.1345.006.2013349041416.hdf
;  SEVIRI DATA SAMPLE FILE NAME:
;  SEV_06-CLD-L2_2008-06-01T00-00-00_V1-03.hdf
;
;  FLOW CHART:
;  ============================================================================
;  (1 ) DO THE YEAR, MONTH, AND DAY LOOPS;
;  (2 ) SELECT MODIS FILE NAMES BASED ON THE YEAR, MONTH, AND DAY;
;  (3 ) IF THERE IS/ARE MODIS FILE/S ON THIS DAY, THEN OPEN A TEXT FILE FOR 
;       WRITING SELECTED MODIS AND SEVIRI GRIDS;
;  (4 ) DO THE MODIS FILE NAMES LOOP;
;  (5 ) SELECT SEVIRI FILE NAME BASED ON MODIS FILE NAME AND TIME APPEARING IN 
;       THE FILE NAMES. IF THE MODIS TIME AND SEVIRI TIME ARE WITHIN 10 MINS, 
;       THEN WE CONSIDER THEY HAPPEN AT THE SAME TIME. OTHERWISE, WE TREAT THE 
;       SEVIRI DATA AS MISSING AT THIS TIME, AND DO NOT CONSIDER THIS TIME OF 
;       MODIS DATA;
;  (6 ) READ VARIABLES FROM SELECTED MODIS AND SEVIRI DATA;
;       NOTICE: SINCE WE WILL USE 1KM SPATIAL RESOLUTION MODIS DATA AND THERE 
;               IS NO GEOLOCATION DATA COREESPONDING TO 1KM SPATIAL RESOLUTION 
;               DATA, SO WE WILL EMPLOY GEOLOCATION FIELDS FROM MYD03. HERE IS 
;               THE DATA DESCRIPTION OF MOD03/MYD03 FROM MODIS WEBSITE:
;       http://modis.gsfc.nasa.gov/data/dataprod/dataproducts.php?MOD_NUMBER=03
;       The MODIS Geolocation product contains geodetic coordinates, 
;       ground elevation, and solar and satellite zenith, and azimuth angle for 
;       each MODIS 1-km sample. These data are provided as a companion data set 
;       to the Level 1B calibrated radiances and the Level 2 data sets to 
;       enable further processing. These geolocation fields are determined 
;       using the spacecraft attitude and orbit, instrument telemetry, and a 
;       digital elevation model.
;  (7 ) SELECT THE SAME GRIDS FROM MODIS AND SEVIRI GRIDDED DATA, CONSIDERING 
;       THEY ARE WITHIN THE STUDY REGION, AND MODIS AND SEVIRI MATCH EACH OTHER;
;  (8 ) WRITE THE SELECTED GRIDS INTO THE OPENED TEXT FILE. THE WRITE-IN ITEMS 
;       INCLUDE 1.LATITUDE, 2.LONGITUDE, 3.ABOVE CLOUD WATER VAPOR, 4.CLOUD 
;       OPTICAL THICKNESS 16, 5.CLOUD EFFECTIVE RADIUS 16, 6.CLOUD WATER PATH 
;       16, 7.CLOUD TOP TEMPERATURE, 8.CLOUD TOP HEIGHT, 9.CLOUD TOP PRESSURE
;  (9 ) END MODIS FILE NAMES LOOP;
;  (10) END DAY, MONTH, AND YEAR LOOPS.
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (07/21/2015)
;  (2 ) NEXT STEP FROM THIS PROGRAM IS PLOTTING THE SELECTED DATA INTO VARIOUS 
;       IMAGES FOR ANALYSIS. (07/21/2015)
;******************************************************************************

;  LOAD FUNCTIONS AND PROCEDURES
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/universal/gsn_csm_epa.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/universal/grid_lat_lon.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/select_modis_mod03_filename.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/select_modis_mod06_filename.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/select_seviri_modis_filename.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/pixel_to_grid_ESMF.ncl"


begin
;  DIRETORY TO SAVE FILES
   plot_dir   = "/home/vy57456/zzbatmos_user/program_plot/ncl/aca_diurnal/compare_modis_seviri/"

;  MODIS DATA INFO
;  MYD03
   m3dir      = "/home/vy57456/zzbatmos_common/Data/MODIS/aca_diurnal/MYD03/"
   m3filelist = "filelist_MYD03"
;  MYD06_L2
   m6dir      = "/home/vy57456/zzbatmos_common/Data/MODIS/aca_diurnal/MYD06_L2/"
   m6filelist = "filelist_MYD06_L2"
   msate      = "MODIS"

;  SEVIRI DATA INFO
;  SINCE SEVIRI FILE NAME HAS FIXED FORMAT, WE WILL BUILD SEVIRI FILE NAME 
;  WITHOUT USING FILE NAME LIST
   sdir       = "/home/vy57456/zzbatmos_common/Data/SEVIRI/SEV_06-CLD-L2.v1.03/"
   ssate      = "SEVIRI"

;  DEFINE BAD VALUE
   bv0        = "FilleValue"
   bv1a       = -9999
   bv1b       = -999
   bv2a       = -9999.
   bv2b       = -999.9
   bv2c       = -999.
   bv2d       = -999.999
   bv2e       = -9.9
   bv2f       = -249.99
   bv2g       = 127.

;  SET UP LIMITED REGION
   minlat     =-30.0
   maxlat     = 10.0
   minlon     =-20.0
   maxlon     = 20.0
;  GRID SIZE TO GRID PIXEL LEVEL DATA INTO GRIDDED LEVEL DATA
   lat_grid_size = 0.25
   lon_grid_size = 0.25

;  SET UP THE START TIME AND END TIME
   start_year = 2008
   end_year   = 2008
   start_month= 6
   end_month  = 6
   start_day  = 1

   start_ind_lat = 1400
   end_ind_lat   = 3000
   start_ind_lon = 1100
   end_ind_lon   = 2600

;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;  START TO PROCESS DATA
;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

;  DEFINE ARRAY FOR GRIDDED LATITUDE AND LONGITUDE ARRAY
   nlat       = floattoint((maxlat-minlat)/lat_grid_size) + 2
   nlon       = floattoint((maxlon-minlon)/lon_grid_size) + 2
   lat_grid_1d= new((/nlat/), float, bv2a)
   lon_grid_1d= new((/nlon/), float, bv2a)
   lat_grid_2d= new((/nlat, nlon/), float, bv2a)
   lon_grid_2d= new((/nlat, nlon/), float, bv2a)

;  GENERATE GRID BOX WITHIN THE STUDY REGION
;  CALL SUBROUTINE grid_lat_lon.ncl TO GENERATE GRIDDED LATITUDE AND LONGITUDE
   grid_lat_lon \
   (minlat, maxlat, minlon, maxlon, lat_grid_size, lon_grid_size, \
    lat_grid_1d, lon_grid_1d, lat_grid_2d, lon_grid_2d)

;  DO YEAR LOOP
   do iyear = start_year, end_year

;  DO MONTH LOOP
      do imonth = start_month, end_month
         nday = days_in_month(iyear, imonth)

;  DO DAY LOOP
         do iday = start_day, nday-1
            siyear  = sprinti("%0.4i", iyear)
            simonth = sprinti("%0.2i", imonth)
            siday   = sprinti("%0.2i", iday)
            stime   = siyear + "_" + simonth + "_" + siday
            print("Date : " + stime)

            logic_m3filename = True
            nm3filename_day  = 25
            sm3filename      = new((/nm3filename_day/), string,   bv0)
            nm3filename_real = new((/1/),               integer, bv1a)
            logic_m6filename = True
            nm6filename_day  = 25
            sm6filename      = new((/nm6filename_day/), string,   bv0)
            nm6filename_real = new((/1/),               integer, bv1a)
;  CALL SUBROUTINE select_modis_mod03_filename.ncl TO SELECT MODIS MOD03/MYD03 
;  FILE NAMES BASED ON THE YEAR, MONTH, DAY
            select_modis_mod03_filename              \
            (m3dir, m3filelist, iyear, imonth, iday, \
            sm3filename, nm3filename_real, logic_m3filename)
;  CALL SUBROUTINE select_modis_mod06_filename.ncl TO SELECT MODIS MOD06_L2/MYD06_L2 
;  FILE NAMES BASED ON THE YEAR, MONTH, DAY
            select_modis_mod06_filename              \
            (m6dir, m6filelist, iyear, imonth, iday, \
            sm6filename, nm6filename_real, logic_m6filename)
;  CALL SUBROUTINE 
            if (.not.logic_m3filename .or. \
                .not.logic_m6filename) then
               print("----------------------------------------------------------")
               print("MYD03 and MYD06_L2 File name does not exist")
               continue
            else if (nm3filename_real .ne. nm6filename_real) then
               print("MYD03 and MYD06_L2 don't match, please doublecheck file names!!!")
               continue
            end if
            end if
            print("AVAILABLE MODIS FILE NAME : " + \
                  sm3filename(0:nm3filename_real-1) + " | " + \
                  sm6filename(0:nm6filename_real-1))

;  BUILD TEXT FILE NAME FOR WRITTING SELECTED MODIS & SEVIRI DATA
            file_text = msate + "_" + ssate + "_" + stime + ".txt"

            iloop = 0
;  DO SELECTED MODIS FILE NAMES LOOP
            do ifilename_real = 0, nm3filename_real-1
;  BEFORE READ MODIS DATA, CHECK WHETHER SEVIRI DATA MATCH MODIS DATA
               ssfilename       = new((/1/), string)
               logic_ssfilename = True
;  CALL SUBROUTINE select_seviri_modis_filename.ncl TO SELECT SEVIRI FILE NAME BASED ON 
;  MODIS FILE NAME.
               select_seviri_modis_filename \
               (m6dir, sm6filename(ifilename_real), sdir, ssfilename, logic_ssfilename)

               if (.not. logic_ssfilename) then
                  continue
               end if
               if (.not.fileexists(sdir + siyear + "/" + stime + "/" + ssfilename)) then
                  print(ssfilename + " doesn't exist!!!")
                  continue
               end if
print("selected file name : " + ssfilename)
;  READ MODIS FILE NAME AND VARIABLES
               a     = addfile(m3dir + siyear + "/" + sm3filename(ifilename_real), "r")
               b     = addfile(m6dir + siyear + "/" + sm6filename(ifilename_real), "r")
               mlat  = a->Latitude
               mlon  = a->Longitude
               mAbove_Cloud_Water_Vapor_094 = b->Above_Cloud_Water_Vapor_094
               mCloud_Optical_Thickness_37  = b->Cloud_Optical_Thickness_37
               mCloud_Effective_Radius_37   = b->Cloud_Effective_Radius_37
               mCloud_Water_Path_37         = b->Cloud_Water_Path_37
               mcloud_top_pressure_1km      = b->cloud_top_pressure_1km
               mcloud_top_height_1km        = b->cloud_top_height_1km
               mcloud_top_temperature_1km   = b->cloud_top_temperature_1km

;  APPLY THEIR scale_factor AND add_offset TO THE VARIABLES
               macwv = doubletofloat(mAbove_Cloud_Water_Vapor_094@scale_factor* \
                                    (mAbove_Cloud_Water_Vapor_094 +             \
                                     mAbove_Cloud_Water_Vapor_094@add_offset))
               mcot  = doubletofloat(mCloud_Optical_Thickness_37@scale_factor*  \
                                    (mCloud_Optical_Thickness_37  +             \
                                     mCloud_Optical_Thickness_37@add_offset))
               mcer  = doubletofloat(mCloud_Effective_Radius_37@scale_factor*   \
                                    (mCloud_Effective_Radius_37 +               \
                                     mCloud_Effective_Radius_37@add_offset))
               mcwp  = doubletofloat(mCloud_Water_Path_37@scale_factor*         \
                                    (mCloud_Water_Path_37 +                     \
                                     mCloud_Water_Path_37@add_offset))
               mctp  = doubletofloat(mcloud_top_pressure_1km@scale_factor*      \
                                    (mcloud_top_pressure_1km +                  \
                                     mcloud_top_pressure_1km@add_offset))
               mcth  = doubletofloat(mcloud_top_height_1km@scale_factor*        \
                                    (mcloud_top_height_1km +                    \
                                     mcloud_top_height_1km@add_offset))
               mctt  = doubletofloat(mcloud_top_temperature_1km@scale_factor*   \
                                    (mcloud_top_temperature_1km +               \
                                     mcloud_top_temperature_1km@add_offset))
;  FillValue FOR EACH VARIABLE
;  mlat : bv2c
;  mlon : bv2c
;  macwv: bv2a
;  mcot : bv2a
;  mcer : bv2a
;  mcwp : bv2a
;  mctp : bv2c
;  mcth : bv2c
;  mctt : bv2c
;  CHANGE ALL THE MISSING VALUE TO bv2a
               mlat = where(ismissing(mlat), bv2a, mlat)
               mlon = where(ismissing(mlon), bv2a, mlon)
               mctp = where(ismissing(mctp), bv2a, mctp)
               mcth = where(ismissing(mcth), bv2a, mcth)
               mctt = where(ismissing(mctt), bv2a, mctt)
               mlat@_FillValue = bv2a
               mlon@_FillValue = bv2a
               mctp@_FillValue = bv2a
               mcth@_FillValue = bv2a
               mctt@_FillValue = bv2a
;  DEFINE ARRAY FOR SUBROUTINE pixel_to_grid_ESMF.ncl
;  PUT ALL MODIS DATA INTO ONE ARRAY
               nmvariable         = 7
               ndim               = dimsizes(macwv)
               dim_modis_all      = (/nmvariable, ndim(0), ndim(1)/)
               modis_all          = new(dim_modis_all, float, bv2a)
               dim_modis_grid_all = (/nmvariable, nlat, nlon/)
               modis_grid_all     = new(dim_modis_grid_all, float, bv2a)
               modis_all(0, :, :) = macwv
               modis_all(1, :, :) = mcot
               modis_all(2, :, :) = mcer
               modis_all(3, :, :) = mcwp
               modis_all(4, :, :) = mctp
               modis_all(5, :, :) = mcth
               modis_all(6, :, :) = mctt

;  READ SEVIRI DATA
               c = addfile(sdir + siyear + "/" + stime + "/" + ssfilename, "r")
               if (.not.isdefined("lat")) then
                  lat   = (/c->MSG_Latitude(start_ind_lat:end_ind_lat, \
                                            start_ind_lon:end_ind_lon)/)
                  lon   = (/c->MSG_Longitude(start_ind_lat:end_ind_lat,\
                                             start_ind_lon:end_ind_lon)/)
                  lat@_FillValue = bv2d
                  lon@_FillValue = bv2d
               end if
               Above_Cloud_Water_Vapor        = c->Above_Cloud_Water_Vapor     \
                                                   (start_ind_lat:end_ind_lat, \
                                                    start_ind_lon:end_ind_lon)
               Cloud_Optical_Thickness_38     = c->Cloud_Optical_Thickness_38  \
                                                   (start_ind_lat:end_ind_lat, \
                                                    start_ind_lon:end_ind_lon)
               Cloud_Effective_Radius_38      = c->Cloud_Effective_Radius_38   \
                                                   (start_ind_lat:end_ind_lat, \
                                                    start_ind_lon:end_ind_lon)
               Cloud_Water_Path_38            = c->Cloud_Water_Path_38         \
                                                   (start_ind_lat:end_ind_lat, \
                                                    start_ind_lon:end_ind_lon)
               Cloud_Top_Pressure             = c->Cloud_Top_Pressure          \
                                                   (start_ind_lat:end_ind_lat, \
                                                    start_ind_lon:end_ind_lon)
               Cloud_Top_Height               = c->Cloud_Top_Height            \
                                                   (start_ind_lat:end_ind_lat, \
                                                    start_ind_lon:end_ind_lon)
               Cloud_Top_Temperature          = c->Cloud_Top_Temperature       \
                                                   (start_ind_lat:end_ind_lat, \
                                                    start_ind_lon:end_ind_lon)
               acwv  = doubletofloat(Above_Cloud_Water_Vapor@scale_factor*   \
                                    (Above_Cloud_Water_Vapor +               \
                                     Above_Cloud_Water_Vapor@add_offset))
               cot38 = doubletofloat(Cloud_Optical_Thickness_38@scale_factor*\
                                    (Cloud_Optical_Thickness_38 +            \
                                     Cloud_Optical_Thickness_38@add_offset))
               cer38 = doubletofloat(Cloud_Effective_Radius_38@scale_factor* \
                                    (Cloud_Effective_Radius_38 +             \
                                     Cloud_Effective_Radius_38@add_offset))
               cwp38 = doubletofloat(Cloud_Water_Path_38@scale_factor*       \
                                    (Cloud_Water_Path_38 +                   \
                                     Cloud_Water_Path_38@add_offset))
               cth   = doubletofloat(Cloud_Top_Height@scale_factor*          \
                                    (Cloud_Top_Height +                      \
                                     Cloud_Top_Height@add_offset))
               ctp   = doubletofloat(Cloud_Top_Pressure@scale_factor*        \
                                    (Cloud_Top_Pressure +                    \
                                     Cloud_Top_Pressure@add_offset))
               ctt   = doubletofloat(Cloud_Top_Temperature@scale_factor*     \
                                    (Cloud_Top_Temperature +                 \
                                     Cloud_Top_Temperature@add_offset))
               acwv@_FillValue      = bv2e
               cot38@_FillValue     = bv2a
               cer38@_FillValue     = bv2a
               cwp38@_FillValue     = bv2a
               cth@_FillValue       = bv2c
               ctp@_FillValue       = bv2f
               ctt@_FillValue       = bv2g
               acwv = where(acwv .eq. bv2e,  bv2a, acwv)
               cth  = where(ismissing(cth),  bv2a,  cth)
               ctp  = where(ismissing(ctp),  bv2a,  ctp)
               ctt  = where(ctt  .eq. bv2f,  bv2a,  ctt)
               if (all(ismissing(acwv))      .and. \
                   all(ismissing(cot38))     .and. \
                   all(ismissing(cer38))     .and. \
                   all(ismissing(cwp38))     .and. \
                   all(ismissing(cth))       .and. \
                   all(ismissing(ctp))       .and. \
                   all(ismissing(ctt))) then
                  print("----------------------------------------------")
                  print("ALL THE SEVIRI VARIABLES ARE MISSING VALUES!!!!!!!!!")
                  continue
               end if
;  DEFINE ARRAY FOR SUBROUTINE pixel_to_grid_ESMF.ncl
;  PUT ALL SEVIRI DATA INTO ONE ARRAY
                  nvariable           = 7
                  ndim                = dimsizes(acwv)
                  dim_seviri_all      = (/nvariable, ndim(0), ndim(1)/)
                  seviri_all          = new(dim_seviri_all, float, bv2a)
                  dim_seviri_grid_all = (/nvariable, nlat, nlon/)
                  seviri_grid_all     = new(dim_seviri_grid_all, float, bv2a)
                  seviri_all(0, :, :) = acwv
                  seviri_all(1, :, :) = cot38
                  seviri_all(2, :, :) = cer38
                  seviri_all(3, :, :) = cwp38
                  seviri_all(4, :, :) = ctp
                  seviri_all(5, :, :) = cth
                  seviri_all(6, :, :) = ctt
;  IF ALL THE SEVIRI DATA ARE MISSING, THEN CONTINUE TO NEXT LOOP
                  if (all(ismissing(seviri_all))) then
                     print("ALL THE SEVIRI DATA ARE MISSING!!!!!!!!")
                     continue
                  end if

print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@")
;  CALL SUBROUTINE pixel_to_grid_ESMF.ncl TO GRID THE PIXEL LEVEL DATA INTO
;  GRIDDED LEVEL DATA
               pixel_to_grid_ESMF                                 \
               (bv2a, mlat, mlon, minlat, maxlat, minlon, maxlon, \
               lat_grid_size, lon_grid_size, modis_all, modis_grid_all)
               if (.not.isdefined("ssfilename_tmp")) then
;  CALL SUBROUTINE pixel_to_grid_ESMF.ncl TO GRID THE PIXEL LEVEL DATA INTO
;  GRIDDED LEVEL DATA
                  pixel_to_grid_ESMF                               \
                  (bv2a, lat, lon, minlat, maxlat, minlon, maxlon, \
                  lat_grid_size, lon_grid_size, seviri_all, seviri_grid_all)
                  seviri_grid_all_tmp = seviri_grid_all
               else
                  if (ssfilename_tmp .eq. ssfilename) then
                     print("Same SEVIRI file name, ignore regridding!!!")
                  else
;  CALL SUBROUTINE pixel_to_grid_ESMF.ncl TO GRID THE PIXEL LEVEL DATA INTO
;  GRIDDED LEVEL DATA
                     pixel_to_grid_ESMF                               \  
                     (bv2a, lat, lon, minlat, maxlat, minlon, maxlon, \
                     lat_grid_size, lon_grid_size, seviri_all, seviri_grid_all)
                     seviri_grid_all_tmp = seviri_grid_all
                  end if
               end if
print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@")
;  RESHAPE modis_grid_all AND seviri_grid_all
               lat_grid_2d_resh     = reshape(lat_grid_2d, (/nlat*nlon/))
               lon_grid_2d_resh     = reshape(lon_grid_2d, (/nlat*nlon/))
               modis_grid_all_resh  = reshape(modis_grid_all,  (/nmvariable, nlat*nlon/))
               seviri_grid_all_resh = reshape(seviri_grid_all_tmp, (/nvariable,  nlat*nlon/))
;  CHECK WHETHER LIQUID WATER PATH IS MISSING
               index = ind(.not.ismissing(modis_grid_all_resh (3, :)) .and. \
                           .not.ismissing(seviri_grid_all_resh(3, :)))
               if (.not.all(ismissing(index))) then
                  header            = (/"Latitude "                    + \ 
                                        "Longitude "                   + \ 
                                        "Above_Cloud_Water_Vapor_094 " + \ 
                                        "Cloud_Optical_Thickness_37 "  + \ 
                                        "Cloud_Effective_Radius_37 "   + \ 
                                        "Cloud_Water_Path_37 "         + \ 
                                        "cloud_top_pressure_1km "      + \ 
                                        "cloud_top_height_1km "        + \ 
                                        "cloud_top_temperature_1km "   + \ 
                                        "Above_Cloud_Water_Vapor "     + \ 
                                        "Cloud_Optical_Thickness_38 "  + \ 
                                        "Cloud_Effective_Radius_38 "   + \ 
                                        "Cloud_Water_Path_38 "         + \ 
                                        "Cloud_Top_Pressure "          + \ 
                                        "Cloud_Top_Height "            + \ 
                                        "Cloud_Top_Temperature "/)
                  hlist             = [/header/]
                  modis_seviri_list = [/lat_grid_2d_resh(index),        \
                                        lon_grid_2d_resh(index),        \
                                        modis_grid_all_resh(0, index),  \
                                        modis_grid_all_resh(1, index),  \
                                        modis_grid_all_resh(2, index),  \
                                        modis_grid_all_resh(3, index),  \
                                        modis_grid_all_resh(4, index),  \
                                        modis_grid_all_resh(5, index),  \
                                        modis_grid_all_resh(6, index),  \
                                        seviri_grid_all_resh(0, index), \
                                        seviri_grid_all_resh(1, index), \
                                        seviri_grid_all_resh(2, index), \
                                        seviri_grid_all_resh(3, index), \
                                        seviri_grid_all_resh(4, index), \
                                        seviri_grid_all_resh(5, index), \
                                        seviri_grid_all_resh(6, index)/]
                  format = "%10.3f%10.3f%10.3f%10.3f%10.3f%10.3f%10.3f%10.3f" + \
                           "%10.3f%10.3f%10.3f%10.3f%10.3f%10.3f%10.3f%10.3f"
                  if (iloop .eq. 0) then
                     write_table(plot_dir +file_text, "w", hlist, "%s")
                  end if
                  write_table(plot_dir + file_text, "a", modis_seviri_list, format)
               end if
               ssfilename_tmp = ssfilename

               delete([/mlat, mlon,                   \
                        mAbove_Cloud_Water_Vapor_094, \
                        mCloud_Optical_Thickness_37,  \
                        mCloud_Effective_Radius_37,   \
                        mCloud_Water_Path_37,         \
                        mcloud_top_pressure_1km,      \
                        mcloud_top_height_1km,        \
                        mcloud_top_temperature_1km,   \
                        macwv, mcot, mcer, mcwp,      \
                        mctp, mcth, mctt,             \
                        modis_all, modis_grid_all/])
               delete([/index/])
               iloop = iloop + 1
            end do ;ifilename_real
         end do ;iday
      end do ;imonth
   end do ;iyear

end
