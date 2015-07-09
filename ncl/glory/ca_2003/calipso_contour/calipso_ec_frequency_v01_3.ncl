;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PURPOSE OF THIS PROGRAM : READ AOD FROM CALIPSO DATA FILE           ;
; CAL_LID_L2_05kmALay-Prov-V3-01(DAYTIME AND NIGHTTIME SEPARATELY)    ;
; AND PLOT THE AOD AND MONTHLY AOD FREQUENCY(PROFILE AND ERROR BAR)   ;
; BRUCE                                                               ;
; JULY 14 21:53 2011                                                  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
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
   wks  = gsn_open_wks(type, "1plt_calipso_ec_frequency_2006_10_v12_smoke")
   gsn_define_colormap(wks,"BlAqGrYeOrReVi200")
   plot1= new(2, graphic)

; READ CALIPSO DATA CAL_LID_L2_05kmALay-Prov-V3-01
  cdir      = "/media/disk/data/calipso/seas/2006/CAL_LID_L2_05kmAPro-Prov-V3-01/"
  cnamelist = "CAL_LID_L2_05kmAPro-Prov-V3-01_10" ; USER SPECIFY
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

; HEIGHT OF EACH LAYER
   h           = 0.06
; DEFINE MONTHLY DATA ARRAY
   mn          = 500000
   n_layer     = 399
   n_old_layer = 330
   imn         = 0
   nt          = 0
   tgrid       = 0

; SET UP COLOR MAP AND LABEL
   colorstart= 2
   colorend  = 220
; DIVIDE THE FREQUENCY INTO DIFFERENT RANGE
   minfre    = 0.0
   maxfre    = 0.25
   frestride = 0.025
   nnpts     = 11
   nlevel1   = (maxfre-minfre)/frestride+2
   inlevel1  = toint(nlevel1)
   interval1 = toint((colorend - colorstart)/nlevel1)
   colors1   = ispan(colorstart,colorend,interval1)
; DIVIDE THE PM25 INTO DIFFERENT RANGE
   minfre2   = 0.0
   maxfre2   = 0.05
   minpm25   = 0.0
   maxpm25   = 50.0
   pm25stride= 5.0
   pm25npts  = 11
   nlevel2   = (maxpm25-minpm25)/pm25stride+2
   inlevel2  = toint(nlevel2)
   interval2 = toint((colorend - colorstart)/nlevel2)
   colors2   = ispan(colorstart,colorend,interval2)
; DIVIDE THE AOD INTO DIFFERENT RANGE
   minaod    = 0.0
   maxaod    = 0.12
   aodstride = 0.01
   npts      = 13
   daod      = fspan(minaod, maxaod, npts)
   nlevel    = (maxaod-minaod)/aodstride+2
   inlevel   = toint(nlevel)
   interval  = toint((colorend - colorstart)/nlevel)
   colors    = ispan(colorstart,colorend,interval)

; SPECIFY THE LAYER INDEX OF THE TOP LAYER
; IN THE TROPOSPHERIC REGION BETWEEN 20KM TO -0.5KM, THE AEROSOL PROFILE 
; PRODUCTS ARE REPORTED AT A RESOLUTION OF 60M VERTICALLY. CONSIDERING 
; THE ELEVATED HEIGHT OF AEROSOL, WHICH SHOULD BE LOWER THAN 20KM, WE 
; SELECT TOP LAYER AT 340, WHICH MEANS THE HEIGHT SHOULD BE (340-10)*60 = 
; 19800M=19.8KM. WE SELECT 300M(5 LAYERS) AS ONE NEW LAYER.
   stride      = 5
   n_new_layer = n_old_layer/stride
   mcaod       = new((/mn, n_old_layer/), float, -9999)
   tpm25n      = new((/mn, n_new_layer/), float, -9999)
   toheight    = new((/mn, n_old_layer/), float, -9999)
   minheight   =  0.3
   maxheight   = 19.8
   nheight     = fspan(minheight, maxheight, n_new_layer)
   ominheight  =  0.0
   omaxheight  = 19.8
   oheight     = fspan(ominheight, omaxheight, n_old_layer)
   do i = 0, mn-1
    toheight(i,:) = oheight
   end do ; END OF I LOOP
   pheight     = new((/npts, n_new_layer/), float, -9999)
   nfre        = new((/npts, n_new_layer/), integer, -9999)
   pfre        = new((/npts, n_new_layer/), float, -9999)
   lfre        = new((/npts, n_new_layer/), float, -9999)
   sfre        = new((/npts, n_new_layer/), float, -9999)
   aaod        = new((/npts, n_new_layer/), float, -9999)

