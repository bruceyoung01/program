; The Gulf of Mexico: 
; Place: Latitude: 20-30°; Longitude: -100 - -80°
; Time: May 7, 2009 1950UTC
; Purpose: to plot the true color image of the Gulf of Mexico using the MODIS data
; Author: Bruce Young
; Date: Sep. 20, 2009

; modification : OCT 25, 2010 Bruce

  @./overlay3band_img.pro
  @./process_day.pro

; define input file dir and name
  filelist  = '2008126mod012km'
  filedir   = '/mnt/sdc/data/modis/ca/mod021km/2008/'
  filedirres= '/home/bruce/program/idl/modis/data/results/2008/'

; read the file names
  process_day, filedir+filelist, nday, filename, startid, endid

; Check if this file is a valid HDF file
  FOR i = 0, nday-1 DO BEGIN

; define array
  npr = 1354L
  nlr = 2030L
  z250= 2
  z500= 5 
  flat   = FLTARR(endid(i)-startid(i)+1, npr, nlr)
  flon   = FLTARR(endid(i)-startid(i)+1, npr, nlr)
  ref250 = FLTARR(endid(i)-startid(i)+1, npr, nlr, z250)
  ref500 = FLTARR(endid(i)-startid(i)+1, npr, nlr, z500)
  FOR j = 0, endid(i)-startid(i) DO BEGIN
  IF NOT HDF_ISHDF(filedir + filename(j)) THEN BEGIN
  PRINT, 'Invalid HDF file ...'
  RETURN
  ENDIF ELSE BEGIN
  PRINT, 'Open HDF file: ' + filename(j)
  ENDELSE

; The SDS var name we're interested in
  sdsvar = STRARR(endid(i)-startid(i)+1, 4)
  sdsvar(j, *) = ['Latitude', 'Longitude', 'EV_250_Aggr1km_RefSB', 'EV_500_Aggr1km_RefSB']

; get the SDS data
; get hdf file id
  fileid = HDF_SD_start(filedir + filename(j), /read)
  FOR k = 0, N_ELEMENTS(sdsvar(j, *))-1 DO BEGIN
  print, 'k', k
; based on SDSname, get the index of this SDS
  thisSDSinx = HDF_SD_nametoindex(fileid, sdsvar(j, k))

; built connections / SDS is selected
  thisSDS = HDF_SD_select(fileid, thisSDSinx)

; get information of this SDS
  HDF_SD_getinfo, thisSDS, NAME = thisSDSName, Ndims = nd, HDF_TYPE = SdsType
  PRINT, 'SDAname ', thisSDSname, ' SDS Dims', nd, ' Sdstype = ', STRTRIM(SdsType, 2)

; dimension information of SDS
  FOR kk = 0, nd-1 DO BEGIN
  DimID = HDF_SD_dimgetid( thisSDS, kk)
  HDF_SD_dimget, DimID, Count = DimSize, Name = DimName
  PRINT, 'Dim ', STRTRIM(kk,2), ' Size = ', STRTRIM(DimSize, 2),' Name = ', STRTRIM(DimName)

  IF ( k  EQ 2 ) THEN BEGIN
  IF ( kk EQ 0 ) THEN np = DimSize     ; dimension size
  IF ( kk EQ 1 ) THEN nl = DimSize
  ENDIF

  ENDFOR ; kk


; end of entering SDS
  HDF_SD_endaccess, thisSDS

; get data
  HDF_SD_getdata, thisSDS, Data

; save data into different arrays
  IF (k EQ 0) THEN BEGIN
  data = CONGRID(data, npr, nlr)
  flat(j, *, *) = data             ;lat data
  ENDIF
  IF (k EQ 1) THEN BEGIN
  data = CONGRID(data, npr, nlr)
  flon(j, *, *) = data             ;lon data
  ENDIF
  IF (k EQ 2) THEN BEGIN 
  data = CONGRID(data, npr, nlr, z250)
  ref250(j, *, *, *) = data        ;Ref 250m merged to 1km
  ENDIF
  IF (k EQ 3) THEN BEGIN
  data = CONGRID(data, npr, nlr, z500)
  ref500(j, *, *, *) = data        ;Ref 500m merged to 1km
  ENDIF

