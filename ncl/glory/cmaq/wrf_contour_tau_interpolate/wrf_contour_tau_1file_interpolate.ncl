; $ID: wrf_contour_tau_1file_interpolate.ncl V01 01/18/2012 21:15 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM wrf_contour_tau_1file_interpolate IS USED TO PLOT TAU CONTOUR ON A MAP.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (01/18/2012)
;******************************************************************************

;  LOAD LIBRARIES
   load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
   load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
   load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/universal/interpolate_aod.ncl"

begin

; OPEN A WORKSTATION AND CHOOSE COLORMAP
; type = "x11"
  type = "pdf"
; type = "png"
  wks = gsn_open_wks(type,"1plt_wrf_contour_tau_interpolate_v02_2007_winter")
  gsn_define_colormap(wks,"WhAqGrYeOrReVi200")

; READ WRFCHEM FILE LIST
; dir      = "/home/bruce/sshfs/shw/model/wrfchem34_1/WRFV3/test/em_real/wrfout_cmaq_2007_summer/wrfout/"
  dir      = "/home/bruce/sshfs/shw/data/wrf_output/wrfout_cmaq_2007_winter/wrfout_test/2007_winter_3hr/"
  filelist = "2007_wrfout_d01"
  filename = asciiread(dir + filelist, -1, "string")
  nfiles   = dimsizes(filename)

; SET UP THE DESIRED MODS FOR THE MAP AND PLOT
  res                             = True

; SET UP MAP PROJECTION AND LIMITED REGION
  res@mpProjection                = "CylindricalEquidistant"
  res@mpCenterRotF                = 0.0
  res@mpGridAndLimbOn             = True
  res@mpGridLatSpacingF           = 5.0
  res@mpGridLonSpacingF           = 5.0
  res@mpLimitMode                 = "latlon"
  res@mpMinLatF                   =  25.0
  res@mpMaxLatF                   =  50.0
  res@mpMinLonF                   =-130.0
  res@mpMaxLonF                   = -65.0

; COLOR OF CONTINIENTAL OUTLINES
  res@mpOutlineOn                 = True
  res@mpGeophysicalLineColor      = "Black"
  res@mpNationalLineColor         = "Black"
  res@mpGridLineColor             = "Black"
  res@mpLimbLineColor             = "Black"
  res@mpPerimLineColor            = "Black"
  res@mpGeophysicalLineThicknessF = 2.0
  res@mpGridLineThicknessF        = 1.5
  res@mpLimbLineThicknessF        = 2.0
  res@mpNationalLineThicknessF    = 2.0
  res@mpGridLineDashPattern       = 2
  res@mpOutlineBoundarySets       = "National"

; TURN ON MAP TICKNARKS
  res@pmTickMarkDisplayMode       = "always"
  res@mpFillDrawOrder             = "PreDraw"

; SET UP THE FEATRUED TITLE
  res@gsnLeftString               = "Aerosol Optical Depth (550 nm)"
  res@gsnStringFontHeightF        = 0.02
  res@gsnLeftStringOrthogonalPosF = 0.02

; COLOR PLOT DEDIRED
  res@cnFillOn                    = True
; TURN OFF CONTOUR LINES
  res@cnLinesOn                   = False
; TURN OFF CONTOUR LABELS
  res@cnLineLabelsOn              = False

; SET UP COLOR MAP AND LABEL
  res@gsnSpreadColors             = True
  res@gsnSpreadColorStart         = 0
  res@gsnSpreadColorEnd           = 200
  res@cnInfoLabelOn               = True
  res@cnInfoLabelFontHeightF      = 0.01

; res@cnLevelSelectionMode        = "ManualLevels"
; res@cnMinLevelValF              = 0.1
; res@cnMaxLevelValF              = 1.0
; res@cnLevelSpacingF             = 0.1
  res@cnLevelSelectionMode        = "ExplicitLevels"
  res@cnLevels                    = (/0.0, 0.02, 0.04, 0.06, 0.08, 0.1, 0.12, 0.14, 0.16, 0.18, 0.2, \
                                      0.22, 0.24, 0.26, 0.28, 0.3, 0.32, 0.34, 0.36, 0.38, 0.4/)

