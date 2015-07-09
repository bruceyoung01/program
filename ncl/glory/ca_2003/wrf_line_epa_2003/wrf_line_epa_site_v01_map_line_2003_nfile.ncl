
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
; type = "x11"
  type = "pdf"
; type = "ps"
; type = "ncgm"
; type = "png"
  wks = gsn_open_wks(type,"1plt_wrf_line_pm25_i_2003-0321_0328_zhang")
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

; SET UP THE DESIRED MODS FOR THE MAP AND PLOT
  res = True
  res@xyDashPatterns   = (/15,0,1,2,3/)
  res@xyMarkLineModes  = (/"Markers","Lines","Lines","Lines","Lines"/)
  res@xyMarkers        = (/16/)
  res@xyMarkerSizes    = (/6/)
  res@xyMarkerColors   = (/"Blue"/)
  res@xyLineColors     = (/"Blue","Red"/)
  res@xyLineThicknessF = 2
  res@trYMaxF          = 120
  res@trYMinF          = 0

; SET LEGEND
  res@pmLegendDisplayMode    = "Always"              ; turn on legend
  res@pmLegendSide           = "Top"                 ; Change location of 
  res@pmLegendParallelPosF   = 0.20                  ; move units right
  res@pmLegendOrthogonalPosF = -0.3                  ; more neg = down

  res@pmLegendWidthF         = 0.12                  ; Change width and
  res@pmLegendHeightF        = 0.12                  ; height of legend.
  res@lgLabelFontHeightF     = 0.015                 ; change font height
  res@lgPerimOn              = False                 ; no box around

; LABELS FOR THE LEGEND
  res@xyExplicitLegendLabels = (/" EPA"," WRF/CHEM"," G"," M"," USG"/)

; SET TITLE RESOURCES
  res@tiXAxisString = "Date (day)"
  res@tiYAxisString = "PM2.5 Mass Concentration (~F33~m~F0~g/m~S~3~N~)"

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
; SET X AXIS LABELS  
  nxtick_interval     = 2
  xtick               = (/"March22", "24", "26", "28", "30"/)
; xtick               = (/"April20", "21", "22", "23", "24", "25", "26", "27", "28", \
;                        "29", "30", "May1", "2", "3", "4", "5", "6", "7", "8", "9",\
;                        "10", "11", "12", "13", "14", "15", "16", "17", "18"/)
  res1@tmXBMode       = "Explicit"
  res1@tmXBValues     = ispan(1,nfile,nhour*nxtick_interval)
  res1@tmXBLabels     = xtick(0:floattoint((tday/nxtick_interval)))

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
tppm(2,:) = 15
tppm(3,:) = 40
tppm(4,:) = 65

draw(mpplot)
plot = gsn_csm_xy(wks,x,tppm,res1)
frame(wks)
delete(tppm)
delete(eppm)
delete(lppm)
delete(res1)
delete(polyres)
end do ; END OF IS LOOP
end

