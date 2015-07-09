FUNCTION SCALE_IMAGE, IMAGE, X, Y

;- Create scaled image with specified histogram
;- X is an array of input values
;- Y is an array of specified output values

;- Create output array
dims = size(image, /dimensions)
nx = dims[0]
ny = dims[1]
scaled = bytarr(nx, ny)

;- Scale the image
for index = 0, n_elements(x) - 2 do begin
  x1 = x[index]
  x2 = x[index + 1]
  y1 = y[index]
  y2 = y[index + 1]
  m = (y2 - y1) / float((x2 - x1))
  b = y2 - (m * x2)
  mask = (image ge x1) and (image lt x2)
  scaled = scaled + mask * byte(m * image + b)
endfor

;- Scale the pixels greater than the maximum value
mask = image ge x2
scaled = scaled + (mask * 255B)

;- Return the result
return, scaled

END

FUNCTION ENHANCE, BAND01, BAND03, BAND04, RANGE=RANGE, CLOUD=CLOUD

;- Apply piecewise linear enhancement to MODIS corrected reflectance images where
;- BAND01, BAND03, BAND04 are corrected reflectances for MODIS bands 1, 3, 4.

;- Check keywords
if (n_elements(band01) eq 0) then message, 'Argument BAND01 is undefined'
if (n_elements(band03) eq 0) then message, 'Argument BAND03 is undefined'
if (n_elements(band04) eq 0) then message, 'Argument BAND04 is undefined'
if (n_elements(range) eq 0) then range = [0.0, 1.1]

;- Rapid Response default enhancement: 0,0, 30,110, 60,160, 120,210, 190,240, 255,255
x = byte([0,  30,  60, 120, 190, 255])
y = byte([0, 110, 160, 210, 240, 255])

;- Rapid Response cloud enhancement: 0,0, 25,90, 55,140, 100,175, 255,255
if keyword_set(cloud) then begin
  x = byte([0, 25,  55, 100, 255])
  y = byte([0, 90, 140, 175, 255])
endif

;- Create output true color image array
dims = size(band01, /dimensions)
nx = dims[0]
ny = dims[1]
true = bytarr(nx, ny, 3, /nozero)

;- Scale each band
true[0, 0, 0] = scale_image(bytscl(band01, min=range[0], max=range[1]), x, y)
true[0, 0, 1] = scale_image(bytscl(band04, min=range[0], max=range[1]), x, y)
true[0, 0, 2] = scale_image(bytscl(band03, min=range[0], max=range[1]), x, y)

;- Return result
return, true

END
