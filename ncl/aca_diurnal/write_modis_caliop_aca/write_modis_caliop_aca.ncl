;  $ID: write_modis_caliop_aca.ncl V01 07/22/2015 10:20 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM write_modis_caliop_aca.ncl READS MODIS AND CALIOP DATA. THE DATA ARE 
;  AS FOLLOWING:
;  CAL_LID_L2_05kmALay-Prov-V3-01.2008-12-30T19-14-10ZD.hdf
;  CAL_LID_L2_05kmCLay-Prov-V3-01.2008-12-30T19-14-10ZD.hdf
;  MYD04_L2.A2008209.1550.006.2013349093609.hdf
;  MYD06_L2.A2008197.1215.006.2013349035724.hdf
;  THEN USES COSTANTINO_2013_ACP METHOD TO SEPARATE CASES WITH DIFFERENT 
;  RELATIVE POSITION OF CLOUD AND ACA. THEN WRITE THE SELECTED DATA INTO A TEXT 
;  FILE FOR POST-PROCESSING.
;  L : DISTANCE BETWEEN CLOUD TOP ALTITUDE AND AEROSOL BASE ALTITUDE.
;  (a ) touch : L<100m;
;  (b ) uncertain : 100m<L<750m;
;  (c ) untouch : L>750m.
;  THE DISTINGUISHING METHOD USED HERE IS FROM THE FOLLOWING REFERENCES:
;  (1 ) Costantino, L. and Bréon, F.-M.: Aerosol indirect effect on warm clouds 
;       over South-East Atlantic, from co-located MODIS and CALIPSO observations, 
;       Atmos. Chem. Phys., 13, 69-88, doi:10.5194/acp-13-69-2013, 2013.
;
;  FLOW CHART:
;  ============================================================================
;  (1 ) DO YEAR, MONTH, AND DAY LOOP
;  (2 ) READ MODIS FILE NAME BASED ON YEAR, MONTH, AND DAY;
;       THE VARIABLES NEEDED FROM MODIS ARE AS FOLLOWING:
;       MYD04_L2.A2008209.1550.006.2013349093609.hdf (SPATIAL RESOLUTION): 
;       (A ) 30: (    7 x  203 x  135 ) Effective_Optical_Depth_Best_Ocean (10KM)
;       (B ) 44: (  203 x  135 ) Angstrom_Exponent_1_Ocean (10KM)
;       MYD06_L2.A2008197.1215.006.2013349035724.hdf : 
;       (C ) 79: ( 2030 x 1354 ) Cloud_Optical_Thickness_37 (1KM)
;       (D ) 91: ( 2030 x 1354 ) Cloud_Water_Path_37 (1KM)
;       (E ) 73: ( 2030 x 1354 ) Cloud_Effective_Radius_37 (1KM)
;       (F ) 24: (  406 x  270 ) Cloud_Top_Pressure (5KM)
;       (G ) 37: (  406 x  270 ) Cloud_Fraction (5KM)
;  (3 ) GRID THE PIXEL DATA TO GRIDDED DATA USING ESMF_REGRIDDING METHOD. THE 
;       GRID SIZE IS 1 DEGREE BY 1 DEGREE;
;  (4 ) READ CALIPSO LAYER PRODUCT;
;       THE VARIABLES NEEDED FROM CALIOP ARE AS FOLLOWING:
;       CAL_LID_L2_05kmALay-Prov-V3-01.2008-12-30T19-14-10ZD.hdf :
;       CAL_LID_L2_05kmCLay-Prov-V3-01.2008-12-30T19-14-10ZD.hdf :
;       (A ) 41: ( 3728 x    1 ) Number_Layers_Founod (5KM)
;       (B ) 43: ( 3728 x    8 ) Layer_Top_Altitude (5KM)
;       (C ) 44: ( 3728 x    8 ) Layer_Base_Altitude (5KM)
;  (5 ) SELECT MODIS DATA WITH ALL (INCLUDING TOUCHING, UNTOUCHING, AND UNCERTAIN), 
;       TOUCHING, UNTOUCHING, UNCERTAIN, AND NOACA CASES;
;  (6 ) WRITE SELECTED MODIS AND CALIOP DATA INTO A TEXT FILE.
;
;  NOTES:
;  ============================================================================
;  (1 ) METHODOLOGY USED HERE IS FROM COSTANTINO_2013_ACP PAPER. (BRUCE, 07/22/2015)
;  (2 ) THIS NCL CODE IS ORIGINALLY WRITTEN BY BRUCE. (07/22/2015)
;  (3 ) SINCE AQUA AND CALIPSO ARE BOTH IN THE A-TRAIN, WE ONLY CONSIDER MODIS 
;       FROM AQUA. (BRUCE, 07/22/2015)
;******************************************************************************
;
;  LOAD FUNCTIONS AND PROCEDURES
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/universal/gsn_csm_epa.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/universal/grid_lat_lon.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/match_modis_mod03_mod04_mod06_filename_yearmonthday.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/select_calipso_filename.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/collect_calipso_region_dn_filename.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/pixel_to_grid_ESMF.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/select_aca_aba_cloud_cta_var.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/select_modis_calipso_aca_cloud_costantino2013_write_all_28var.ncl"

