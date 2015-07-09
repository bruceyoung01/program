;
;  geos_grid.pro
;  xxu, 01/13/10
;
;  GEOS-Chem model grid info

   PRO geos_grid_CN, position, nlon, nlat, lon_cmt, lat_cmt


;  longitude and latitude limitations and centers of 
;  GEOS-Chem 0.5 X 0.666 China nested grid

    blat = 10
    tlat = 55
    wlon = 70
    elon = 140

    position = [wlon,elon,blat,tlat]

    nlat = (tlat-blat)*2+1
    nlon = (elon-wlon)*3/2+1

    lon_cmt = wlon+findgen(nlon)*2/3.
    lat_cmt = blat+findgen(nlat)/2.


    END

