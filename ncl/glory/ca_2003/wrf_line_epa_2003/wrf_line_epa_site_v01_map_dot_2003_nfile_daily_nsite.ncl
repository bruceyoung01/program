
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PURPOSE OF THIS PROGRAM : 
; PLOT THE RELATIONSHIP BETWEEN SIMULATION AND EPA GROUND_BASED 
; OBSERVATION
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm_epa.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin

;-----------------------EPA SITES-------------------------------------
; READ EPA DATA
  fdir      = "/home/bruce/program/idl/smoke/2003_jw/2003_processed/"
  fnamelist = "filelist45_tx" ; USER SPECIFY
  fname     = asciiread(fdir+fnamelist,-1,"string")
  nfname    = dimsizes(fname)

  ncolumn   = 31
; THE NUMBER OF DAYS IN APRIL AND MAY
  nday4     = 30 ; USER SPECIFY
  nday5     = 31 ; USER SPECIFY
; THE NUMBER OF COLUMNS OF THE LINE OF LATITUDE AND LONGITUDE
  nll       = 8
; TOTAL NUMBER OF EPA SITES IN ONE MONTH
  nsites    = 51
  ll        = new((/nll, nfname/),float,999)
  epa       = new((/nday4+nday5, ncolumn, nfname/),float,999)
  do i = 0, nfname-1
   if(i.le.nsites-1)then
   lldata1  = readAsciiTable(fdir+fname(i), 1, "string", (/1,nday4+2/))
   do k = 0, nll-1
    ll(k,i) = stringtofloat(str_get_field(lldata1, k, " "))
   end do
   end if
   if(i.gt.nsites-1)then
   lldata2  = readAsciiTable(fdir+fname(i), 1, "string", (/1,nday5+2/))
   do k = 0, nll-1
    ll(k,i) = stringtofloat(str_get_field(lldata2, k, " "))
   end do
   end if
   fdata    = readAsciiTable(fdir+fname(i), 1, "string", (/4,0/))
   if(i.le.nsites-1)then
   do j = 0, ncolumn-1
    epa(0:nday4-1,j,i) = stringtofloat(str_get_field(fdata, j+1, " "))
   end do
   end if
   if(i.gt.nsites-1)then
   do j = 0, ncolumn-1
    epa(nday4:(nday4+nday5-1),j,i) = stringtofloat(str_get_field(fdata, j+1, " "))
   end do
   end if
   delete(fdata)
  end do

; OPEN WRF/CHEM OUTPUT FILES
; LIST THE NC FILES AND READ NC FILES
  files  = systemfunc("ls /home/bruce/sshfs/pfw/model/wrfchem3/WRFV311/test/em_real/wrfout/*.nc")
  a      = addfiles(files,"r")
  nhour  = 24
  start_day = 20 ; April 20 2003  USER SPECIFY
  left_day  = nday4-start_day ; CALCULATE THE NUMBER OF LAFT DAY IN THIS MONTH (April)
  ListSetType(a, "join")

; OPEN A WORKSTATION AND CHOOSE COLORMAP
  type = "x11"
; type = "pdf"
; type = "ps"
; type = "ncgm"
; type = "png"
  wks = gsn_open_wks(type,"1plt_wrf_dot_pm25_i_2003-0420_0519_zhang_daily_nsite_v09")
  gsn_define_colormap(wks,"BlAqGrYeOrReVi200")

; SET UP MAP RESOURCES
  mpres = True
  mpres@mpFillOn = False ; TURN OFF GRAY FILL
  mpres@mpOutlineBoundarySets = "USStates" ; TURN ON STATES BOUNDARY
; SET UP THE POSITION OF THE MAP
  mpres@vpWidthF = 0.2
  mpres@vpHeightF= 0.2
  mpres@vpXF     = 0.55
  mpres@vpYF     = 0.8
