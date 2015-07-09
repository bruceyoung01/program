;   Example script to produce plots for a WRF/CHEM real-data run,
;   with the ARW coordinate dynamics option.

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin
;
; The WRF ARW input file.  
; This needs to have a ".nc" appended, so just do it.
  a = addfile("/media/disk/data/wrfchem/test/met_wrfout/met_em.d01.2003-05-01_12:00:00.nc","r")
  b = addfile("/media/disk/data/wrfchem/test/met_wrfout/narr/met_em.d01.2003-05-01_12:00:00.nc","r")
  c = addfile("/media/disk/data/wrfchem/test/met_wrfout/wrfout_d01_2003-05-01_12:00:00.nc", "r")
  d = addfile("/media/disk/data/wrfchem/test/met_wrfout/wrfinput/wrfinput_d01_2003-05-01.nc", "r")

; READ GRIB FILE AND CONVERT IT INTO NETCDF FILE
  grib_in = addfile("/media/disk/data/wrfchem/test/met_wrfout/fnl/fnl_20030501_12_00.grb", "r")
  names   = getfilevarnames(grib_in)
  print(names)
  e       = addfile("/media/disk/data/wrfchem/test/met_wrfout/fnl/fnl_20030501_12_00.nc", "c")
  do i = 0, dimsizes(names)-1
   e ->$names(i)$ = grib_in->$names(i)$
  end do

; We generate plots, but what kind do we prefer?
  type = "x11"
; type = "pdf"
; type = "ps"
; type = "ncgm"
  wks  = gsn_open_wks(type,"1plt_met_wrfout_height_2003-05-01_12")


; Set some Basic Plot options
  res    = True
  mpres  = True
  mpres@mpGeophysicalLineThicknessF = 2.0
  mpres@mpUSStateLineThicknessF     = 2.0
  mpres@mpNationalLineThicknessF    = 2.0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; What times and how many time steps are in the data set?
  times  = wrf_user_list_times(a)  ; get times in the file
  ntimes = dimsizes(times)         ; number of times in the file

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  pressure = 700
  it       = 0

  print("Working on time: " + times(it) )
  res@TimeLabel = times(it)   ; Set Valid time to use on plots

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; REAF VARIABLE

  pa = wrf_user_getvar(a,"pressure",it)
  pb = wrf_user_getvar(b,"pressure",it)
  pc = wrf_user_getvar(c,"pressure",it)
  pd = wrf_user_getvar(d,"pressure",it)
  ;pe = wrf_user_getvar(e,"pressure",it)
  ha = wrf_user_getvar(a,"GHT",it)
  hb = wrf_user_getvar(b,"height",it)
  hc = wrf_user_getvar(c,"height",it)
  hd = wrf_user_getvar(d,"height",it)
  ;he = wrf_user_getvar(e,"height",it)

  z_planea  = wrf_user_intrp3d( ha,pa,"h",pressure,0.,False)
  z_planeb  = wrf_user_intrp3d( hb,pb,"h",pressure,0.,False)
  z_planec  = wrf_user_intrp3d( hc,pc,"h",pressure,0.,False)
  z_planed  = wrf_user_intrp3d( hd,pd,"h",pressure,0.,False)

; SELECT LEVEL
  level = 0
  display_level = level + 1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; HEIGHT
  opts = res
  opts@cnLineColor         = "Blue"
  opts@cnFillOn            = True
  opts@ContourParameters = (/ 2920., 3220., 20. /)
; SET UP TITLE FOR DIFFERENT DATA SOURCES
  optsa = True
  optsa = opts
  optsa@MainTitle = "Final Analysis WPS"
  optsb = True
  optsb = opts
  optsb@MainTitle = "NARR WPS"
  optsc = True
  optsc = opts
  optsc@MainTitle = "36 Hours Run Initial"
  optsd = True
  optsd = opts
  optsd@MainTitle = "Real Initial"

  contourza = wrf_contour(a,wks,z_planea(:,:),optsa)
  contourzb = wrf_contour(b,wks,z_planeb(:,:),optsb)
  contourzc = wrf_contour(c,wks,z_planec(:,:),optsc)
  contourzd = wrf_contour(d,wks,z_planed(:,:),optsd)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PLOT THE CONTOUR PLOT
  plot = wrf_map_overlays(a,wks,(/contourza/),res,mpres)
  ;plot = wrf_map_overlays(b,wks,(/contourzb/),res,mpres)
  plot = wrf_map_overlays(c,wks,(/contourzc/),res,mpres)
  plot = wrf_map_overlays(d,wks,(/contourzd/),res,mpres)

end

