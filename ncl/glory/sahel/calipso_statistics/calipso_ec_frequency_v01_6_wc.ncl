;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PURPOSE OF THIS PROGRAM : READ AOD FROM CALIPSO DATA FILE
; CAL_LID_L2_05kmAPro-Prov-V3-01(DAYTIME AND NIGHTTIME SEPARATELY)
; AND PLOT THE AOD AND MONTHLY AOD FREQUENCY(PROFILE AND ERROR BAR)
; INCLUDING BOTH OF CALIPSO AND WRFCHEM
; ====================================================================
; NOTES:
; (1 ): ADD IF STATEMENT FOR onennrsspm25h. (11/22/2011)
; (2 ): ADD IF STATEMENT FOR onennnncaod1.  (11/22/2011)
; (3 ): ADD IF STATEMENT FOR avglcaod.      (11/22/2011)
; (4 ): ADD IF STATEMENT FOR monennnncaod1  (11/24/2011)
; (5 ): ADD IF STATEMENT FOR onetpm25h      (11/24/2011)
; BRUCE
; JULY 14 21:53 2011
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;  LOAD FUNCTIONS AND PROCEDURES
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/universal/WRFUserARW.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/function/add_markers.ncl"

begin

; SET UP THE PLOT PLATFORM
;  type = "x11"
   type = "pdf" 
;  type = "png"
   wks  = gsn_open_wks(type, "1plt_calipso_ec_frequency_2007_v37_smoke_dust650_sahel_v03_02")
   gsn_define_colormap(wks,"WhAqGrYeOrReVi200")
   plot1= new(2, graphic)
   plot2= new(4, graphic)

; DEFINE BAD VALUE
   bv1  = -599.94
   bv2  = -9999

; READ CALIPSO DATA CAL_LID_L2_05kmALay-Prov-V3-01
  cdir      = "/home/bruce/sshfs/shw/data/satellite/CALIPSO/sahel/2007/CAL_LID_L2_05kmAPro-Prov-V3-01/"
  cnamelist = "CAL_LID_L2_05kmAPro-Prov-V3-01" ; USER SPECIFY
  cname     = asciiread(cdir+cnamelist,-1,"string")
  ncname    = dimsizes(cname)
  mtime     = str_get_cols(cname(0), 31, 37)

; READ WRFCHEM OUTPUT NC FILE
; THIS NEEDS TO HAVE A ".nc" APPENDED
  dirn      = "/home/bruce/sshfs/shw/data/wrf_output/wrfout_sahel_85_smoke_650/wrfout/"
  filelistn = "wrfout_d01_2008"
  injht     = "(650m)"
  namen     = asciiread(dirn+filelistn,-1,"string")
  nfnamen   = dimsizes(namen)
  daten     = new((/nfnamen/), string, "No_FillValue")
  timen     = new((/nfnamen/), string, "No_FillValue")

; READ OUT DATE AND TIME OF WRFCHEM INTO AN ARRARY
  do i = 0, nfnamen-1
   daten(i) = str_get_cols(namen(i), 11, 20)
   timen(i) = str_get_cols(namen(i), 22, 23)
  end do

; ENLARGEMENT FACTOR FOR PM2.5
   pn          = 2.0
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
   colorstart  = 2
   colorend    = 220
; DIVIDE THE FREQUENCY INTO DIFFERENT RANGE
   minfre      = 0.0
   maxfre      = 0.1
   frestride   = 0.01
   nnpts       = 11
   nlevel1     = (maxfre-minfre)/frestride+2
   inlevel1    = toint(nlevel1)
   interval1   = toint((colorend - colorstart)/nlevel1)
   colors1     = ispan(colorstart,colorend,interval1)
; DIVIDE THE PM25 INTO DIFFERENT RANGE
   minfre2     = 0.015
   maxfre2     = 0.025
   minpm25     = 0.0
   maxpm25     = 50.0
   pm25stride  = 5.0
   pm25npts    = 11
   nlevel2     = (maxpm25-minpm25)/pm25stride+2
   inlevel2    = toint(nlevel2)
   interval2   = toint((colorend - colorstart)/nlevel2)
   colors2     = ispan(colorstart,colorend,interval2)
; DIVIDE THE AOD INTO DIFFERENT RANGE
   minaod      = 0.0
   maxaod      = 0.30
   aodstride   = 0.03
   npts        = 11
   daod        = fspan(minaod, maxaod, npts)
   nlevel      = (maxaod-minaod)/aodstride+2
   inlevel     = toint(nlevel)
   interval    = toint((colorend - colorstart)/nlevel)
   colors      = ispan(colorstart,colorend,interval)

