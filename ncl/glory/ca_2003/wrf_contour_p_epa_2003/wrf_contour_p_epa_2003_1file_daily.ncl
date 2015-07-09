; PURPOSE OF THIS PROGRAM :
; READ THE REANALYSIS DATA OF EACH EPA SITE FROM JW
; PLOT THE EPA SITE ONTO THE WRFCHEM SIMULATION MAP

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm_epa.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW_epa.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/pro_fun.ncl"


begin

;-----------------------EPA SITES------------------------------------
; READ EPA DATA
  fdir      = "/home/bruce/program/idl/smoke/2003_jw/2003_processed/"
  fnamelist = "filelist4_tx"
  fname     = asciiread(fdir+fnamelist,-1,"string")
  nfname    = dimsizes(fname)
  ncolumn   = 30
; THE NUMBER OF DAYS OF THE MONTH
  nday      = 30 ; USER SPECIFY
; THE NUMBER OF COLUMNS OF THE LINE OF LATITUDE AND LONGITUDE
  nll       = 8
; TOTAL NUMBER OF EPA SITES IN ONE MONTH
  ll        = new((/nll, nfname/),float,999)
  epa       = new((/nday, ncolumn, nfname/),float,999)
  do i = 0, nfname-1
   lldata   = readAsciiTable(fdir+fname(i), 1, "string", (/1,nday+2/))
   fdata    = readAsciiTable(fdir+fname(i), 1, "string", (/4,0/))
   do k = 0, nll-1
    ll(k,i) = stringtofloat(str_get_field(lldata, k, " "))
   end do
   do j = 0, ncolumn-1
    epa(:,j,i) = stringtofloat(str_get_field(fdata, j+1, " "))
   end do
   delete(fdata)
  end do

;--------------------------------------------WRF/CHEM---------------------------------------------------------------------
; OPEN WRF/CHEM OUTPUT FILE
  wfdir = "/home/bruce/sshfs/pfw/model/wrfchem3/WRFV311/test/em_real/wrfout/"
  wfnamelist = "2003_ca_60_list"
  wfname = asciiread(wfdir+wfnamelist, -1, "string")
  wnfname= dimsizes(wfname)
  thour  = 24
  tday   = wnfname/thour
  tlevel = 27
  tlat   = 89
  tlon   = 99
  pm25hour     = new((/tday,thour,tlevel,tlat,tlon/), float, -999)
  pm25daily    = new((/tday,tlevel,tlat,tlon/), float, -999)
  z_planehour  = new((/tday,thour,tlat,tlon/), float, -999)
  z_planedaily = new((/tday,tlat,tlon/), float, -999)
  epahour      = new((/tday,thour,nfname/), float, -999)
  epadaily     = new((/tday,nfname/), float, -999)
  id     = 0
  ih     = 0
;-----------------------WRFCHEM-------------------------------------
; The specific pressure levels that we want the data interpolated to.
  pressure = 700   ; pressure levels to plot   USER SPECIFY

; SET UP THE DESIRED MODS FOR THE MAP AND PLOT
  res             = True

; SET UP MAP PROJECTION AND LIMITED REGION
  res@mpProjection      = "CylindricalEquidistant"
  res@mpCenterRotF      = 0.0
  res@mpGridAndLimbOn   = True
  res@mpGridLatSpacingF = 5.0
  res@mpGridLonSpacingF = 5.0
  res@mpLimitMode       = "latlon"
  res@mpMinLatF         = 10.0
  res@mpMaxLatF         = 45.0
  res@mpMinLonF         = -115.0
  res@mpMaxLonF         = -65.0

; COLOR OF CONTINIENTAL OUTLINES
  res@mpOutlineOn                 = True
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

; MAXIMIZE PLOT IN FRAME
  res@gsnMaximize = True
; THE DATA IS NOT GLOBAL
  res@gsnAddCyclic= False
; SET UP THE FEATRUED TITLE
  res@gsnLeftString                = "PM2.5 SURFACE MASS CONCENTRATION"
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
  res@cnInfoLabelOn          = True
  res@cnInfoLabelFontHeightF = 0.01

  res@cnLevelSelectionMode   = "ManualLevels"
  res@cnMinLevelValF         = 0.0
  res@cnMaxLevelValF         = 20.0
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

