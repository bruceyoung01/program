@set_legend.pro
@color_contour.pro

Function filedate, filename
 date1 = float( strmid(filename, 10, 7) )
 return, date1
END



;PRO read_modis_L3_aerosol, filename, np, nl, AOT, AOTsmall
 
;filename = 'MOD02HKM.A2002128.1610.005.2007130125411.hdf'
filename = 'MOD08_D3.A2004022.005.2007006175056.psgscs_000500263170.hdf'
filedir = './'
date = string(filedate(filename), format = '(I7)')

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
SDsvar = strarr(2)
SdSVar = ['Optical_Depth_Ratio_Small_Land_And_Ocean_Mean', $
           'Optical_Depth_Land_And_Ocean_Mean' ]

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
  ; if ( i ge 0 ) then begin
   scaleinx = HDF_SD_ATTRFIND(thisSDS, Attrname(0))
   offsetinx = HDF_SD_ATTRFIND(thisSDS, Attrname(1))
   hdf_sd_attrinfo, thisSDS, scaleinx, Data = scale
   hdf_sd_attrinfo, thisSDS, OffsetInx, Data = offset
  ; endif

   if (i eq 0) then AOT      = data*scale(0) + offset(0)
   if (i eq 1) then begin
      data = data*scale(0) + offset(0) 
      AOTSmall = data * AOT
   endif

  ; print get one SDS var data is over
  print, '========= one SDS data is over ========='

endfor

; end the access to sd
  hdf_sd_end, FileID

; 
; define lat and lon
; based upon the box range, the spatial resolution is 1X1 
rlat = fltarr(np, nl)
rlon = fltarr(np, nl)
for i = 0, np-1 do begin
for j = 0, nl-1 do begin
 rlat(i,j) = 65. - 1 * j
 rlon(i,j) = 60. + 1 * i 
endfor
endfor

; define the max and min for your color bar 
maxvalue = 1.0
minvalue = 0.0

; color bar coordinate
    xa = 0.125       &   ya = 0.9
      dx = 0.05      &   dy = 0.00
      ddx = 0.0      &   ddy = 0.03
      dddx = 0.05    &   dddy = -0.047
      dirinx = 0     &   extrachar=' '
; color bar levels
n_levels = 12
FORMAT = '(f5.2)'
; region
region = [min(rlat)-2, min(rlon)-2, max(rlat)+2, max(rlon)+2]

; title
title = 'MODIS AOT ' + date 

set_plot, 'ps'
device, filename = 'dailymass_map.ps', xsize=7, ysize=10, $
        xoffset=0.5, yoffset=0.5, /inches,/color
!p.thick=3 
!p.charthick=3
!p.charsize=1.2 

color_contour, rlat, rlon, AOT, maxvalue, minvalue, $
                  N_Levels , region, $
                  xa, dx, ddx, dddx, $
                  ya, dy, ddy, dddy, FORMAT, dirinx, extrachar, title 

device, /close
END