; print reading one SDS var data is over
  PRINT, '=======one SDS data is over ======'
  ENDFOR ; k

; end the access to sd
  HDF_SD_end, fileid
  ENDFOR ; j

; start color plot, true color image combination of
; band 1 0.62-0.67 um  -red
; band 4 0.54-0.57 um  -green
; band 3 0.46-0.48 um  -blue
  red   = bytarr(npr,nlr)
  green = bytarr(npr,nlr)
  blue  = bytarr(npr,nlr)


; manupilate data and enhance the image
 red(0:npr-1, 0:nlr-1)   = HIST_EQUAL(BYTSCL(ref250(0, 0:npr-1, 0:nlr-1, 0)))
 green(0:npr-1, 0:nlr-1) = HIST_EQUAL(BYTSCL(ref500(0, 0:npr-1, 0:nlr-1, 1)))
 blue(0:npr-1, 0:nlr-1)  = HIST_EQUAL(BYTSCL(ref500(0, 0:npr-1, 0:nlr-1, 0)))


; write the image into tiff
; note Aqua images need reverse, otherwise
; the north direction would pointing down.
; left and right also need to be reversed,
; in order to fit our visual experience.
  WRITE_TIFF, STRMID(filename(0), 0, 17) + '.tif',   $
              red   = REVERSE(REVERSE(red, 2), 1),   $
              green = REVERSE(REVERSE(green, 2), 1), $
              blue  = REVERSE(REVERSE(blue, 2), 1),  $
              PLANARCONFIG = 2
; mapping
; map limit
  region_limit = [10, -65, 45, -110]
  win_x = 2000
  win_y = 2000

; pixel after reprojection, default is while pixel
  newred   = BYTARR(win_x, win_y)+255
  newgreen = BYTARR(win_x, win_y)+255
  newblue  = BYTARR(win_x, win_y)+255

; MODIS only gives lat and lon not 1km resolution 
; hence, interpolation is needed to have every 1km pixel has lat and lon
; flat = congrid(flat, np, nl, /interp)
; flon = congrid(flon, np, nl, /interp)


; set up
  SET_PLOT, 'x'
  !p.background = 255L + 256L*(255+256L*255)
  WINDOW, 1, xsize = win_x, ysize = win_y
  MAP_SET, latdel = 5, londel = 10, /continent, $
         /grid, charsize = 0.8, mlinethick = 2, $
         limit = region_limit, color = 0, /USA
; map pixel to the right location in the windown
; based on windown size, map cooridnate and the lat and lon of the pixel

  FOR i = 0, npr-1 DO BEGIN
  FOR j = 0, nlr-1 DO BEGIN
  result = CONVERT_COORD(flon(0,i,j), flat(0,i,j), /data, /to_device)
  newcoordx = result(0)
  newcoordy = result(1)
  newred(newcoordx, newcoordy)   = red(i,j)
  newgreen(newcoordx, newcoordy) = green(i,j)
  newblue(newcoordx, newcoordy)  = blue(i,j)
  ENDFOR
  ENDFOR

; display the reprojecte image
  TV, [[newred]], [[newgreen]], [[newblue]], true = 3

; redraw the map with noerase option
  MAP_SET, latdel = 5, londel = 10, /noerase, /continent, $
           /grid, charsize = 0.8, mlinethick = 2,         $
           limit = region_limit, color = 0, /USA

; write image into file
; read current window content
  image = TVRD(true = 3, order = 1)

; writte to tiff
  WRITE_TIFF, STRMID(filename(0), 0, 17) + '_projected.tif', image, PLANARCONFIG = 2

  ENDFOR ; i
  END
