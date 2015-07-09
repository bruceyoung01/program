; $ID: read_viirs_cloudmask_1day.ncl V01 08/08/2012 10:37 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE read_viirs_cloudmask_1day READS VIIRS CLOUD DATA INTO ONE 2-D 
;  ARRAY, INCLUDING LATITUDE, LONGITUDE, AND CLOUD MASK.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (08/08/2012)
;******************************************************************************

undef("read_viirs_cloudmask_1day")
procedure read_viirs_cloudmask_1day \
         (dir       :string,   bv0      :string,   \ ; INPUT
          iday      :integer,                      \ ; INPUT
          startinx  :integer,  endinx   :integer,  \ ; INPUT
          filename1 :string,   filename2:string,   \ ; INPUT
          date_title:string,                       \ ; OUTPUT
          lat       :float,    lon      :float,    \ ; OUTPUT
          aod_qf    :integer,  aod      :float,    \ ; OUTPUT
          sza       :float,    mp       :float)      ; OUTPUT

begin
;  GET ALL THE FILENAME IN ONE DAY
   ninx = endinx(iday) - startinx(iday) + 1
   tmpfilename1 = new(ninx, string, bv0)
   tmpfilename2 = new(ninx, string, bv0)
   tmpfilename1 = filename1(startinx(iday):endinx(iday))
   tmpfilename2 = filename2(startinx(iday):endinx(iday))
;  GET DATE TITLE
   date_title   = str_get_cols(filename1(startinx(iday)), 6, 27) + "_" + \
                  str_get_cols(filename1(endinx(iday)),  29, 36)
   k = 0
;  DO FILE NAME LOOP IN ONE DAY
   do i = 0, ninx-1
    print("NOW READING VIIRS FILE : " + tmpfilename2(i))
;  READ LATITUDE, LONGITUDE, AND AOD
    a          = addfile(dir + tmpfilename1(i), "r")
    b          = addfile(dir + tmpfilename2(i), "r")
    tem_lat    = a->$"Latitude"$
    tem_lon    = a->$"Longitude"$
    tem_aod    = b->$"QF1_VIIRSCMIP"$
    tem_aod_qf = b->$"QF2_VIIRSCMIP"$
    tem_sza    = a->$"SatelliteZenithAngle"$
    tem_mp     = a->$"SatelliteZenithAngle"$

;  COLLECT ALL THE DATA INTO ONE 2-D ARRAY
    ntem_lat = dimsizes(tem_lat)
    np       = ntem_lat(0)
    nl       = ntem_lat(1)
    lat((np*k):(np*(k+1)-1), 0:nl-1)   = tem_lat
    lon((np*k):(np*(k+1)-1), 0:nl-1)   = tem_lon
    aod_qf((np*k):(np*(k+1)-1), 0:nl-1)= tem_aod_qf(:, :)
    aod((np*k):(np*(k+1)-1), 0:nl-1)   = tem_aod
    sza((np*k):(np*(k+1)-1), 0:nl-1)   = tem_sza
    mp ((np*k):(np*(k+1)-1), 0:nl-1)   = tem_mp
   delete([/tem_lat, tem_lon, tem_aod, tem_aod_qf, tem_sza, tem_mp/])
   k = k + 1
  end do
  aod@lat2d = lat
  aod@lon2d = lon

return

end
