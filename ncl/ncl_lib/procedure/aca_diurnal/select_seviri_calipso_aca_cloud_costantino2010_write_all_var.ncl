;  $ID: select_seviri_calipso_aca_cloud_costantino2010_write_all_var.ncl V01 07/01/2015 23:38 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE select_seviri_calipso_aca_cloud_costantino2010_write_all_var SELECTS ALL 
;  THE GRIDDED SEVIRI GRIDS WITH THE RELATIVE VERTICAL POSITION OF AEROSOL AND CLOUD.
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
;  THIS PROCEDURE ONLY CONSIDERS THE SECOND METHOD (Costantino, 2010).
;  VARIABLES:
;  ============================================================================
;  (1 ) 
;  (1 ) clat      (2-D):LATITUDE OF A CALIPSO GROUND TRACK                [DEG]
;  (2 ) clon      (2-D):LONGITUDE OF A CALIPSO GROUND TRACK               [DEG]
;  (3 ) lat       (1-D):LATITUDE GRIDS FOR SEVIRI DATA                    [DEG]
;  (4 ) lon       (1-D):LONGITUDE GRIDS FOR SEVIRI DATA                   [DEG]
;  (5 ) minlat (scalar):MINIMUM LATITUDE IN THE STUDY REGION              [DEG]
;  (6 ) maxlat (scalar):MAXIMUM LATITUDE IN THE STUDY REGION              [DEG]
;  (7 ) minlon (scalar):MINIMUM LONGITUDE IN THE STUDY REGION             [DEG]
;  (8 ) maxlon (scalar):MAXIMUM LONGITUDE IN THE STUDY REGION             [DEG]
;  (9 ) iday_or_night(scalar):SCALAR TO DETERMINE DAY TIME OR NIGHT TIME  [   ]
;  (10) alay_base_altitude  (1-D):AEROSOL BASE LAYER ALTITUDE             [KM ]
;  (11) clay_top_altitude   (1-D):CLOUD TOP LAYER ALTITUDE                [KM ]
;  (12) seviri_data_day     (4-D):SEVIRI DATA                             [   ]
;  (13) seviri_data_all_day (4-D):SEVIRI DATA INCLUDING ALL THE CASES     [   ]
;  (14) wseviri_data_all_day(4-D):WRITE DATA INCLUDING ALL THE CASES      [   ]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE REFERING THE REFERENCES MENTIONED ABOVE.
;       (06/22/2015)
;  (2 ) MODIFIED FROM select_amsre_calipso_aca_cloud_costantino2010_write.ncl
;       (BRUCE, 06/30/2015)
;  (3 ) MODIFIED FROM select_seviri_calipso_aca_cloud_costantino2010_write.ncl
;       BY REDUCING THE # OF OUTPUT VARIABLES. (BRUCE, 07/01/2015)
;******************************************************************************
undef("select_seviri_calipso_aca_cloud_costantino2010_write_all_var")
procedure select_seviri_calipso_aca_cloud_costantino2010_write_all_var \
          (bv2                 :float,                                 \;INPUT
           nvariable           :integer, nelement_write      :integer, \;INPUT
           ictrack_real        :integer, ncount_write        :integer, \;INPUT
           clat                :float,   clon                :float,   \;INPUT
           lat                 :float,   lon                 :float,   \;INPUT
           lat_grid_size       :float,   lon_grid_size       :float,   \;INPUT
           nlat                :integer, nlon                :integer, \;INPUT
           minlat              :float,   maxlat              :float,   \;INPUT
           minlon              :float,   maxlon              :float,   \;INPUT
           iday_or_night       :integer,                               \;INPUT
           cColumn_Optical_Depth_Cloud_532     :float,                 \;INPUT
           aColumn_Optical_Depth_Aerosols_532  :float,                 \;INPUT
           aColumn_Optical_Depth_Aerosols_1064 :float,                 \;INPUT
           aLayer_Top_Altitude :float,   alay_base_altitude  :float,   \;INPUT
           aLayer_Top_Pressure :float,   aMidlayer_Pressure  :float,   \;INPUT
           aLayer_Base_Pressure:float,   aLayer_Top_Temperature:float, \;INPUT
           aMidlayer_Temperature:float,  aLayer_Base_Temperature:float,\;INPUT
           clay_top_altitude   :float,   cLayer_Base_Altitude :float,  \;INPUT
           cLayer_Top_Pressure :float,   cMidlayer_Pressure   :float,  \;INPUT
           cLayer_Base_Pressure:float,   cLayer_Top_Temperature:float, \;INPUT
           cMidlayer_Temperature:float,  cLayer_Base_Temperature:float,\;INPUT
           seviri_data_day     :numeric,                               \;INPUT
           seviri_data_all_day :numeric, wseviri_data_all_day:numeric)  ;OUTPUT

