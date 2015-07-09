; read the grid emission data and plot 
@./color_contour.pro
@./set_legend.pro
@./plot_mod14_subroutine.pro
; read the grid emission data

Function filedate, filename
 date1 = float( strmid(filename, 11, 7) )
 return, date1
END

  m = 4
  n = 3

 
  dir1 = '/home/bruce/program/idl/arslab4/'
  filename1 = 'MOD14.A2000366.1655.005.2006342072113.hdf_fire.txt'
 
  fire = FLTARR(m, n)
  OPENR, lun, dir1+filename1, /get_lun
  READF, lun, fire
  PRINT, max(fire(1,0:n-1))

filedir = '/home/bruce/data/modis/arslab4/mod11/2000/'
filename = 'MOD11_L2.A2000366.1655.005.2006342145851.hdf'
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

   if ( i eq 1 ) then begin
     if ( kk eq 0) then xl = DimSize    ; dimension size
     if ( kk eq 1) then yl = DimSize
   endif
  
   endfor

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

  ; print get one SDS var data is over
  print, '========= one SDS data is over ========='

endfor
; end the access to sd
  hdf_sd_end, FileID

;print,lst
print,'AA'
openw, lun, filename1+'.dat', /get_lun

; judge the land surface temperature near the grid of fire number
for i = 0, xl-1 do begin
  for j = 0, yl-1 do begin
    for k = 0, n-1 do begin
      if (rlat(i,j) ge fire(0,k)-0.05 and rlat(i,j) le fire(0,k)+0.05 and  $ 
          rlon(i,j) ge fire(1,k)-0.05 and rlon(i,j) le fire(1,k)+0.05 and  $
          lst(i,j) ne 0.0) then begin
        print,i, 'select'
        printf, lun, fire(0,k), fire(1,k), fire(2,k), lst(i,j), FORMAT = '(f10.5, f12.5, i4, f15.5)'
      endif else begin
      print, i
      endelse
    endfor
  endfor
endfor
free_lun, lun

  set_plot, 'ps'
  device, filename =filename1 + '.ps', /portrait, xsize = 7.5, ysize=9, $
          xoffset = 0.5, yoffset = 1, /inches, /color, bits=8

  ;print, fire(0,0:n-1)
  ;print, fire(1,0:n-1)
  ;print, fire(2,0:n-1)
  plot_mod14_subroutine, fire(0,0:n-1), fire(1,0:n-1), fire(2,0:n-1)

  device, /close
  close,2
  
  END
