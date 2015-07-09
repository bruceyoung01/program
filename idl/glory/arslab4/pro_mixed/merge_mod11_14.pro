; Purpose of this program : select the pixels which is fire pixel.


@/home/bruce/idl/Williwaw/task/superior/MOD11T/set_legend.pro
@./color_contour.pro
@/home/bruce/idl/Williwaw/task/superior/MOD11T/modis_lst_lat_lon.pro

Function filedate, filename
 date1 = float( strmid(filename, 11, 7) )
 return, date1
END



filedir  = '/home/bruce/data/modis/arslab4/mod11/2000/'
filename = 'MOD11_L2.A2000066.1635.005.2006257183843.hdf'
date = string(filedate(filename), format = '(I7)')

filedir1 = '/home/bruce/data/modis/arslab4/mod14/2000/'
filename1= 'MOD14.A2000066.1635.005.2008235193438.hdf'


; read MOD11
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
  
  PRINT, np, nl
  ; end of entering SDS
  hdf_sd_endaccess, thisSDS

  ; get data
   HDF_SD_getdata, thisSDS, Data
   if ( i eq 0 ) then begin
   scaleinx = HDF_SD_ATTRFIND(thisSDS, Attrname(0))
   offsetinx = HDF_SD_ATTRFIND(thisSDS, Attrname(1))
   hdf_sd_attrinfo, thisSDS, scaleinx, Data = scale
   hdf_sd_attrinfo, thisSDS, OffsetInx, Data = offset
   endif

   if (i eq 0) then LST      = data*scale(0) + offset(0)
   if (i eq 1) then RLAT      = data
   if (i eq 2) then RLON      = data
  HELP, rlat
  ; print get one SDS var data is over
  print, '========= one SDS data is over ========='

endfor

; end the access to sd
  hdf_sd_end, FileID

rlat = congrid(rlat, np, nl, /interp)
rlon = congrid(rlon, np, nl, /interp)

; open a new file to write new variables

  lun1= 91
  lun2= 92
  lun3= 93
  lun4= 94
  lun5= 95
  lun6= 96

  OPENW, lun1, filename1 + '_ftlat.txt'
  OPENW, lun2, filename1 + '_ftlon.txt'
  OPENW, lun3, filename1 + '_ft.txt'
  OPENW, lun4, filename1 + '_tlat.txt'
  OPENW, lun5, filename1 + '_tlon.txt'
  OPENW, lun6, filename1 + '_t.txt'


; open the HDF file for reading
sd_id = HDF_SD_START(filedir1 + filename1, /READ)

; find the SDS index to the MOD14 fire mask
index1 = HDF_SD_NAMETOINDEX(sd_id, 'FP_latitude')
index2 = HDF_SD_NAMETOINDEX(sd_id, 'FP_longitude')
index3 = HDF_SD_NAMETOINDEX(sd_id, 'FP_sample')

; select and read the entire fire SDS
sds_id1 = HDF_SD_SELECT(sd_id, index1)
HDF_SD_GETDATA, sds_id1, lat
PRINT, lat
HELP,lat

sds_id2 = HDF_SD_SELECT(sd_id, index2)
HDF_SD_GETDATA, sds_id2, lon
PRINT, lon
HELP,lon

sds_id3 = HDF_SD_SELECT(sd_id, index3)
HDF_SD_GETDATA, sds_id3, fire_sample
PRINT, fire_sample
HELP,fire_sample

; finished with SDS
HDF_SD_ENDACCESS, sds_id1
HDF_SD_ENDACCESS, sds_id2
HDF_SD_ENDACCESS, sds_id3


; finished with HDF file
HDF_SD_END, sd_id
n = n_elements(lat)

rlat0= rlat
rlon0= rlon
LST0 = LST

For i = 0, np-1 DO BEGIN
   FOR j = 0, nl-1 DO BEGIN
      FOR k = 0, n-1 DO BEGIN
          IF (abs(rlat(i,j) - lat(k)) lt 0.0045 and abs(rlon(i,j) - lon(k)) lt 0.0045) THEN BEGIN
          PRINTF, lun1, rlat(i,j), FORMAT = '(f10.5)'
          PRINTF, lun2, rlon(i,j), FORMAT = '(f12.5)'
          PRINTF, lun3, LST(i,j),  FORMAT = '(f10.5)'
          rlat0(i,j)= -999
          rlon0(i,j)= -999
          LST0(i,j) = -999
          ;PRINT, rlat(i,j)
          ENDIF
      ENDFOR
   ENDFOR
ENDFOR

For i = 0, np-1 DO BEGIN
   FOR j = 0, nl-1 DO BEGIN
      IF (rlat0(i,j) ne -999 or rlon0(i,j) ne -999 or LST0(i,j) ne -999) THEN BEGIN
      PRINTF, lun4, rlat0(i,j), FORMAT = '(f10.5)'
      PRINTF, lun5, rlon0(i,j), FORMAT = '(f12.5)'
      PRINTF, lun6, LST0(i,j),  FORMAT = '(f10.5)'
      PRINT, rlat0(i,j)
      ENDIF
   ENDFOR
ENDFOR

FREE_LUN, lun1
FREE_LUN, lun2
FREE_LUN, lun3
FREE_LUN, lun4
FREE_LUN, lun5
FREE_LUN, lun6

END