; DEFINE DAYTIME OR NIGHTTIME FOR CALIPSO 
  dornh  = str_get_cols(cname(0), 51, 51)
  if(dornh .eq. "D")then
   dntime= " Daytime "
  else
   dntime= " Nighttime "
  end if
;----------------------------------------------------------------------
; SET UP RESOURCES FOR THE FREQUENCY PLOT WITH DIFFERENT AOD BINS
   res                             = True
   res@tiYAxisString               = "Z AGL (km)"
   res@tiXAxisString               = "Frequency"
; SET UP AXIS
   res@trXAxisType                 = "LogAxis"
   res@trXMaxF                     = 1.1
   res@trYMinF                     = 0.0
   res@trYMaxF                     = 10.0
   res@tmXMajorGrid                = True
   res@tmYMajorGrid                = True
   res@tmXMinorGrid                = True
   res@tmXMajorGridThicknessF      = 1.0
   res@tmYMajorGridThicknessF      = 1.0
   res@tmXMinorGridThicknessF      = 1.0
   res@tmXMajorGridLineDashPattern = 2
   res@tmYMajorGridLineDashPattern = 2
   res@tmXMinorGridLineDashPattern = 2
   res@xyMarkLineMode              = "Markers"
   res@xyMarkerColor               = "White"
;----------------------------------------------------------------------

; SET UP RESOURCES OF LABEL BAR FOR BOTH CALIPSO AND WRFCHEM
   lbres                      = True
; NO MARGINS AROUND LABELBAR
   lbres@lbBottomMarginF      = 0.0
   lbres@lbLeftMarginF        = 0.0
   lbres@lbRightMarginF       = 0.0
   lbres@lbTopMarginF         = 0.0
; TURN VARIOUS FEATURES ON AND OFF
   lbres@lbLabelsOn           = True
   lbres@lbPerimOn            = False
   lbres@lbTitleOn            = False
   lbres@lbMonoFillPattern    = True
   lbres@lbOrientation        = "Vertical"
   lbres@lbLabelFontHeightF   = 0.013
   lbres@lbLabelStride        = 2
   lbres@lbBoxLinesOn         = False
; SET UP COLOR BAR
   lbres@tiMainFontHeightF    = 0.02
   lbres@lbTitleOn            = True
   lbres@lbTitleFontHeightF   = 0.015
   lbres@lbTitlePosition      = "Right"
   lbres@lbBoxMinorExtentF    = 1.0
   lbres@lbBoxLineColor       = "White"
; WHICH POINT TO POSITION LABELBAR ABOUT
   lbres@lbJustification      = "BottomRight"
   lbres@lbLabelAlignment     = "InteriorEdges"
   lbres@lbLabelAutoStride    = True
   lbres@lbLabelJust          = "CenterLeft"
   lbres@lbLabelOffsetF       = 0.5
; SET INITIAL WIDTH AND HEIGHT
   lbres@vpHeightF            = 0.4
   lbres@vpWidthF             = 0.03

; SET UP RESOURCES OF LABEL BAR FOR CALIPSO
   lbres1              = True
   lbres1              = lbres
   lbres1@lbFillColors = colors1
   lbres1@lbTitleString= "F"

; SET UP RESOURCES OF LABEL BAR FOR WRFCHEM
   lbres2 = True
   lbres2 = lbres
   lbres2@lbFillColors = colors2
   lbres2@lbTitleString= "F"

; SET UP RESOURCES OF LABEL BAR FOR CALIPSO
   lbres3 = True
   lbres3 = lbres 
   lbres3@lbFillColors = colors
   lbres3@lbTitleString= "AOD"
;----------------------------------------------------------------------
; SET UP RESOURCES OF BAR CHART FOR CALIPSO AND WRFCHEM
   polyresl                  = True
   polyresl@gsLineColor      = "blue"
   polyresl@gsLineThicknessF = 16.0