begin
;  RESULTS SAVING INFO (INCLUDING PLOTS AND DATA)
   plot_dir   = "/home/vy57456/zzbatmos_user/program_plot/ncl/aca_diurnal/write_modis_caliop_aca/"

;  DATA DIRECTORY FOR MODIS
;  MYD03
   m3dir      = "/home/vy57456/zzbatmos_common/Data/MODIS/aca_diurnal/MYD03/"
   m3filelist = "filelist_MYD03"
;  MYD04_L2
   m4dir      = "/home/vy57456/zzbatmos_common/Data/MODIS/aca_diurnal/MYD04_L2/"
   m4filelist = "filelist_MYD04_L2"
;  MYD06_L2
   m6dir      = "/home/vy57456/zzbatmos_common/Data/MODIS/aca_diurnal/MYD06_L2/"
   m6filelist = "filelist_MYD06_L2"

;  DATA DIRECTORY FOR CALIOP AEROSOL LAYER PRODUCTS, PRODUCT NAME IS:
;  CAL_LID_L2_05kmALay-Prov-V3
   acdir      = "/home/vy57456/zzbatmos_common/Data/CALIPSO/CAL_LID_L2_05kmALay/"
   acfilelist = "filelist_CAL_LID_L2_05kmALay-Prov-V3"

;  CAL_LID_L2_05kmCLay-Prov-V3
   ccdir      = "/home/vy57456/zzbatmos_common/Data/CALIPSO/CAL_LID_L2_05kmCLay/"
   ccfilelist = "filelist_CAL_LID_L2_05kmCLay-Prov-V3"

;  DEFINE BAD VALUE
   bv0        = "FillValue"
   bv1        = -9999
   bv2        = -9999.

;  SET UP LIMITED REGION
   minlat     =-15.0
   maxlat     =-2.0
   minlon     =-14.0
   maxlon     = 18.0
;  LATTITUDE AND LONGITUDE FOR STUDY REGION
   lat_pg     = (/minlat, minlat, maxlat, maxlat, minlat/)
   lon_pg     = (/minlon, maxlon, maxlon, minlon, minlon/)
;  GRID SIZE TO GRID PIXEL LEVEL DATA INTO GRIDDED LEVEL DATA
   lat_grid_size = 1.0
   lon_grid_size = 1.0

;  SET UP THE START TIME AND END TIME
   start_year = 2008
   end_year   = 2010
   start_month= 7
   end_month  = 9
   start_day  = 1

;  SWITCH FOR DIFFERENT CASES
;  FOR Costantino_2013
;  "all"       : ALL THE CASES INCLUDING ACA AND CLOUD WITH UNTOUCH AND TOUCH
;  "untouch"   : UNTOUCH ACA AND CLOUD
;  "touch"     : TOUCH ACA AND CLOUD
;  "uncertain" : UNCERTAIN ABOUT WHETHER ACA AND CLOUD TOUCH OR UNTOUCH
;  "noaca"     : NO ACA
   case          = (/"all", "untouch", "touch", "uncertain", "noaca"/)
   sday_or_night = (/"D"/)
   ncase         = dimsizes(case)
   nday_or_night = dimsizes(sday_or_night)

;  DEFINE ARRAY FOR GRIDDED LATITUDE AND LONGITUDE ARRAY
   nlat       = floattoint((maxlat-minlat)/lat_grid_size) + 2
   nlon       = floattoint((maxlon-minlon)/lon_grid_size) + 2
   dim_2d     = (/nlat, nlon/)
   lat_grid_1d= new((/nlat/), float, bv2)
   lon_grid_1d= new((/nlon/), float, bv2)
   lat_grid_2d= new(dim_2d, float, bv2)
   lon_grid_2d= new(dim_2d, float, bv2)

;  CALL SUBROUTINE grid_lat_lon.ncl TO GENERATE GRIDDED LATITUDE AND LONGITUDE
   grid_lat_lon \
   (minlat, maxlat, minlon, maxlon, lat_grid_size, lon_grid_size, \
    lat_grid_1d, lon_grid_1d, lat_grid_2d, lon_grid_2d)
;  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;  START TO PROCESS DATA
;  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

;  DO YEAR LOOP
   do iyear = start_year, end_year

;  DO MONTH LOOP
      do imonth = start_month, end_month

;  CALCULATE THE NUMBER OF DAYS IN THIS MONTH
         nday_month = days_in_month(iyear, imonth)
;  DO DAY LOOP
         do iday = start_day, nday_month
