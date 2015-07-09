;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PURPOSE OF THIS PROGRAM : READ AOD FROM CALIPSO DATA FILE           ;
; CAL_LID_L2_05kmALay-Prov-V3-01                                      ;
; AND PLOT THE AOD AND MONTHLY AOD FREQUENCY                          ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "/home/bruce/program/ncl/tutorial/test/wrf_contour_h/WRFUserARW.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/pro_fun.ncl"


begin

; SET UP THE PLOT PLATFORM
   type = "x11"
;  type = "pdf"
;  type = "ps"
;  type = "ncgm"
;  type = "png"
   wks  = gsn_open_wks(type, "1plt_calipso_ec_frequency_2006_10_v07_daytime_smoke_aodg1")
   gsn_define_colormap(wks,"BlAqGrYeOrReVi200")
   plot1= new(2, graphic)

; READ CALIPSO DATA CAL_LID_L2_05kmALay-Prov-V3-01
  cdir      = "/media/disk/data/calipso/seas/2006/CAL_LID_L2_05kmAPro-Prov-V3-01/"
  cnamelist = "CAL_LID_L2_05kmAPro-Prov-V3-01_10N_smoke" ; USER SPECIFY
  cname     = asciiread(cdir+cnamelist,-1,"string")
  ncname    = dimsizes(cname)

; READ WRFCHEM OUTPUT NC FILE
; THIS NEEDS TO HAVE A ".nc" APPENDED
  dirn      = "/media/disk/data/wrfchem/seas/2006_seas_800/"
  filelistn = "wrfout_d01_2006-10_800"
  namen     = asciiread(dirn+filelistn,-1,"string")
  nfnamen   = dimsizes(namen)
  daten     = new((/nfnamen/), string, "No_FillValue")
  timen     = new((/nfnamen/), string, "No_FillValue")

; READ OUT DATE AND TIME OF WRFCHEM INTO AN ARRARY
  do i = 0, nfnamen-1
   daten(i) = str_get_cols(namen(i), 11, 20)
   timen(i) = str_get_cols(namen(i), 22, 23)
  end do

; SET UP RESOURCES
   res = True
   res@tiYAxisString = "Z AGL (km)"
   res@tiXAxisString = "Frequency"
   
; SET UP Y AXIS
   res@trXAxisType  = "LogAxis"
   res@trXMaxF      = 1
   res@tmXMajorGrid = True
   res@tmYMajorGrid = True
   res@tmXMinorGrid = True
   res@tmXMajorGridThicknessF      = 1.0
   res@tmYMajorGridThicknessF      = 1.0
   res@tmXMinorGridThicknessF      = 1.0
   res@tmXMajorGridLineDashPattern = 2
   res@tmYMajorGridLineDashPattern = 2
   res@tmXMinorGridLineDashPattern = 2
   res@xyMarkLineMode              = "Markers"
   res@xyMarkerColor               = "White"

; HEIGHT OF EACH LAYER
   h        = 0.06
; DEFINE MONTHLY DATA ARRAY
   mn       = 1000
   n_layer  = 399
   mcaod    = new((/mn, n_layer/), float, -9999)
   mcaodt   = new((/mn/), float, -9999)
   imn      = 0
   nt       = 0
   tgrid    = 0
; DIVIDE THE AOD INTO DIFFERENT RANGE
   minaod   = 0.0
   maxaod   = 0.12
   aodstride= 0.01
   npts     = 13
   daod     = fspan(minaod, maxaod, npts)

; SPECIFY THE LAYER INDEX OF THE TOP LAYER
; IN THE TROPOSPHERIC REGION BETWEEN 20KM TO -0.5KM, THE AEROSOL PROFILE 
; PRODUCTS ARE REPORTED AT A RESOLUTION OF 60M VERTICALLY. CONSIDERING 
; THE ELEVATED HEIGHT OF AEROSOL, WHICH SHOULD BE LOWER THAN 20KM, WE 
; SELECT TOP LAYER AT 330, WHICH MEANS THE HEIGHT SHOULD BE 330*60 = 
; 19800M=19.8KM. WE SELECT 900M(15 LAYERS) AS ONE NEW LAYER.
   minheight   = 0.3
   maxheight   = 10.8
   n_old_layer = floattoint(maxheight/h)
   stride      = 5
   n_new_layer = n_old_layer/stride
   nheight     = fspan(minheight, maxheight, n_new_layer)
   ominheight  = -0.5
   omaxheight  = 10.8
   onheight    = fspan(ominheight, omaxheight, n_old_layer)
   tnheight    = new((/mn, n_old_layer/), float, -9999)
   tpm25n      = new((/mn, n_old_layer/), float, -9999)
   do i = 0, mn-1
    tnheight(i,:) = onheight
   end do ; END OF I LOOP
   pheight     = new((/npts, n_new_layer/), float, -9999)
   nfre        = new((/npts, n_new_layer/), integer, -9999)
   pfre        = new((/npts, n_new_layer/), float, -9999)
   aaod        = new((/npts, n_new_layer/), float, -9999)

