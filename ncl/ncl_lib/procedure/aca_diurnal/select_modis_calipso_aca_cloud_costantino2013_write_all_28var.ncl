;  $ID: select_modis_calipso_aca_cloud_costantino2013_write_all_28var.ncl V01 07/01/2015 23:52 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE select_modis_calipso_aca_cloud_costantino2013_write_28all_var SELECTS ALL 
;  THE MODIS GRIDS WITH THE RELATIVE VERTICAL POSITION OF AEROSOL AND CLOUD.
;  WHICH INCLUDES TOUCH AND UNTOUCH.
;  L : DISTANCE BETWEEN CLOUD TOP ALTITUDE AND AEROSOL BASE ALTITUDE.
;  (a ) touch : L<100m;
;  (b ) uncertain : 100m<L<750m;
;  (c ) untouch : L>750m.
;  THE DISTINGUISHING METHOD USED HERE IS FROM THE FOLLOWING REFERENCES:
;  (1 ) Costantino, L. and Bréon, F.-M.: Aerosol indirect effect on warm clouds 
;       over South-East Atlantic, from co-located MODIS and CALIPSO observations, 
;       Atmos. Chem. Phys., 13, 69-88, doi:10.5194/acp-13-69-2013, 2013.
;
;  HOWEVER, IN THE PAPER OF (Costantino, 2010, GRL), THE METHOD IS:
;  (a ) touch : L<250m;
;  (b ) untouch : L>250m.
;  REFERENCE:
;  (1 ) Costantino, L. and Br ́ on, F.-M.: Analysis of aerosol-cloud interaction 
;       from multi-sensor satellite observations, Geophys. Res. Lett., 37, 
;       L11801, doi:10.1029/2009GL041828, 2010.
;
;  THIS PROCEDURE ONLY CONSIDERS THE FIRST METHOD (Costantino, 2013).
;  VARIABLES:
;  ============================================================================
;  (1 ) clat     (2-D):LATITUDE OF A CALIPSO GROUND TRACK                 [DEG]
;  (2 ) clon     (2-D):LONGITUDE OF A CALIPSO GROUND TRACK                [DEG]
;  (3 ) lat      (1-D):LATITUDE GRIDS FOR MODIS DATA                      [DEG]
;  (4 ) lon      (1-D):LONGITUDE GRIDS FOR MODIS DATA                     [DEG]
;  (5 ) minlat (scalar):MINIMUM LATITUDE IN THE STUDY REGION              [DEG]
;  (6 ) maxlat (scalar):MAXIMUM LATITUDE IN THE STUDY REGION              [DEG]
;  (7 ) minlon (scalar):MINIMUM LONGITUDE IN THE STUDY REGION             [DEG]
;  (8 ) maxlon (scalar):MAXIMUM LONGITUDE IN THE STUDY REGION             [DEG]
;  (9 ) iday_or_night(scalar):SCALAR TO DETERMINE DAY TIME OR NIGHT TIME  [   ]
;  (10) alay_base_altitude (1-D):AEROSOL BASE LAYER ALTITUDE              [KM ]
;  (11) clay_top_altitude  (1-D):CLOUD TOP LAYER ALTITUDE                 [KM ]
;  (12) modis_data_day     (2-D):MODIS DATA                               [   ]
;  (13) wmodis_data_all_day(2-D):WRITE DATA INCLUDING ALL THE CASES       [   ]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE REFERING THE REFERENCES MENTIONED ABOVE.
;       (06/22/2015)
;  (2 ) MODIFIED FROM select_amsre_calipso_aca_cloud_costantino2013_write.ncl
;       (06/30/2015)
;  (3 ) MODIFIED FROM select_seviri_calipso_aca_cloud_costantino2013_write.ncl
;       BY REDUCING THE # OF OUTPUT VARIABLES. (BRUCE, 07/01/2015)
;******************************************************************************
undef("select_modis_calipso_aca_cloud_costantino2013_write_all_28var")
procedure select_modis_calipso_aca_cloud_costantino2013_write_all_28var \
          (bv2                 :float,                                  \;INPUT
           nvariable           :integer, nelement_write        :integer,\;INPUT
           ictrack_real        :integer, ncount_write          :integer,\;INPUT
           clat                :float,   clon                  :float,  \;INPUT
           lat                 :float,   lon                   :float,  \;INPUT
           lat_grid_size       :float,   lon_grid_size         :float,  \;INPUT
           nlat                :integer, nlon                  :integer,\;INPUT
           minlat              :float,   maxlat                :float,  \;INPUT
           minlon              :float,   maxlon                :float,  \;INPUT
           iday_or_night       :integer,                                \;INPUT
           cColumn_Optical_Depth_Cloud_532     :float,                  \;INPUT
           aColumn_Optical_Depth_Aerosols_532  :float,                  \;INPUT
           aColumn_Optical_Depth_Aerosols_1064 :float,                  \;INPUT
           aLayer_Top_Altitude :float,   aLayer_Base_Altitude:float,    \;INPUT
           aLayer_Top_Pressure :float,   aMidlayer_Pressure  :float,    \;INPUT
           aLayer_Base_Pressure:float,   aLayer_Top_Temperature:float,  \;INPUT
           aMidlayer_Temperature:float,  aLayer_Base_Temperature:float, \;INPUT
           cLayer_Top_Altitude :float,   cLayer_Base_Altitude :float,   \;INPUT
           cLayer_Top_Pressure :float,   cMidlayer_Pressure   :float,   \;INPUT
           cLayer_Base_Pressure:float,   cLayer_Top_Temperature:float,  \;INPUT
           cMidlayer_Temperature:float,  cLayer_Base_Temperature:float, \;INPUT
           modis_data_day      :numeric,                               \;INPUT
           wmodis_data_all_day :numeric)                                ;OUTPUT

