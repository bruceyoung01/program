; $ID plot_vertical_profile_1fre.ncl V01 01/18/2012 11:27 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE plot_vertical_profile IS USED TO PLOT VERTICAL PROFILE WITH 
;  ERROR BAR AND FREQUENCY COLOR BAR.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) wks      (graphic): WORK STATION                               [---]
;  (2 ) stype    (string) : TYPE OF CLASSIFICATION                     [---]
;  (3 ) height   (float)  : HEIGHT LELVELS                             [km ]
;  (4 ) data     (float)  : DATA TO PLOT                               [---]
;  (5 ) error    (float)  : ERROR OF DATA                              [---]
;  (6 ) fre1     (float)  : FREQUENCY OF AEROSOL IN EACH LAYER         [---]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (01/18/2012)
;******************************************************************************

undef("plot_vertical_profile_1fre")
procedure plot_vertical_profile_1fre(wks       :graphic, \ ; INPUT
                                     stype     :string,  \ ; INPUT
                                     height    :float,   \ ; INPUT
                                     data      :float,   \ ; INPUT
                                     error     :float,   \ ; INPUT
                                     fre1      :float)     ; INPUT

begin
;  DEFINE VARIABELS
   nheights  = dimsizes(height)
   i         = 1
   minfre    = 0.0
   maxfre    = 0.05
   frestride = 0.005
   npts      = 11
   colorst   = 2
   colored   = 220
   nlevels   = (maxfre-minfre)/frestride + 2
   inlevels  = toint(nlevels)
   interval  = toint((colored-colorst)/nlevels)
   colors    = ispan(colorst, colored, interval)
;----------------------------------------------------------------------
;  SET UP RESOURCES OF FREQUENCY AND ERROR BAR PLOT FOR CALIPSO
   res                        = True 
   res@xyMarkLineMode         = "Markers"
   res@xyMarkers              = 16
   res@trXMinF                = 0.0
   res@trXMaxF                = 0.04
   res@trYMinF                = 0.0
   res@trYMaxF                = 10.0
   res@tiXAxisString          = "AOD (532 nm)"
   res@tiYAxisString          = "Z AGL (km)"
   res@tiMainString           = "CALIPSO " + stype
   res@gsnDraw                = False
   res@gsnFrame               = False

;----------------------------------------------------------------------
;  SET UP RESOURCES OF ERROR BAR FOR CALIPSO
   eres                       = True
   eres@gsLineColor           = "black"
   eres@gsLineThicknessF      = 2.0
;----------------------------------------------------------------------
; SET UP RESOURCES OF LABEL BAR FOR BOTH CALIPSO AND WRFCHEM
   lbres                      = True
   lbres@lbAutoManage         = False
   lbres@pmLabelBarDisplayMode= False
; NO MARGINS AROUND LABELBAR
   lbres@lbBottomMarginF      = 0.0
   lbres@lbLeftMarginF        = 0.0
   lbres@lbRightMarginF       = 0.0
   lbres@lbTopMarginF         = 0.0
; TURN VARIOUS FEATURES ON AND OFF
   lbres@lbLabelsOn           = True
   lbres@lbPerimOn            = False
   lbres@lbTitleOn            = False
   lbres@lbMonoFillPattern    = True
   lbres@lbOrientation        = "Vertical"
   lbres@lbLabelFontHeightF   = 0.013
   lbres@lbLabelStride        = 2
   lbres@lbBoxLinesOn         = False
; SET UP COLOR BAR
   lbres@tiMainFontHeightF    = 0.02
   lbres@lbTitleOn            = True
   lbres@lbTitleFontHeightF   = 0.015
   lbres@lbTitlePosition      = "Top"
   lbres@lbBoxMinorExtentF    = 1.0
   lbres@lbBoxLineColor       = "White"
; WHICH POINT TO POSITION LABELBAR ABOUT
   lbres@lbJustification      = "BottomRight"
   lbres@lbLabelAlignment     = "InteriorEdges"
   lbres@lbLabelAutoStride    = True
   lbres@lbLabelJust          = "CenterLeft"
   lbres@lbLabelOffsetF       = 0.6
   lbres@pmLabelBarWidthF     = 0.01
; SET INITIAL WIDTH AND HEIGHT
   lbres@vpHeightF            = 0.4
   lbres@vpWidthF             = 0.02
; SET UP RESOURCES OF LABEL BAR FOR CALIPSO
   lbres@lbFillColors         = colors
   lbres@lbTitleString        = "F(%)"
   if (.not. all(ismissing(data)) .and. \
       .not. all(ismissing(height)) .and. \
       .not. all(ismissing(fre1)))then
    plot = gsn_csm_xy(wks, data, height, res)
;  DEFINE LABEL BAR VARIABLES
    mlabels = fspan(minfre, maxfre, npts)
    llabels = mlabels*100. + ""
    lb      = gsn_create_labelbar_ndc(wks, npts+1, llabels, 0.9, 0.7, lbres)
    draw(lb)
;  PLOT ERROR BAR
    do j = 0, nheights-1
     if(.not.ismissing(data(j)) .and. \
        .not.ismissing(error(j))) then
      gsn_polyline(wks, plot, (/data(j), data(j)+error(j)/),          \
                              (/height(j), height(j)/), eres)
      gsn_polyline(wks, plot, (/data(j)+error(j), data(j)+error(j)/), \
                              (/height(j)-0.1, height(j)+0.1/), eres)
     end if
    end do
;  PLOT FREQUENCY IN EACH LAYER
    do l = 0, nheights-1
     if ( .not.ismissing(data(l)) .and. data(l) .ne. 0.03) then
     do k = 0, inlevels-2
      if(ismissing(fre1(l)))then
       pmcolor = 0
      end if
      if (.not.ismissing(fre1(l)) .and. k .lt. (inlevels-2) .and. \
          fre1(l) .ge. mlabels(k) .and. fre1(l) .lt. mlabels(k+1))then
       pmcolor = colors(k+1)
      end if
      if (.not.ismissing(fre1(l)) .and. k .eq. (inlevels-2) .and. \
          fre1(l) .ge. mlabels(k))then
       pmcolor = colors(k+1)
      end if
     end do
      add_markers(wks, plot, data(l), height(l), pmcolor, 16, 0.0075, 3.8)
     end if
     if ( .not.ismissing(data(l)) .and. data(l) .eq. 0.03) then
      add_markers(wks, plot, data(l), height(l), "grey20", 16, 0.01, 1.0)
     end if
    end do
    draw(plot)
;  SET UP TEXT RESOURCES
    tres                       = True
    tres@txPerimOn             = False
    tres@txFontHeightF         = 0.012
    tres@txBackgroundFillColor = 0
    tres@gsnframe              = True
    gsn_text_ndc(wks," Cloud ", 0.943, 0.308, tres)
    frame(wks)
  end if
 end