; SET UP THE RANGE OF MAP
  mpres@mpMaxLatF =  37 ; MAXIMUM LATITUDE
  mpres@mpMinLatF =  25 ; MINIMUM LATITUDE
  mpres@mpMaxLonF = -93 ; MAXIMUM LONGITUDE
  mpres@mpMinLonF = -107; MINIMUM LONGITUDE
  mpplot = gsn_csm_map_ce(wks, mpres)

; SET RESOURCES FOR SCATTER PLOT
  res = True
  res@tiMainString      = "PM2.5 Mass Concentration"
  res@xyDashPatterns    = 1
  res@xyMarkLineModes   = (/"Markers","Lines"/)
  res@xyMarkers         = 16
  res@xyMarkerSizes     = 6
  res@xyMarkerColors    = "Blue"
  res@xyLineThicknesses = (/1,2/)
  res@trXMaxF           = 50
  res@trXMinF           = 0
  res@trYMaxF           = 50
  res@trYMinF           = 0

; SET TITLE RESOURCES
  res@tiYAxisString = "EPA Observation (~F33~m~F0~g/m~S~3~N~)"
  res@tiXAxisString = "WRF/CHEM Simulation (~F33~m~F0~g/m~S~3~N~)"


; READ PM2.5 DATA FROM WRF/CHEM OUTPUT FILE AND SET XLAT AND XLONG AS THE ATTRIBUTE OF PM25
  times      = a[:]->Times(:,0,:)
  pm25       = a[:]->PM2_5_DRY(:,0,1,:,:)
  pm25@lat2d = a[:]->XLAT(:,0,:,:)
  pm25@lon2d = a[:]->XLONG(:,0,:,:)
  wlat       = a[:]->XLAT(:,0,:,:)
  wlon       = a[:]->XLONG(:,0,:,:)
  ncount     = dimsizes(times)
  nfile      = ncount(0)
  tday       = floattoint(nfile/nhour)
  avgeppm    = new((/nsites,tday/),float,-999)
  avglppm    = new((/nsites,tday/),float,-999)
  ttppm      = new((/2,tday/),float,-999)
  attppm     = new((/2,nsites*tday/),float,-999)
  aattppm    = new((/2,nsites*tday/),float,-999)
  eppm       = new((/nfile/),float,-999)
  lppm       = new((/nfile/),float,-999)
  eppma      = new((/nsites,tday/),float,-999)
  lppma      = new((/nsites,tday/),float,-999)
  eppma2     = new((/nsites,tday/),float,-999)
  lppma2     = new((/nsites,tday/),float,-999)
  elppm      = new((/nsites,tday/),float,-999)
  seppm      = new((/nhour/),float,-999)
  slppm      = new((/nhour/),float,-999)
  srel       = new((/nsites/),float,-999)

; DO I SPECIFIED SITE
  do is = 0, nsites-1
  isp = 0
; SET UP POLY MARKERS
  polyres = True
  polyres@gsMarkerColor = "Red"
  polyres@gsMarkerIndex = 16 ; POLYMARKER STYLE
  polyres@gsMarkerSizeF = 10.; POLYMARKER SIZE
  pplot = gsn_add_polymarker(wks, mpplot, ll(6,is), ll(5,is),polyres)

; DO THE FILE LOOP
  do ifile = 0, tday-1

; DO TIME LOOP
  do it = 0, nhour-1