;  FOR EVERY ITERATION, ASSUME THE FILE NAME EXISTS
            siyear  = sprinti("%0.4i", iyear)
            simonth = sprinti("%0.2i", imonth)
            siday   = sprinti("%0.2i", iday)
            symd1   = siyear + "_" + simonth + "_" + siday
            print("Now processing : " + symd1)
;  DO DAY AND NIGHT LOOP
            do iday_or_night = 0, nday_or_night-1

;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;  SELECT MODIS DATA
;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;  DEFINE ARRAY FOR SUBROUTINE match_modis_mod03_mod04_mod06_filename.ncl
               logic_smfilename = True
               nsmfilename      = 10
               nsmfilename_real = new((/1/), integer, bv1)
               sm3filename      = new((/nsmfilename/), string, bv0)
               sm4filename      = new((/nsmfilename/), string, bv0)
               sm6filename      = new((/nsmfilename/), string, bv0)
;  CALL SUBROUTINE match_modis_mod03_mod04_mod06_filename_yearmonthday.ncl 
;  TO MATCH MODIS FILENAMES OF MOD03/MYD03, MOD04_L2/MYD04_L2, AND 
;  MOD06_L2/MYD04_L2
               match_modis_mod03_mod04_mod06_filename_yearmonthday \
               (iyear, imonth, iday, m3dir, m3filelist, m4dir, m4filelist,  \
               m6dir, m6filelist, sm3filename, sm4filename, sm6filename, \
               nsmfilename_real, logic_smfilename)

               if (logic_smfilename) then
                  print("NO FILES OF MOD03/MYD03, MOD04_L2/MYD04_L2, AND MOD06_L2/MYD06_L2 MATCHING!!!")
                  continue
               end if
               print("SELECTED MOD03/MYD03 :" + sm3filename(0:nsmfilename_real-1))
               print("SELECTED MOD04_L2/MYD04_L2 : " + sm4filename(0:nsmfilename_real-1))
               print("SELECTED MOD06_L2/MYD06_L2  : " + sm6filename(0:nsmfilename_real-1))
;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;  SELECT CALIOP DATA
;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;  DEFINE VARIABLES FOR SUBROUTINE select_calipso_filename.ncl
               logic_sacfilename = True
               logic_sccfilename = True
               nscfilename       = 20
               sacfilename       = new((/nscfilename/), string)
               sccfilename       = new((/nscfilename/), string)
;  CALL SUBROUTINE select_calipso_filename.ncl TO SELECT FILE NAMES BASED ON 
;  YEAR, MONTH, AND DAY FOR CAL_LID_L2_05kmALay-Prov-V3
               select_calipso_filename \
               (acdir, acfilelist, iyear, imonth, iday, iday_or_night, \
               logic_sacfilename, sacfilename)
;  CALL SUBROUTINE select_calipso_filename.ncl TO SELECT FILE NAMES BASED ON 
;  YEAR, MONTH, AND DAY FOR CAL_LID_L2_05kmCLay-Prov-V3
               select_calipso_filename \
               (ccdir, ccfilelist, iyear, imonth, iday, iday_or_night, \
               logic_sccfilename, sccfilename)
;  CHECK FILENAMES EXIST OR NOT. IF NOT, CONTINUE TO THE NEXT DO LOOP
               if (logic_sacfilename .and. logic_sccfilename) then
;  DEFINE ARRAY TO HOLD LATITUDE AND LONGITUDE
                  nctrack                  = 3
                  sacfilename_region       = new((/nctrack/), string)
                  sccfilename_region       = new((/nctrack/), string)
                  nactrack_real            = new((/1/), integer, bv1)
                  ncctrack_real            = new((/1/), integer, bv1)
                  logic_sacfilename_region = False
                  logic_sccfilename_region = False
;  CALL SUBROUTINE collect_calipso_region_dn_filename.ncl TO COLLECT ALL THE 
;  CALIPSO FILENAMES IN THE STUDY REGION FOR CAL_LID_L2_05kmALay-Prov-V3
                  collect_calipso_region_dn_filename \
                  (acdir, sacfilename, siyear, sday_or_night(iday_or_night), \
                  minlat, maxlat, minlon, maxlon,                            \
                  sacfilename_region, logic_sacfilename_region, nactrack_real)
;  CALL SUBROUTINE collect_calipso_region_dn_filename.ncl TO COLLECT ALL THE 
;  CALIPSO FILENAMES IN THE STUDY REGION FOR CAL_LID_L2_05kmCLay-Prov-V3
                  collect_calipso_region_dn_filename \
                  (ccdir, sccfilename, siyear, sday_or_night(iday_or_night), \
                  minlat, maxlat, minlon, maxlon,                            \
                  sccfilename_region, logic_sccfilename_region, ncctrack_real)
               else
                  print("NO CALIPSO DATA ON " + symd1)
                  continue
               end if