;  SET UP Z RESOURCES
  res2 = True
  res2@cnLevelSelectionMode           = "ManualLevels"
  res2@cnMinLevelValF                 = 290.
  res2@cnMaxLevelValF                 = 320.
  res2@cnLevelSpacingF                = 2.
  res2@cnLabelDrawOrder               = "PostDraw"
  res2@cnLineColor                    = "Red"
  res2@cnInfoLabelOn                  = False
  res2@gsnContourLineThicknessesScale = 1.5
  res2@cnLineLabelInterval            = 2
  res2@cnLineLabelsOn                 = True ; turn on line labels

  do itd = 0, tday-1
  do ith = 0, thour-1
  iw = ith+itd*thour
  a    = addfile(wfdir + wfname(iw) + ".nc","r")
; THE DATE USED TO PLOT
  syear = str_get_cols(wfname(iw),11,14)
  smonth= str_get_cols(wfname(iw),16,17)
  sdate = str_get_cols(wfname(iw),19,20)
  shour = str_get_cols(wfname(iw),22,23)
  oyear  = stringtoint(syear)
  omonth = stringtoint(smonth)
  odate  = stringtoint(sdate)
  oit    = stringtoint(shour)
  jul   = greg2jul(oyear,omonth,odate,oit)
  cjul  = jul-0.25
  greg  = jul2greg(cjul)
  year  = greg(0)
  month = greg(1)
  date  = greg(2)
  it    = greg(3)
; OPEN A WORKSTATION AND CHOOSE COLORMAP
; type = "x11"
  type = "pdf"
; type = "ps"
; type = "ncgm"
; type = "png"
  wks  = gsn_open_wks(type,"1plt_wrf_contour_pm25_i_"+syear+"-"+smonth+"-"+sdate+"_"+shour+"_zhang_v03_l")
  gsn_define_colormap(wks,"BlAqGrYeOrReVi200")
  map  = gsn_csm_map(wks,res)

   times      = a->Times(0,:)
   pm25       = a->PM2_5_DRY(0,:,:,:)
   pm25@lat2d = a->XLAT(0,:,:)
   pm25@lon2d = a->XLONG(0,:,:)
   res1 = True
   res1 = res
   res1@tiMainString = "WRF/CHEM  " + times
   print(times)

;  DECREASE THE FILE EMISSION
;   pm25(:, 0:40, :) = pm25(:, 0:40, :)/3
   z  = wrf_user_getvar(a, "z",0)        ; grid point height
   z  = z/10.
   z@lat2d = a->XLAT(0,:,:)
   z@lon2d = a->XLONG(0,:,:)


   pa        = a->P(0,:,:,:)
   pb        = a->PB(0,:,:,:)
   p          = pa+pb
   p@lat2d = a->XLAT(0,:,:)
   p@lon2d = a->XLONG(0,:,:)

   z_plane  = gsn_csm_user_intrp3d( z,p,"h",pressure,0.,False)
;  COLLECT HOURLY DATA IN ONE DAY
   if(ih .le. 23)then
    pm25hour(id,ih,:,:,:)  = pm25
    z_planehour(id,ih,:,:) = z_plane
    epahour(id,ih,:) = epa(date-1,it+1,:)
    ih = ih+1
    if(ih .gt. 23)then
     id = id+1
     ih = 0
    end if
   end if


; PLOT EPA SITES ONTO WRFCHEM PLOT

  do i = 0, nfname-1
        nlevel = (res@cnMaxLevelValF-res@cnMinLevelValF)/res@cnLevelSpacingF+2
        inlevel=toint(nlevel)
        interval=toint((res@gsnSpreadColorEnd - res@gsnSpreadColorStart)/nlevel)
        colors = ispan(2,201,interval)
        tpmcolor=toint(((epa(date-1,it+1,i)-min(epa(date-1,it+1,:)))/\
                 ((max(epa(date-1,it+1,:)))-min(epa(date-1,it+1,:))))*\
                 (res@gsnSpreadColorEnd - res@gsnSpreadColorStart))
        do j=0,nlevel-1
        if(ismissing(tpmcolor))then
         pmcolor=0
        end if
        if(.not.ismissing(tpmcolor).and.tpmcolor.eq.colors(j))then
         pmcolor=colors(j)
        end if
        if(.not.ismissing(tpmcolor).and.j.gt.0.and.tpmcolor.gt.colors(j).and.tpmcolor.lt.colors(j+1))then
         pmcolor=colors(j)
        end if
        if(.not.ismissing(tpmcolor).and.tpmcolor.eq.colors(inlevel-1))then
         pmcolor=colors(inlevel-1)
        end if
        end do
        add_markers(wks,map,ll(6,i),ll(5,i),"Black",14,0.012,2.5)
        add_markers(wks,map,ll(6,i),ll(5,i),pmcolor,16,0.01,1.0)
  end do ; END OF I LOOP

  map = gsn_csm_contour_map_overlay(wks,pm25(0,:,:),z_plane,map,res1,res2)
  delete(res1)
  delete(map)
  delete(wks)
 end do ; END OF ITH LOOP