; DEFINE DAYTIME OR NIGHTTIME FOR CALIPSO
  dornh = str_get_cols(cname(0), 51, 51)
  if(dornh .eq. "D")then
   dntime= " Daytime "
  else
   dntime= " Nighttime "
  end if
 
  do i = 0, ncname-1
   cdata = addfile(cdir+cname(i), "r")
   clat  = cdata->Latitude
   clon  = cdata->Longitude
   cec   = cdata->Extinction_Coefficient_532
   caodt = cdata->Column_Optical_Depth_Aerosols_532
   caod  = cec*h
   caod@lat2d = clat
   caod@lon2d = clon
   time       = str_get_cols(cname(i), 31, 40) + " " + str_get_cols(cname(i), 42, 49)
   dateh = str_get_cols(cname(i), 31, 40)
   timeh = str_get_cols(cname(i), 42, 43)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;START OF WRFCHEM;;;;;;;;;;;;;;;;;;
; WRFCHEM DATA LOOP
   index  = ind(dateh .eq. daten .and. timeh .eq.timen)
   fn     = addfile(dirn+namen(index), "r")
   print("WORKING ON TIME : " + dateh + "_" + timeh)
   pm25n       = getvar(fn, "PM2_5_DRY", 0)
   latn        = getvar(fn, "XLAT", 0)
   lonn        = getvar(fn, "XLONG", 0)
   zn          = getvar(fn, "z", 0)
   pm25n@lat2d = latn
   pm25n@lon2d = lonn
   dimpm25n    = dimsizes(pm25n)
   nleveln     = dimpm25n(0)
   nlatn       = dimpm25n(1)
   nlonn       = dimpm25n(2)
   pm25h       = new((/n_old_layer, nlatn,nlonn/),float,-9999)
   delete(index)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;START OF CALIPSO;;;;;;;;;;;;;;;;;;;;;;;;
; SELECT THE CALIPSO DATA WHICH ARE IN THE FIRE REGION (20N~10S, 95E~125E)
   maxlat =  20.0
   minlat = -10.0
   maxlon = 125.0
   minlon =  95.0
   ndim   = dimsizes(clat)
   nclat  = new((/ndim(0)/), float, -9999)
   nclon  = new((/ndim(0)/), float, -9999)
   ncaod  = new((/ndim(0), n_layer/), float, -599.94)
   ncaodt = new((/ndim(0)/), float, -9999)
   nclat  = clat(:,0)
   nclon  = clon(:,0)
   ncaod  = caod(:,:)
   ncaodt = caodt(:,0)
   index  = ind(nclat .gt. minlat .and. nclat .lt. maxlat .and. \
               nclon .gt. minlon .and. nclon .lt. maxlon)
   nnclat = nclat(index)
   nnclon = nclon(index)
   nncaod = ncaod(index,:)
   nncaodt= ncaodt(index)
   nndim  = dimsizes(nnclat)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;END OF CALIPSO;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; INTERPOLATE THE VARAIBLE TO THE VERTICAL PROFILE
   do ih = 0, n_old_layer-1
    pm25h(ih,:,:) = wrf_user_intrp3d(pm25n, zn, "h", onheight(ih)*1000, 0., False)
   end do
; DEFINE A NEW ARRAY FOR SELECTED VERTICAL VARAIBLE
   sn      = 150 ; # OF SELECTED GRIDS
   spm25h  = new((/n_old_layer, sn/),float,-9999)
   spm25h1 = new((/n_old_layer, sn/),float,-9999)
   aspm25h1= new((/n_old_layer, sn/),float,-9999)
   slatn   = new((/sn/),float,-9999)
   slonn   = new((/sn/),float,-9999)
   slonn1  = new((/sn/),float,-9999)
   aslonn1 = new((/sn/),float,-9999)