; PM25 DATA AT THE SPECIFIED TIME
   index   = ind(ll(5,is).eq.ll(5,:))
   if(dimsizes(index) .le. 2)then
   if(ifile .le. left_day)then
   ppm     = epa(start_day+ifile-1,it+1,index(0))
   end if
   if(ifile .gt. left_day)then
   ppm     = epa(start_day+ifile-1,it+1,index(1))
   end if
   end if
   if(dimsizes(index) .gt. 2 .and. dimsizes(index) .le. 4)then
   if(ifile .le. left_day)then
   ppm     = epa(start_day+ifile-1,it+1,index(0))
   end if
   if(ifile .gt. left_day)then
   ppm     = epa(start_day+ifile-1,it+1,index(2))
   end if
   end if
   if(dimsizes(index) .gt. 4)then
   if(ifile .le. left_day)then
   ppm     = epa(start_day+ifile-1,it+1,index(0))
   end if
   if(ifile .gt. left_day)then
   ppm     = epa(start_day+ifile-1,it+1,index(3))
   end if
   end if

   dim       = dimsizes(wlat)
   ss        = 0
   eppm(isp) = ppm(0)
   do j=0,dim(1)-2
    do k=0,dim(2)-2
     if(ll(5,is).gt.wlat((it+nhour*ifile),j,k).and.ll(5,is).lt.wlat((it+nhour*ifile),j+1,k+1).and. \
        ll(6,is).gt.wlon((it+nhour*ifile),j,k).and.ll(6,is).lt.wlon((it+nhour*ifile),j+1,k+1).and. \
        pm25((it+nhour*ifile),j,k).gt.0.0)
        lppm(isp) = pm25((it+nhour*ifile), j, k)
        print("NUMBER OF POINTS = "+isp)
      end if
     end do ; END OF K LOOP
    end do ; END OF J LOOP
   isp = isp+1
   delete(index)
   delete(ppm)
  end do ; END OF IT LOOP
 end do ; END OF IFILE LOOP
 do i = 0, tday-1
  seppm(:)   = eppm((0+i*nhour):(23+i*nhour))
  slppm(:)   = lppm((0+i*nhour):(23+i*nhour))
  avgeppm(is,i) = avg(seppm)
  avglppm(is,i) = avg(slppm)
 end do
 aavgeppm  = avg(avgeppm(is,:))
 aavglppm  = avg(avglppm(is,:))
 stdeppm   = dim_stddev_n(avgeppm(is,:), 0)
 stdlppm   = dim_stddev_n(avglppm(is,:), 0)
 rc        = regline(avglppm(is,:),avgeppm(is,:))
 ttppm(0,:)= avgeppm(is,:)
 ttppm(1,:)= rc*(avglppm(is,:)-rc@xave) + rc@yave

; CALCULATE CORRELATION COEFFICIENT BETWEEN TWO ARRAYS
  do i = 0, tday-1
   eppma(is,i) = avgeppm(is,i)-aavgeppm
   lppma(is,i) = avglppm(is,i)-aavglppm
   eppma2(is,i)= (avgeppm(is,i)-aavgeppm)^2
   lppma2(is,i)= (avglppm(is,i)-aavglppm)^2
   elppm(is,i) = eppma(is,i)*lppma(is,i)
  end do
 srel(is)      = sum(elppm(is,:))/sqrt(sum(eppma2(is,:))*sum(lppma2(is,:)))


; SET UP TEXT RESOURCES
 tres = True
 tres@txFontHeightF = 0.015
 gsn_text_ndc(wks,"y = ", 0.25, 0.7, tres)
 gsn_text_ndc(wks,sprintf("%5.3f", rc), 0.32, 0.7, tres)
 gsn_text_ndc(wks,"x + ", 0.39, 0.7, tres)
 gsn_text_ndc(wks,sprintf("%5.3f", rc@yave-rc*rc@xave), 0.46, 0.7, tres)
 gsn_text_ndc(wks,"R = ", 0.25, 0.68, tres)
 gsn_text_ndc(wks,sprintf("%5.3f", srel(is)), 0.32, 0.68, tres)
 gsn_text_ndc(wks,"n = ", 0.25, 0.66,tres)
 gsn_text_ndc(wks,rc@nptxy, 0.28, 0.66,tres)
 gsn_text_ndc(wks,"EPA: ", 0.26, 0.64,tres)
 gsn_text_ndc(wks,sprintf("%5.3f", aavgeppm), 0.33, 0.64,tres)
 gsn_text_ndc(wks,"~F34~1", 0.38, 0.64,tres)
 gsn_text_ndc(wks,sprintf("%5.3f", stdeppm), 0.43, 0.64,tres)
 gsn_text_ndc(wks,"WRFCHEM: ", 0.29, 0.62,tres)
 gsn_text_ndc(wks,sprintf("%5.3f", aavglppm), 0.39, 0.62,tres)
 gsn_text_ndc(wks,"~F34~1", 0.44, 0.62,tres)
 gsn_text_ndc(wks,sprintf("%5.3f", stdlppm), 0.49, 0.62,tres)
 draw(mpplot)
 plot = gsn_csm_xy(wks,avglppm(is,:),ttppm,res)
 frame(wks)
 delete(tres)
 delete(polyres)
 end do ; END OF IS LOOP

