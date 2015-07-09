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
   wks  = gsn_open_wks(type, "1plt_calipso_aod_frequency_2006_10_v01_nightime")
   gsn_define_colormap(wks,"BlAqGrYeOrReVi200")

; READ CALIPSO DATA CAL_LID_L2_05kmALay-Prov-V3-01
  cdir      = "/media/disk/data/calipso/seas/2006/CAL_LID_L2_05kmALay-Prov-V3-01/"
  cnamelist = "CAL_LID_L2_05kmALay-Prov-V3-01_10N" ; USER SPECIFY
  cname     = asciiread(cdir+cnamelist,-1,"string")
  nfname    = dimsizes(cname)
; DEFINE MONTHLY DATA ARRAY
  mn        = 1000000
  mclat     = new((/mn/), float, -9999)
  mclon     = new((/mn/), float, -9999)
  mcaod     = new((/mn/), float, -9999)
  imn       = 0

; SET UP RESOURCES
   res = True
   res@tiXAxisString = "AOD (532nm)"
   res@tiYAxisString = "Frequency"
   res@xyLineColor   = "red"
   
; SET UP Y AXIS
   res@trYAxisType  = "LogAxis"
   res@trYMaxF      = 1
   res@tmXMajorGrid = True
   res@tmYMajorGrid = True
   res@tmYMinorGrid = True
   res@tmXMajorGridThicknessF      = 1.0
   res@tmYMajorGridThicknessF      = 1.0
   res@tmYMinorGridThicknessF      = 1.0
   res@tmXMajorGridLineDashPattern = 2
   res@tmYMajorGridLineDashPattern = 2
   res@tmYMinorGridLineDashPattern = 2

  do i = 0, nfname-1
   cdata = addfile(cdir+cname(i), "r")
   clat  = cdata->Latitude
   clon  = cdata->Longitude
   caod  = cdata->Column_Optical_Depth_Aerosols_532
   caod@lat2d = clat
   caod@lon2d = clon
   time       = str_get_cols(cname(i), 31, 40) + " " + str_get_cols(cname(i), 42, 49)

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

; DIVIDE THE AOD INTO DIFFERENT RANGE
   minaod  = 0.0
   maxaod  = 3.5
   npts    = 350
   daod    = fspan(minaod, maxaod, npts)
   nfre    = new((/npts-1/), integer, -9999)
   pfre    = new((/npts-1/), float, -9999)
   do j = 0, npts-2
    dindex = ind(nncaod .gt. daod(j) .and. nncaod .lt. daod(j+1))
    nfre(j)= dimsizes(dindex)
    delete(dindex)
   end do
   tfre    = int2flt(sum(nfre))
   pfre    = nfre/tfre

; CALCULATE THE AVERAGE AOD
   avgaod  = avg(nncaod)
; SET UP RESOURCES
   lres = True
   lres = res
   lres@trYMinF      = 10^-3 ;min(pfre)
   lres@tiMainString  = "CALISPO    AOD  Nightime " + time

; PLOT THE DAILY AOD-FREQUENCY IMAGE
; SET UP TEXT RESOURCES
   tres = True
   tres@txPerimOn     = True
   tres@txFontHeightF = 0.015
   tres@txBackgroundFillColor = 100
   tres@gsnframe      = True
   gsn_text_ndc(wks,"mean = "+sprintf("%7.5f", avgaod), 0.65, 0.7, tres)
   plot = gsn_csm_xy(wks, daod(0:npts-2), pfre(0:npts-2), lres)

; COLLECT EACH DAY AOD DATA
   mclat(imn:imn+nndim-1)  = nnclat
   mclon(imn:imn+nndim-1)  = nnclon
   mcaod(imn:imn+nndim-1)  = nncaod
   imn = imn + nndim
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
   delete(lres)
   delete(tres)
  end do ; END OF I LOOP

; DIVIDE THE MONTHLY AOD INTO DIFFERENT RANGE
   mminaod  = 0.0
   mmaxaod  = 3.5
   mnpts    = 350
   mdaod    = fspan(mminaod, mmaxaod, mnpts)
   mnfre    = new((/mnpts-1/), integer, -9999)
   mpfre    = new((/mnpts-1/), float, -9999)
   do j = 0, mnpts-2
    mdindex = ind(mcaod .gt. mdaod(j) .and. mcaod .lt. mdaod(j+1))
    mnfre(j)= dimsizes(mdindex)
    delete(mdindex)
   end do
   mtfre    = int2flt(sum(mnfre))
   mpfre    = mnfre/mtfre
   
; CALCULATE THE AVERAGE AOD
   mavgaod  = avg(mcaod)
; SET UP RESOURCES
   mtime= str_get_cols(cname(0), 31, 37)
   lres = True
   lres = res
   lres@trYMinF      = 10^-5 ;min(mpfre)
   lres@tiMainString  = "CALISPO    AOD  Nightime " + mtime

; PLOT THE DAILY AOD-FREQUENCY IMAGE
; SET UP TEXT RESOURCES
   tres = True
   tres@txPerimOn     = True
   tres@txFontHeightF = 0.015
   tres@txBackgroundFillColor = 100
   tres@gsnframe      = True
   gsn_text_ndc(wks,"mean = "+sprintf("%7.5f", mavgaod), 0.65, 0.7, tres)
   plot = gsn_csm_xy(wks, mdaod(0:mnpts-2), mpfre(0:mnpts-2), lres)

end