begin
   dim_3d                 = (/nvariable, nlat, nlon/)
   dim_write              = (/ncount_write, nelement_write/)
   seviri_data_all        = new(dim_3d,    float, bv2)
   seviri_data_untouch    = new(dim_3d,    float, bv2)
   seviri_data_touch      = new(dim_3d,    float, bv2)
   seviri_data_uncertain  = new(dim_3d,    float, bv2)
   seviri_data_noaca      = new(dim_3d,    float, bv2)
   wseviri_data_all       = new(dim_write, float, bv2)
   wseviri_data_untouch   = new(dim_write, float, bv2)
   wseviri_data_touch     = new(dim_write, float, bv2)
   wseviri_data_uncertain = new(dim_write, float, bv2)
   wseviri_data_noaca     = new(dim_write, float, bv2)

;  GET THE NADIR LATITUDE AND LONGITUDE FROM CALIPSO TRACK
   clat_nadir = clat(:, 1)
   clon_nadir = clon(:, 1)

;  CALCULATE THE DISTANCE BETWEEN ACA BASE AND CLOUD TOP
   aclay_altitude_diff = alay_base_altitude - clay_top_altitude

;  SELECT SEVIRI DATA IN THE STUDY REGION
   index_lat = ind(lat .ge. minlat .and. \
                   lat .le. maxlat)
   index_lon = ind(lon .ge. minlon .and. \
                   lon .le. maxlon)
   if (.not.all(ismissing(index_lat)) .and.\
       .not.all(ismissing(index_lon))) then
      nindex_lat = dimsizes(index_lat)
      nindex_lon = dimsizes(index_lon)
;  DO LOOP FOR SEVIRI LATITUDE AND LONGITUDE TO SELECT SEVIRI GRIDS HAVING 
;  ACA AND CLOUD RELATIVE VERTICAL POSITION
;  PLEASE NOTE: LATITUDE AND LONGITUDE FROM SEVIRI ARE FOR THE GRID CENTER
      icount_all     = 0
      icount_untouch = 0
      icount_touch   = 0
      icount_noaca   = 0
      do i = 0, nindex_lat-1
         do j = 0, nindex_lon-1
;  INDEX FOR ACA
            index_clatlon_nadir = ind(clat_nadir .ge. lat(index_lat(i))-lat_grid_size/2. .and. \
                                      clat_nadir .le. lat(index_lat(i))+lat_grid_size/2. .and. \
                                      clon_nadir .ge. lon(index_lon(j))-lon_grid_size/2. .and. \
                                      clon_nadir .le. lon(index_lon(j))+lon_grid_size/2. .and. \
                                      aclay_altitude_diff .gt. 0.0                       .and. \
                                      seviri_data_day(5, index_lat(i), index_lon(j)) .le. 300.0)
            if (.not.all(ismissing(index_clatlon_nadir))) then
               seviri_data_all(:, index_lat(i), index_lon(j)) = \
               (/seviri_data_day(:, index_lat(i), index_lon(j))/)
               num_untouch = num(aclay_altitude_diff(index_clatlon_nadir) .ge. 0.25)
               num_touch   = num(aclay_altitude_diff(index_clatlon_nadir) .le. 0.25 .and. \
                                 aclay_altitude_diff(index_clatlon_nadir) .ge. 0.0)
