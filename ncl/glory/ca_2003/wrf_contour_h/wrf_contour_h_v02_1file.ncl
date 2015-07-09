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
;  (1) WRITE THE ORIGINAL PROGRAM (BRUCE 10/21/2011)
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


; Set some basic resources
  pltres   = True


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  times    = a->Times(0,:)             ; get time from the file
  mdims    = getfilevardimsizes(a,"P") ; get some dimension sizes for the file
  nd       = dimsizes(mdims)
print(mdims)

;---------------------------------------------------------------
  it       = 0
  print("Working on time: " + times )
  pm25     = a->PM2_5_DRY(0,:,:,:)
  wlat     = a->XLAT(0,:,:)
  wlong    = a->XLONG(0,:,:)
  pm25@lat2d = wlat
  pm25@lon2d = wlong
  pm25@units = "~F33~m~F0~g/m~S~3~N~"
  z        = wrf_user_getvar(a, "z",0)
  z@lat2d  = a->XLAT(0,:,:)
  z@lon2d  = a->XLONG(0,:,:)

; GET HEIGHT INFO FOR LABELS
  FirstTime= True
  if ( FirstTime ) then
    zmin = 0.
    zmax = max(z(0:15,:,:))/1000.
    nz   = floattoint(zmax/2 + 1)
    FirstTime = False
  end if

;---------------------------------------------------------------
; PLOT A CROSS SESSION THAT RUN FROM POINT A TO POINT B
; THE COORDINATE OF A IS (XA, YA), THE COORDINATE OF B IS (XB, YB)
; THE FORMAT OF PALNE (AS SHOWN BELOW) IS (XA, YA, XB, YB)
    plane      = new(4,float)
    plane      = (/ 0,25,99,25 /)
    opts       = True
; FIND THE DATA SPAN, FOR USE IN LABELS
    pm25_plane = intrp3d(pm25(0:15,:,:),z(0:15,:,:),"v",plane,0.,opts)
    dim        = dimsizes(pm25_plane)
    zspan      = dim(0)
    xspan      = mdims(2)
    nx         = 6
    stride     = xspan/nx+3

print(sprintf("%5.2f",(wlat(0:(mdims(2)-1):stride,0))))
print(sprintf("%5.2f",(wlong(0,0:(mdims(3)-1):stride+1))))
; OPTIONS FOR XY PLOTS
    opts_xy                         = pltres
    opts_xy@tiYAxisString           = "Height (km)"
    opts_xy@cnMissingValPerimOn     = True
    opts_xy@cnMissingValFillColor   = 0
    opts_xy@cnMissingValFillPattern = 11
    opts_xy@tmXBMode                = "Explicit"
    opts_xy@tmXBValues              = fspan(0,xspan,nx)
print(opts_xy@tmXBValues)
; LATITUDE, LONGITUDE AXISES WITH DIFFERENT VALUES
;    opts_xy@tmXBLabels              = sprintf("%5.2f",(wlat(0:(mdims(2)-1):stride,0:(mdims(3)-mdims(3)):stride+1))) + "~C~" +\
;                                      sprintf("%5.2f",(wlong(0:(mdims(2)-1):stride,0:(mdims(3)-mdims(3)):stride+1)))
; LATITUDE WITH THE SAME VALUES, LONGITUDE WITH DIFFERENT VALUES
    opts_xy@tmXBLabels              = sprintf("%5.2f",(wlat(25,0:(mdims(3)-1):stride+1))) + "~C~" +\
                                      sprintf("%5.2f",(wlong(25,0:(mdims(3)-1):stride+1)))
; LATITUDE WITH DIFFERENT VALUES, LONGITUDE WITH THE SAME VALUES
;    opts_xy@tmXBLabels              = sprintf("%5.2f",(wlat(0:(mdims(2)-1):stride,9))) + "~C~" +\
;                                      sprintf("%5.2f",(wlong(0:(mdims(2)-1):stride,9):stride+1)))
    opts_xy@tmYLMode                = "Explicit"
    opts_xy@tmYLValues              = fspan(0,zspan,nz)
    opts_xy@tmYLLabels              = sprintf("%.2f",fspan(zmin,zmax,nz))
    opts_xy@tiXAxisFontHeightF      = 0.02
    opts_xy@tiYAxisFontHeightF      = 0.02
    opts_xy@tmXBMajorLengthF        = 0.02
    opts_xy@tmYLMajorLengthF        = 0.02
    opts_xy@tmYLLabelFontHeightF    = 0.02

; PLOTING OPTIONS FOR PM2.5
    opts_pm25 = opts_xy
    opts_pm25@ContourParameters       = (/ 1., 10., 1. /)
    opts_pm25@pmLabelBarOrthogonalPosF = -0.07
    opts_pm25@cnFillOn                = True

; GET THE CONTOUR INFO FOR THE TC AND PM2.5
    contour_pm25 = wrf_contour(a,wks,pm25_plane,opts_pm25)

; MAKE PLOTS         
    plot = wrf_overlays(a,wks,(/contour_pm25/),pltres)

end