;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;  READ MODIS DATA AND COLLECT ALL THE DATA INTO AN ARRAY
;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;  SINCE MODIS DATA HAVE VARIOUS SPATIAL RSOLUTIONS, WE SHOLD NOTICE THE 
;  DIMENSION SIZE BASED ON SPAIAL RESOLUTIONS
               a          = addfile(m3dir + siyear + "/" + sm3filename(0), "r")
               b          = addfile(m4dir + siyear + "/" + sm4filename(0), "r")
               c          = addfile(m6dir + siyear + "/" + sm6filename(0), "r")
               lat1km     = a->Latitude
               lat10km    = b->Latitude
               lat5km     = c->Latitude

;  DEFINE ARRAY BASED ON SPATIAL RESOLUTION
               dim1km     = (/2030, 1354/)
               dim10km    = (/203,   135/)
               dim5km     = (/406,   270/)
               n1km       = 3
               n10km      = 2
               n5km       = 2
;       (C ) 79: ( 2030 x 1354 ) Cloud_Optical_Thickness_37 (1KM)
;       (D ) 91: ( 2030 x 1354 ) Cloud_Water_Path_37 (1KM)
;       (E ) 73: ( 2030 x 1354 ) Cloud_Effective_Radius_37 (1KM)
               lat_1km    = new((/nsmfilename_real*dim1km(0),  dim1km(1)/),         float, bv2)
               lon_1km    = new((/nsmfilename_real*dim1km(0),  dim1km(1)/),         float, bv2)
               modis_1km  = new((/n1km, nsmfilename_real*dim1km(0),  dim1km(1)/),   float, bv2)
;       (A ) 30: (    7 x  203 x  135 ) Effective_Optical_Depth_Best_Ocean (10KM)
;       (B ) 44: (  203 x  135 ) Angstrom_Exponent_1_Ocean (10KM)
               lat_10km   = new((/nsmfilename_real*dim10km(0),  dim10km(1)/),       float, bv2)
               lon_10km   = new((/nsmfilename_real*dim10km(0),  dim10km(1)/),       float, bv2)
               modis_10km = new((/n10km, nsmfilename_real*dim10km(0), dim10km(1)/), float, bv2)
;       (F ) 24: (  406 x  270 ) Cloud_Top_Pressure (5KM)
;       (G ) 37: (  406 x  270 ) Cloud_Fraction (5KM)
               lat_5km    = new((/nsmfilename_real*dim5km(0),  dim5km(1)/),         float, bv2)
               lon_5km    = new((/nsmfilename_real*dim5km(0),  dim5km(1)/),         float, bv2)
               modis_5km  = new((/n5km, nsmfilename_real*dim5km(0),  dim5km(1)/),   float, bv2)
