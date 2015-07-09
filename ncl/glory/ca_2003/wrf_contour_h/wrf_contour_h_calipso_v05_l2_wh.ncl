;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PURPOSE OF THIS PROGRAM :                                                  ;
; (1) READ CALIPSO DATA, AND DEPENDING ON THE CALIPSO PATH TO SELECT THE SAME;
;     PATH FROM WRFCHEM OUTPUT FILE.                                         ;
; (2) PLOT THE VERTICLE PROFILE OF WRFCHEM                                   ;
; (3) THIS PROGRAM IS FOR AFRICA CASE(30W-50E, 15S-40N)                      ;
; (4) ADD TWO IF STATEMENTS. ONE IS FOR VARIABLE IN, THE OTHER IS FOR        ;
;     VARIABLE NDIMH. ALSO ADD SYSTEM TIME ECHO. SO THAT THE START TIME AND  ;
;     END TIME OF RUNNING PRORGAM IS KNOWN. ( BRUCE 11/12/2011)              ;
; (5) OVERLAY WIND VECTOR ON THE PM2.5 AND HEIGHT FOR LEVEL PLOT.            ;
;     (BRUCE 12/08/2011)                                                     ;
; NOTE : CALIPSO DATA---CAL_LID_L2_05kmAPro-Prov-V3-01                       ;
; BRUCE APRIL 05 2011                                                        ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm_epa.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" 
  load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
  load "/home/bruce/program/ncl/tutorial/test/wrf_contour_h/WRFUserARW.ncl"
  load "/home/bruce/program/ncl/tutorial/test/ncl_lib/pro_fun.ncl"


begin

; SET UP THE PLOT PLATFORM
  type = "x11"
; type = "pdf"
  wks  = gsn_open_wks(type, "1plt_contour_h_calipso_2008-02_v05_wh_01_650")
  gsn_define_colormap(wks,"BlAqGrYeOrReVi200")

  plot1= new(3, graphic)
  plot2= new(2, graphic)
  bv1  = -9999.
  nfv  = "No_FillValue"
  str  = "string"
  sstr = " "
  kmtom= 1000.

; READ THE CALIPSO HDF DATA
  dirh      = "/home/bruce/sshfs/pfw/satellite/CALIPSO/sahel/2008/CAL_LID_L2_05kmAPro-Prov-V3-01/"
  filelisth = "CAL_LID_L2_05kmAPro-Prov-V3-01_select"
  nameh     = asciiread(dirh+filelisth, -1, str)
  nfnameh   = dimsizes(nameh)

; READ WRFCHEM OUTPUT NC FILE
; THIS NEEDS TO HAVE A ".nc" APPENDED
  dirn      = "/home/bruce/sshfs/pfw/model/wrfchem2/WRFV3/test/em_real/wrfout_sahel_2000/"
  filelistn = "wrfout_d01_2008"
  namen     = asciiread(dirn+filelistn, -1, str)
  nfnamen   = dimsizes(namen)
  daten     = new((/nfnamen/), string, nfv)
  timen     = new((/nfnamen/), string, nfv)

  dirn2     = "/home/bruce/sshfs/pfw/model/wrfchem2/WRFV3/test/em_real/wrfout_sahel_650/"
  filelistn2= "wrfout_d01_2008"
  namen2    = asciiread(dirn2+filelistn2, -1, str)
  nfnamen2  = dimsizes(namen2)
  daten2    = new((/nfnamen2/), string, nfv)
  timen2    = new((/nfnamen2/), string, nfv)

; RANGE OF STUDY AREA
  minlatn   = -15.0
  maxlatn   =  35.0
  minlonn   = -25.0
  maxlonn   =  45.0

; READ OUT DATE AND TIME OF WRFCHEM INTO AN ARRARY
  do i = 0, nfnamen-1
   daten(i) = str_get_cols(namen(i), 11, 20)
   timen(i) = str_get_cols(namen(i), 22, 23)
  end do
  do i = 0, nfnamen2-1
   daten2(i)= str_get_cols(namen2(i), 11, 20)
   timen2(i)= str_get_cols(namen2(i), 22, 23)
  end do

; CALIPSO DATA LOOP
  t = 0
  do ic = 0, nfnameh-1
   print("START TIME : ")
   system("date")
   fh     = addfile(dirh+nameh(ic), "r")
   d_or_n = str_get_cols(nameh(ic), 51, 51)
   ech    = fh->Extinction_Coefficient_532
   clfh   = fh->Cloud_Layer_Fraction
   aodh   = fh->Column_Optical_Depth_Aerosols_532
   sfch   = fh->Surface_Elevation_Statistics
   qch    = fh->Extinction_QC_Flag_532
   lath   = fh->Latitude
   lonh   = fh->Longitude
   dimlath= dimsizes(lath)
   dimlonh= dimsizes(lonh)
   dimech = dimsizes(ech)
   nlevelh= dimech(1)
   dateh  = str_get_cols(nameh(ic), 31, 40)
   timeh  = str_get_cols(nameh(ic), 42, 43)
   timeall= str_get_cols(nameh(ic), 42, 49)
   clfh1  = new((/dimech(0), dimech(1)/), float, bv1)
   sfch1  = new((/dimech(0)/), float, bv1)
   clfh1  = clfh
   sfch1  = sfch(:,2)

