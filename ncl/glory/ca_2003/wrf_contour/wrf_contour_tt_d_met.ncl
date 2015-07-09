
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
  filesa  = systemfunc("ls /home/bruce/sshfs/pf/model/wrfchem4/WPS/sixteen_pt_four_pt_average_4pt/met_em.d01.2008-05-07*.nc")
  a       = addfiles(filesa,"r")
  nfilesa = dimsizes(filesa)
  ListSetType(a, "join")
  filesb  = systemfunc("ls /home/bruce/sshfs/pf/model/wrfchem4/WPS/nearest_neighbor/met_em.d01.2008-05-07*.nc")
  b       = addfiles(filesb,"r")
  nfilesb = dimsizes(filesb)
  ListSetType(b, "join")

; OPEN A WORKSTATION AND CHOOSE COLORMAP
; type = "x11"
; type = "pdf"
; type = "ps"
; type = "ncgm"
  type = "png"
  wks = gsn_open_wks(type,"1plt_wrf_contour_tt_d_met_2008-05-07")
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
;  res@mpGeophysicalLineColor      = "White"
;  res@mpNationalLineColor         = "White"
;  res@mpUSStateLineColor          = "White"
;  res@mpGridLineColor             = "White"
;  res@mpLimbLineColor             = "White"
;  res@mpPerimLineColor            = "White"
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
  res@gsnLeftString                = "Temperature"
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
  res@cnMinLevelValF         = -10.0
  res@cnMaxLevelValF         = 10.0
  res@cnLevelSpacingF        = 1.0

; SET UP LABEL BAR
  res@pmLabelBarWidthF       = 0.6
  res@pmLabelBarHeightF      = 0.08
  res@lbLabelFontHeightF     = 0.013
  res@lbLabelStride          = 2
  res@lbBoxLinesOn           = False


; PLOT THE CONTOUR OVER THE CE MAP
  do i = 0, nfilesa - 1
; READ TT DATA FROM WRF/CHEM met_em FILE AND SET XLAT AND XLONG AS THE ATTRIBUTE OF TT
   times     = a[i]->Times(0,0,:)
   tta       = a[i]->TT(0,0,0,:,:)
   tta@lat2d = a[i]->XLAT_M(0,0,:,:)
   tta@lon2d = a[i]->XLONG_M(0,0,:,:)
   ttb       = b[i]->TT(0,0,0,:,:)
   ttb@lat2d = b[i]->XLAT_M(0,0,:,:)
   ttb@lon2d = b[i]->XLONG_M(0,0,:,:)
   tt = tta - ttb
   tt@lat2d = b[i]->XLAT_M(0,0,:,:)
   tt@lon2d = b[i]->XLONG_M(0,0,:,:)

print(times)
   res@tiMainString = "WRF/CHEM   " + times
   res@tiMainFontHeightF      = 0.02
   res@lbTitleString          = tta@description + "  " + "(" + tta@units + ")"
   res@lbTitleFontHeightF     = 0.015
   res@lbTitlePosition        = "Bottom"
   map = gsn_csm_contour_map(wks,tt(:,:),res)
   end do
end
