
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
  wks  = gsn_open_wks(type,"plt_wrf_epasites_2003")
  gsn_define_colormap(wks,"percent_11lev")

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
  map      = gsn_csm_map(wks,res)

; DO SITES LOOP
  do is = 0, ns-1
   if(slon(is).gt.-102.and.slon(is).lt.-101.and. \
      slat(is).gt. 35.and.slat(is).lt. 36)then
    print(slon(is))
    print(slat(is))
   end if
   cres = True
   res  = cres
   cres@gsMarkerColor = "red"
   cres@gsMarkerIndex = 16
   cres@gsMarkerSizeF = 0.008
   cres@gsMarkerThicknessF = 0.3
   gsn_polymarker(wks,map,slon(is),slat(is),cres)
   delete(cres)
  end do
  frame(wks)
end
