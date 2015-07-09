;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PURPOSE OF THIS PROGRAM : READ AOD FROM CALIPSO DATA FILE           ;
; CAL_LID_L2_05kmALay-Prov-V3-01                                      ;
; AND PLOT THE AOD AND MONTHLY AOD FREQUENCY                          ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin

; SET UP THE PLOT PLATFORM
   type = "x11"
;  type = "pdf"
;  type = "ps"
;  type = "ncgm"
;  type = "png"
   wks  = gsn_open_wks(type, "1plt_calipso_ec_h_2006_10_v01_daytime")
   gsn_define_colormap(wks,"BlAqGrYeOrReVi200")

; READ CALIPSO DATA CAL_LID_L2_05kmALay-Prov-V3-01
  cdir      = "/media/disk/data/calipso/seas/2006/CAL_LID_L2_05kmAPro-Prov-V3-01/"
  cnamelist = "CAL_LID_L2_05kmAPro-Prov-V3-01_10D" ; USER SPECIFY
  cname     = asciiread(cdir+cnamelist,-1,"string")
  nfname    = dimsizes(cname)

; SET UP RESOURCES
  cres                 = True
  cres@cnFillOn        = True
; TURN OFF CONTOUR LINES
  cres@cnLinesOn       = False
; TURN OFF CONTOUR LABELS
  cres@cnLineLabelsOn  = False
  cres@gsnSpreadColors = True
  cres@cnLevelSelectionMode = "ManualLevels"
  cres@cnMinLevelValF       = 0.0
  cres@cnMaxLevelValF       = 2.0
  cres@cnLevelSpacingF      = 0.2

  do i = 0, nfname-1
   cdata = addfile(cdir+cname(i), "r")
   clat  = cdata->Latitude
   clon  = cdata->Longitude
   cec   = cdata->Extinction_Coefficient_532
   time  = str_get_cols(cname(i), 31, 40) + " " + str_get_cols(cname(i), 42, 49)

; SELECT THE CALIPSO DATA WHICH ARE IN THE FIRE REGION (20N~10S, 95E~125E)
   maxlat=  20.0
   minlat= -10.0
   maxlon= 125.0
   minlon=  95.0
   ndim  = dimsizes(cec)
   nclat = new((/ndim(0)/), float, -9999)
   nclon = new((/ndim(0)/), float, -9999)
   ncec  = new((/ndim(0), ndim(1)/), float, -9999)
   nclat = clat(:,1)
   nclon = clon(:,1)
   ncec  = cec(:,:)
   index = ind(nclat .gt. minlat .and. nclat .lt. maxlat .and. \
               nclon .gt. minlon .and. nclon .lt. maxlon)
   nnclat = nclat(index)
   nnclon = nclon(index)
   nncec  = ncec(index, :)
   nndim  = dimsizes(nnclat)

; REVERSE EC ARRARY
   rnncec = new((/ndim(1), nndim/), float, -9999)
   do j = 0, ndim(1)-1
    do k = 0, nndim-1
     if( .not.ismissing(nncec(k,j)).and.nncec(k,j) .gt. -1.0 .and. nncec(k,j) .lt. 0.0)then
      nncec(k,j) = 0.0
     end if
     rnncec(j, k) = nncec(k, j)
    end do
   end do
; SET UP AXIS LABEL FOR CONTOUR PLOT
   cres@tmXBMode        = "Explicit"
   xnpts                = 5
   cres@tmXBValues      = fspan(0.,(nndim-1),xnpts+1)
   stride               = floattoint(nndim/xnpts)-1
   cres@tmXBLabels      = sprintf("%5.2f", nnclat(0:(nndim-1):stride)) + "/" + \
                          sprintf("%5.2f", nnclon(0:(nndim-1):stride))
   cres@tiXAxisString   = "Latitude/Longitude"
   cres@tiYAxisString   = "Altitude (km)"
   cres@tiMainString    = "CALISPO     Daytime " + time
   maxh                 = 20
   minh                 = -0.5
   ynpts                = 341
   cres@sfYArray        = fspan(maxh, minh, ynpts)

; SET UP LABEL BAR
   cres@pmLabelBarWidthF       = 0.05
   cres@pmLabelBarHeightF      = 0.3
   cres@lbLabelFontHeightF     = 0.01
   cres@lbLabelStride          = 1
   cres@lbBoxLinesOn           = False
   cres@lbOrientation          = "Vertical"
   cres@lbLabelPosition        = "Right"
; SET UP THE POSITION OF THE CONTOUR PLOT
   cres@vpWidthF               = 0.7
   cres@vpHeightF              = 0.3
   cres@vpXF                   = 0.15
   cres@vpYF                   = 0.7

; DESCRIPTION OF EXTINCTION COEFFICIENT
   rnncec@units = "km~S~-1"
   rnncec@description = "Extinction Coefficient 532nm"
   plot = gsn_csm_contour(wks, rnncec(59:398,:), cres)
   delete(clon)
   delete(cec)
   delete(nclat)
   delete(nclon)
   delete(ncec)
   delete(nnclat)
   delete(nnclon)
   delete(nncec)
   delete(rnncec)
   delete(index)
  end do ; END OF I LOOP
end