; SELECT WRFCHEM DATA BASED ON CALIPSO PATH
   in = 0
; DO LATITUDE AND LONGITUDE LOOP OF WRFCHEM
   do ilatn = nlatn-2, 0, 1
    do ilonn = nlonn-2, 0, 1
; DO LATITUDE AND LONGITUDE LOOP OF CALIPSO
     k = 0
     do ilath = 0, nndim(0)-1
      if (nnclat(ilath) .ge. latn(ilatn,ilonn) .and. \
          nnclat(ilath) .le. latn(ilatn+1,ilonn+1) .and. \
          nnclon(ilath) .ge. lonn(ilatn,ilonn) .and. \
          nnclon(ilath) .le. lonn(ilatn+1,ilonn+1) .and. \
          k .eq. 0)then
       spm25h(:,in)  = pm25h(:,ilatn,ilonn)
       spm25h1(:,in) = pm25h(:,ilatn,ilonn+1)
       aspm25h1(:,in)= (spm25h(:,in)+spm25h1(:,in))/2.
       slatn(in)     = latn(ilatn,ilonn)
       slonn(in)     = lonn(ilatn,ilonn)
       slonn1(in)    = lonn(ilatn,ilonn+1)
       aslonn1(in)   = (slonn(in)+slonn1(in))/2.
       in = in+1
       k = k+1
       print("INDEX : "+ilath)
       print("THE NUMBER OF SELECTED POINTS : "+in)
      end if
     end do ; ilath
    end do ; ilonn
   end do ; ilatn

   sspm25h= new((/n_old_layer, in/),float,-999)
   sslatn = new((/in/),float,-999)
   sslonn = new((/in/),float,-999)
   sspm25h= aspm25h1(:,0:in-1)
   sslatn = slatn(0:in-1)
   sslonn = aslonn1(0:in-1)

; REVERSE VERTICAL AND HORIZONTAL FOR SELECTED WRFCHEM DATA
   rsspm25h = new((/in,n_old_layer/),float,-999)
   do j = 0, in-1
    do k = 0, n_old_layer-1
     rsspm25h(j, k) = sspm25h(k, j)
    end do 
   end do
; GET ALL THE DATA TO THE ABOVE GROUND LEVEL FOR WRFCHEM
   nrsspm25h = new((/in,n_old_layer/),float,-999)
   do j = 0, in-1
    oneaglpm25 = ndtooned(rsspm25h(j,:))
    aglindex2  = ind(oneaglpm25 .gt. 0.0)
    naglindex2 = dimsizes(aglindex2)
    if(naglindex2 .gt. 1)then
     nrsspm25h(j, (n_old_layer-1):n_old_layer-aglindex2(naglindex2-1)) = \
      rsspm25h(j, (aglindex2(naglindex2-1)-1):0)
    end if
    delete(aglindex2)
    delete(naglindex2)
   end do
   tpm25n(tgrid:(tgrid+in-1), 0:n_old_layer-11) = nrsspm25h(:,10:n_old_layer-1)
   tgrid  = tgrid+in
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;END OF WRFCHEM;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; SELECT THE POINTS WHERE COLUMN AOD>1.0 FOR CALIPSO
   gcaodtind = ind(nncaodt .gt. 1.0)
   imm = dimsizes(gcaodtind)
   if(imm .gt. 1)then
   gnncaod = new((/imm, n_layer/), float, -599.94)
   gnncaod = nncaod(gcaodtind, :)

; GET ALL THE DATA TO THE ABOVE GROUND LEVEL FOR CALIPSO
   nnncaod = new((/imm, n_layer/), float, -599.94)
   do j = 0, imm-1
    oneaglcaod  = ndtooned(gnncaod(j,:))
    aglindex1   = ind(oneaglcaod .gt. 0.0)
    naglindex1  = dimsizes(aglindex1)
    if(naglindex1 .gt. 1)then
     nnncaod(j,(n_layer-1):(n_layer-aglindex1(naglindex1-1)-1)) = \
     gnncaod(j, aglindex1(naglindex1-1):0)
    end if
    delete(aglindex1)
    delete(naglindex1)
   end do

