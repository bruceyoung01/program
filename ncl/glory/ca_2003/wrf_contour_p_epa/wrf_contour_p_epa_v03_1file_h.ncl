; $ID wrf_contour_p_epa_v03_1file.ncl V01 11/15/2011 09:35 BRUCE EXP$
;
;******************************************************************************
; PURPOSE OF THIS PROGRAM :
; PLOT THE WRFCHEM SIMULATION LEVEL DATA WITH HEIGHT CONTOUR (700mb)
; =============================================================================
; NOTES:
; (1 ): ORIGINALLY WRITTEN BY RBUCE. (N/A)
; (2 ): MODIFIED BY BRUCE. (11/15/2011)
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
; type = "ps"
; type = "ncgm"
; type = "png"
  wks  = gsn_open_wks(type,"1plt_wrf_contour_pm25_i_" + \
                      syear+"-"+smonth+"-"+sdate+"_"+shour+"_v03")
  gsn_define_colormap(wks,"BlAqGrYeOrReVi200")

;-----------------------WRFCHEM-------------------------------------
; THE SPECIFIC PRESSURE LEVELS THAT WE WANT THE DATA INTERPOLATED TO
  pressure = 700

; SET UP THE DESIRED MODS FOR THE MAP AND PLOT
  res      = True

; SET UP MAP PROJECTION AND LIMITED REGION
  res@mpProjection      = "CylindricalEquidistant"
  res@mpCenterRotF      = 0.0
  res@mpGridAndLimbOn   = True
  res@mpGridLatSpacingF = 5.0
  res@mpGridLonSpacingF = 5.0
  res@mpLimitMode       = "latlon"
  res@mpMinLatF         = -15.0
  res@mpMaxLatF         =  35.0
  res@mpMinLonF         = -25.0
  res@mpMaxLonF         =  45.0

; COLOR OF CONTINIENTAL OUTLINES
  res@mpOutlineOn                 = True
  res@mpGeophysicalLineColor      = "White"
  res@mpNationalLineColor         = "White"
  res@mpUSStateLineColor          = "White"
  res@mpGridLineColor             = "White"
  res@mpLimbLineColor             = "White"
  res@mpPerimLineColor            = "White"
  res@mpGeophysicalLineThicknessF = 3.0
  res@mpGridLineThicknessF        = 1.5
  res@mpLimbLineThicknessF        = 2.0
  res@mpNationalLineThicknessF    = 3.0
  res@mpUSStateLineThicknessF     = 2.0
  res@mpGridLineDashPattern       = 2
  res@mpOutlineBoundarySets       = "GeophysicalAndUSStates"

; TURN ON MAP TICKNARKS
  res@pmTickMarkDisplayMode       = "always"
  res@mpFillDrawOrder             = "PreDraw"
  map  = gsn_csm_map(wks,res)

; MAXIMIZE PLOT IN FRAME
  res@gsnMaximize = True
; THE DATA IS NOT GLOBAL
  res@gsnAddCyclic= False
; SET UP THE FEATRUED TITLE
  res@gsnLeftString                = "PM2.5 SURFACE MASS CONCENTRATION"
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
  res@cnInfoLabelOn          = True
  res@cnInfoLabelFontHeightF = 0.01

  res@cnLevelSelectionMode   = "ManualLevels"
  res@cnMinLevelValF         = 0.0
  res@cnMaxLevelValF         = 40.0
  res@cnLevelSpacingF        = 2.0

; SET UP LABEL BAR
  res@pmLabelBarWidthF       = 0.6
  res@pmLabelBarHeightF      = 0.08
  res@lbLabelFontHeightF     = 0.013
  res@lbLabelStride          = 2
  res@lbBoxLinesOn           = False

; SET UP COLOR BAR
  res@tiMainFontHeightF      = 0.02
  res@lbTitleString          = "PM2.5 SURFACE MASS CONCENTRATION (~F33~m~F0~g/m~S~3~N~)"
  res@lbTitleFontHeightF     = 0.015
  res@lbTitlePosition        = "Bottom"

   times      = a->Times(0,:)
   pm25       = a->PM2_5_DRY(0,:,:,:)
   pm25@lat2d = a->XLAT(0,:,:)
   pm25@lon2d = a->XLONG(0,:,:)
   res@tiMainString = "WRF/CHEM " + times
   print("WORKING ON : " + ndtooned(times))

   z  = wrf_user_getvar(a, "z",0)        ; grid point height
   z  = z/10.
   z@lat2d = a->XLAT(0,:,:)
   z@lon2d = a->XLONG(0,:,:)


   pa      = a->P(0,:,:,:)
   pb      = a->PB(0,:,:,:)
   p       = pa+pb
   p@lat2d = a->XLAT(0,:,:)
   p@lon2d = a->XLONG(0,:,:)

   z_plane  = gsn_csm_user_intrp3d( z,p,"h",pressure,0.,False)

;  SET UP Z RESOURCES
   res2                                = True
   res2@cnLevelSelectionMode           = "ManualLevels"
   res2@cnMinLevelValF                 = 290.
   res2@cnMaxLevelValF                 = 320.
   res2@cnLevelSpacingF                = 2.
   res2@cnLabelDrawOrder               = "PostDraw"
   res2@cnLineColor                    = "Red"
   res2@cnInfoLabelOn                  = False
   res2@gsnContourLineThicknessesScale = 2.5
   res2@cnLineLabelInterval            = 2
   res2@cnLineLabelsOn                 = True

  map = gsn_csm_contour_map_overlay(wks,pm25(0,:,:),z_plane,map,res,res2)
  delete(res)
  delete(res2)
  delete(wks)
 end do ; END OF IW LOOP
end
