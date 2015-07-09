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

; SET UP THE PLOT PLATFORM
   type = "x11"
;  type = "pdf"
;  type = "ps"
;  type = "ncgm"
;  type = "png"
   wks  = gsn_open_wks(type, "1plt_calipso_aod_2006_10_v01_nightime")
   gsn_define_colormap(wks,"BlAqGrYeOrReVi200")

; READ CALIPSO DATA CAL_LID_L2_05kmALay-Prov-V3-01
  cdir      = "/media/disk/data/calipso/seas/2006/CAL_LID_L2_05kmALay-Prov-V3-01/"
  cnamelist = "CAL_LID_L2_05kmALay-Prov-V3-01_10N" ; USER SPECIFY
  cname     = asciiread(cdir+cnamelist,-1,"string")
  nfname    = dimsizes(cname)

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

   res = True
; SET UP AXIS LABEL FOR CONTOUR PLOT
   npts                = 5
   stride              = floattoint(nndim/npts)-1
   time                = str_get_cols(cname(i), 31, 40) + " " + str_get_cols(cname(i), 42, 49)
   res@tmXBMode        = "Explicit"
   res@tmXBValues      = fspan(0.,max(dis),npts+1)
   res@tmXBLabels      = sprintf("%5.2f", nnclat(0:(nndim-1):stride)) + "/" + \
                         sprintf("%5.2f", nnclon(0:(nndim-1):stride))
   res@tiXAxisString   = "Latitude/Longitude"
   res@tiYAxisString   = "Aerosol Optical Depth (532nm)"
   res@tiMainString    = "CALISPO    AOD  Nightime" + time
   res@xyLineColor     = "red"

; SET UP Y AXIS RANGE
   res@trYMaxF         = 3.5
   res@trYMinF         = 0.0

; SET UP THE POSITION OF THE XY PLOT
   res@vpWidthF                = 0.75
   res@vpHeightF               = 0.3
   res@vpXF                    = 0.15
   res@vpYF                    = 0.7

   plot = gsn_csm_xy(wks, dis, nncaod, res)

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
