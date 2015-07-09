;  $ID: select_seviri_calipso_aca_cloud_costantino2013_write_all.ncl V01 07/01/2015 23:52 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE select_seviri_calipso_aca_cloud_costantino2013_write_all SELECTS ALL 
;  THE SEVIRI GRIDS WITH THE RELATIVE VERTICAL POSITION OF AEROSOL AND CLOUD.
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
;  (3 ) lat      (1-D):LATITUDE GRIDS FOR SEVIRI DATA                     [DEG]
;  (4 ) lon      (1-D):LONGITUDE GRIDS FOR SEVIRI DATA                    [DEG]
;  (5 ) minlat (scalar):MINIMUM LATITUDE IN THE STUDY REGION              [DEG]
;  (6 ) maxlat (scalar):MAXIMUM LATITUDE IN THE STUDY REGION              [DEG]
;  (7 ) minlon (scalar):MINIMUM LONGITUDE IN THE STUDY REGION             [DEG]
;  (8 ) maxlon (scalar):MAXIMUM LONGITUDE IN THE STUDY REGION             [DEG]
;  (9 ) iday_or_night(scalar):SCALAR TO DETERMINE DAY TIME OR NIGHT TIME  [   ]
;  (10) alay_base_altitude (1-D):AEROSOL BASE LAYER ALTITUDE              [KM ]
;  (11) clay_top_altitude  (1-D):CLOUD TOP LAYER ALTITUDE                 [KM ]
;  (12) seviri_data_day     (2-D):SEVIRI DATA                             [   ]
;  (13) seviri_data_all_day (4-D):SEVIRI DATA INCLUDING ALL THE CASES     [   ]
;  (14) wseviri_data_all_day(2-D):WRITE DATA INCLUDING ALL THE CASES      [   ]
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
undef("select_seviri_calipso_aca_cloud_costantino2013_write_all")
procedure select_seviri_calipso_aca_cloud_costantino2013_write_all \
          (bv2                 :float,   nelement_write        :integer,\;INPUT
           ictrack_real        :integer, ncount_write          :integer,\;INPUT
           clat                :float,   clon                  :float,  \;INPUT
           lat                 :float,   lon                   :float,  \;INPUT
           lat_grid_size       :float,   lon_grid_size         :float,  \;INPUT
           nlat                :integer, nlon                  :integer,\;INPUT
           minlat              :float,   maxlat                :float,  \;INPUT
           minlon              :float,   maxlon                :float,  \;INPUT
           iday_or_night       :integer,                                \;INPUT
           alay_base_altitude  :float,   clay_top_altitude     :float,  \;INPUT
           seviri_data_day     :numeric,                                \;INPUT
           seviri_data_all_day :numeric, wseviri_data_all_day  :numeric) ;OUTPUT

begin

   dim_2d                 = (/nlat, nlon/)
   dim_write              = (/ncount_write, nelement_write/)
   seviri_data_all        = new(dim_2d,    float, bv2)
   seviri_data_untouch    = new(dim_2d,    float, bv2)
   seviri_data_touch      = new(dim_2d,    float, bv2)
   seviri_data_uncertain  = new(dim_2d,    float, bv2)
   wseviri_data_all       = new(dim_write, float, bv2)
   wseviri_data_untouch   = new(dim_write, float, bv2)
   wseviri_data_touch     = new(dim_write, float, bv2)
   wseviri_data_uncertain = new(dim_write, float, bv2)

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
      icount_all       = 0
      icount_untouch   = 0
      icount_touch     = 0
      icount_uncertain = 0
      do i = 0, nindex_lat-1
         do j = 0, nindex_lon-1
