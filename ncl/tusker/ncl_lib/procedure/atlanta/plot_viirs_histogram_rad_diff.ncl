;  $ID: plot_viirs_histogram_rad_diff.ncl V01 02/23/2013 15:54 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE plot_viirs_histogram_rad_diff PLOTS THE HISTOGRAM OF VIIRS DNB 
;  RADIANCE IN DIFFERENT BINS.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (02/23/2013)
;******************************************************************************
undef("plot_viirs_histogram_rad_diff")
procedure plot_viirs_histogram_rad_diff \
         (wks         :graphic,   bv0         :string,  \; INPUT
          bv2         :float,     data1       :float,   \; INPUT
          data2       :float)                            ; INPUT

begin
;  CALCULATE THE # OF GRIDS IN EACH BIN
   minl      = 0.0
   maxl      = 1.1
   nbin      = 12
   bin       = fspan(minl, maxl, nbin)
   sbin      = new((/nbin/), string, bv0)
   sbin         = flt2string(bin)
   sbin(nbin-1) = "~F18~x~F21~"
   minv      = 1.0
   maxv      = 12.0
   nv        = 12
   value     = fspan(minv, maxv, nv)
   fre1      = new((/nbin/), float, bv2)
   fre2      = new((/nbin/), float, bv2)
   fre       = new((/nbin/), float, bv2)
   oned_data1= ndtooned(data1)
   print(max(oned_data1))
   do i = 0, nbin-1
    if (i .le. nbin-2) then
     index   = ind(oned_data1 .ge. bin(i) .and. \
                   oned_data1 .lt. bin(i+1))
    else
     index   = ind(oned_data1 .ge. bin(i))
    end if
    if (.not.all(ismissing(index))) then
     fre1(i) = dimsizes(index)
    end if
    delete([/index/])
   end do
   fre1 = fre1/sum(fre1)*100

   oned_data2= ndtooned(data2)
   do i = 0, nbin-1
    if (i .le. nbin-2) then
     index   = ind(oned_data2 .ge. bin(i) .and. \
                   oned_data2 .lt. bin(i+1))
    else
     index   = ind(oned_data2 .ge. bin(i))
    end if
    if (.not.all(ismissing(index))) then
     fre2(i) = dimsizes(index)
    end if
    delete([/index/])
   end do
   fre2 = fre2/sum(fre2)*100
   fre  = fre1 - fre2
print(fre1)
print(fre2)
print(fre)
;  PLOT THE HISTOGRAM 
   bres                         = True
   bres@gsnDraw                 = True
   bres@gsnFrame                = True
   bres@gsnXYBarChart           = True
   bres@gsnXYBarChartBarWidth   = 0.5
   bres@trXMinF                 = minv
   bres@trXMaxF                 = maxv
   bres@trYMinF                 = -3.0
   bres@trYMaxF                 =  1.5
;  bres@trYAxisType             = "LogAxis"
   bres@tiXAxisString           = "Radiance (Wm~S~-2~N~str~S~-1~N~~F33~m~F21~m~S~-1~N~)"
   bres@tiYAxisString           = "Frequency Difference (%)"
   bres@tiMainString            = "VIIRS DNB Radiance Frequency " + "09/25/2012-10/25/2012"
   bres@tiMainFontHeightF       = 0.02
   bres@tmXBMode                = "Explicit"
   bres@tmXBValues              = value
   bres@tmXBLabels              = sbin
   bres@tmXBLabelFontHeightF    = 0.025
   bres@tmXBLabelFontThicknessF = 0.8
   bres@tmXBMajorThicknessF     = 0.5
   bres@tmYLLabelFontHeightF    = 0.025
   bres@tmYLLabelFontThicknessF = 0.8
   bres@tmYLMajorThicknessF     = 0.5
   bres@gsnXYBarChartColors     = (/"black"/)
   bres@gsnXYBarChartPatterns   = 6
   bres@gsnYRefLine             = 0.0
;  SET INITIAL WIDTH AND HEIGHT
   bres@vpHeightF               = 0.4
   bres@vpWidthF                = 0.75
   bres@vpXF                    = 0.2
   bres@vpYF                    = 0.7
   plot = gsn_csm_xy(wks, value+0.5, fre, bres)

end