; QUALIFY THE QUALITY OF EXTINCTION COEFFICIENT
   qch2   = qch(:,:,0)
   oneqch2= ndtooned(qch2)
   nqch2  = dimsizes(qch2)
   qch2ind= ind_resolve(ind(oneqch2 .ne. 0.0 .and. oneqch2 .ne. 1.0 .and.\
                            oneqch2 .ne. 2.0 .and. oneqch2 .ne. 16.), nqch2)
   dimqch2= dimsizes(qch2ind)
   qcnpts = dimqch2(0)
   ndimqc = dimqch2(1)
   do j = 0, qcnpts-1
    ech(qch2ind(j, 0), qch2ind(j, 1)) = bv1
   end do
   delete(qch2)
   delete(oneqch2)
   delete(qch2ind)

; ASSIGN ARRAY TO A NEW VALUE
   do j = 0, dimech(1)-1
    do k = 0, dimech(0)-1
     if(clfh1(k,j) .le. 0.0)then
      clfh1(k,j) = bv1
     else
      clfh1(k,j) = 0.0-clfh1(k,j)
     end if
    end do
   end do
; ASSIGN NEW 1 DIMENSIONAL ARRAY FOR LATITUDE AND LONGITUDE OF CALIPSO
   lathh       = lath(:,0)
   lonhh       = lonh(:,0)
; READ WRFCHEM DATA 1
   index       = ind(dateh .eq. daten .and. timeh .eq.timen)
   fn          = addfile(dirn+namen(index)+".nc", "r")
   print("WORKING ON TIME : " + dateh + "_" + timeh)
   pm25n       = getvar(fn, "PM2_5_DRY", t)
   pblhn       = getvar(fn, "PBLH", t)
   ptn         = getvar(fn, "T", t)
   tcn         = getvar(fn, "tc", t)
   latn        = getvar(fn, "XLAT", t)
   lonn        = getvar(fn, "XLONG", t)
   zn          = getvar(fn, "z", t)
   pm25n@lat2d = latn
   pm25n@lon2d = lonn
   dimpm25n    = dimsizes(pm25n)
   pblhn@lat2d = latn
   pblhn@lon2d = lonn
   nleveln     = dimpm25n(0)
   nlatn       = dimpm25n(1)
   nlonn       = dimpm25n(2)

; READ WRFCHEM DATA 2
   index2      = ind(dateh .eq. daten2 .and. timeh .eq.timen2)
   fn2         = addfile(dirn2+namen2(index2)+".nc", "r")
   pm25n2      = getvar(fn2, "PM2_5_DRY", t)
   pblhn2      = getvar(fn2, "PBLH", t)
   ptn2        = getvar(fn2, "T", t)
   tcn2        = getvar(fn2, "tc", t)
   latn2       = getvar(fn2, "XLAT", t)
   lonn2       = getvar(fn2, "XLONG", t)
   zn2         = getvar(fn2, "z", t)
   pm25n2@lat2d= latn
   pm25n2@lon2d= lonn
   dimpm25n2   = dimsizes(pm25n)
   pblhn2@lat2d= latn
   pblhn2@lon2d= lonn
   nleveln2    = dimpm25n2(0)
   nlatn2      = dimpm25n2(1)
   nlonn2      = dimpm25n2(2)

; DEFINE THE HEIGHT LEVELS
; MINIMUM HEIGHT, MAXIMUM HEIGHT, INTERVAL
   minh   = 0
   maxh   = 15
   deltah = 0.06
   inth   = 251
   height = fspan(minh, maxh, inth)

; SELECTED REGION FROM CALIPSO BASED ON WRFCHEM
   indexh = ind(lathh .ge. minlatn .and. lathh .le. maxlatn .and. \
                lonhh .ge. minlonn .and. lonhh .le. maxlonn)
   ndimh  = dimsizes(indexh)
   sstart = indexh(0)
   send   = indexh(ndimh-1)
   sech   = new((/ndimh, inth/), float, bv1)
   sclfh  = new((/ndimh, inth/), float, bv1)
   saodh  = new((/ndimh/), float, bv1)
   ssfch  = new((/ndimh/), float, bv1)
; IF ndimh LOOP BEGIN
   if (ndimh .gt. 1) then
   slathh = lathh(indexh)
   slonhh = lonhh(indexh)
   sech   = ech(sstart:send,(nlevelh-9):(nlevelh-inth-8))
   sclfh  = clfh1(sstart:send,(nlevelh-9):(nlevelh-inth-8))
   saodh  = aodh(sstart:send,0)
   ssfch  = sfch1(sstart:send)

