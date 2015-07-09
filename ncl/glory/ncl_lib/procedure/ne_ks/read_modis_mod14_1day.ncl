; $ID: read_modis_mod14_1day.ncl V01 08/08/2012 10:37 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE read_modis_mod14_1day READS MODIS MOD04/MOY04 AOD DATA INTO ONE 
;  2-D ARRAY, INCLUDING LATITUDE, LONGITUDE, AND AOD.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (08/08/2012)
;  (2 ) MODIFIED FROM read_modis_aod_1day.ncl. (10/08/2012)
;******************************************************************************

undef("read_modis_mod14_1day")
procedure read_modis_mod14_1day \
         (dir      :string,   bv0      :string,   \ ; INPUT
          iday     :integer,                      \ ; INPUT
          startinx :integer,  endinx   :integer,  \ ; INPUT
          filename :string,                       \ ; INPUT
          lat      :float,    lon      :float,    \ ; OUTPUT
          fp       :float)                          ; OUTPUT

begin
;  GET ALL THE FILENAME IN ONE DAY
   ninx = endinx(iday) - startinx(iday) + 1
   tmpfilename = new(ninx, string, bv0)
   tmpfilename = filename(startinx(iday):endinx(iday))

   np = 0
;  DO FILE NAME LOOP IN ONE DAY
   do i = 0, ninx-1
    print("NOW READING MODIS FILE : " + tmpfilename(i))
;  READ LATITUDE, LONGITUDE, AND AOD
    a        = addfile(dir + tmpfilename(i), "r")
    fire_mask= a->fire_mask
    nfire    = num(fire_mask .gt. 6)
    if (nfire .gt. 0) then
    tem_lat  = a->FP_latitude
    tem_lon  = a->FP_longitude

;  COLLECT ALL THE DATA INTO ONE 2-D ARRAY
    ntem_lat = dimsizes(tem_lat)
    if (i .eq. 0 .or. np .eq. 0) then
     lat(0:(ntem_lat(0)-1)) = tem_lat
     lon(0:(ntem_lat(0)-1)) = tem_lon
     fp (0:(ntem_lat(0)-1)) = 1.0
    else if (i .ge. 1 .and. np .gt. 0) then
     lat(np:(np+ntem_lat(0)-1)) = tem_lat
     lon(np:(np+ntem_lat(0)-1)) = tem_lon
     fp (np:(np+ntem_lat(0)-1)) = 1.0
    end if
    end if
    np = np + ntem_lat(0)
   delete([/tem_lat, tem_lon/])
   end if
   delete([/fire_mask/])
   end do

return

end