;  DO MODIS FILE NAME LOOP
               iloop_ismfilename_real = 0
               do ismfilename_real = 0, nsmfilename_real-1
                  a = addfile(m3dir + siyear + "/" + sm3filename(ismfilename_real), "r")
                  b = addfile(m4dir + siyear + "/" + sm4filename(ismfilename_real), "r")
                  c = addfile(m6dir + siyear + "/" + sm6filename(ismfilename_real), "r")
                  lat_1km(iloop_ismfilename_real*dim1km(0):(iloop_ismfilename_real+1)*dim1km(0)-1, :) = \
                  a->Latitude(0:dim1km(0)-1, 0:dim1km(1)-1)
                  lon_1km(iloop_ismfilename_real*dim1km(0):(iloop_ismfilename_real+1)*dim1km(0)-1, :) = \
                  a->Longitude(0:dim1km(0)-1, 0:dim1km(1)-1)
                  lat_10km(iloop_ismfilename_real*dim10km(0):(iloop_ismfilename_real+1)*dim10km(0)-1, :) = \
                  b->Latitude(0:dim10km(0)-1, 0:dim10km(1)-1)
                  lon_10km(iloop_ismfilename_real*dim10km(0):(iloop_ismfilename_real+1)*dim10km(0)-1, :) = \
                  b->Longitude(0:dim10km(0)-1, 0:dim10km(1)-1)
                  lat_5km(iloop_ismfilename_real*dim5km(0):(iloop_ismfilename_real+1)*dim5km(0)-1, :) = \
                  c->Latitude(0:dim5km(0)-1, 0:dim5km(1)-1)
                  lon_5km(iloop_ismfilename_real*dim5km(0):(iloop_ismfilename_real+1)*dim5km(0)-1, :) = \
                  c->Longitude(0:dim5km(0)-1, 0:dim5km(1)-1)
                  Cloud_Optical_Thickness    = c->Cloud_Optical_Thickness(0:dim1km(0)-1, 0:dim1km(1)-1)
                  Cloud_Effective_Radius     = c->Cloud_Effective_Radius(0:dim1km(0)-1, 0:dim1km(1)-1)
                  Cloud_Water_Path           = c->Cloud_Water_Path(0:dim1km(0)-1, 0:dim1km(1)-1)
                  Effective_Optical_Depth_Best_Ocean = b->Effective_Optical_Depth_Best_Ocean(1, 0:dim10km(0)-1, 0:dim10km(1)-1)
                  Angstrom_Exponent_1_Ocean          = b->Angstrom_Exponent_1_Ocean(0, 0:dim10km(0)-1, 0:dim10km(1)-1)
                  Cloud_Top_Pressure                 = c->Cloud_Top_Pressure(0:dim5km(0)-1, 0:dim5km(1)-1)
                  Cloud_Fraction                     = c->Cloud_Fraction(0:dim5km(0)-1, 0:dim5km(1)-1)
                  m1kmCloud_Optical_Thickness    = doubletofloat(Cloud_Optical_Thickness@scale_factor*\
                                                                (Cloud_Optical_Thickness + \
                                                                 Cloud_Optical_Thickness@add_offset))
                  m1kmCloud_Effective_Radius     = doubletofloat(Cloud_Effective_Radius@scale_factor*\
                                                                (Cloud_Effective_Radius + \
                                                                 Cloud_Effective_Radius@add_offset))
                  m1kmCloud_Water_Path           = doubletofloat(Cloud_Water_Path@scale_factor*\
                                                                 Cloud_Water_Path + \
                                                                 Cloud_Water_Path@add_offset)
                  m10kmEffective_Optical_Depth_Best_Ocean = doubletofloat(Effective_Optical_Depth_Best_Ocean@scale_factor*\
                                                                 Effective_Optical_Depth_Best_Ocean + \
                                                                 Effective_Optical_Depth_Best_Ocean@add_offset)
                  m10kmAngstrom_Exponent_1_Ocean = doubletofloat(Angstrom_Exponent_1_Ocean@scale_factor*\
                                                                 Angstrom_Exponent_1_Ocean + \
                                                                 Angstrom_Exponent_1_Ocean@add_offset)
                  m5kmCloud_Top_Pressure         = doubletofloat(Cloud_Top_Pressure@scale_factor*\
                                                                 Cloud_Top_Pressure + \
                                                                 Cloud_Top_Pressure@add_offset)
                  m5kmCloud_Fraction             = doubletofloat(Cloud_Fraction@scale_factor*\
                                                                 Cloud_Fraction + \
                                                                 Cloud_Fraction@add_offset)
;print(Effective_Optical_Depth_Best_Ocean)
;printVarSummary(Effective_Optical_Depth_Best_Ocean)
;printVarSummary(m10kmEffective_Optical_Depth_Best_Ocean)
;printMinMax(m1kmCloud_Optical_Thickness, 0)
;printMinMax(m1kmCloud_Effective_Radius, 0)
;printMinMax(m1kmCloud_Water_Path, 0)
;printMinMax(m10kmEffective_Optical_Depth_Best_Ocean, 0)
;printMinMax(m10kmAngstrom_Exponent_1_Ocean, 0)
;printMinMax(m5kmCloud_Top_Pressure, 0)
;printMinMax(m5kmCloud_Fraction, 0)
                  modis_1km(0, iloop_ismfilename_real*dim1km(0):(iloop_ismfilename_real+1)*dim1km(0)-1, :) = \
                  m1kmCloud_Optical_Thickness
                  modis_1km(1, iloop_ismfilename_real*dim1km(0):(iloop_ismfilename_real+1)*dim1km(0)-1, :) = \
                  m1kmCloud_Water_Path
                  modis_1km(2, iloop_ismfilename_real*dim1km(0):(iloop_ismfilename_real+1)*dim1km(0)-1, :) = \
                  m1kmCloud_Effective_Radius
                  modis_10km(0, iloop_ismfilename_real*dim10km(0):(iloop_ismfilename_real+1)*dim10km(0)-1, :) = \
                  m10kmEffective_Optical_Depth_Best_Ocean
                  modis_10km(1, iloop_ismfilename_real*dim10km(0):(iloop_ismfilename_real+1)*dim10km(0)-1, :) = \
                  m10kmAngstrom_Exponent_1_Ocean
                  modis_5km(0, iloop_ismfilename_real*dim5km(0):(iloop_ismfilename_real+1)*dim5km(0)-1, :) = \
                  m5kmCloud_Top_Pressure
                  modis_5km(1, iloop_ismfilename_real*dim5km(0):(iloop_ismfilename_real+1)*dim5km(0)-1, :) = \
                  m5kmCloud_Fraction
                  iloop_ismfilename_real = iloop_ismfilename_real + 1
               end do ;ismfilename_real

;  DEFINE ARRAY FOR SUBROUTINE pixel_to_grid_ESMF.ncl
               modis_1km_grid  = new((/n1km,  nlat, nlon/), float, bv2)
               modis_10km_grid = new((/n10km, nlat, nlon/), float, bv2)
               modis_5km_grid  = new((/n5km,  nlat, nlon/), float, bv2)