; REVERSE EC ARRARY BETWEEN HEIGHT AND LATITUDE/LONGITUDE
   rsech = new((/inth, ndimh/), float, bv1)
   rsclfh= new((/inth, ndimh/), float, bv1)
   rssfch= new((/ndimh/), float, bv1)
   do j = 0, inth-1
    do k = 0, ndimh-1
     if( .not.ismissing(sech(k,j)).and. sech(k,j) .gt. -1.0  \
         .and. sech(k,j) .lt. 0.0)then
      sech(k,j) = 0.0
     end if
     if( d_or_n .eq. "D" ) then
      rsech(j, k) = sech(ndimh-k-1, j)
      rsclfh(j,k) = sclfh(ndimh-k-1, j)
      rssfch(k)   = ssfch(ndimh-k-1)
     end if
     if( d_or_n .eq. "N" ) then
      rsech(j, k) = sech(k, j)
      rsclfh(j,k) = sclfh(k, j)
      rssfch(k)   = ssfch(k)
     end if
    end do
   end do

; DEFINE A NEW ARRAY FOR VERTICAL VARAIBLE
   pm25h  = new((/inth, nlatn,nlonn/),float, bv1)
   pth    = new((/inth, nlatn,nlonn/),float, bv1)
   pm25h2 = new((/inth, nlatn2,nlonn2/),float, bv1)
   pth2   = new((/inth, nlatn2,nlonn2/),float, bv1)

; DEFINE NEW ARRAY FOR SELECTED VERTICAL VARAIBLE
   sn       = 150 ; # OF SELECTED GRIDS
   spm25h   = new((/inth, sn/),float, bv1)
   spm25h1  = new((/inth, sn/),float, bv1)
   aspm25h1 = new((/inth, sn/),float, bv1)
   spth     = new((/inth, sn/),float, bv1)
   spth1    = new((/inth, sn/),float, bv1)
   aspth1   = new((/inth, sn/),float, bv1)
   spblh    = new((/sn/),float, bv1)
   spblh1   = new((/sn/),float, bv1)
   aspblh1  = new((/sn/),float, bv1)
   slatn    = new((/sn/),float, bv1)
   slonn    = new((/sn/),float, bv1)
   slonn1   = new((/sn/),float, bv1)
   aslonn1  = new((/sn/),float, bv1)
   spm25h2  = new((/inth, sn/),float, bv1)
   spm25h21 = new((/inth, sn/),float, bv1)
   aspm25h21= new((/inth, sn/),float, bv1)
   spth2    = new((/inth, sn/),float, bv1)
   spth21   = new((/inth, sn/),float, bv1)
   aspth21  = new((/inth, sn/),float, bv1)
   spblh2   = new((/sn/),float, bv1)
   spblh21  = new((/sn/),float, bv1)
   aspblh21 = new((/sn/),float, bv1)
   slatn2   = new((/sn/),float, bv1)
   slonn2   = new((/sn/),float, bv1)
   slonn21  = new((/sn/),float, bv1)
   aslonn21 = new((/sn/),float, bv1)

; INTERPOLATE THE VARAIBLE TO THE VERTICAL PROFILE
   do ih = 0, inth-1
    pm25h(ih,:,:)  = wrf_user_intrp3d(pm25n, zn, "h", height(ih)*kmtom, 0., False)
    pm25h2(ih,:,:) = wrf_user_intrp3d(pm25n2, zn2, "h", height(ih)*kmtom, 0., False)
    pth(ih,:,:)    = wrf_user_intrp3d(ptn, zn, "h", height(ih)*kmtom, 0., False)
    pth2(ih,:,:)   = wrf_user_intrp3d(ptn2, zn2, "h", height(ih)*kmtom, 0., False)
   end do

   in = 0
; DO LATITUDE AND LONGITUDE LOOP OF WRFCHEM
   do ilatn = nlatn-2, 0, 1
    do ilonn = nlonn-2, 0, 1
; DO LATITUDE AND LONGITUDE LOOP OF CALIPSO
     k = 0
     do ilath = sstart, send
      if (lath(ilath,0) .ge. latn(ilatn,ilonn) .and. \
          lath(ilath,0) .le. latn(ilatn+1,ilonn+1) .and. \
          lonh(ilath,0) .ge. lonn(ilatn,ilonn) .and. \
          lonh(ilath,0) .le. lonn(ilatn+1,ilonn+1) .and. k .eq. 0)then
       spm25h(:,in)   = pm25h(:,ilatn,ilonn)
       spm25h1(:,in)  = pm25h(:,ilatn,ilonn+1)
       aspm25h1(:,in) = (spm25h(:,in)+spm25h1(:,in))/2.
       spth(:,in)     = pth(:,ilatn,ilonn)
       spth1(:,in)    = pth(:,ilatn,ilonn+1)
       aspth1(:,in)   = (spth(:,in)+spth1(:,in))/2.
       spblh(in)      = pblhn(ilatn,ilonn)
       spblh1(in)     = pblhn(ilatn,ilonn+1)
       aspblh1(in)    = (spblh(in)+spblh1(in))/2.
       slatn(in)      = latn(ilatn,ilonn)
       slonn(in)      = lonn(ilatn,ilonn)
       slonn1(in)     = lonn(ilatn,ilonn+1)
       aslonn1(in)    = (slonn(in)+slonn1(in))/2.
       spm25h2(:,in)  = pm25h2(:,ilatn,ilonn)
       spm25h21(:,in) = pm25h2(:,ilatn,ilonn+1)
       aspm25h21(:,in)= (spm25h2(:,in)+spm25h21(:,in))/2.
       spth2(:,in)    = pth2(:,ilatn,ilonn)
       spth21(:,in)   = pth2(:,ilatn,ilonn+1)
       aspth21(:,in)  = (spth2(:,in)+spth21(:,in))/2.
       spblh2(in)     = pblhn2(ilatn,ilonn)
       spblh21(in)    = pblhn2(ilatn,ilonn+1)
       aspblh21(in)   = (spblh2(in)+spblh21(in))/2.
       slatn2(in)     = latn2(ilatn,ilonn)
       slonn2(in)     = lonn2(ilatn,ilonn)
       slonn21(in)    = lonn2(ilatn,ilonn+1)
       aslonn21(in)   = (slonn2(in)+slonn21(in))/2.
       in = in+1
       k = k+1
      end if
     end do ; ilath
    end do ; ilonn
   end do ; ilatn
   print("THE NUMBER OF SELECTED POINTS : "+in)