; SPECIFY THE LAYER INDEX OF THE TOP LAYER
; IN THE TROPOSPHERIC REGION BETWEEN 20KM TO -0.5KM, THE AEROSOL PROFILE 
; PRODUCTS ARE REPORTED AT A RESOLUTION OF 60M VERTICALLY. CONSIDERING 
; THE ELEVATED HEIGHT OF AEROSOL, WHICH SHOULD BE LOWER THAN 20KM, WE 
; SELECT TOP LAYER AT 340, WHICH MEANS THE HEIGHT SHOULD BE (340-10)*60 = 
; 19800M=19.8KM. WE SELECT 300M(5 LAYERS) AS ONE NEW LAYER.
   stride      = 5
   n_new_layer = n_old_layer/stride
   mcaod       = new((/mn, n_old_layer/), float, bv2)
   tpm25n      = new((/mn, n_new_layer/), float, bv2)
   toheight    = new((/mn, n_old_layer/), float, bv2)
   minheight   =  0.3
   maxheight   = 19.8
   nheight     = fspan(minheight, maxheight, n_new_layer)
   ominheight  =  0.0
   omaxheight  = 19.8
   oheight     = fspan(ominheight, omaxheight, n_old_layer)
   do i = 0, mn-1
    toheight(i,:) = oheight
   end do ; END OF I LOOP
   pheight     = new((/npts, n_new_layer/), float, bv2)
   nfre        = new((/npts, n_new_layer/), integer, bv2)
   pfre        = new((/npts, n_new_layer/), float, bv2)
   lfre        = new((/npts, n_new_layer/), float, bv2)
   sfre        = new((/npts, n_new_layer/), float, bv2)
   aaod        = new((/npts, n_new_layer/), float, bv2)

;----------------------------------------------------------------------
; SET UP RESOURCES FOR THE FREQUENCY PLOT WITH DIFFERENT AOD BINS
   res                             = True
   res@tiYAxisString               = "Z AGL (km)"
   res@tiXAxisString               = "Frequency (%)"
; SET UP AXIS
   res@trXAxisType                 = "LogAxis"
   res@trYMinF                     = 0.0
   res@trYMaxF                     = 20.0
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
   lbres@lbAutoManage         = False
   lbres@pmLabelBarDisplayMode= False
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
   lbres@lbTitlePosition      = "Top"
   lbres@lbBoxMinorExtentF    = 1.0
   lbres@lbBoxLineColor       = "White"
; WHICH POINT TO POSITION LABELBAR ABOUT
   lbres@lbJustification      = "BottomRight"
   lbres@lbLabelAlignment     = "InteriorEdges"
   lbres@lbLabelAutoStride    = True
   lbres@lbLabelJust          = "CenterLeft"
   lbres@lbLabelOffsetF       = 0.5
   lbres@pmLabelBarWidthF     = 0.01
; SET INITIAL WIDTH AND HEIGHT
   lbres@vpHeightF            = 0.4
   lbres@vpWidthF             = 0.02

; SET UP RESOURCES OF LABEL BAR FOR CALIPSO
   lbres1              = True
   lbres1              = lbres
   lbres1@lbFillColors = colors1
   lbres1@lbTitleString= "F(%)"

; SET UP RESOURCES OF LABEL BAR FOR WRFCHEM
   lbres2              = True
   lbres2              = lbres
   lbres2@lbFillColors = colors2
   lbres2@lbTitleString= "F(%)"

; SET UP RESOURCES OF LABEL BAR FOR CALIPSO
   lbres3              = True
   lbres3              = lbres
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
   ttres@xyLineColor     = "blue"
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
   pvres                 = True
   pvres@gsLineColor     = "blue"
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
   csfc  = cdata->Surface_Elevation_Statistics
   cqc   = cdata->Extinction_QC_Flag_532
   caod  = cec*h
   caod@lat2d = clat
   caod@lon2d = clon
   ndim  = dimsizes(clat)
   time  = str_get_cols(cname(i), 31, 40) + " " + str_get_cols(cname(i), 42, 49)
   dateh = str_get_cols(cname(i), 31, 40)
   timeh = str_get_cols(cname(i), 42, 43)
; DEFINE DAYTIME OR NIGHTTIME FOR CALIPSO
   dornh = str_get_cols(cname(i), 51, 51)
   if(dornh .eq. "D")then
    dntime= " Daytime "
   else
    dntime= " Nighttime "
   end if

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;START OF WRFCHEM;;;;;;;;;;;;;;;;;;
   index       = ind(dateh .eq. daten .and. timeh .eq.timen)
   fn          = addfile(dirn+namen(index)+".nc", "r")
   print("WORKING ON TIME : " + dateh + "_" + timeh)
   system("date")
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
   opm25h      = new((/n_old_layer, nlatn,nlonn/),float,-bv2)
   npm25h      = new((/n_new_layer, nlatn,nlonn/),float,-bv2)
   delete(index)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;START OF CALIPSO;;;;;;;;;;;;;;;;;;;;;;;;
; QUALIFY THE QUALITY OF EXTINCTION COEFFICIENT
   cqc2   = cqc(:,:,0)
   onecqc2= ndtooned(cqc2)
   ncqc2  = dimsizes(cqc2)
   cqc2ind= ind_resolve(ind(onecqc2 .ne. 0.0 .and. onecqc2 .ne. 1.0), ncqc2)
   dimcqc2= dimsizes(cqc2ind)
   qcnpts = dimcqc2(0)
   ndimqc = dimcqc2(1)
   do j = 0, qcnpts-1
    caod(cqc2ind(j, 0), cqc2ind(j, 1)) = bv1
   end do
   delete(onecqc2)
   delete(cqc2ind)

; SELECT THE CALIPSO DATA WHICH ARE IN THE FIRE REGION
; SEAS : 20N~10S, 95E~125E
; SAHEL: 35N~15S, 25W~45E
   maxlat =  10.0 ; 10.0 ; 20.0 ; 10.0
   minlat =  -5.0 ;-10.0 ; 10.0 ;- 5.0
   maxlon =  45.0 ; 30.0 ; 45.0 ; 45.0
   minlon = -25.0 ;-25.0 ;-25.0 ;-25.0

