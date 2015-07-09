;  $ID: plot_raster_viirs_pixel_fre_group.ncl V01 02/11/2014 08:26 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM plot_raster_viirs_pixel_fre_group PLOTS VIIRS PIXEL DATA DIRECTLY AS 
;  CONTOUR WITH RASTERFILL, WITH THE SAME POSITION AS VIIRS, ALSO WITH 
;  FREQUENCY FOR EACH SELECTED PIXEL
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (02/11/2014)
;  (2 ) MODIFIED FROM plot_raster_viirs_pixel.ncl BY ADDING FREQUENCY FOR EACH 
;       PIXEL. (02/11/2014)
;******************************************************************************

undef("plot_raster_viirs_pixel_fre_group")
procedure plot_raster_viirs_pixel_fre_group \
         (wks      :graphic,     icount   :integer, \; INPUT
          x        :float,       y        :float,   \; INPUT
          date     :integer,     isite    :integer, \; INPUT
          sitename :string,      data     :float,   \; INPUT
          fre      :float,                          \; INPUT
          plot     :graphic)                         ; OUTPUT

begin

;  CONVERT DATE TO STRING
   cdate = int2string_format(date(0), False, 4, 4) + "-"  + \
           int2string_format(date(1), False, 2, 2) + "-"  + \
           int2string_format(date(2), False, 2, 2) + " G" + \
           int2string_format(date(3), False, 2, 2)
   ci    = int2string(icount)

  res                      = True
  res@gsnMaximize          = True          ; Maximize plot in frame.

  res@cnFillOn             = True          ; Turn on contour fill
  res@cnFillMode           = "RasterFill"  ; Turn on raster fill
  res@cnLinesOn            = False         ; Turn off contour lines

  res@cnLevelSelectionMode = "ManualLevels"
  res@cnMinLevelValF       = 0
  res@cnMaxLevelValF       = 1
  res@cnLevelSpacingF      = 0.05
  res@lbLabelStride        = 4
  res@lbBoxLinesOn         = False
  res@lbTitleString        = "VIIRS DNB Radiance at 700nm (Wm~S~-2~N~str~S~-1~N~~F33~m~F21~m~S~-1~N~)"
  res@lbTitlePosition      = "bottom"
  res@lbTitleFontHeightF   = 0.02
  res@tiMainString         = "VIIRS Pixel  " + cdate + "  " + sitename + " " + ci

  res@tmXBMinorOn          = False
  res@tmXBLabelStride      = 1.0
  res@tmXBFormat           = "f"
  res@tmXBMode             = "Explicit"
  res@tmXBValues           = x
  res@tmXBLabels           = flt2string(x)
  res@tmYLMinorOn          = False
  res@tmYLFormat           = "f"
  res@tmYLMode             = "Explicit"
  res@tmYLValues           = y
  res@tmYLLabels           = flt2string(y)
  res@tmLabelAutoStride    = True
  res@gsnDraw              = False
  res@gsnFrame             = False

;
; By adding extra element to X,Y axes values, we can get
; full rasters at the boundary.
;
  res@sfXArray = x    ; One more element in both
  res@sfYArray = y    ; X and Y
  
  plot = gsn_csm_contour(wks,data,res)
; draw(plot)

; PLOT PIXEL NUMBER ON THE PIXEL

  pncres                    = True
  pncres@txFontColor        = "deeppink"
  pncres@txFontHeightF      = 0.025
  pncres@gsnDraw            = False
  pncres@gsnFrame           = False

; CONVERT FREQUENCY FROM INTEGER TO STRING
  sfre = sprintf("%5.2f", fre*100)

  ndim   = dimsizes(data)
  icount = 0
; FOR SITE A, B, C
  if (isite .eq. 0 .or. \
      isite .eq. 1 .or. \
      isite .eq. 2) then
     do i = ndim(0) - 1, 0, 1
        do j = ndim(1) - 1, 0, 1
;          print(i + " :: " + j)
;          print("data = " + data(i, j))
           if (.not.all(ismissing(data(i, ndim(1)-1-j)))) then
              icount = icount + 1