;----------------------------------------------------------------------
; SET UP RESOURCES FOR CALIPSO AOD AND WRFCHEM PM2.5 PROFILE (BARS)
   ttres                 = True
   ttres@xyMarkLineModes = "Lines"
   ttres@xyLineColor     = "red"
   ttres@xyLineThicknessF= 3.0
   ttres@trYMinF         = 0.0
   ttres@trYMaxF         = 10.0
   ttres@tiYAxisString   = "Z AGL (km)"
   ttres@gsnDraw         = False
   ttres@gsnFrame        = False
;----------------------------------------------------------------------
; SET UP RESOURCES OF FREQUENCY AND ERROR BAR PLOT FOR CALIPSO AND WRFCHEM
   vres                  = True
   vres@xyLineColor      = "blue"
   vres@xyLineThicknessF = 2.0
   vres@trYMinF          = 0.0
   vres@trYMaxF          = 10.0
   vres@tiYAxisString    = "Z AGL (km)"
;----------------------------------------------------------------------
; SET UP RESOURCES OF ERROR BAR FOR CALIPSO AND WRFCHEM
   pvres = True
   pvres@gsLineColor     = "red"
   pvres@gsLineThicknessF= 2.0
;----------------------------------------------------------------------
; SET UP TEXT RESOURCES
   tres                       = True
   tres@txPerimOn             = True
   tres@txFontHeightF         = 0.015
   tres@txBackgroundFillColor = 100
   tres@gsnframe              = True

  do i = 0, ncname-1
   cdata = addfile(cdir+cname(i), "r")
   clat  = cdata->Latitude
   clon  = cdata->Longitude
   cec   = cdata->Extinction_Coefficient_532
   caod  = cec*h
   caod@lat2d = clat
   caod@lon2d = clon
   time  = str_get_cols(cname(i), 31, 40) + " " + str_get_cols(cname(i), 42, 49)
   dateh = str_get_cols(cname(i), 31, 40)
   timeh = str_get_cols(cname(i), 42, 43)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;START OF WRFCHEM;;;;;;;;;;;;;;;;;;
   index       = ind(dateh .eq. daten .and. timeh .eq.timen)
   fn          = addfile(dirn+namen(index), "r")
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
   opm25h      = new((/n_old_layer, nlatn,nlonn/),float,-9999)
   npm25h      = new((/n_new_layer, nlatn,nlonn/),float,-9999)
   delete(index)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;START OF CALIPSO;;;;;;;;;;;;;;;;;;;;;;;;
; SELECT THE CALIPSO DATA WHICH ARE IN THE FIRE REGION (20N~10S, 95E~125E)
   maxlat =  20.0
   minlat = -10.0
   maxlon = 125.0
   minlon =  95.0
   ndim   = dimsizes(clat)
; SET ALL THE NEGATIVE VALUE TO -599.94
   do j = 0, ndim(0)-1
    do k = 0, ndim(1)-1
     if(caod(j,k) .lt. 0.0)then
      caod(j,k) = -599.94
     end if
    end do
   end do
   nclat  = new((/ndim(0)/), float, -9999)
   nclon  = new((/ndim(0)/), float, -9999)
   ncaod  = new((/ndim(0), n_layer/), float, -599.94)
   nclat  = clat(:,0)
   nclon  = clon(:,0)
   ncaod  = caod(:,:)
   index  = ind(nclat .gt. minlat .and. nclat .lt. maxlat .and. \
                nclon .gt. minlon .and. nclon .lt. maxlon)
   nnclat = nclat(index)
   nnclon = nclon(index)
   nncaod = ncaod(index,:)
   nndim  = dimsizes(nnclat)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;END OF CALIPSO;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; INTERPOLATE THE VARAIBLE TO THE VERTICAL PROFILE
   do ioh = 0, n_old_layer-1
    opm25h(ioh,:,:) = wrf_user_intrp3d(pm25n, zn, "h", oheight(ioh)*1000, 0., False)
   end do
   do inh = 0, n_new_layer-1
    npm25h(inh,:,:) = wrf_user_intrp3d(pm25n, zn, "h", nheight(inh)*1000, 0., False)
   end do
