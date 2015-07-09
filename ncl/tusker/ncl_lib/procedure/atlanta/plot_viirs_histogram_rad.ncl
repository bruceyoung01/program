;  $ID: plot_viirs_histogram_rad.ncl V01 02/23/2013 15:54 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE plot_viirs_histogram_rad PLOTS THE HISTOGRAM OF VIIRS DNB RADIANCE 
;  IN DIFFERENT BINS.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (02/23/2013)
;******************************************************************************
undef("plot_viirs_histogram_rad")
procedure plot_viirs_histogram_rad \
         (wks         :graphic,   bv0         :string,  \; INPUT
          bv2         :float,                           \; INPUT
          date        :string,    data        :float)    ; INPUT

begin
;  CALCULATE THE # OF GRIDS IN EACH BIN
   minl     = 0.0
   maxl     = 1.1
   nbin     = 12
   bin      = fspan(minl, maxl, nbin)
   sbin     = new((/nbin/), string, bv0)
   sbin         = flt2string(bin)
   sbin(nbin-1) = "~F18~x~F21~"
   minv     = 1.0
   maxv     = 12.0
   nv       = 12
   value    = fspan(minv, maxv, nv)
   fre      = new((/nbin/), float, bv2)
   oned_data= ndtooned(data)
   do i = 0, nbin-1
    if (i .le. nbin-2) then
     index   = ind(oned_data .ge. bin(i) .and. \
                   oned_data .lt. bin(i+1))
    else
     index   = ind(oned_data .ge. bin(i))
    end if
    if (.not.all(ismissing(index))) then
     fre(i) = dimsizes(index)
    end if
    delete([/index/])
   end do
   fre = fre/sum(fre)*100

;  PLOT THE HISTOGRAM 
   bres                         = True
   bres@gsnDraw                 = True
   bres@gsnFrame                = True
   bres@gsnXYBarChart           = True
   bres@gsnXYBarChartBarWidth   = 0.5
   bres@trXMinF                 = minv
   bres@trXMaxF                 = maxv
   bres@trYMinF                 = 0.01
   bres@trYMaxF                 = 110
   bres@trYAxisType             = "LogAxis"
   bres@tiXAxisString           = "Radiance (Wm~S~-2~N~str~S~-1~N~~F33~m~F21~m~S~-1~N~)"
   bres@tiYAxisString           = "Frequency(%)"
   bres@tiMainString            = date + "  VIIRS DNB Radiance Frequency"
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
;  SET INITIAL WIDTH AND HEIGHT
   bres@vpHeightF               = 0.4
   bres@vpWidthF                = 0.8
   bres@vpXF                    = 0.15
   bres@vpYF                    = 0.7
   plot = gsn_csm_xy(wks, value+0.5, fre, bres)

end