;  CALL SUBROUTINE pixel_to_grid_ESMF.ncl TO GRID THE PIXEL LEVEL DATA INTO
;  GRIDDED LEVEL DATA
               pixel_to_grid_ESMF                                      \
               (bv2, lat_1km, lon_1km, minlat, maxlat, minlon, maxlon, \
               lat_grid_size, lon_grid_size, modis_1km, modis_1km_grid)
;  CALL SUBROUTINE pixel_to_grid_ESMF.ncl TO GRID THE PIXEL LEVEL DATA INTO
;  GRIDDED LEVEL DATA
               pixel_to_grid_ESMF                                        \
               (bv2, lat_10km, lon_10km, minlat, maxlat, minlon, maxlon, \
               lat_grid_size, lon_grid_size, modis_10km, modis_10km_grid)
;  CALL SUBROUTINE pixel_to_grid_ESMF.ncl TO GRID THE PIXEL LEVEL DATA INTO
;  GRIDDED LEVEL DATA
               pixel_to_grid_ESMF                                      \
               (bv2, lat_5km, lon_5km, minlat, maxlat, minlon, maxlon, \
               lat_grid_size, lon_grid_size, modis_5km, modis_5km_grid)
               delete([/lat1km,   lat10km,  lat5km,     \
                        lat_1km,  lon_1km,  modis_1km,  \
                        lat_10km, lon_10km, modis_10km, \
                        lat_5km,  lon_5km,  modis_5km/])

;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;  PUT ALL THE MODIS DATA INO ONE ARRAY
;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
            nvariable               = 7
            dim_modis_grid_all      = (/nvariable, nlat, nlon/)
            modis_grid_all          = new(dim_modis_grid_all, float, bv2)
            modis_grid_all(0, :, :) = modis_1km_grid(0, :, :)
            modis_grid_all(1, :, :) = modis_1km_grid(1, :, :)
            modis_grid_all(2, :, :) = modis_1km_grid(2, :, :)
            modis_grid_all(3, :, :) = modis_10km_grid(0, :, :)
            modis_grid_all(4, :, :) = modis_10km_grid(1, :, :)
            modis_grid_all(5, :, :) = modis_5km_grid(0, :, :)
            modis_grid_all(6, :, :) = modis_5km_grid(1, :, :)

;printMinMax(modis_grid_all(0, :, :), 0)
;printMinMax(modis_grid_all(1, :, :), 0)
;printMinMax(modis_grid_all(2, :, :), 0)
;printMinMax(modis_grid_all(3, :, :), 0)
;printMinMax(modis_grid_all(4, :, :), 0)
;printMinMax(modis_grid_all(5, :, :), 0)
;printMinMax(modis_grid_all(6, :, :), 0)
;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;  READ CALIPSO DATA
;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
            nelement_write          = 28
            ncount_write            = 100
            ncount_write_day        = ncount_write*nctrack
            dim_write_day           = (/ncase, ncount_write_day, nelement_write/)
            wmodis_grid_all         = new(dim_write_day, float, bv2)

;  READ VARIABLES FROM CAL_LID_L2_05kmALay-Prov-V3 AND CAL_LID_L2_05kmCLay-Prov-V3
            if (logic_sacfilename_region .and. logic_sccfilename_region) then
               if (nactrack_real .eq. ncctrack_real) then
;  DEFINE ARRAY TO COLLECT ALL THE LATITUDE AND LONGITUDE
                  if (isdefined("clat_day") .and. isdefined("clon_day")) then
                     delete([/clat_day, clon_day/])
                  end if
                  npixel                   = 4001
                  clat_day                 = new((/npixel, nactrack_real/), float, bv2)
                  clon_day                 = new((/npixel, nactrack_real/), float, bv2)
