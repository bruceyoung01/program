FUNCTION MODIS_GEO_INTERP_250, DATA

compile_opt idl2

;- Interpolate 1000 meter resolution geolocation data to 250 meter resolution

;- Get size of input array (1000 meter resolution)
dims = size(data, /dimensions)
ncol = dims[0]
nrow = dims[1]
nscan = nrow / 10

;- Interpolate to 250 meter resolution
result = fltarr(4 * ncol, 4 * nrow)
x = findgen(4 * ncol) * 0.25
y = findgen(40) * 0.25 - 0.375
for scan = 0, nscan - 1 do begin

  ;- Use bilinear interpolation for all 250 meter pixels
  j0 = 10 * scan
  j1 = 10 * scan + 9
  k0 = 40 * scan
  k1 = 40 * scan + 39
  result[*, k0 : k1] = interpolate(data[*, j0 : j1], x, y, /grid)

  ;- Use linear extrapolation for the first two 250 meter pixels along track
  m = (result[*, k0 + 5] - result[*, k0 + 2]) / (y[5] - y[2])
  b = result[*, k0 + 5] - m * y[5]
  result[*, k0 + 0] = m * y[0] + b
  result[*, k0 + 1] = m * y[1] + b
      
  ;- Use linear extrapolation for the last two 250 meter pixels along track
  m = (result[*, k0 + 37] - result[*, k0 + 34]) / (y[37] - y[34])
  b = result[*, k0 + 37] - m * y[37]
  result[*, k0 + 38] = m * y[38] + b
  result[*, k0 + 39] = m * y[39] + b
      
endfor

;- Return the interpolated array
return, result

END
