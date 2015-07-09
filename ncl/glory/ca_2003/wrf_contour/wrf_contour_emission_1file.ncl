;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PURPOSE OF THIS PROGRAM : PLOT THE CONTOUR PLOT USING WRF/CHEM OUTPUT;
; THE STEPS ARE AS FOLLOWING :                                         ;
; (1 ), READ DATA FROM WRF OUTPUT .NC FILE                             ;
; (2 ), PLOT A MAP WITH A SPECIFIED PROJECTION (NOT NATIVE)            ;
; (3 ), PLOT A CONTOUR OVER A MAP                                      ;
; (4 ), MODIFY FOR ONE-HOUR PER FILE (BRUCE 03/21/2012 CONTINUING)     ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"

begin

; OPEN WRF/CHEM OUTPUT FILE
  wdir     = "/home/bruce/sshfs/pfw/model/wrfchem2/WRFV3/test/em_real/wrfout_sahel_650/"
  wfilelist= "wrfout_d01_2008"
  wfname   = asciiread(wdir + wfilelist, -1, "string")
  wnfname  = dimsizes(wfname)

; READ EMISSION DATA
  dir      = "/home/bruce/sshfs/pfw/model/wrfchem2/WRFV3/test/em_real/"
  filelist = "2008_wrfchemi"
  fname    = asciiread(dir + filelist, -1, "string")
  nfname   = dimsizes(fname)

; OPEN A WORKSTATION AND CHOOSE COLORMAP
; type     = "x11"
  type     = "pdf"
; type     = "png"
  wks      = gsn_open_wks(type,"1plt_wrf_contour_pm25_2008_sahel")
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
; plot_base = gsn_csm_map(wks,res)

; MAXIMIZE PLOT IN FRAME
  res@gsnMaximize                 = True
; THE DATA IS NOT GLOBAL
  res@gsnAddCyclic                = False
; SET UP THE FEATRUED TITLE
  res@gsnLeftString               = "Emission Rate"
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

  res@cnLevelSelectionMode        = "ManualLevels"
  res@cnMinLevelValF              = 0.05
  res@cnMaxLevelValF              = 0.55
  res@cnLevelSpacingF             = 0.05

; SET UP LABEL BAR
  res@pmLabelBarWidthF            = 0.6
  res@pmLabelBarHeightF           = 0.08
  res@lbLabelFontHeightF          = 0.013
  res@lbLabelStride               = 2
  res@lbBoxLinesOn                = False

; PLOT THE CONTOUR OVER THE CE MAP
; READ PM2.5 DATA FROM WRF/CHEM OUTPUT FILE AND SET XLAT AND XLONG AS THE ATTRIBUTE OF PM25
  do i = 0, nfname-1
   a = addfile(dir + fname(i) + ".nc", "r")
   b = addfile(wdir+wfname(0) + ".nc", "r")
   do j = 0, 11
    times      = a->Times(j,:)
    orgj       = a->E_ORGJ(j,:,:,:)
    ecj        = a->E_ECJ(j,:,:,:)
    orgj@lat2d = b->XLAT(0,:,:)
    orgj@lon2d = b->XLONG(0,:,:)
    ecj@lat2d  = b->XLAT(0,:,:)
    ecj@lon2d  = b->XLONG(0,:,:)
    pm25       = orgj + ecj
    pm25@lat2d = b->XLAT(0,:,:)
    pm25@lon2d = b->XLONG(0,:,:)
    res@tiMainString      = "WRF-Chem "+times
    res@tiMainFontHeightF = 0.02
    pm25@description      = "Emission Rdate"
    pm25@units            = "~F33~m~F0~g/m~S~2~N~/s"
    res@lbTitleString     = pm25@description + "  " + "(" + pm25@units + ")"
    res@lbTitleFontHeightF= 0.015
    res@lbTitlePosition   = "Bottom"
    map = gsn_csm_contour_map(wks,pm25(0,:,:),res)
   end do
  end do


end