begin

   dim_3d                 = (/nvariable, nlat, nlon/)
   dim_write              = (/ncount_write, nelement_write/)
   modis_data_all        = new(dim_3d,    float, bv2)
   modis_data_untouch    = new(dim_3d,    float, bv2)
   modis_data_touch      = new(dim_3d,    float, bv2)
   modis_data_uncertain  = new(dim_3d,    float, bv2)
   modis_data_noaca      = new(dim_3d,    float, bv2)
   wmodis_data_all       = new(dim_write, float, bv2)
   wmodis_data_untouch   = new(dim_write, float, bv2)
   wmodis_data_touch     = new(dim_write, float, bv2)
   wmodis_data_uncertain = new(dim_write, float, bv2)
   wmodis_data_noaca     = new(dim_write, float, bv2)

;  GET THE NADIR LATITUDE AND LONGITUDE FROM CALIPSO TRACK
   clat_nadir = clat(:, 1)
   clon_nadir = clon(:, 1)

;  CALCULATE THE DISTANCE BETWEEN ACA BASE AND CLOUD TOP
   aclayer_altitude_diff = aLayer_Base_Altitude - cLayer_Top_Altitude

;  SELECT MODIS DATA IN THE STUDY REGION
   index_lat = ind(lat .ge. minlat .and. \
                   lat .le. maxlat)
   index_lon = ind(lon .ge. minlon .and. \
                   lon .le. maxlon)
   if (.not.all(ismissing(index_lat)) .and.\
       .not.all(ismissing(index_lon))) then
      nindex_lat = dimsizes(index_lat)
      nindex_lon = dimsizes(index_lon)
;  DO LOOP FOR MODIS LATITUDE AND LONGITUDE TO SELECT MODIS GRIDS HAVING 
;  ACA AND CLOUD RELATIVE VERTICAL POSITION
;  PLEASE NOTE: LATITUDE AND LONGITUDE FROM MODIS ARE FOR THE GRID CENTER
      icount_all       = 0
      icount_untouch   = 0
      icount_touch     = 0
      icount_uncertain = 0
      icount_noaca     = 0
      do i = 0, nindex_lat-1
         do j = 0, nindex_lon-1
;  INDEX FOR ACA
            index_clatlon_nadir = ind(clat_nadir .ge. lat(index_lat(i))-lat_grid_size/2.      .and. \
                                      clat_nadir .le. lat(index_lat(i))+lat_grid_size/2.      .and. \
                                      clon_nadir .ge. lon(index_lon(j))-lon_grid_size/2.      .and. \
                                      clon_nadir .le. lon(index_lon(j))+lon_grid_size/2.      .and. \
                                      aclayer_altitude_diff .gt. 0.0                          .and. \
                                      modis_data_day(0, index_lat(i), index_lon(j)) .ge. 5.0  .and. \
                                      modis_data_day(0, index_lat(i), index_lon(j)) .le. 35.0 .and. \
                                      modis_data_day(2, index_lat(i), index_lon(j)) .le. 300.0)
            if (.not.all(ismissing(index_clatlon_nadir))) then
               modis_data_all(:, index_lat(i), index_lon(j)) = \
               (/modis_data_day(:, index_lat(i), index_lon(j))/)
               num_untouch   = num(aclayer_altitude_diff(index_clatlon_nadir) .ge. 0.75)
               num_touch     = num(aclayer_altitude_diff(index_clatlon_nadir) .le. 0.10 .and. \
                                   aclayer_altitude_diff(index_clatlon_nadir) .ge. 0.0)
               num_uncertain = num(aclayer_altitude_diff(index_clatlon_nadir) .le. 0.75 .and. \
                                   aclayer_altitude_diff(index_clatlon_nadir) .ge. 0.10)