; SET ALL THE NEGATIVE VALUE TO -599.94
   do j = 0, ndim(0)-1
    do k = 0, ndim(1)-1
     if(caod(j,k) .lt. 0.0)then
      caod(j,k) = bv1
     end if
    end do
   end do
   nclat  = new((/ndim(0)/), float, bv2)
   nclon  = new((/ndim(0)/), float, bv2)
   ncsfc  = new((/ndim(0)/), float, bv2)
   ncaod  = new((/ndim(0), n_layer/), float, bv1)
   nclat  = clat(:,0)
   nclon  = clon(:,0)
   ncsfc  = csfc(:,2)
   ncaod  = caod(:,:)
   index  = ind(nclat .gt. minlat .and. nclat .lt. maxlat .and. \
                nclon .gt. minlon .and. nclon .lt. maxlon)
   if (dimsizes(index) .gt. 1) then
   nnclat = nclat(index)
   nnclon = nclon(index)
   nncsfc = ncsfc(index)
   nncaod = ncaod(index,:)
   nndim  = dimsizes(nnclat)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;END OF CALIPSO;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; INTERPOLATE THE VARAIBLE TO THE VERTICAL PROFILE
   do ioh = 0, n_old_layer-1
    opm25h(ioh,:,:) = wrf_user_intrp3d(pm25n*pn, zn, "h", oheight(ioh)*1000, 0., False)
   end do
   do inh = 0, n_new_layer-1
    npm25h(inh,:,:) = wrf_user_intrp3d(pm25n*pn, zn, "h", nheight(inh)*1000, 0., False)
   end do
; DEFINE A NEW ARRAY FOR SELECTED VERTICAL VARAIBLE
   sn       = 150 ; # OF SELECTED GRIDS
   ospm25h  = new((/n_old_layer, sn/),float, bv2)
   ospm25h1 = new((/n_old_layer, sn/),float, bv2)
   aospm25h1= new((/n_old_layer, sn/),float, bv2)
   spm25h   = new((/n_new_layer, sn/),float, bv2)
   spm25h1  = new((/n_new_layer, sn/),float, bv2)
   aspm25h1 = new((/n_new_layer, sn/),float, bv2)
   slatn    = new((/sn/),float, bv2)
   slonn    = new((/sn/),float, bv2)
   slonn1   = new((/sn/),float, bv2)
   aslonn1  = new((/sn/),float, bv2)

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
      end if
     end do ; ilath
    end do ; ilonn
   end do ; ilatn
   if (in .gt. 0) then
   osspm25h= new((/n_old_layer, in/),float, bv2)
   sspm25h = new((/n_new_layer, in/),float, bv2)
   sslatn  = new((/in/),float, bv2)
   sslonn  = new((/in/),float, bv2)
   osspm25h= aospm25h1(:,0:in-1)
   sspm25h = aspm25h1(:,0:in-1)
   sslatn  = slatn(0:in-1)
   sslonn  = aslonn1(0:in-1)
; REVERSE VERTICAL AND HORIZONTAL FOR SELECTED WRFCHEM DATA
   orsspm25h = new((/in,n_old_layer/),float, bv2)
   nrsspm25h = new((/in,n_new_layer/),float, bv2)
   do j = 0, in-1
    do k = 0, n_old_layer-1
     orsspm25h(j, k) = osspm25h(k, j)
    end do
    do l = 0, n_new_layer-1
     nrsspm25h(j, l) = sspm25h(l, j)
    end do
   end do
; GET ALL THE DATA TO THE ABOVE GROUND LEVEL FOR WRFCHEM
   oorsspm25h = new((/in,n_old_layer/),float, bv2)
   nnrsspm25h = new((/in,n_new_layer/),float, bv2)
   do j = 0, in-1
    ooneaglpm25 = ndtooned(orsspm25h(j,:))
    noneaglpm25 = ndtooned(nrsspm25h(j,:))
    oaglindex2  = ind(ooneaglpm25 .gt. 0.0)
    naglindex2  = ind(noneaglpm25 .gt. 0.0)
    ooaglindex2 = dimsizes(oaglindex2)
    nnaglindex2 = dimsizes(naglindex2)
    if(ooaglindex2 .gt. 1)then
     oorsspm25h(j, (oaglindex2(ooaglindex2-1)-1):0) = \
      orsspm25h(j, (n_old_layer-1):n_old_layer-oaglindex2(ooaglindex2-1))
    end if
    if(nnaglindex2 .gt. 1)then
     nnrsspm25h(j,(naglindex2(nnaglindex2-1)-1):0) = \
      nrsspm25h(j,(n_new_layer-1):n_new_layer-naglindex2(nnaglindex2-1))
    end if
    delete(oaglindex2)
    delete(naglindex2)
    delete(ooaglindex2)
    delete(nnaglindex2)
   end do
; CALCULATE THE AVERAGE AND STANDARD DEVIATION FOR EACH NEW LAYER
   avgpm25h = new((/n_new_layer/), float, bv2)
   stdpm25h = new((/n_new_layer/), float, bv2)
   wfre     = new((/n_new_layer/), float, bv2)
   wsum     = num(nnrsspm25h .gt. 1.0)
   do j = 0, n_new_layer-2
    onennrsspm25h= ndtooned(nnrsspm25h(:, j+1))
