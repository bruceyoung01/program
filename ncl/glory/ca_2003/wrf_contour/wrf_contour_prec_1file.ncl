;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PURPOSE OF THIS PROGRAM : PLOT THE CONTOUR PLOT USING WRF/CHEM OUTPUT;
; THE STEPS ARE AS FOLLOWING :                                         ;
; (1 ) READ DATA FROM WRF OUTPUT .NC FILE                              ;
; (2 ) PLOT A MAP WITH A SPECIFIED PROJECTION (NOT NATIVE)             ;
; (3 ) PLOT A CONTOUR OVER A MAP                                       ;
; (4 ) MODIFY FOR ONE-HOUR PER FILE (BRUCE 11/15/2011 CONTINUING)      ;
; (5 ) PLOT TOTAL PRECIPITATION. (BRUCE 02/29/2012 23:38)              ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin

; OPEN WRF/CHEM OUTPUT FILE
  dir      = "/home/bruce/sshfs/pfw/model/wrfchem33_1/WRFV3/test/em_real/wrfout_sahel_650/"
  filelist = "wrfout_d01_2008"
  fname    = asciiread(dir + filelist, -1, "string")
  nfname   = dimsizes(fname)

; OPEN A WORKSTATION AND CHOOSE COLORMAP
  type     = "x11"
; type     = "pdf"
; type     = "png"
  wks      = gsn_open_wks(type,"1plt_wrf_contour_prec_2008-02_v01")
  gsn_define_colormap(wks,"WhGrYeOrReVi200")

; SET UP THE DESIRED MODS FOR THE MAP AND PLOT
  res                             = True

; SET UP MAP PROJECTION AND LIMITED REGION
  res@mpProjection                = "CylindricalEquidistant"
  res@mpCenterRotF                = 0.0
  res@mpGridAndLimbOn             = True
  res@mpGridLatSpacingF           = 5.0
  res@mpGridLonSpacingF           = 5.0
  res@mpLimitMode                 = "latlon"
  res@mpMinLatF                   = -15.0
  res@mpMaxLatF                   =  35.0
  res@mpMinLonF                   = -25.0
  res@mpMaxLonF                   =  45.0

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
  res@gsnLeftString               = "Total Precipitation"
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
  res@gsnSpreadColorEnd           = 189
  res@cnInfoLabelOn               = True
  res@cnInfoLabelFontHeightF      = 0.01

  res@cnLevelSelectionMode        = "ManualLevels"
  res@cnMinLevelValF              = 2.0
  res@cnMaxLevelValF              = 42.0
  res@cnLevelSpacingF             = 2.0

; SET UP LABEL BAR
  res@pmLabelBarWidthF            = 0.6
  res@pmLabelBarHeightF           = 0.08
  res@lbLabelFontHeightF          = 0.013
  res@lbLabelStride               = 2
  res@lbBoxLinesOn                = False


; PLOT THE CONTOUR OVER THE CE MAP
  do i = 0, nfname-1
   a = addfile(dir + fname(i) + ".nc", "r")
; READ PRECIPITATION DATA FROM WRF/CHEM OUTPUT FILE AND 
; SET XLAT AND XLONG AS THE ATTRIBUTE OF PRECIPITATION
   times       = a->Times
   print("NOW WORKING ON : " + times)
   rain_exp    = a->RAINNC(0,:,:)
   rain_con    = a->RAINC(0,:,:)
   rain_tot    = rain_exp + rain_con
   rain_tot@lat2d = a->XLAT(0,:,:)
   rain_tot@lon2d = a->XLONG(0,:,:)
   rain_tot@description      = "Total Precipitation"
   rain_tot@units            = "mm"
   res@tiMainString          = "WRF/CHEM "+times
   res@tiMainFontHeightF     = 0.02
   res@lbTitleString         = rain_tot@description + "  " + \
                               "(" + rain_tot@units + ")"
   res@lbTitleFontHeightF    = 0.015
   res@lbTitlePosition       = "Bottom"
   map = gsn_csm_contour_map(wks,rain_tot,res)
  end do


end
