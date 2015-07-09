; $ID wrf_contour_p_epa_v03_1file.ncl V01 11/15/2011 09:35 BRUCE EXP$
;
;******************************************************************************
; PURPOSE OF THIS PROGRAM :
; PLOT THE WRFCHEM SIMULATION LEVEL DATA WITH HEIGHT CONTOUR (700mb)
; =============================================================================
; NOTES:
; (1 ): ORIGINALLY WRITTEN BY RBUCE. (N/A)
; (2 ): MODIFIED BY BRUCE. (11/15/2011)
; (3 ): ADD WIND FIELD OVER THE PM2.5 CONTOUR PLOT. (11/23/2011)
; (4 ): OVERLAY WIND VECTOR ON THE CONTOUR PLOT. (12/08/2011)
;******************************************************************************

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm_epa.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/pro_fun.ncl"

begin

;--------------------------------------------WRF/CHEM---------------------------------
; OPEN WRF/CHEM OUTPUT FILE
  wfdir = "/home/bruce/sshfs/pfw/model/wrfchem2/WRFV3/test/em_real/wrfout_sahel_1200/"
  wfnamelist = "wrfout_d01_2008"
  wfname = asciiread(wfdir+wfnamelist, -1, "string")
  wnfname = dimsizes(wfname)
  do iw = 0, wnfname-1
  a    = addfile(wfdir + wfname(iw) + ".nc","r")
; THE DATE USED TO PLOT
  syear = str_get_cols(wfname(iw),11,14)
  smonth= str_get_cols(wfname(iw),16,17)
  sdate = str_get_cols(wfname(iw),19,20)
  shour = str_get_cols(wfname(iw),22,23)
  oyear  = stringtoint(syear)
  omonth = stringtoint(smonth)
  odate  = stringtoint(sdate)
  oit    = stringtoint(shour)
  jul   = greg2jul(oyear,omonth,odate,oit)
  cjul  = jul-0.25
  greg  = jul2greg(cjul)
  year  = greg(0)
  month = greg(1)
  date  = greg(2)
  it    = greg(3)
; OPEN A WORKSTATION AND CHOOSE COLORMAP
  type = "x11"
; type = "pdf"
; type = "png"
  wks  = gsn_open_wks(type,"1plt_wrf_contour_pm25_i_" + \
                      syear+"-"+smonth+"-"+sdate+"_"+shour+"_v03")
  gsn_define_colormap(wks,"WhBlGrYeOrReVi200")

;-----------------------WRFCHEM-------------------------------------
; THE SPECIFIC PRESSURE LEVELS THAT WE WANT THE DATA INTERPOLATED TO
  pressure = 700

; SET UP THE DESIRED MODS FOR THE MAP AND PLOT
  resmp    = True

; SET UP MAP PROJECTION AND LIMITED REGION
  resmp@mpProjection      = "CylindricalEquidistant"
  resmp@mpCenterRotF      = 0.0
  resmp@mpGridAndLimbOn   = True
  resmp@mpGridLatSpacingF = 5.0
  resmp@mpGridLonSpacingF = 5.0
  resmp@mpLimitMode       = "latlon"
  resmp@mpMinLatF         = -15.0
  resmp@mpMaxLatF         =  35.0
  resmp@mpMinLonF         = -25.0
  resmp@mpMaxLonF         =  45.0

; COLOR OF CONTINIENTAL OUTLINES
  resmp@mpOutlineOn                 = True
  resmp@mpGeophysicalLineColor      = "Black"
  resmp@mpNationalLineColor         = "Black"
  resmp@mpUSStateLineColor          = "Black"
  resmp@mpGridLineColor             = "Black"
  resmp@mpLimbLineColor             = "Black"
  resmp@mpPerimLineColor            = "Black"
  resmp@mpGeophysicalLineThicknessF = 3.0
  resmp@mpGridLineThicknessF        = 1.5
  resmp@mpLimbLineThicknessF        = 2.0
  resmp@mpNationalLineThicknessF    = 3.0
  resmp@mpUSStateLineThicknessF     = 2.0
  resmp@mpGridLineDashPattern       = 2
  resmp@mpOutlineBoundarySets       = "GeophysicalAndUSStates"

; TURN ON MAP TICKNARKS
  resmp@pmTickMarkDisplayMode       = "always"
  resmp@mpFillDrawOrder             = "PreDraw"
  resmp@gsnDraw                     = False
  resmp@gsnFrame                    = False

  map  = gsn_csm_map(wks,resmp)

; MAXIMIZE PLOT IN FRAME
  res             = True
  res@gsnMaximize = True
; THE DATA IS NOT GLOBAL
  res@gsnAddCyclic= False
; SET UP THE FEATRUED TITLE
  res@gsnLeftString                = " "
  res@gsnStringFontHeightF         = 0.02
  res@gsnRightStringOrthogonalPosF = 0.02
  res@gsnLeftStringOrthogonalPosF  = 0.02

; COLOR PLOT DEDIRED
  res@cnFillOn       = True
; TURN OFF CONTOUR LINES
  res@cnLinesOn      = False
; TURN OFF CONTOUR LABELS
  res@cnLineLabelsOn = False

; SET UP COLOR MAP AND LABEL
  res@gsnSpreadColors        = True
  res@gsnSpreadColorStart    = 0
  res@gsnSpreadColorEnd      = 200
  res@cnInfoLabelOn          = False
  res@cnInfoLabelPerimOn     = False

  res@cnLevelSelectionMode   = "ManualLevels"
  res@cnMinLevelValF         = 2.0
  res@cnMaxLevelValF         = 42.0
  res@cnLevelSpacingF        = 2.0

