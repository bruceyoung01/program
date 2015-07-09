;  $ID: color_table_2d.ncl V01 10/30/2012 10:53 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM color_table_2d PLOTS 2-DIMENDIONAL COLOR TABLE WITH X-AXIS, AND 
;  Y-AXIS.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (10/30/2012)
;******************************************************************************
;
;  LOAD FUNCTIONS AND PROCEDURES
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/function/int2string.ncl"

begin
;  SET UP THE PLOT PLATFORM
;  type      = "x11" 
   type      = "pdf"
;  type      = "ps"
;  type      = "png"
   wks       = gsn_open_wks(type, "1plt_color_table_2d_v02")
   gsn_define_colormap(wks, (/"White", "Black"/))

;  ASSIGN COORDINATE VALUES
   bv1       = -999
   xbegin    = 0
   xend      = 20
   ybegin    = 0
   yend      = 10
   sd_factor = 0.5
   ms_factor = 1./yend
   x         = ispan(xbegin, xend, 1)*sd_factor
   y         = ispan(ybegin, yend, 1)*ms_factor

;  ASSIGN COLOR INDEX
   ncolors1  = yend
   ncolors2  = xend
   hues      = fspan(60.0, 360.0, ncolors1*ncolors2)
   sats      = fspan(0.8, 0.8, ncolors1)
   vals      = fspan(0.3, 1.0, ncolors2)

;  SET UP XY IMAGE RESOURCES
   res                    = True
   res@gsnDraw            = False
   res@gsnFrame           = False
   res@xyMarkLineMode     = "Markers"
   res@xyMarkers          = 1
   res@xyMarkerColor      = "white"
   res@xyMarkerSizes      = 0.00001
   res@xyMarkerThicknessF = 0.00001
   res@trXMaxF            = xend*sd_factor
   res@trXMinF            = 0.0
   res@trYMaxF            = 1.0
   res@trYMinF            = 0.0

;  TITLE
   res@tiXAxisString      = "Smoke Mass Concentration" + "(~F33~m~F0~g/m~S~3~N~)"
   res@tiYAxisString      = "Smoke/(Dust+Smoke)"

; SET UP THE POSITION OF THE CONTOUR PLOT
   res@vpWidthF           = 0.6
   res@vpHeightF          = 0.15
   res@vpXF               = 0.2
   res@vpYF               = 0.8     

;  PLOT XY IMAGE
   plot      = gsn_csm_xy(wks, x*0, y, res)

;  DECLARE TWO 1-D ARRAY TO HOLD COORDINATES OF THE PLOYGON
   xp        = new((/4/), float)
   yp        = new((/4/), float)
   rgb1_out  = new((/3, 200/), integer, bv1)

;  SET POLYHON RESOURCES
   pres      = True
   icount    = 0
   do i = 0, yend-1
     sat = sats(i)
    do j = 0, xend-1
     hue   = hues(icount)
     val   = vals(j)
     rgb   = hsvrgb((/hue, sat, val/))
     rgb1  = floattoint(rgb*255)
     red   = rgb(0)
     green = rgb(1)
     blue  = rgb(2)
;    print(red + " a " + green + " b " + blue)
;    print("aa" + i + "b" + j)
     xp = (/x(j), x(j), x(j)+sd_factor*(j+1), x(j)+sd_factor*(j+1)/)
     yp = (/y(i), y(i)+ms_factor*(i+1), y(i)+ms_factor*(i+1), y(i)/)
;    print(xp + "||" + yp)
     pres@gsFillColor = NhlNewColor(wks, red, green, blue)
;    print(pres@gsFillColor)
     gsn_polygon(wks, plot, xp, yp, pres)
;  PREPARE DATA FOR OUTPUT
     rgb1     = floattoint(rgb*255)
     rgb1_out(:, icount) = rgb1
     icount = icount + 1
;    print(icount)
    end do
   end do
   draw(plot)
   frame(wks)

;  WRITE THE COLOR TABLE INTO A FILE
;  ============================================================================
;  METHOD1 : USE asciiwrite
   lines = sprinti("%4.0i", rgb1_out(0, :)) + \
           sprinti("%4.0i", rgb1_out(1, :)) + \
           sprinti("%4.0i", rgb1_out(2, :))
   asciiwrite("color_map_2d_200.rgb", lines)
;  ============================================================================
;  METHOD2 : USE write_matrix (TO BE CONTINUED)
;  opt      = True
;  opt@title = "ncolors= 225 ~C~" + \
;              "#  r   g   b"
;  write_matrix(rgb1_out, "3i4.0", opt)
end