; IF IN IS NOT EQUAL TO 0
   if (in .gt. 0) then
   sspm25h = new((/inth, in-1/),float, bv1)
   sspth   = new((/inth, in-1/),float, bv1)
   sspblh  = new((/in-1/),float, bv1)
   sslatn  = new((/in-1/),float, bv1)
   sslonn  = new((/in-1/),float, bv1)
   dis     = new((/in-1/),float, bv1)
   sspm25h2= new((/inth, in-1/),float, bv1)
   sspth2  = new((/inth, in-1/),float, bv1)
   sspblh2 = new((/in-1/),float, bv1)
   sspm25h = aspm25h1(:,0:in-2)
   sspth   = aspth1(:,0:in-2)
   sspblh  = aspblh1(0:in-2)
   sslatn  = slatn(0:in-2)
   sslonn  = aslonn1(0:in-2)
   sspm25h2= aspm25h21(:,0:in-2)
   sspth2  = aspth21(:,0:in-2)
   sspblh2 = aspblh21(0:in-2)

; CALCULATE THE DISTANCE BETWEEN THE POINT AND THE FIRST POINT
  do id = 0, in-2
   dis(id) = gc_latlon(sslatn(0),sslonn(0),sslatn(id),sslonn(id),2,-3)
  end do ; id

; PLOT THE VERTICAL PROFILE OF WRFCHEM BASED ON CALIPSO
; SET UP RESOURCES
  cres                 = True
  cres@cnFillOn        = True
; TURN OFF CONTOUR LINES
  cres@cnLinesOn       = False
; TURN OFF CONTOUR LABELS
  cres@cnLineLabelsOn  = False
  cres@gsnSpreadColors = True
  cres@sfYArray        = height
  cres@trYMaxF         = maxh
  cres@trYMinF         = minh
  cres@tmXBMajorLengthF= 0.005
  cres@tmYRMajorLengthF= 0.005
  cres@tmYLMajorLengthF= 0.005
  cres@tmYRMinorLengthF= 0.002
  cres@tmYLMinorLengthF= 0.002

; SET UP LABEL BAR
  cres@pmLabelBarWidthF       = 0.05
  cres@pmLabelBarHeightF      = 0.3
  cres@lbLabelFontHeightF     = 0.01
  cres@lbLabelStride          = 1
  cres@lbBoxLinesOn           = False
  cres@lbOrientation          = "Vertical"
  cres@lbLabelPosition        = "Right"

; SET UP THE POSITION OF THE CONTOUR PLOT
  cres@vpWidthF                = 0.4
  cres@vpHeightF               = 0.25
  cres@vpXF                    = 0.3
  cres@vpYF                    = 0.7
  cres@gsnDraw                 = False
  cres@gsnFrame                = False

