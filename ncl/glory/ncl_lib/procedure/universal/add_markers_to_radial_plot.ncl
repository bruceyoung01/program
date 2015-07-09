;----------------------------------------------------------------------
; This procedure adds markers to an existing radial plot, given:
;
;
;   plot  : the radial background plot created with radial_plot
;   dvals : the values used to determine marker size and color
;   xarr, yarr: the x and y location
;  
; NOTES:
; =====================================================================
; (1 ): ORIGINALLY FROM NCL WEBSITE: (11/20/2011)
;       http://www.ncl.ucar.edu/Applications/Scripts/radar_3.ncl
; (2 ): MODIFIED BY BRUCE. (11/20/2011)
;----------------------------------------------------------------------

procedure add_markers_to_radial_plot(wks,plot,dvals,ranges,angles,levels,res)
local radius, radius, xcenter, ycenter, nlevels, sizes, colors,
mkres, dum_fill, dum_hollow, i, ii, tmpstr, xarr, yarr
begin
  res2    = res
  radius  = get_res_value_keep(res2,"rdlRadius",240)
  xcenter = get_res_value_keep(res2,"rdlXCenter",0)
  ycenter = get_res_value_keep(res2,"rdlYCenter",0)
  nlevels = dimsizes(levels)
    
;---Calculate cartesian coordinates given angle and range.
  xarr = xcenter+(ranges*cos(DEGTORAD*angles))
  yarr = ycenter+(ranges*sin(DEGTORAD*angles))

;
; For each level, we want a different size and color for the marker.
; You may need to change sizes and/or colors if they do not have
; enough values to represent all of your levels.
;
  sizes  = ispan(25,75,5)/1000.    ; 0.0025 to 0.0075
  colors = (/"limegreen","orange","green","red","yellow","purple","blue",\
             "red","brown","red2","skyblue"/)
  nsizes  = dimsizes(sizes)
  ncolors = dimsizes(colors)

;---Error checking.
  if(any((/ncolors,nsizes/).lt.(nlevels-1))) then
     print("add_markers_to_radial_plot: warning: you don't have enough colors (" + \
           ncolors + ") and/or marker sizes (" + nsizes + \
           ") for the number of levels (" + (nlevels-1) + ").")
  end if

;---Arrays for attaching two sets of markers
  dum_fill   = new(nlevels-1,graphic)
  dum_hollow = new(nlevels-1,graphic)

;---Resource list for customizing markers.
  mkres = True

  mkres@gsMarkerThicknessF = 2.0      ; Twice as thick
;
; For each set of levels, gather the data that falls
; between two levels, and draw the set of markers at those
; locations.
;
  do i=0,nlevels-2
    ii = ind(levels(i).le.dvals.and.dvals.lt.levels(i+1))

    print("There are " + dimsizes(ii) + " points b/w levels " + \
           levels(i) + " and " + levels(i+1))

;---Filled dots
    mkres@gsMarkerIndex = 16
    mkres@gsMarkerSizeF = sizes(i)
    mkres@gsMarkerColor = colors(i)

    tmpstr = unique_string("fill")
    plot@$tmpstr$ = gsn_add_polymarker(wks,plot,xarr(ii),yarr(ii),mkres)

;---Hollow dots (to get outlines of the solid dots)
    mkres@gsMarkerIndex = 4           ; Hollow dots
    mkres@gsMarkerColor = "black"

    tmpstr = unique_string("hollow")
    plot@$tmpstr$ = gsn_add_polymarker(wks,plot,xarr(ii),yarr(ii),mkres)
    delete(ii)
  end do
end