;  @@@PREPARE DATA FOR PUTTING THEM INTO AN ARRAY@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
               wmodis_data_all(icount_all, 0) = (/lat(index_lat(i))/)
               wmodis_data_all(icount_all, 1) = (/lon(index_lon(j))/)
               wmodis_data_all(icount_all, 2:8) = modis_data_day(0:6, index_lat(i), index_lon(j))
               if (.not.all(ismissing(cColumn_Optical_Depth_Cloud_532(index_clatlon_nadir)))) then
                  wmodis_data_all(icount_all,9) = avg(cColumn_Optical_Depth_Cloud_532(index_clatlon_nadir))
               end if
               if (.not.all(ismissing(aColumn_Optical_Depth_Aerosols_532(index_clatlon_nadir)))) then
                  wmodis_data_all(icount_all,10) = avg(aColumn_Optical_Depth_Aerosols_532(index_clatlon_nadir))
               end if
               if (.not.all(ismissing(aColumn_Optical_Depth_Aerosols_1064(index_clatlon_nadir)))) then
                  wmodis_data_all(icount_all,11) = avg(aColumn_Optical_Depth_Aerosols_1064(index_clatlon_nadir))
               end if
               if (.not.all(ismissing(aLayer_Top_Altitude(index_clatlon_nadir)))) then
                  wmodis_data_all(icount_all,12) = avg(aLayer_Top_Altitude(index_clatlon_nadir))
               end if
               if (.not.all(ismissing(aLayer_Base_Altitude(index_clatlon_nadir)))) then
                  wmodis_data_all(icount_all,13) = avg(aLayer_Base_Altitude(index_clatlon_nadir))
               end if
               if (.not.all(ismissing(aLayer_Top_Pressure(index_clatlon_nadir)))) then
                  wmodis_data_all(icount_all,14) = avg(aLayer_Top_Pressure(index_clatlon_nadir))
               end if
               if (.not.all(ismissing(aMidlayer_Pressure(index_clatlon_nadir)))) then
                  wmodis_data_all(icount_all,15) = avg(aMidlayer_Pressure(index_clatlon_nadir))
               end if
               if (.not.all(ismissing(aLayer_Base_Pressure(index_clatlon_nadir)))) then
                  wmodis_data_all(icount_all,16) = avg(aLayer_Base_Pressure(index_clatlon_nadir))
               end if
               if (.not.all(ismissing(aLayer_Top_Temperature(index_clatlon_nadir)))) then
                  wmodis_data_all(icount_all,17) = avg(aLayer_Top_Temperature(index_clatlon_nadir))
               end if
               if (.not.all(ismissing(aMidlayer_Temperature(index_clatlon_nadir)))) then
                  wmodis_data_all(icount_all,18) = avg(aMidlayer_Temperature(index_clatlon_nadir))
               end if
               if (.not.all(ismissing(aLayer_Base_Temperature(index_clatlon_nadir)))) then
                  wmodis_data_all(icount_all,19) = avg(aLayer_Base_Temperature(index_clatlon_nadir))
               end if
               if (.not.all(ismissing(cLayer_Top_Altitude(index_clatlon_nadir)))) then
                  wmodis_data_all(icount_all,20) = avg(cLayer_Top_Altitude(index_clatlon_nadir))
               end if
               if (.not.all(ismissing(cLayer_Base_Altitude(index_clatlon_nadir)))) then
                  wmodis_data_all(icount_all,21) = avg(cLayer_Base_Altitude(index_clatlon_nadir))
               end if
               if (.not.all(ismissing(cLayer_Top_Pressure(index_clatlon_nadir)))) then
                  wmodis_data_all(icount_all,22) = avg(cLayer_Top_Pressure(index_clatlon_nadir))
               end if
               if (.not.all(ismissing(cMidlayer_Pressure(index_clatlon_nadir)))) then
                  wmodis_data_all(icount_all,23) = avg(cMidlayer_Pressure(index_clatlon_nadir))
               end if
               if (.not.all(ismissing(cLayer_Base_Pressure(index_clatlon_nadir)))) then
                  wmodis_data_all(icount_all,24) = avg(cLayer_Base_Pressure(index_clatlon_nadir))
               end if
               if (.not.all(ismissing(cLayer_Top_Temperature(index_clatlon_nadir)))) then
                  wmodis_data_all(icount_all,25) = avg(cLayer_Top_Temperature(index_clatlon_nadir))
               end if
               if (.not.all(ismissing(cMidlayer_Temperature(index_clatlon_nadir)))) then
                  wmodis_data_all(icount_all,26) = avg(cMidlayer_Temperature(index_clatlon_nadir))
               end if
               if (.not.all(ismissing(cLayer_Base_Temperature(index_clatlon_nadir)))) then
                  wmodis_data_all(icount_all,27) = avg(cLayer_Base_Temperature(index_clatlon_nadir))
               end if

               if (num_untouch .gt. num_touch .and. \
                   num_untouch .gt. num_uncertain) then
                  index_untouch = ind(aclayer_altitude_diff(index_clatlon_nadir) .ge. 0.75)
                  if (.not.all(ismissing(index_untouch))) then
                     index_untouch = index_clatlon_nadir(index_untouch)