; DIVIDE THE CALIPSO DATA INTO DIFFERENT BIN
   do j = 0, npts-1
    pheight(j, :) = nheight
    l   = 0
    do k = n_layer-1, stride-1, stride
     oneaod     = ndtooned(nnncaod(:,(k-stride):k))
     print(oneaod)
     if(j.lt.npts-1)then
      dindex    = ind(oneaod .gt. daod(j) .and. oneaod .lt. daod(j+1))
     end if
     if(j.eq.npts-1)then
      dindex    = ind(oneaod .ge. daod(j))
     end if
     if(dimsizes(dindex) .gt. 1)then
      aaod(j, l)= avg(oneaod(dindex))
      nfre(j, l)= dimsizes(dindex)
     end if
     l         = l + 1
     delete(oneaod)
     delete(dindex)
    end do
   end do
   tfre = int2flt(sum(nfre))
   pfre = nfre/tfre

; CALCULATE THE TOTAL AVERAGE AOD
   avgaod = avg(aaod)
; SET UP RESOURCES
   lres = True
   lres = res
   lres@tiMainString = "CALIPSO    AOD>1.0 " + dntime + time
; PLOT THE DAILY AOD-FREQUENCY IMAGE
; SET UP TEXT RESOURCES
   tres = True
   tres@txPerimOn     = True
   tres@txFontHeightF = 0.015
   tres@txBackgroundFillColor = 100
   tres@gsnframe      = True
   gsn_text_ndc(wks,"mean = "+sprintf("%7.5f", avgaod), 0.65, 0.7, tres)
   plot = gsn_csm_xy(wks, pfre, pheight, lres)

; PLOT LABEL BAR
; SET UP COLOR MAP AND LABEL
   colorstart    = 2
   colorend      = 220

; SET UP LABEL BAR
   lbres = True
; No margins around labelbar.
   lbres@lbBottomMarginF      = 0.0
   lbres@lbLeftMarginF        = 0.0
   lbres@lbRightMarginF       = 0.0
   lbres@lbTopMarginF         = 0.0

; Turn various features on and off.
   lbres@lbLabelsOn             = True
   lbres@lbPerimOn              = False
   lbres@lbTitleOn              = False
   lbres@lbMonoFillPattern      = True
   lbres@lbOrientation          = "Vertical"
   lbres@lbLabelFontHeightF     = 0.013
   lbres@lbLabelStride          = 2
   lbres@lbBoxLinesOn           = False

   nlevel = (maxaod-minaod)/aodstride+2
   inlevel=toint(nlevel)
   interval=toint((colorend - colorstart)/nlevel)
   colors = ispan(colorstart,colorend,interval)

; SET UP COLOR BAR
   lbres@tiMainFontHeightF      = 0.02
   lbres@lbTitleOn              = True
   lbres@lbTitleString          = "AOD"
   lbres@lbTitleFontHeightF     = 0.015
   lbres@lbTitlePosition        = "Right"
   lbres@lbBoxMinorExtentF      = 1.0
   lbres@lbBoxLineColor         = "White"
   lbres@lbFillColors           = colors

; Which point to position labelbar about.
   lbres@lbJustification        = "BottomRight"
   lbres@lbLabelAlignment       = "InteriorEdges"
   lbres@lbLabelAutoStride      = True
   lbres@lbLabelJust            = "CenterLeft"
   lbres@lbLabelOffsetF         = 0.5
; Set initial width and height.
   lbres@vpHeightF              = 0.4
   lbres@vpWidthF               = 0.03

   labels= daod + ""
   lbid = gsn_create_labelbar_ndc(wks,npts+1,labels,0.9,0.7,lbres)
   draw(lbid)
   delete(lbres)
   do j = 0, npts-1
    do l = 0, n_new_layer-1
     do k = 0, inlevel-2
      if(ismissing(aaod(j, l)))then
       pmcolor = 0
      end if
      if(.not.ismissing(aaod(j, l)).and.k.lt.(inlevel-2).and.aaod(j, l).ge.daod(k).and.aaod(j, l).lt.daod(k+1))then
       pmcolor = colors(k+1)
      end if
      if(.not.ismissing(aaod(j, l)).and.k.eq.(inlevel-2).and.aaod(j, l).ge.daod(k))then
       pmcolor = colors(k+1)
      end if
     end do
     add_markers(wks,plot,pfre(j, l),pheight(j, l),pmcolor,16,0.008,1.0)
    end do
   end do