; DEFINE A NEW ARRAY FOR SELECTED VERTICAL VARAIBLE
   sn       = 150 ; # OF SELECTED GRIDS
   ospm25h  = new((/n_old_layer, sn/),float,-9999)
   ospm25h1 = new((/n_old_layer, sn/),float,-9999)
   aospm25h1= new((/n_old_layer, sn/),float,-9999)
   spm25h   = new((/n_new_layer, sn/),float,-9999)
   spm25h1  = new((/n_new_layer, sn/),float,-9999)
   aspm25h1 = new((/n_new_layer, sn/),float,-9999)
   slatn    = new((/sn/),float,-9999)
   slonn    = new((/sn/),float,-9999)
   slonn1   = new((/sn/),float,-9999)
   aslonn1  = new((/sn/),float,-9999)

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
          nnclon(ilath) .le. lonn(ilatn+1,ilonn+1) .and. k .eq. 0)then
       ospm25h(:,in)  = opm25h(:,ilatn,ilonn)
       ospm25h1(:,in) = opm25h(:,ilatn,ilonn+1)
       aospm25h1(:,in)= (ospm25h(:,in)+ospm25h1(:,in))/2.
       spm25h(:,in)   = npm25h(:,ilatn,ilonn)
       spm25h1(:,in)  = npm25h(:,ilatn,ilonn+1)
       aspm25h1(:,in) = (spm25h(:,in)+spm25h1(:,in))/2.
       slatn(in)      = latn(ilatn,ilonn)
       slonn(in)      = lonn(ilatn,ilonn)
       slonn1(in)     = lonn(ilatn,ilonn+1)
       aslonn1(in)    = (slonn(in)+slonn1(in))/2.
       in = in+1
       k = k+1
       print("INDEX : "+ilath)
       print("THE NUMBER OF SELECTED POINTS : "+in)
      end if
     end do ; ilath
    end do ; ilonn
   end do ; ilatn
   osspm25h= new((/n_old_layer, in/),float,-999)
   sspm25h = new((/n_new_layer, in/),float,-999)
   sslatn  = new((/in/),float,-999)
   sslonn  = new((/in/),float,-999)
   osspm25h= aospm25h1(:,0:in-1)
   sspm25h = aspm25h1(:,0:in-1)
   sslatn  = slatn(0:in-1)
   sslonn  = aslonn1(0:in-1)
; REVERSE VERTICAL AND HORIZONTAL FOR SELECTED WRFCHEM DATA
   orsspm25h = new((/in,n_old_layer/),float,-999)
   nrsspm25h = new((/in,n_new_layer/),float,-999)
   do j = 0, in-1
    do k = 0, n_old_layer-1
     orsspm25h(j, k) = osspm25h(k, j)
    end do
    do l = 0, n_new_layer-1
     nrsspm25h(j, l) = sspm25h(l, j)
    end do
   end do
; GET ALL THE DATA TO THE ABOVE GROUND LEVEL FOR WRFCHEM
   oorsspm25h = new((/in,n_old_layer/),float,-999)
   nnrsspm25h = new((/in,n_new_layer/),float,-999)
   do j = 0, in-1
    ooneaglpm25 = ndtooned(orsspm25h(j,:))
    noneaglpm25 = ndtooned(nrsspm25h(j,:))
    oaglindex2  = ind(ooneaglpm25 .gt. 0.0)
    naglindex2  = ind(noneaglpm25 .gt. 0.0)
    ooaglindex2 = dimsizes(oaglindex2)
    nnaglindex2 = dimsizes(naglindex2)
    if(ooaglindex2 .gt. 1)then
     oorsspm25h(j,(n_old_layer-1):n_old_layer-oaglindex2(ooaglindex2-1)) = \
      orsspm25h(j, (oaglindex2(ooaglindex2-1)-1):0)
    end if
    if(nnaglindex2 .gt. 1)then
     nnrsspm25h(j,(n_new_layer-1):n_new_layer-naglindex2(nnaglindex2-1)) = \
      nrsspm25h(j, (naglindex2(nnaglindex2-1)-1):0)
    end if
    delete(oaglindex2)
    delete(naglindex2)
    delete(ooaglindex2)
    delete(nnaglindex2)
   end do