;  CONSIDER THIS MODIS GRID BOX AS ACA AND CLOUD UNTOUCH
                     modis_data_untouch(:, index_lat(i), index_lon(j)) = \
                     (/modis_data_day(:, index_lat(i), index_lon(j))/)
;  @@@PREPARE DATA FOR PUTTING THEM INTO AN ARRAY@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
                     wmodis_data_untouch(icount_untouch, 0) = (/lat(index_lat(i))/)
                     wmodis_data_untouch(icount_untouch, 1) = (/lon(index_lon(j))/)
                     wmodis_data_untouch(icount_untouch, 2:8) = modis_data_day(0:6, index_lat(i), index_lon(j))
                     if (.not.all(ismissing(cColumn_Optical_Depth_Cloud_532(index_untouch)))) then
                        wmodis_data_untouch(icount_untouch,9) = avg(cColumn_Optical_Depth_Cloud_532(index_untouch))
                     end if
                     if (.not.all(ismissing(aColumn_Optical_Depth_Aerosols_532(index_untouch)))) then
                        wmodis_data_untouch(icount_untouch,10) = avg(aColumn_Optical_Depth_Aerosols_532(index_untouch))
                     end if
                     if (.not.all(ismissing(aColumn_Optical_Depth_Aerosols_1064(index_untouch)))) then
                        wmodis_data_untouch(icount_untouch,11) = avg(aColumn_Optical_Depth_Aerosols_1064(index_untouch))
                     end if
                     if (.not.all(ismissing(aLayer_Top_Altitude(index_untouch)))) then
                        wmodis_data_untouch(icount_untouch,12) = avg(aLayer_Top_Altitude(index_untouch))
                     end if
                     if (.not.all(ismissing(aLayer_Base_Altitude(index_untouch)))) then
                        wmodis_data_untouch(icount_untouch,13) = avg(aLayer_Base_Altitude(index_untouch))
                     end if
                     if (.not.all(ismissing(aLayer_Top_Pressure(index_untouch)))) then
                        wmodis_data_untouch(icount_untouch,14) = avg(aLayer_Top_Pressure(index_untouch))
                     end if
                     if (.not.all(ismissing(aMidlayer_Pressure(index_untouch)))) then
                        wmodis_data_untouch(icount_untouch,15) = avg(aMidlayer_Pressure(index_untouch))
                     end if
                     if (.not.all(ismissing(aLayer_Base_Pressure(index_untouch)))) then
                        wmodis_data_untouch(icount_untouch,16) = avg(aLayer_Base_Pressure(index_untouch))
                     end if
                     if (.not.all(ismissing(aLayer_Top_Temperature(index_untouch)))) then
                        wmodis_data_untouch(icount_untouch,17) = avg(aLayer_Top_Temperature(index_untouch))
                     end if
                     if (.not.all(ismissing(aMidlayer_Temperature(index_untouch)))) then
                        wmodis_data_untouch(icount_untouch,18) = avg(aMidlayer_Temperature(index_untouch))
                     end if
                     if (.not.all(ismissing(aLayer_Base_Temperature(index_untouch)))) then
                        wmodis_data_untouch(icount_untouch,19) = avg(aLayer_Base_Temperature(index_untouch))
                     end if
                     if (.not.all(ismissing(cLayer_Top_Altitude(index_untouch)))) then
                        wmodis_data_untouch(icount_untouch,20) = avg(cLayer_Top_Altitude(index_untouch))
                     end if
                     if (.not.all(ismissing(cLayer_Base_Altitude(index_untouch)))) then
                        wmodis_data_untouch(icount_untouch,21) = avg(cLayer_Base_Altitude(index_untouch))
                     end if
                     if (.not.all(ismissing(cLayer_Top_Pressure(index_untouch)))) then
                        wmodis_data_untouch(icount_untouch,22) = avg(cLayer_Top_Pressure(index_untouch))
                     end if
                     if (.not.all(ismissing(cMidlayer_Pressure(index_untouch)))) then
                        wmodis_data_untouch(icount_untouch,23) = avg(cMidlayer_Pressure(index_untouch))
                     end if
                     if (.not.all(ismissing(cLayer_Base_Pressure(index_untouch)))) then
                        wmodis_data_untouch(icount_untouch,24) = avg(cLayer_Base_Pressure(index_untouch))
                     end if
                     if (.not.all(ismissing(cLayer_Top_Temperature(index_untouch)))) then
                        wmodis_data_untouch(icount_untouch,25) = avg(cLayer_Top_Temperature(index_untouch))
                     end if
                     if (.not.all(ismissing(cMidlayer_Temperature(index_untouch)))) then
                        wmodis_data_untouch(icount_untouch,26) = avg(cMidlayer_Temperature(index_untouch))
                     end if
                     if (.not.all(ismissing(cLayer_Base_Temperature(index_untouch)))) then
                        wmodis_data_untouch(icount_untouch,27) = avg(cLayer_Base_Temperature(index_untouch))
                     end if

                  icount_untouch = icount_untouch + 1
                  end if
                  delete([/index_untouch/])
               else if (num_touch .gt. num_untouch .and. \
                        num_touch .gt. num_uncertain) then
                  index_touch = ind(aclayer_altitude_diff(index_clatlon_nadir) .le. 0.10 .and. \
                                    aclayer_altitude_diff(index_clatlon_nadir) .ge. 0.0)
                  if (.not.all(ismissing(index_touch))) then
                     index_touch = index_clatlon_nadir(index_touch)