; Drawing the plot will draw all the attached markers too.
; SET UP TEXT RESOURCES
   tres = True
   tres@txPerimOn     = True
   tres@txFontHeightF = 0.015
   tres@txBackgroundFillColor = 100
   tres@gsnframe      = True
   gsn_text_ndc(wks,"mean = "+sprintf("%7.5f", avgaod), 0.65, 0.7, tres)
   draw(plot)
   frame(wks)

; COLLECT EACH DAY AOD DATA
   mcaod(imn:imn+imm-1, :) = nnncaod
   imn = imn + imm
   delete(clat)
   delete(clon)
   delete(caod)
   delete(nclat)
   delete(nclon)
   delete(ncaod)
   delete(ncaodt)
   delete(nnclat)
   delete(nnclon)
   delete(nncaod)
   delete(nncaodt)
   delete(nnncaod)
   delete(gnncaod)
   delete(sspm25h)
   delete(rsspm25h)
   delete(nrsspm25h)
   delete(sslatn)
   delete(sslonn)
   delete(index)
   delete(gcaodtind)
   delete(lres)
   delete(tres)
   end if
  end do ; END OF I LOOP

;######################################################################
; START MONTHLY PLOT
;######################################################################
; DIVIDE THE MONTHLY AOD INTO DIFFERENT RANGE
   mminaod  = 0.0
   mmaxaod  = 0.12
   mnpts    = 13
   mdaod    = fspan(mminaod, mmaxaod, mnpts)
   mnfre    = new((/mnpts, n_new_layer/), integer, -9999)
   mpfre    = new((/mnpts, n_new_layer/), float, -9999)
   maaod    = new((/mnpts, n_new_layer/), float, -9999)
   smcaod   = new((/imn, n_layer/), float, -9999)
; GET ALL THE DATA TO THE ABOVE GROUND LEVEL
   do i = 0, imn-1
    oneaglmcaod = ndtooned(mcaod(i,:))
    aglindex    = ind(oneaglmcaod .gt. 0.0 .and. mcaodt(i) .gt. 1.0)
    naglindex   = dimsizes(aglindex)
    if(naglindex .gt. 1)then
    smcaod(i,(n_layer-1):n_layer-aglindex(naglindex-1)) = mcaod(i, (aglindex(naglindex-1)-1):0)
    end if
    delete(aglindex)
    delete(naglindex)
   end do
; DIVIDE THE DATA INTO DIFFERENT AOD LEVELS
   do j = 0, mnpts-1
    l   = 0
; REVERSE THE VERTICAL INDEX
    do k = n_old_layer-1, 0, stride
     moneaod    = ndtooned(smcaod(:,k:(k+stride-1)))
     if(j.lt.mnpts-1)then
      mdindex   = ind(moneaod .gt. mdaod(j) .and. moneaod .lt. mdaod(j+1))
     end if      
     if(j.eq.mnpts-1)then
      mdindex   = ind(moneaod .ge. mdaod(j))
     end if
     if(dimsizes(mdindex) .gt. 1)then
      maaod(j, l)= avg(moneaod(mdindex))
      mnfre(j, l)= dimsizes(mdindex)
     end if
     l         = l + 1
     delete(moneaod)
     delete(mdindex)
    end do
   end do
   mtfre    = int2flt(sum(mnfre))
   mpfre    = mnfre/mtfre

; CALCULATE THE AVERAGE AOD
   mavgaod  = avg(maaod)
; SET UP RESOURCES
   mtime= str_get_cols(cname(0), 31, 37)
   lres = True
   lres = res
   lres@trXMinF      = 10^-5
   lres@tiMainString  = "CALIPSO    AOD>1.0  " + dntime + mtime

; PLOT THE DAILY AOD-FREQUENCY IMAGE
; SET UP TEXT RESOURCES
   tres = True
   tres@txPerimOn     = True
   tres@txFontHeightF = 0.015
   tres@txBackgroundFillColor = 100
   tres@gsnframe      = True
   gsn_text_ndc(wks,"mean = "+sprintf("%7.5f", mavgaod), 0.65, 0.7, tres)
   plot = gsn_csm_xy(wks, mpfre, pheight, lres)

