@overlay3band_img.pro
@overlay3band_ps.pro
;
; Read HDF file 
;

filename = 'MOD021KM.A2007128.1600.005.2007130035342.hdf'
filedir = '/home/zyang/task/' 

;
; Check if this file is a valid HDF file 
;
if not hdf_ishdf(filedir + filename) then begin
  print, 'Invalid HDF file ...'
  return
endif else begin
  print, 'Open HDF file : ' + filename
endelse

;
; The SDS var name we're interested in 
;
SDsvar = strarr(4)
SdSVar = ['Latitude', 'Longitude', $
         'EV_250_Aggr1km_RefSB','EV_500_Aggr1km_RefSB']

;
; get the SDS data
;

; get hdf file id 
FileID = Hdf_sd_start(filedir + filename, /read)

for i = 0, n_elements(SDSvar)-1 do begin
 thisSDSinx = hdf_sd_nametoindex(FileID, SDSVar(i))
 thisSDS = hdf_sd_select(FileID, thisSDSinx)
 hdf_sd_getinfo, thisSDS, NAME = thisSDSName, $
                 Ndims = nd, hdf_type = SdsType
   print, 'SDAname ', thisSDSname, ' SDS Dims', nd, $
          ' SdsType = ',  strtrim(SdsType,2)

  ; dimension information
   for kk = 0, nd-1 do begin		   
   DimID =   hdf_sd_dimgetid( thisSDS, kk)
   hdf_sd_dimget, DimID, Count = DimSize, Name = DimName  
   print, 'Dim  ', strtrim(kk,2), $
          ' Size = ', strtrim(DimSize,2), $
          ' Name  = ', strtrim(DimName)
	   
   if ( i eq 2 ) then begin
     if ( kk eq 0) then np = DimSize    ; dimension size
     if ( kk eq 1) then nl = DimSize    
   endif
      	  
   endfor
   
  ; end of entering SDS
  hdf_sd_endaccess, thisSDS 
  
  ; get data
   HDF_SD_getdata, thisSDS, Data
   if (i eq 0) then flat = data
   if (i eq 1) then flon = data
   if (i eq 2) then ref250 = data  ; 1km
   if (i eq 3) then ref500 = data ; 250 merged to 1km 
  
  ; print get one SDS var data is over
  print, '========= one SDS data is over ========='
  
endfor

; end the access to sd
  hdf_sd_end, FileID

; start color plot

red = bytarr(np,nl)
green = bytarr(np,nl)
blue = bytarr(np,nl)

; manupilate data and enhance the image
red(0:np-1,0:nl-1)   = hist_equal(bytscl(ref250(0:np-1, 0:nl-1, 0)))
green(0:np-1,0:nl-1) = hist_equal(bytscl(ref500(0:np-1, 0:nl-1, 1)))
blue(0:np-1,0:nl-1)  = hist_equal(bytscl(ref500(0:np-1, 0:nl-1, 0)))


filename = strmid(filename, 0, 22)

; write the image into tiff , note Aqua images need reverse
;
;write_tiff, 'overlay-new.tif', red=reverse(reverse(red,2),1), $
;               green= reverse(reverse(green,2), 1), $ 
;	       blue=reverse(reverse(blue,2), 1),$ 
;	       PLANARCONFIG=2

write_tiff, filename + '_noprojection.tif', red=reverse(reverse(red,2),1), $
               green= reverse(reverse(green,2), 1), $ 
	       blue=reverse(reverse(blue,2), 1),$ 
	       PLANARCONFIG=2

image = bytarr(3, np, nl)
image(0, *,*) = red(*,*) & image(1,  *,*) = green(*,*) & image(2, *,*) =blue(*,*)

write_png, filename + '_noprojection.png', image, /order

; plot projected images into ps or png files
;overlay3band_ps, red, green, blue, flat, flon, np, nl, filedir, filename 
win_x = 100
win_y = 100
overlay3band_img, win_x, win_y, red, green, blue, flat, flon, np, nl, filedir, filename 

end


