;  @@@PREPARE DATA FOR PUTTING THEM INTO AN ARRAY@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
               wseviri_data_all(icount_all, 0) = (/lat(index_lat(i))/)
               wseviri_data_all(icount_all, 1) = (/lon(index_lon(j))/)
               wseviri_data_all(icount_all, 2:13) = seviri_data_day(0:11, index_lat(i), index_lon(j))
               if (.not.all(ismissing(cColumn_Optical_Depth_Cloud_532(index_clatlon_nadir)))) then
                  wseviri_data_all(icount_all,14) = avg(cColumn_Optical_Depth_Cloud_532(index_clatlon_nadir))
               end if
               if (.not.all(ismissing(aColumn_Optical_Depth_Aerosols_532(index_clatlon_nadir)))) then
                  wseviri_data_all(icount_all,15) = avg(aColumn_Optical_Depth_Aerosols_532(index_clatlon_nadir))
               end if
               if (.not.all(ismissing(aColumn_Optical_Depth_Aerosols_1064(index_clatlon_nadir)))) then
                  wseviri_data_all(icount_all,16) = avg(aColumn_Optical_Depth_Aerosols_1064(index_clatlon_nadir))
               end if
               if (.not.all(ismissing(aLayer_Top_Altitude(index_clatlon_nadir)))) then
                  wseviri_data_all(icount_all,17) = avg(aLayer_Top_Altitude(index_clatlon_nadir))
               end if
               if (.not.all(ismissing(aLayer_Base_Altitude(index_clatlon_nadir)))) then
                  wseviri_data_all(icount_all,18) = avg(aLayer_Base_Altitude(index_clatlon_nadir))
               end if
               if (.not.all(ismissing(aLayer_Top_Pressure(index_clatlon_nadir)))) then
                  wseviri_data_all(icount_all,19) = avg(aLayer_Top_Pressure(index_clatlon_nadir))
               end if
               if (.not.all(ismissing(aMidlayer_Pressure(index_clatlon_nadir)))) then
                  wseviri_data_all(icount_all,20) = avg(aMidlayer_Pressure(index_clatlon_nadir))
               end if
               if (.not.all(ismissing(aLayer_Base_Pressure(index_clatlon_nadir)))) then
                  wseviri_data_all(icount_all,21) = avg(aLayer_Base_Pressure(index_clatlon_nadir))
               end if
               if (.not.all(ismissing(aLayer_Top_Temperature(index_clatlon_nadir)))) then
                  wseviri_data_all(icount_all,22) = avg(aLayer_Top_Temperature(index_clatlon_nadir))
               end if
               if (.not.all(ismissing(aMidlayer_Temperature(index_clatlon_nadir)))) then
                  wseviri_data_all(icount_all,23) = avg(aMidlayer_Temperature(index_clatlon_nadir))
               end if
               if (.not.all(ismissing(aLayer_Base_Temperature(index_clatlon_nadir)))) then
                  wseviri_data_all(icount_all,24) = avg(aLayer_Base_Temperature(index_clatlon_nadir))
               end if
               if (.not.all(ismissing(cLayer_Top_Altitude(index_clatlon_nadir)))) then
                  wseviri_data_all(icount_all,25) = avg(cLayer_Top_Altitude(index_clatlon_nadir))
               end if
               if (.not.all(ismissing(cLayer_Base_Altitude(index_clatlon_nadir)))) then
                  wseviri_data_all(icount_all,26) = avg(cLayer_Base_Altitude(index_clatlon_nadir))
               end if
               if (.not.all(ismissing(cLayer_Top_Pressure(index_clatlon_nadir)))) then
                  wseviri_data_all(icount_all,27) = avg(cLayer_Top_Pressure(index_clatlon_nadir))
               end if
               if (.not.all(ismissing(cMidlayer_Pressure(index_clatlon_nadir)))) then
                  wseviri_data_all(icount_all,28) = avg(cMidlayer_Pressure(index_clatlon_nadir))
               end if
               if (.not.all(ismissing(cLayer_Base_Pressure(index_clatlon_nadir)))) then
                  wseviri_data_all(icount_all,29) = avg(cLayer_Base_Pressure(index_clatlon_nadir))
               end if
               if (.not.all(ismissing(cLayer_Top_Temperature(index_clatlon_nadir)))) then
                  wseviri_data_all(icount_all,30) = avg(cLayer_Top_Temperature(index_clatlon_nadir))
               end if
               if (.not.all(ismissing(cMidlayer_Temperature(index_clatlon_nadir)))) then
                  wseviri_data_all(icount_all,31) = avg(cMidlayer_Temperature(index_clatlon_nadir))
               end if
               if (.not.all(ismissing(cLayer_Base_Temperature(index_clatlon_nadir)))) then
                  wseviri_data_all(icount_all,32) = avg(cLayer_Base_Temperature(index_clatlon_nadir))
               end if

               if (num_untouch .gt. num_touch) then
                  index_untouch = ind(aclay_altitude_diff(index_clatlon_nadir) .ge. 0.25)
                  if (.not.all(ismissing(index_untouch))) then
