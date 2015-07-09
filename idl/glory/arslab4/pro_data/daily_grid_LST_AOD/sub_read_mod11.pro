
; purpose of this subroutine program : read MODIS mod11 land surface temperature product


  PRO sub_read_mod11, filedir, filename, np, nl, rlat, rlon, lst 
; Check if this file is a valid HDF file 

if not hdf_ishdf(filedir + filename) then begin
  print, 'Invalid HDF file ...'
  return
endif else begin
  print, 'Open HDF file : ' + filename
endelse

;
; The SDS var name we're interested in 
;
SDsvar = strarr(1)
SdSVar = ['LST', 'Latitude', 'Longitude' ]
AttrName = ['scale_factor',  'add_offset']

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

   if ( i eq 0 ) then begin
     if ( kk eq 0) then np = DimSize    ; dimension size
     if ( kk eq 1) then nl = DimSize
   endif

   endfor

  ; end of entering SDS
  hdf_sd_endaccess, thisSDS

  ; get data
   HDF_SD_getdata, thisSDS, Data
   if ( i eq 0 ) then begin
   scaleinx  = HDF_SD_ATTRFIND(thisSDS, Attrname(0))
   offsetinx = HDF_SD_ATTRFIND(thisSDS, Attrname(1))
   hdf_sd_attrinfo, thisSDS, scaleinx,  Data = scale
   hdf_sd_attrinfo, thisSDS, OffsetInx, Data = offset
   endif

   if (i eq 0) then LST       = data*scale(0) + offset(0)
   if (i eq 1) then RLAT      = data
   if (i eq 2) then RLON      = data

  ; print get one SDS var data is over
  print, '========= one SDS data is over ========='

endfor

  rlat = congrid(rlat, np, nl, /interp)
  rlon = congrid(rlon, np, nl, /interp)

; end the access to sd
  hdf_sd_end, FileID


END
