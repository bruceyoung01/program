
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
; SPECIFY THE LATITUDE AND LONGITUDE OF THE SELECTED SITE

  slat = (/32.769169, 26.225555,  29.275278, 30.483610, \
           29.733889, 31.768333, 35.209999/) ; USER SPECIFY
  slon = (/-96.546112, -98.291389, -98.311668, -97.872223, \
           -95.257500, -106.501389, -101.831947/) ; USER SPECIFY
;  slat = (/32.769169, 26.225555, 25.891111, 29.275278, 30.483610, \
;           29.733889, 31.768333, 35.209999/) ; USER SPECIFY
;  slon = (/-96.546112, -98.291389, -97.493889, -98.311668, -97.872223, \
;           -95.257500, -106.501389, -101.831947/) ; USER SPECIFY

; READ EPA DATA
  fdir      = "/home/bruce/program/idl/smoke/2003_jw/2003_processed/"
  fnamelist = "filelist34_tx" ; USER SPECIFY
  fname     = asciiread(fdir+fnamelist,-1,"string")
  nfname    = dimsizes(fname)

  ncolumn   = 31
; THE NUMBER OF DAYS IN APRIL AND MAY
  nday4     = 31 ; USER SPECIFY
  nday5     = 30 ; USER SPECIFY
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
  files  = systemfunc("ls /media/disk/data/wrfchem/2003_ca_60_24/*.nc")
  a      = addfiles(files,"r")
  nhour = 24
  start_day = 21 ; March 21 2003  USER SPECIFY
  ListSetType(a, "join")

; OPEN A WORKSTATION AND CHOOSE COLORMAP
  type = "x11"
; type = "pdf"
; type = "ps"
; type = "ncgm"
; type = "png"
  wks = gsn_open_wks(type,"1plt_wrf_dot_pm25_i_2003-0421_0424_zhang")
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
  res@xyDashPattern = 0
  res@xyMarkLineMode= "Markers"
  res@xyMarkers     = 16
  res@xyMarkerSizes = 6
  res@xyMarkerColors= "Blue"
  res@trXMaxF       = 50
  res@trXMinF       = 0
  res@trYMaxF       = 50
  res@trYMinF       = 0

; SET TITLE RESOURCES
  res@tiXAxisString = "EPA Observation (~F33~m~F0~g/m~S~3~N~)"
  res@tiYAxisString = "WRF/CHEM Simulation (~F33~m~F0~g/m~S~3~N~)"


; DO I SPECIFIED SITE
  do is=0,dimsizes(slat)-1
; READ PM2.5 DATA FROM WRF/CHEM OUTPUT FILE AND SET XLAT AND XLONG AS THE ATTRIBUTE OF PM25
   times      = a[:]->Times(:,0,:)
   pm25       = a[:]->PM2_5_DRY(:,0,0,:,:)
   pm25@lat2d = a[:]->XLAT(:,0,:,:)
   pm25@lon2d = a[:]->XLONG(:,0,:,:)
   wlat       = a[:]->XLAT(:,0,:,:)
   wlon       = a[:]->XLONG(:,0,:,:)
   ncount     = dimsizes(times)
   nfile      = ncount(0)
   tday       = floattoint(nfile/nhour)
   print(tday)
  isp   = 0
  x     = ispan(1,nfile,1)
  tppm  = new((/5,nfile/),float,-999)
  ttppm = new((/2,nfile/),float,-999)
  eppm  = new((/nfile/),float,-999)
  lppm  = new((/nfile/),float,-999)
  eppma = new((/nfile/),float,-999)
  lppma = new((/nfile/),float,-999)
  eppma2= new((/nfile/),float,-999)
  lppma2= new((/nfile/),float,-999)
  elppm = new((/nfile/),float,-999)
  tppm@_FillValue=-999
  eppm@_FillValue=-999
  lppm@_FillValue=-999
  res1  = True
  res1  = res
  res1@tiMainString   = "PM2.5 Mass Concentration"
  res1@xyDashPatterns = 1
  res1@xyMarkLineModes= (/"Markers","Lines"/)
  res1@xyMarkers      = 16
  res1@xyMarkerSizes  = 6
  res1@xyMarkerColors = "Blue"
  res1@xyLineThicknesses = (/1,2/)

; SET UP POLY MARKERS
  polyres = True
  polyres@gsMarkerColor = "Red"
  polyres@gsMarkerIndex = 16 ; POLYMARKER STYLE
  polyres@gsMarkerSizeF = 10.; POLYMARKER SIZE
  pplot = gsn_add_polymarker(wks, mpplot, slon(is), slat(is),polyres)

; DO THE FILE LOOP
  do ifile = 0, tday-1

; DO TIME LOOP
  do it = 0, nhour-1

