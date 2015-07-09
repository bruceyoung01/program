; PURPOSE OF THIS PROGRAM :
; READ THE REANALYSIS DATA OF EACH EPA SITE FROM JW
; PLOT THE EPA SITE ONTO THE WRFCHEM SIMULATION MAP

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm_epa.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/pro_fun.ncl"

begin

;--------------------------------------------WRF/CHEM---------------------------------------------------------------------
; READ WRF/CHEM OUTPUT FILE LIST
  fdirw      = "/media/disk/data/wrfchem/2003_ca_60_36/"
  fnamelistw = "2003_ca_60_36_0420_29"
  fnamew     = asciiread(fdirw+fnamelistw, -1, "string")
  nfnamew    = dimsizes(fnamew)
; THE DATE USED TO PLOT
  date = 20 ; USER SPECIFY
; THE NUMBER OF DAYS OF THE MONTH
  nday = 30 ; USER SPECIFY
; SUT UP GRID NUMBER
;  ai   = 27 ; BOTTOM-UP GRID (LEVEL)
;  aj   = 89 ; SOUTH-NORTH GRID (LATITUDE)
;  ak   = 99 ; WEST-EAST GRID (LONGITUDE)
;  z    = new((/1,ai,aj,ak/), float, -999)
; OPEN A WORKSTATION AND CHOOSE COLORMAP
  type = "x11"
; type = "pdf"
; type = "ps"
; type = "ncgm"
; type = "png"
  wks  = gsn_open_wks(type,"1plt_wrf_contour_pm25_i_2003-04-20_29_zhang")
  gsn_define_colormap(wks,"BlAqGrYeOrReVi200")

;-----------------------EPA SITES------------------------------------
; READ EPA DATA
  fdir      = "/home/bruce/program/idl/smoke/2003_jw/2003_processed/"
  fnamelist = "filelist4_tx"
  fname     = asciiread(fdir+fnamelist,-1,"string")
  nfname    = dimsizes(fname)
  ncolumn   = 31
  nhours    = 24
; THE NUMBER OF COLUMNS OF THE LINE OF LATITUDE AND LONGITUDE
  nll       = 8
  ll        = new((/nll, nfname/),float,999)
  epa       = new((/nday, ncolumn, nfname/),float,999)
  do i = 0, nfname-1
   lldata   = readAsciiTable(fdir+fname(i), 1, "string", (/1,nday+2/))
   fdata    = readAsciiTable(fdir+fname(i), 1, "string", (/4,0/))
   do k = 0, nll-1
    ll(k,i) = stringtofloat(str_get_field(lldata, k, " "))
   end do
   do j = 0, ncolumn-1
    epa(:,j,i) = stringtofloat(str_get_field(fdata, j+1, " "))
   end do
   delete(fdata)
  end do

;-----------------------WRFCHEM-------------------------------------
; The specific pressure levels that we want the data interpolated to.
  pressure = 700   ; pressure levels to plot   USER SPECIFY

  do it = 0, nfnamew-1, 1
; SET UP THE DESIRED MODS FOR THE MAP AND PLOT
  res             = True

; SET UP MAP PROJECTION AND LIMITED REGION
  res@mpProjection      = "CylindricalEquidistant"
  res@mpCenterRotF      = 0.0
  res@mpGridAndLimbOn   = True
  res@mpGridLatSpacingF = 5.0
  res@mpGridLonSpacingF = 5.0
  res@mpLimitMode       = "latlon"
  res@mpMinLatF         = 10.0
  res@mpMaxLatF         = 45.0
  res@mpMinLonF         = -115.0
  res@mpMaxLonF         = -65.0

; COLOR OF CONTINIENTAL OUTLINES
  res@mpOutlineOn                 = True
  res@mpGeophysicalLineColor      = "White"
  res@mpNationalLineColor         = "White"
  res@mpUSStateLineColor          = "White"
  res@mpGridLineColor             = "White"
  res@mpLimbLineColor             = "White"
  res@mpPerimLineColor            = "White"
  res@mpGeophysicalLineThicknessF = 2.0
  res@mpGridLineThicknessF        = 1.5
  res@mpLimbLineThicknessF        = 2.0
  res@mpNationalLineThicknessF    = 2.0
  res@mpUSStateLineThicknessF     = 2.0
  res@mpGridLineDashPattern       = 2
  res@mpOutlineBoundarySets       = "GeophysicalAndUSStates"

; TURN ON MAP TICKNARKS
  res@pmTickMarkDisplayMode       = "always"

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
  res@cnMaxLevelValF         = 20.0
  res@cnLevelSpacingF        = 1.0

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

   a          = addfile(fdirw+fnamew(it), "r")
   times      = a->Times(0,:)
   pm25       = a->PM2_5_DRY(0,:,:,:)
   pm25@lat2d = a->XLAT(0,:,:)
   pm25@lon2d = a->XLONG(0,:,:)
   res@tiMainString = "WRF/CHEM  ZHANG    " + times
   print(times)
   printVarSummary(pm25)

   z = wrf_user_getvar(a, "z",0)        ; grid point height
   z  = z/10.
   z@lat2d = a->XLAT
   z@lon2d = a->XLONG
   printVarSummary(z)

   pa        = a->P(0,:,:,:)
   pb        = a->PB(0,:,:,:)
   p          = pa+pb
   p@lat2d = a->XLAT(0,:,:)
   p@lon2d = a->XLONG(0,:,:)
   printVarSummary(p)

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
   res2@gsnContourLineThicknessesScale = 1.5
   res2@cnLineLabelInterval            = 2
   res2@cnLineLabelsOn                 = True ; turn on line labels


; PLOT EPA SITES ONTO WRFCHEM PLOT

  do i = 0, nfname-1
        nlevel   = (res@cnMaxLevelValF-res@cnMinLevelValF)/res@cnLevelSpacingF+2
        inlevel  = toint(nlevel)
        interval = toint((res@gsnSpreadColorEnd - res@gsnSpreadColorStart)/nlevel)
        colors   = ispan(2,201,interval)
        tpmcolor = toint(((epa(date-1,it+1,i)-min(epa(date-1,it+1,:)))/\
                 ((max(epa(date-1,it+1,:)))-min(epa(date-1,it+1,:))))*\
                 (res@gsnSpreadColorEnd - res@gsnSpreadColorStart))
        do j=0,nlevel-1
        if(ismissing(tpmcolor))then
         pmcolor=0
        end if
        if(.not.ismissing(tpmcolor).and.tpmcolor.eq.colors(j))then
         pmcolor=colors(j)
        end if
        if(.not.ismissing(tpmcolor).and.j.gt.0.and.tpmcolor.gt.colors(j).and.tpmcolor.lt.colors(j+1))then
         pmcolor=colors(j)
        end if
        if(.not.ismissing(tpmcolor).and.tpmcolor.eq.colors(inlevel-1))then
         pmcolor=colors(inlevel-1)
        end if
        end do
        add_markers(wks,map,ll(6,i),ll(5,i),"Black",14,0.012,2.5)
        add_markers(wks,map,ll(6,i),ll(5,i),pmcolor,16,0.01,1.0)
  end do ; END OF I LOOP

  printVarSummary(pm25)
  printVarSummary(z_plane)
  ;map = gsn_csm_contour_map_overlay(wks,pm25(0,:,:),z_plane,map,res,res2)
  delete(res)
  delete(res2)
 end do ; END OF IT LOOP
 delete(epa)
end