; ADD IF STATEMENT FOR onennrsspm25h (BRUCE 11/22/2011)
    if ( .not.all(ismissing(onennrsspm25h))) then
    avgpm25h(j)  = avg(onennrsspm25h)
    stdpm25h(j)  = stddev(onennrsspm25h)
    end if
    wjsum        = int2flt(num(onennrsspm25h .gt. 1.0))
    if(wsum .gt. 0)then
     wfre(j)      = wjsum/wsum
    end if
   end do
   delete(wsum)
   delete(onennrsspm25h)
   tpm25n(tgrid:(tgrid+in-1), 0:n_new_layer-2) = nnrsspm25h(:,1:n_new_layer-1)
   tgrid  = tgrid+in

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;END OF WRFCHEM;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; GET ALL THE DATA TO THE ABOVE GROUND LEVEL FOR CALIPSO
   nnncaod = new((/nndim(0), n_layer/), float, bv1)
   do j = 0, nndim(0)-1
    aglindex1   = ind(oheight .ge. nncsfc(j))
    naglindex1  = aglindex1(0)
    if(naglindex1 .gt. 1)then
     nnncaod(j, (n_layer-1):naglindex1) = \
      nncaod(j, (n_layer-naglindex1-1):0)
    end if
    delete(aglindex1)
    delete(naglindex1)
   end do

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; DIVIDE OLD LAYER(340) INTO NEW LAYER FOR CALIPSO
   nl = stride
   nnnncaod   = new((/nndim(0), n_old_layer/), float, bv1)
   nnnncaod   = nnncaod(:,(n_layer-9):(n_layer-n_old_layer-8))
   nnnnncaod  = new((/nndim(0), n_new_layer/), float, bv1)
   avglcaod   = new((/n_new_layer/), float, bv1)
   stdlcaod   = new((/n_new_layer/), float, bv1)
   mfre       = new((/n_new_layer/), float, bv1)
   mfre2      = new((/n_new_layer/), float, bv1)
   msum       = num(.not.ismissing(nnnncaod))
   do j = 0, n_new_layer-2
    nnnnncaod(:, j) = dim_sum_n(nnnncaod(:, nl:(nl+stride-1)), 1)
    onennnncaod1    = ndtooned(nnnncaod(:, nl:(nl+stride-1)))
    oneindex        = ind(onennnncaod1 .lt. 0.0)
    if(dimsizes(oneindex) .gt. 1)then
     onennnncaod1(oneindex) = bv1
    end if
    oneindex1       = ind(onennnncaod1 .gt. 0.0)
; ADD IF STATEMENT FOR onennnncaod1 (BRUCE 11/22/2011)
    if(dimsizes(oneindex1) .gt. 1 .and. .not.all(ismissing(onennnncaod1)))then
     avglcaod(j) = avg(onennnncaod1)
     stdlcaod(j) = stddev(onennnncaod1)
     jsum        = int2flt(num(.not.ismissing(onennnncaod1)))
     mfre(j)     = jsum/msum
     mfre2(j)    = jsum/int2flt(nndim(0)*stride)
    end if
    nl = nl + stride
    delete(oneindex)
    delete(oneindex1)
    delete(onennnncaod1)
   end do
   delete(msum)
; ADD IF STATEMENT FOR avglcaod (BRUCE 11/22/2011)
   if (.not.all(ismissing(avglcaod))) then
; SET UP RESOURCES FOR CALIPSO AOD PROFILE (BARS)
   ctres                 = True
   ctres                 = ttres
   ctres@trXMinF         = 0.0
   ctres@trXMaxF         = 0.05
   ctres@tiXAxisString   = "AOD"
   ctres@tiMainString    = "CALIPSO    " + dntime + time
   ctres@gsnDraw         = False
   ctres@gsnFrame        = False
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
   wtres@trXMaxF      = 150.0
   wtres@tiXAxisString= "PM~B~2.5~N~ Mass Concentration (~F33~m~F0~g/m~S~3~N~)"
   wtres@tiMainString = "WRFCHEM " + injht + dateh + "_" + timeh
   wtres@gsnDraw      = False
   wtres@gsnFrame     = False

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
   cvres@trXMinF         = 0.0
   cvres@trXMaxF         = 0.04
   cvres@tiXAxisString   = "AOD"
   cvres@tiMainString    = "CALIPSO    " + dntime + time
   cvres@gsnDraw         = False
   cvres@gsnFrame        = False

   plot     = gsn_csm_xy(wks, avglcaod, nheight, cvres)
   mlabels1 = fspan(minfre, maxfre, nnpts)
   llabels1 = mlabels1*100. + ""
   lbid1    = gsn_create_labelbar_ndc(wks,nnpts+1,llabels1,0.9,0.7,lbres1)
   draw(lbid1)
; PLOT STANDARD DEVIATION OF AOD IN EACH NEW LAYER
   do j = 0, n_new_layer-1
    if(.not.ismissing(avglcaod(j)) .and. .not.ismissing(stdlcaod(j)))then
    gsn_polyline(wks, plot, (/avglcaod(j), avglcaod(j)+stdlcaod(j)/), (/nheight(j), nheight(j)/), pvres)
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
   wvres@trXMinF         = 0.0
   wvres@trXMaxF         = 150.0
   wvres@tiXAxisString   = "PM~B~2.5~N~ Mass Concentration (~F33~m~F0~g/m~S~3~N~)"
   wvres@tiMainString    = "WRFCHEM " + injht + dateh + "_" + timeh
   wvres@gsnDraw         = False
   wvres@gsnFrame        = False

   plot     = gsn_csm_xy(wks, avgpm25h, nheight, wvres)
   mlabels2 = fspan(minfre2, maxfre2, pm25npts)
   llabels2 = mlabels2*100. + ""
   ;lbid2    = gsn_create_labelbar_ndc(wks,pm25npts+1,llabels2,0.9,0.7,lbres2)
   ;draw(lbid2)
