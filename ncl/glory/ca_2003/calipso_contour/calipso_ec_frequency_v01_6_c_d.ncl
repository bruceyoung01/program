;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PURPOSE OF THIS PROGRAM : READ AOD FROM CALIPSO DATA FILE
; CAL_LID_L2_05kmAPro-Prov-V3-01(DAYTIME AND NIGHTTIME SEPARATELY)
; AND PLOT THE AOD AND MONTHLY AOD FREQUENCY(PROFILE AND ERROR BAR)
; INCLUDING CALIPSO ONLY
; ====================================================================
; NOTES:
; (1 ): ADD IF STATEMENT FOR onennnncaod1.  (11/22/2011)
; (2 ): ADD IF STATEMENT FOR avglcaod.      (11/22/2011)
; BRUCE
; JULY 31 23:43 2011
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
;  type = "x11"
   type = "pdf" 
;  type = "ps"
;  type = "ncgm"
;  type = "png"
   wks  = gsn_open_wks(type, "1plt_calipso_ec_frequency_2007_11_v37_smoke_column_sahel")
   gsn_define_colormap(wks,"WhAqGrYeOrReVi200")
   plot1= new(2, graphic)
   plot2= new(4, graphic)

; DEFINE BAD VALUE
   bv1  = -599.94
   bv2  = -9999

; READ CALIPSO DATA CAL_LID_L2_05kmALay-Prov-V3-01
  cdir      = "/home/bruce/sshfs/pfw/satellite/CALIPSO/sahel/CAL_LID_L2_05kmAPro-Prov-V3-01/"
  cnamelist = "CAL_LID_L2_05kmAPro-Prov-V3-01" ; USER SPECIFY
  cname     = asciiread(cdir+cnamelist,-1,"string")
  ncname    = dimsizes(cname)
  mtime     = str_get_cols(cname(0), 31, 37)

; HEIGHT OF EACH LAYER
   h           = 0.06
; DEFINE MONTHLY DATA ARRAY
   mn          = 300000
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
   maxfre      = 0.12
   frestride   = 0.012
   nnpts       = 11
   nlevel1     = (maxfre-minfre)/frestride+2
   inlevel1    = toint(nlevel1)
   interval1   = toint((colorend - colorstart)/nlevel1)
   colors1     = ispan(colorstart,colorend,interval1)
; DIVIDE THE AOD INTO DIFFERENT RANGE
   minaod      = 0.0
   maxaod      = 0.30
   aodstride   = 0.05
   npts        = 7
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

; SET UP RESOURCES OF LABEL BAR FOR CALIPSO
   lbres3              = True
   lbres3              = lbres
   lbres3@lbFillColors = colors
   lbres3@lbTitleString= "AOD"
;----------------------------------------------------------------------
; SET UP RESOURCES OF BAR CHART FOR CALIPSO
   polyresl                  = True
   polyresl@gsLineColor      = "blue"
   polyresl@gsLineThicknessF = 16.0
;----------------------------------------------------------------------
; SET UP RESOURCES FOR CALIPSO AOD PROFILE (BARS)
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
; SET UP RESOURCES OF FREQUENCY AND ERROR BAR PLOT FOR CALIPSO
   vres                  = True
   vres@xyLineColor      = "black"
   vres@xyLineThicknessF = 2.0
   vres@trYMinF          = 0.0
   vres@trYMaxF          = 10.0
   vres@tiYAxisString    = "Z AGL (km)"
;----------------------------------------------------------------------
; SET UP RESOURCES OF ERROR BAR FOR CALIPSO
   pvres                 = True
   pvres@gsLineColor     = "black"
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
   cadb  = cdata->CAD_Score
   cad   = byte2flt(cadb)
   delete(cadb)
   caod  = cec*h
   caod@lat2d = clat
   caod@lon2d = clon
   ndim  = dimsizes(clat)
   time  = str_get_cols(cname(i), 31, 40) + " " + str_get_cols(cname(i), 42, 49)
   dateh = str_get_cols(cname(i), 31, 40)
   timeh = str_get_cols(cname(i), 42, 43)
   print("WORKING ON TIME : " + dateh + "_" + timeh)
   system("date")
