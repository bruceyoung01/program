
; PURPOSE OF THIS PROGRAM : 
; PLOT THE DIFFERENT SITES ON THE MAP

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
; type = "png"
  wks  = gsn_open_wks(type,"plt_sampling_site_map_v01")
  gsn_define_colormap(wks,"percent_11lev")

; REGION LIMITE
  minlat    =  33.5
  maxlat    =  34.0
  minlon    = -84.8
  maxlon    = -84.2
; SET UP SITE INFO
  dir       = "/home/bruce/program/ncl/tutorial/test/atlanta/sampling_site_map/"
  sfile     = "atlanta_sites_info"
  delimiter = " "
  data      = asciiread(dir + sfile, -1, "string")
  header    = data(0)
  sdata     = data(1:)
  ns        = dimsizes(sdata)
  sname     = new(ns, string)
  slat      = new(ns, float)
  slon      = new(ns, float)
  nfields   = str_fields_count(sdata(0), delimiter)
  var_name  = new(nfields, string)
  var_types = "float"
  var_types(0) = "string"
  do i = 0, nfields-1
   var_name(i) = str_get_field(header, i+1, delimiter)
   do j = 0, ns-1
    sname(j) = str_get_cols(sdata(j), 0,  16)
    slat(j)  = stringtofloat(str_get_cols(sdata(j), 17, 29))
    slon(j)  = stringtofloat(str_get_cols(sdata(j), 30, 37))
   end do
  end do

; SET UP MAP PROJECTION AND LIMITED REGION
  res@mpProjection           = "CylindricalEquidistant"
  res@mpCenterRotF           = 0.0
  res@mpGridAndLimbOn        = True
  res@mpGridLatSpacingF      = 0.1
  res@mpGridLonSpacingF      = 0.1
  res@mpLimitMode            = "latlon"
  res@mpMinLatF              = minlat
  res@mpMaxLatF              = maxlat
  res@mpMinLonF              = minlon
  res@mpMaxLonF              = maxlon
; COLOR OF CONTINIENTAL OUTLINES
  res@mpOutlineOn            = True
  res@mpUSStateLineThicknessF= 4.0
  res@mpCountyLineThicknessF = 3.0
  res@mpGridLineDashPattern  = 2
  res@mpDataResolution       = "FinestResolution"
  res@mpOutlineBoundarySets  = "GeophysicalAndUSStates"
  res@mpUSStateLineColor     = "Black"
  res@mpOutlineBoundarySets  = "AllBoundaries"
  res@mpDataBaseVersion      = "Ncarg4_1"
  res@mpDataSetName          = "Earth..2"
  res@gsnFrame               = False
  map      = gsn_csm_map(wks,res)

; DO SITES LOOP
  do is = 0, ns-1
;  SET UP DOT RESOURCES
   cres                    = True
   res                     = cres
   cres@gsMarkerColor      = "red"
   cres@gsMarkerIndex      = 16
   cres@gsMarkerSizeF      = 0.008
   cres@gsMarkerThicknessF = 0.3
   gsn_polymarker(wks, map, slon(is), slat(is), cres)
;  SET UP TEXT RESOURCE
   tres                    = True
   tres@txFontHeightF      = 0.012
   tres@txFontThicknessF   = 15
   tres@txFontColor        = "Blue"
   gsn_text(wks, map, sname(is), slon(is), slat(is), tres)
   delete([/cres, tres/])
  end do
  frame(wks)
end
