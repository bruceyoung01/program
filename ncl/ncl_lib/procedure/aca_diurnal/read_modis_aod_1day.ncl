; $ID: read_modis_aod_1day.ncl V01 08/08/2012 10:37 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE read_modis_aod_1day READS MODIS MOD04/MOY04 AOD DATA INTO ONE 2-D 
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

undef("read_modis_aod_1day")
procedure read_modis_aod_1day \
         (dir      :string,   bv0      :string,   \ ; INPUT
          iday     :integer,                      \ ; INPUT
          startinx :integer,  endinx   :integer,  \ ; INPUT
          filename :string,   loro     :string,   \ ; INPUT
          lat      :float,    lon      :float,    \ ; OUTPUT
          aod_qf   :integer,  aod      :float)      ; OUTPUT


begin
;  GET ALL THE FILENAME IN ONE DAY
   ninx = endinx(iday) - startinx(iday) + 1
   tmpfilename = new(ninx, string, bv0)
   tmpfilename = filename(startinx(iday):endinx(iday))

   k = 0
;  DO FILE NAME LOOP IN ONE DAY
   do i = 0, ninx-1
    print("NOW READING MODIS FILE : " + tmpfilename(i))
;  READ LATITUDE, LONGITUDE, AND AOD
    a                 = addfile(dir + tmpfilename(i), "r")
    tem_lat           = a->Latitude
    tem_lon           = a->Longitude
;   tem_aod           = a->$loro$(1, :, :)
    tem_aod           = a->$loro$(:, :)
    tem_aod_qf        = a->Quality_Assurance_Land
    tem_aod_scale     = tem_aod@scale_factor
    tem_aod_offset    = tem_aod@add_offset
    tem_aod_qf_scale  = tem_aod_qf@scale_factor
    tem_aod_qf_offset = tem_aod_qf@add_offset

;  COLLECT ALL THE DATA INTO ONE 2-D ARRAY
    ntem_lat = dimsizes(tem_lat)
    np       = ntem_lat(0)
    nl       = ntem_lat(1)
    lat((np*k):(np*(k+1)-1), 0:nl-1)   = tem_lat
    lon((np*k):(np*(k+1)-1), 0:nl-1)   = tem_lon
    aod_qf((np*k):(np*(k+1)-1), 0:nl-1)= tem_aod_qf(:, :, 0)* \
                                         doubletointeger(tem_aod_qf_scale) + \
                                         doubletointeger(tem_aod_qf_offset)
    aod((np*k):(np*(k+1)-1), 0:nl-1)   = short2flt(tem_aod) + \
                                         doubletofloat(tem_aod_offset)
   delete([/tem_lat, tem_lon, tem_aod, tem_aod_qf/])
   k = k + 1
  end do

return

end