;             print("x = " + (x(ndim(1)-1-j)+0.5))
;             print("y = " + (y(ndim(0)-1-i)+0.5))
;             print("icount = " + icount)
              ccount = int2string(icount)
              pncres@txFontColor = "deeppink"
              if (.not.(ismissing(fre(i, ndim(1)-1-j))) .and. \
                  fre(i, ndim(1)-1-j) .ge. 0.3) then
                 pncres@txFontColor = "green"
              end if
              plot1 = gsn_add_text(wks, plot, ccount, x(ndim(1)-1-j)+0.5, y(i)+0.75, pncres)
              plot2 = gsn_add_text(wks, plot, sfre(i, ndim(1)-1-j) + "%", x(ndim(1)-1-j)+0.5, y(i)+0.25, pncres)
           end if
        end do
     end do
  end if
; FOR SITE D
  if (isite .eq. 3) then
     icountd = (/5, 2, 1, 4, 3/)
     do i = 0, 4
        pncres@txFontColor = "deeppink"
        if (icountd(i) .eq. 1) then
           ccount = int2string(icountd(i))
           if (fre(1, 0) .ge. 0.3) then
              pncres@txFontColor = "green"
           end if
           plot1  = gsn_add_text(wks, plot, ccount, x(2)+0.5, y(1)+0.75, pncres)
           plot2  = gsn_add_text(wks, plot, sfre(1, 0) + "%", x(2)+0.5, y(1)+0.25, pncres)
        end if
        if (icountd(i) .eq. 2) then
           ccount = int2string(icountd(i))
           if (fre(1, 1) .ge. 0.3) then
              pncres@txFontColor = "green"
           end if
           plot1  = gsn_add_text(wks, plot, ccount, x(1)+0.5, y(1)+0.75, pncres)
           plot2  = gsn_add_text(wks, plot, sfre(1, 1) + "%", x(1)+0.5, y(1)+0.25, pncres)
        end if
        if (icountd(i) .eq. 3) then
           ccount = int2string(icountd(i))
           if (fre(1, 2) .ge. 0.3) then
              pncres@txFontColor = "green"
           end if
           plot1  = gsn_add_text(wks, plot, ccount, x(2)+0.5, y(0)+0.75, pncres)
           plot2  = gsn_add_text(wks, plot, sfre(1, 2) + "%", x(2)+0.5, y(0)+0.25, pncres)
        end if
        if (icountd(i) .eq. 4) then
           ccount = int2string(icountd(i))
           if (fre(0, 1) .ge. 0.3) then
              pncres@txFontColor = "green"
           end if
           plot1  = gsn_add_text(wks, plot, ccount, x(1)+0.5, y(0)+0.75, pncres)
           plot2  = gsn_add_text(wks, plot, sfre(0, 1) + "%", x(1)+0.5, y(0)+0.25, pncres)
        end if
        if (icountd(i) .eq. 5) then
           ccount = int2string(icountd(i))
           if (fre(0, 2) .ge. 0.3) then
              pncres@txFontColor = "green"
           end if
           plot1  = gsn_add_text(wks, plot, ccount, x(0)+0.5, y(1)+0.75, pncres)
           plot2  = gsn_add_text(wks, plot, sfre(0, 2) + "%", x(0)+0.5, y(1)+0.25, pncres)
        end if

     end do
  end if

; FOR SITE E, CTR
  if (isite .eq. 4 .or. \
      isite .eq. 5) then
     do j = ndim(1) - 1, 0, 1
        do i = ndim(0) - 1, 0, 1
;          print(i + " :: " + j)
;          print("data = " + data(i, j))
           if (.not.all(ismissing(data(i, ndim(1)-1-j)))) then
              icount = icount + 1
;             print("x = " + (x(ndim(1)-1-j)+0.5))
;             print("y = " + (y(ndim(0)-1-i)+0.5))
;             print("icount = " + icount)
              ccount = int2string(icount)
              pncres@txFontColor = "deeppink"
              if (fre(i, ndim(1)-1-j) .ge. 0.3) then
                 pncres@txFontColor = "green"
              end if
              plot1 = gsn_add_text(wks, plot, ccount, x(ndim(1)-1-j)+0.5, y(i)+0.75, pncres)
              plot2 = gsn_add_text(wks, plot, sfre(i, ndim(1)-1-j) + "%", x(ndim(1)-1-j)+0.5, y(i)+0.25, pncres)
           end if
        end do
     end do
  end if

; frame(wks)

end

