@overlay3band_img.pro
@overlay3band_ps.pro
@read_modis_level1B_routines.pro

; purpose: read refletance and brighness temperature
;          from MODIS level 1B, and read corresponding
;          solar zenith, view zenith, and azimuth 
;          angles for each pixel from MODIS03 
;          geolocation product.

; note: conversion from radiance to brightness
;       temperature should follow the handouts (using Planck's
;       function).

; note: please download the pair of MOD021km (level 1B) and MOD03
;       product based upon their file name from which 
;       you can see the time these data were collected. 



;
; Read HDF file 
;

filename = 'MOD021KM.A2007128.1600.005.2007130035342.hdf'
filedir = './' 


; Read HDF data
; read 1km refletance aggregated from 250m: red band, modis ch1 
bandname = '1'
readflag = read_1km_data(filedir + filename, bandname, red, /reflectance)
if readflag ne 0 then begin
  print, 'read data wrong'
  stop
endif

; read 1km refletance aggregated from 500m: green, modis ch4, 550 nm
; not this refletance is just pi * I, not normalized with cos(SZA). 
bandname = '4'
readflag = read_1km_data(filedir + filename, bandname, green, /reflectance)
if readflag ne 0 then begin
  print, 'read data wrong'
  stop
endif

; read 1km refletance aggregated from 500m: green, modis ch4, 550 nm 
bandname = '3'
readflag = read_1km_data(filedir + filename, bandname, blue, /reflectance)
if readflag ne 0 then begin
  print, 'read data wrong'
  stop
endif

; read 1km emissivity: 12um channel 32 
bandname = '32'
readflag = read_1km_data(filedir + filename, bandname,  IR12, /radiance)
if readflag ne 0 then begin
  print, 'read data wrong'
  stop
endif

; read 1km emissivity: 11um channel 31 
bandname = '31'
readflag = read_1km_data(filedir + filename, bandname,  IR11, /radiance)
if readflag ne 0 then begin
  print, 'read data wrong'
  stop
endif

; convert radiance to brightness temperature using Planck function
; please see handout written by R. B. Smith from Yale. 
; to fastern the computation, you need to compute the some constants
; for each band and then save it. 


; read latitude
SDSname = 'Latitude'
readflag = read_dataset(filedir + filename, SDSname,  Latitude)
if readflag ne 0 then begin
  print, 'read data wrong'
  stop
endif

; read longitude 
SDSname = 'Longitude'
readflag = read_dataset(filedir + filename, SDSname,  Longitude)
if readflag ne 0 then begin
  print, 'read data wrong'
  stop
endif

;read modis03 geolocation data : sensor zenith
filename = 'MOD03.A2007128.1600.005.2007129044944.hdf'
SDSname = 'SensorZenith'
readflag = read_dataset(filedir + filename, SDSname,  VZA)
if readflag ne 0 then begin
  print, 'read data wrong'
  stop
endif

;read modis03 geolocation data: sensor azimuth
filename = 'MOD03.A2007128.1600.005.2007129044944.hdf'
SDSname = 'SensorAzimuth'
readflag = read_dataset(filedir + filename, SDSname,  VAZM)
if readflag ne 0 then begin
  print, 'read data wrong'
  stop
endif


;read modis03 geolocation data : solar zenith
filename = 'MOD03.A2007128.1600.005.2007129044944.hdf'
SDSname = 'SolarZenith'
readflag = read_dataset(filedir + filename, SDSname,  SZA)
if readflag ne 0 then begin
  print, 'read data wrong'
  stop
endif

;read modis03 geolocation data: solar azimuth
filename = 'MOD03.A2007128.1600.005.2007129044944.hdf'
SDSname = 'SolarAzimuth'
readflag = read_dataset(filedir + filename, SDSname,  SAZM)
if readflag ne 0 then begin
  print, 'read data wrong'
  stop
endif

; relative azimuth angle
RZA = abs(VAZM - SAZM)


; start color plot
result = size(red)
np = result(1)
nl = result(2)

filename = strmid(filename, 0, 22)

image = bytarr(3, np, nl)
red = hist_equal(bytscl(red(*,*)))
green = hist_equal(bytscl( green(*,*))) 
blue = hist_equal(bytscl(blue(*,*)))

image(0, *,*) = red(*,*)
image(1,  *,*) = green(*,*)
image(2, *,*) = blue(*,*)

write_png, filename + '_noprojection.png', image, /order

; plot projected image
win_x = 700
win_y = 700
overlay3band_img, win_x, win_y, red, green, blue, latitude, longitude, np, nl, filedir, filename


end


