; SET UP AXIS LABEL FOR CONTOUR PLOT OF WRFCHEM
  cresn                 = True
  cresn                 = cres
  npts                  = 6
  stride                = floattoint(in/npts)+1
  cresn@sfXArray        = fspan(0.,(in-2),npts)
  cresn@tmXBMode        = "Explicit"
  cresn@tmXBValues      = fspan(0.,(in-2),npts)
  cresn@tmXBLabels      = sprintf("%5.2f", (slatn(0:(in-2):stride))) + "~C~" + \
                          sprintf("%5.2f", (aslonn1(0:(in-2):stride)))
  cresn@cnLevelSelectionMode = "ManualLevels"
  cresn@cnMinLevelValF       = 2.
  cresn@cnMaxLevelValF       = 20.
  cresn@cnLevelSpacingF      = 2.
  cresn@tiXAxisString   = "Latitude~C~Longitude"
  cresn@tiYAxisString   = "Altitude (km)"
  cresn@tiMainString    = "WRF/CHEM(2000m)    " + dateh + "_" + timeh
  sspm25h@units         = "~F33~m~F0~g/m~S~3~N~"
  sspm25h@description   = "Aerosol Concentration Profile"
  sspm25h2@units        = "~F33~m~F0~g/m~S~3~N~"
  sspm25h2@description  = "Aerosol Concentration Profile"
  sspth@units           = "K"
  sspth@description     = "Perturbation Potential Temperature (theta-t0)"
  cresn1                = True
  cresn1                = cresn
  cresn1@tiMainString   = "WRF/CHEM(2000m)    " + dateh + "_" + timeh
  cresn2                = True
  cresn2                = cresn
  cresn2@tiMainString   = "WRF/CHEM(650m)    " + dateh + "_" + timeh
  plot1(0) = gsn_csm_contour(wks, sspm25h2, cresn2)
  plot1(1) = gsn_csm_contour(wks, sspm25h, cresn1)
  plot2(0) = gsn_csm_contour(wks, sspth, cresn)
  delete(cresn)
  delete(cresn1)
  delete(cresn2)

; SET UP AXIS LABEL FOR XY PLOT
  lres                  = True
  lres@vpWidthF         = 0.4
  lres@vpHeightF        = 0.25
  lres@vpXF             = 0.3
  lres@vpYF             = 0.7
  lres@tmXBMajorLengthF = 0.005
  lres@tmYRMajorLengthF = 0.005
  lres@tmYLMajorLengthF = 0.005
  lres@tmYRMinorLengthF = 0.002
  lres@tmYLMinorLengthF = 0.002
  lres@gsnDraw          = False
  lres@gsnFrame         = False
  wlres                 = True
  wlres                 = lres
  wlres@tmXBMode        = "Explicit"
  wlres@tmXBValues      = fspan(0.,dis(in-2),npts)
  wlres@tmXBLabels      = sprintf("%5.2f", (slatn(0:(in-2):stride))) + "~C~" + \
                          sprintf("%5.2f", (aslonn1(0:(in-2):stride)))
  wlres@tiXAxisString   = "Latitude~C~Longitude"
  wlres@tiYAxisString   = "PBL Height (m)"
  wlres@tiMainString    = "WRF/CHEM(2000m)    " + dateh + "_" + timeh
  sspblh@units          = "km"
  sspblh@description    = "Atmospheric Boundary Layer Height"
  plot2(1) = gsn_csm_xy(wks, dis, sspblh, wlres)
  delete(wlres)

; SET UP AXIS LABEL FOR CONTOUR PLOT OF CALIPSO
  cresh                 = True
  cresh                 = cres
  cresh@tmXBMode        = "Explicit"
  cresh@tmXBValues      = fspan(0.,(ndimh-1),npts)
  cresh@tmXBLabels      = sprintf("%5.2f", (slatn(0:(in-2):stride))) + "~C~" + \
                          sprintf("%5.2f", (aslonn1(0:(in-2):stride)))
  cresh@tiXAxisString   = "Latitude~C~Longitude"
  cresh@tiYAxisString   = "Altitude (km)"
  cresh@tiMainString    = "CALISPO    " + dateh + "_" + timeall
  cresh@cnLevelSelectionMode = "ManualLevels"
  cresh@cnMinLevelValF  = 0.0
  cresh@cnMaxLevelValF  = 0.5
  cresh@cnLevelSpacingF = 0.05

  rsech@units           = "km~S~-1"
  rsech@description     = "Aerosol Extinction Coefficient 532nm"
  gsn_define_colormap(wks,"GaAqGrYeOrReVi200")
  plot1(2) = gsn_csm_contour(wks, rsech, cresh)
  rsclfh@units          = sstr
  rsclfh@description    = sstr
  plot     = gsn_csm_contour(wks, rsclfh, cresh)
  plres                 = True
  plres@gsLineColor     = "black"
  plres@gsLineThicknessF= 2.0
  dum = gsn_add_polyline(wks, plot, fspan(0.,(ndimh-1),ndimh), rssfch, plres)
  overlay(plot1(2), plot)
  draw(plot1(2))
  frame(wks)
  delete(plres)
  pres                  = True
  pres@gsnMaximize      = True
  pres@gsnFrame         = False
  pres@gsnDraw          = False
  pplots  = gsn_panel_return(wks, plot1, (/3,1/), pres)
  bb      = NhlGetBB(pplots)
  pheight = 0.3 ;max(bb(:,0))-min(bb(:,1))
  pres@gsnDraw          = True
  pres@gsnPanelTop      = 0.95
  pres@gsnPanelBottom   = pres@gsnPanelTop-pheight
  colormaps = (/"BlAqGrYeOrReVi200", "BlAqGrYeOrReVi200", "GaAqGrYeOrReVi200"/)
  do iplot = 0, 2
   gsn_define_colormap(wks, colormaps(iplot))
   gsn_panel(wks, plot1(iplot), (/1,1/), pres)
   pres@gsnPanelTop    = pres@gsnPanelBottom
   pres@gsnPanelBottom = pres@gsnPanelTop-pheight
  end do