; WRITE OUT THE CORRELATION TO A FILE
 asciiwrite("texas_correlation_sst", srel)
 asciiwrite("texas_lat_sst", ll(5, :))
 asciiwrite("texas_lon_sst", ll(6, :))

; PLOT THE CORRELATION OF ALL THE SITES
; CALCULATE CORRELATION COEFFICIENT BETWEEN TWO ARRAYS
 aaavgeppm  = avg(avgeppm)
 aaavglppm  = avg(avglppm)
 do is = 0, nsites-1
  do i = 0, tday-1
   aattppm(0,i+tday*is) = avglppm(is,i)
   aattppm(1,i+tday*is) = avgeppm(is,i)
  end do
 end do
 astdlppm   = dim_stddev_n(aattppm(0,:), 0)
 astdeppm   = dim_stddev_n(aattppm(1,:), 0)

 arc        = regline(aattppm(0,:),aattppm(1,:))

 do is = 0, nsites-1
  do i = 0, tday-1
   attppm(0,i+tday*is) = avgeppm(is,i)
   attppm(1,i+tday*is) = arc*(avglppm(is,i)-arc@xave) + arc@yave
   eppma(is,i) = avgeppm(is,i)-aaavgeppm
   lppma(is,i) = avglppm(is,i)-aaavglppm
   eppma2(is,i)= (avgeppm(is,i)-aaavgeppm)^2
   lppma2(is,i)= (avglppm(is,i)-aaavglppm)^2
   elppm(is,i) = eppma(is,i)*lppma(is,i)
  end do
 end do
 asrel          = sum(elppm)/sqrt(sum(eppma2)*sum(lppma2))


; SET UP TEXT RESOURCES
 tres = True
 tres@txFontHeightF = 0.015
 gsn_text_ndc(wks,"y = ", 0.25, 0.7, tres)
 gsn_text_ndc(wks,sprintf("%5.3f", arc), 0.32, 0.7, tres)
 gsn_text_ndc(wks,"x + ", 0.39, 0.7, tres)
 gsn_text_ndc(wks,sprintf("%5.3f", arc@yave-arc*arc@xave), 0.46, 0.7, tres)
 gsn_text_ndc(wks,"R = ", 0.25, 0.68, tres)
 gsn_text_ndc(wks,sprintf("%5.3f", asrel), 0.32, 0.68, tres)
 gsn_text_ndc(wks,"n = ", 0.25, 0.66,tres)
 gsn_text_ndc(wks,arc@nptxy, 0.28, 0.66,tres)
 gsn_text_ndc(wks,"EPA: ", 0.26, 0.64,tres)
 gsn_text_ndc(wks,sprintf("%5.3f", aaavgeppm), 0.33, 0.64,tres)
 gsn_text_ndc(wks,"~F34~1", 0.38, 0.64,tres)
 gsn_text_ndc(wks,sprintf("%5.3f", astdeppm), 0.43, 0.64,tres)
 gsn_text_ndc(wks,"WRFCHEM: ", 0.29, 0.62,tres)
 gsn_text_ndc(wks,sprintf("%5.3f", aaavglppm), 0.39, 0.62,tres)
 gsn_text_ndc(wks,"~F34~1", 0.44, 0.62,tres)
 gsn_text_ndc(wks,sprintf("%5.3f", astdlppm), 0.49, 0.62,tres)
 plot = gsn_csm_xy(wks,aattppm(0,:),attppm,res)
 frame(wks)

end

