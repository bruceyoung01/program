
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PURPOSE OF THIS PROGRAM : PLOT THE CONTOUR PLOT USING WRF/CHEM OUTPUT
; THE STEPS ARE AS FOLLOWING : 
; 1, READ DATA FROM WRF OUTPUT .NC FILE
; 2, PLOT A MAP WITH A SPECIFIED PROJECTION (NOT NATIVE)
; 3, PLOT A CONTOUR OVER A MAP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin

; OPEN WRF/CHEM OUTPUT FILE
  a = addfile("/home/bruce/sshfs/pf/model/wrfchem4/WRFV3/test/em_real/sixteen_pt_four_pt_average_4pt/wrfout_d01_2008-05-07_00:00:00.nc","r")
  b = addfile("/home/bruce/sshfs/pf/model/wrfchem4/WRFV3/test/em_real/nearest_neighbor/wrfout_d01_2008-05-07_00:00:00.nc","r")

; OPEN A WORKSTATION AND CHOOSE COLORMAP
; type = "x11"
; type = "pdf"
; type = "ps"
; type = "ncgm"
  type = "png"
  wks = gsn_open_wks(type,"1plt_wrf_contour_pm25_d_2008-05-07")
  gsn_define_colormap(wks,"BlAqGrYeOrReVi200")

; SET UP THE DESIRED MODS FOR THE MAP AND PLOT
  res             = True

; SET UP MAP PROJECTION AND LIMITED REGION
  res@mpProjection = "CylindricalEquidistant"
  res@mpCenterRotF      = 0.0
  res@mpGridAndLimbOn   = True
  res@mpGridLatSpacingF = 5.0
  res@mpGridLonSpacingF = 5.0
  res@mpLimitMode    = "latlon"
  res@mpMinLatF      = 10.0
  res@mpMaxLatF      = 45.0
  res@mpMinLonF      = -115.0
  res@mpMaxLonF      = -65.0

; COLOR OF CONTINIENTAL OUTLINES
  res@mpOutlineOn            = True
  res@mpGeophysicalLineThicknessF = 2.0
  res@mpGridLineThicknessF        = 1.5
  res@mpLimbLineThicknessF        = 2.0
  res@mpNationalLineThicknessF    = 2.0
  res@mpUSStateLineThicknessF     = 2.0
  res@mpGridLineDashPattern       = 2
  res@mpOutlineBoundarySets       = "GeophysicalAndUSStates"

; TURN ON MAP TICKNARKS
  res@pmTickMarkDisplayMode       = "always"
  ;plot_base = gsn_csm_map(wks,res)

; MAXIMIZE PLOT IN FRAME
  res@gsnMaximize = True
; THE DATA IS NOT GLOBAL
  res@gsnAddCyclic= False
; SET UP THE FEATRUED TITLE
  res@gsnLeftString                = "PM2.5 SURFACE MASS CONCENTRATION"
  res@gsnStringFontHeightF         = 0.02
  res@gsnLeftStringOrthogonalPosF  = 0.02

; COLOR PLOT DEDIRED
  res@cnFillOn = True
; TURN OFF CONTOUR LINES
  res@cnLinesOn = False
; TURN OFF CONTOUR LABELS
  res@cnLineLabelsOn = False

; SET UP COLOR MAP AND LABEL
  res@gsnSpreadColors = True
  res@gsnSpreadColorStart = 0
  res@gsnSpreadColorEnd   = 200
  res@cnInfoLabelOn        = True
  res@cnInfoLabelFontHeightF = 0.01

  res@cnLevelSelectionMode   = "ManualLevels"
  res@cnMinLevelValF           = -5.0
  res@cnMaxLevelValF           = 5.0
  res@cnLevelSpacingF        = 1.0

; SET UP LABEL BAR
  res@pmLabelBarWidthF       = 0.6
  res@pmLabelBarHeightF      = 0.08
  res@lbLabelFontHeightF     = 0.013
  res@lbLabelStride          = 2
  res@lbBoxLinesOn           = False


; PLOT THE CONTOUR OVER THE CE MAP
  do it = 0, 23, 1

; READ PM2.5 DATA FROM WRF/CHEM OUTPUT FILE AND SET XLAT AND XLONG AS THE ATTRIBUTE OF PM25
   times       = a->Times(it,:)
   pm25a       = a->PM2_5_DRY(it,:,:,:)
   pm25a@lat2d = a->XLAT(it,:,:)
   pm25a@lon2d = a->XLONG(it,:,:)
   pm25b       = b->PM2_5_DRY(it,:,:,:)
   pm25b@lat2d = b->XLAT(it,:,:)
   pm25b@lon2d = b->XLONG(it,:,:)
   pm25 = pm25a - pm25b
   pm25@lat2d  = a->XLAT(it,:,:)
   pm25@lon2d  = a->XLONG(it,:,:)


   res@tiMainString = "WRF/CHEM 16_pt + 4_pt + average_4pt - Nearest neighbor "+times
   res@tiMainFontHeightF      = 0.02
   res@lbTitleString          = pm25a@description + "  " + "(" + pm25a@units + ")"
   res@lbTitleFontHeightF     = 0.015
   res@lbTitlePosition        = "Bottom"
   map = gsn_csm_contour_map(wks,pm25(0,:,:),res)
  end do


end