; SET UP TEXT RESOURCES
  tres = True
  tres@txPerimOn     = False
  tres@txFontHeightF = 0.006
  tres@txBackgroundFillColor = 0
  tres@gsnframe      = True
  gsn_text_ndc(wks," Cloud ", 0.705, 0.105, tres)
  frame(wks)
  gsn_define_colormap(wks,"BlAqGrYeOrReVi200")
  panel_res                = True
  panel_res@gsnPanelTop    = 0.9
  panel_res@gsnPanelBottom = 0.1
  panel_res@gsnPanelLeft   = 0.1
  panel_res@gsnPanelRight  = 0.9
  gsn_panel(wks, plot2, (/2,1/), panel_res)
  delete(cresh)
  delete(cres)
  delete(pres)
  delete(panel_res)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PLOT THE CALIPSO PATH ON WRFCHEM LEVEL IMAGE
;-----------------------EPA SITES-------------------------------------
  gsn_define_colormap(wks,"WhBlGrYeOrReVi200")
; READ DATA INTO A BIG 1D STRING ARRAY
  fname = "/mnt/sdc/data/epa/epa_data/PM25_DATA/PM25_Simplified_Data/Simple_New_RD_501_88502_2006-0.txt"
  fname1= "/mnt/sdc/data/epa/epa_data/PM25_DATA/PM25_Simplified_Data/Simple_new_site_monitor.txt"
  data  = asciiread(fname, -1, str)
  data1 = asciiread(fname1, -1, str) 
; COUNT THE NUMBER OF FIELDS, JUST TO SHOW IT CAN BE DONE
  nfields =str_fields_count(data(1), sstr)
  nfields1=str_fields_count(data1(1), sstr)
  
; SKIP THE FIRST ROW OF "DATA" BECAUSE IT'S JUST A HEADER LINE
; USE A SPACE(" ") AS A DELIMETER IN STR_GET_FIELD. THE FIRST FIELD
; IS FIELD=1 (UNLIKE STR_GET_COLS, IN WHICH THE FIRST COLUMN IS COLUMN=0)
  state  =stringtoint(str_get_field(data(1::), 1, sstr))
  county =stringtoint(str_get_field(data(1::), 2, sstr))
  site   =stringtoint(str_get_field(data(1::), 3, sstr))
  yr     =stringtoint(str_get_field(data(1::), 4, sstr))
  mn     =stringtoint(str_get_field(data(1::), 5, sstr))
  dd     =stringtoint(str_get_field(data(1::), 6, sstr))
  time   =stringtoint(str_get_field(data(1::), 7, sstr))
  epapm25=stringtofloat(str_get_field(data(1::), 8, sstr))
  
  astate =stringtoint(str_get_field(data1(1::), 2, sstr))
  acounty=stringtoint(str_get_field(data1(1::), 3, sstr))
  asite  =stringtoint(str_get_field(data1(1::), 4, sstr))
  lat    =stringtofloat(str_get_field(data1(1::), 5, sstr))
  lon    =stringtofloat(str_get_field(data1(1::), 6, sstr))

; SET UP THE LEVEL IMAGE
; THE SPECIFIC PRESSURE LEVELS THAT WE WANT THE DATA INTERPOLATED TO
  pressure = 700

; SET UP THE DESIRED MODS FOR THE MAP AND PLOT
  resmp    = True

; SET UP MAP PROJECTION AND LIMITED REGION
  resmp@mpProjection      = "CylindricalEquidistant"
  resmp@mpCenterRotF      = 0.0
  resmp@mpGridAndLimbOn   = True
  resmp@mpGridLatSpacingF = 5.0
  resmp@mpGridLonSpacingF = 5.0
  resmp@mpLimitMode       = "latlon"
  resmp@mpMinLatF         = minlatn
  resmp@mpMaxLatF         = maxlatn
  resmp@mpMinLonF         = minlonn
  resmp@mpMaxLonF         = maxlonn

; COLOR AND THICKNESS OF CONTINIENTAL OUTLINES OF MAP
  resmp@mpOutlineOn                 = True
  resmp@mpGeophysicalLineColor      = "Black"
  resmp@mpNationalLineColor         = "Black"
  resmp@mpUSStateLineColor          = "Black"
  resmp@mpGridLineColor             = "Black"
  resmp@mpLimbLineColor             = "Black"
  resmp@mpPerimLineColor            = "Black"
  resmp@mpGeophysicalLineThicknessF = 3.0
  resmp@mpGridLineThicknessF        = 1.5
  resmp@mpLimbLineThicknessF        = 3.0
  resmp@mpNationalLineThicknessF    = 3.0
  resmp@mpUSStateLineThicknessF     = 3.0
  resmp@mpGridLineDashPattern       = 2
  resmp@mpOutlineBoundarySets       = "GeophysicalAndUSStates"

; TURN ON MAP TICKMARKS
  resmp@pmTickMarkDisplayMode       = "always"
  resmp@gsnDraw                     = False
  resmp@gsnFrame                    = False

  map  = gsn_csm_map(wks,resmp)