;  CONSIDER THIS modis GRID BOX AS ACA AND CLOUD TOUCH
                     modis_data_touch(:, index_lat(i), index_lon(j)) = \
                     (/modis_data_day(:, index_lat(i), index_lon(j))/)
;  @@@PREPARE DATA FOR PUTTING THEM INTO AN ARRAY@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
                     wmodis_data_touch(icount_touch, 0) = (/lat(index_lat(i))/)
                     wmodis_data_touch(icount_touch, 1) = (/lon(index_lon(j))/)
                     wmodis_data_touch(icount_touch, 2:8) = modis_data_day(0:6, index_lat(i), index_lon(j))
                     if (.not.all(ismissing(cColumn_Optical_Depth_Cloud_532(index_touch)))) then
                        wmodis_data_touch(icount_touch,9) = avg(cColumn_Optical_Depth_Cloud_532(index_touch))
                     end if
                     if (.not.all(ismissing(aColumn_Optical_Depth_Aerosols_532(index_touch)))) then
                        wmodis_data_touch(icount_touch,10) = avg(aColumn_Optical_Depth_Aerosols_532(index_touch))
                     end if
                     if (.not.all(ismissing(aColumn_Optical_Depth_Aerosols_1064(index_touch)))) then
                        wmodis_data_touch(icount_touch,11) = avg(aColumn_Optical_Depth_Aerosols_1064(index_touch))
                     end if
                     if (.not.all(ismissing(aLayer_Top_Altitude(index_touch)))) then
                        wmodis_data_touch(icount_touch,12) = avg(aLayer_Top_Altitude(index_touch))
                     end if
                     if (.not.all(ismissing(aLayer_Base_Altitude(index_touch)))) then
                        wmodis_data_touch(icount_touch,13) = avg(aLayer_Base_Altitude(index_touch))
                     end if
                     if (.not.all(ismissing(aLayer_Top_Pressure(index_touch)))) then
                        wmodis_data_touch(icount_touch,14) = avg(aLayer_Top_Pressure(index_touch))
                     end if
                     if (.not.all(ismissing(aMidlayer_Pressure(index_touch)))) then
                        wmodis_data_touch(icount_touch,15) = avg(aMidlayer_Pressure(index_touch))
                     end if
                     if (.not.all(ismissing(aLayer_Base_Pressure(index_touch)))) then
                        wmodis_data_touch(icount_touch,16) = avg(aLayer_Base_Pressure(index_touch))
                     end if
                     if (.not.all(ismissing(aLayer_Top_Temperature(index_touch)))) then
                        wmodis_data_touch(icount_touch,17) = avg(aLayer_Top_Temperature(index_touch))
                     end if
                     if (.not.all(ismissing(aMidlayer_Temperature(index_touch)))) then
                        wmodis_data_touch(icount_touch,18) = avg(aMidlayer_Temperature(index_touch))
                     end if
                     if (.not.all(ismissing(aLayer_Base_Temperature(index_touch)))) then
                        wmodis_data_touch(icount_touch,19) = avg(aLayer_Base_Temperature(index_touch))
                     end if
                     if (.not.all(ismissing(cLayer_Top_Altitude(index_touch)))) then
                        wmodis_data_touch(icount_touch,20) = avg(cLayer_Top_Altitude(index_touch))
                     end if
                     if (.not.all(ismissing(cLayer_Base_Altitude(index_touch)))) then
                        wmodis_data_touch(icount_touch,21) = avg(cLayer_Base_Altitude(index_touch))
                     end if
                     if (.not.all(ismissing(cLayer_Top_Pressure(index_touch)))) then
                        wmodis_data_touch(icount_touch,22) = avg(cLayer_Top_Pressure(index_touch))
                     end if
                     if (.not.all(ismissing(cMidlayer_Pressure(index_touch)))) then
                        wmodis_data_touch(icount_touch,23) = avg(cMidlayer_Pressure(index_touch))
                     end if
                     if (.not.all(ismissing(cLayer_Base_Pressure(index_touch)))) then
                        wmodis_data_touch(icount_touch,24) = avg(cLayer_Base_Pressure(index_touch))
                     end if
                     if (.not.all(ismissing(cLayer_Top_Temperature(index_touch)))) then
                        wmodis_data_touch(icount_touch,25) = avg(cLayer_Top_Temperature(index_touch))
                     end if
                     if (.not.all(ismissing(cMidlayer_Temperature(index_touch)))) then
                        wmodis_data_touch(icount_touch,26) = avg(cMidlayer_Temperature(index_touch))
                     end if
                     if (.not.all(ismissing(cLayer_Base_Temperature(index_touch)))) then
                        wmodis_data_touch(icount_touch,27) = avg(cLayer_Base_Temperature(index_touch))
                     end if

                     icount_touch = icount_touch + 1
                  end if
                  delete([/index_touch/])
               else if (num_uncertain .gt. num_untouch .and. \
                        num_uncertain .gt. num_touch) then
                  index_uncertain = ind(aclayer_altitude_diff(index_clatlon_nadir) .le. 0.75 .and. \
                                        aclayer_altitude_diff(index_clatlon_nadir) .ge. 0.10)
                  if (.not.all(ismissing(index_uncertain))) then
                     index_uncertain = index_clatlon_nadir(index_uncertain)
                     modis_data_uncertain(:, index_lat(i), index_lon(j)) = \
                     (/modis_data_day(:, index_lat(i), index_lon(j))/)
