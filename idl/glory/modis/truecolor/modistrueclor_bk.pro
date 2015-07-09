;The Gulf of Mexico: 
;Place: Latitude: 20-30°; Longitude: -100 - -80°
;Time: May 7, 2009 1950UTC
;Purpose: to plot the true color image of the Gulf of Mexico using the MODIS data
;Author: Bruce Young
;Date: Sep. 20, 2009

@./overlay3band_img.pro

; define input file dir and name
filename = 'MYD021KM.A2009270.1910.005.2009271171417.hdf'
filedir = '/home/zyang/task/'

; Check if this file is a valid HDF file
if not hdf_ishdf (filedir + filename) then begin
print, 'Invalid HDF file ...'
return
endif else begin
print, 'Open HDF file: '+filename
endelse

; The SDS var name we're interested in
SDsvar = strarr(4)
SdSvar = ['Latitude', 'Longitude', 'EV_250_Aggr1km_RefSB', 'EV_500_Aggr1km_RefSB']

; get the SDS data
; get hdf file id
fileID = Hdf_sd_start(filedir + filename, /read)
for i=0, n_elements(SDSvar)-1 do begin
;print,'iii',i
;based on SDSname, get the index of this SDS
thisSDSinx = hdf_sd_nametoindex(fileID, SDSVar(i))

;built connections / SDS is selected.
thisSDS = hdf_sd_select(fileID, thisSDSinx)

;get information of this SDS
hdf_sd_getinfo, thisSDS, NAME = thisSDSName, Ndims = nd, hdf_type = SdsType
print, 'SDAname ', thisSDSname, ' SDS Dims', nd, ' Sdstype = ', strtrim(SdsType, 2)
;print,'ii',i
;dimension information of SDS
for kk = 0, nd-1 do begin
DimID = hdf_sd_dimgetid( thisSDS, kk)
hdf_sd_dimget, DimID, Count = DimSize, Name = DimName
print, 'Dim ', strtrim(kk,2), ' Size = ', strtrim(DimSize, 2),' Name = ', strtrim(DimName)
print,'i',i
if (i eq 2 ) then begin
  if ( kk eq 0) then np = DimSize     ;dimension size
  if ( kk eq 1) then nl = DimSize
;print, 'kk', kk
endif

endfor


;end of entering SDS
hdf_sd_endaccess, thisSDS

;get data
HDF_SD_getdata, thisSDS, Data

;save data into different arrays
if (i eq 0) then flat = data             ;lat data
if (i eq 1) then flon = data             ;lon data
if (i eq 2) then ref250 = data           ;Ref 250m merged to 1km
if (i eq 3) then ref500 = data           ;Ref 500m merged to 1km

;print reading one SDS var data is over
print, '=======one SDS data is over ======'
endfor

;end the access to sd
hdf_sd_end, fileID

;start color plot, true color image combination of
;band 1 0.62-0.67 um  -red
;band 4 0.54-0.57 um  -green
;band 3 0.46-0.48 um  -blue
;red = bytarr(np,nl)
;green = bytarr(np,nl)
;blue = bytarr(np,nl)
red = bytarr(512,512)
green = bytarr(512,512)
blue = bytarr(512,512)


;manupilate data and enhance the image
;red(0:np-1, 0:nl-1) = hist_equal(bytscl(ref250(0:np-1, 0:nl-1, 0)))
;green(0:np-1, 0:nl-1) = hist_equal(bytscl(ref500(0:np-1, 0:nl-1, 1)))
;blue(0:np-1, 0:nl-1) = hist_equal(bytscl(ref500(0:np-1, 0:nl-1, 0)))
;red(62:574-1,1478:1990-1)   = bytscl(ref250(62:574-1,1478:1990-1, 0))
;green(62:574-1,1478:1990-1) = bytscl(ref500(62:574-1,1478:1990-1, 1))
;blue(62:574-1,1478:1990-1)  = bytscl(ref500(62:574-1,1478:1990-1, 0))
red(0:511,0:511)   = bytscl(ref250(0:511, 0:511, 0))
green(0:511,0:511) = bytscl(ref500(0:511, 0:511, 1))
blue(0:511,0:511)  = bytscl(ref500(0:511, 0:511, 0))


;write the image into tiff
;note Aqua images need reverse, otherwise
;the north direction would pointing down.
;left and right also need to be reversed,
;in order to fit our visual experience.
write_tiff, filename + '.tif', red = reverse (reverse (red,2),1), $
              green = reverse (reverse(green, 2),1), $
              blue = reverse (reverse(blue, 2), 1), $
              PLANARCONFIG = 2
;mapping
;map limit
region_limit = [10, 10, 35, -75]
win_x = 8000
win_y = 8000

;pixel after reprojection, default is while pixel
newred = bytarr(win_x, win_y)+255
newgreen = bytarr(win_x, win_y)+255
newblue = bytarr(win_x, win_y)+255

;MODIS only gives lat and lon not 1km resolution 
;hence, interpolation is needed to have every 1km pixel has lat and lon
;flat = congrid(flat, np, nl, /interp)
;flon = congrid(flon, np, nl, /interp)
flat = congrid(flat, 512, 512, /interp)
flon = congrid(flon, 512, 512, /interp)


;set up
set_plot, 'x'
!p.background = 255L + 256L*(255+256L*255)
window, 1, xsize = win_x, ysize = win_y
map_set, latdel = 5, londel = 10, /continent, $
         /grid, charsize = 0.8, mlinethick = 2, $
         limit = region_limit, color = 0, /USA
;map pixel to the right location in the windown
;based on windown size, map cooridnate and the lat and lon of the pixel

;for i = 0, np-1 do begin
;for j = 0, nl-1 do begin
for i = 0, 512-1 do begin
for j = 0, 512-1 do begin


result = convert_coord(flon(i,j), flat(i,j), /data, /to_device)
newcoordx = result(0)
newcoordy = result(1)
print, 'newcoordx = ', newcoordx, 'newcoordy = ', newcoordy
newred(newcoordx, newcoordy) = red(i,j)
newgreen(newcoordx, newcoordy) = green(i,j)
newblue(newcoordx, newcoordy) = blue(i,j)
endfor
endfor

;display the reprojecte image
tv, [[newred]], [[newgreen]], [[newblue]], true = 3

;redraw the map with noerase option
map_set, latdel = 5, londel = 10, /noerase, /continent, $
        /grid, charsize = 0.8, mlinethick = 2, $
        limit = region_limit, color = 0, /USA

;write image into file
;read current window content
image = tvrd(true = 3, order = 1)

;writte to tiff
write_tiff, filename + 'projected.tif', image, PLANARCONFIG = 2

end