; SET UP LABEL BAR
  res@pmLabelBarWidthF       = 0.4
  res@pmLabelBarHeightF      = 0.04
  res@lbLabelFontHeightF     = 0.01
  res@lbLabelStride          = 2
  res@lbBoxLinesOn           = False

; SET UP COLOR BAR
  res@tiMainFontHeightF      = 0.015
  res@lbTitleString          = "PM2.5 SURFACE MASS CONCENTRATION (~F33~m~F0~g/m~S~3~N~)"
  res@lbTitleFontHeightF     = 0.01
  res@lbTitlePosition        = "Bottom"

; SET UP VIEW PLOT
  res@vpWidthF               = 0.4
  res@vpHeightF              = 0.25
  res@vpXF                   = 0.3
  res@vpYF                   = 0.7
  res@gsnDraw                = False
  res@gsnFrame               = False

   times      = a->Times(0,:)
   pm25       = a->PM2_5_DRY(0,:,:,:)
   pm25@lat2d = a->XLAT(0,:,:)
   pm25@lon2d = a->XLONG(0,:,:)
   pm25@units = " "
   res@tiMainString = "WRF/CHEM " + times
   print("WORKING ON : " + ndtooned(times))

   z  = wrf_user_getvar(a, "z",0)        ; grid point height
   z  = z/10.
   z@lat2d = a->XLAT(0,:,:)
   z@lon2d = a->XLONG(0,:,:)

   u       = wrf_user_getvar(a, "ua", 0)
   v       = wrf_user_getvar(a, "va", 0)
   u@lat2d = a->XLAT(0,:,:)
   u@lon2d = a->XLONG(0,:,:)
   v@lat2d = a->XLAT(0,:,:)
   v@lon2d = a->XLONG(0,:,:)

   pa      = a->P(0,:,:,:)
   pb      = a->PB(0,:,:,:)
   p       = pa+pb
   p@lat2d = a->XLAT(0,:,:)
   p@lon2d = a->XLONG(0,:,:)
   z_plane = gsn_csm_user_intrp3d( z,p,"h",pressure,0.,False)

;  SET UP Z RESOURCES
   resz                                = True
   resz@cnLevelSelectionMode           = "ManualLevels"
   resz@cnMinLevelValF                 = 290.
   resz@cnMaxLevelValF                 = 320.
   resz@cnLevelSpacingF                = 2.
   resz@cnLabelDrawOrder               = "PostDraw"
   resz@cnLineColor                    = "Red"
   resz@cnInfoLabelOn                  = False
   resz@gsnContourLineThicknessesScale = 2.5
   resz@cnLineLabelInterval            = 1
   resz@cnLineLabelsOn                 = True
   resz@cnLineLabelFontColor           = "Red"
   resz@cnLineLabelPlacementMode       = "Constant"
; SET UP THE FEATRUED TITLE
   resz@gsnLeftString                  = "Height ~C~ ~C~"
   resz@gsnRightString                 = "10m ~C~ ~C~"
   resz@gsnStringFontHeightF           = 0.01
   resz@gsnRightStringOrthogonalPosF   = 0.01
   resz@gsnLeftStringOrthogonalPosF    = 0.01
   resz@vpWidthF                       = 0.4
   resz@vpHeightF                      = 0.25
   resz@vpXF                           = 0.3
   resz@vpYF                           = 0.7
   resz@gsnDraw                        = False
   resz@gsnFrame                       = False

;  SET UP VECTOR RESOURCES
   resvc                               = True
   resvc@vcRefAnnoString2              = " "
   resvc@vcRefMagnitudeF               = 10.0
   resvc@vcRefLengthF                  = 0.05
   resvc@vcRefAnnoOrthogonalPosF       =-1.282
   resvc@vcRefAnnoArrowLineColor       = "black"
   resvc@vcRefAnnoArrowUseVecColor     = False
   resvc@vcGlyphStyle                  = "CurlyVector"
   resvc@vcLineArrowColor              = "Black"
   resvc@vcLineArrowThicknessF         = 2.0
   resvc@vcVectorDrawOrder             = "PostDraw"
   resvc@vcMinDistanceF                = 0.03
; SET UP THE FEATRUED TITLE
   resvc@gsnLeftString                 = "Wind"
   resvc@gsnRightString                = "m/s"
   resvc@gsnStringFontHeightF          = 0.01
   resvc@gsnRightStringOrthogonalPosF  = 0.01
   resvc@gsnLeftStringOrthogonalPosF   = 0.01
   resvc@vpWidthF                      = 0.4
   resvc@vpHeightF                     = 0.25
   resvc@vpXF                          = 0.3
   resvc@vpYF                          = 0.7
   resvc@gsnDraw                       = False
   resvc@gsnFrame                      = False

  vcid = gsn_csm_vector(wks, u(0,:,:), v(0,:,:), resvc)
  zid  = gsn_csm_contour(wks, z_plane, resz)
  pmid = gsn_csm_contour(wks, pm25(0,:,:), res)
  overlay(map, vcid)
  overlay(map, pmid)
  overlay(map, zid)
  draw(map)
  frame(wks)
  delete(res)
  delete(resz)
  delete(resvc)
  delete(wks)
 end do ; END OF IW LOOP
end