; DEFINE DAYTIME OR NIGHTTIME FOR CALIPSO
   dornh = str_get_cols(cname(i), 51, 51)
   if(dornh .eq. "D")then
    dntime= " Daytime "
   else
    dntime= " Nighttime "
   end if

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
;    if(caod(cqc2ind(j, 0), cqc2ind(j, 1)) .gt. 0.3)then
;     caod(cqc2ind(j, 0), cqc2ind(j, 1)) = bv1
;    end if
   end do
   delete(onecqc2)
   delete(cqc2ind)

; DISTINGUISH THE AEROSOL FROM CLOUD
;   print(cad)
;   cad2   = cad(:,:,0)
;   onecad2= ndtooned(cad2)
;   ncad2  = dimsizes(cad2)
;   ;print(onecad2)
;   cad2ind= ind_resolve(ind(onecad2 .le. -90. .and. onecad2 .ge. -100.), ncad2)
;   print(cad2ind)
;   dimcad2= dimsizes(cad2ind)
;   cadnpts= dimcad2(0)
;   ndimcad= dimcad2(1)
;   do j = 0, cadnpts-1
;    caod(cad2ind(j, 0), cad2ind(j, 1)) = bv1
;   end do
;   delete(onecad2)
;   delete(cad2ind)

; SELECT THE CALIPSO DATA WHICH ARE IN THE FIRE REGION
; SEAS : 20N~10S, 95E~125E
; SAHEL: 10N~10S, 25W~30E
   maxlat =  10.0
   minlat = -10.0
   maxlon =  30.0
   minlon = -25.0

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
    if(dimsizes(oneindex) .gt. 1 .and. .not.all(ismissing(onennnncaod1)))then
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
   plot1(0) = gsn_csm_xy(wks, avglcaod, nheight, ctres)
   do j = 0, n_new_layer-1
    gsn_polyline(wks, plot1(0), (/0,avglcaod(j)/), (/nheight(j), nheight(j)/), polyresl)
   end do
   draw(plot1(0))
   frame(wks)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PLOT VERTICAL PROFILE AND ERROR BAR FOR CALIPSO
;--------------------CALIPSO-------------------------------------------
   cvres                 = True
   cvres                 = vres
   cvres@trXMinF         = 0.0
   cvres@trXMaxF         = 0.04
   cvres@tiXAxisString   = "AOD"
   cvres@tiMainString    = "CALIPSO    " + dntime + time
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
   tlres@trXMaxF      = 10^2
   tlres@tiMainString = "CALIPSO TOTAL LAYER " + dntime + time
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
   llres@trXMaxF      = 10^3
   llres@tiMainString = "CALIPSO (VALID) EACH LAYER " + dntime + time
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
   delete(cvres)
   end if ; avglcaod
   delete(nnclat)
   delete(nnclon)
   delete(nncsfc)
   delete(nncaod)
   delete(nnncaod)
   delete(nnnncaod)
   delete(nnnnncaod)
   end if ; index
   delete(clat)
   delete(clon)
   delete(csfc)
   delete(cec)
   delete(caod)
   delete(cqc)
   delete(cqc2)
   delete(cad)
   delete(nclat)
   delete(nclon)
   delete(ncsfc)
   delete(ncaod)
   delete(index)
  end do ; END OF I LOOP