;  DEFINE ARRAY TO COLLECT ALL THE SEVIRI DATA FOR ONE DAY
                  do ictrack_real = 0, nactrack_real-1
                     a = addfile(acdir + siyear + "/" + sacfilename_region(ictrack_real), "r")
                     b = addfile(ccdir + siyear + "/" + sccfilename_region(ictrack_real), "r")
                     clat                  = a->Latitude
                     clon                  = a->Longitude
                     cColumn_Optical_Depth_Cloud_532     = a->Column_Optical_Depth_Cloud_532(:, 0)
                     aColumn_Optical_Depth_Aerosols_532  = a->Column_Optical_Depth_Aerosols_532(:, 0)
                     aColumn_Optical_Depth_Aerosols_1064 = a->Column_Optical_Depth_Aerosols_1064(:, 0)
                     aLayer_Top_Altitude   = a->Layer_Top_Altitude
                     aLayer_Base_Altitude  = a->Layer_Base_Altitude
                     aLayer_Top_Pressure   = a->Layer_Top_Pressure
                     aMidlayer_Pressure    = a->Midlayer_Pressure
                     aLayer_Base_Pressure  = a->Layer_Base_Pressure
                     aLayer_Top_Temperature= a->Layer_Top_Temperature
                     aMidlayer_Temperature = a->Midlayer_Temperature
                     aLayer_Base_Temperature=a->Layer_Base_Temperature
                     aNumber_Layers_Found  = a->Number_Layers_Found
                     cLayer_Top_Altitude   = b->Layer_Top_Altitude
                     cLayer_Base_Altitude  = b->Layer_Base_Altitude
                     cLayer_Top_Pressure   = b->Layer_Top_Pressure
                     cMidlayer_Pressure    = b->Midlayer_Pressure
                     cLayer_Base_Pressure  = b->Layer_Base_Pressure
                     cLayer_Top_Temperature= b->Layer_Top_Temperature
                     cMidlayer_Temperature = b->Midlayer_Temperature
                     cLayer_Base_Temperature=b->Layer_Base_Temperature
                     cNumber_Layers_Found  = b->Number_Layers_Found
                     dim_aba               = dimsizes(aLayer_Base_Altitude)
                     npts                  = dim_aba(0)
                     clat@_FillValue       = bv2
                     clon@_FillValue       = bv2
                     clat_day(0:npts-1, ictrack_real) = clat(0:npts-1, 1)
                     clon_day(0:npts-1, ictrack_real) = clon(0:npts-1, 1)
                     acLayer_Top_Altitude   = new((/npts/), float, bv2)
                     acLayer_Base_Altitude  = new((/npts/), float, bv2)
                     acLayer_Top_Pressure   = new((/npts/), float, bv2)
                     acMidlayer_Pressure    = new((/npts/), float, bv2)
                     acLayer_Base_Pressure  = new((/npts/), float, bv2)
                     acLayer_Top_Temperature= new((/npts/), float, bv2)
                     acMidlayer_Temperature = new((/npts/), float, bv2)
                     acLayer_Base_Temperature=new((/npts/), float, bv2)
                     ccLayer_Top_Altitude   = new((/npts/), float, bv2)
                     ccLayer_Base_Altitude  = new((/npts/), float, bv2)
                     ccLayer_Top_Pressure   = new((/npts/), float, bv2)
                     ccMidlayer_Pressure    = new((/npts/), float, bv2)
                     ccLayer_Base_Pressure  = new((/npts/), float, bv2)
                     ccLayer_Top_Temperature= new((/npts/), float, bv2)
                     ccMidlayer_Temperature = new((/npts/), float, bv2)
                     ccLayer_Base_Temperature=new((/npts/), float, bv2)
;  CALL SUBROUTINE select_aca_aba_cloud_cta_var.ncl TO GET REAL ONE LAYER acLayer_Base_Altitude 
;  AND ccLayer_Top_Altitude
                     select_aca_aba_cloud_cta_var \
                     (aLayer_Top_Altitude, aLayer_Base_Altitude, aLayer_Top_Pressure,       \
                      aMidlayer_Pressure, aLayer_Base_Pressure, aLayer_Top_Temperature,     \
                      aMidlayer_Temperature, aLayer_Base_Temperature, aNumber_Layers_Found, \
                      cLayer_Top_Altitude, cLayer_Base_Altitude, cLayer_Top_Pressure,       \
                      cMidlayer_Pressure, cLayer_Base_Pressure, cLayer_Top_Temperature,     \
                      cMidlayer_Temperature, cLayer_Base_Temperature, cNumber_Layers_Found, \
                      acLayer_Top_Altitude, acLayer_Base_Altitude, acLayer_Top_Pressure,    \
                      acMidlayer_Pressure, acLayer_Base_Pressure, acLayer_Top_Temperature,  \
                      acMidlayer_Temperature, acLayer_Base_Temperature,                     \
                      ccLayer_Top_Altitude, ccLayer_Base_Altitude, ccLayer_Top_Pressure,    \
                      ccMidlayer_Pressure, ccLayer_Base_Pressure, ccLayer_Top_Temperature,  \
                      ccMidlayer_Temperature, ccLayer_Base_Temperature)
