
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
  type = "x11"
; type = "pdf"
; type = "ps"
; type = "ncgm"
; type = "png"
  wks  = gsn_open_wks(type,"plt_wrf_texas_dot_20030420_0519_v01")
  gsn_define_colormap(wks,"BlGrYeOrReVi200")

  slat = asciiread("texas_lat", -1, "float")
  slon = asciiread("texas_lon", -1, "float")
  srel = asciiread("correlation", -1, "float")
  ns   = dimsizes(srel)

; SET UP MAP PROJECTION AND LIMITED REGION
  res@mpProjection = "CylindricalEquidistant"
  res@mpCenterRotF      = 0.0
  res@mpGridAndLimbOn   = True
  res@mpGridLatSpacingF = 2.0
  res@mpGridLonSpacingF = 2.0
  res@mpLimitMode       = "latlon"
  res@mpMinLatF         = 24.0
  res@mpMaxLatF         = 38.0
  res@mpMinLonF         = -108.0
  res@mpMaxLonF         = -92.0
; COLOR OF CONTINIENTAL OUTLINES
  res@mpOutlineOn            = True
  res@mpUSStateLineThicknessF= 2.0
  res@mpGridLineDashPattern  = 2
  res@mpOutlineBoundarySets  = "GeophysicalAndUSStates"
  res@mpUSStateLineColor     = "Black"
  res@gsnFrame               = False

; TURN ON MAP TICKNARKS
  res@pmTickMarkDisplayMode  = "always"
; SET UP MAIN TITLE
  res@tiMainString           = "Correlation Coefficient(April20-May19 2003)"
  map      = gsn_csm_map(wks,res)
  maxlevel = 90
  minlevel = 30
  linterval= 10
  cinterval= 30
  nlevel   = (maxlevel-minlevel)/linterval
  labels   = ispan(minlevel, maxlevel, linterval)
  colors   = ispan(32,183,cinterval)
  print(labels)
  print(colors)
  getvalues map                       ; Get plot size for use in
    "vpHeightF" : vph                 ; creating labelbar.
    "vpWidthF"  : vpw
  end getvalues

  lbres                    = True          ; labelbar only resources
  lbres@lbAutoManage       = False         ; Necessary to control sizes
  lbres@vpWidthF           = 0.2 * vpw     ; labelbar width
  lbres@vpHeightF          = 0.5 * vph     ; labelbar height
  lbres@vpXF               = 0.8           ; the location of left edge
  lbres@vpYF               = 0.6           ; the location of top edge
  lbres@lbBoxMajorExtentF  = 1.0           ; puts space between color boxes
  lbres@lbMonoFillPattern  = True          ; Solid fill pattern
  lbres@lbLabelFontHeightF = 0.015         ; font height. default is small
  lbres@lbLabelAlignment   = "ExternalEdges"
  lbres@lbFillColors       = colors
  lbres@lbPerimOn          = False
  lbid = gsn_create_labelbar(wks,nlevel,labels/100.,lbres)

; DO SITE LOOP
  do is = 0, ns-1
   cres = True
   res  = cres
   if(srel(is).lt.0.3)then
    srel(is) = 0.3
   end if
   tpmcolor = cinterval*toint((srel(is)-minlevel/100.)/(maxlevel/100.-minlevel/100.)*nlevel) + 32
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
 frame(wks)
end
