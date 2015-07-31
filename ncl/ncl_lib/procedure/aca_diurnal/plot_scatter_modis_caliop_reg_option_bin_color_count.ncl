;  $ID: plot_scatter_modis_caliop_reg_option_bin_color.ncl 07/15/2015 09:10 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE plot_scatter_modis_caliop_reg_option_bin_color.ncl PLOTS SCATTER PLOT 
;  FOR TWO VARIABLES WITH VARIOUS DIMENSIONS, AND ADDS REGRESSION LINE WITH 
;  STATISTICAL VARIABLES, AND VARIOUS COLOR POINTS.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) wks     (workstation):WORK STATION                               [   ]
;  (2 ) stime      (a string):ATTRIBUTES                                 [   ]
;  (3 ) xtick_name (a string):X AXIS NAME                                [   ]
;  (4 ) ytick_name (a string):Y AXIS NAME                                [   ]
;  (5 ) xmin       (a scalar):MINIMUM VALUE OF X AXIS                    [   ]
;  (6 ) xmax       (a scalar):MAXIMUM VALUE OF X AXIS                    [   ]
;  (7 ) ymin       (a scalar):MINIMUM VALUE OF Y AXIS                    [   ]
;  (8 ) ymax       (a scalar):MAXIMUM VALUE OF Y AXIS                    [   ]
;  (9 ) data1           (X-D):DATA1 FOR X AXIS                           [   ]
;  (10) data1_fre       (X-D):DATA1 FREQUENCY IN EACH BIN                [   ]
;  (11) data2           (X-D):DATA2 FOR Y AXIS                           [   ]
;  (12) data2_std       (X-D):DATA2 STANDARD DEVIATION                   [   ]
;  (13) data2_count     (X-D):DATA2 COUNT IN EACH BIN                    [   ]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (07/15/2015)
;******************************************************************************
undef("plot_scatter_modis_caliop_reg_option_bin_color_count")
procedure plot_scatter_modis_caliop_reg_option_bin_color_count \
          (wks        :graphic,  stime        :string,   \;INPUT
           xtick_name :string,   ytick_name   :string,   \;INPUT
           xmin       :numeric,  xmax         :numeric,  \;INPUT
           ymin       :numeric,  ymax         :numeric,  \;INPUT
           data1      :numeric,  data1_fre    :numeric,  \;INPUT
           data2      :numeric,  data2_std    :numeric,  \;INPUT
           data2_count:integer)                           ;INPUT

begin

   bv2          = -9999.
   oned_data1   = ndtooned(data1)
   oned_data2   = ndtooned(data2)
   npts         = dimsizes(oned_data1)

;  SET UP THE POSITION OF THE SCATTER PLOT
   res                        = True
   res@vpWidthF               = 0.7
   res@vpHeightF              = 0.7
   res@vpXF                   = 0.17
   res@vpYF                   = 0.85
   res@gsnDraw                = False
   res@gsnFrame               = False
   res@trXMaxF                = xmax
   res@trXMinF                = xmin
   res@trYMaxF                = ymax
   res@trYMinF                = ymin
;  res@trYReverse             = True
   res@tmXBMajorLengthF       = 0.01
   res@tmXBMinorLengthF       = 0.005
   res@tmXBMajorOutwardLengthF= 0.0
   res@tmXBMinorOutwardLengthF= 0.0
   res@tmXTMajorLengthF       = 0.01
   res@tmXTMinorLengthF       = 0.005
   res@tmXTMajorOutwardLengthF= 0.0
   res@tmXTMinorOutwardLengthF= 0.0
   res@tmYLMajorLengthF       = 0.01
   res@tmYLMinorLengthF       = 0.005
   res@tmYLMajorOutwardLengthF= 0.0
   res@tmYLMinorOutwardLengthF= 0.0
   res@tmYRMajorLengthF       = 0.01
   res@tmYRMinorLengthF       = 0.005
   res@tmYRMajorOutwardLengthF= 0.0
   res@tmYRMinorOutwardLengthF= 0.0
;  res@xyXStyle               = "Log"
;  res@xyYStyle               = "Log"
;  SET RESOURCES FOR SCATTER PLOT
   ncolor                     = 200
   lmin                       = 0
   lmax                       = 10
   levels                     = ispan(lmin, lmax, 1)
   nlevels                    = dimsizes(levels)
   labels                     = new(nlevels,string)
   labels                     = ""
   labels                     = "" + levels
   nstep                      = ncolor/nlevels
   colors                     = ispan(2, ncolor, nstep)
   res@xyDashPatterns         = 1
   res@xyMarkLineModes        = (/"Markers"/)
   res@xyMarkers              = 16
   res@xyMarkerSizes          = 6
   res@xyMarkerColors         = "White"
;  SET TITLE RESOURCES
   res@tiMainFontHeightF      = 0.015
   res@tiMainString           = stime
   res@tiXAxisString          = xtick_name
   res@tiYAxisString          = ytick_name

   if (.not.all(ismissing(oned_data1)) .and. \
       .not.all(ismissing(oned_data2))) then

   plot = gsn_csm_xy(wks, oned_data1, oned_data2, res)

