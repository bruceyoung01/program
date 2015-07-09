;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; PURPOSE OF THIS PROGRAM : PLOT HISTOGRAM                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "/home/bruce/program/ncl/tutorial/test/wrf_contour_h/WRFUserARW.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/pro_fun.ncl"


begin

; SET UP THE PLOT PLATFORM
   type = "x11"
;  type = "pdf"
;  type = "ps"
;  type = "ncgm"
;  type = "png"
   wks  = gsn_open_wks(type, "1plt_calipso_ec_histogram_20710_10_v40_smoke_column")
   gsn_define_colormap(wks,"WhAqGrYeOrReVi200")

   datatypef = "float"
   npts      = 8
   minaod    = 0.0
   maxaod    = 0.35
   daod      = fspan(minaod, maxaod, npts)
   fre1      = asciiread("fre_2006", (/npts/), datatypef)
   fre2      = asciiread("fre_2007_2010", (/npts/), datatypef)

   bres                       = True
   bres@gsnDraw               = True
   bres@gsnFrame              = True
   bres@gsnXYBarChart         = True
   bres@gsnXYBarChartBarWidth = 0.3
   bres@trXMinF               = 0.0
   bres@trXMaxF               = 8
   bres@trYMinF               = 0.1
   bres@trYMaxF               = 110
   bres@trYAxisType           = "LogAxis"
   bres@tiXAxisString         = "AOD"
   bres@tiYAxisString         = "Frequency(%)"
   bres@tiMainString          = "Frequency Comparison"
   bres@tmXBMode              = "Explicit"
   bres@tmXBValues            = ispan(1, npts, 1)
   bres@tmXBLabels            = daod + ""
   bres@gsnXYBarChartColors   = (/"black"/)
   bres@gsnXYBarChartPatterns = 6
   plot1 = gsn_csm_xy(wks, fspan(1.35, npts+0.35, npts), fre1, bres)
   bres@gsnXYBarChartColors   = (/"white"/)
   bres@gsnXYBarChartPatterns = 0
   plot2 = gsn_csm_xy(wks, fspan(1.65, npts+0.65, npts), fre2, bres) 
   overlay(plot1, plot2)
   draw(plot1)
   frame(wks)
   getvalues plot1
   "vpXF"      : vpx
   "vpYF"      : vpy
   "vpHeightF" : vph
   "vpWidthF"  : vpw
   end getvalues

   lbw    = 0.5 * vpw 
   lbh    = 0.1 * vph

   lbres                    = True
   lbres@vpWidthF           = 0.1*vpw
   lbres@vpHeightF          = 0.2*vph
   lbres@lbPerimOn          = False
   lbres@lbBoxLinesOn       = True
   lbres@lbBoxMajorExtentF  = 0.5
   lbres@lbFillPatterns     = (/6, 0/)
   lbres@lbLabelFontHeightF = 0.03
   lbres@lbLabelJust        = "CenterLeft"
   labels                   = (/"2006", "2007-2010"/)
   gsn_labelbar_ndc(wks,2,labels,vpx+vph-lbw,0.77,lbres)
   draw(plot1) 
   frame(wks)

end