; CALCULATE THE AVERAGE AND STANDARD DEVIATION FOR EACH NEW LAYER
   avgpm25h = new((/n_new_layer/), float, -999)
   stdpm25h = new((/n_new_layer/), float, -999)
   wfre     = new((/n_new_layer/), float, -999)
   wsum     = num(nnrsspm25h .gt. 1.0)
   do j = 0, n_new_layer-2
    onennrsspm25h= ndtooned(nnrsspm25h(:, j+1))
    avgpm25h(j)  = avg(onennrsspm25h)
    stdpm25h(j)  = stddev(onennrsspm25h)
    wjsum        = int2flt(num(onennrsspm25h .gt. 1.0))
    wfre(j)      = wjsum/wsum
   end do
   delete(wsum)
   delete(onennrsspm25h)
   tpm25n(tgrid:(tgrid+in-1), :) = nnrsspm25h
   tgrid  = tgrid+in

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;END OF WRFCHEM;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; GET ALL THE DATA TO THE ABOVE GROUND LEVEL FOR CALIPSO
   nnncaod = new((/nndim(0), n_layer/), float, -599.94)
   do j = 0, nndim(0)-1
    oneaglcaod  = ndtooned(nncaod(j,:))
    aglindex1   = ind(oneaglcaod .gt. 0.0)
    naglindex1  = dimsizes(aglindex1)
    if(naglindex1 .gt. 1)then
     nnncaod(j,(n_layer-1):(n_layer-aglindex1(naglindex1-1)-1)) = \
      nncaod(j, aglindex1(naglindex1-1):0)
    end if
    delete(aglindex1)
    delete(naglindex1)
   end do

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; DIVIDE OLD LAYER(340) INTO NEW LAYER FOR CALIPSO
   nl = 0
   nnnncaod   = new((/nndim(0), n_old_layer/), float, -599.94)
   nnnncaod   = nnncaod(:,(n_layer-1):(n_layer-n_old_layer))
   nnnnncaod  = new((/nndim(0), n_new_layer/), float, -599.94)
   avglcaod   = new((/n_new_layer/), float, -599.94)
   stdlcaod   = new((/n_new_layer/), float, -599.94)
   mfre       = new((/n_new_layer/), float, -599.94)
   msum       = num(.not.ismissing(nnnncaod))
   do j = 0, n_new_layer-1
    nnnnncaod(:, j) = dim_sum_n(nnnncaod(:, nl:(nl+stride-1)), 1)
    onennnncaod1    = ndtooned(nnnncaod(:, nl:(nl+stride-1)))
    oneindex        = ind(onennnncaod1 .lt. 0.0)
    if(dimsizes(oneindex) .gt. 1)then
     onennnncaod1(oneindex) = -599.94
    end if
    oneindex1       = ind(onennnncaod1 .gt. 0.0)
    if(dimsizes(oneindex1) .gt. 1)then
     avglcaod(j) = avg(onennnncaod1)
     stdlcaod(j) = stddev(onennnncaod1)
     jsum        = int2flt(num(.not.ismissing(onennnncaod1)))
     mfre(j)     = jsum/msum
    end if
    nl = nl + stride
    delete(oneindex)
    delete(oneindex1)
    delete(onennnncaod1)
   end do
   delete(msum)
; SET UP RESOURCES FOR CALIPSO AOD PROFILE (BARS)
   ctres                 = True
   ctres                 = ttres
   ctres@trXMinF         = 0.0
   ctres@trXMaxF         = 0.1
   ctres@tiXAxisString   = "AOD"
   ctres@tiMainString    = "CALIPSO    " + dntime + time
   plot1(0) = gsn_csm_xy(wks, avglcaod, nheight, ctres)
   do j = 0, n_new_layer-1
    gsn_polyline(wks, plot1(0), (/0,avglcaod(j)/), (/nheight(j), nheight(j)/), polyresl)
   end do
   draw(plot1(0))
   frame(wks)
; SET UP RESOURCES FOR WRFCHEM PM2.5 PROFILE (BARS)
   wtres              = True
   wtres              = ttres
   wtres@trXMinF      = 0.0
   wtres@trXMaxF      = 30.0
   wtres@tiXAxisString= "PM2.5 MASS CONCENTRATION (~F33~m~F0~g/m~S~3~N~)"
   wtres@tiMainString = "WRFCHEM    " + dateh + "_" + timeh
   plot1(1) = gsn_csm_xy(wks, avgpm25h, nheight, wtres)
   do j = 0, n_new_layer-1
    gsn_polyline(wks, plot1(1), (/0,avgpm25h(j)/), (/nheight(j), nheight(j)/), polyresl)
   end do
   draw(plot1(1))
   frame(wks)
   gsn_panel(wks, plot1, (/2,1/), False)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PLOT VERTICAL PROFILE AND ERROR BAR FOR CALIPSO AND WRFCHEM
