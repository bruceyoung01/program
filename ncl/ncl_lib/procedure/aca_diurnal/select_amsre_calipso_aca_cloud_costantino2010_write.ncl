;  $ID: select_amsre_calipso_aca_cloud_costantino2010_write.ncl V01 06/22/2015 10:24 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE select_amsre_calipso_aca_cloud_costantino2010_write SELECTS ALL 
;  THE AMSR-E GRIDS WITH THE RELATIVE VERTICAL POSITION OF AEROSOL AND CLOUD.
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
;  (1 ) clat     (2-D):LATITUDE OF A CALIPSO GROUND TRACK                 [DEG]
;  (2 ) clon     (2-D):LONGITUDE OF A CALIPSO GROUND TRACK                [DEG]
;  (3 ) lat      (1-D):LATITUDE GRIDS FOR AMSR-E DATA                     [DEG]
;  (4 ) lon      (1-D):LONGITUDE GRIDS FOR AMSR-E DATA                    [DEG]
;  (5 ) minlat (scalar):MINIMUM LATITUDE IN THE STUDY REGION              [DEG]
;  (6 ) maxlat (scalar):MAXIMUM LATITUDE IN THE STUDY REGION              [DEG]
;  (7 ) minlon (scalar):MINIMUM LONGITUDE IN THE STUDY REGION             [DEG]
;  (8 ) maxlon (scalar):MAXIMUM LONGITUDE IN THE STUDY REGION             [DEG]
;  (9 ) iday_or_night(scalar):SCALAR TO DETERMINE DAY TIME OR NIGHT TIME  [   ]
;  (10) alay_base_altitude (1-D):AEROSOL BASE LAYER ALTITUDE              [KM ]
;  (11) clay_top_altitude  (1-D):CLOUD TOP LAYER ALTITUDE                 [KM ]
;  (12) amsre_data_day     (4-D):AMSR-E DATA                              [   ]
;  (13) amsre_data_all     (4-D):AMSR-E DATA INCLUDING ALL THE CASES      [   ]
;  (14) amsre_data_untouch (4-D):AMSR-E DATA WITH ACA UNTOUCHING CLOUD    [   ]
;  (15) amsre_data_touch   (4-D):AMSR-E DATA WITH ACA TOUCHING CLOUD      [   ]
;  (16) wamsre_data_all    (2-D):WRITE DATA INCLUDING ALL THE CASES       [   ]
;  (17) wamsre_data_untouch(2-D):WRITE DATA WITH ACA UNTOUCHING CLOUD     [   ]
;  (18) wamsre_data_touch  (2-D):WRITE DATA WITH ACA TOUCHING CLOUD       [   ]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE REFERING THE REFERENCES MENTIONED ABOVE.
;       (06/22/2015)
;******************************************************************************
undef("select_amsre_calipso_aca_cloud_costantino2010_write")
procedure select_amsre_calipso_aca_cloud_costantino2010_write \
          (clat               :float,   clon              :float,  \;INPUT
           lat                :float,   lon               :float,  \;INPUT
           minlat             :float,   maxlat            :float,  \;INPUT
           minlon             :float,   maxlon            :float,  \;INPUT
           iday_or_night      :integer,                            \;INPUT
           alay_base_altitude :float,   clay_top_altitude :float,  \;INPUT
           amsre_data_day     :numeric, amsre_data_all    :numeric,\;INPUT
           amsre_data_untouch :numeric, amsre_data_touch  :numeric,\;OUTPUT
           wamsre_data_all    :numeric,                            \;OUTPUT
           wamsre_data_untouch:numeric, wamsre_data_touch :numeric) ;OUTPUT

begin
;  GET THE NADIR LATITUDE AND LONGITUDE FROM CALIPSO TRACK
   clat_nadir = clat(:, 1)
   clon_nadir = clon(:, 1)

;  CALCULATE THE DISTANCE BETWEEN ACA BASE AND CLOUD TOP
   aclay_altitude_diff = alay_base_altitude - clay_top_altitude

;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;  CAUTION: SINCE AMSR-E LONGITUDE IS FROM 0~360,
;  CONVERT IT TO -90~90
   lon       = where(lon .ge. 180, lon-360, lon)
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

;  SELECT AMSR-E DATA IN THE STUDY REGION
   index_lat = ind(lat .ge. minlat .and. \
                   lat .le. maxlat)
   index_lon = ind(lon .ge. minlon .and. \
                   lon .le. maxlon)
   if (.not.all(ismissing(index_lat)) .and.\
       .not.all(ismissing(index_lon))) then
      nindex_lat = dimsizes(index_lat)
      nindex_lon = dimsizes(index_lon)
;  DO LOOP FOR AMSR-E LATITUDE AND LONGITUDE TO SELECT AMSR-E GRIDS HAVING 
;  ACA AND CLOUD RELATIVE VERTICAL POSITION
;  PLEASE NOTE: LATITUDE AND LONGITUDE FROM AMSR-E ARE FOR THE GRID CENTER
      icount_all     = 0
      icount_untouch = 0
      icount_touch   = 0
      do i = 0, nindex_lat-1
         do j = 0, nindex_lon-1
