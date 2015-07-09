;
; Read HDF file 
;

PRO get_hdf_info, filename, outfilename  

;filename = '/data/China/MOD08_M3.005.g3Stats.3374.hdf'

;
; Check if this file is a valid HDF file 
;
if not hdf_ishdf(filename) then begin
  print, 'Invalid HDF file ...'
  return
endif else begin
  print, 'Open HDF file : ' + filename
endelse

;
;open outfilename 
;

openw, 1, outfilename

;
; See what is inside
;
FileID = Hdf_sd_start(filename, /read)
printf, 1, 'reading # of datasets and file attibutes in file'
hdf_sd_fileinfo, FileID, Ndatasets, Nattributes

; print # of datasets and attributes
printf, 1, 'No. of datasets :', ndatasets
printf, 1, 'No. of attributes :', Nattributes

; print name of each  attribute
printf, 1, ' '
printf, 1, 'Printing name of each file attribute ...'
for j = 0, nattributes-1 do begin
  hdf_sd_attrinfo, FileId, j, Name = thisAttr
  printf, 1, 'File Attibute # ', + strtrim(j,2), ': ', thisAttr
endfor

; print name of each SDS and associated attributes
printf, 1, ' '
printf, 1, 'Printing SDS info ...' 

for j = 0, ndatasets -1 do begin
   thisSDS = Hdf_sd_select(FileID, j)
   hdf_sd_getinfo, thisSDS, NAME = thisSDSName, $
                   Natts = numAttrOfSDS,  Ndims = nd, hdf_type = SdsType
   printf, 1, 'SDS No. ' + strtrim(j,2) , ': ', thisSDSName, '  SdsType = ',     SdsType

   ; dimension information
   for kk = 0, nd-1 do begin		   
   DimID =   hdf_sd_dimgetid( thisSDS, kk)
   hdf_sd_dimget, DimID, Count = DimSize, Name = DimName  
   printf, 1, 'Dim  ', strtrim(kk,2), ' Size = ', strtrim(DimSize,2), ' Name  = ', strtrim(DimName) 
   endfor

   ; select SDS data
   HDF_SD_getdata, thisSDS, Data
   help, data

   for k = 0, numAttrOfSDS-1 do begin
     hdf_sd_attrinfo, thisSDS, k, Name = thisAttrName, Data = thisAttrData
     printf, 1, '  Data Attribute: ', thisAttrName 
   endfor
   print , 1,  ' '
endfor
close, 1

end