;  CALL SUBROUTINE select_modis_calipso_aca_cloud_costantino2013_write_all_28var.ncl TO DISTINGUISH 
;  ACA AND CLOUD AS TOUCH AND UNTOUCH
                     select_modis_calipso_aca_cloud_costantino2013_write_all_28var            \
                     (bv2, nvariable, nelement_write, ictrack_real, ncount_write,             \
                     clat, clon, lat_grid_1d, lon_grid_1d, lat_grid_size, lon_grid_size,      \
                     nlat, nlon, minlat, maxlat, minlon, maxlon, iday_or_night,               \
                     cColumn_Optical_Depth_Cloud_532, aColumn_Optical_Depth_Aerosols_532,     \
                     aColumn_Optical_Depth_Aerosols_1064, acLayer_Top_Altitude,               \
                     acLayer_Base_Altitude, acLayer_Top_Pressure, acMidlayer_Pressure,        \
                     acLayer_Base_Pressure, acLayer_Top_Temperature,                          \
                     acMidlayer_Temperature, acLayer_Base_Temperature, ccLayer_Top_Altitude,  \
                     ccLayer_Base_Altitude, ccLayer_Top_Pressure, ccMidlayer_Pressure,        \
                     ccLayer_Base_Pressure, ccLayer_Top_Temperature, ccMidlayer_Temperature,  \
                     ccLayer_Base_Temperature, modis_grid_all, wmodis_grid_all)
                     delete([/clat, clon, \
                              cColumn_Optical_Depth_Cloud_532, aColumn_Optical_Depth_Aerosols_532,  \
                              aColumn_Optical_Depth_Aerosols_1064,                                  \
                              aLayer_Top_Altitude, aLayer_Base_Altitude, aLayer_Top_Pressure,       \
                              aMidlayer_Pressure, aLayer_Base_Pressure, aLayer_Top_Temperature,     \
                              aMidlayer_Temperature, aLayer_Base_Temperature, aNumber_Layers_Found, \
                              cLayer_Top_Altitude, cLayer_Base_Altitude, cLayer_Top_Pressure,       \
                              cMidlayer_Pressure, cLayer_Base_Pressure, cLayer_Top_Temperature,     \
                              cMidlayer_Temperature, cLayer_Base_Temperature, cNumber_Layers_Found, \
                              acLayer_Top_Altitude, acLayer_Base_Altitude, acLayer_Top_Pressure,    \
                              acMidlayer_Pressure, acLayer_Base_Pressure, acLayer_Top_Temperature,  \
                              acMidlayer_Temperature, acLayer_Base_Temperature,                     \
                              ccLayer_Top_Altitude, ccLayer_Base_Altitude, ccLayer_Top_Pressure,    \
                              ccMidlayer_Pressure, ccLayer_Base_Pressure, ccLayer_Top_Temperature,  \
                              ccMidlayer_Temperature, ccLayer_Base_Temperature/])

                  end do ;ictrack_real
               else
                  print("ERROR: CAL_LID_L2_05kmALay-Prov-V3 and CAL_LID_L2_05kmCLay-Prov-V3 don't match")
               end if
            else
               print("NO CALIPSO FILE IN THE STUDY REGION ON " + symd1)
            end if

;  !!!THIS PART JUST FOR WRITING FILE QUICKLY!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;  @@@WRITE VARIABLES INTO A FILE@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
            fmt        = nelement_write + "f10.3"
            datatitle  = "Latitude "                           + \
                         "Longitude "                          + \
                         "Cloud_Optical_Thickness "            + \
                         "Cloud_Water_Path "                   + \
                         "Cloud_Effective_Radius "             + \
                         "Effective_Optical_Depth_Best_Ocean " + \
                         "Angstrom_Exponent_1_Ocean "          + \
                         "Cloud_Top_Pressure "                 + \
                         "Cloud_Fraction "                     + \
                         "Column_Optical_Depth_Cloud_532 "     + \
                         "Column_Optical_Depth_Aerosols_532 "  + \
                         "Column_Optical_Depth_Aerosols_1064 " + \
                         "Aerosol_Layer_Top_Altitude "         + \
                         "Aerosol_Layer_Base_Altitude "        + \
                         "Aerosol_Layer_Top_Pressure "         + \
                         "Aerosol_Midlayer_Pressure "          + \
                         "Aerosol_Layer_Base_Pressure "        + \
                         "Aerosol_Layer_Top_Temperature "      + \
                         "Aerosol_Midlayer_Temperature "       + \
                         "Aerosol_Layer_Base_Temperature "     + \
                         "Cloud_Layer_Top_Altitude "           + \
                         "Cloud_Layer_Base_Altitude "          + \
                         "Cloud_Layer_Top_Pressure "           + \
                         "Cloud_Midlayer_Pressure "            + \
                         "Cloud_Layer_Base_Pressure "          + \
                         "Cloud_Layer_Top_Temperature "        + \
                         "Cloud_Midlayer_Temperature "         + \
                         "Cloud_Layer_Base_Temperature "
            opt        = True
            opt@title  = datatitle
               do icase = 0, ncase-1
                  if (.not.all(ismissing(wmodis_grid_all(icase, :, :)))) then
                     opt@fout = plot_dir + case(icase) + "_" + \
                                sday_or_night(iday_or_night) + "_" + symd1 + ".txt"
                     write_matrix(wmodis_grid_all(icase, :, :), fmt, opt)
                  else
                     continue
                  end if
               end do ;icase

            end do ;iday_or_night
         end do ;iday
      end do ;imonth
   end do ;iyear
end
