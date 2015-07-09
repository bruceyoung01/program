
; PURPOSE OF THIS PROGRAM : 
; PLOT THE CORRELATION COEFFICIENT OF DIFFERENT SITES ON THE MAP

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm_epa.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"


begin
  res = True

;-----------------------PLOT WRFCHEM OUTPUT------------------------------
; We generate plots, but what kind do we prefer?
; type = "x11"
  type = "pdf"
; type = "ps"
; type = "ncgm"
; type = "png"
  wks  = gsn_open_wks(type,"1plt_site_pm25_map_v01")
; gsn_define_colormap(wks,"BlGrYeOrReVi200")

; SET UP MAP PROJECTION AND LIMITED REGION
  res@mpProjection           = "CylindricalEquidistant"
  res@mpCenterRotF           = 0.0
  res@mpGridAndLimbOn        = True
  res@mpGridLatSpacingF      = 2.0
  res@mpGridLonSpacingF      = 2.0
  res@mpLimitMode            = "latlon"
  res@mpMinLatF              = 33.66
  res@mpMaxLatF              = 34.0
  res@mpMinLonF              = -84.9
  res@mpMaxLonF              = -84.35
; COLOR OF CONTINIENTAL OUTLINES
  res@mpOutlineOn            = True
  res@mpUSStateLineThicknessF= 2.0
  res@mpGeophysicalLineThicknessF = 2.0
  res@mpCountyLineThicknessF = 2.0
  res@mpGridLineDashPattern  = 2
  res@mpOutlineBoundarySets  = "GeophysicalAndUSStates"
  res@mpUSStateLineColor     = "Black"
  res@gsnFrame               = False
  res@mpFillOn               = False
; ADD US COUNTIES BOUNDARIES
  res@mpOutlineBoundarySets  = "AllBoundaries"
  res@mpDataBaseVersion      = "Ncarg4_1"
  res@mpDataSetName          = "Earth..2"

; TURN ON MAP TICKNARKS
  res@pmTickMarkDisplayMode  = "always"
  map      = gsn_csm_map(wks,res)

  maxlevel = 32
  minlevel = 2
  linterval= 2
  maxclevel= 183
  minclevel= 4
  cinterval= 12
  nlevel   = (maxlevel-minlevel)/linterval
  labels   = ispan(minlevel,  maxlevel,  linterval)
  colors   = ispan(minclevel, maxclevel, cinterval)
  print(labels)
  print(colors)
  getvalues map                       ; Get plot size for use in
    "vpHeightF" : vph                 ; creating labelbar.
    "vpWidthF"  : vpw
  end getvalues

  lbres                    = True          ; labelbar only resources
  lbres@lbAutoManage       = False         ; Necessary to control sizes
  lbres@vpWidthF           = 0.12*vpw      ; labelbar width
  lbres@vpHeightF          = 0.5*vph       ; labelbar height
  lbres@vpXF               = 0.85          ; the location of left edge
  lbres@vpYF               = 0.6           ; the location of top edge
  lbres@lbBoxMajorExtentF  = 1.0           ; puts space between color boxes
  lbres@lbLabelStride      = 2
  lbres@lbMonoFillPattern  = True          ; Solid fill pattern
  lbres@lbLabelFontHeightF = 0.015         ; font height. default is small
  lbres@lbLabelAlignment   = "InteriorEdges"
  lbres@lbFillColors       = colors
  lbres@lbPerimOn          = False
  lbres@lbBoxLinesOn       = False
  lbres@lbTitleFontHeightF = 15.0
  lbres@lbTitleFontThicknessF = 1.0
  lbres@lbTitleString      = "(~F33~m~F0~g/m~S~3~N~)"
  lbid = gsn_create_labelbar(wks,nlevel,labels*1.0,lbres)

; READ SITE INFO
  dir      = "./data/"
  lat_file = asciiread(dir + "atlanta_lat_list", -1, "string")
  lon_file = asciiread(dir + "atlanta_lon_list", -1, "string")
  pm_file  = asciiread(dir + "atlanta_pm_list",  -1, "string")
  nday     = dimsizes(lat_file)

  do iday = 0, nday-1
   date = str_get_cols(lat_file(iday), 12, 19)
   slat = asciiread(dir + lat_file(iday), -1, "float")
   slon = asciiread(dir + lon_file(iday), -1, "float")
   srel = asciiread(dir + pm_file(iday), -1, "float")
   ns   = dimsizes(srel)

;  SET UP MAIN TITLE
   res@tiMainString = "Observed PM2.5 " + date
   map              = gsn_csm_map(wks,res)

;  DO SITE LOOP
   do is = 0, ns-1
    cres = True
    if(srel(is).lt.0.3)then
     srel(is) = 0.3
    end if
    tpmcolor = cinterval*toint((srel(is)-minlevel)/(maxlevel-minlevel)*nlevel) + minclevel
    print("color = " + tpmcolor)
    do j=0,nlevel-1
     if(tpmcolor.eq.colors(j))then
      scolor=colors(j)
     end if
     if(j.gt.0.and.tpmcolor.gt.colors(j).and.tpmcolor.lt.colors(j+1))then
      scolor=colors(j)
     end if
     if(tpmcolor.eq.colors(nlevel-1))then
      scolor=colors(nlevel-1)
     end if
    end do
    cres@gsMarkerColor = scolor
    cres@gsMarkerIndex = 16
    cres@gsMarkerSizeF = 0.015
    cres@gsMarkerThicknessF = 0.3
    gsn_polymarker(wks,map,slon(is),slat(is),cres)
    delete(cres)
   end do
  draw(lbid)
  draw(map)
  frame(wks)
  delete([/slat, slon, srel/])
 end do
end
