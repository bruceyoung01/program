;
; read MODIS level 1B digital count.
;
; INPUT: 
;        filedir, filename: file directory and name
; Output:
;         lat, lon: Latitude and longitude
;           np, nl: number of pixels and lines
; red, green, blue: data in digital count for 3 
;                   different colors. 
;

PRO reader_mod, filedir, filename, lat=flat, $
    lon = flon, np = np, nl = nl, $
    red = red, green = green, blue = blue

;
; Check if this file is a valid HDF file
;
if not hdf_ishdf(filedir + filename) then begin
  print, 'Invalid HDF file ...', filedir + filename
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
         ;'EV_250_Aggr500_RefSB','EV_500_RefSB']

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

; manupilate data and enhance the image
red   = reform(ref250(0:np-1, 0:nl-1, 0))
green = reform(ref500(0:np-1, 0:nl-1, 1))
blue  = reform(ref500(0:np-1, 0:nl-1, 0))

end