;  @@@PREPARE DATA FOR PUTTING THEM INTO AN ARRAY@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
                     wmodis_data_uncertain(icount_uncertain, 0) = (/lat(index_lat(i))/)
                     wmodis_data_uncertain(icount_uncertain, 1) = (/lon(index_lon(j))/)
                     wmodis_data_uncertain(icount_uncertain, 2:8) = modis_data_day(0:6, index_lat(i), index_lon(j))
                     if (.not.all(ismissing(cColumn_Optical_Depth_Cloud_532(index_uncertain)))) then
                        wmodis_data_uncertain(icount_uncertain,9) = avg(cColumn_Optical_Depth_Cloud_532(index_uncertain))
                     end if
                     if (.not.all(ismissing(aColumn_Optical_Depth_Aerosols_532(index_uncertain)))) then
                        wmodis_data_uncertain(icount_uncertain,10) = avg(aColumn_Optical_Depth_Aerosols_532(index_uncertain))
                     end if
                     if (.not.all(ismissing(aColumn_Optical_Depth_Aerosols_1064(index_uncertain)))) then
                        wmodis_data_uncertain(icount_uncertain,11) = avg(aColumn_Optical_Depth_Aerosols_1064(index_uncertain))
                     end if
                     if (.not.all(ismissing(aLayer_Top_Altitude(index_uncertain)))) then
                        wmodis_data_uncertain(icount_uncertain,12) = avg(aLayer_Top_Altitude(index_uncertain))
                     end if
                     if (.not.all(ismissing(aLayer_Base_Altitude(index_uncertain)))) then
                        wmodis_data_uncertain(icount_uncertain,13) = avg(aLayer_Base_Altitude(index_uncertain))
                     end if
                     if (.not.all(ismissing(aLayer_Top_Pressure(index_uncertain)))) then
                        wmodis_data_uncertain(icount_uncertain,14) = avg(aLayer_Top_Pressure(index_uncertain))
                     end if
                     if (.not.all(ismissing(aMidlayer_Pressure(index_uncertain)))) then
                        wmodis_data_uncertain(icount_uncertain,15) = avg(aMidlayer_Pressure(index_uncertain))
                     end if
                     if (.not.all(ismissing(aLayer_Base_Pressure(index_uncertain)))) then
                        wmodis_data_uncertain(icount_uncertain,16) = avg(aLayer_Base_Pressure(index_uncertain))
                     end if
                     if (.not.all(ismissing(aLayer_Top_Temperature(index_uncertain)))) then
                        wmodis_data_uncertain(icount_uncertain,17) = avg(aLayer_Top_Temperature(index_uncertain))
                     end if
                     if (.not.all(ismissing(aMidlayer_Temperature(index_uncertain)))) then
                        wmodis_data_uncertain(icount_uncertain,18) = avg(aMidlayer_Temperature(index_uncertain))
                     end if
                     if (.not.all(ismissing(aLayer_Base_Temperature(index_uncertain)))) then
                        wmodis_data_uncertain(icount_uncertain,19) = avg(aLayer_Base_Temperature(index_uncertain))
                     end if
                     if (.not.all(ismissing(cLayer_Top_Altitude(index_uncertain)))) then
                        wmodis_data_uncertain(icount_uncertain,20) = avg(cLayer_Top_Altitude(index_uncertain))
                     end if
                     if (.not.all(ismissing(cLayer_Base_Altitude(index_uncertain)))) then
                        wmodis_data_uncertain(icount_uncertain,21) = avg(cLayer_Base_Altitude(index_uncertain))
                     end if
                     if (.not.all(ismissing(cLayer_Top_Pressure(index_uncertain)))) then
                        wmodis_data_uncertain(icount_uncertain,22) = avg(cLayer_Top_Pressure(index_uncertain))
                     end if
                     if (.not.all(ismissing(cMidlayer_Pressure(index_uncertain)))) then
                        wmodis_data_uncertain(icount_uncertain,23) = avg(cMidlayer_Pressure(index_uncertain))
                     end if
                     if (.not.all(ismissing(cLayer_Base_Pressure(index_uncertain)))) then
                        wmodis_data_uncertain(icount_uncertain,24) = avg(cLayer_Base_Pressure(index_uncertain))
                     end if
                     if (.not.all(ismissing(cLayer_Top_Temperature(index_uncertain)))) then
                        wmodis_data_uncertain(icount_uncertain,25) = avg(cLayer_Top_Temperature(index_uncertain))
                     end if
                     if (.not.all(ismissing(cMidlayer_Temperature(index_uncertain)))) then
                        wmodis_data_uncertain(icount_uncertain,26) = avg(cMidlayer_Temperature(index_uncertain))
                     end if
                     if (.not.all(ismissing(cLayer_Base_Temperature(index_uncertain)))) then
                        wmodis_data_uncertain(icount_uncertain,27) = avg(cLayer_Base_Temperature(index_uncertain))
                     end if
                     icount_uncertain = icount_uncertain + 1
                  end if
                  delete([/index_uncertain/])
               end if
               end if
               end if
               icount_all = icount_all + 1

            end if