; PLOT STANDARD DEVIATION OF AOD IN EACH NEW LAYER
   do j = 0, n_new_layer-1
    if(.not.ismissing(avgpm25h(j)) .and. .not.ismissing(stdpm25h(j)))then
    gsn_polyline(wks, plot, (/avgpm25h(j), avgpm25h(j)+stdpm25h(j)/), (/nheight(j), nheight(j)/), pvres)
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
    add_markers(wks,plot,avgpm25h(l),nheight(l),"blue",16,0.01,1.0)
   end do
   draw(plot)
   frame(wks)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; DIVIDE THE CALIPSO DATA INTO DIFFERENT BIN AND CALCULATE FREQUENCY
; FOR THE TOTAL LAYERS
   do j = 0, npts-1
    pheight(j, :)= nheight
    l   = 0
    do k = stride, n_old_layer-1, stride
     oneaod      = ndtooned(nnnncaod(:,(k-stride):(k-1)))
     if(j.lt.npts-1)then
      dindex     = ind(oneaod .gt. daod(j) .and. oneaod .lt. daod(j+1))
     end if
     if(j.eq.npts-1)then
      dindex     = ind(oneaod .ge. daod(j))
     end if
     if(dimsizes(dindex) .gt. 1)then
      aaod(j, l) = avg(oneaod(dindex))
      nfre(j, l) = dimsizes(dindex)
     end if
     l = l + 1
     delete(oneaod)
     delete(dindex)
    end do
   end do
   tfre = int2flt(nndim(0)*n_new_layer)
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
   tlres@trXMinF      = 10^-4
   tlres@trXMaxF      = 10^0
   tlres@tiMainString = "CALIPSO TOTAL LAYER " + dntime + time
   tlres@gsnDraw      = False
   tlres@gsnFrame     = False

   plot   = gsn_csm_xy(wks, pfre*100, pheight, tlres)
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
     add_markers(wks,plot,pfre(j, l)*100,pheight(j, l),pmcolor,16,0.008,1.5)
    end do
   end do

; DRAW THE TEXT ON THE PLOT
   ;gsn_text_ndc(wks,"F(%)", 0.8, 0.8, False)
   ;gsn_text_ndc(wks,"mean = "+sprintf("%7.5f", avgaod), 0.65, 0.7, tres)
   draw(plot)
   frame(wks)

; PLOT THE DAILY AOD-FREQUENCY IMAGE FOR THE EACH LAYER(VALID DATA)
; SET UP RESOURCES
   llres              = True
   llres              = res
   llres@trXMinF      = 10^-4
   llres@trXMaxF      = 10^2
   llres@tiMainString = "CALIPSO (VALID) EACH LAYER " + dntime + time
   llres@gsnDraw      = False
   llres@gsnFrame     = False

   plot   = gsn_csm_xy(wks, lfre*100, pheight, llres)
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
     add_markers(wks,plot,lfre(j, l)*100,pheight(j, l),pmcolor,16,0.008,1.5)
    end do
   end do
   
; DRAW THE TEXT ON THE PLOT
   ;gsn_text_ndc(wks,"mean = "+sprintf("%7.5f", avgaod), 0.35, 0.7, tres)
   draw(plot)
   frame(wks)

; PLOT THE DAILY AOD-FREQUENCY IMAGE FOR THE EACH LAYER (ALL DATA)
; SET UP RESOURCES
   slres              = True
   slres              = res
   slres@trXMinF      = 10^-4
   slres@trXMaxF      = 10^2
   slres@trXAxisType  = "LogAxis"
   slres@tiMainString = "CALIPSO (ALL)  EACH LAYER " + dntime + time
   slres@gsnDraw      = False
   slres@gsnFrame     = False

   plot   = gsn_csm_xy(wks, sfre*100, pheight, slres)
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
     add_markers(wks,plot,sfre(j, l)*100,pheight(j, l),pmcolor,16,0.008,1.5)
    end do
   end do

; DRAW THE TEXT ON THE PLOT
   ;gsn_text_ndc(wks,"mean = "+sprintf("%7.5f", avgaod), 0.65, 0.7, tres)
   draw(plot)
   frame(wks)

; COLLECT EACH DAY AOD DATA
   mcaod(imn:imn+nndim(0)-1, :) = nnnncaod
   imn = imn + nndim(0)
   delete(tlres)
   delete(llres)
   delete(slres)
   delete(ctres)
   delete(wtres)
   delete(cvres)
   delete(wvres)
   end if ; avglcaod
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
   end if ; in
   delete(nnclat)
   delete(nnclon)
   delete(nncsfc)
   delete(nncaod)
   end if ; index
   delete(clat)
   delete(clon)
   delete(csfc)
   delete(cec)
   delete(caod)
   delete(cqc)
   delete(cqc2)
   delete(nclat)
   delete(nclon)
   delete(ncsfc)
   delete(index)
   delete(ncaod)
  end do ; END OF I LOOP

