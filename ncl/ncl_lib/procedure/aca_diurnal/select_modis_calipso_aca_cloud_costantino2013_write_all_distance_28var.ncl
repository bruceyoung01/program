;  $ID: select_modis_calipso_aca_cloud_costantino2013_write_all_distance_28var.ncl 
;       V01 07/01/2015 23:52 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE select_modis_calipso_aca_cloud_costantino2013_write_all_distance_28var 
;  SELECTS ALL THE MODIS GRIDS WITH THE RELATIVE VERTICAL POSITION OF AEROSOL 
;  AND CLOUD, WHICH INCLUDES TOUCH AND UNTOUCH.
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
;  (3 ) lat      (2-D):LATITUDE FOR MODIS DATA                            [DEG]
;  (4 ) lon      (2-D):LONGITUDE FOR MODIS DATA                           [DEG]
;  (5 ) minlat (scalar):MINIMUM LATITUDE IN THE STUDY REGION              [DEG]
;  (6 ) maxlat (scalar):MAXIMUM LATITUDE IN THE STUDY REGION              [DEG]
;  (7 ) minlon (scalar):MINIMUM LONGITUDE IN THE STUDY REGION             [DEG]
;  (8 ) maxlon (scalar):MAXIMUM LONGITUDE IN THE STUDY REGION             [DEG]
;  (9 ) iday_or_night(scalar):SCALAR TO DETERMINE DAY TIME OR NIGHT TIME  [   ]
;  (10) alay_base_altitude (1-D):AEROSOL BASE LAYER ALTITUDE              [KM ]
;  (11) clay_top_altitude  (1-D):CLOUD TOP LAYER ALTITUDE                 [KM ]
;  (12) modis_data_day     (2-D):MODIS DATA                               [   ]
;  (13) wmodis_caliop_data(2-D):WRITE DATA INCLUDING ALL THE CASES       [   ]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE REFERING THE REFERENCES MENTIONED ABOVE.
;       (06/22/2015)
;  (2 ) MODIFIED FROM select_amsre_calipso_aca_cloud_costantino2013_write.ncl
;       (06/30/2015)
;  (3 ) MODIFIED FROM select_seviri_calipso_aca_cloud_costantino2013_write.ncl
;       BY REDUCING THE # OF OUTPUT VARIABLES. (BRUCE, 07/01/2015)
;  (4 ) MODIFIED FROM select_modis_calipso_aca_cloud_costantino2013_write_all_28var.ncl
;       BY EMPLOYING THE MODIS DATA SELECTION METHOD FROM COSTANTINO ET AL., 
;       2013, ACP, WHICH IS AS "All MODIS retrievals within a 20 km radius from 
;       the CALIPSO target are averaged together, to provide single estimates 
;       of cloud and aerosol parameters for each CALIPSO shot."
;       (BRUCE, 07/28/2015)
;  (5 ) USING ONE ARRAY TO HOLD ALL THE CALIOP DATA. (BRUCE, 07/28/2015)
;******************************************************************************
undef("select_modis_calipso_aca_cloud_costantino2013_write_all_distance_28var")
procedure select_modis_calipso_aca_cloud_costantino2013_write_all_distance_28var \
          (bv2                 :float,   ictrack_real          :integer,\;INPUT
           nelement_write      :integer, ncount_write          :integer,\;INPUT
           clat                :float,   clon                  :float,  \;INPUT
           minlat              :float,   maxlat                :float,  \;INPUT
           minlon              :float,   maxlon                :float,  \;INPUT
           caliop_data         :float,                                  \;INPUT
           lat_1km             :float,   lon_1km               :float,  \;INPUT
           modis_1km           :float,                                  \;INPUT
           lat_10km            :float,   lon_10km              :float,  \;INPUT
           modis_10km          :float,                                  \;INPUT
           lat_5km             :float,   lon_5km               :float,  \;INPUT
           modis_5km           :float,                                  \;INPUT
           wmodis_caliop_data  :numeric)                                 ;OUTPUT

