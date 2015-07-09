; $ID: wrf_contour.ncl V01 01/30/2012 15:38 BRUCE EXP$
;
;******************************************************************************
;  PURPOSE OF THIS FUNCTION : PLOT THE CONTOUR PLOT USING WRF/CHEM OUTPUT
;  THE STEPS ARE AS FOLLOWING : 
;  1, READ DATA FROM WRF OUTPUT .NC FILE
;  2, PLOT A MAP WITH A SPECIFIED PROJECTION (NOT NATIVE)
;  3, PLOT A CONTOUR OVER A MAP
;
;  VARIABLES:
;  ============================================================================
;  (1 ) wks      (graphic): WORK STATION                                  [---]
;  (2 ) dir      (string) : DIRECTORY OF WRFCHEM DATA                     [---]
;  (3 ) filename (string) : FILE NAME OF WRFCHEM DATA                     [---]
;  (4 ) itime    (integer): SELECT HOUR OF ONE DAY                        [---]
;  (5 ) ilevel   (integer): SELECT VERTICAL LEVEL                         [---]
;  (6 ) minlat   (float)  : MINIMUM LATITUDE OF LIMITED REGION            [---]
;  (7 ) maxlat   (float)  : MAXIMUM LATITUDE OF LIMITED REGION            [---]
;  (8 ) minlon   (float)  : MINIMUM LONGITUDE OF LIMITED REGION           [---]
;  (9 ) maxlon   (float)  : MAXIMUM LONGITUDE OF LIMITED REGION           [---]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (01/30/2012)
;  (2 ) THE VARIABLE READ BY THIS PROCEDURE MUST BE 4-DIMENSION
;       THE DIMENSION IS : TIME, LEVEL, LATITUDE, LONGITUDE
;******************************************************************************

undef("plot_wrf_contour")
procedure plot_wrf_contour(wks       :graphic, dir       :string, \ ; INPUT
                           filename  :string,                     \ ; INPUT
                           itime     :integer, ilevel    :integer,\ ; INPUT
                           minlat    :float,   maxlat    :float,  \ ; INPUT
                           minlon    :float,   maxlon    :float)

begin

; SET UP COLOR MAP
  gsn_define_colormap(wks,"BlAqGrYeOrReVi200")

; SET UP THE DESIRED MODS FOR THE MAP AND PLOT
  res                              = True

; SET UP MAP PROJECTION AND LIMITED REGION
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

; COLOR AND THICKNESS OF CONTINIENTAL OUTLINES
  res@mpOutlineOn                  = True
  res@mpOutlineBoundarySets        = "GeophysicalAndUSStates"  
  res@mpGeophysicalLineColor       = "White"
  res@mpNationalLineColor          = "White"
  res@mpUSStateLineColor           = "White"
  res@mpGridLineColor              = "White"
  res@mpLimbLineColor              = "White"
  res@mpPerimLineColor             = "White"
  res@mpGeophysicalLineThicknessF  = 2.0
  res@mpGridLineThicknessF         = 1.5
  res@mpLimbLineThicknessF         = 2.0
  res@mpNationalLineThicknessF     = 2.0
  res@mpUSStateLineThicknessF      = 2.0
  res@mpGridLineDashPattern        = 2

; TURN ON MAP TICKMARKS
  res@pmTickMarkDisplayMode        = "always"

; MAXIMIZE PLOT IN FRAME
  res@gsnMaximize                  = True

; THE DATA IS NOT GLOBAL
  res@gsnAddCyclic                 = False

; SET UP THE FEATRUED TITLE
  res@gsnLeftString                = "PM2.5 SURFACE MASS CONCENTRATION"
  res@gsnStringFontHeightF         = 0.02
  res@gsnRightStringOrthogonalPosF = 0.02
  res@gsnLeftStringOrthogonalPosF  = 0.02

; COLOR PLOT DEDIRED
  res@cnFillOn                     = True

; TURN OFF CONTOUR LINES
  res@cnLinesOn                    = False

; TURN OFF CONTOUR LABELS
  res@cnLineLabelsOn               = False

; SET UP COLOR MAP AND LABEL
  res@gsnSpreadColors              = True
  res@gsnSpreadColorStart          = 0
  res@gsnSpreadColorEnd            = 200
  res@cnInfoLabelOn                = True
  res@cnInfoLabelFontHeightF       = 0.01
  res@cnLevelSelectionMode         = "ManualLevels"
  res@cnMinLevelValF               = 0.0
  res@cnMaxLevelValF               = 20.0
  res@cnLevelSpacingF              = 1.0

; SET UP LABEL BAR
  res@pmLabelBarWidthF             = 0.6
  res@pmLabelBarHeightF            = 0.08
  res@lbLabelFontHeightF           = 0.013
  res@lbLabelStride                = 2
  res@lbBoxLinesOn                 = False

; PLOT THE CONTOUR OVER THE CE MAP
; READ ONE VARIABLE DATA FROM WRF/CHEM OUTPUT FILE AND 
; SET XLAT AND XLONG AS THE ATTRIBUTE OF THE VARIABLE
  a                                = addfile(dir + filename,"r")
  times                            = a->Times(itime,:)
  data                             = a->var(itime,:,:,:)
  data@lat2d                       = a->XLAT(itime,:,:)
  data@lon2d                       = a->XLONG(itime,:,:)
  res@tiMainString                 = "WRFCHEM "+times
  res@tiMainFontHeightF            = 0.02
  res@lbTitleString                = data@description + "  " + "(" + data@units + ")"
  res@lbTitleFontHeightF           = 0.015
  res@lbTitlePosition              = "Bottom"
  plot                             = gsn_csm_contour_map(wks,data(ilevel,:,:),res)
  return(map)
  delete(res)

end