; MAXIMIZE PLOT IN FRAME
  res             = True
  res@gsnMaximize = True
; THE DATA IS NOT GLOBAL
  res@gsnAddCyclic= False
; SET UP THE FEATRUED TITLE
  res@gsnLeftString                = " "
  res@gsnRightString               = " "
  res@gsnStringFontHeightF         = 0.02
  res@gsnRightStringOrthogonalPosF = 0.02
  res@gsnLeftStringOrthogonalPosF  = 0.02

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
  res@cnInfoLabelOn          = False
  res@cnInfoLabelPerimOn     = False

  res@cnLevelSelectionMode   = "ManualLevels"
  res@cnMinLevelValF         =  2.0
  res@cnMaxLevelValF         = 42.0
  res@cnLevelSpacingF        =  2.0

; SET UP LABEL BAR
  res@pmLabelBarWidthF       = 0.4
  res@pmLabelBarHeightF      = 0.04
  res@lbLabelFontHeightF     = 0.01
  res@lbLabelStride          = 2
  res@lbBoxLinesOn           = False


; SET UP COLOR BAR
  res@tiMainFontHeightF      = 0.015
  res@lbTitleString          = "PM~B~2.5~N~ Mass Concentration (~F33~m~F0~g/m~S~3~N~)"
  res@lbTitleFontHeightF     = 0.01
  res@lbTitlePosition        = "Bottom"

; SET UP VIEW PLOT
  res@vpWidthF               = 0.4
  res@vpHeightF              = 0.25
  res@vpXF                   = 0.3
  res@vpYF                   = 0.7
  res@gsnDraw                = False
  res@gsnFrame               = False

; PLOT THE CONTOUR OVER THE CE MAP
; READ PM2.5 DATA FROM WRF/CHEM OUTPUT FILE AND SET XLAT AND XLONG AS THE ATTRIBUTE OF PM25
  times      = fn->Times(t,:)
  pm25       = fn->PM2_5_DRY(t,:,:,:)
  pm25@lat2d = fn->XLAT(t,:,:)
  pm25@lon2d = fn->XLONG(t,:,:)
  res@tiMainString = "WRF/CHEM   " + times
; GRID POINT HEIGHT
  z  = getvar(fn, "z",t)
  z  = z/10.
  z@lat2d = fn->XLAT(t,:,:)
  z@lon2d = fn->XLONG(t,:,:)

  u       = wrf_user_getvar(fn, "ua", 0)
  v       = wrf_user_getvar(fn, "va", 0)
  u@lat2d = fn->XLAT(0,:,:)
  u@lon2d = fn->XLONG(0,:,:)
  v@lat2d = fn->XLAT(0,:,:)
  v@lon2d = fn->XLONG(0,:,:)

  pa      = fn->P(t,:,:,:)
  pb      = fn->PB(t,:,:,:)
  p       = pa+pb
  p@lat2d = fn->XLAT(t,:,:)
  p@lon2d = fn->XLONG(t,:,:)

  z_plane  = gsn_csm_user_intrp3d( z,p,"h",pressure,0.,False)
; SET UP Z RESOURCES
   resz                                = True
   resz@cnLevelSelectionMode           = "ManualLevels"
   resz@cnMinLevelValF                 = 290.
   resz@cnMaxLevelValF                 = 320.
   resz@cnLevelSpacingF                = 2.
   resz@cnLabelDrawOrder               = "PostDraw"
   resz@cnLineColor                    = "Red"
   resz@cnInfoLabelOn                  = False
   resz@gsnContourLineThicknessesScale = 2.5
   resz@cnLineLabelInterval            = 1
   resz@cnLineLabelsOn                 = True
   resz@cnLineLabelFontColor           = "Red"
   resz@cnLineLabelPlacementMode       = "Constant"
; SET UP THE FEATRUED TITLE
   resz@gsnLeftString                  = "Height ~C~ ~C~"
   resz@gsnRightString                 = "10m ~C~ ~C~"
   resz@gsnStringFontHeightF           = 0.01
   resz@gsnRightStringOrthogonalPosF   = 0.01
   resz@gsnLeftStringOrthogonalPosF    = 0.01
   resz@vpWidthF                       = 0.4
   resz@vpHeightF                      = 0.25
   resz@vpXF                           = 0.3
   resz@vpYF                           = 0.7
   resz@gsnDraw                        = False
   resz@gsnFrame                       = False

;  SET UP VECTOR RESOURCES
   resvc                               = True
   resvc@vcRefAnnoString2              = " "
   resvc@vcRefMagnitudeF               = 10.0
   resvc@vcRefLengthF                  = 0.05
   resvc@vcRefAnnoOrthogonalPosF       =-1.282
   resvc@vcRefAnnoArrowLineColor       = "black"
   resvc@vcRefAnnoArrowUseVecColor     = False
   resvc@vcGlyphStyle                  = "CurlyVector"
   resvc@vcLineArrowColor              = "Black"
   resvc@vcLineArrowThicknessF         = 2.0
   resvc@vcVectorDrawOrder             = "PostDraw"
   resvc@vcMinDistanceF                = 0.03