; PLOT LABEL BAR
; SET UP LABEL BAR
   lbres = True
; No margins around labelbar.
   lbres@lbBottomMarginF      = 0.0
   lbres@lbLeftMarginF        = 0.0
   lbres@lbRightMarginF       = 0.0
   lbres@lbTopMarginF         = 0.0

; Turn various features on and off.
   lbres@lbLabelsOn             = True
   lbres@lbPerimOn              = False
   lbres@lbTitleOn              = False
   lbres@lbMonoFillPattern      = True
   lbres@lbOrientation          = "Vertical"
   lbres@lbLabelFontHeightF     = 0.013
   lbres@lbLabelStride          = 2
   lbres@lbBoxLinesOn           = False

   nlevel = (maxaod-minaod)/aodstride+2
   inlevel=toint(nlevel)
   interval=toint((colorend - colorstart)/nlevel)
   colors = ispan(colorstart,colorend,interval)

; SET UP COLOR BAR
   lbres@tiMainFontHeightF      = 0.02
   lbres@lbTitleOn              = True
   lbres@lbTitleString          = "AOD"
   lbres@lbTitleFontHeightF     = 0.015
   lbres@lbTitlePosition        = "Right"
   lbres@lbBoxMinorExtentF      = 1.0
   lbres@lbBoxLineColor         = "White"
   lbres@lbFillColors           = colors

; Which point to position labelbar about.
   lbres@lbJustification        = "BottomRight"
   lbres@lbLabelAlignment       = "InteriorEdges"
   lbres@lbLabelAutoStride      = True
   lbres@lbLabelJust            = "CenterLeft"
   lbres@lbLabelOffsetF         = 0.5
; Set initial width and height.
   lbres@vpHeightF              = 0.4
   lbres@vpWidthF               = 0.03

   mlabels= mdaod + ""
   mlbid  = gsn_create_labelbar_ndc(wks,mnpts+1,mlabels,0.9,0.7,lbres)
   draw(mlbid)
   delete(lbres)
   do j = 0, mnpts-1
    do l = 0, n_new_layer-1
     do k = 0, inlevel-2
      if(ismissing(maaod(j, l)))then
       pmcolor = 0
      end if
      if(.not.ismissing(maaod(j, l)).and.k.lt.(inlevel-2).and.maaod(j, l).ge.mdaod(k).and.maaod(j, l).lt.mdaod(k+1))then
       pmcolor = colors(k+1)
      end if
      if(.not.ismissing(maaod(j, l)).and.k.eq.(inlevel-2).and.maaod(j, l).ge.mdaod(k))then
       pmcolor = colors(k+1)
      end if
     end do
     add_markers(wks,plot,mpfre(j, l),pheight(j, l),pmcolor,16,0.01,1.5)
    end do
   end do

; Drawing the plot will draw all the attached markers too.
; SET UP TEXT RESOURCES
   tres = True
   tres@txPerimOn     = True
   tres@txFontHeightF = 0.015
   tres@txBackgroundFillColor = 100
   tres@gsnframe      = True
   gsn_text_ndc(wks,"mean = "+sprintf("%7.5f", mavgaod), 0.65, 0.7, tres)
   draw(plot)
   frame(wks)

; PLOT MONTHLY TOTAL AOD PROFILE
   ttres = True
   ttres@xyMarkLineModes = "Lines"
   ttres@xyLineColor     = "white"
   ttres@trYMinF         = 0.0
   ttres@tiYAxisString   = "Z AGL (km)"
   tttres                = True
   tttres                = ttres
   tttres@trXMinF        = 0.0
   tttres@trXMaxF        = 0.01
   tttres@tiXAxisString  = "AOD"
   tttres@tiMainString   = "CALIPSO    AOD>1.0  " + dntime + mtime
   avgtcaod     = new((/n_old_layer/), float, -599.94)
   onetcaod1    = new((/n_old_layer/), float, -599.94)
   onetcaod1    = 1.0
   avgtnheight  = new((/n_old_layer/), float, -599.94)
   avgtaodheight= new((/n_old_layer, 2/), float, -599.94)
   tcaod        = new((/imn, n_old_layer/), float, -599.94)
   tcaod        = smcaod(:,(n_layer-1):(n_layer-n_old_layer))