; PLOT DAILY AVERAGE MAP
; SPECIFY THE DATE
  cjul  = jul-1
  greg  = jul2greg(cjul)
  year  = greg(0)
  month = greg(1)
  date  = greg(2)
  it    = greg(3)
  fyear  = int2flt(year)
  fmonth = int2flt(month)
  fdate  = int2flt(date)
  fhour  = int2flt(it)
  ssyear = flt2string(fyear)
  ssmonth= flt2string(fmonth)
  ssdate  = flt2string(fdate)

; OPEN A WORKSTATION AND CHOOSE COLORMAP
  type = "x11"
; type = "pdf"
; type = "ps"
; type = "ncgm"
; type = "png"
  wks  = gsn_open_wks(type,"1plt_wrf_contour_pm25_i_"+syear+"-"+smonth+"-"+sdate+"_zhang_smoke_v05_daily")
  gsn_define_colormap(wks,"BlAqGrYeOrReVi200")
  map  = gsn_csm_map(wks,res)

  res3 = True
  res3 = res
  res3@tiMainString = "WRF/CHEM DAILY Smoke" +ssyear+"-"+ssmonth+"-"+ssdate
  pm25daily(itd,:,:,:)  = dim_avg_n(pm25hour(itd,:,:,:,:), 0)
  z_planedaily(itd,:,:) = dim_avg_n(z_planehour(itd,:,:,:), 0)
  epadaily(itd,:)       = dim_avg_n(epahour(itd,:,:),0)
  pm25daily@lat2d = a->XLAT(0,:,:)
  pm25daily@lon2d = a->XLONG(0,:,:)
  z_planedaily@lat2d = a->XLAT(0,:,:)
  z_planedaily@lon2d = a->XLONG(0,:,:)
; PLOT EPA SITES ONTO WRFCHEM PLOT

  do i = 0, nfname-1
        nlevel = (res@cnMaxLevelValF-res@cnMinLevelValF)/res@cnLevelSpacingF+2
        inlevel=toint(nlevel)
        interval=toint((res@gsnSpreadColorEnd - res@gsnSpreadColorStart)/nlevel)
        colors = ispan(2,201,interval)
        tpmcolor=toint(((epadaily(itd,i)-min(epadaily(itd,:)))/\
                 ((max(epadaily(itd,:)))-min(epadaily(itd,:))))*\
                 (res@gsnSpreadColorEnd - res@gsnSpreadColorStart))
        do j=0,nlevel-1
        if(ismissing(tpmcolor))then
         pmcolor=0
        end if
        if(.not.ismissing(tpmcolor).and.tpmcolor.eq.colors(j))then
         pmcolor=colors(j)
        end if
        if(.not.ismissing(tpmcolor).and.j.gt.0.and.tpmcolor.gt.colors(j).and.tpmcolor.lt.colors(j+1))then
         pmcolor=colors(j)
        end if
        if(.not.ismissing(tpmcolor).and.tpmcolor.eq.colors(inlevel-1))then
         pmcolor=colors(inlevel-1)
        end if
        end do
        add_markers(wks,map,ll(6,i),ll(5,i),"Black",14,0.012,2.5)
        add_markers(wks,map,ll(6,i),ll(5,i),pmcolor,16,0.01,1.0)
  end do ; END OF I LOOP

  map = gsn_csm_contour_map_overlay(wks,pm25daily(itd,0,:,:),z_planedaily(itd,:,:),map,res3,res2)
  delete(res3)
  delete(wks)
end do  ; END OF ITD LOOP
end
