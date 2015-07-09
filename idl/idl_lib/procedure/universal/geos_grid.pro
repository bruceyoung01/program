;
; define the GC grid 
;

pro geos_grid, index,nlat,nlon,lat,lon

; China/SE Asia 0.5 ° x 0.667 ° nested grid
;      LON: [100E,140E]
;      LAT: [ 15N, 55N]

  if ( index eq 1 ) then begin
  
   nlat = 81
   nlon = 61

   lats = 15.
   latn = 55.
   lonw = 100.
   lone = 140.

   lat  = lats + findgen(nlat)*0.5
   lon  = lonw + findgen(nlon)*2./3.

  endif

  return

  end
