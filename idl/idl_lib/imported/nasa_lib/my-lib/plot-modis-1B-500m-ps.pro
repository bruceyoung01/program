
pro overlay, region_limit, ch1, ch2, ch3, lat, lon, np, nl, outfile

  ; scale each channel from 0 ~ 255
    mag = 1.
  ; create color tables and color indices
        result = color_quan(ch1, ch2, ch3, r, g, b, colors=256)
        tvlct, r, g, b

        lat =  congrid(lat, np*mag, nl*mag, /interp)
        lon =  congrid(lon, np*mag, nl*mag, /interp)

     map_set, /continent,$
     charsize=1, mlinethick = 4, $
     position=[0.05, 0.31, 0.95, 0.87], $
     limit = region_limit,/usa, color=0,con_color=0, $
     title = outfile  

     color_imagemap, result, lat, lon, /current, missing = 0

     map_set,  /continent,$
     charsize=1, mlinethick = 4, $
     position=[0.05, 0.31, 0.95, 0.87], $
     limit = region_limit,/noerase, $
     /usa,color=0,con_color=0

    end


PRO modis_04, filename, filedir, region_limit, outfdir

;
; Check if this file is a valid HDF file 
;
if not hdf_ishdf(filedir + filename) then begin
  print, 'Invalid HDF file ...'
  return
endif else begin
  print, 'Open HDF file : ' + filename
endelse

outfile = strmid(filename, 0, 24) 

;
; The SDS var name we're interested in 
;
SDsvar = strarr(4)
SdSVar = ['Latitude', 'Longitude', $
         'EV_250_Aggr500_RefSB', 'EV_500_RefSB']


; loop over all filenames
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


; write the image into tiff , note Aqua images need reverse
 write_tiff, outfdir + outfile + '.tif', red=red, $
               green= green, $ 
	       blue=blue,$ 
	       PLANARCONFIG=2

overlay, region_limit, red, green, blue, flat, flon, np, nl, outfile 

end

