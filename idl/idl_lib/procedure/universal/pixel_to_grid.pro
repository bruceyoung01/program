; $ID: pixel_to_grid.pro V01 04/18/2012 23:04 BRUCE EXP$
;
;******************************************************************************
;  SUBROUTINE pixel_to_grid INTERPOLATES THE PIXEL DATA INTO GRID DATA.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) gclat     (float)  : LATITUDE IN EACH GRID BOX (2-D)              [deg]
;  (2 ) gclon     (float)  : LONGITUDE IN EACH GRID BOX (2-D)             [deg]
;  (3 ) npgc      (integer): # OF LATITUDE GRID                           [---]
;  (4 ) nlgc      (integer): # OF LONGITUDE GRID                          [---]
;  (5 ) flat      (float)  : LATITUDE OF PIXEL DATA (2-D)                 [deg]
;  (6 ) flon      (float)  : LONGITUDE OF PIXEL DATA (2-D)                [deg]
;  (7 ) np        (integer): # OF PIXELS OF GRANULE WIDTH                 [---]
;  (8 ) nl        (integer): # OF PIXELS OF GRANULE LENGTH                [---]
;  (9 ) minpixel  (integer): THRESHOLD OF MINIMUM # OF PIXELS IN EACH GRID[---]
;  (10) pdat      (float)  : PIXEL DATA                                   [---]
;  (11) gdat      (float)  : GRID DATA                                    [---]
;  (12) pcon      (float)  : # OF PIXELS IN EACH GRID                     [---]
;  (13) stdd      (float)  : STANDARD DEVIATION OF PIXEL DATA IN EACH GRID[---]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY BY RICHARD. (NOT CLEAR)
;  (2 ) MODIFIED BY BRUCE. (04/18/2012)
;******************************************************************************

  pro  pixel_to_grid, gclat,gclon,npgc,nlgc, $
                      flat,flon,np,nl,       $
                      minpixel,pdat,gdat,    $
                      pcon=pcon,stdd=stdd

; define arrays
  gdat = fltarr(npgc,nlgc) - 999.
  stdd = gdat
  pcon = intarr(npgc,nlgc)

; start gc grid loop

  dx = (gclon[1]-gclon[0])/2.
  dy = (gclat[1]-gclat[0])/2.

  for j = 0, nlgc-1 do begin
  for i = 0, npgc-1 do begin

   idx_grid = where(flat[0:np-1,0:nl-1] GE gclat[j]-dy AND $
                    flat[0:np-1,0:nl-1] LT gclat[j]+dy AND $
                    flon[0:np-1,0:nl-1] GE gclon[i]-dx AND $
                    flon[0:np-1,0:nl-1] LT gclon[i]+dx AND $
                    pdat[0:np-1,0:nl-1] GT 0., count_grid)

   if ( count_grid GE minpixel ) THEN BEGIN
     pcon[i,j] = count_grid
     gdat[i,j] =   mean( pdat[idx_grid] )
     stdd[i,j] = stddev( pdat[idx_grid] ) 
   endif else begin
     pcon[i,j] = 0
     gdat[i,j] = -999.
     stdd[i,j] = -999.
   endelse

  endfor
  endfor

; end of routine
  return
  end
