; $ID: read_viirs_rad_1day.ncl V01 08/08/2012 10:37 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE read_viirs_rad_1day READS VIIRS SVDNB RADIANCE DATA INTO ONE 2-D 
;  ARRAY, INCLUDING LATITUDE, LONGITUDE, AND AOD.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (08/08/2012)
;******************************************************************************

undef("read_viirs_rad_1day")
procedure read_viirs_rad_1day \
         (dir      :string,   bv0      :string,   \ ; INPUT
          iday     :integer,                      \ ; INPUT
          startinx :integer,  endinx   :integer,  \ ; INPUT
          filename1:string,   filename2:string,   \ ; INPUT
          lat      :float,    lon      :float,    \ ; OUTPUT
          aod_qf   :integer,  aod      :float,    \ ; OUTPUT
          sza      :float)                          ; OUTPUT

begin
;  GET ALL THE FILENAME IN ONE DAY
   ninx = endinx(iday) - startinx(iday) + 1
   tmpfilename1 = new(ninx, string, bv0)
   tmpfilename2 = new(ninx, string, bv0)
   tmpfilename1 = filename1(startinx(iday):endinx(iday))
   tmpfilename2 = filename2(startinx(iday):endinx(iday))

   k = 0
;  DO FILE NAME LOOP IN ONE DAY
   do i = 0, ninx-1
    print("NOW READING VIIRS FILE : " + tmpfilename2(i))
;  READ LATITUDE, LONGITUDE, AND AOD
    a          = addfile(dir + tmpfilename1(i), "r")
    b          = addfile(dir + tmpfilename2(i), "r")
    tem_lat    = a->$"Latitude"$
    tem_lon    = a->$"Longitude"$
    tem_aod    = b->$"Radiance"$
    tem_aod_qf = b->$"QF1_VIIRSDNBSDR"$
    tem_sza    = a->$"SatelliteZenithAngle"$

;  COLLECT ALL THE DATA INTO ONE 2-D ARRAY
    ntem_lat = dimsizes(tem_lat)
    np       = ntem_lat(0)
    nl       = ntem_lat(1)
    lat((np*k):(np*(k+1)-1), 0:nl-1)   = tem_lat
    lon((np*k):(np*(k+1)-1), 0:nl-1)   = tem_lon
    aod_qf((np*k):(np*(k+1)-1), 0:nl-1)= tem_aod_qf(:, :)
    aod((np*k):(np*(k+1)-1), 0:nl-1)   = tem_aod*10^7
    sza((np*k):(np*(k+1)-1), 0:nl-1)   = tem_sza
   delete([/tem_lat, tem_lon, tem_aod, tem_aod_qf, tem_sza/])
   k = k + 1
  end do
  aod@lat2d = lat
  aod@lon2d = lon

return

end