begin
   dim_write                    = (/ncount_write, nelement_write/)
   wmodis_caliop_data_all       = new(dim_write, float, bv2)
   wmodis_caliop_data_untouch   = new(dim_write, float, bv2)
   wmodis_caliop_data_touch     = new(dim_write, float, bv2)
   wmodis_caliop_data_uncertain = new(dim_write, float, bv2)
   wmodis_caliop_data_noaca     = new(dim_write, float, bv2)

;  GET THE NADIR LATITUDE AND LONGITUDE FROM CALIPSO TRACK
   clat_nadir = clat(:, 1)
   clon_nadir = clon(:, 1)

;  CALCULATE THE DISTANCE BETWEEN ACA BASE AND CLOUD TOP
   aclayer_altitude_diff = caliop_data(:, 4) - caliop_data(:, 11)

;  SELECT MODIS DATA IN THE STUDY REGION
   index_clatlon_nadir = ind(clat_nadir .ge. minlat .and. \
                             clat_nadir .le. maxlat .and. \
                             clon_nadir .ge. minlon .and. \
                             clon_nadir .le. maxlon .and. \
                             aclayer_altitude_diff .gt. 0.0)
   if (.not.all(ismissing(index_clatlon_nadir))) then
      nindex_clatlon_nadir = dimsizes(index_clatlon_nadir)
;  DO LOOP FOR MODIS LATITUDE AND LONGITUDE TO SELECT MODIS GRIDS HAVING 
;  ACA AND CLOUD RELATIVE VERTICAL POSITION
;  PLEASE NOTE: LATITUDE AND LONGITUDE FROM MODIS ARE FOR THE GRID CENTER
      icount_all       = 0
      icount_untouch   = 0
      icount_touch     = 0
      icount_uncertain = 0
      do i = 0, nindex_clatlon_nadir-1
;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;  ALL
;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
         wmodis_caliop_data_all(icount_all, 0) = (/clat_nadir(index_clatlon_nadir(i))/)
         wmodis_caliop_data_all(icount_all, 1) = (/clon_nadir(index_clatlon_nadir(i))/)

;  CALCULATE THE DISTANCE BETWEEN MODIS AND CALIOP DATA
;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;  FOR 1KM MODIS DATA
;  CONVERT 2-D ARRAY TO 1-D ARRAY
         lat_1km_oned    = ndtooned(lat_1km)
         lon_1km_oned    = ndtooned(lon_1km)
         modis_1km1_oned = ndtooned(modis_1km(0, :, :))
         modis_1km2_oned = ndtooned(modis_1km(1, :, :))
         modis_1km3_oned = ndtooned(modis_1km(2, :, :))
         gcdist_1km      = gc_latlon(clat_nadir(index_clatlon_nadir(i)), \
                                     clon_nadir(index_clatlon_nadir(i)), \
                                     lat_1km_oned, lon_1km_oned, 2, -4)
         index_1km       = ind(gcdist_1km .le. 20.0)
         if (.not.all(ismissing(index_1km))) then
            wmodis_caliop_data_all(icount_all, 2) = avg(modis_1km1_oned(index_1km))
            wmodis_caliop_data_all(icount_all, 3) = avg(modis_1km2_oned(index_1km))
            wmodis_caliop_data_all(icount_all, 4) = avg(modis_1km3_oned(index_1km))
         end if
;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;  FOR 10KM MODIS DATA
;  CONVERT 2-D ARRAY TO 1-D ARRAY
         lat_10km_oned    = ndtooned(lat_10km)
         lon_10km_oned    = ndtooned(lon_10km)
         modis_10km1_oned = ndtooned(modis_10km(0, :, :))
         modis_10km2_oned = ndtooned(modis_10km(1, :, :))
         gcdist_10km      = gc_latlon(clat_nadir(index_clatlon_nadir(i)), \
                                      clon_nadir(index_clatlon_nadir(i)), \
                                      lat_10km_oned, lon_10km_oned, 2, -4)
         index_10km       = ind(gcdist_10km .le. 20.0)
         if (.not.all(ismissing(index_10km))) then
            wmodis_caliop_data_all(icount_all, 5) = avg(modis_10km1_oned(index_10km))
            wmodis_caliop_data_all(icount_all, 6) = avg(modis_10km2_oned(index_10km))
         end if