;  INDEX FOR ACA
            index_clatlon_nadir = ind(clat_nadir .ge. lat(index_lat(i))-0.125 .and. \
                                      clat_nadir .le. lat(index_lat(i))+0.125 .and. \
                                      clon_nadir .ge. lon(index_lon(j))-0.125 .and. \
                                      clon_nadir .le. lon(index_lon(j))+0.125 .and. \
                                      aclay_altitude_diff .gt. 0.0            .and. \
                                      amsre_data_day(iday_or_night, 5, index_lat(i), index_lon(j)) .le. 300.0)
            if (.not.all(ismissing(index_clatlon_nadir))) then
               amsre_data_all(:, :, index_lat(i), index_lon(j)) = \
               amsre_data_day(:, :, index_lat(i), index_lon(j))
               num_untouch = num(aclay_altitude_diff(index_clatlon_nadir) .ge. 0.25)
               num_touch   = num(aclay_altitude_diff(index_clatlon_nadir) .le. 0.25 .and. \
                                 aclay_altitude_diff(index_clatlon_nadir) .ge. 0.0)
;  @@@PREPARE DATA FOR PUTTING THEM INTO AN ARRAY@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
               wamsre_data_all(icount_all, 0) = lat(index_lat(i))
               wamsre_data_all(icount_all, 1) = lon(index_lon(j))
               wamsre_data_all(icount_all, 2) = amsre_data_day(iday_or_night, 5, index_lat(i), index_lon(j))
               wamsre_data_all(icount_all, 3) = amsre_data_day(iday_or_night, 6, index_lat(i), index_lon(j))
               if (.not.all(ismissing(alay_base_altitude(index_clatlon_nadir)))) then
                  wamsre_data_all(icount_all, 4) = avg(alay_base_altitude(index_clatlon_nadir))
               end if
               if (.not.all(ismissing(clay_top_altitude(index_clatlon_nadir)))) then
                  wamsre_data_all(icount_all, 5) = avg(clay_top_altitude(index_clatlon_nadir))
               end if
               if (num_untouch .gt. num_touch) then
                  index_untouch = ind(aclay_altitude_diff(index_clatlon_nadir) .ge. 0.25)
                  if (.not.all(ismissing(index_untouch))) then
;  CONSIDER THIS AMSR-E GRID BOX AS ACA AND CLOUD UNTOUCH
                     amsre_data_untouch(:, :, index_lat(i), index_lon(j)) = \
                     amsre_data_day(:, :, index_lat(i), index_lon(j))
;  @@@PREPARE DATA FOR PUTTING THEM INTO AN ARRAY@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
                     wamsre_data_untouch(icount_untouch, 0) = lat(index_lat(i))
                     wamsre_data_untouch(icount_untouch, 1) = lon(index_lon(j))
                     wamsre_data_untouch(icount_untouch, 2) = amsre_data_day(iday_or_night, 5, index_lat(i), index_lon(j))
                     wamsre_data_untouch(icount_untouch, 3) = amsre_data_day(iday_or_night, 6, index_lat(i), index_lon(j))
                     if (.not.all(ismissing(alay_base_altitude(index_clatlon_nadir(index_untouch))))) then
                        wamsre_data_untouch(icount_untouch, 4) = avg(alay_base_altitude(index_clatlon_nadir(index_untouch)))
                     end if
                     if (.not.all(ismissing(clay_top_altitude(index_clatlon_nadir(index_untouch))))) then
                        wamsre_data_untouch(icount_untouch, 5) = avg(clay_top_altitude(index_clatlon_nadir(index_untouch)))
                     end if
                     icount_untouch = icount_untouch + 1
                  end if
                  delete([/index_untouch/])
               else if (num_untouch .lt. num_touch) then
                  index_touch = ind(aclay_altitude_diff(index_clatlon_nadir) .le. 0.25 .and. \
                                    aclay_altitude_diff(index_clatlon_nadir) .ge. 0.0)
                  if (.not.all(ismissing(index_touch))) then
;  CONSIDER THIS AMSR-E GRID BOX AS ACA AND CLOUD TOUCH
                     amsre_data_touch(:, :, index_lat(i), index_lon(j)) = \
                     amsre_data_day(:, :, index_lat(i), index_lon(j))
;  @@@PREPARE DATA FOR PUTTING THEM INTO AN ARRAY@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
                     wamsre_data_touch(icount_touch, 0) = lat(index_lat(i))
                     wamsre_data_touch(icount_touch, 1) = lon(index_lon(j))
                     wamsre_data_touch(icount_touch, 2) = amsre_data_day(iday_or_night, 5, index_lat(i), index_lon(j))
                     wamsre_data_touch(icount_touch, 3) = amsre_data_day(iday_or_night, 6, index_lat(i), index_lon(j))
                     if (.not.all(ismissing(alay_base_altitude(index_clatlon_nadir)))) then
                        wamsre_data_touch(icount_touch, 4) = avg(alay_base_altitude(index_clatlon_nadir(index_touch)))
                     end if
                     if (.not.all(ismissing(clay_top_altitude(index_clatlon_nadir)))) then
                        wamsre_data_touch(icount_touch, 5) = avg(clay_top_altitude(index_clatlon_nadir(index_touch)))
                     end if
                     icount_touch = icount_touch + 1
                  end if
                  delete([/index_touch/])
               end if
               end if
               icount_all = icount_all + 1
            end if
            delete([index_clatlon_nadir])
         end do ; j
      end do ; i
   end if
   delete([/index_lat, index_lon/])
print("icount_all     = " + icount_all)
print("icount_untouch = " + icount_untouch)
print("icount_touch   = " + icount_touch)

;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;  SINCE NOW AMSR-E LONGITUDE IS FROM -180~180,
;  CONVERT IT BACK TO 0~360
   lon       = where(lon .le. 0,  360+lon, lon)
;!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
return
end
