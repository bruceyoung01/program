;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PURPOSE OF THIS PROGRAM :                                                  ;
; (1) READ CALIPSO DATA, AND DEPENDING ON THE CALIPSO PATH TO SELECT THE SAME;
;     PATH FROM WRFCHEM OUTPUT FILE.                                         ;
; (2) PLOT THE VARTICLE PROFILE OF WRFCHEM                                   ;
; NOTE : CALIPSO DATA---CAL_LID_L1-ValStage1-V3-01                           ;
; BRUCE APRIL 05 2011                                                        ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm_epa.ncl"
  load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl" 
  load "/home/bruce/program/ncl/tutorial/test/wrf_contour_h/WRFUserARW.ncl"

; This procedure adds markers to a plot, making sure that each
; set is returned to a unique variable name, and that this
; variable is retained even outside this procedure call.
; 
procedure add_markers(wks,plot,x,y,color,type,size,thick)
local pmres, str
begin
  pmres = True
  pmres@gsMarkerColor = color
  pmres@gsMarkerIndex = type
  pmres@gsMarkerSizeF = size
  pmres@gsMarkerThicknessF=thick
  str = unique_string("polymarker")  ; "unique_string" will return a unique
                                     ; string every time it is called from
                                     ;  within a single NCL session.
; 
; You can then use this unique string as an attribute variable name
; that gets attached to the plot variable. This ensures that this
; value will live for the duration of the script.
;
  plot@$str$ = gsn_add_polymarker(wks, plot, x, y, pmres)
end 

begin

; READ THE CALIPSO HDF DATA
  dirh   = "/media/disk/data/calipso/2008/CAL_LID_L1-ValStage1-V3-01/ca/"
  fileh  = "CAL_LID_L1-ValStage1-V3-01.2008-05-08T08-18-52ZN.hdf"

  fh     = addfile(dirh+fileh, "r")
  tbks   = fh->Total_Attenuated_Backscatter_532
  lath   = fh->Latitude
  lonh   = fh->Longitude
  dimlath= dimsizes(lath)
  dimlonh= dimsizes(lonh)

; ASSIGN NEW 1 DIMENSIONAL ARRAY FOR LATITUDE AND LONGITUDE OF CALIPSO
  lathh  = lath(:,0)
  lonhh  = lonh(:,0)

; READ WRFCHEM OUTPUT NC FILE
; THIS NEEDS TO HAVE A ".nc" APPENDED
  dirn   = "/media/disk/data/wrfchem/ca200805_2_f/"
  filen  = "wrfout_d01_2008-05-08_00:00:00_1200sepaf.nc"

  fn     = addfile(dirn+filen, "r")
  atimes = fn->Times
  t      = 8
  atime  = atimes(t,:)
  print("WORKING ON TIME : " + atime)

  pm25n       = getvar(fn, "PM2_5_DRY", t)
  pblhn       = getvar(fn, "PBLH", t)
  ptn         = getvar(fn, "T", t)
  tcn         = getvar(fn, "tc", t)
  latn        = getvar(fn, "XLAT", t)
  lonn        = getvar(fn, "XLONG", t)
  zn          = getvar(fn, "z", t)
  pm25n@lat2d = latn
  pm25n@lon2d = lonn
  pm25n@units = "~F33~m~F0~g/m~S~3~N~"
  dimpm25n    = dimsizes(pm25n)
  pblhn@lat2d = latn
  pblhn@lon2d = lonn
  nleveln     = dimpm25n(0)
  nlatn       = dimpm25n(1)
  nlonn       = dimpm25n(2)

; DEFINE THE HEIGHT LEVELS
; MINIMUM HEIGHT, MAXIMUM HEIGHT, INTERVAL
  minh   = 0
  maxh   = 15
  inth   = 501
  height = fspan(minh, maxh, inth)

; SELECTED REGION FROM CALIPSO BASED ON WRFCHEM
  sstart = 5000
  send   = 18000

; DEFINE A NEW ARRAY FOR VERTICAL VARAIBLE
  pm25h  = new((/inth, nlatn,nlonn/),float,-999)
  pth    = new((/inth, nlatn,nlonn/),float,-999)

; DEFINE A NEW ARRAY FOR SELECTED VERTICAL VARAIBLE
  sn     = 189
  spm25h = new((/inth, sn/),float,-999)
  spth   = new((/inth, sn/),float,-999)
  spblh  = new((/sn/),float,-999)
  slatn  = new((/sn/),float,-999)
  slonn  = new((/sn/),float,-999)
  dis    = new((/sn/),float,-999)

