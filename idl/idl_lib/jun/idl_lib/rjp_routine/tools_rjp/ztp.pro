function ztp, alt

;   -------------------------------------------------------------------------
; PURPOSE - Compute the properties of the 1976 standard atmosphere to 86 km.
; AUTHOR - Ralph Carmichael, Public Domain Aeronautical Software
; NOTE - If alt > 86, the values returned will not be correct, but they will
;   not be too far removed from the correct values for density.
;   The reference document does not use the terms pressure and temperature
;   above 86 km.

  pbottom = 1013.25
  ptop    = 0.1

  tol   = 1.e-5
  error = call_function('ptz',pbottom)-alt ; absolute error

  if error(0) gt 0 then begin
     print, 'Pressure is greater than ', pbottom
     stop
  endif

  error = (call_function('ptz',ptop)-alt) ; absolute error
  if error(0) lt 0 then begin
     print, 'Pressure is smaller than', ptop
     stop
  endif

  while (abs(error(0)) ge tol) do begin
   press = 0.5*(pbottom+ptop)
   error = call_function('ptz',press)-alt
   if error(0) ge 0. then ptop = press else pbottom = press
  end
  
 return, press

end