; PM25 DATA AT THE SPECIFIED TIME
   index   = ind(slat(is).eq.ll(5,:))
   if(dimsizes(index) .le. 2)then
   if(ifile.le.10)then
   ppm     = epa(start_day+ifile-1,it+1,index(0))
   end if
   if(ifile.gt.10)then
   ppm     = epa(start_day+ifile-1,it+1,index(1))
   print(index)
   print(epa(start_day+ifile-1,it+1,index(1)))
   end if
   end if
   if(dimsizes(index) .gt. 2 .and. dimsizes(index) .le. 4)then
   if(ifile.le.10)then
   ppm     = epa(start_day+ifile-1,it+1,index(0))
   end if
   if(ifile.gt.10)then
   ppm     = epa(start_day+ifile-1,it+1,index(2))
   print(index)
   print(epa(start_day+ifile-1,it+1,index(1)))
   end if
   end if
   if(dimsizes(index) .gt. 4)then
   if(ifile.le.10)then
   ppm     = epa(start_day+ifile-1,it+1,index(0))
   end if
   if(ifile.gt.10)then
   ppm     = epa(start_day+ifile-1,it+1,index(3))
   print(index)
   print(epa(start_day+ifile-1,it+1,index(1)))
   end if
   end if

   dim     = dimsizes(wlat)
   ss      = 0
   eppm(isp) = ppm(0)
   do j=0,dim(1)-2
    do k=0,dim(2)-2
     if(slat(is).gt.wlat((it+nhour*ifile),j,k).and.slat(is).lt.wlat((it+nhour*ifile),j+1,k+1).and. \
        slon(is).gt.wlon((it+nhour*ifile),j,k).and.slon(is).lt.wlon((it+nhour*ifile),j+1,k+1).and. \
        pm25((it+nhour*ifile),j,k).gt.0.0)
        lppm(isp) = pm25((it+nhour*ifile), j, k)
        print("NUMBER OF POINTS = "+isp)
;        print(slat(is))
;        print(slon(is))
      end if
     end do ; END OF K LOOP
    end do ; END OF J LOOP
;   print(eppm(isp))
;   print(lppm(isp))
;   print(ifile)
;   print(it)
   isp = isp+1
   delete(index)
   delete(ppm)
  end do ; END OF IT LOOP
 end do ; END OF IFILE LOOP
tppm(0,:) = eppm(:)
tppm(1,:) = lppm(:)
avgeppm   = avg(eppm)
avglppm   = avg(lppm)
stdeppm   = dim_stddev_n(eppm, 0)
stdlppm   = dim_stddev_n(lppm, 0)
tppm!0    = "EPA"
tppm!1    = "WRFCHEM"
ecr       = esccr(eppm,lppm,0)
prob      = rtest(ecr,nfile,0)
rc        = regline(eppm,lppm)
ttppm(0,:)= lppm(:)
ttppm(1,:)= rc*(eppm-rc@xave) + rc@yave

; CALCULATE CORRELATION COEFFICIENT BETWEEN TWO ARRAYS
  do i = 0, nfile-1
   eppma(i) = eppm(i)-avgeppm
   lppma(i) = lppm(i)-avglppm
   eppma2(i)= (eppm(i)-avgeppm)^2
   lppma2(i)= (lppm(i)-avglppm)^2
   elppm(i) = eppma(i)*lppma(i)
  end do
srel        = sum(elppm)/sqrt(sum(eppma2)*sum(lppma2))


; SET UP TEXT RESOURCES
tres = True
tres@txFontHeightF = 0.015
gsn_text_ndc(wks,"y = ", 0.25, 0.7, tres)
gsn_text_ndc(wks,sprintf("%5.3f", rc), 0.32, 0.7, tres)
gsn_text_ndc(wks,"x + ", 0.39, 0.7, tres)
gsn_text_ndc(wks,sprintf("%5.3f", rc@yave-rc*rc@xave), 0.46, 0.7, tres)
gsn_text_ndc(wks,"R = ", 0.25, 0.68, tres)
gsn_text_ndc(wks,sprintf("%5.3f", srel), 0.32, 0.68, tres)
gsn_text_ndc(wks,"n = ", 0.25, 0.66,tres)
gsn_text_ndc(wks,rc@nptxy, 0.28, 0.66,tres)
gsn_text_ndc(wks,"EPA: ", 0.26, 0.64,tres)
gsn_text_ndc(wks,sprintf("%5.3f", avgeppm), 0.33, 0.64,tres)
gsn_text_ndc(wks,"~F34~1", 0.38, 0.64,tres)
gsn_text_ndc(wks,sprintf("%5.3f", stdeppm), 0.43, 0.64,tres)
gsn_text_ndc(wks,"WRFCHEM: ", 0.29, 0.62,tres)
gsn_text_ndc(wks,sprintf("%5.3f", avglppm), 0.39, 0.62,tres)
gsn_text_ndc(wks,"~F34~1", 0.44, 0.62,tres)
gsn_text_ndc(wks,sprintf("%5.3f", stdlppm), 0.49, 0.62,tres)
draw(mpplot)
plot = gsn_csm_xy(wks,eppm,ttppm,res1)
frame(wks)
delete(tppm)
delete(eppm)
delete(lppm)
delete(res1)
delete(tres)
delete(polyres)
end do ; END OF IS LOOP
end

