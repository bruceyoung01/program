
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PURPOSE OF THIS PROGRAM : PLOT THE CONTOUR AND MARKER PLOT USING 
; WRF/CHEM OUTPUT FILE AND EPA STATION OBSERVATION FILE
; THE STEPS ARE AS FOLLOWING : 
; 1, PLOT THE EPA MARKERS ON THE MAP.
; 2, PLOT THE CONTOUR OF WRF/CHEM OUTPUT, INCLUDING HEIGHT AND PM2.5
; 3, OVERLAY THE CONTOUR AND EPA MARKERS.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm_epa.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/pro_fun.ncl"

begin

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

; OPEN WRF/CHEM OUTPUT FILE
  a = addfile("/media/disk/data/wrfchem/200805_sepanf/wrfout_d01_2008-05-01_00:00:00_1200sepanf.nc","r")

; OPEN A WORKSTATION AND CHOOSE COLORMAP
; type = "x11"
  type = "pdf"
; type = "ps"
; type = "ncgm"
; type = "png"
  wks = gsn_open_wks(type,"1plt_wrf_contour_pm25_i_2008-05-01_main")
  gsn_define_colormap(wks,"BlAqGrYeOrReVi200")

; The specific pressure levels that we want the data interpolated to.
  pressure = 700   ; pressure levels to plot

; DO TIME LOOP
  do it = 0, 23, 3

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
  res@mpFillDrawOrder             = "PreDraw"
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
  res@lbTitleString          = "PM2.5 SURFACE MASS CONCENTRATION (ug m^-3)"
  res@lbTitleFontHeightF     = 0.015
  res@lbTitlePosition        = "Bottom"

; DRAW A LINE THE MAP
; 2008-05-08
;  lat1 = 10.0
;  lon1 = -98.
;  lat2 = 45.
;  lon2 = -92.
;  pres                  = True           ; polyline mods desired
;  pres@gsLineThicknessF = 4.0            ; line thickness
;  pres@gsLineColor      = "red"          ; color of lines

; PLOT THE CONTOUR OVER THE CE MAP
; READ PM2.5 DATA FROM WRF/CHEM OUTPUT FILE AND SET XLAT AND XLONG AS THE ATTRIBUTE OF PM25
   times      = a->Times(it,:)
   pm25       = a->PM2_5_DRY(it,:,:,:)
   pm25@lat2d = a->XLAT(it,:,:)
   pm25@lon2d = a->XLONG(it,:,:)
   res@tiMainString = "WRF/CHEM  MAIN    " + times
   print(times)

   z  = wrf_user_getvar(a, "z",it)        ; grid point height
   z  = z/10.
   z@lat2d = a->XLAT(it,:,:)
   z@lon2d = a->XLONG(it,:,:)


   pa        = a->P(it,:,:,:)
   pb        = a->PB(it,:,:,:)
   p          = pa+pb
   p@lat2d = a->XLAT(it,:,:)
   p@lon2d = a->XLONG(it,:,:)

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
;    gsn_polyline(wks,map, (/lon1, lon2/) , (/lat1, lat2/) ,pres)
    delete(res)
    delete(res2)
    frame(wks)
  end do ; END OF IT LOOP
end