;  CONSIDER THIS SEVIRI GRID BOX AS ACA AND CLOUD UNTOUCH
                     seviri_data_untouch(:, index_lat(i), index_lon(j)) = \
                     (/seviri_data_day(:, index_lat(i), index_lon(j))/)
;  @@@PREPARE DATA FOR PUTTING THEM INTO AN ARRAY@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
                     wseviri_data_untouch(icount_untouch, 0) = (/lat(index_lat(i))/)
                     wseviri_data_untouch(icount_untouch, 1) = (/lon(index_lon(j))/)
                     wseviri_data_untouch(icount_untouch, 2:13) = seviri_data_day(0:11, index_lat(i), index_lon(j))
                     if (.not.all(ismissing(cColumn_Optical_Depth_Cloud_532(index_untouch)))) then
                        wseviri_data_all(icount_untouch,14) = avg(cColumn_Optical_Depth_Cloud_532(index_untouch))
                     end if
                     if (.not.all(ismissing(aColumn_Optical_Depth_Aerosols_532(index_untouch)))) then
                        wseviri_data_all(icount_untouch,15) = avg(aColumn_Optical_Depth_Aerosols_532(index_untouch))
                     end if
                     if (.not.all(ismissing(aColumn_Optical_Depth_Aerosols_1064(index_untouch)))) then
                        wseviri_data_all(icount_untouch,16) = avg(aColumn_Optical_Depth_Aerosols_1064(index_untouch))
                     end if
                     if (.not.all(ismissing(aLayer_Top_Altitude(index_untouch)))) then
                        wseviri_data_all(icount_untouch,17) = avg(aLayer_Top_Altitude(index_untouch))
                     end if
                     if (.not.all(ismissing(aLayer_Base_Altitude(index_untouch)))) then
                        wseviri_data_all(icount_untouch,18) = avg(aLayer_Base_Altitude(index_untouch))
                     end if
                     if (.not.all(ismissing(aLayer_Top_Pressure(index_untouch)))) then
                        wseviri_data_all(icount_untouch,19) = avg(aLayer_Top_Pressure(index_untouch))
                     end if
                     if (.not.all(ismissing(aMidlayer_Pressure(index_untouch)))) then
                        wseviri_data_all(icount_untouch,20) = avg(aMidlayer_Pressure(index_untouch))
                     end if
                     if (.not.all(ismissing(aLayer_Base_Pressure(index_untouch)))) then
                        wseviri_data_all(icount_untouch,21) = avg(aLayer_Base_Pressure(index_untouch))
                     end if
                     if (.not.all(ismissing(aLayer_Top_Temperature(index_untouch)))) then
                        wseviri_data_all(icount_untouch,22) = avg(aLayer_Top_Temperature(index_untouch))
                     end if
                     if (.not.all(ismissing(aMidlayer_Temperature(index_untouch)))) then
                        wseviri_data_all(icount_untouch,23) = avg(aMidlayer_Temperature(index_untouch))
                     end if
                     if (.not.all(ismissing(aLayer_Base_Temperature(index_untouch)))) then
                        wseviri_data_all(icount_untouch,24) = avg(aLayer_Base_Temperature(index_untouch))
                     end if
                     if (.not.all(ismissing(cLayer_Top_Altitude(index_untouch)))) then
                        wseviri_data_all(icount_untouch,25) = avg(cLayer_Top_Altitude(index_untouch))
                     end if
                     if (.not.all(ismissing(cLayer_Base_Altitude(index_untouch)))) then
                        wseviri_data_all(icount_untouch,26) = avg(cLayer_Base_Altitude(index_untouch))
                     end if
                     if (.not.all(ismissing(cLayer_Top_Pressure(index_untouch)))) then
                        wseviri_data_all(icount_untouch,27) = avg(cLayer_Top_Pressure(index_untouch))
                     end if
                     if (.not.all(ismissing(cMidlayer_Pressure(index_untouch)))) then
                        wseviri_data_all(icount_untouch,28) = avg(cMidlayer_Pressure(index_untouch))
                     end if
                     if (.not.all(ismissing(cLayer_Base_Pressure(index_untouch)))) then
                        wseviri_data_all(icount_untouch,29) = avg(cLayer_Base_Pressure(index_untouch))
                     end if
                     if (.not.all(ismissing(cLayer_Top_Temperature(index_untouch)))) then
                        wseviri_data_all(icount_untouch,30) = avg(cLayer_Top_Temperature(index_untouch))
                     end if
                     if (.not.all(ismissing(cMidlayer_Temperature(index_untouch)))) then
                        wseviri_data_all(icount_untouch,31) = avg(cMidlayer_Temperature(index_untouch))
                     end if
                     if (.not.all(ismissing(cLayer_Base_Temperature(index_untouch)))) then
                        wseviri_data_all(icount_untouch,32) = avg(cLayer_Base_Temperature(index_untouch))
                     end if
                     icount_untouch = icount_untouch + 1
                  end if
                  delete([/index_untouch/])
               else if (num_untouch .lt. num_touch) then
                  index_touch = ind(aclay_altitude_diff(index_clatlon_nadir) .le. 0.25 .and. \
                                    aclay_altitude_diff(index_clatlon_nadir) .ge. 0.0)
                  if (.not.all(ismissing(index_touch))) then
