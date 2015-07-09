
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
  slat = (/32.5,32.8,27.8,30.3,29.9,29.7,29.4,31.8/)
  slon = (/-97.0,-96.9,-97.4,-97.7,-93.9,-95.4,-98.5,-106.4/)
  sname= (/"Tarrant","Dallas","Nueces","Travis","Jefferson","Harris","Bexar","El Paso"/)

; READ DATA INTO A BIG 1D STRING ARRAY
  fname ="/mnt/sdc/data/epa/epa_data/PM25_DATA/PM25_Simplified_Data/Simple_New_RD_501_88502_2008-0.txt"
  fname1="/mnt/sdc/data/epa/epa_data/PM25_DATA/PM25_Simplified_Data/Simple_new_site_monitor.txt"
  data=asciiread(fname,-1,"string")
  data1=asciiread(fname1,-1,"string") 

; COUNT THE NUMBER OF FIELDS, JUST TO SHOW IT CAN BE DONE
  nfields=str_fields_count(data(1)," ")
  print("number of fields = "+nfields) 
  nfields1=str_fields_count(data1(1)," ")
  print("number of fields1 = "+nfields1)
  
; SKIP THE FIRST ROW OF "DATA" BECAUSE IT'S JUST A HEADER LINE
; USE A SPACE(" ") AS A DELIMETER IN STR_GET_FIELD. THE FIRST FIELD
; IS FIELD=1 (UNLIKE STR_GET_COLS, IN WHICH THE FIRST COLUMN IS COLUMN=0)
  state  =stringtoint(str_get_field(data(1::),1," "))
  county =stringtoint(str_get_field(data(1::),2," "))
  site   =stringtoint(str_get_field(data(1::),3," "))
  yr     =stringtoint(str_get_field(data(1::),4," "))
  mn     =stringtoint(str_get_field(data(1::),5," "))
  dd     =stringtoint(str_get_field(data(1::),6," "))
  time   =stringtoint(str_get_field(data(1::),7," "))
  epapm25=stringtofloat(str_get_field(data(1::),8," "))
  
  astate =stringtoint(str_get_field(data1(1::),2," "))
  acounty=stringtoint(str_get_field(data1(1::),3," "))
  asite  =stringtoint(str_get_field(data1(1::),4," "))
  lat    =stringtofloat(str_get_field(data1(1::),5," "))
  lon    =stringtofloat(str_get_field(data1(1::),6," "))

; OPEN WRF/CHEM OUTPUT FILES
; LIST THE NC FILES AND READ NC FILES
  files  = systemfunc("ls /media/disk/data/wrfchem/200805_sepanf/*.nc")
  a      = addfiles(files,"r")
  nfiles = dimsizes(files)
  ncount = dimsizes(files)*24
  ListSetType(a, "join")

; OPEN A WORKSTATION AND CHOOSE COLORMAP
; type = "x11"
  type = "pdf"
; type = "ps"
; type = "ncgm"
; type = "png"
  wks = gsn_open_wks(type,"1plt_wrf_line_pm25_i_2008-05-01_14_sepanf_v01_daily_v01_1")
  gsn_define_colormap(wks,"BlAqGrYeOrReVi200")

; SET UP MAP RESOURCES
  mpres = True
  mpres@mpFillOn = False ; TURN OFF GRAY FILL
  mpres@mpOutlineBoundarySets = "USStates" ; TURN ON STATES BOUNDARY

; SET UP THE POSITION OF THE MAP
  mpres@vpWidthF = 0.2
  mpres@vpHeightF= 0.2
  mpres@vpXF     = 0.55
  mpres@vpYF     = 0.80

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
; SET X AXIS LABELS
  xtick              = (/"May3", "4", "5", "6", "9", "10", "12"/)
  res@tmXBMode       = "Explicit"
  res@tmXBValues     = ispan(1,ncount,24)
  res@tmXBLabels     = xtick(0:nfiles-1)
  res@trYMaxF        = 100
  res@trYMinF        = 0

; SET LEGEND
  res@pmLegendDisplayMode    = "Always"              ; turn on legend
  res@pmLegendSide           = "Top"                 ; Change location of 
  res@pmLegendParallelPosF   = .20                   ; move units right
  res@pmLegendOrthogonalPosF = -0.3                  ; more neg = down
 
  res@pmLegendWidthF         = 0.12                  ; Change width and
  res@pmLegendHeightF        = 0.12                  ; height of legend.
  res@lgLabelFontHeightF     = 0.015                 ; change font height
  res@lgPerimOn              = False                 ; no box around
; labels for the legend
  res@xyExplicitLegendLabels = (/" EPA"," WRF/CHEM"," G"," M"," USG"/)

