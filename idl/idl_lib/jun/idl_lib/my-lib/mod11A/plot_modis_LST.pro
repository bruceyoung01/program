@/home/jwang/class/data/grid/set_legend.pro
@/home/jwang/class/data/grid/color_contour.pro
@/home/jwang/class/data/grid/modis_lst_lat_lon.pro

Function filedate, filename
 date1 = float( strmid(filename, 9, 7) )
 return, date1
END



;PRO read_modis_L3_aerosol, filename, np, nl, AOT, AOTsmall
 
;filename = 'MOD02HKM.A2002128.1610.005.2007130125411.hdf'
filename = 'MOD11A2.A2001001.h11v04.005.2006350190215.hdf'
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
SdSVar = ['LST_Day_1km', 'LST_Night_1km'] 
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

   if (i eq 0) then DayLST      = data*scale(0) + offset(0)
   if (i eq 1) then NightLST =  data*scale(0) + offset(0) 

  ; print get one SDS var data is over
  print, '========= one SDS data is over ========='

endfor

; end the access to sd
  hdf_sd_end, FileID

; 
; read  lat and lon

mod_lst_lat_lon, filename, rlat, rlon

; define the max and min for your color bar 
;maxvalue = max(daylst)+1 
;minvalue = min(daylst(where (daylst ne 0))) - 1 
; make your own choice here
maxvalue= 281
minvalue= 245

; color bar coordinate
    xa = 0.125       &   ya = 0.9
      dx = 0.05      &   dy = 0.00
      ddx = 0.0      &   ddy = 0.03
      dddx = 0.05    &   dddy = -0.047
      dirinx = 0     &   extrachar=' K'
; color bar levels
n_levels = 12

;labelformat
FORMAT = '(f6.2)' 

; region
region = [min(rlat)-2, min(rlon)-2, max(rlat)+2, max(rlon)+2]

; title
title = 'MODIS SURFACE TEMPERATURE ' + date 

set_plot, 'ps'
device, filename = 'temperature.ps', xsize=7, ysize=10, $
        xoffset=0.5, yoffset=0.5, /inches,/color
!p.thick=3 
!p.charthick=3
!p.charsize=1.2 

color_contour, rlat, rlon, DayLST, maxvalue, minvalue, $
                  N_Levels , region, $
                  xa, dx, ddx, dddx, $
                  ya, dy, ddy, dddy, FORMAT, dirinx, extrachar, title 

device, /close
END