;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;  FOR 5KM MODIS DATA
;  CONVERT 2-D ARRAY TO 1-D ARRAY
         lat_5km_oned    = ndtooned(lat_5km)
         lon_5km_oned    = ndtooned(lon_5km)
         modis_5km1_oned = ndtooned(modis_5km(0, :, :))
         modis_5km2_oned = ndtooned(modis_5km(1, :, :))
         gcdist_5km      = gc_latlon(clat_nadir(index_clatlon_nadir(i)), \
                                     clon_nadir(index_clatlon_nadir(i)), \
                                     lat_5km_oned, lon_5km_oned, 2, -4)
         index_5km       = ind(gcdist_5km .le. 20.0)
         if (.not.all(ismissing(index_5km))) then
            wmodis_caliop_data_all(icount_all, 7) = avg(modis_5km1_oned(index_5km))
            wmodis_caliop_data_all(icount_all, 8) = avg(modis_5km2_oned(index_5km))
         end if
         wmodis_caliop_data_all(icount_all, 9:27) = caliop_data(index_clatlon_nadir(i), :)
         icount_all = icount_all + 1
;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;  UNTOUCH
;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
         if (aclayer_altitude_diff(index_clatlon_nadir(i)) .ge. 0.75) then
            wmodis_caliop_data_untouch(icount_untouch, 0) = (/clat_nadir(index_clatlon_nadir(i))/)
            wmodis_caliop_data_untouch(icount_untouch, 1) = (/clon_nadir(index_clatlon_nadir(i))/)
            if (.not.all(ismissing(index_1km))) then
               wmodis_caliop_data_untouch(icount_untouch, 2) = avg(modis_1km1_oned(index_1km))
               wmodis_caliop_data_untouch(icount_untouch, 3) = avg(modis_1km2_oned(index_1km))
               wmodis_caliop_data_untouch(icount_untouch, 4) = avg(modis_1km3_oned(index_1km))
            end if
            if (.not.all(ismissing(index_10km))) then
               wmodis_caliop_data_untouch(icount_untouch, 5) = avg(modis_10km1_oned(index_10km))
               wmodis_caliop_data_untouch(icount_untouch, 6) = avg(modis_10km2_oned(index_10km))
            end if
            if (.not.all(ismissing(index_5km))) then
               wmodis_caliop_data_untouch(icount_untouch, 7) = avg(modis_5km1_oned(index_5km))
               wmodis_caliop_data_untouch(icount_untouch, 8) = avg(modis_5km2_oned(index_5km))
            end if
            wmodis_caliop_data_untouch(icount_untouch, 9:27) = caliop_data(index_clatlon_nadir(i), :)
            icount_untouch = icount_untouch + 1
         end if
;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;  TOUCH
;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
         if (aclayer_altitude_diff(index_clatlon_nadir(i)) .le. 0.10 .and. \
             aclayer_altitude_diff(index_clatlon_nadir(i)) .gt. 0.00) then
            wmodis_caliop_data_touch(icount_touch, 0) = (/clat_nadir(index_clatlon_nadir(i))/)
            wmodis_caliop_data_touch(icount_touch, 1) = (/clon_nadir(index_clatlon_nadir(i))/)
            if (.not.all(ismissing(index_1km))) then
               wmodis_caliop_data_touch(icount_touch, 2) = avg(modis_1km1_oned(index_1km))
               wmodis_caliop_data_touch(icount_touch, 3) = avg(modis_1km2_oned(index_1km))
               wmodis_caliop_data_touch(icount_touch, 4) = avg(modis_1km3_oned(index_1km))
            end if
            if (.not.all(ismissing(index_10km))) then
               wmodis_caliop_data_touch(icount_touch, 5) = avg(modis_10km1_oned(index_10km))
               wmodis_caliop_data_touch(icount_touch, 6) = avg(modis_10km2_oned(index_10km))
            end if
            if (.not.all(ismissing(index_5km))) then
               wmodis_caliop_data_touch(icount_touch, 7) = avg(modis_5km1_oned(index_5km))
               wmodis_caliop_data_touch(icount_touch, 8) = avg(modis_5km2_oned(index_5km))
            end if
            wmodis_caliop_data_touch(icount_touch, 9:27) = caliop_data(index_clatlon_nadir(i), :)
            icount_touch = icount_touch + 1
         end if
