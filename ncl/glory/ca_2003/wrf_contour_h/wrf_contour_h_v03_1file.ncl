; $ID: wrf_contour_h_v02_1file.ncl V02 10/21/2011 11:52:00 BRUCE EXP $
; 
;******************************************************************************
;  PROGRAM WRF_CONTOUR_H_V02_1FILE IS USED TO PLOT THE VERTICAL PROFILE 
;  USING ONE TIME STEP WRF OUTPUT FILE. IT IS A CROSS SESSION FROM A TO B.
;
;  VARIABLES:
;  ============================================================================
;  
;  ============================================================================
;  NOTES:
;  (1 ) WRITE THE ORIGINAL PROGRAM (BRUCE 10/21/2011)
;  (2 ) ADD THE STATEMENT HOW TO ADD X AXIS LABELS USING LATITUDE AND LONGITUDE
;       (BRUCE 10/25/2011)
;
;******************************************************************************
; LAOD LIBRARIES USED IN THIS PROGRAM
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW_epa.ncl"
load "/home/bruce/program/ncl/tutorial/test/wrf_contour_h/WRFUserARW.ncl"
load "/home/bruce/program/ncl/tutorial/test/wrf_contour_h/intrp_v01.ncl"

begin

; SPECIFY THE FILE DIRECTORY AND FILE NAME
  dir      = "/home/bruce/sshfs/pfw/model/wrfchem2/WRFV3/test/em_real/wrfout/wrfout_900/"
  filename = "wrfout_d01_2003-04-03_21:00:00.nc"
  a        = addfile( dir + filename, "r")

; DEFINE THE FORMAT OF THE PLOT AND WORK STATION
  type     = "x11"
; type     = "pdf"
  output   = "1plt_contour_h_v02_1file_2003-04-03_21_l"
  wks      = gsn_open_wks(type, output)

; SET THE BASIC RESOURCES
  pltres   = True

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  times    = a->Times(0,:)
  mdims    = getfilevardimsizes(a,"P")
  nd       = dimsizes(mdims)
  print("Working on time: " + times )

;---------------------------------------------------------------
; READ VARIABLES FROM NC FILE
  pm25     = a->PM2_5_DRY(0,:,:,:)
  wlat     = a->XLAT(0,:,:)
  wlon     = a->XLONG(0,:,:)
  pm25@lat2d = wlat
  pm25@lon2d = wlon
  pm25@units = "~F33~m~F0~g/m~S~3~N~"
  z        = wrf_user_getvar(a, "z",0)
  z@lat2d  = a->XLAT(0,:,:)
  z@lon2d  = a->XLONG(0,:,:)

; GET HEIGHT INFO FOR LABELS
  level    = 15
  FirstTime= True
  if ( FirstTime ) then
    zmin = 0.
    zmax = max(z(0:level,:,:))/1000.
    nz   = floattoint(zmax/2 + 1)
    FirstTime = False
  end if

;---------------------------------------------------------------
; PLOT A CROSS SESSION THAT RUN FROM POINT A TO POINT B
; THE COORDINATE OF A IS (XA, YA), THE COORDINATE OF B IS (XB, YB)
; THE FORMAT OF PALNE (AS SHOWN BELOW) IS (XA, YA, XB, YB)
  plane      = new(4,float)
  xa         = 0
  ya         = 25
  xb         = 98
  yb         = 25
  plane      = (/ xa,ya,xb,yb /)
  opts       = True
; FIND THE DATA SPAN, FOR USE IN LABELS
  pm25_plane = intrp3d(pm25(0:level,:,:),z(0:level,:,:),"v",plane,0.,opts)
  dim        = dimsizes(pm25_plane)
  zspan      = dim(0)
  xspan      = xb-xa
  yspan      = yb-ya
  nx         = 6
  ny         = 6
  xstride    = xspan/nx+1
  ystride    = yspan/ny+1
  if (xspan .gt. yspan) then
   span   = xspan
   stride = xstride
   n      = nx
  else
   span   = yspan
   stride = ystride
   n      = ny
  end if

; OPTIONS FOR XY PLOTS
  opts_xy                         = pltres
  opts_xy@tiYAxisString           = "Height (km)"
  opts_xy@cnMissingValPerimOn     = True
  opts_xy@cnMissingValFillColor   = 0
  opts_xy@cnMissingValFillPattern = 11
  opts_xy@tmXBMode                = "Explicit"
  opts_xy@tmXBValues              = ispan(0,span,stride)
  opts_xy@tmXBLabels              = sprintf("%5.2f",ndtooned(wlat(ya:yb:ystride,xa:xb:xstride))) + "~C~" +\
                                    sprintf("%5.2f",ndtooned(wlon(ya:yb:ystride,xa:xb:xstride)))
  opts_xy@tmYLMode                = "Explicit"
  opts_xy@tmYLValues              = fspan(0,zspan,nz)
  opts_xy@tmYLLabels              = sprintf("%.1f",fspan(zmin,zmax,nz))
  opts_xy@tiXAxisFontHeightF      = 0.02
  opts_xy@tiYAxisFontHeightF      = 0.02
  opts_xy@tmXBMajorLengthF        = 0.02
  opts_xy@tmYLMajorLengthF        = 0.02
  opts_xy@tmYLLabelFontHeightF    = 0.02
  opts_xy@vpHeightF               = 0.4
  opts_xy@vpWidthF                = 0.7

; PLOTING OPTIONS FOR PM2.5
  opts_pm25  = opts_xy
  pm25min    = 1.0
  pm25max    = 10.0
  pm25stride = 1.
  opts_pm25@ContourParameters        = (/ pm25min, pm25max, pm25stride /)
  opts_pm25@pmLabelBarOrthogonalPosF = -0.07
  opts_pm25@cnFillOn                 = True

; GET THE CONTOUR INFO FOR THE TC AND PM2.5
  contour_pm25 = wrf_contour(a,wks,pm25_plane,opts_pm25)

; MAKE PLOTS         
  plot = wrf_overlays(a,wks,(/contour_pm25/),pltres)

end