; SET UP THE POSITION OF THE CONTOUR PLOT
  res@mpShapeMode                 = "FreeAspect"
  res@vpWidthF                    = 0.7
  res@vpHeightF                   = 0.45
  res@vpXF                        = 0.15
  res@vpYF                        = 0.7
  res@gsnFrame                    = False

; SET UP LABEL BAR
  res@pmLabelBarWidthF            = 0.6
  res@pmLabelBarHeightF           = 0.08
  res@lbLabelFontHeightF          = 0.013
  res@lbLabelStride               = 2
  res@lbBoxLinesOn                = False
  res@lbAutoManage                = False

; WAVELENGTH SET UP
  lambda1 = 400.0
  lambda2 = 600.0
  lambda  = 550.0

; GET THE DIMENSION OF WRFCHEM DATA
  a      = addfile(dir + filename(0) + ".nc", "r")
  lat    = a->XLAT(0, :, :)
  lon    = a->XLONG(0, :, :)
  taua   = a->TAUAER1(0, :, :, :)
  ndim   = dimsizes(taua)
  nlevel = ndim(0)
  nlat   = ndim(1)
  nlon   = ndim(2)
  tau    = new((/nlat, nlon/), typeof(taua))
  ttau   = new((/nlat, nlon/), typeof(taua))

; PLOT THE CONTOUR OVER THE CE MAP
  icount = 0
  ttau   = 0.0
  do i = 0, nfiles-1
   a          = addfile(dir + filename(i) + ".nc", "r")
   times      = a->Times
   taua       = a->TAUAER2(0, :, :, :)
   taub       = a->TAUAER3(0, :, :, :)
   tau1       = dim_sum_n(taua, 0)
   tau2       = dim_sum_n(taub, 0)
;  CALL RPOCEDURE interpolate_aod.ncl TO INTERPOLATE AOD
   interpolate_aod(lambda1, tau1, lambda2, tau2, lambda, tau)
   tau@lat2d  = a->XLAT(0, :, :)
   tau@lon2d  = a->XLONG(0, :, :)
   ttau       = ttau + tau
   icount     = icount + 1
   print("WORKING ON TIME : " + times)
   tres                       = True
   tres                       = res
   tau@description            = "Aerosol Optical Depth"
   tres@tiMainString          = "WRFCHEM AOD  "+times
   tres@tiMainFontHeightF     = 0.02
   tres@lbTitleString         = tau@description 
   tres@lbTitleFontHeightF    = 0.015
   tres@lbTitlePosition       = "Bottom"
   tres@gsnFrame              = False
;  plot = gsn_csm_contour_map(wks,tau,tres)
;  frame(wks)
  end do

;  WRITE TOTAL AVERAGE TO NETCDF FILE
   system("/bin/rm -f cmaq_2006_summer.nc")
   ncdf = addfile("cmaq_2006_summer.nc", "c")

   filedimdef(ncdf, "time", -1, True)

   lat@long_name   = "Latitude"
   lat@units       = "degree"
   lon@long_name   = "Longitude"
   lon@units       = "degree"
   ttau!0          = "lat"
   ttau!1          = "lon"
   ttau@long_name  = "AOD at 550nm"
   ttau@units      = " "
   ncdf->XLAT      = lat
   ncdf->XLONG     = lon
   ncdf->TAUAER550 = ttau

;  PLOT THE TOTAL AVERAGE
   ttau                        = ttau/icount
   ttres                       = True
   ttres                       = tres
   ttau@lat2d                  = a->XLAT(0, :, :)
   ttau@lon2d                  = a->XLONG(0, :, :)
   ttres@tiMainString          = "WRFCHEM AOD 2007 winter"
   plot = gsn_csm_contour_map(wks,ttau,ttres)
   frame(wks)
end