;  @@@PUT NO ACA CASES SELECTION HERE TO MAKE SURE ACA AND NO ACA CASES HAPPEN ON THE SAME DAY.
;  NO ACA CASES
            if (.not.all(ismissing(ind(ndtooned(aclayer_altitude_diff) .gt. 0.0)))) then
            index_noaca = ind(clat_nadir .ge. lat(index_lat(i))-lat_grid_size/2. .and. \
                              clat_nadir .le. lat(index_lat(i))+lat_grid_size/2. .and. \
                              clon_nadir .ge. lon(index_lon(j))-lon_grid_size/2. .and. \
                              clon_nadir .le. lon(index_lon(j))+lon_grid_size/2. .and. \
                              aclayer_altitude_diff .lt. 0.0                     .and. \
                              .not.all(ismissing(modis_data_day(:, index_lat(i), index_lon(j)))) .or. \
                              clat_nadir .ge. lat(index_lat(i))-lat_grid_size/2. .and. \
                              clat_nadir .le. lat(index_lat(i))+lat_grid_size/2. .and. \
                              clon_nadir .ge. lon(index_lon(j))-lon_grid_size/2. .and. \
                              clon_nadir .le. lon(index_lon(j))+lon_grid_size/2. .and. \
                              ismissing(aLayer_Base_Altitude)                    .and. \
                              .not.ismissing(cLayer_Top_Altitude)                .and. \
                              .not.all(ismissing(modis_data_day(:, index_lat(i), index_lon(j)))))
               if (.not.all(ismissing(index_noaca))) then
;  CONSIDER THIS MODIS GRID BOX AS NO ACA
                  modis_data_noaca(:, index_lat(i), index_lon(j)) = \
                  (/modis_data_day(:, index_lat(i), index_lon(j))/)