;######################################################################
;######################################################################
; START MONTHLY PLOT                                                  #
;######################################################################
;######################################################################
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; DIVIDE OLD LAYER(340) INTO NEW LAYER FOR CALIPSO
   asciiwrite("2007_old_sahel", mcaod)
   mnndim    = dimsizes(mcaod)
   mnl       = stride
   mnnnnncaod= new((/mnndim(0), n_new_layer/), float, bv1)
   mavglcaod = new((/n_new_layer/), float, bv1)
   mstdlcaod = new((/n_new_layer/), float, bv1)
   mmfre     = new((/n_new_layer/), float, bv1)
   mnfre     = new((/npts, n_new_layer/), integer, bv2)
   mpfre     = new((/npts, n_new_layer/), float, bv2)
   mlfre     = new((/npts, n_new_layer/), float, bv2)
   msfre     = new((/npts, n_new_layer/), float, bv2)
   maaod     = new((/npts, n_new_layer/), float, bv2)
   mmsum     = num(.not.ismissing(mcaod))
   do j = 0, n_new_layer-2
    mnnnnncaod(:, j) = dim_sum_n(mcaod(:, mnl:(mnl+stride-1)), 1)
    monennnncaod1    = ndtooned(mcaod(:, mnl:(mnl+stride-1)))
    moneindex        = ind(monennnncaod1 .lt. 0.0)
    if(dimsizes(moneindex) .gt. 1)then
     monennnncaod1(moneindex) = bv1
    end if
    moneindex1       = ind(monennnncaod1 .gt. 0.0)
    if(dimsizes(moneindex1) .gt. 1)then
; ADD IF STATEMENT FOR monennnncaod1 (BRUCE 11/24/2011)
    if ( .not.all(ismissing(monennnncaod1))) then
     mavglcaod(j) = avg(monennnncaod1)
     mstdlcaod(j) = stddev(monennnncaod1)
    end if
     mjsum        = int2flt(num(.not.ismissing(monennnncaod1)))
     mmfre(j)     = mjsum/mmsum
    end if
    mnl = mnl + stride
    delete(moneindex)
    delete(moneindex1)
    delete(monennnncaod1)
   end do
   delete(mmsum)
   asciiwrite("2007_new_sahel", mavglcaod)
; CALCULATE AVERAGE PM2.5 IN EACH LAYER FOR WRFCHEM
   mavgpm25h = new((/n_new_layer/), float, bv2)
   mstdpm25h = new((/n_new_layer/), float, bv2)
   mwfre     = new((/n_new_layer/), float, bv2)
   mwsum     = num(tpm25n .gt. 1.0)
   do j = 0, n_new_layer-1
    onetpm25h    = ndtooned(tpm25n(:,j))
; ADD IF STATEMENT FOR onetpm25h (BRUCE 11/24/2011)
    if ( .not.all(ismissing(onetpm25h))) then
    mavgpm25h(j) = avg(onetpm25h)
    mstdpm25h(j) = stddev(onetpm25h)
    end if
    mwjsum       = int2flt(num(onetpm25h .gt. 1.0))
    mwfre(j)     = mwjsum/mwsum
   end do
   delete(mwsum)
   delete(onetpm25h)

; SET UP RESOURCES FOR CALIPSO AOD PROFILE (BARS)
   mctres                 = True
   mctres                 = ttres
   mctres@trXMinF         = 0.0
   mctres@trXMaxF         = 0.05
   mctres@tiXAxisString   = "AOD"
   mctres@tiMainString    = "CALIPSO  " + mtime
   plot1(0) = gsn_csm_xy(wks, mavglcaod, nheight, mctres)
   do j = 0, n_new_layer-1
    gsn_polyline(wks, plot1(0), (/0, mavglcaod(j)/), (/nheight(j), nheight(j)/), polyresl)
   end do
   draw(plot1(0))
   frame(wks)
; SET UP RESOURCES FOR WRFCHEM PM2.5 PROFILE (BARS)
   mwtres              = True
   mwtres              = ttres
   mwtres@trXMinF      = 0.0
   mwtres@trXMaxF      = 150.0
   mwtres@tiXAxisString= "PM~B~2.5~N~ Mass Concentration (~F33~m~F0~g/m~S~3~N~)"
   mwtres@tiMainString = "WRFCHEM " + injht + mtime
   plot1(1) = gsn_csm_xy(wks, mavgpm25h, nheight, mwtres)
   do j = 0, n_new_layer-1
    gsn_polyline(wks, plot1(1), (/0, mavgpm25h(j)/), (/nheight(j), nheight(j)/), polyresl)
   end do
   draw(plot1(1))
   frame(wks)
   gsn_panel(wks, plot1, (/2,1/), False)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PLOT VERTICAL PROFILE AND ERROR BAR FOR CALIPSO AND WRFCHEM
;--------------------CALIPSO-------------------------------------------
   mcvres                 = True
   mcvres                 = vres
   mcvres@trXMinF         = 0.0
   mcvres@trXMaxF         = 0.04
   mcvres@tiXAxisString   = "AOD"
   mcvres@tiMainString    = "CALIPSO    " + mtime
   plot2(0)    = gsn_csm_xy(wks, mavglcaod, nheight, mcvres)
   mlabels1    = fspan(minfre, maxfre, nnpts)
   llabels1    = mlabels1*100 + ""
   lbid1       = gsn_create_labelbar_ndc(wks,nnpts+1,llabels1,0.9,0.7,lbres1)
   draw(lbid1)