; INTERPOLATE THE VARAIBLE TO THE VERTICAL PROFILE
  do ih = 0, inth-1
   pm25h(ih,:,:) = wrf_user_intrp3d(pm25n, zn, "h", height(ih)*1000, 0., False)
   pth(ih,:,:)   = wrf_user_intrp3d(ptn, zn, "h", height(ih)*1000, 0., False)
  end do

; SELECT THE SAME POINTS OF WRFCHEM AS CALIPSO
  maxlatn = max(latn)
  minlatn = min(latn)
  maxlonn = max(lonn)
  minlonn = min(lonn)

  in = 0
; DO LATITUDE AND LONGITUDE LOOP OF WRFCHEM
  do ilatn = nlatn-2, 0, 1
   do ilonn = nlonn-2, 0, 1
; DO LATITUDE AND LONGITUDE LOOP OF CALIPSO
    k = 0
     do ilath = sstart, send
      if (lath(ilath,0) .ge. minlatn .and. lath(ilath,0) .le. maxlatn .and. \
          lonh(ilath,0) .ge. minlonn .and. lonh(ilath,0) .le. maxlonn .and. \
          k .eq. 0)then
       if (lath(ilath,0) .ge. latn(ilatn,ilonn) .and. \
           lath(ilath,0) .le. latn(ilatn+1,ilonn+1) .and. \
           lonh(ilath,0) .ge. lonn(ilatn,ilonn) .and. \
           lonh(ilath,0) .le. lonn(ilatn+1,ilonn+1))then
        spm25h(:,in)  = pm25h(:,ilatn,ilonn)
        spth(:,in)    = pth(:,ilatn,ilonn)
        print(pblhn(ilatn,ilonn))
        spblh(in)     = pblhn(ilatn,ilonn)
        print(spblh(in))
        slatn(in)     = latn(ilatn,ilonn)
        slonn(in)     = lonn(ilatn,ilonn)
        in = in+1
        k = k+1
        print("AAAA : "+ilath)
        print("THE NUMBER OF SELECTED POINTS : "+in)
       end if
      end if
     end do ; ilath
   end do ; ilonn
  end do ; ilatn

; CALCULATE THE DISTANCE BETWEEN THE POINT AND THE FIRST POINT
  do id = 0, in-2
   dis(id) = gc_latlon(slatn(0),slonn(0),slatn(id),slonn(id),2,-3)
  end do ; id

; FORMATED OF LATITUDE AND LONGITUDE
  asciiwrite("wslatn.txt",sprintf("%5.2f",slatn))
  asciiwrite("wslonn.txt",sprintf("%7.2f",slonn))
  rslatn = asciiread("wslatn.txt",-1,"float")
  rslonn = asciiread("wslonn.txt",-1,"float")

; SET UP THE PLOT PLATFORM
  type = "x11"
; type = "pdf"
; type = "ps"
; type = "ncgm"
; type = "png"
  wks  = gsn_open_wks(type, "1plt_contour_h_calipso_2008-05-08_5")
  gsn_define_colormap(wks,"BlAqGrYeOrReVi200")


; PLOT THE VERTICAL PROFILE OF WRFCHEM BASED ON CALIPSO
; SET UP RESOURCES
  cres                 = True
  cres@cnFillOn        = True
; TURN OFF CONTOUR LINES
  cres@cnLinesOn       = False
; TURN OFF CONTOUR LABELS
  cres@cnLineLabelsOn  = False
  cres@gsnSpreadColors = True
  cres@sfXArray        = dis
  cres@sfYArray        = height
  cres@trYMaxF         = maxh
  cres@trYMinF         = minh
; SET UP AXIS LABEL FOR CONTOUR PLOT
  cres@tmXBMode        = "Explicit"
  cres@tmXBValues      = fspan(0.,(sn-1),6)
  cres@tmXBLabels      = flt2string(rslatn(0:(sn-1):37))+"/"+flt2string(rslonn(0:(sn-1):37))
  cres@tmXBFontThicknessF = 0.5
  cres@tiXAxisString   = "Latitude/Longitude"
  cres@tiYAxisString   = "Altitude (km)"
  cres@tiMainString    = "WRF/CHEM  CALISPO    " + atime