;  INDEX FOR ACA
            index_clatlon_nadir = ind(clat_nadir .ge. lat(index_lat(i))-lat_grid_size/2. .and. \
                                      clat_nadir .le. lat(index_lat(i))+lat_grid_size/2. .and. \
                                      clon_nadir .ge. lon(index_lon(j))-lon_grid_size/2. .and. \
                                      clon_nadir .le. lon(index_lon(j))+lon_grid_size/2. .and. \
                                      aclay_altitude_diff .gt. 0.0            .and. \
                                      seviri_data_day(index_lat(i), index_lon(j)) .le. 300.0)
            if (.not.all(ismissing(index_clatlon_nadir))) then
               seviri_data_all(index_lat(i), index_lon(j)) = \
               (/seviri_data_day(index_lat(i), index_lon(j))/)
               num_untouch   = num(aclay_altitude_diff(index_clatlon_nadir) .ge. 0.75)
               num_touch     = num(aclay_altitude_diff(index_clatlon_nadir) .le. 0.10 .and. \
                                   aclay_altitude_diff(index_clatlon_nadir) .ge. 0.0)
               num_uncertain = num(aclay_altitude_diff(index_clatlon_nadir) .le. 0.75 .and. \
                                   aclay_altitude_diff(index_clatlon_nadir) .ge. 0.10)
;  @@@PREPARE DATA FOR PUTTING THEM INTO AN ARRAY@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
               wseviri_data_all(icount_all, 0) = (/lat(index_lat(i))/)
               wseviri_data_all(icount_all, 1) = (/lon(index_lon(j))/)
               wseviri_data_all(icount_all, 2) = seviri_data_day(index_lat(i), index_lon(j))
               if (.not.all(ismissing(alay_base_altitude(index_clatlon_nadir)))) then
                  wseviri_data_all(icount_all, 3) = avg(alay_base_altitude(index_clatlon_nadir))
               end if
               if (.not.all(ismissing(clay_top_altitude(index_clatlon_nadir)))) then
                  wseviri_data_all(icount_all, 4) = avg(clay_top_altitude(index_clatlon_nadir))
               end if
               if (num_untouch .gt. num_touch .and. \
                   num_untouch .gt. num_uncertain) then
                  index_untouch = ind(aclay_altitude_diff(index_clatlon_nadir) .ge. 0.75)
                  if (.not.all(ismissing(index_untouch))) then
;  CONSIDER THIS SEVIRI GRID BOX AS ACA AND CLOUD UNTOUCH
                  seviri_data_untouch(index_lat(i), index_lon(j)) = \
                  (/seviri_data_day(index_lat(i), index_lon(j))/)
;  @@@PREPARE DATA FOR PUTTING THEM INTO AN ARRAY@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
                  wseviri_data_untouch(icount_untouch, 0) = (/lat(index_lat(i))/)
                  wseviri_data_untouch(icount_untouch, 1) = (/lon(index_lon(j))/)
                  wseviri_data_untouch(icount_untouch, 2) = seviri_data_day(index_lat(i), index_lon(j))
                  if (.not.all(ismissing(alay_base_altitude(index_clatlon_nadir)))) then
                     wseviri_data_untouch(icount_untouch, 3) = avg(alay_base_altitude(index_clatlon_nadir(index_untouch)))
                  end if
                  if (.not.all(ismissing(clay_top_altitude(index_clatlon_nadir)))) then
                     wseviri_data_untouch(icount_untouch, 4) = avg(clay_top_altitude(index_clatlon_nadir(index_untouch)))
                  end if
                  icount_untouch = icount_untouch + 1
                  end if
                  delete([/index_untouch/])
               else if (num_touch .gt. num_untouch .and. \
                        num_touch .gt. num_uncertain) then
                  index_touch = ind(aclay_altitude_diff(index_clatlon_nadir) .le. 0.10 .and. \
                                    aclay_altitude_diff(index_clatlon_nadir) .ge. 0.0)
                  if (.not.all(ismissing(index_touch))) then
;  CONSIDER THIS SEVIRI GRID BOX AS ACA AND CLOUD TOUCH
                  seviri_data_touch(index_lat(i), index_lon(j)) = \
                  (/seviri_data_day(index_lat(i), index_lon(j))/)