;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;  UNCERTAIN
;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
         if (aclayer_altitude_diff(index_clatlon_nadir(i)) .gt. 0.10 .and. \
             aclayer_altitude_diff(index_clatlon_nadir(i)) .lt. 0.75) then
            wmodis_caliop_data_uncertain(icount_uncertain, 0) = (/clat_nadir(index_clatlon_nadir(i))/)
            wmodis_caliop_data_uncertain(icount_uncertain, 1) = (/clon_nadir(index_clatlon_nadir(i))/)
            if (.not.all(ismissing(index_1km))) then
               wmodis_caliop_data_uncertain(icount_uncertain, 2) = avg(modis_1km1_oned(index_1km))
               wmodis_caliop_data_uncertain(icount_uncertain, 3) = avg(modis_1km2_oned(index_1km))
               wmodis_caliop_data_uncertain(icount_uncertain, 4) = avg(modis_1km3_oned(index_1km))
            end if
            if (.not.all(ismissing(index_10km))) then
               wmodis_caliop_data_uncertain(icount_uncertain, 5) = avg(modis_10km1_oned(index_10km))
               wmodis_caliop_data_uncertain(icount_uncertain, 6) = avg(modis_10km2_oned(index_10km))
            end if
            if (.not.all(ismissing(index_5km))) then
               wmodis_caliop_data_uncertain(icount_uncertain, 7) = avg(modis_5km1_oned(index_5km))
               wmodis_caliop_data_uncertain(icount_uncertain, 8) = avg(modis_5km2_oned(index_5km))
            end if
            wmodis_caliop_data_uncertain(icount_uncertain, 9:27) = caliop_data(index_clatlon_nadir(i), :)
            icount_uncertain = icount_uncertain + 1
         end if
         delete([/index_1km, index_10km, index_5km/])
      end do ; i
      print("icount_all       = " + icount_all)
      print("icount_untouch   = " + icount_untouch)
      print("icount_touch     = " + icount_touch)
      print("icount_uncertain = " + icount_uncertain)
   end if
   delete([/index_clatlon_nadir/])

;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;  NO ACA
;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;  SELECT MODIS DATA IN THE STUDY REGION
   index_clatlon_nadir = ind(clat_nadir .ge. minlat .and. \
                             clat_nadir .le. maxlat .and. \
                             clon_nadir .ge. minlon .and. \
                             clon_nadir .le. maxlon .and. \
                             aclayer_altitude_diff .le. 0.0)
   if (.not.all(ismissing(index_clatlon_nadir))) then
      nindex_clatlon_nadir = dimsizes(index_clatlon_nadir)
;  DO LOOP FOR MODIS LATITUDE AND LONGITUDE TO SELECT MODIS GRIDS HAVING 
;  ACA AND CLOUD RELATIVE VERTICAL POSITION
;  PLEASE NOTE: LATITUDE AND LONGITUDE FROM MODIS ARE FOR THE GRID CENTER
      icount_noaca     = 0
      do i = 0, nindex_clatlon_nadir-1
         wmodis_caliop_data_noaca(icount_noaca, 0) = (/clat_nadir(index_clatlon_nadir(i))/)
         wmodis_caliop_data_noaca(icount_noaca, 1) = (/clon_nadir(index_clatlon_nadir(i))/)

