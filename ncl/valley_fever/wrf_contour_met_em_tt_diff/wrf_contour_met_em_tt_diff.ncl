;  $ID: wrf_contour_met_em_tt_diff.ncl V01 04/17/2014 22:47 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM wrf_contour_met_em_tt_diff READS VARIABLE (TT) TWO met_em FILES FROM
;  WPS AND CESM, CALCULATES THE DIFFERENCES BETWEEN THEM, AND PLOT AS CONTOUR.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (04/17/2014)
;******************************************************************************

;  LOAD FUNCTIONS AND PROCEDURES
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin

; OPEN A WORKSTATION AND CHOOSE COLORMAP
; type = "x11"
  type = "pdf"
; type = "png"
  wks = gsn_open_wks(type,"1plt_wrf_contour_met_em_tt_diff_narr_cesm")
  gsn_define_colormap(wks,"BlWhRe")

  str       = "string"

; OPEN met_em.d0 FILE
; CESM
  dira      = "/Volumes/TOSHIBA_3B/iproject/valley_fever/wrf_input/met_em/cam2wrf/2d_test/"
  filelista = "met_em_d01_list"
  filenamea = asciiread(dira + filelista, -1, str)
  nfilea    = dimsizes(filenamea)
; NARR
  dirb      = "/Volumes/TOSHIBA_3B/iproject/valley_fever/wrf_input/met_em/ungrib/2d_test/"
  filelistb = "met_em_d01_list"
  filenameb = asciiread(dirb + filelistb, -1, str)
  nfileb    = dimsizes(filenameb)

; SET UP THE DESIRED MODS FOR THE MAP AND PLOT
  res                             = True

; SET UP MAP PROJECTION AND LIMITED REGION
  res@mpProjection                = "CylindricalEquidistant"
  res@mpCenterRotF                = 0.0
  res@mpGridAndLimbOn             = True
  res@mpGridLatSpacingF           = 5.0
  res@mpGridLonSpacingF           = 5.0
  res@mpLimitMode                 = "latlon"
  res@mpMinLatF                   = 25.0
  res@mpMaxLatF                   = 45.0
  res@mpMinLonF                   = -125.0
  res@mpMaxLonF                   = -95.0

; COLOR OF CONTINIENTAL OUTLINES
  res@mpOutlineOn                 = True
  res@mpGeophysicalLineColor      = "Black"
  res@mpNationalLineColor         = "Black"
  res@mpUSStateLineColor          = "Black"
  res@mpGridLineColor             = "Black"
  res@mpLimbLineColor             = "Black"
  res@mpPerimLineColor            = "Black"
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
  res@gsnMaximize                 = True
; THE DATA IS NOT GLOBAL
  res@gsnAddCyclic                = False
; SET UP THE FEATRUED TITLE
  res@gsnLeftString               = "Temperature"
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
  res@gsnSpreadColorStart         = 2
  res@gsnSpreadColorEnd           = 102
  res@cnInfoLabelOn               = True
  res@cnInfoLabelFontHeightF      = 0.01
  res@cnLevelSelectionMode        = "ManualLevels"
  res@cnMinLevelValF              = -10.0
  res@cnMaxLevelValF              = 10.0
  res@cnLevelSpacingF             = 0.2

; SET UP LABEL BAR
  res@pmLabelBarWidthF            = 0.6
  res@pmLabelBarHeightF           = 0.08
  res@lbLabelFontHeightF          = 0.013
  res@lbLabelStride               = 5
  res@lbBoxLinesOn                = False


; PLOT THE CONTOUR OVER THE CE MAP
  do i = 0, nfilea-1, 6
     a          = addfile(dira + filenamea(i) + ".nc", "r")
     b          = addfile(dirb + filenameb(i) + ".nc", "r")
; READ TT DATA FROM WRF/CHEM met_em FILE AND SET XLAT AND XLONG AS THE ATTRIBUTE OF TT
     time       = a->Times(0,:)
     print("NOW WORKING ON : " + time)
     tta        = a->TT(0,0,:,:)
     tta@lat2d  = a->XLAT_M(0,:,:)
     tta@lon2d  = a->XLONG_M(0,:,:)
     ttb        = b->TT(0,0,:,:)
     ttb@lat2d  = b->XLAT_M(0,:,:)
     ttb@lon2d  = b->XLONG_M(0,:,:)
     tt         = ttb - tta
     tt@lat2d   = a->XLAT_M(0,:,:)
     tt@lon2d   = a->XLONG_M(0,:,:)

     res@lbTitleString          = tta@description + "  " + "(K)"
     res@lbTitleFontHeightF     = 0.015
     res@lbTitlePosition        = "Bottom"
     res@tiMainString           = "CESM Temperature " + time
     res@tiMainFontHeightF      = 0.02
     map = gsn_csm_contour_map(wks, tt, res)
  end do
end