;  @@@PREPARE DATA FOR PUTTING THEM INTO AN ARRAY@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
                  wseviri_data_touch(icount_touch, 0) = (/lat(index_lat(i))/)
                  wseviri_data_touch(icount_touch, 1) = (/lon(index_lon(j))/)
                  wseviri_data_touch(icount_touch, 2) = seviri_data_day(index_lat(i), index_lon(j))
                  if (.not.all(ismissing(alay_base_altitude(index_clatlon_nadir)))) then
                     wseviri_data_touch(icount_touch, 3) = avg(alay_base_altitude(index_clatlon_nadir))
                  end if
                  if (.not.all(ismissing(clay_top_altitude(index_clatlon_nadir)))) then
                     wseviri_data_touch(icount_touch, 4) = avg(clay_top_altitude(index_clatlon_nadir))
                  end if
                  icount_touch = icount_touch + 1
                  end if
                  delete([/index_touch/])
               else if (num_uncertain .gt. num_untouch .and. \
                        num_uncertain .gt. num_touch) then
                  index_uncertain = ind(aclay_altitude_diff(index_clatlon_nadir) .le. 0.75 .and. \
                                        aclay_altitude_diff(index_clatlon_nadir) .ge. 0.10)
                  if (.not.all(ismissing(index_uncertain))) then
                  seviri_data_uncertain(index_lat(i), index_lon(j)) = \
                  (/seviri_data_day(index_lat(i), index_lon(j))/)
;  @@@PREPARE DATA FOR PUTTING THEM INTO AN ARRAY@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
                  wseviri_data_uncertain(icount_uncertain, 0) = (/lat(index_lat(i))/)
                  wseviri_data_uncertain(icount_uncertain, 1) = (/lon(index_lon(j))/)
                  wseviri_data_uncertain(icount_uncertain, 2) = seviri_data_day(index_lat(i), index_lon(j))
                  if (.not.all(ismissing(alay_base_altitude(index_clatlon_nadir)))) then
                     wseviri_data_uncertain(icount_uncertain, 3) = avg(alay_base_altitude(index_clatlon_nadir))
                  end if
                  if (.not.all(ismissing(clay_top_altitude(index_clatlon_nadir)))) then
                     wseviri_data_uncertain(icount_uncertain, 4) = avg(clay_top_altitude(index_clatlon_nadir))
                  end if
                  icount_uncertain = icount_uncertain + 1
                  end if
                  delete([/index_uncertain/])
               end if
               end if
               end if
               icount_all = icount_all + 1
            end if
            delete([index_clatlon_nadir])
         end do ; j
      end do ; i
   end if
   delete([/index_lat, index_lon/])

   seviri_data_all_day(1, 0, ictrack_real, :, :) = (/seviri_data_all/)
   seviri_data_all_day(1, 1, ictrack_real, :, :) = (/seviri_data_untouch/)
   seviri_data_all_day(1, 2, ictrack_real, :, :) = (/seviri_data_touch/)
   seviri_data_all_day(1, 3, ictrack_real, :, :) = (/seviri_data_uncertain/)
   wseviri_data_all_day(1, 0, (ictrack_real*ncount_write):((ictrack_real+1)*ncount_write-1), :) = \
   (/wseviri_data_all/)
   wseviri_data_all_day(1, 1, (ictrack_real*ncount_write):((ictrack_real+1)*ncount_write-1), :) = \
   (/wseviri_data_untouch/)
   wseviri_data_all_day(1, 2, (ictrack_real*ncount_write):((ictrack_real+1)*ncount_write-1), :) = \
   (/wseviri_data_touch/)
   wseviri_data_all_day(1, 3, (ictrack_real*ncount_write):((ictrack_real+1)*ncount_write-1), :) = \
   (/wseviri_data_uncertain/)

print("icount_all       = " + icount_all)
print("icount_untouch   = " + icount_untouch)
print("icount_touch     = " + icount_touch)
print("icount_uncertain = " + icount_uncertain)

return
end