; DELETE THE DATA WHOSE TOTAL NUMBER IS SMALL
   do i = 0, n_old_layer-1
    avgindex = ind(tcaod(:,i) .gt. 0.0)
    avgindexn= dimsizes(avgindex)
    if(avgindexn .gt. 1)then
     if(avgindexn .lt. 100)then
      tcaod(avgindex,i) = 0.0
     end if
    end if
   delete(avgindex)
   end do
   avgtcaod    = dim_avg_n(tcaod,0)
   avgtnheight = dim_avg_n(tnheight,0)
   onetcaod    = ndtooned(avgtcaod)
   onetnheight = ndtooned(avgtnheight)
   do i = 0, n_old_layer-1
    avgtaodheight(i, 0) = onetnheight(i)
    avgtaodheight(i, 1) = onetnheight(i)
   end do
   plot1(0) = gsn_csm_xy(wks,onetcaod1,onheight,tttres)
   polyres = True
   polyres@gsLineColor      = "blue"
   polyres@gsLineThicknessF = 3.0
   do i = 0, n_old_layer-1
    gsn_polyline(wks, plot1(0), (/0,onetcaod(i)/), (/onheight(i), onheight(i)/), polyres)
   end do
   avgaodm = avg(onetcaod)
   gsn_text_ndc(wks,"mean = "+sprintf("%7.5f", mavgaod), 0.65, 0.7, tres)
   draw(plot1(0))
   frame(wks)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; DIVIDE OLD LAYER(330) INTO NEW LAYER(22*3) FOR CALIPSO
   nn = 3
   nl = 0
   avgltcaod = new((/n_new_layer*nn/), float, -599.94)
   avgltcaod1= new((/n_new_layer*nn/), float, -599.94)
   avgltcaod1= 1.0
   avgltheight = fspan(0.3, maxheight, n_new_layer*nn)
   do i = 0, n_new_layer*nn-1
    avgltcaod(i) = avg(onetcaod(nl:(nl+stride/nn-1)))
    nl = nl + stride/nn
   end do
   plot1(1) = gsn_csm_xy(wks, avgltcaod1, avgltheight, tttres)
   polyresl = True
   polyresl@gsLineColor      = "blue"
   polyresl@gsLineThicknessF = 9.0
   avgltcaod(ind(avgltcaod .le. 0.005)) = 0.0
   do i = 0, n_new_layer*nn-1
    gsn_polyline(wks, plot1(1), (/0,avgltcaod(i)/), (/avgltheight(i), avgltheight(i)/), polyresl)
   end do
   gsn_text_ndc(wks,"mean = "+sprintf("%7.5f", mavgaod), 0.65, 0.7, tres)
   draw(plot1(1))
   frame(wks)
;  gsn_panel(wks, plot1, (/2,1/), False)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; DIVIDE OLD LAYER(330) INTO NEW LAYER(22*3) FOR WRFCHEM

  avgltpm25 = new((/n_new_layer*nn/), float, -599.94)
  avgltpm251= new((/n_new_layer*nn/), float, -599.94)
  avgltpm251= 100.
  pl = 0
  do i = 0, n_new_layer*nn-1
   avgltpm25(i) = avg(tpm25n(:, pl:(pl+stride/nn-1)))
   pl = pl + stride/nn
  end do
  ttttres                = True
  ttttres                = ttres
  ttttres@trXMinF        = 0.0
  ttttres@trXMaxF        = 30.0
  ttttres@tiXAxisString  = "AEROSOL MASS CONCENTRATION (~F33~m~F0~g/m~S~3~N~)"
  ttttres@tiMainString   = "WRFCHEM    AOD>1.0 " + mtime
  plot2 = gsn_csm_xy(wks, avgltpm251, avgltheight, ttttres)
  do i = 0, n_new_layer*nn-1
   gsn_polyline(wks,plot2, (/0, avgltpm25(i)/), (/avgltheight(i), avgltheight(i)/), polyresl)
  end do
  mavgtpm25= avg(tpm25n)
  mavgpm25 = sum(avgltpm25(ind(avgltpm25 .gt. 0.0)))/dimsizes(ind(avgltpm25 .gt. 0.0))
  ;gsn_text_ndc(wks,"mean = "+sprintf("%7.5f", mavgpm25), 0.65, 0.7, tres)
  draw(plot2)
  frame(wks)
end