;  @@@PREPARE DATA FOR PUTTING THEM INTO AN ARRAY@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
                  wmodis_data_noaca(icount_noaca, 0) = (/lat(index_lat(i))/)
                  wmodis_data_noaca(icount_noaca, 1) = (/lon(index_lon(j))/)
                  wmodis_data_noaca(icount_noaca, 2:8) = modis_data_day(0:6, index_lat(i), index_lon(j))
                  if (.not.all(ismissing(cColumn_Optical_Depth_Cloud_532(index_noaca)))) then
                     wmodis_data_noaca(icount_noaca,9) = avg(cColumn_Optical_Depth_Cloud_532(index_noaca))
                  end if
                  if (.not.all(ismissing(aColumn_Optical_Depth_Aerosols_532(index_noaca)))) then
                     wmodis_data_noaca(icount_noaca,10) = avg(aColumn_Optical_Depth_Aerosols_532(index_noaca))
                  end if
                  if (.not.all(ismissing(aColumn_Optical_Depth_Aerosols_1064(index_noaca)))) then
                     wmodis_data_noaca(icount_noaca,11) = avg(aColumn_Optical_Depth_Aerosols_1064(index_noaca))
                  end if
                  if (.not.all(ismissing(aLayer_Top_Altitude(index_noaca)))) then
                     wmodis_data_noaca(icount_noaca,12) = avg(aLayer_Top_Altitude(index_noaca))
                  end if
                  if (.not.all(ismissing(aLayer_Base_Altitude(index_noaca)))) then
                     wmodis_data_noaca(icount_noaca,13) = avg(aLayer_Base_Altitude(index_noaca))
                  end if
                  if (.not.all(ismissing(aLayer_Top_Pressure(index_noaca)))) then
                     wmodis_data_noaca(icount_noaca,14) = avg(aLayer_Top_Pressure(index_noaca))
                  end if
                  if (.not.all(ismissing(aMidlayer_Pressure(index_noaca)))) then
                     wmodis_data_noaca(icount_noaca,15) = avg(aMidlayer_Pressure(index_noaca))
                  end if
                  if (.not.all(ismissing(aLayer_Base_Pressure(index_noaca)))) then
                     wmodis_data_noaca(icount_noaca,16) = avg(aLayer_Base_Pressure(index_noaca))
                  end if
                  if (.not.all(ismissing(aLayer_Top_Temperature(index_noaca)))) then
                     wmodis_data_noaca(icount_noaca,17) = avg(aLayer_Top_Temperature(index_noaca))
                  end if
                  if (.not.all(ismissing(aMidlayer_Temperature(index_noaca)))) then
                     wmodis_data_noaca(icount_noaca,18) = avg(aMidlayer_Temperature(index_noaca))
                  end if
                  if (.not.all(ismissing(aLayer_Base_Temperature(index_noaca)))) then
                     wmodis_data_noaca(icount_noaca,19) = avg(aLayer_Base_Temperature(index_noaca))
                  end if
                  if (.not.all(ismissing(cLayer_Top_Altitude(index_noaca)))) then
                     wmodis_data_noaca(icount_noaca,20) = avg(cLayer_Top_Altitude(index_noaca))
                  end if
                  if (.not.all(ismissing(cLayer_Base_Altitude(index_noaca)))) then
                     wmodis_data_noaca(icount_noaca,21) = avg(cLayer_Base_Altitude(index_noaca))
                  end if
                  if (.not.all(ismissing(cLayer_Top_Pressure(index_noaca)))) then
                     wmodis_data_noaca(icount_noaca,22) = avg(cLayer_Top_Pressure(index_noaca))
                  end if
                  if (.not.all(ismissing(cMidlayer_Pressure(index_noaca)))) then
                     wmodis_data_noaca(icount_noaca,23) = avg(cMidlayer_Pressure(index_noaca))
                  end if
                  if (.not.all(ismissing(cLayer_Base_Pressure(index_noaca)))) then
                     wmodis_data_noaca(icount_noaca,24) = avg(cLayer_Base_Pressure(index_noaca))
                  end if
                  if (.not.all(ismissing(cLayer_Top_Temperature(index_noaca)))) then
                     wmodis_data_noaca(icount_noaca,25) = avg(cLayer_Top_Temperature(index_noaca))
                  end if
                  if (.not.all(ismissing(cMidlayer_Temperature(index_noaca)))) then
                     wmodis_data_noaca(icount_noaca,26) = avg(cMidlayer_Temperature(index_noaca))
                  end if
                  if (.not.all(ismissing(cLayer_Base_Temperature(index_noaca)))) then
                     wmodis_data_noaca(icount_noaca,27) = avg(cLayer_Base_Temperature(index_noaca))
                  end if
                  icount_noaca = icount_noaca + 1
               end if
               delete([/index_noaca/])
            end if
            delete([index_clatlon_nadir])
         end do ; j
      end do ; i
   end if
   delete([/index_lat, index_lon/])

   wmodis_data_all_day(0, (ictrack_real*ncount_write):((ictrack_real+1)*ncount_write-1), :) = \
   (/wmodis_data_all/)
   wmodis_data_all_day(1, (ictrack_real*ncount_write):((ictrack_real+1)*ncount_write-1), :) = \
   (/wmodis_data_untouch/)
   wmodis_data_all_day(2, (ictrack_real*ncount_write):((ictrack_real+1)*ncount_write-1), :) = \
   (/wmodis_data_touch/)
   wmodis_data_all_day(3, (ictrack_real*ncount_write):((ictrack_real+1)*ncount_write-1), :) = \
   (/wmodis_data_uncertain/)
   wmodis_data_all_day(4, (ictrack_real*ncount_write):((ictrack_real+1)*ncount_write-1), :) = \
   (/wmodis_data_noaca/)

print("icount_all       = " + icount_all)
print("icount_untouch   = " + icount_untouch)
print("icount_touch     = " + icount_touch)
print("icount_uncertain = " + icount_uncertain)
print("icount_noaca     = " + icount_noaca)

return
end
