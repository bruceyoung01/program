
;   Example script display location of model domains
;   Only works for ARW domains
;   Beta code used
;   November 2008

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin
;

; We generate plots, but what kind do we prefer?
  type = "x11"
; type = "pdf"
; type = "ps"
; type = "ncgm"
  wks = gsn_open_wks(type,"wps_show_dom")

  colors = (/"white","black","White","ForestGreen","DeepSkyBlue"/)
  gsn_define_colormap(wks, colors)  

; SET UP SITE INFO
  lon        = (/-112.0667, -118.25/)
  lat        = (/33.45, 34.05/)
  nsite      = dimsizes(lat)

  mpres = True
  mpres@mpFillOn = True
  mpres@mpFillColors  = (/"background","DeepSkyBlue","ForestGreen","DeepSkyBlue", "transparent"/)
  mpres@mpGeophysicalLineColor      = "Black"
  mpres@mpGridLineColor             = "Black"
  mpres@mpLimbLineColor             = "Black"
  mpres@mpNationalLineColor         = "Black"
  mpres@mpPerimLineColor            = "Black"
  mpres@mpUSStateLineColor          = "Black"

  lnres = True 
  lnres@gsLineThicknessF = 2.5

  txres = True
  txres@txFont = "helvetica-bold"
  txres@txJust = "BottomLeft"
  txres@txPerimOn = False
  txres@txFontHeightF = 0.015

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


  mpres@max_dom           = 2
  mpres@parent_id         = (/   1,   1,   2,   3,   1 /)
  mpres@parent_grid_ratio = (/   1,   3,   1,   5,   5 /)
;==========================================================
; 3 domains
; mpres@i_parent_start    = (/   1,   9,   50,  25,  10 /)
; mpres@j_parent_start    = (/   1,   23,  -5,  25,  10 /)
; mpres@e_we              = (/  77,  43,  45, 101,  51/)
; mpres@e_sn              = (/  69,  31,  30, 101,  51 /)
;==========================================================
; 2 domains
  mpres@i_parent_start    = (/   1,   9,   50,  25,  10 /)
  mpres@j_parent_start    = (/   1,   18,  -5,  25,  10 /)
  mpres@e_we              = (/  87,  106,  45, 101,  51/)
  mpres@e_sn              = (/  79,  73,  30, 101,  51 /)
  mpres@dx                = 36000.
  mpres@dy                = 36000.
  mpres@map_proj          = "lambert"
  mpres@ref_lat           =  36.672
  mpres@ref_lon           = -109.297
  mpres@truelat1          =  36.672
  mpres@truelat2          =  36.672
  mpres@stand_lon         = -109.297
  
  
  mp = wrf_wps_dom (wks,mpres,lnres,txres)

; Now you can add some information to the plot.
  pmres               = True
  pmres@gsMarkerColor = "Red"
  pmres@gsMarkerIndex = 16
  pmres@gsMarkerSizeF = 0.01
  do i = 0, nsite-1
   gsn_polymarker(wks, mp, lon(i), lat(i), pmres)
  end do
  frame(wks)           ; lets frame the plot - do not delete


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

end
