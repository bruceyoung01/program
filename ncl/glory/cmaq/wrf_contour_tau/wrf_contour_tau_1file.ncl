; $ID: wrf_contour_tau_1file.ncl V01 01/18/2012 21:15 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM wrf_contour_tau_1file IS USED TO PLOT TAU CONTOUR ON A MAP.
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

begin

; OPEN A WORKSTATION AND CHOOSE COLORMAP
; type = "x11"
; type = "pdf"
  type = "png"
  wks = gsn_open_wks(type,"1plt_wrf_contour_tau_v02_400")
  gsn_define_colormap(wks,"WhAqGrYeOrReVi200")

; READ WRFCHEM FILE LIST
; dir      = "/home/bruce/sshfs/shw/model/wrfchem34_1/WRFV3/test/em_real/wrfout_cmaq_2007_summer/wrfout/"
  dir      = "/home/bruce/sshfs/shw/data/wrf_output/wrfout_cmaq_2006_summer/wrfout/"
  filelist = "2006_wrfout_d01"
  filename = asciiread(dir + filelist, -1, "string")
  nfiles   = dimsizes(filename)

; SET UP THE DESIRED MODS FOR THE MAP AND PLOT
  res                   = True

; SET UP MAP PROJECTION AND LIMITED REGION
  res@mpProjection      = "CylindricalEquidistant"
  res@mpCenterRotF      = 0.0
  res@mpGridAndLimbOn   = True
  res@mpGridLatSpacingF = 5.0
  res@mpGridLonSpacingF = 5.0
  res@mpLimitMode       = "latlon"
  res@mpMinLatF         =  25.0
  res@mpMaxLatF         =  50.0
  res@mpMinLonF         =-130.0
  res@mpMaxLonF         = -65.0

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

; MAXIMIZE PLOT IN FRAME
  res@gsnMaximize                 = True
; THE DATA IS NOT GLOBAL
  res@gsnAddCyclic                = False
; SET UP THE FEATRUED TITLE
  res@gsnLeftString               = "Aerosol Optical Depth (400 nm)"
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
  res@cnLevels                    = (/0.02, 0.04, 0.06, 0.08, 0.1, 0.12, 0.14, 0.16, 0.18, 0.2, \
                                      0.22, 0.24, 0.26, 0.28, 0.3, 0.32, 0.34, 0.36, 0.38, 0.4, 0.42/)


; SET UP LABEL BAR
  res@pmLabelBarWidthF            = 0.6
  res@pmLabelBarHeightF           = 0.08
  res@lbLabelFontHeightF          = 0.013
  res@lbLabelStride               = 2
  res@lbBoxLinesOn                = False

; PLOT THE CONTOUR OVER THE CE MAP
  do i = 0, nfiles-1
   a          = addfile(dir + filename(i) + ".nc", "r")
   times      = a->Times
   taua       = a->TAUAER2(0, :, :, :)
   tau        = dim_sum_n(taua,0)
   tau@lat2d  = a->XLAT(0, :, :)
   tau@lon2d  = a->XLONG(0, :, :)
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
   plot = gsn_csm_contour_map(wks,tau,tres)
   delete(tres)
   frame(wks)
  end do
end
