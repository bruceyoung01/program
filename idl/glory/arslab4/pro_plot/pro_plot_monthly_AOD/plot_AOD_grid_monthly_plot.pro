

; purpose of this program : plot the monthly average MODIS AOD

@/home/bruce/program/idl/arslab4/pro_plot/pro_plot_monthly_AOD/plot_emission_subroutine_AOD_grid_monthly_plot.pro

  n = 30
  m = 7000
  nlat = 70
  nlon = 100
  filedir  = '/home/bruce/data/modis/arslab4/results/2003/'
  filelist = '200304aod_list'
  date     = '200304aod'    
  filedirres = '/home/bruce/program/idl/arslab4/pro_plot/pro_plot_monthly_AOD/'

  maxlat = 45.
  minlat = 10.
  maxlon = -65.
  minlon = -115.

  filename = STRARR(n)
  READCOL, filedir + filelist, F = 'A', filename   

  lat = FLTARR(nlat, nlon)
  lon = FLTARR(nlat, nlon)
  aod = FLTARR(nlat, nlon)
  tmplat = 0.0
  tmplon = 0.0
  tmpaod = 0.0
  count  = 0

  aod_month = FLTARR(nlat,nlon,n)
  FOR i = 0, n-1 DO BEGIN
    OPENR, lun, filedir + filename(i), /get_lun
    FOR j = 0, nlat-1 DO BEGIN
     FOR k = 0, nlon-1 DO BEGIN
      READF, lun, tmplat, tmplon, tmpaod, count
      lat(j,k) = tmplat
      lon(j,k) = tmplon
      aod(j,k) = tmpaod
      aod_month(j,k,i) = tmpaod
     ENDFOR
    ENDFOR
    FREE_LUN, lun
  ENDFOR


  OPENW, lun, filedir + date, /get_lun
  ncount = INTARR(nlat,nlon)
  aodmean  = FLTARR(nlat,nlon)
  FOR j = 0, nlat-1 DO BEGIN
   FOR k = 0, nlon-1 DO BEGIN
      index = WHERE(aod_month(j,k,0:n-1) gt 0.0, count)
      IF (count gt 0) THEN BEGIN
      aodmean(j,k) = mean(aod_month[j,k,index])
      ncount(j,k)= count
      IF (aodmean(j,k) eq 0.0) THEN BEGIN
      aodmean(j,k) = -999.99
      ENDIF
      PRINTF, lun, lat(j,k), lon(j,k), aodmean(j,k), ncount(j,k)
      ENDIF ELSE BEGIN
      IF (aodmean(j,k) eq 0.0) THEN BEGIN
      aodmean(j,k) = -999.99
      ENDIF
      PRINTF, lun, lat(j,k), lon(j,k), aodmean(j,k), ncount(j,k)
      ENDELSE
   ENDFOR
  ENDFOR
  FREE_LUN, lun


  SET_PLOT, 'ps'
  DEVICE, filename =filedirres + 'plot_200304_aod.ps', /portrait, xsize = 7.5, ysize=9, $
          xoffset = 0.5, yoffset = 1, /inches, /color, bits=8

  MYCT, 33, ncolors =  180, range = [0.0, 1]
  TVMAP, transpose(aodmean), /grid,$
         LIMIT=[minlat, minlon, maxlat, maxlon], /ISOTROPIC, sample = 4, $
         title = 'AOD(Terra) 200304',$
         /cbar,DIVISIONS = 5, maxdata = 0.8, mindata = 0, $
         CBMIN = 0, CBMAX = 0.8, /COUNTRIES, /COAST, $
         MIN_VALID = 0.00001

  DEVICE, /close

  END

