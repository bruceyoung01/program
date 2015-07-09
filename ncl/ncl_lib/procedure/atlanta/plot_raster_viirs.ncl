;  $ID: plot_raster_viirs.ncl V01 01/31/2013 10:50 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM plot_raster_viirs PLOTS VIIRS PIXEL DATA DIRECTLY AS 
;  CONTOUR WITH RASTERFILL.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (02/12/2013)
;******************************************************************************

undef("plot_raster_viirs")
procedure plot_raster_viirs \
         (wks      :graphic,     i        :integer, \; INPUT
          x        :float,       y        :float,   \; INPUT
          date     :integer,                        \; INPUT
          sitename :string,      data     :float)    ; INPUT

begin

;  CONVERT DATE TO STRING
   cdate = int2string_format(date(0), False, 4, 4) + "-" + \
           int2string_format(date(1), False, 2, 2) + "-" + \
           int2string_format(date(2), False, 2, 2) + "-" + \
           int2string_format(date(3), False, 2, 2)
   ci    = int2string(i+1)

  res                      = True
  res@gsnMaximize          = True          ; Maximize plot in frame.

  res@cnFillOn             = True          ; Turn on contour fill
  res@cnFillMode           = "RasterFill"  ; Turn on raster fill
  res@cnLinesOn            = False         ; Turn off contour lines

  res@cnLevelSelectionMode = "ManualLevels"
  res@cnMinLevelValF       = 0
  res@cnMaxLevelValF       = 1
  res@cnLevelSpacingF      = 0.05
  res@lbLabelStride        = 2
  res@lbBoxLinesOn         = False
  res@lbTitleString        = "VIIRS DNB Radiance at 700nm (Wm~S~-2~N~str~S~-1~N~~F33~m~F21~m~S~-1~N~)"
  res@lbTitlePosition      = "bottom"
  res@lbTitleFontHeightF   = 0.02
  res@tiMainString         = "VIIRS Pixel  " + cdate + "  " + sitename + " " + ci

  res@tmXBMinorOn          = False
  res@tmXBFormat           = "f"
  res@tmYLFormat           = "f"
  res@gsnDraw              = False
  res@gsnFrame             = False

;
; By adding extra element to X,Y axes values, we can get
; full rasters at the boundary.
;
  res@sfXArray = x    ; One more element in both
  res@sfYArray = y    ; X and Y
  
  plot = gsn_csm_contour(wks,data,res)
  draw(plot)

; PLOT PIXEL NUMBER ON THE PIXEL
  ndim   = dimsizes(data)

  do j = 0, ndim(1) - 1
     do i = 0, ndim(0) - 1
     index1 = ind(.not.ismissing(data(j, i)))
     pncres                    = True
     pncres@txFontColor        = "deeppink"
     pncres@txFontHeightF      = 0.05
     if (.not.all(ismissing(index1))) then
        icount =  j*ndim(1) + i + 1
        ccount = int2string(icount)
        gsn_text(wks, plot, ccount, x(i)+0.5, y(j)+0.5, pncres)
     end if
     delete(index1)
     end do
  end do
  frame(wks)

end