;  CONSIDER THIS SEVIRI GRID BOX AS ACA AND CLOUD TOUCH
                     seviri_data_touch(:, index_lat(i), index_lon(j)) = \
                     (/seviri_data_day(:, index_lat(i), index_lon(j))/)
;  @@@PREPARE DATA FOR PUTTING THEM INTO AN ARRAY@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
                     wseviri_data_touch(icount_touch, 0) = (/lat(index_lat(i))/)
                     wseviri_data_touch(icount_touch, 1) = (/lon(index_lon(j))/)
                     wseviri_data_touch(icount_touch, 2:13) = seviri_data_day(0:11, index_lat(i), index_lon(j))
                     if (.not.all(ismissing(cColumn_Optical_Depth_Cloud_532(index_touch)))) then
                        wseviri_data_all(icount_touch,14) = avg(cColumn_Optical_Depth_Cloud_532(index_touch))
                     end if
                     if (.not.all(ismissing(aColumn_Optical_Depth_Aerosols_532(index_touch)))) then
                        wseviri_data_all(icount_touch,15) = avg(aColumn_Optical_Depth_Aerosols_532(index_touch))
                     end if
                     if (.not.all(ismissing(aColumn_Optical_Depth_Aerosols_1064(index_touch)))) then
                        wseviri_data_all(icount_touch,16) = avg(aColumn_Optical_Depth_Aerosols_1064(index_touch))
                     end if
                     if (.not.all(ismissing(aLayer_Top_Altitude(index_touch)))) then
                        wseviri_data_all(icount_touch,17) = avg(aLayer_Top_Altitude(index_touch))
                     end if
                     if (.not.all(ismissing(aLayer_Base_Altitude(index_touch)))) then
                        wseviri_data_all(icount_touch,18) = avg(aLayer_Base_Altitude(index_touch))
                     end if
                     if (.not.all(ismissing(aLayer_Top_Pressure(index_touch)))) then
                        wseviri_data_all(icount_touch,19) = avg(aLayer_Top_Pressure(index_touch))
                     end if
                     if (.not.all(ismissing(aMidlayer_Pressure(index_touch)))) then
                        wseviri_data_all(icount_touch,20) = avg(aMidlayer_Pressure(index_touch))
                     end if
                     if (.not.all(ismissing(aLayer_Base_Pressure(index_touch)))) then
                        wseviri_data_all(icount_touch,21) = avg(aLayer_Base_Pressure(index_touch))
                     end if
                     if (.not.all(ismissing(aLayer_Top_Temperature(index_touch)))) then
                        wseviri_data_all(icount_touch,22) = avg(aLayer_Top_Temperature(index_touch))
                     end if
                     if (.not.all(ismissing(aMidlayer_Temperature(index_touch)))) then
                        wseviri_data_all(icount_touch,23) = avg(aMidlayer_Temperature(index_touch))
                     end if
                     if (.not.all(ismissing(aLayer_Base_Temperature(index_touch)))) then
                        wseviri_data_all(icount_touch,24) = avg(aLayer_Base_Temperature(index_touch))
                     end if
                     if (.not.all(ismissing(cLayer_Top_Altitude(index_touch)))) then
                        wseviri_data_all(icount_touch,25) = avg(cLayer_Top_Altitude(index_touch))
                     end if
                     if (.not.all(ismissing(cLayer_Base_Altitude(index_touch)))) then
                        wseviri_data_all(icount_touch,26) = avg(cLayer_Base_Altitude(index_touch))
                     end if
                     if (.not.all(ismissing(cLayer_Top_Pressure(index_touch)))) then
                        wseviri_data_all(icount_touch,27) = avg(cLayer_Top_Pressure(index_touch))
                     end if
                     if (.not.all(ismissing(cMidlayer_Pressure(index_touch)))) then
                        wseviri_data_all(icount_touch,28) = avg(cMidlayer_Pressure(index_touch))
                     end if
                     if (.not.all(ismissing(cLayer_Base_Pressure(index_touch)))) then
                        wseviri_data_all(icount_touch,29) = avg(cLayer_Base_Pressure(index_touch))
                     end if
                     if (.not.all(ismissing(cLayer_Top_Temperature(index_touch)))) then
                        wseviri_data_all(icount_touch,30) = avg(cLayer_Top_Temperature(index_touch))
                     end if
                     if (.not.all(ismissing(cMidlayer_Temperature(index_touch)))) then
                        wseviri_data_all(icount_touch,31) = avg(cMidlayer_Temperature(index_touch))
                     end if
                     if (.not.all(ismissing(cLayer_Base_Temperature(index_touch)))) then
                        wseviri_data_all(icount_touch,32) = avg(cLayer_Base_Temperature(index_touch))
                     end if
                     icount_touch = icount_touch + 1
                  end if
                  delete([/index_touch/])
               end if
               end if
               icount_all = icount_all + 1

            end if