;--------------------CALIPSO-------------------------------------------
   cvres                 = True
   cvres                 = vres
   cvres@trXMinF         =-0.1
   cvres@trXMaxF         = 0.2
   cvres@tiXAxisString   = "AOD"
   cvres@tiMainString    = "CALIPSO    " + dntime + time
   plot    = gsn_csm_xy(wks, avglcaod, nheight, cvres)
   mlabels1 = fspan(minfre, maxfre, nnpts)
   llabels1 = mlabels1 + ""
   lbid1    = gsn_create_labelbar_ndc(wks,nnpts+1,llabels1,0.9,0.7,lbres1)
   draw(lbid1)
; PLOT STANDARD DEVIATION OF AOD IN EACH NEW LAYER
   do j = 0, n_new_layer-1
    if(.not.ismissing(avglcaod(j)) .and. .not.ismissing(stdlcaod(j)))then
    gsn_polyline(wks, plot, (/avglcaod(j)-stdlcaod(j), avglcaod(j)+stdlcaod(j)/), (/nheight(j), nheight(j)/), pvres)
    gsn_polyline(wks, plot, (/avglcaod(j)-stdlcaod(j), avglcaod(j)-stdlcaod(j)/), (/nheight(j)-0.1, nheight(j)+0.1/), pvres)
    gsn_polyline(wks, plot, (/avglcaod(j)+stdlcaod(j), avglcaod(j)+stdlcaod(j)/), (/nheight(j)-0.1, nheight(j)+0.1/), pvres)
    end if
   end do
; PLOT FREQUENCY IN EACH NEW LAYER
   do l = 0, n_new_layer-1
    do k = 0, inlevel1-2
     if(ismissing(mfre(l)))then
      pmcolor = 0
     end if
     if(.not.ismissing(mfre( l)).and.k.lt.(inlevel1-2).and.mfre(l).ge.mlabels1(k).and.mfre(l).lt.mlabels1(k+1))then
      pmcolor = colors1(k+1)
     end if
     if(.not.ismissing(mfre(l)).and.k.eq.(inlevel1-2).and.mfre(l).ge.mlabels1(k))then
      pmcolor = colors1(k+1)
     end if
    end do
    add_markers(wks,plot,avglcaod(l),nheight(l),pmcolor,16,0.01,1.0)
   end do
   draw(plot)
   frame(wks)

;-------------------WRFCHEM--------------------------------------------
   wvres                 = True
   wvres                 = vres
   wvres@trXMinF         =-20.0
   wvres@trXMaxF         = 50.0
   wvres@tiXAxisString   = "PM2.5"
   wvres@tiMainString    = "WRFCHEM    " + dateh + "_" + timeh
   plot    = gsn_csm_xy(wks, avgpm25h, nheight, wvres)
   mlabels2 = fspan(minfre2, maxfre2, pm25npts)
   llabels2 = mlabels2 + ""
   lbid2    = gsn_create_labelbar_ndc(wks,pm25npts+1,llabels2,0.9,0.7,lbres2)
   draw(lbid2)
; PLOT STANDARD DEVIATION OF AOD IN EACH NEW LAYER
   do j = 0, n_new_layer-1
    if(.not.ismissing(avgpm25h(j)) .and. .not.ismissing(stdpm25h(j)))then
    gsn_polyline(wks, plot, (/avgpm25h(j)-stdpm25h(j), avgpm25h(j)+stdpm25h(j)/), (/nheight(j), nheight(j)/), pvres)
    gsn_polyline(wks, plot, (/avgpm25h(j)-stdpm25h(j), avgpm25h(j)-stdpm25h(j)/), (/nheight(j)-0.1, nheight(j)+0.1/), pvres)
    gsn_polyline(wks, plot, (/avgpm25h(j)+stdpm25h(j), avgpm25h(j)+stdpm25h(j)/), (/nheight(j)-0.1, nheight(j)+0.1/), pvres)
    end if
   end do