;  PLOT DOTS WITH VARIOUS COLOR BASED ON ITS VALUES
   data1_fre  = data1_fre*100
   overlays   = new(nlevels-1,graphic)

;  ASSIGN ALL THE data1_fre BIGGER THAN levels(nlevels-1) TO levels(nlevels-1)
   data1_fre  = where(data1_fre .gt. levels(nlevels-1), levels(nlevels-1), data1_fre)
   do ilevels = 0, nlevels-2
      index = ind(data1_fre .ge. levels(ilevels) .and. \
                  data1_fre .lt. levels(ilevels+1))
      nindex = dimsizes(index)
      if (nindex .ge. 1                          .and. \
          .not.all(ismissing(index))             .and. \
          .not.all(ismissing(oned_data1(index))) .and. \
          .not.all(ismissing(oned_data1(index)))) then
         res@xyMarkerColors = colors(ilevels)
;  FOR nindex = 1, IN ORDER TO AVIOD THE ERROR BELOW
;  fatal:CheckArray:Each vector in the caXArray array must have at least 2 elements
;  WE ADD ONE ELEMENT FOR PLOT, WITHOUT INFLUENCING THE FINAL RESULTS
         if (nindex .eq. 1) then
            overlays(ilevels)  = gsn_csm_xy(wks, (/oned_data1(index), bv2/), (/oned_data2(index), bv2/), res)
         else
            overlays(ilevels)  = gsn_csm_xy(wks, oned_data1(index), oned_data2(index), res)
         end if
         overlay(plot, overlays(ilevels))

;  SET UP RESOURCES OF ERROR BAR FOR CALIPSO
   eres                       = True
   eres@gsLineColor           = colors(ilevels)
   eres@gsLineThicknessF      = 2.0
   bar_width                  = (xmax-xmin)/100.
;  PLOT ERROR BAR
         if (.not.all(ismissing(oned_data1(index))) .and. \
             .not.all(ismissing(oned_data2(index))) .and. \
             .not.all(ismissing(data2_std(index)))) then
            do i = 0, nindex-1
;  CALCULATE THE CONFIDENCE LEVEL OF THE MEAN VALUES
               data2_conf = data2_std(index(i))*sqrt(data2_count(index(i))-2)
               gsn_polyline(wks, plot, (/oned_data1(index(i)),           \
                                         oned_data1(index(i))/),         \
                                       (/oned_data2(index(i))-data2_conf,\
                                         oned_data2(index(i))/), eres)
               gsn_polyline(wks, plot, (/oned_data1(index(i))-bar_width,   \
                                         oned_data1(index(i))+bar_width/), \
                                       (/oned_data2(index(i))-data2_conf,  \
                                         oned_data2(index(i))-data2_conf/), eres)
               gsn_polyline(wks, plot, (/oned_data1(index(i)),   \
                                         oned_data1(index(i))/), \
                                       (/oned_data2(index(i)),   \
                                         oned_data2(index(i))+data2_conf/), eres)
               gsn_polyline(wks, plot, (/oned_data1(index(i))-bar_width,   \
                                         oned_data1(index(i))+bar_width/), \
                                       (/oned_data2(index(i))+data2_conf,  \
                                         oned_data2(index(i))+data2_conf/), eres)
            end do
         end if
      end if
      delete([/index/])
   end do

;  ATTACH A COLOR BAR
   labelbar = attach_labelbar(wks, plot, labels, colors)

;  DRAW REGRESSION LINE
   lres                  = True
   lres@gsLineColor      = "deeppink"
   lres@gsLineThicknessF = 5.0
   if (.not.all(ismissing(oned_data2)))
;  CALCULATE STATISTIS BEWTEEN data1 AND data2
      rc      = regline_stats(oned_data1, oned_data2)
      cor     = rc@r2
      yreg    = rc*oned_data1 + rc@yintercept
      yregmin = rc*xmin + rc@yintercept
      yregmax = rc*xmax + rc@yintercept
      dum     = gsn_add_polyline(wks, plot, (/xmin, xmax/), (/yregmin, yregmax/), lres)
   end if

;  ADD STATISTICS INFO ON THE PLOT
;  SET UP TEXT RESOURCES
   tres               = True
   tres@txFontHeightF = 0.018
   gsn_text_ndc(wks,"Y   = ", 0.285, 0.82, tres)
   gsn_text_ndc(wks,sprintf("%5.2f", rc), 0.35, 0.82, tres)
   gsn_text_ndc(wks,"X + ", 0.40, 0.82, tres)
   gsn_text_ndc(wks,sprintf("%5.2f", rc@yintercept), 0.45, 0.82, tres)
   gsn_text_ndc(wks,"R~S~2~N~ = ", 0.285, 0.79, tres)
   gsn_text_ndc(wks,sprintf("%5.2f", cor), 0.335, 0.79, tres)
   gsn_text_ndc(wks,"N   = ", 0.285, 0.76,tres)
   gsn_text_ndc(wks,sprinti("%4.0i", rc@nptxy), 0.335, 0.76,tres)
   draw(plot)
   frame(wks)
   end if
end
