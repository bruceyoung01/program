function ptzatm, press

;   -------------------------------------------------------------------------
; PURPOSE - Compute the properties of the 1976 standard atmosphere to 86 km.
; AUTHOR - Ralph Carmichael, Public Domain Aeronautical Software
; NOTE - If alt > 86, the values returned will not be correct, but they will
;   not be too far removed from the correct values for density.
;   The reference document does not use the terms pressure and temperature
;   above 86 km.

if n_elements(press) eq 0 then return, 0

  REARTH = 6369.0                 ; radius of the Earth (km)
  GMR = 34.163195                 ; gas constant
  NTAB=8       ; number of entries in the defining tables

htab= [0.0, 11.0, 20.0, 32.0, 47.0, 51.0, 71.0, 84.852]
ttab= [288.15, 216.65, 216.65, 228.65, 270.65, 270.65, 214.65, 186.946]
ptab= [1.0, 2.233611E-1, 5.403295E-2, 8.5666784E-3, 1.0945601E-3, 6.6063531E-4, 3.9046834E-5, 3.68501E-6]
gtab= [-6.5, 0.0, 1.0, 2.8, 0.0, -2.8, -2.0, 0.0]

  delta = press/1013.25

  i = 0
  j = ntab-1

  while (j gt i+1) do begin
    k = (i+j)/2
     if ((-delta) lt (-ptab(k))) then begin
        j = k
     endif else begin
        i = k
     endelse
  end

 tgrad = gtab(i)
 tbase = ttab(i)

 if (tgrad eq 0.0) then begin
    deltah = tbase*alog(delta/ptab(i))/(-GMR)
 endif else begin
    deltah = tbase*((delta/ptab(i))^(-tgrad/GMR)-1.)/tgrad
 endelse

 h = deltah+htab(i)
 tlocal = tbase + tgrad*deltah
 theta = tlocal /ttab(1)
 sigma = delta/theta

 sigma = sigma*1.225*6.022169e+20/28.9644   ; number density of air (#/cm^3)
 theta = tlocal                             ; temperature (K)
 alt = REARTH*h/(REARTH-h)      ; convert geopotential to geometric altitude

return, alt
end