; PLOT FREQUENCY IN EACH NEW LAYER
   do l = 0, n_new_layer-1
    do k = 0, inlevel2-2
     if(ismissing(wfre(l)))then
      pmcolor = 0
     end if
     if(.not.ismissing(wfre( l)).and.k.lt.(inlevel2-2).and.wfre(l).ge.mlabels2(k).and.wfre(l).lt.mlabels2(k+1))then
      pmcolor = colors2(k+1)
     end if
     if(.not.ismissing(wfre(l)).and.k.eq.(inlevel2-2).and.wfre(l).ge.mlabels2(k))then
      pmcolor = colors2(k+1)
     end if
    end do
    add_markers(wks,plot,avgpm25h(l),nheight(l),pmcolor,16,0.01,1.0)
   end do
   draw(plot)
   frame(wks)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; DIVIDE THE CALIPSO DATA INTO DIFFERENT BIN AND CALCULATE FREQUENCY
; FOR THE TOTAL LAYERS
   do j = 0, npts-1
    pheight(j, :) = nheight
    l   = 0
    do k = stride, n_old_layer-1, stride
     oneaod     = ndtooned(nnnncaod(:,(k-stride):(k-1)))
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
     l = l + 1
     delete(oneaod)
     delete(dindex)
    end do
   end do
   tfre = int2flt(sum(nfre))
   pfre = nfre/tfre
; CALCULATE FREQUENCY FOR EACH LAYER SEPARATELY
   do j = 0, n_new_layer-1
    lfre(:, j) = nfre(:,j)/int2flt(sum(nfre(:,j)))
    sfre(:, j) = nfre(:,j)/int2flt(nndim(0))
   end do

; CALCULATE THE TOTAL AVERAGE AOD
   avgaod = avg(nnnncaod)
; PLOT THE DAILY AOD-FREQUENCY IMAGE FOR THE TOTAL LAYERS
; SET UP RESOURCES
   tlres              = True
   tlres              = res
   tlres@trXMinF      = 10^-5
   tlres@tiMainString = "CALIPSO (AOD)  TOTAL LAYERS" + dntime + time
   plot   = gsn_csm_xy(wks, pfre, pheight, tlres)
   labels = daod + ""
   lbid   = gsn_create_labelbar_ndc(wks,npts+1,labels,0.9,0.7,lbres3)
   draw(lbid)
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
     add_markers(wks,plot,pfre(j, l),pheight(j, l),pmcolor,16,0.01,1.5)
    end do
   end do

; DRAW THE TEXT ON THE PLOT
   gsn_text_ndc(wks,"mean = "+sprintf("%7.5f", avgaod), 0.65, 0.7, tres)
   draw(plot)
   frame(wks)

; PLOT THE DAILY AOD-FREQUENCY IMAGE FOR THE EACH LAYER(VALID DATA)
; SET UP RESOURCES
   llres              = True
   llres              = res
   llres@trXMinF      = 10^-4
   llres@tiMainString = "CALIPSO (VALID)  EACH LAYER" + dntime + time
   plot   = gsn_csm_xy(wks, lfre, pheight, llres)
   labels = daod + ""
   lbid   = gsn_create_labelbar_ndc(wks,npts+1,labels,0.9,0.7,lbres3)
   draw(lbid)
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
     add_markers(wks,plot,lfre(j, l),pheight(j, l),pmcolor,16,0.01,1.5)
    end do
   end do
   
; DRAW THE TEXT ON THE PLOT
   gsn_text_ndc(wks,"mean = "+sprintf("%7.5f", avgaod), 0.65, 0.7, tres)
   draw(plot)
   frame(wks)

; PLOT THE DAILY AOD-FREQUENCY IMAGE FOR THE EACH LAYER (ALL DATA)
; SET UP RESOURCES
   slres              = True
   slres              = res
   slres@trXMinF      = 10^-4
   slres@trXAxisType  = "LogAxis"
   slres@tiMainString = "CALIPSO (ALL)  EACH LAYER" + dntime + time
   plot   = gsn_csm_xy(wks, sfre, pheight, slres)
   labels = daod + ""
   lbid   = gsn_create_labelbar_ndc(wks,npts+1,labels,0.9,0.7,lbres3)
   draw(lbid)
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
     add_markers(wks,plot,sfre(j, l),pheight(j, l),pmcolor,16,0.01,1.5)
    end do
   end do

; DRAW THE TEXT ON THE PLOT
   gsn_text_ndc(wks,"mean = "+sprintf("%7.5f", avgaod), 0.65, 0.7, tres)
   draw(plot)
   frame(wks)

