
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PURPOSE OF THIS PROGRAM : PLOT THE CONTOUR PLOT USING WPS GEOG DATA
; THE STEPS ARE AS FOLLOWING : 
; 1, READ DATA FROM WRF OUTPUT .NC FILE
; 2, PLOT A MAP WITH A SPECIFIED PROJECTION (NOT NATIVE)
; 3, PLOT A CONTOUR OVER A MAP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin

; OPEN WRF/CHEM OUTPUT FILE
  dir     = "./"
  filename= "geo_em.d01_china_qu.nc"
  a       = addfile(dir + filename,"r")

; OPEN A WORKSTATION AND CHOOSE COLORMAP
  type    = "x11"
; type    = "pdf"
; type    = "png"
  wks     = gsn_open_wks(type,"1plt_contour_topo_height_v01")
  gsn_define_colormap(wks,"WhAqGrYeOrReVi200")

; SET UP THE DESIRED MODS FOR THE MAP AND PLOT
  res                             = True
; RANGE OF STUDY AREA
;                                   CHINA     WA       CA    
  minlat                          =  17.0    ;30.0    ;-15.0
  maxlat                          =  55.0    ;45.0    ; 35.0
  minlon                          =  72.0    ;-130.0  ;-25.0
  maxlon                          = 136.0    ;-110.0  ; 45.0


; SET UP MAP PROJECTION AND LIMITED REGION
  res@mpProjection                = "CylindricalEquidistant"
  res@mpCenterRotF                = 0.0
  res@mpGridAndLimbOn             = True
  res@mpGridLatSpacingF           = 5.0
  res@mpGridLonSpacingF           = 5.0
  res@mpLimitMode                 = "latlon"
  res@mpMinLatF                   = minlat
  res@mpMaxLatF                   = maxlat
  res@mpMinLonF                   = minlon
  res@mpMaxLonF                   = maxlon

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

; MAXIMIZE PLOT IN FRAME
  res@gsnMaximize                 = True
; THE DATA IS NOT GLOBAL
  res@gsnAddCyclic                = False
; SET UP THE FEATRUED TITLE
  res@gsnLeftString               = "Topography Height"
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
; res@cnMinLevelValF              = 100.0
; res@cnMaxLevelValF              = 2100.0
; res@cnLevelSpacingF             = 100.0
  res@cnLevelSelectionMode        = "ExplicitLevels"
  res@cnLevels                    = (/5, 10, 20, 30, 40, 50, 100, 150, 200, 300, 400, \
                                      500, 1000, 1500, 2000, 2500, 3000, 3500, 4000,  \
                                      5000, 6000, 7000/)


; SET UP LABEL BAR
  res@pmLabelBarWidthF            = 0.6
  res@pmLabelBarHeightF           = 0.08
  res@lbLabelFontHeightF          = 0.013
  res@lbLabelStride               = 2
  res@lbBoxLinesOn                = False


; PLOT THE CONTOUR OVER THE CE MAP
; READ TT DATA FROM WRF/CHEM met_em FILE AND SET XLAT AND XLONG AS THE ATTRIBUTE OF TT
   times     = a->Times(0,:)
   topo      = a->HGT_M(0,:,:)
   topo@lat2d= a->XLAT_M(0,:,:)
   topo@lon2d= a->XLONG_M(0,:,:)
   res@lbTitleString          = topo@description + "  " + "(" + topo@units + ")"
   res@lbTitleFontHeightF     = 0.015
   res@lbTitlePosition        = "Bottom"

   map = gsn_csm_contour_map(wks,topo(:,:),res)
end
