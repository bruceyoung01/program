;   Example script to produce plots for a WRF/CHEM real-data run,
;   with the ARW coordinate dynamics option.

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin
;
; The WRF ARW input file.  
; This needs to have a ".nc" appended, so just do it.
  a = addfile("/media/disk/data/wrfchem/test/met_wrfout/met_em.d01.2003-05-01_10:00:00.nc","r")
  b = addfile("/media/disk/data/wrfchem/test/met_wrfout/narr/met_em.d01.2003-05-01_10:00:00.nc","r")
  c = addfile("/media/disk/data/wrfchem/test/met_wrfout/wrfout_d01_2003-05-02_09:00:00.nc", "r")

; We generate plots, but what kind do we prefer?
  type = "x11"
; type = "pdf"
; type = "ps"
; type = "ncgm"
  wks  = gsn_open_wks(type,"1plt_met_wrfout_height_2003-05-01_10")


; Set some Basic Plot options
  res    = True
  res@MainTitle = "Final Analysis"

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
  ha = wrf_user_getvar(a,"GHT",it)
  hb = wrf_user_getvar(b,"height",it)
  hc = wrf_user_getvar(c,"height",it)

  z_planea  = wrf_user_intrp3d( ha,pa,"h",pressure,0.,False)
  z_planeb  = wrf_user_intrp3d( hb,pb,"h",pressure,0.,False)
  z_planec  = wrf_user_intrp3d( hc,pc,"h",pressure,0.,False)
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
  optsa@MainTitle = "Final Analysis"
  optsb = True
  optsb = opts
  optsb@MainTitle = "NARR"
  optsc = True
  optsc = opts
  optsc@MainTitle = "36 Hours Run"

  contourza = wrf_contour(a,wks,z_planea(:,:),optsa)
  contourzb = wrf_contour(b,wks,z_planeb(:,:),optsb)
  contourzc = wrf_contour(c,wks,z_planec(:,:),optsc)
  delete(opts)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PLOT THE CONTOUR PLOT
  plot = wrf_map_overlays(a,wks,(/contourza/),res,mpres)
  plot = wrf_map_overlays(b,wks,(/contourzb/),res,mpres)
  plot = wrf_map_overlays(c,wks,(/contourzc/),res,mpres)
 ;plot = wrf_map_overlays(b,wks,(/contourz1/),pltres,mpres)
 ;plot = wrf_map_overlays(c,wks,(/contourz2/),pltres,mpres)
 ;plot = wrf_map_overlays(a,wks,(/contourtt/),pltres,mpres)
 ;plot = wrf_map_overlays(a,wks,(/contourtt2/),pltres,mpres)
 ;plot = wrf_map_overlays(a,wks,(/contourtt3/),pltres,mpres)
 ;plot = wrf_map_overlays(a,wks,(/contourtta/),pltres,mpres)
 ;plot = wrf_map_overlays(a,wks,(/contourttb/),pltres,mpres)
 ;plot = wrf_map_overlays(a,wks,(/contourttc/),pltres,mpres)

end