;  @@@PUT NO ACA CASES SELECTION HERE TO MAKE SURE ACA AND NO ACA CASES HAPPEN ON THE SAME DAY.
;  NO ACA CASES
            if (.not.all(ismissing(ind(ndtooned(aclay_altitude_diff) .gt. 0.0)))) then
            index_noaca = ind(clat_nadir .ge. lat(index_lat(i))-lat_grid_size/2. .and. \
                              clat_nadir .le. lat(index_lat(i))+lat_grid_size/2. .and. \
                              clon_nadir .ge. lon(index_lon(j))-lon_grid_size/2. .and. \
                              clon_nadir .le. lon(index_lon(j))+lon_grid_size/2. .and. \
                              aclay_altitude_diff .lt. 0.0                       .and. \
                              .not.all(ismissing(seviri_data_day(:, index_lat(i), index_lon(j)))) .or. \
                              clat_nadir .ge. lat(index_lat(i))-lat_grid_size/2. .and. \
                              clat_nadir .le. lat(index_lat(i))+lat_grid_size/2. .and. \
                              clon_nadir .ge. lon(index_lon(j))-lon_grid_size/2. .and. \
                              clon_nadir .le. lon(index_lon(j))+lon_grid_size/2. .and. \
                              ismissing(alay_base_altitude)                      .and. \
                              .not.ismissing(clay_top_altitude)                  .and. \
                              .not.all(ismissing(seviri_data_day(:, index_lat(i), index_lon(j)))))
               if (.not.all(ismissing(index_noaca))) then