; SET UP AXIS LABEL FOR XY PLOT
  lres                 = True
  lres@sfXArray        = dis
  lres@tmXBMode        = "Explicit"
  lres@tmXBValues      = fspan(0.,(sn-1),6)
  lres@tmXBLabels      = flt2string(rslatn(0:(sn-1):37))+"/"+flt2string(rslonn(0:(sn-1):37))
  lres@tmXBFontThicknessF = 0.5
  lres@tiXAxisString   = "Latitude/Longitude"
  lres@tiYAxisString   = "Altitude (km)"
  lres@tiMainString    = "WRF/CHEM  CALISPO    " + atime

; SET UP LABEL BAR
  cres@pmLabelBarWidthF       = 0.05
  cres@pmLabelBarHeightF      = 0.3 
  cres@lbLabelFontHeightF     = 0.01
  cres@lbLabelStride          = 1
  cres@lbBoxLinesOn           = False
  cres@lbOrientation          = "Vertical"
  cres@lbLabelPosition        = "Right"

; SET UP COLOR BAR
;  cres@tiMainFontHeightF      = 0.02
;  cres@lbTitleString          = "PM2.5 SURFACE MASS CONCENTRATION (~F33~m~F0~g/m~S~3~N~)"
;  cres@lbTitleFontHeightF     = 0.015 
;  cres@lbTitlePosition        = "Right"

; SET UP THE POSITION OF THE CONTOUR PLOT
  cres@vpWidthF                = 0.7
  cres@vpHeightF               = 0.3
  cres@vpXF                    = 0.15
  cres@vpYF                    = 0.7

; SET UP THE POSITION OF THE XY PLOT
  lres@vpWidthF                = 0.7
  lres@vpHeightF               = 0.3
  lres@vpXF                    = 0.15
  lres@vpYF                    = 0.7

  plot = gsn_csm_contour(wks, spm25h, cres)
  plot = gsn_csm_contour(wks, spth, cres)
  plot = gsn_csm_xy(wks, dis, spblh, lres)

; PLOT THE CALIPSO PATH ON WRFCHEM LEVEL IMAGE
;-----------------------EPA SITES-------------------------------------
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

; SET UP THE LEVEL IMAGE
; The specific pressure levels that we want the data interpolated to.
  pressure = 700   ; pressure levels to plot

; DO TIME LOOP
  do it = 0, 23, 1

; SET UP THE DESIRED MODS FOR THE MAP AND PLOT
  res             = True

; SET UP MAP PROJECTION AND LIMITED REGION
  res@mpProjection = "CylindricalEquidistant"
  res@mpCenterRotF      = 0.0
  res@mpGridAndLimbOn   = True
  res@mpGridLatSpacingF = 5.0
  res@mpGridLonSpacingF = 5.0
  res@mpLimitMode    = "latlon"
  res@mpMinLatF      = 10.0
  res@mpMaxLatF      = 45.0
  res@mpMinLonF      = -115.0
  res@mpMaxLonF      = -65.0

; COLOR OF CONTINIENTAL OUTLINES
  res@mpOutlineOn            = True
  res@mpGeophysicalLineColor      = "White"
  res@mpNationalLineColor         = "White"
  res@mpUSStateLineColor          = "White"
  res@mpGridLineColor             = "White"
  res@mpLimbLineColor             = "White"
  res@mpPerimLineColor            = "White"
  res@mpGeophysicalLineThicknessF = 2.0
  res@mpGridLineThicknessF        = 1.5
  res@mpLimbLineThicknessF        = 2.0
  res@mpNationalLineThicknessF    = 2.0
  res@mpUSStateLineThicknessF     = 2.0
  res@mpGridLineDashPattern       = 2
  res@mpOutlineBoundarySets       = "GeophysicalAndUSStates"

; TURN ON MAP TICKNARKS
  res@pmTickMarkDisplayMode       = "always"

  map  = gsn_csm_map(wks,res)

; MAXIMIZE PLOT IN FRAME
  res@gsnMaximize = True
; THE DATA IS NOT GLOBAL
  res@gsnAddCyclic= False
; SET UP THE FEATRUED TITLE
  res@gsnLeftString                = "PM2.5 SURFACE MASS CONCENTRATION"
  res@gsnStringFontHeightF         = 0.02
  res@gsnRightStringOrthogonalPosF = 0.02
  res@gsnLeftStringOrthogonalPosF  = 0.02
; DO NOT ADVANCE FRAME YET
  res@gsnFrame                     = False

; COLOR PLOT DEDIRED
  res@cnFillOn = True
; TURN OFF CONTOUR LINES
  res@cnLinesOn = False
; TURN OFF CONTOUR LABELS
  res@cnLineLabelsOn = False

