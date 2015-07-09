; $ID: plot_wrf_contour_vector_aod_diff_dim.ncl V01 05/16/2012 15:00 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE plot_contour_vector_aod_diff_dim PLOTS CONTOUR WITH VECTOR 
;  OVERLAIED ON IT.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) wks      (graphic): WORK STATION                               [---]
;  (2 ) minlat   (float)  : MINIMUM LATITUDE                           [deg]
;  (3 ) maxlat   (float)  : MAXIMUM LATITUDE                           [deg]
;  (4 ) minlon   (float)  : MINIMUM LONGITUDE                          [deg]
;  (5 ) maxlon   (float)  : MAXIMUM LONGITUDE                          [deg]
;  (6 ) time     (string) : TIME                                       [---]
;  (7 ) u        (float)  : U WIND                                     [m/s]
;  (8 ) v        (float)  : V WIND                                     [m/s]
;  (9 ) data     (float)  : CONTOUR DATA                               [---]
;  (10) plot     (graphic): PLOT                                       [---]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (05/16/2012)
;******************************************************************************

undef("plot_wrf_contour_vector_aod_diff_dim")
procedure plot_wrf_contour_vector_aod_diff_dim \
          (wks        :graphic,                    \ ; INPUT
           minlat     :float,   maxlat     :float, \ ; INPUT
           minlon     :float,   maxlon     :float, \ ; INPUT
           time       :string,                     \ ; INPUT
           u          :float,   v          :float, \ ; INPUT
           data       :float)                      \ ; INPUT

begin

   map = new(1, graphic)
;  SET UP THE DESIRED MODS FOR THE MAP AND PLOT
   res                              = True

;  SET UP MAP PROJECTION AND LIMITED REGION
   res@mpFillOn                     = False
   res@mpProjection                 = "CylindricalEquidistant"
   res@mpCenterRotF                 = 0.0
   res@mpGridAndLimbOn              = True
   res@mpGridLatSpacingF            = 5.0
   res@mpGridLonSpacingF            = 5.0
   res@mpLimitMode                  = "latlon"
   res@mpMinLatF                    = minlat
   res@mpMaxLatF                    = maxlat
   res@mpMinLonF                    = minlon
   res@mpMaxLonF                    = maxlon
;  COLOR OF CONTINIENTAL OUTLINES
   res@mpOutlineOn                  = True
   res@mpGeophysicalLineColor       = "Black"
   res@mpNationalLineColor          = "Black"
   res@mpUSStateLineColor           = "Black"
   res@mpGridLineColor              = "Black"
   res@mpLimbLineColor              = "Black"
   res@mpPerimLineColor             = "Black"
   res@mpGeophysicalLineThicknessF  = 3.0
   res@mpGridLineThicknessF         = 1.5
   res@mpLimbLineThicknessF         = 2.0
   res@mpNationalLineThicknessF     = 3.0
   res@mpUSStateLineThicknessF      = 2.0
   res@mpGridLineDashPattern        = 2
   res@mpOutlineBoundarySets        = "GeophysicalAndUSStates"

;  TURN ON MAP TICKNARKS
   res@pmTickMarkDisplayMode        = "always"
   res@mpFillDrawOrder              = "PreDraw"
   res@gsnDraw                      = False
   res@gsnFrame                     = False
   map  = gsn_csm_map(wks,res)

;  MAXIMIZE PLOT IN FRAME
   resc                             = True
   resc                             = res
   resc@gsnMaximize                 = True
;  THE DATA IS NOT GLOBAL
   resc@gsnAddCyclic                = False
   resc@gsnDraw                     = True
   resc@gsnFrame                    = True

;  SET UP THE FEATRUED TITLE
   resc@gsnLeftString               = "Aerosol Optical Depth"
   resc@gsnStringFontHeightF        = 0.02
   resc@gsnRightStringOrthogonalPosF= 0.02
   resc@gsnLeftStringOrthogonalPosF = 0.02

;  COLOR PLOT DEDIRED
   resc@cnFillOn                    = True
;  TURN OFF CONTOUR LINE
   resc@cnLinesOn                   = False
;  TURN OFF CONTOUR LABELS
   resc@cnLineLabelsOn              = False

;  SET UP COLOR MAP AND LABEL
   resc@gsnSpreadColors             = True
   resc@gsnSpreadColorStart         = 2
   resc@gsnSpreadColorEnd           = 200
   resc@cnInfoLabelOn               = False
   resc@cnInfoLabelPerimOn          = False
   resc@cnLevelSelectionMode        = "ManualLevels"
   resc@cnMinLevelValF              = 0.0
   resc@cnMaxLevelValF              = 1.0
   resc@cnLevelSpacingF             = 0.05

;  SET UP LABEL BAR
   resc@pmLabelBarOrthogonalPosF    = 0.085
   resc@pmLabelBarParallelPosF      = 0.5
   resc@pmLabelBarWidthF            = 0.6
   resc@pmLabelBarHeightF           = 0.068
   resc@lbLabelFontHeightF          = 0.013
   resc@lbLabelStride               = 2
   resc@lbBoxLinesOn                = False

;  SET UP COLOR BAR
   resc@tiMainFontHeightF           = 0.02
   resc@tiMainString                = "AOD (550nm) Wind Monthly " + time
   resc@lbTitleString               = "AOD (550nm)"
   resc@lbTitleFontHeightF          = 0.015
   resc@lbTitlePosition             = "Bottom"
;  SET UP VECTOR RESOURCES
   resvc                            = True
   resvc@vcRefMagnitudeF            = 10.0
   resvc@vcRefLengthF               = 0.05
   resvc@vcRefAnnoOrthogonalPosF    = -1.0
   resvc@vcRefAnnoArrowLineColor    = "purple"
   resvc@vcRefAnnoArrowUseVecColor  = False
   resvc@vcGlyphStyle               = "CurlyVector"
   resvc@vcLineArrowColor           = "purple"
   resvc@vcLineArrowThicknessF      = 2.0
   resvc@vcVectorDrawOrder          = "PostDraw"
   resvc@vcMinDistanceF             = 0.03
   resvc@gsnDraw                    = False
   resvc@gsnFrame                   = False
   data@units                       = " "
   plot1 = gsn_csm_vector_map_ce(wks, u, v, map, resvc)
   plot2 = gsn_csm_contour_map_ce(wks, data, map, resc)
   delete([/res, resc, resvc/])

return
end