; PLOT STANDARD DEVIATION OF AOD IN EACH NEW LAYER
   do j = 0, n_new_layer-1
    if(.not.ismissing(mavglcaod(j)) .and. .not.ismissing(mstdlcaod(j)))then
    gsn_polyline(wks, plot2(0), (/mavglcaod(j), mavglcaod(j)+mstdlcaod(j)/), (/nheight(j), nheight(j)/), pvres)
    gsn_polyline(wks, plot2(0), (/mavglcaod(j)+mstdlcaod(j), mavglcaod(j)+mstdlcaod(j)/), (/nheight(j)-0.1, nheight(j)+0.1/), pvres)
    end if
   end do
; PLOT FREQUENCY IN EACH NEW LAYER
   do l = 0, n_new_layer-1
    do k = 0, inlevel1-2
     if(ismissing(mmfre(l)))then
      pmcolor = 0
     end if
     if(.not.ismissing(mmfre( l)).and.k.lt.(inlevel1-2).and.mmfre(l).ge.mlabels1(k).and.mmfre(l).lt.mlabels1(k+1))then
      pmcolor = colors1(k+1)
     end if
     if(.not.ismissing(mmfre(l)).and.k.eq.(inlevel1-2).and.mmfre(l).ge.mlabels1(k))then
      pmcolor = colors1(k+1)
     end if
    end do
    add_markers(wks,plot2(0),mavglcaod(l),nheight(l),pmcolor,16,0.01,1.0)
   end do
   draw(plot2(0))
   frame(wks)
; OUTPUT nheight, mavglcaod, mmfre, mstdlcaod
   all_calipso       = new((/n_new_layer, 4/), float, bv1)
   all_calipso(:, 0) = nheight
   all_calipso(:, 1) = mavglcaod
   all_calipso(:, 2) = mmfre
   all_calipso(:, 3) = mstdlcaod
   opt               = True
   opt@title         = "Height, AOD, Frequency, Error"
   opt@tspace        = 1
   opt@fout          = "average_aod_monthly"
   format            = "f11.6, f11.6, f11.6, f11.6"
   write_matrix(all_calipso, format, opt)
;-------------------WRFCHEM--------------------------------------------
   mwvres                 = True
   mwvres                 = vres
   mwvres@trXMinF         = 0.0
   mwvres@trXMaxF         = 150.0
   mwvres@tiXAxisString   = "PM~B~2.5~N~ Mass Concentration (~F33~m~F0~g/m~S~3~N~)"
   mwvres@tiMainString    = "WRFCHEM " + injht + mtime
   plot2(1)    = gsn_csm_xy(wks, mavgpm25h, nheight, mwvres)
   mlabels2    = fspan(minfre2, maxfre2, pm25npts)
   llabels2    = mlabels2 + ""
   ;lbid2    = gsn_create_labelbar_ndc(wks,pm25npts+1,llabels2,0.9,0.7,lbres2)
   ;draw(lbid2)
; PLOT STANDARD DEVIATION OF AOD IN EACH NEW LAYER
   do j = 0, n_new_layer-1
    if(.not.ismissing(mavgpm25h(j)) .and. .not.ismissing(mstdpm25h(j)))then
    gsn_polyline(wks, plot2(1), (/mavgpm25h(j), mavgpm25h(j)+mstdpm25h(j)/), (/nheight(j), nheight(j)/), pvres)
    gsn_polyline(wks, plot2(1), (/mavgpm25h(j)+mstdpm25h(j), mavgpm25h(j)+mstdpm25h(j)/), (/nheight(j)-0.1, nheight(j)+0.1/), pvres)
    end if
   end do
; PLOT FREQUENCY IN EACH NEW LAYER
   do l = 0, n_new_layer-1
    do k = 0, inlevel2-2
     if(ismissing(mwfre(l)))then
      pmcolor = 0
     end if
     if(.not.ismissing(mwfre( l)).and.k.lt.(inlevel2-2).and.mwfre(l).ge.mlabels2(k).and.mwfre(l).lt.mlabels2(k+1))then
      pmcolor = colors2(k+1)
     end if
     if(.not.ismissing(mwfre(l)).and.k.eq.(inlevel2-2).and.mwfre(l).ge.mlabels2(k))then
      pmcolor = colors2(k+1)
     end if
    end do
    add_markers(wks,plot2(1),mavgpm25h(l),nheight(l),"blue",16,0.01,1.0)
   end do
   draw(plot2(1))
   frame(wks)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; DIVIDE THE CALIPSO DATA INTO DIFFERENT BIN AND CALCULATE FREQUENCY  ;
; FOR THE TOTAL LAYERS

   do j = 0, npts-1
    l   = 0
    do k = stride, n_old_layer-1, stride
     oneaod      = ndtooned(mcaod(:,(k-stride):(k-1)))
     if(j.lt.npts-1)then
      dindex     = ind(oneaod .gt. daod(j) .and. oneaod .lt. daod(j+1))
     end if
     if(j.eq.npts-1)then
      dindex     = ind(oneaod .ge. daod(j))
     end if
     if(dimsizes(dindex) .gt. 1)then
      maaod(j, l)= avg(oneaod(dindex))
      mnfre(j, l)= dimsizes(dindex)
     end if
     l = l + 1
     delete(oneaod)
     delete(dindex)
    end do
   end do
   mtfre = int2flt(mnndim(0)*n_new_layer)
   mpfre = mnfre/mtfre
; CALCULATE FREQUENCY FOR EACH LAYER SEPARATELY
   do j = 0, n_new_layer-1
    mlfre(:, j) = mnfre(:,j)/int2flt(sum(mnfre(:,j)))
    msfre(:, j) = mnfre(:,j)/int2flt(mnndim(0))
   end do