; COLLECT EACH DAY AOD DATA
   mcaod(imn:imn+nndim(0)-1, :) = nnnncaod
   imn = imn + nndim(0)
   delete(clat)
   delete(clon)
   delete(cec)
   delete(caod)
   delete(nclat)
   delete(nclon)
   delete(ncaod)
   delete(nnclat)
   delete(nnclon)
   delete(nncaod)
   delete(nnncaod)
   delete(nnnncaod)
   delete(nnnnncaod)
   delete(sspm25h)
   delete(osspm25h)
   delete(orsspm25h)
   delete(oorsspm25h)
   delete(nrsspm25h)
   delete(nnrsspm25h)
   delete(sslatn)
   delete(sslonn)
   delete(index)
   delete(tlres)
   delete(llres)
   delete(slres)
   delete(ctres)
   delete(wtres)
   delete(cvres)
   delete(wvres)
  end do ; END OF I LOOP

;######################################################################
;######################################################################
; START MONTHLY PLOT                                                  #
;######################################################################
;######################################################################
; DIVIDE THE MONTHLY AOD INTO DIFFERENT RANGE
   mdaod    = fspan(minaod, maxaod, npts)
   mnfre    = new((/npts, n_new_layer/), integer, -9999)
   mpfre    = new((/npts, n_new_layer/), float, -9999)
   maaod    = new((/npts, n_new_layer/), float, -9999)
   smcaod   = new((/imn, n_new_layer/), float, -9999)
; GET ALL THE DATA TO THE ABOVE GROUND LEVEL
   do i = 0, imn-1
    oneaglmcaod = ndtooned(mcaod(i,:))
    aglindex    = ind(oneaglmcaod .gt. 0.0)
    naglindex   = dimsizes(aglindex)
    if(naglindex .gt. 1)then
    smcaod(i,(n_new_layer-1):n_new_layer-aglindex(naglindex-1)) = mcaod(i, (aglindex(naglindex-1)-1):0)
    end if
    delete(aglindex)
    delete(naglindex)
   end do
; DIVIDE THE DATA INTO DIFFERENT AOD LEVELS
   do j = 0, npts-1
    l   = 0
; REVERSE THE VERTICAL INDEX
    do k = n_new_layer-1, 0, stride
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
   lres@tiMainString  = "CALIPSO    AOD  " + dntime + mtime

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
   tres                       = True
   tres@txPerimOn             = True
   tres@txFontHeightF         = 0.015
   tres@txBackgroundFillColor = 100
   tres@gsnframe              = True
   gsn_text_ndc(wks,"mean = "+sprintf("%7.5f", mavgaod), 0.65, 0.7, tres)
   draw(plot)
   frame(wks)

; PLOT MONTHLY TOTAL AOD PROFILE
   ttres                 = True
   ttres@xyMarkLineModes = "Lines"
   ttres@xyLineColor     = "white"
   ttres@trYMinF         = 0.0
   ttres@tiYAxisString   = "Z AGL (km)"
   tttres                = True
   tttres                = ttres
   tttres@trXMinF        = 0.0
   tttres@trXMaxF        = 0.04
   tttres@tiXAxisString  = "AOD"
   tttres@tiMainString   = "CALIPSO    " + dntime + mtime
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
   plot1(0) = gsn_csm_xy(wks,onetcaod1,oheight,tttres)
   polyres = True
   polyres@gsLineColor      = "blue"
   polyres@gsLineThicknessF = 3.0
   do i = 0, n_old_layer-1
    gsn_polyline(wks, plot1(0), (/0,onetcaod(i)/), (/oheight(i), oheight(i)/), polyres)
   end do
   avgaodm = avg(onetcaod)
   gsn_text_ndc(wks,"mean = "+sprintf("%7.5f", mavgaod), 0.65, 0.7, tres)
   draw(plot1(0))
   frame(wks)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; DIVIDE OLD LAYER(330) INTO NEW LAYER(22*3) FOR CALIPSO
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
   do i = 0, n_new_layer*nn-1
    gsn_polyline(wks, plot1(1), (/0,avgltcaod(i)/), (/avgltheight(i), avgltheight(i)/), polyresl)
   end do
   ;gsn_text_ndc(wks,"mean = "+sprintf("%7.5f", mavgaod), 0.65, 0.7, tres)
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
  ttttres@trXMaxF        = 21.0
  ttttres@tiXAxisString  = "AEROSOL MASS CONCENTRATION (~F33~m~F0~g/m~S~3~N~)"
  ttttres@tiMainString   = "WRFCHEM    " + mtime
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
