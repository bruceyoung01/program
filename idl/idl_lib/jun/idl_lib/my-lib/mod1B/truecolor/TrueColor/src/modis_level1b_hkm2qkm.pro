FUNCTION MODIS_LEVEL1B_HKM2QKM, IMAGE_500

;- Interpolate MODIS 500 meter resolution image data to 250 meter resolution
;- Note: Assumes that the centers of the first 1KM, HKM, and QKM pixels
;- on each earth scan are co-registered.

compile_opt idl2

;- Get input array dimensions
dims = size(image_500, /dimensions)
ncol = dims[0]
nrow = dims[1]
nscan = nrow / 20
if (ncol ne 2708) then message, 'Input array does not have 2708 columns'

;- Create 250 meter image
image_250 = fltarr(2 * ncol, 2 * nrow, /nozero)

;- Interpolate to 250 meter resolution
x = findgen(ncol * 2) * 0.5
y = [0.0, findgen(38) * 0.5 + 0.25, 19.0]
for scan = 0, nscan - 1 do begin
  j0 = 20 * scan
  j1 = 20 * scan + 19
  k0 = 40 * scan
  k1 = 40 * scan + 39
  image_250[*, k0 : k1] = interpolate(image_500[*, j0 : j1], x, y, /grid)
endfor

;- Return the result
return, image_250

END
