;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PURPOSE OF THIS PROGRAM : READ AOD FROM CALIPSO DATA FILE           ;
; CAL_LID_L2_05kmALay-Prov-V3-01                                      ;
; AND PLOT THE AOD AND MONTHLY AVERAGE AOD                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin

; READ CALIPSO DATA CAL_LID_L2_05kmALay-Prov-V3-01
  cdir      = "/media/disk/data/calipso/seas/2006/CAL_LID_L2_05kmALay-Prov-V3-01/"
  cnamelist = "CAL_LID_L2_05kmALay-Prov-V3-01" ; USER SPECIFY
  cname     = asciiread(cdir+cnamelist,-1,"string")
  nfname    = dimsizes(cname)
  print(cname)

  do i = 0, nfname-1
   cdata = addfile(cdir+cname(i), "r")
   clat  = cdata->Latitude
   clon  = cdata->Longitude
   caod  = cdata->Column_Optical_Depth_Aerosols_532
   caod@lat2d = clat
   caod@lon2d = clon
; SELECT THE CALIPSO DATA WHICH ARE IN THE FIRE REGION (20N~10S, 95E~125E)
   maxlat=  20.0
   minlat= -10.0
   maxlon= 125.0
   minlon=  95.0
   ndim  = dimsizes(clat)
   nclat = new((/ndim(0)/), float, -9999)
   nclon = new((/ndim(0)/), float, -9999)
   ncaod = new((/ndim(0)/), float, -9999)
   nclat = clat(:,0)
   nclon = clon(:,0)
   ncaod = caod(:,0)
   index = ind(nclat .gt. minlat .and. nclat .lt. maxlat .and. \
               nclon .gt. minlon .and. nclon .lt. maxlon)
   nnclat = nclat(index)
   nnclon = nclon(index)
   nncaod = ncaod(index)
   nndim  = dimsizes(nnclat)
; CALCULATE THE DISTANCE BETWEEN THE FIRST POINT AND OTHER POINT
   dis    = new((/nndim/),float, -9999)
   do j = 0, nndim-1
    dis(j) = gc_latlon(nnclat(0), nnclon(0),nnclat(j), nnclon(j), 2, -3)
   end do ; END OF J LOOP

; SET UP THE PLOT PLATFORM
   type = "x11"
;  type = "pdf"
;  type = "ps"
;  type = "ncgm"
;  type = "png"
   wks  = gsn_open_wks(type, "1plt_calipso_aod_h_2006-10-01_v01")
   gsn_define_colormap(wks,"BlAqGrYeOrReVi200")

   res = True
; SET UP MAP PROJECTION AND LIMITED REGION
   res@mpProjection      = "CylindricalEquidistant"
   res@mpCenterRotF      = 0.0
   res@mpGridAndLimbOn   = True
   res@mpGridLatSpacingF = 5.0
   res@mpGridLonSpacingF = 5.0
   res@mpLimitMode       = "latlon"
   res@mpMinLatF         = -10.0
   res@mpMaxLatF         =  20.0
   res@mpMinLonF         = 105.0
   res@mpMaxLonF         = 115.0

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
   res@mpOutlineBoundarySets       = "GeophysicalAndUSStates"

; TURN ON MAP TICKNARKS
   res@pmTickMarkDisplayMode       = "always"
; MAXIMIZE PLOT IN FRAME
   res@gsnMaximize = True
; THE DATA IS NOT GLOBAL
   res@gsnAddCyclic= False
; SET UP THE MAIN TITLE
   res@tiMainString                 = "Aerosol Optical Depth (532nm)"

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
   res@cnMaxLevelValF         = 1.0
   res@cnLevelSpacingF        = 0.1

; SET UP LABEL BAR
   res@pmLabelBarWidthF       = 0.6
   res@pmLabelBarHeightF      = 0.08
   res@lbLabelFontHeightF     = 0.013
   res@lbLabelStride          = 2
   res@lbBoxLinesOn           = False
; SET UP COLOR BAR
   res@tiMainFontHeightF      = 0.02
   res@lbTitleString          = "Aerosol Optical Depth (532nm)"
   res@lbTitleFontHeightF     = 0.015
   res@lbTitlePosition        = "Bottom"
; SET UP sfXArray AND sfYArray
   res@sfXArray = nnclon
   res@sfYArray = nnclat
   map = gsn_csm_contour_map(wks,nncaod,res)

   delete(clat)
   delete(clon)
   delete(caod)
   delete(nclat)
   delete(nclon)
   delete(ncaod)
   delete(nnclat)
   delete(nnclon)
   delete(nncaod)
   delete(index)
   delete(dis)
   delete(res)
  end do ; END OF I LOOP

end