;  CONSIDER THIS SEVIRI GRID BOX AS NO ACA
                  seviri_data_noaca(:, index_lat(i), index_lon(j)) = \
                  (/seviri_data_day(:, index_lat(i), index_lon(j))/)
;  @@@PREPARE DATA FOR PUTTING THEM INTO AN ARRAY@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
                  wseviri_data_noaca(icount_noaca, 0) = (/lat(index_lat(i))/)
                  wseviri_data_noaca(icount_noaca, 1) = (/lon(index_lon(j))/)
                  wseviri_data_noaca(icount_noaca, 2:13) = seviri_data_day(0:11, index_lat(i), index_lon(j))
                  if (.not.all(ismissing(cColumn_Optical_Depth_Cloud_532(index_noaca)))) then
                     wseviri_data_all(icount_noaca,14) = avg(cColumn_Optical_Depth_Cloud_532(index_noaca))
                  end if
                  if (.not.all(ismissing(aColumn_Optical_Depth_Aerosols_532(index_noaca)))) then
                     wseviri_data_all(icount_noaca,15) = avg(aColumn_Optical_Depth_Aerosols_532(index_noaca))
                  end if
                  if (.not.all(ismissing(aColumn_Optical_Depth_Aerosols_1064(index_noaca)))) then
                     wseviri_data_all(icount_noaca,16) = avg(aColumn_Optical_Depth_Aerosols_1064(index_noaca))
                  end if
                  if (.not.all(ismissing(aLayer_Top_Altitude(index_noaca)))) then
                     wseviri_data_all(icount_noaca,17) = avg(aLayer_Top_Altitude(index_noaca))
                  end if
                  if (.not.all(ismissing(aLayer_Base_Altitude(index_noaca)))) then
                     wseviri_data_all(icount_noaca,18) = avg(aLayer_Base_Altitude(index_noaca))
                  end if
                  if (.not.all(ismissing(aLayer_Top_Pressure(index_noaca)))) then
                     wseviri_data_all(icount_noaca,19) = avg(aLayer_Top_Pressure(index_noaca))
                  end if
                  if (.not.all(ismissing(aMidlayer_Pressure(index_noaca)))) then
                     wseviri_data_all(icount_noaca,20) = avg(aMidlayer_Pressure(index_noaca))
                  end if
                  if (.not.all(ismissing(aLayer_Base_Pressure(index_noaca)))) then
                     wseviri_data_all(icount_noaca,21) = avg(aLayer_Base_Pressure(index_noaca))
                  end if
                  if (.not.all(ismissing(aLayer_Top_Temperature(index_noaca)))) then
                     wseviri_data_all(icount_noaca,22) = avg(aLayer_Top_Temperature(index_noaca))
                  end if
                  if (.not.all(ismissing(aMidlayer_Temperature(index_noaca)))) then
                     wseviri_data_all(icount_noaca,23) = avg(aMidlayer_Temperature(index_noaca))
                  end if
                  if (.not.all(ismissing(aLayer_Base_Temperature(index_noaca)))) then
                     wseviri_data_all(icount_noaca,24) = avg(aLayer_Base_Temperature(index_noaca))
                  end if
                  if (.not.all(ismissing(cLayer_Top_Altitude(index_noaca)))) then
                     wseviri_data_all(icount_noaca,25) = avg(cLayer_Top_Altitude(index_noaca))
                  end if
                  if (.not.all(ismissing(cLayer_Base_Altitude(index_noaca)))) then
                     wseviri_data_all(icount_noaca,26) = avg(cLayer_Base_Altitude(index_noaca))
                  end if
                  if (.not.all(ismissing(cLayer_Top_Pressure(index_noaca)))) then
                     wseviri_data_all(icount_noaca,27) = avg(cLayer_Top_Pressure(index_noaca))
                  end if
                  if (.not.all(ismissing(cMidlayer_Pressure(index_noaca)))) then
                     wseviri_data_all(icount_noaca,28) = avg(cMidlayer_Pressure(index_noaca))
                  end if
                  if (.not.all(ismissing(cLayer_Base_Pressure(index_noaca)))) then
                     wseviri_data_all(icount_noaca,29) = avg(cLayer_Base_Pressure(index_noaca))
                  end if
                  if (.not.all(ismissing(cLayer_Top_Temperature(index_noaca)))) then
                     wseviri_data_all(icount_noaca,30) = avg(cLayer_Top_Temperature(index_noaca))
                  end if
                  if (.not.all(ismissing(cMidlayer_Temperature(index_noaca)))) then
                     wseviri_data_all(icount_noaca,31) = avg(cMidlayer_Temperature(index_noaca))
                  end if
                  if (.not.all(ismissing(cLayer_Base_Temperature(index_noaca)))) then
                     wseviri_data_all(icount_noaca,32) = avg(cLayer_Base_Temperature(index_noaca))
                  end if
                  icount_noaca = icount_noaca + 1
               end if
               delete([/index_noaca/])
            end if
            delete([index_clatlon_nadir])
         end do ; j
      end do ; i
   end if
   delete([/clat_nadir, clon_nadir, index_lat, index_lon/])

   seviri_data_all_day(0, 0, ictrack_real, :, :, :) = (/seviri_data_all/)
   seviri_data_all_day(0, 1, ictrack_real, :, :, :) = (/seviri_data_untouch/)
   seviri_data_all_day(0, 2, ictrack_real, :, :, :) = (/seviri_data_touch/)
   seviri_data_all_day(0, 4, ictrack_real, :, :, :) = (/seviri_data_noaca/)
   wseviri_data_all_day(0, 0, (ictrack_real*ncount_write):((ictrack_real+1)*ncount_write-1), :) = (/wseviri_data_all/)
   wseviri_data_all_day(0, 1, (ictrack_real*ncount_write):((ictrack_real+1)*ncount_write-1), :) = (/wseviri_data_untouch/)
   wseviri_data_all_day(0, 2, (ictrack_real*ncount_write):((ictrack_real+1)*ncount_write-1), :) = (/wseviri_data_touch/)
   wseviri_data_all_day(0, 4, (ictrack_real*ncount_write):((ictrack_real+1)*ncount_write-1), :) = (/wseviri_data_noaca/)

print("icount_all     = " + icount_all)
print("icount_untouch = " + icount_untouch)
print("icount_touch   = " + icount_touch)
print("icount_noaca   = " + icount_noaca)

return
end