;######################################################################
;######################################################################
; START MONTHLY PLOT                                                  #
;######################################################################
;######################################################################
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; DIVIDE OLD LAYER(340) INTO NEW LAYER FOR CALIPSO
   system("date")
   mnndim     = dimsizes(mcaod)
   mnndim1    = 500000
   mnndim2    = 900000
   mnl1       = stride
   mnl2       = stride
   mcaod1     = asciiread("2008_old_sahel", (/mnndim1, n_old_layer/), "float")
   mcaod2     = asciiread("2007_11_old_sahel", (/mnndim2, n_old_layer/), "float")
   mnnnnncaod1= new((/mnndim1, n_new_layer/), float, bv1)
   mnnnnncaod2= new((/mnndim2, n_new_layer/), float, bv1)
   mavglcaod  = new((/n_new_layer/), float, bv1)
   mstdlcaod  = new((/n_new_layer/), float, bv1)
   mmfre      = new((/n_new_layer/), float, bv1)
   mmfre1     = new((/n_new_layer/), float, bv1)
   mmfre2     = new((/n_new_layer/), float, bv1)
   mnfre      = new((/npts, n_new_layer/), integer, bv2)
   mpfre      = new((/npts, n_new_layer/), float, bv2)
   mlfre      = new((/npts, n_new_layer/), float, bv2)
   msfre      = new((/npts, n_new_layer/), float, bv2)
   maaod      = new((/npts, n_new_layer/), float, bv2)
   mpfre1     = new((/npts/), float, bv2)
   mpfre2     = new((/npts/), float, bv2)
   mnfre1     = new((/npts/), integer, bv2)
   mnfre2     = new((/npts/), integer, bv2)
   mmsum1     = num(.not.ismissing(mcaod1))
   mmsum2     = num(.not.ismissing(mcaod2))
   do j = 0, n_new_layer-2
    mnnnnncaod1(:, j) = dim_sum_n(mcaod1(:, mnl1:(mnl1+stride-1)), 1)
    monennnncaod1     = ndtooned(mcaod1(:, mnl1:(mnl1+stride-1)))
    moneindex1        = ind(monennnncaod1 .lt. 0.0)
    if(dimsizes(moneindex1) .gt. 1)then
     monennnncaod1(moneindex1) = bv1
    end if
    moneindex11       = ind(monennnncaod1 .gt. 0.0)
    if(dimsizes(moneindex1) .gt. 1)then
     mjsum1        = int2flt(num(.not.ismissing(monennnncaod1)))
     mmfre1(j)     = mjsum1/mmsum1
    end if
    mnl1 = mnl1 + stride
    delete(moneindex1)
    delete(moneindex11)
    delete(monennnncaod1)
   end do
   delete(mmsum1)

   do j = 0, n_new_layer-2
    mnnnnncaod2(:, j) = dim_sum_n(mcaod2(:, mnl2:(mnl2+stride-1)), 1)
    monennnncaod2     = ndtooned(mcaod2(:, mnl2:(mnl2+stride-1)))
    moneindex2        = ind(monennnncaod2 .lt. 0.0)
    if(dimsizes(moneindex2) .gt. 1)then
     monennnncaod2(moneindex2) = bv1
    end if
    moneindex22       = ind(monennnncaod2 .gt. 0.0)
    if(dimsizes(moneindex2) .gt. 1)then
     mjsum2        = int2flt(num(.not.ismissing(monennnncaod2)))
     mmfre2(j)     = mjsum2/mmsum2
    end if
    mnl2 = mnl2 + stride
    delete(moneindex2)
    delete(moneindex22)
    delete(monennnncaod2)
   end do
   delete(mmsum2)


   mavglcaod  = new((/n_new_layer/), float, bv1)
   mavglcaod1 = asciiread("2008_new_sahel", (/n_new_layer/), "float")
   mavglcaod2 = asciiread("2007_11_new_sahel", (/n_new_layer/), "float")
   mavglcaod  = mavglcaod1 - mavglcaod2

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
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PLOT VERTICAL PROFILE AND ERROR BAR FOR CALIPSO AND WRFCHEM
;--------------------CALIPSO-------------------------------------------
   mcvres                 = True
   mcvres                 = vres
   mcvres@trXMinF         = -0.02
   mcvres@trXMaxF         = 0.04
   mcvres@tiXAxisString   = "AOD"
   mcvres@tiMainString    = "CALIPSO  Difference"
   plot2(0)    = gsn_csm_xy(wks, mavglcaod, nheight, mcvres)
