;
; read MODIS14 fire product 
;
; INPUT: 
;        filedir, filename: file directory and name
; Output:
;         lat, lon: Latitude and longitude
;           np, nl: number of pixels and lines
; red, green, blue: data in digital count for 3 
;                   different colors. 
;

;PRO firemod_reader, filedir, filename, lat=flat, $
;    lon = flon, nfire = nfire, Line = Line, Sample = Sample, $
;    FP = FP 

filedir = '/home/bruce/data/modis/arslab4/mod14/2000/'
filename = 'MOD14.A2000066.1635.005.2008235193438.hdf'
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
SDsvar = strarr(5)
SdSVar = ['FP_line', 'FP_sample', 'FP_latitude', 'FP_longitude', $
         'FP_power']

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
   if (kk eq 0 ) then dsize = DimSize 
   endfor
 ; end of entering SDS
  hdf_sd_endaccess, thisSDS

   if ( dsize gt 0 ) then begin
 ; get data

   HDF_SD_getdata, thisSDS, Data
 
   if (i eq 0) then Line =  data 
   if (i eq 1) then Sample = data 
   if (i eq 2) then flat = data  
   if (i eq 3) then flon = data 
   if (i eq 4) then fp = data 
   endif else begin
   if (i eq 0) then Line =  0 
   if (i eq 1) then Sample = 0 
   if (i eq 2) then flat = 0  
   if (i eq 3) then flon = 0 
   if (i eq 4) then fp = 0 
   endelse

  ; print get one SDS var data is over
  print, '========= one SDS data is over ========='

endfor

; end the access to sd
  hdf_sd_end, FileID
  if dsize eq 0 then nfire = 0
  if dsize gt 0 then nfire = n_elements(Line) 

end

