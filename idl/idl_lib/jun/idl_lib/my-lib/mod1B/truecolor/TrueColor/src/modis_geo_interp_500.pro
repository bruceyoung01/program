FUNCTION MODIS_GEO_INTERP_500, DATA

compile_opt idl2

;- Interpolate 1000 meter resolution geolocation data to 500 meter resolution

;- Get size of input array (1000 meter resolution)
dims = size(data, /dimensions)
ncol = dims[0]
nrow = dims[1]
nscan = nrow / 10

;- Interpolate to 500 meter resolution
result = fltarr(2 * ncol, 2 * nrow)
x = findgen(2 * ncol) * 0.5
y = findgen(20) * 0.5 - 0.25
for scan = 0, nscan - 1 do begin

  ;- Use bilinear interpolation for all 500 meter pixels
  j0 = 10 * scan
  j1 = 10 * scan + 9
  k0 = 20 * scan
  k1 = 20 * scan + 19
  result[*, k0 : k1] = interpolate(data[*, j0 : j1], x, y, /grid)

  ;- Use linear extrapolation for the first 500 meter pixel along track
  m = (result[*, k0 + 2] - result[*, k0 + 1]) / (y[2] - y[1])
  b = result[*, k0 + 2] - m * y[2]
  result[*, k0 + 0] = m * y[0] + b
      
  ;- Use linear extrapolation for the last 500 meter pixel along track
  m = (result[*, k0 + 18] - result[*, k0 + 17]) / (y[18] - y[17])
  b = result[*, k0 + 18] - m * y[18]
  result[*, k0 + 19] = m * y[19] + b
      
endfor

;- Return the interpolated array
return, result

END
