@read_modis_level1B_routines.pro
@overlay3band_img.pro
@overlay3band_ps.pro

;
; Read HDF file 
;

filename = 'MOD021KM.A2010226.1505.005.2010229023011.hdf'
filedir = '/data/modis/' 

;
; Check if this file is a valid HDF file 
;
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

; read latitude
SDSname = 'Latitude'
readflag = read_dataset(filedir + filename, SDSname,  flat)
if readflag ne 0 then begin
  print, 'read data wrong'
  stop
endif

; read longitude 
SDSname = 'Longitude'
readflag = read_dataset(filedir + filename, SDSname,  flon)
if readflag ne 0 then begin
  print, 'read data wrong'
  stop
endif


filename0 = filename
filename = strmid(filename, 0, 22)
imgtitle= '!6'+doy2date( strmid(filename0, 14, 3), strmid(filename0, 10, 4))+ ' ' + $
          'Visible ' + filename


win_x = 700
win_y = 700
S = size(red)
np = s(1)
nl = s(2)
overlay3band_img, win_x, win_y, red, green, blue, flat, flon, $
                  np, nl, filedir, imgtitle, range=[0.0, 1.0] ;, /histequal 
; red, green, blue
plots, -60.025, -3.11, psym=mysym(6,3),  symsize=2, color= 255 

; image = tvrd(true=1, order=1)
; write_png, filedir + filename+'.png', $
;            image, /order 
image = tvread(filename =  filedir + filename, type='png',  /NODIALOG)

; special handling with tiff, interviewd with band [columan,rows, band]
image24 = TVRD(TRUE=3)
Write_Tiff, filedir + filename+'.tif', reverse(image24,2),  PLANARCONFIG=2


; spwan a unix command
;spawn, 'convert -quality 100 -modulate 105,125 -sharpen 3 ' + filedir + filename + '.tif ' + $ 
;      filedir + filename + '.jpg' 

spawn, 'convert -quality 100 -modulate 110,130 -sharpen 5 ' + filedir + filename + '.tif ' + $ 
      filedir + filename + '.jpg' 
end