; SET TITLE RESOURCES
  res@tiXAxisString = "Date (day)"
  res@tiYAxisString = "PM2.5 Mass Concentration (~F33~m~F0~g/m~S~3~N~)"

  x = ispan(1,ncount,24)

; DO I SPECIFIED SITE
  do is=0,dimsizes(slat)-1
  isp  =0
  tppm  = new((/5,nfiles/),float,-999)
  eppm  = new((/nfiles/),float,-999)
  lppm  = new((/nfiles/),float,-999)
  tppm@_FillValue=-999
  eppm@_FillValue=-999
  lppm@_FillValue=-999
  res2  = True
  res2  = res
  res2@tiMainString   = "PM2.5 Mass Concentration    "+ sname(is)

; SET UP POLY MARKERS
  polyres = True
  polyres@gsMarkerColor = "Red"
  polyres@gsMarkerIndex = 16 ; POLYMARKER STYLE
  polyres@gsMarkerSizeF = 10 ; POLYMARKER SIZE
  pplot = gsn_add_polymarker(wks, mpplot, slon(is), slat(is),polyres)

; DO THE FILE LOOP
  do ifile = 0,nfiles-1
  seppm = 0.0
  slppm = 0.0
  nt    = 0

; DO TIME LOOP
  do it = 0, 23
   nt = nt + 1

; READ PM2.5 DATA FROM WRF/CHEM OUTPUT FILE AND SET XLAT AND XLONG AS THE ATTRIBUTE OF PM25
   times      = a[:]->Times(:,it,:)
   pm25       = a[:]->PM2_5_DRY(:,it,0,:,:)
   pm25@lat2d = a[:]->XLAT(:,it,:,:)
   pm25@lon2d = a[:]->XLONG(:,it,:,:)
   wlat       = a[:]->XLAT(:,it,:,:)
   wlon       = a[:]->XLONG(:,it,:,:)
 
; JUDGE IF THE THERE ARE EPA STATION OBSERVATION AT THIS TIME
   yyr=stringtoint(str_get_cols(times(ifile,:),0,3))
   mmn=stringtoint(str_get_cols(times(ifile,:),5,6))
   ddd=stringtoint(str_get_cols(times(ifile,:),8,9))
   ttime=stringtoint(str_get_cols(times(ifile,:),11,12)+"00")

; SELECT EPA  SITE DATA
; FIND THE INDEX THAT MATCHES THE SPECIFIED TIME
   locat=ind(mn.eq.mmn.and.dd.eq.ddd.and.time.eq.ttime)

; PM25 DATA AT THE SPECIFIED TIME
   ppm     = epapm25(locat)
   sstate  = state(locat)
   ccounty = county(locat)
   ssite   = site(locat)
   count   = dimsizes(ppm)
   index   = 0
   dim     = dimsizes(wlat)
   ss      = 0
   do i = 0, count-1
     index=ind(astate.eq.sstate(i) .and. \
               acounty.eq.ccounty(i) .and. \
               asite.eq.ssite(i))
     if(index.eq.0)then
       print("No Match Found")
     end if
     if(index.gt.0)then
        if(lat(index(0)).gt.slat(is)-0.2.and.lat(index(0)).lt.slat(is)+0.2.and. \
           lon(index(0)).gt.slon(is)-0.2.and.lon(index(0)).lt.slon(is)+0.2.and. \
           ppm(i).gt.0.0.and.ss.eq.0)then
        ss = ss+1
        seppm     = seppm + ppm(i)
       do j=0,dim(1)-2
        do k=0,dim(2)-2
         if(slat(is).gt.wlat(ifile,j,k).and.slat(is).lt.wlat(ifile,j+1,k+1).and. \
            slon(is).gt.wlon(ifile,j,k).and.slon(is).lt.wlon(ifile,j+1,k+1).and. \
            pm25(ifile,j,k).gt.0.0)
          slppm    = slppm + pm25(ifile,j,k)
          print("NUMBER OF POINTS = "+isp)
         end if
        end do ; END OF K LOOP
       end do ; END OF J LOOP
      end if
     end if
    end do ; END OF I LOOP
   delete(locat)
   delete(ppm)
   delete(sstate)
   delete(ccounty)
   delete(ssite)
   delete(count)
  end do ; END OF IT LOOP
  eppm(ifile) = seppm/nt
  lppm(ifile) = slppm/nt
 end do ; END OF IFILE LOOP
tppm(0,:) = eppm(:)
tppm(1,:) = lppm(:)
tppm(2,:) = 15
tppm(3,:) = 40
tppm(4,:) = 65
draw(mpplot)
plot=gsn_csm_xy(wks,x,tppm,res2)
frame(wks)
delete(tppm)
delete(eppm)
delete(lppm)
delete(res2)
end do ; END OF IS LOOP
end