; SET UP THE FEATRUED TITLE
   resvc@gsnLeftString                 = "Wind"
   resvc@gsnRightString                = "m/s"
   resvc@gsnStringFontHeightF          = 0.01
   resvc@gsnRightStringOrthogonalPosF  = 0.01
   resvc@gsnLeftStringOrthogonalPosF   = 0.01
   resvc@vpWidthF                      = 0.4
   resvc@vpHeightF                     = 0.25
   resvc@vpXF                          = 0.3
   resvc@vpYF                          = 0.7
   resvc@gsnDraw                       = False
   resvc@gsnFrame                      = False

; JUDGE IF THE THERE ARE EPA STATION OBSERVATION AT THIS TIME
  yyr  = stringtoint(str_get_cols(times,0,3))
  mmn  = stringtoint(str_get_cols(times,5,6))
  ddd  = stringtoint(str_get_cols(times,8,9))
  ttime= stringtoint(str_get_cols(times,11,12)+"00")

; SELECT EPA  SITE DATA
; FIND THE INDEX THAT MATCHES THE SPECIFIED TIME
  location=ind(mn.eq.mmn.and.dd.eq.ddd.and.time.eq.ttime)

; PM25 DATA AT THE SPECIFIED TIME
  ppm=epapm25(location)
  sstate=state(location)
  ccounty=county(location)
  ssite=site(location)
  count=dimsizes(ppm)
  llat=new((/count/), float, bv1)
  llon=new((/count/), float, bv1)
  llat@_FillValue = bv1
  llon@_FillValue = bv1
  index=0
  do i=0,count-1
   index=ind(astate.eq.sstate(i) .and. \
             acounty.eq.ccounty(i) .and. \
             asite.eq.ssite(i))
   if(index.eq.0)then
    print("No Match Found")
   end if

   if(index.gt.0)then
    llat(i)=lat(index(0))
    llon(i)=lon(index(0))
   end if
   nlevel = (res@cnMaxLevelValF-res@cnMinLevelValF)/res@cnLevelSpacingF+2
   inlevel=toint(nlevel)
   interval=toint(200/nlevel)
   colors = ispan(2,201,interval)
   tpmcolor=toint((ppm(i)-min(ppm))/(max(ppm)-min(ppm))*200)
   do j=0,nlevel-1
    if(tpmcolor.eq.colors(j))then
     pmcolor=colors(j)
    end if
    if(j.gt.0.and.tpmcolor.gt.colors(j).and.tpmcolor.lt.colors(j+1))then
     pmcolor=colors(j)
    end if
    if(tpmcolor.eq.colors(inlevel-1))then
     pmcolor=colors(inlevel-1)
    end if
   end do
   add_markers(wks,map,llon(i),llat(i),"Black",14,0.012,2.5)
   add_markers(wks,map,llon(i),llat(i),pmcolor,16,0.01,1.0)
  end do   ; END OF I LOOP
  delete(location)
  delete(ppm)
  delete(sstate)
  delete(ccounty)
  delete(ssite)
  delete(llat)
  delete(llon)

  vcid = gsn_csm_vector(wks, u(0,:,:), v(0,:,:), resvc)
  zid  = gsn_csm_contour(wks, z_plane, resz)
  pmid = gsn_csm_contour(wks, pm25(0,:,:), res)
  overlay(map, vcid)
  overlay(map, pmid)
  overlay(map, zid)
  draw(map)

; SET UP THE RESOURCES FOR LINE PLOT
  pres                  = True           ; polyline mods desired
  pres@gsLineThicknessF = 5.0            ; line thickness
  pres@gsLineColor      = "red"          ; color of lines
  qres                  = True           ; polyline mods desired
  qres@gsLineThicknessF = 5.0            ; line thickness
  qres@gsLineColor      = "red"          ; color of lines
  gsn_polyline(wks, map, lonhh, lathh, qres)
 ;gsn_polyline(wks, map, aslonn1, slatn, pres)
  delete(res)
  delete(resz)
  delete(resvc)
  frame(wks)
  delete(sspm25h)
  delete(sspm25h2)
  delete(sspth)
  delete(sspth2)
  delete(sspblh)
  delete(sspblh2)
  delete(sslatn)
  delete(sslonn)
  delete(dis)
 end if ; END OF IF IN IS NOT EQUAL TO 0
  delete(slathh)
  delete(slonhh)
  delete(rsech)
  delete(rssfch)
  delete(rsclfh)
 end if ; END OF IF ndimh LOOP
  delete(lath)
  delete(lathh)
  delete(lonh)
  delete(lonhh)
  delete(ech)
  delete(qch)
  delete(clfh)
  delete(aodh)
  delete(clfh1)
  delete(sfch)
  delete(sfch1)
  delete(sech)
  delete(sclfh)
  delete(saodh)
  delete(ssfch)
  delete(indexh)
  print("END TIME : ")
  system("date")
 end do ; END OF IH LOOP
end