;   mlabels1    = fspan(minfre, maxfre, nnpts)
;   llabels1    = mlabels1*100 + ""
;   lbid1       = gsn_create_labelbar_ndc(wks,nnpts+1,llabels1,0.9,0.7,lbres1)
;   draw(lbid1)
; PLOT STANDARD DEVIATION OF AOD IN EACH NEW LAYER
;   do j = 0, n_new_layer-1
;    if(.not.ismissing(mavglcaod(j)) .and. .not.ismissing(mstdlcaod(j)))then
;    gsn_polyline(wks, plot2(0), (/mavglcaod(j), mavglcaod(j)+mstdlcaod(j)/), (/nheight(j), nheight(j)/), pvres)
;    gsn_polyline(wks, plot2(0), (/mavglcaod(j)+mstdlcaod(j), mavglcaod(j)+mstdlcaod(j)/), (/nheight(j)-0.1, nheight(j)+0.1/), pvres)
;    end if
;   end do
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
    add_markers(wks,plot2(0),mavglcaod(l),nheight(l),"black",16,0.01,1.0)
   end do
   draw(plot2(0))
   frame(wks)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; DIVIDE THE CALIPSO DATA INTO DIFFERENT BIN AND CALCULATE FREQUENCY  ;
; FOR THE TOTAL LAYERS
   do j = 0, npts-1
     onemcaod1 = ndtooned(mcaod1)
     if(j.lt.npts-1)then
      dindex1     = ind(onemcaod1 .gt. daod(j) .and. onemcaod1 .lt. daod(j+1))
     end if
     if(j.eq.npts-1)then
      dindex1     = ind(onemcaod1 .ge. daod(j))
     end if
     if(dimsizes(dindex1) .gt. 1)then
      mnfre1(j)= dimsizes(dindex1)
     end if
     delete(onemcaod1)
     delete(dindex1)
   end do
   mtfre1 = int2flt(sum(mnfre1))
   mpfre1 = mnfre1/mtfre1*100.0

   do j = 0, npts-1
     onemcaod2 = ndtooned(mcaod2)
     if(j.lt.npts-1)then
      dindex2     = ind(onemcaod2 .gt. daod(j) .and. onemcaod2 .lt. daod(j+1))
     end if
     if(j.eq.npts-1)then
      dindex2     = ind(onemcaod2 .ge. daod(j))
     end if
     if(dimsizes(dindex2) .gt. 1)then
      mnfre2(j)= dimsizes(dindex2)
     end if
     delete(onemcaod2)
     delete(dindex2)
   end do
   mtfre2 = int2flt(sum(mnfre2))
   mpfre2 = mnfre2/mtfre2*100.0

; PLOT BAR PLOT OF CALIPSO AOD DATA WITH DIFFERENT BINS
   bres = True
   bres@gsnDraw = True
   bres@gsnFrame = False
   bres@gsnXYBarChart = True
   bres@gsnXYBarChartBarWidth = 0.2
   bres@tmXBMode              = "Explicit"
   bres@tmXMValues            = ispan(1, npts, 1)
   bres@tmXBLabels            = daod + ""
   bres@gsnXYBarChartColors   = (/"red"/)
   plot = gsn_csm_xy(wks, fspan(0.75, npts-0.25, npts), mpfre1, bres)
   bres@gsnXYBarChartColors   = (/"blue"/)
   plot = gsn_csm_xy(wks, fspan(1, npts, npts), mpfre2, bres)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; DIVIDE THE CALIPSO DATA INTO DIFFERENT BIN AND CALCULATE FREQUENCY  ;
; FOR THE EACH NEW LAYER
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
   mtlres@trXMinF      = 10^-6
   mtlres@trXMaxF      = 10^2
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