;  CALCULATE THE DISTANCE BETWEEN MODIS AND CALIOP DATA
;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;  FOR 1KM MODIS DATA
;  CONVERT 2-D ARRAY TO 1-D ARRAY
         lat_1km_oned    = ndtooned(lat_1km)
         lon_1km_oned    = ndtooned(lon_1km)
         modis_1km1_oned = ndtooned(modis_1km(0, :, :))
         modis_1km2_oned = ndtooned(modis_1km(1, :, :))
         modis_1km3_oned = ndtooned(modis_1km(2, :, :))
         gcdist_1km      = gc_latlon(clat_nadir(index_clatlon_nadir(i)), \
                                     clon_nadir(index_clatlon_nadir(i)), \
                                     lat_1km_oned, lon_1km_oned, 2, -4)
         index_1km       = ind(gcdist_1km .le. 20.0)
         if (.not.all(ismissing(index_1km))) then
            wmodis_caliop_data_noaca(icount_noaca, 2) = avg(modis_1km1_oned(index_1km))
            wmodis_caliop_data_noaca(icount_noaca, 3) = avg(modis_1km2_oned(index_1km))
            wmodis_caliop_data_noaca(icount_noaca, 4) = avg(modis_1km3_oned(index_1km))
         end if
;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;  FOR 10KM MODIS DATA
;  CONVERT 2-D ARRAY TO 1-D ARRAY
         lat_10km_oned    = ndtooned(lat_10km)
         lon_10km_oned    = ndtooned(lon_10km)
         modis_10km1_oned = ndtooned(modis_10km(0, :, :))
         modis_10km2_oned = ndtooned(modis_10km(1, :, :))
         gcdist_10km      = gc_latlon(clat_nadir(index_clatlon_nadir(i)), \
                                      clon_nadir(index_clatlon_nadir(i)), \
                                      lat_10km_oned, lon_10km_oned, 2, -4)
         index_10km       = ind(gcdist_10km .le. 20.0)
         if (.not.all(ismissing(index_10km))) then
            wmodis_caliop_data_noaca(icount_noaca, 5) = avg(modis_10km1_oned(index_10km))
            wmodis_caliop_data_noaca(icount_noaca, 6) = avg(modis_10km2_oned(index_10km))
         end if
;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;  FOR 5KM MODIS DATA
;  CONVERT 2-D ARRAY TO 1-D ARRAY
         lat_5km_oned    = ndtooned(lat_5km)
         lon_5km_oned    = ndtooned(lon_5km)
         modis_5km1_oned = ndtooned(modis_5km(0, :, :))
         modis_5km2_oned = ndtooned(modis_5km(1, :, :))
         gcdist_5km      = gc_latlon(clat_nadir(index_clatlon_nadir(i)), \
                                     clon_nadir(index_clatlon_nadir(i)), \
                                     lat_5km_oned, lon_5km_oned, 2, -4)
         index_5km       = ind(gcdist_5km .le. 20.0)
         if (.not.all(ismissing(index_5km))) then
            wmodis_caliop_data_noaca(icount_noaca, 7) = avg(modis_5km1_oned(index_5km))
            wmodis_caliop_data_noaca(icount_noaca, 8) = avg(modis_5km2_oned(index_5km))
         end if
         wmodis_caliop_data_noaca(icount_noaca, 9:27) = caliop_data(index_clatlon_nadir(i), :)
         icount_noaca = icount_noaca + 1
         delete([/index_1km, index_10km, index_5km/])
      end do ;i
      print("icount_noaca     = " + icount_noaca)
   end if

   wmodis_caliop_data(0, (ictrack_real*ncount_write):((ictrack_real+1)*ncount_write-1), :) = \
   (/wmodis_caliop_data_all/)
   wmodis_caliop_data(1, (ictrack_real*ncount_write):((ictrack_real+1)*ncount_write-1), :) = \
   (/wmodis_caliop_data_untouch/)
   wmodis_caliop_data(2, (ictrack_real*ncount_write):((ictrack_real+1)*ncount_write-1), :) = \
   (/wmodis_caliop_data_touch/)
   wmodis_caliop_data(3, (ictrack_real*ncount_write):((ictrack_real+1)*ncount_write-1), :) = \
   (/wmodis_caliop_data_uncertain/)
   wmodis_caliop_data(4, (ictrack_real*ncount_write):((ictrack_real+1)*ncount_write-1), :) = \
   (/wmodis_caliop_data_noaca/)

return
end