; SET UP COLOR MAP AND LABEL
  res@gsnSpreadColors = True
  res@gsnSpreadColorStart = 0
  res@gsnSpreadColorEnd   = 200
  res@cnInfoLabelOn        = True
  res@cnInfoLabelFontHeightF = 0.01

  res@cnLevelSelectionMode   = "ManualLevels"
  res@cnMinLevelValF           = 0.0
  res@cnMaxLevelValF           = 20.0
  res@cnLevelSpacingF        = 1.0

; SET UP LABEL BAR
  res@pmLabelBarWidthF       = 0.6
  res@pmLabelBarHeightF      = 0.08
  res@lbLabelFontHeightF     = 0.013
  res@lbLabelStride          = 2
  res@lbBoxLinesOn           = False


; SET UP COLOR BAR
  res@tiMainFontHeightF      = 0.02
  res@lbTitleString          = "PM2.5 SURFACE MASS CONCENTRATION (~F33~m~F0~g/m~S~3~N~)"
  res@lbTitleFontHeightF     = 0.015
  res@lbTitlePosition        = "Bottom"
; PLOT THE CONTOUR OVER THE CE MAP
; READ PM2.5 DATA FROM WRF/CHEM OUTPUT FILE AND SET XLAT AND XLONG AS THE ATTRIBUTE OF PM25
   times      = fn->Times(it,:)
   pm25       = fn->PM2_5_DRY(it,:,:,:)
   pm25@lat2d = fn->XLAT(it,:,:)
   pm25@lon2d = fn->XLONG(it,:,:)
   res@tiMainString = "WRF/CHEM  CBMZ-MOSAIC    " + times
   print(times)

   z  = getvar(fn, "z",it)        ; grid point height
   z  = z/10.
   z@lat2d = fn->XLAT(it,:,:)
   z@lon2d = fn->XLONG(it,:,:)


   pa      = fn->P(it,:,:,:)
   pb      = fn->PB(it,:,:,:)
   p       = pa+pb
   p@lat2d = fn->XLAT(it,:,:)
   p@lon2d = fn->XLONG(it,:,:)

   z_plane  = gsn_csm_user_intrp3d( z,p,"h",pressure,0.,False)
; SET UP Z RESOURCES
   res2                                = True
   res2@cnLevelSelectionMode           = "ManualLevels"
   res2@cnMinLevelValF                 = 290.
   res2@cnMaxLevelValF                 = 320.
   res2@cnLevelSpacingF                = 2.
   res2@cnLabelDrawOrder               = "PostDraw"
   res2@cnLineColor                    = "Red"
   res2@cnInfoLabelOn                  = False
   res2@gsnContourLineThicknessesScale = 1.5
   res2@cnLineLabelInterval            = 2
   res2@cnLineLabelsOn                 = True          ; turn on line labels
   ;res2@cnLineLabelBackgroundColor     = "white"       ; white bckgrnd around label
; JUDGE IF THE THERE ARE EPA STATION OBSERVATION AT THIS TIME
    yyr=stringtoint(str_get_cols(times,0,3))
    mmn=stringtoint(str_get_cols(times,5,6))
    ddd=stringtoint(str_get_cols(times,8,9))
    ttime=stringtoint(str_get_cols(times,11,12)+"00")

      ; SELECT EPA  SITE DATA
      ; FIND THE INDEX THAT MATCHES THE SPECIFIED TIME
        location=ind(mn.eq.mmn.and.dd.eq.ddd.and.time.eq.ttime)

      ; PM25 DATA AT THE SPECIFIED TIME
        ppm=epapm25(location)
        sstate=state(location)
        ccounty=county(location)
        ssite=site(location)
        count=dimsizes(ppm)
        llat=new((/count/),float,-999)
        llon=new((/count/),float,-999)
        llat@_FillValue=-999
        llon@_FillValue=-999
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
    map = gsn_csm_contour_map_overlay(wks,pm25(0,:,:),z_plane,map,res,res2)

; SET UP THE RESOURCES FOR LINE PLOT
    if (it .eq. t)then
     pres                  = True           ; polyline mods desired
     pres@gsLineThicknessF = 4.0            ; line thickness
     pres@gsLineColor      = "red"          ; color of lines
     qres                  = True           ; polyline mods desired
     qres@gsLineThicknessF = 4.0            ; line thickness
     qres@gsLineColor      = "yellow"       ; color of lines
     gsn_polyline(wks,map, lonhh, lathh, qres)
     gsn_polyline(wks,map, slonn, slatn, pres)
    end if
    delete(res)
    delete(res2)
    frame(wks)
  end do ; END OF IT LOOP
end
