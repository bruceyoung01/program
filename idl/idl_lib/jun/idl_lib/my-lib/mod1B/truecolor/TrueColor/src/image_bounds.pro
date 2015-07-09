PRO IMAGE_BOUNDS, LAT, LON, LATMIN, LATMAX, LONMIN, LONMAX, X1, X2, Y1, Y2

;+
; Purpose:
;    Find lower left (X1, Y1) and upper right (X2, Y2) indices of elements of
;    LAT and LON which are within the bounds LATMIN, LATMAX, LONMIN, LONMAX.
;    If no elements are found within these bounds, -1 is returned for
;    X1, X2, Y1, Y2.
;-

;- Check arguments
if (n_elements(lat) eq 0) then message, 'Argument LAT is undefined'
if (n_elements(lon) eq 0) then message, 'Argument LON is undefined'
if (n_elements(latmin) eq 0) then message, 'Argument LATMIN is undefined'
if (n_elements(latmax) eq 0) then message, 'Argument LATMAX is undefined'
if (n_elements(lonmin) eq 0) then message, 'Argument LONMIN is undefined'
if (n_elements(lonmax) eq 0) then message, 'Argument LONMAX is undefined'

;- Get indices of locations within lat/lon bounds
index = where((lat ge latmin) and (lat le latmax) and $
              (lon ge lonmin) and (lon le lonmax), count)

;- If matching 1D indices were found, convert them to 2D indices
if (count ge 1) then begin

  ;- Convert 1D indices to column and row indices
  dims = size(lat, /dimensions)
  ncol = dims[0]
  col_index = index mod ncol
  row_index = index / ncol

  ;- Get lower left and upper right corner indices
  x1 = min(col_index)
  x2 = max(col_index)
  y1 = min(row_index)
  y2 = max(row_index)

endif else begin

  ;- Set missing values
  x1 = -1L
  x2 = -1L
  y1 = -1L
  y2 = -1L
  
endelse

END
