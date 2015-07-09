;
; Purpose of this program is to use HDF to read omi no2 product
;


PRO read_omi_no2, Filedir, filename, no2,  $
                     flat, flon, np, nl


; check if this file is a valid HDF file
if not hdf_ishdf(filedir + filename) then begin
  print, 'Invalid HDF file ...'
  return
endif else begin
   print, 'Open HDF file : ' + filename
endelse


; the SDS var name we're interested in
SDsvar = strarr(4)
sdsvar = ['ColumnAmountNO2TropCS30', 'Latitude', 'Longitude' ]

; get hdf file id
FileID = Hdf_sd_start(filedir + filename, /read)
for  i = 0, n_elements(SDSvar)-1 do begin
  thisSDSinx = hdf_sd_nametoindex(FileID, SDSVar(i))
  thisSDS = hdf_sd_select(FileID, thisSDSinx)
   hdf_sd_getinfo, thisSDS, NAME = thisSDSName, $
                 Ndims = nd, hdf_type = SdsType
;   print, 'SDAname ', thisSDSname, ' SDS Dims', nd,  $
;          ' SdsType = ',  strtrim(SdsType,2)

     ; dimension information
      for kk = 0, nd-1 do begin
        DimID =   hdf_sd_dimgetid( thisSDS, kk)
        hdf_sd_dimget, DimID, Count = DimSize, Name = DimName
;        print, 'Dim  ', strtrim(kk,2), $
;           ' Size = ', strtrim(DimSize,2), $
;           ' Name  = ', strtrim(DimName)
          if ( i eq 0 ) then begin 
          if ( kk eq 0) then np =  DimSize    ; dimension size
          if ( kk eq 1) then nl  = DimSize
        endif
       endfor

      ; end of entering SDS
       hdf_sd_endaccess, thisSDS
      if ( i ge 1 ) then begin
        startinx = HDF_SD_ATTRFIND(thisSDS, 'startValue')
        hdf_sd_attrinfo, thisSDS, startInx, Data = startValue 
        
        strideinx = HDF_SD_ATTRFIND(thisSDS, 'stride')
        hdf_sd_attrinfo, thisSDS, strideInx, Data = stride 
        
       sizeinx = HDF_SD_ATTRFIND(thisSDS, 'size')
        hdf_sd_attrinfo, thisSDS, sizeInx, Data = nsize 

      endif

      ; get data
       hdf_sd_getdata, thisSDS, Data
       if ( i eq 1 ) then  flat1  = startValue(0) + findgen(nsize(0))*stride(0) 
       if ( i eq 0 ) then  NO2 = data 
       if ( i eq 2 ) then  flon1 =  startValue(0) + findgen(nsize(0))*stride(0) 
   endfor
  ; end the access to sd
   hdf_sd_end, FileID

 ; get flat and flon
   flat = fltarr(np, nl)
   flon = fltarr(np, nl)
   for i = 0, np-1 do begin
    for j = 0, nl-1 do begin
      flat(i,j) = flat1(j)
      flon(i,j) = flon1(i)
    endfor
   endfor

   print, 'np = ', np,  'nl = ', nl
END

  