; CALCULATE THE TOTAL AVERAGE AOD
   mavgaod = avg(mcaod)
; PLOT THE DAILY AOD-FREQUENCY IMAGE FOR THE TOTAL LAYERS
; SET UP RESOURCES
   mtlres              = True
   mtlres              = res
   mtlres@trXMinF      = 10^-7
   mtlres@trXMaxF      = 10^0
   mtlres@tiMainString = "CALIPSO (AOD)  TOTAL LAYER " + mtime
   plot2(2)   = gsn_csm_xy(wks, mpfre*100, pheight, mtlres)
   labels     = daod + ""
   lbid       = gsn_create_labelbar_ndc(wks,npts+1,labels,0.9,0.7,lbres3)
   draw(lbid)
   do j = 0, npts-1
    do l = 0, n_new_layer-1
     do k = 0, inlevel-2
      if(ismissing(maaod(j, l)))then
       pmcolor = 0
      end if
      if(.not.ismissing(maaod(j, l)).and.k.lt.(inlevel-2).and.maaod(j, l).ge.daod(k).and.maaod(j, l).lt.daod(k+1))then
       pmcolor = colors(k+1)
      end if
      if(.not.ismissing(maaod(j, l)).and.k.eq.(inlevel-2).and.maaod(j, l).ge.daod(k))then
       pmcolor = colors(k+1)
      end if
     end do
     add_markers(wks,plot2(2),mpfre(j, l)*100,pheight(j, l),pmcolor,16,0.008,1.5)
    end do
   end do

; DRAW THE TEXT ON THE PLOT
   ;gsn_text_ndc(wks,"mean = "+sprintf("%7.5f", mavgaod), 0.65, 0.7, tres)
   draw(plot2(2))
   frame(wks)

; PLOT THE DAILY AOD-FREQUENCY IMAGE FOR THE EACH LAYER(VALID DATA)
; SET UP RESOURCES
   mllres              = True
   mllres              = res
   mllres@trXMinF      = 10^-3
   mllres@trXMaxF      = 10^3
   mllres@tiMainString = "CALIPSO (VALID)  EACH LAYER" + mtime
   plot2(3) = gsn_csm_xy(wks, mlfre*100, pheight, mllres)
   labels   = daod + ""
   lbid     = gsn_create_labelbar_ndc(wks,npts+1,labels,0.9,0.7,lbres3)
   draw(lbid)
   do j = 0, npts-1
    do l = 0, n_new_layer-1
     do k = 0, inlevel-2
      if(ismissing(maaod(j, l)))then
       pmcolor = 0
      end if
      if(.not.ismissing(maaod(j, l)).and.k.lt.(inlevel-2).and.maaod(j, l).ge.daod(k).and.maaod(j, l).lt.daod(k+1))then
       pmcolor = colors(k+1)
      end if
      if(.not.ismissing(maaod(j, l)).and.k.eq.(inlevel-2).and.maaod(j, l).ge.daod(k))then
       pmcolor = colors(k+1)
      end if
     end do
     add_markers(wks,plot2(3),mlfre(j, l)*100,pheight(j, l),pmcolor,16,0.008,1.5)
    end do
   end do

; DRAW THE TEXT ON THE PLOT
   ;gsn_text_ndc(wks,"mean = "+sprintf("%7.5f", mavgaod), 0.35, 0.7, tres)
   draw(plot2(3))
   frame(wks)

   panel_res                = True
   panel_res@gsnPanelTop    = 0.9
   panel_res@gsnPanelBottom = 0.1
   panel_res@gsnPanelLeft   = 0.1
   panel_res@gsnPanelRight  = 0.9
   gsn_panel(wks, plot2, (/2,2/), panel_res)

; PLOT THE DAILY AOD-FREQUENCY IMAGE FOR THE EACH LAYER (ALL DATA)
; SET UP RESOURCES
   mslres              = True
   mslres              = res
   mslres@trXMinF      = 10^-5
   mslres@trXMaxF      = 10^2
   mslres@trXAxisType  = "LogAxis"
   mslres@tiMainString = "CALIPSO (ALL)  EACH LAYER" + mtime
   plot   = gsn_csm_xy(wks, msfre*100, pheight, mslres)
   labels = daod + ""
   lbid   = gsn_create_labelbar_ndc(wks,npts+1,labels,0.9,0.7,lbres3)
   draw(lbid)
   do j = 0, npts-1
    do l = 0, n_new_layer-1
     do k = 0, inlevel-2
      if(ismissing(maaod(j, l)))then
       pmcolor = 0
      end if
      if(.not.ismissing(maaod(j, l)).and.k.lt.(inlevel-2).and.maaod(j, l).ge.daod(k).and.maaod(j, l).lt.daod(k+1))then
       pmcolor = colors(k+1)
      end if
      if(.not.ismissing(maaod(j, l)).and.k.eq.(inlevel-2).and.maaod(j, l).ge.daod(k))then
       pmcolor = colors(k+1)
      end if
     end do
     add_markers(wks,plot,msfre(j, l)*100,pheight(j, l),pmcolor,16,0.008,1.5)
    end do
   end do

; DRAW THE TEXT ON THE PLOT
   ;gsn_text_ndc(wks,"mean = "+sprintf("%7.5f", mavgaod), 0.65, 0.7, tres)
   draw(plot)
   frame(wks)
   system("date")
end
