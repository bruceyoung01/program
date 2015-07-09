; CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
; PURPOSE OF THIS PROGRAM : 
; INTERPOLATE THE HEIGHT OVER EACH LAYER OF WRF-CHEM OUTPUT FILE
; THE METHOD USED IN THIS PROGRAM IS BASED ON THE ALGORITHM. THE STEPS ARE BELOW
; 1. READ DATA FROM THE WRF OUTPUT FILE
; 2. SET THE X, Y COORDINATE USING THE SUBROUTINE set_xy
; 3. INTERPOLATE ARW WRF 2D MODEL DATA ALONG A GIVEN LINE
;    USING SUBROUTINE interp_2d
; 4. INTERPOLATE ARW WRF MODEL DATA VERTICALLY OR HORIZONTALLY
;    USING SUBROUTINE intrp3d

;--------------------------------------------------------------------------------
undef("getvar")
function getvar( nc_file:file, varin[*]:string, time_in:integer )
local variable, time, var, u, v, u_in, v_in, pii, radians_per_degree, \
dims, nd, latitude, longitude, rank
begin

  variable = varin(0)
  time = time_in(0)


  if( any( variable .eq. (/"p","pres","pressure"/) ) ) then
       ; Full model pressure [=base pressure (PB) + pertubation pressure (P)]
       if(isfilevar(nc_file,"P")) then
         if ( time .eq. -1 ) then
           var = nc_file->P
           PB  = nc_file->PB
         else
           var = nc_file->P(time_in,:,:,:)
           PB  = nc_file->PB(time_in,:,:,:)
         end if
         var = var + PB
       else
         ;; may be a met_em file - see if we can get PRES
         if(isfilevar(nc_file,"PRES")) then
           if ( time .eq. -1 ) then
             var = nc_file->PRES
           else
             var = nc_file->PRES(time_in,:,:,:)
           end if
         end if
       end if
       var@description = "Pressure"
       if( variable .eq. "pressure" ) then
         var = var * 0.01
         var@units = "hPa"
       end if
       return(var)
  end if



  if( any( variable .eq. (/"geopt","geopotential","z","height"/) ) ) then
       ; Height [=full geopotentail height / 9.81]
       if(isfilevar(nc_file,"PH")) then
         if ( time .eq. -1 ) then
           var = nc_file->PH
           PHB = nc_file->PHB
         else
           var = nc_file->PH(time,:,:,:)
           PHB = nc_file->PHB(time,:,:,:)
         end if

         var = var + PHB
         z = wrf_user_unstagger(var,var@stagger)
         z@description = "Geopotential"

       else
         ;; may be a met_em file - see if we can get GHT - data in met_em file is Height in M
         if(isfilevar(nc_file,"GHT")) then
           if ( time .eq. -1 ) then
             z = nc_file->GHT
           else
             z = nc_file->GHT(time,:,:,:)
           end if
           z = z * 9.81
           z@description = "Geopotential"
           z@units       = "m2 s-2"
         end if
       end if

       if( any( variable .eq. (/"z","height"/) ) ) then
         z = z / 9.81
         z@description = "Height"
         z@units       = "m"
       end if
       return(z)
  end if
end

; CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
; PURPOSE OF THIS SUBROUTINE SET_XY
; 1. SPECIFY TWO POINTS
; 2. GET THE SLOPE OF CORSS LINE
; 3. DEPENDING ON THE SLOPE OF CROSS LINE AND THE COORDINATE OF FIRST POINT
;    GET THE COORDINATE OF OTHER POINTS ALONG THE CROSS LINE
; CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
undef("set_xy")
function set_xy( var:numeric, xp:numeric, yp:numeric, x1:numeric, \
                 y1:numeric, angle:numeric, opts )

; MASS COORDINATE VERSION OF NCL USER ROUTINES
; INPUT :
; VAR:NUMERIC--- WRF OUTPUT DATA
; #NOTE ON VAR : MOST VARIABLES IN WRF OUTPUT ARE FOUR DIMENSIONS
; #DIMS(0):TIME/DIMS(1):LEVEL/DIMS(2):LATITUDE/DIMS(3):LONGITUDE
; #HOWEVER, WHEN WE DEAL WITH THE DATA, WE JUST FIX ONE TIME. SO THE DIMENSION SIZE
; #OF VARIABLES BECOME THREE DIMENSIONS. THAT IS 
; #DIMS(0):LEVEL/DIMS(1):LATITUDE/DIMS(2):LONGITUDE
; XP:NUMERIC--- THE X COORDINATE OF BEGINING POINT
; YP:NUMERIC--- THE Y COORDINATE OF BEGINING POINT
; X1:NUMERIC--- THE X COORDINATE OF END POINT
; Y1:NUMERIC--- THE Y COORDINATE OF END POINT
; ANGLE:NUMERIC--- THE ANGLE OF CROSS LINE
; OPTS--- THE OPTIONAL SELECTION
; OUTPUT:
; ALL THE COORDINATE OF POINTS ON THE CROSS LINE
; IT'S A 2 DIMENSIONAL ARRAY

local dims,x,y,slope,intercept,distance,dx,dy,dxy,npts,xy

begin

; FIND INTERSECTION OF LINE AND DOMAIN BOUNDARIES
; GET THE DIMENSION SIZE OF DATA
  dims = dimsizes(var)
; WE HAVE A PIVOT POINT AND LOCATION AND NEED TO CALCULATE THE START AND END 
; POINTS OF THE CROSS SECTION
; FIND THE SLOPE OF THE CROSS LINE
  if (.not. opts) then
     if ((angle .gt. 315.) .or. (angle .lt. 45.) .or. \
         ((angle .gt. 135.) .and. (angle .lt. 225.)) )  then
          slope = -(360.-angle)/45.
          if( angle .lt. 45. ) then
            slope = angle/45.
          end if
          if( angle .gt. 135.) then
            slope = (angle-180.)/45.
          end if
          intercept = xp - yp*slope

; FIND INTERSECTIONS WITH DOMAIN BOUNDARIES DEPENDING ON THE CROSS LINE
          y0 = 0.
          x0 = y0*slope + intercept
; INTERSECT OUTSIDE OF LEFT BOUNDARY
          if( x0 .lt. 0.) then
            x0 = 0.
            y0 =  (x0 - intercept)/slope
          end if
; INTERSECT OUTSIDE OF RIGHT BOUNDARY
          if( x0 .gt. dims(2)-1) then
            x0 = dims(2)-1
            y0 =  (x0 - intercept)/slope
          end if
; MAKE SURE THIS WILL BE A FLOAT
          y1 = dims(1)-1.
          x1 = y1*slope + intercept
; INTERSECT OUTSIDE OF LEFT BOUNDARY
          if( x1 .lt. 0.) then
            x1 = 0.
            y1 =  (x1 - intercept)/slope
          end if
; INTERSECT OUTSIDE OF RIGHT BOUNDARY
          if( x1 .gt. dims(2)-1) then
            x1 = dims(2)-1
            y1 =  (x1 - intercept)/slope
          end if

     else

          slope = (90.-angle)/45.
          if( angle .gt. 225. ) then
            slope = (270.-angle)/45.
          end if
          intercept = yp - xp*slope

; FIND INTERSECTIONS WITH DOMAIN BOUNDARIES
          x0 = 0.
          y0 = x0*slope + intercept
; INTERSECT OUTSIDE OF BOTTOM BOUNDARY
          if( y0 .lt. 0.) then
            y0 = 0.
            x0 =  (y0 - intercept)/slope
          end if
; INTERSECT OUTSIDE OF TOP BOUNDARY
          if( y0 .gt. dims(1)-1) then
            y0 = dims(1)-1
            x0 =  (y0 - intercept)/slope
          end if
; MAKE SURE THIS WILL BE A FLOAT
          x1 = dims(2)-1.
          y1 = x1*slope + intercept
; INTERSECT OUTSIDE OF BOTTOM BOUNDARY
          if( y1 .lt. 0.) then
            y1 = 0.
            x1 =  (y1 - intercept)/slope
          end if
; INTERSECT OUTSIDE OF TOP BOUNDARY
          if( y1 .gt. dims(1)-1) then
            y1 = dims(1)-1
            x1 =  (y1 - intercept)/slope
          end if
; WE HAVE BEGINNING AND ENDING POINTS
     end if

  end if

; WE HAVE A SPECIFIED START AND END POINT
  if (opts) then
    x0 = xp
    y0 = yp
    if ( x1 .gt. dims(2)-1 ) then
      x1 = dims(2)
    end if
    if ( y1 .gt. dims(1)-1 ) then
      y1 = dims(1)
    end if
  end if

  dx = x1 - x0
  dy = y1 - y0
  distance = (dx*dx + dy*dy)^0.5
; BRUCE???
  npts = tointeger(distance)
  dxy = new(1,typeof(distance))
  dxy = distance/npts

  xy = new((/ npts, 2 /),typeof(x1))

  dx = dx/npts
  dy = dy/npts

  do i=0,npts-1
    xy(i,0) = x0 + i*dx
    xy(i,1) = y0 + i*dy
  end do

  return(xy)

end


; CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
; PURPOSE OF THIS SUBROUTINE : 
; INTERPOLATE THE 2-DIMENSIONAL DATA
; CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
undef("intrp2d")
function intrp2d( var2d:numeric, loc_param:numeric, \
                  angle:numeric, opts:logical )

; INPUT:
; VAR2D:NUMERIC--- 2 DIMENSION FIELD TO INTERPOLATE
; LOC_PARAM:NUMERIC--- PLANE FOR VERTICAL PLOTS (2 VALUES REPRESENTING AN XY POINT
;                      ON THE MODEL DOMAIN THROUGH WHICH THE VERTICAL PLANE WILL 
;                      PASS OR 4 VALUES SPECIFYING START AND END VALUES)
; ANGLE:NUMERIC--- 0.0 FOR HORIZONTAL PLOTS, AND AN ANGLE FOR VERTICAL PLOTS
;                  90 REPRESENTS A WEST-EAST CROSS SECTION
; OPTS--- USED IF OPTS IS TRUE, ELSE USE LOC_PARAM AND ANGLE TO DETERMINE CROSS SECTION
; OUTPUT:
; 2 DIMENSION ARRAY, DIMS(0): TIME/DIMS(1):THE NUMBER OF INTERPOLATED POINTS

begin
; GET THE DIMENSION INFORMATION OF THE VARIABLE AND DEFINE A NEW ARRAY
     dims = dimsizes(var2d)
     nd = dimsizes(dims)
     dimX = dims(nd-1) 
     dimY = dims(nd-2)
     dimT = 1
     if ( nd .eq. 3 ) then
       dimT = dims(nd-3)
     end if
     var2dtmp = new( (/ 1, dimY, dimX /), typeof(var2d) )


; SET VERTICAL CROSS SECTION
     if ( nd .eq. 3 ) then
       var2dtmp(0,:,:) = var2d(0,:,:)
     else
       var2dtmp(0,:,:) = var2d(:,:)
     end if
     if (opts) then
       xy = set_xy( var2dtmp, \
                             loc_param(0)-1, loc_param(1)-1, \
                             loc_param(2)-1, loc_param(3)-1, \
                             angle, opts )
     else
       xy = set_xy( var2dtmp, \
                             loc_param(0), loc_param(1), \
                             0.0, 0.0, angle, opts )
     end if
     xp = dimsizes(xy)

     var2dout = new( (/ dimT, xp(0) /), typeof(var2d) )

     var1dtmp = wrf_interp_2d_xy( var2dtmp, xy )
     var2dout(0,:) = var1dtmp(0,:)
     if ( dimT .eq. 1 ) then
       var2dout!1 = "Horizontal"
       return ( var2dout(0,:) )
     end if

     do it = 1,dimT-1
       var2dtmp(0,:,:) = var2d(it,:,:)
       var1dtmp = wrf_interp_2d_xy( var2dtmp, xy )
       var2dout(it,:) = var1dtmp(0,:)
     end do
     var2dout!0 = "Time"
     var2dout!1 = "Horizontal"
     return(var2dout)

end

; CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
; PURPOSE OF THIS PROGRAM : 
; INTERPOLATE 3-DIMENSIONAL DATA
; CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
undef("intrp3d")
function intrp3d( var3d:numeric, z_in:numeric, plot_type:string, \
                  loc_param:numeric, angle:numeric, opts:logical )

; INPUT:
; VAR3D:NUMERIC---   INTERPOLATE WRF OUTPUT 3 DIMENSION DATA
; Z_IN:NUMERIC---  
; PLOT_TYPE:STRING---
; LOC_PARAM:NUMERIC--
; ANGLE:NUMERIC---   
; OPTS:LOGICAL---    
; OUTPUT:
; 

begin
     dims = dimsizes(var3d)

; FOR 4 DIMENSION SIZES
; IF PRESSURE IS PA, CONVERT IT TO HPA
     if ( dimsizes(dims) .eq. 4 ) then
       if ( z_in(0,0,0,0) .gt. 500.) then
         if ( z_in(0,0,0,0) .gt. 2000. ) then
           z_in = z_in * 0.01
         end if
       end if
       z = z_in(0,:,:,:)
     else
; FOR 3 DIMENSION SIZES
; IF PRESSURE IS PA, CONVERT IT TO HPA
       if ( z_in(0,0,0) .gt. 500.) then
         if ( z_in(0,0,0) .gt. 2000. ) then
           z_in = z_in * 0.01
         end if
       end if
       z = z_in
     end if

; SET VERTICAL CROSS SECTION
     if (opts) then
; THE -1 IS FOR NCL DIMENSIONS
       xy = set_xy( z, loc_param(0)-1, loc_param(1)-1, \
                    loc_param(2)-1, loc_param(3)-1, \
                    angle, opts )
     else
       xy = set_xy( z, loc_param(0), loc_param(1), \
                    0.0, 0.0, angle, opts )
     end if
     xp = dimsizes(xy)

; FIRST WE INTERPOLATE Z
     var2dz   = wrf_interp_2d_xy( z, xy)

; INTERPOLATE TO CONSTANT Z GRID
; MONOTONICALLY DECREASING COORDINATE
     if(var2dz(0,0) .gt. var2dz(1,0) ) then
; BOTTOM VALUE
        z_max = floor(max(z)/10)*10
; TOP VALUE
        z_min = ceil(min(z)/10)*10
; THE INTERVAL IS DEFINED 10 METERS
        dz = 10
        nlevels = tointeger( (z_max-z_min)/dz)
        z_var2d = new( (/nlevels/), typeof(z))
        z_var2d(0) = z_max
        dz = -dz
     else
        z_max = max(z)
        z_min = 0.
        dz = 0.01 * z_max
        nlevels = tointeger( z_max/dz )
        z_var2d = new( (/nlevels/), typeof(z))
        z_var2d(0) = z_min
     end if
; CALCULATE THE HEIGHT OF EACH LEVEL
     do i=1, nlevels-1
        z_var2d(i) = z_var2d(0)+i*dz
     end do


; INTERPOLATE THE VARIABLE
     if ( dimsizes(dims) .eq. 4 ) then
       var2d = new( (/dims(0), nlevels, xp(0)/), typeof(var2dz))
       do it = 0,dims(0)-1
         var2dtmp = wrf_interp_2d_xy( var3d(it,:,:,:), xy)
         do i=0,xp(0)-1
            var2d(it,:,i) = wrf_interp_1d( var2dtmp(:,i), var2dz(:,i), z_var2d)
         end do
       end do
       var2d!0 = var3d!0
       var2d!1 = "Vertical"
       var2d!2 = "Horizontal"
     else
       var2d = new( (/nlevels, xp(0)/), typeof(var2dz))
       var2dtmp = wrf_interp_2d_xy( var3d, xy)
       do i=0,xp(0)-1
          var2d(:,i) = wrf_interp_1d( var2dtmp(:,i), var2dz(:,i), z_var2d)
       end do
       var2d!0 = "Vertical"
       var2d!1 = "Horizontal"
     end if



     st_x = tointeger(xy(0,0)) + 1
     st_y = tointeger(xy(0,1)) + 1
     ed_x = tointeger(xy(xp(0)-1,0)) + 1
     ed_y = tointeger(xy(xp(0)-1,1)) + 1
     if (opts) then
       var2d@Orientation = "Cross-Sesion: (" + \
                            st_x + "," + st_y + ") to (" + \
                            ed_x + "," + ed_y + ")"
     else
       var2d@Orientation = "Cross-Sesion: (" + \
                            st_x + "," + st_y + ") to (" + \
                            ed_x + "," + ed_y + ") ; center=(" + \
                            loc_param(0) + "," + loc_param(1) + \
                            ") ; angle=" + angle
     end if

     return(var2d)
end


;--------------------------------------------------------------------------------

undef("wrf_contour")
function wrf_contour(nc_file:file,wks[1]: graphic, data[*][*]:numeric, \
                     opt_args[1]:logical)

; This function creates a contour plot and adds some titles to it.
;
;   1. Determine width to height ratio of plot.
;
;   2. First determine if this is to be a filled or line
;      contour plot (fill_on)
;
;   3. If the ContourParameters attribute is set, then calculate
;      the contour levels.
;
;   4. Set two resources for setting the zero contour line to
;      a larger thickness, and for changing the negative contour
;      lines to a dashed pattern.
;
;   5. If doing a filled contour plot, set a title for the labelbar
;      based on whether a units attribute is set.
;
;   6. Make a copy of the resource list, and set some additional
;      resources for filled contour plots.
;
;   7. Create the contour plot, attach the titles, and draw
;      and advance the frame (if requested).

local dims
begin
  opts = opt_args      ; Make a copy of the resource list.

  if(opts.and.isatt(opts,"gsnDebugWriteFileName")) then
    wrf_debug_file = get_res_value(opts,"gsnDebugWriteFileName",  "")
  end if

  if(opts.and.isatt(opts,"mpOutlineBoundarySets")) then
    delete(opts@mpOutlineBoundarySets)
  end if


; Calculate ratio of plot width and height. Note that this doesn't
; affect the setting of gsnMaximize to True, because gsnMaximize will
; retain the aspect ratio of the plot.

  if(opts.and.isatt(opts,"AspectRatio")) then
    ratio = opts@AspectRatio
  else
    dims  = dimsizes(data)
    ratio = 1.*dims(0)/dims(1)
    if(ratio .gt. 1.2) then
      ratio = 1.2
    end if
    if(ratio .lt. 0.6667) then
      ratio = 0.6667
    end if
  end if

  if(ratio .gt. 1)
    width  = 0.65 * 1.0/ratio
    height = 0.65
  else
    width  = 0.85
    height = 0.85 * ratio
  end if

  opts@vpWidthF = get_res_value_keep(opts,"vpWidthF",  width)
  opts@vpHeightF = get_res_value_keep(opts,"vpHeightF", height)


; Set some basic contour resources
  opts = set_cn_resources(data,opts)


; Find out if we are working with a contour or a shaded plot
; fill_on = False : line contour plot
; fill_on = True  : filled contour plot
  fill_on = get_res_value_keep(opts,"cnFillOn",False)
  if(fill_on) then      ; set lb resources if needed
    opts = set_lb_resources(data,opts)
    atmp = get_res_value(opts,"lbLabelBarOn",True) ; Remove this resource
    delete(atmp)                                   ; just in case.
  end if


; Set Title resources
  opts = set_title_resources(data,opts)


; Setting gsnScale to True ensures that the tickmark lengths and labels
; will be the same size on both axes.
  opts@gsnScale    = get_res_value_keep(opts,"gsnScale",    True)


; The default is not to draw the plot or advance the frame, and
; to maximize the plot in the frame.
  opts@gsnDraw          = False    ; Make sure don't draw or frame or,
  opts@gsnFrame         = False    ; maximize, b/c we'll do this later.
  opts@gsnMaximize      = False


  opts2 = opts
  delete_attrs(opts2)                       ; Clean up.
  cn = gsn_contour(wks,data,opts2)          ; Create the plot.
  _SetMainTitle(nc_file,wks,cn,opts)        ; Set some titles

  if(isvar("wrf_debug_file")) then
    write_wrf_debug_info(wks,data,False,wrf_debug_file,opts2,"wrf_contour")
  end if

  opts2@gsnDraw     = get_res_value_keep(opts2,"gsnDraw",     False)
  opts2@gsnFrame    = get_res_value_keep(opts2,"gsnFrame",    False)
  opts2@gsnMaximize = get_res_value_keep(opts2,"gsnMaximize", True)
  draw_and_frame(wks,cn,opts2@gsnDraw,opts2@gsnFrame,False,opts2@gsnMaximize)

  return(cn)                                ; Return

end

; CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
undef("wrf_overlays")
function wrf_overlays(in_file[1]:file, \
                     wks:graphic, plots[*]:graphic, \
                     opt_arg[1]:logical)

; This procedure takes an array of plots and overlays them.
;
; It will advance the plot and cleanup, unless you set the
; PanelPlot resource to True.
;
;  Attributes recognized by this procedure:
;     FramePlot
;     PanelPlot
;     NoTitles                  (don't do any titles)
;     CommonTitle & PlotTile is used to overwrite field titles
;        CommonTitle will super-seed NoTitles
;
; If FramePlot False, then Draw the plot but do not Frame.
; In this case a user want to add to the drawing, and will
; have to advance the Frame manually in the script.
;
; If the "NoTitles" attribute exists and is set True, then
; don't create the top-left titles, and leave the main titles alone.
; This resource can be useful if you are planning to panel
; the plots.
;
; If PanelPlot is set to True, then this flags to wrf_overlays
; that these plots are going to be eventually paneled (likely
; by gsn_panel), and hence 1) draw and frame should not be called
; (unless gsnDraw and/or gsnFrame are explicitly set to True),
; and 2) the overlays and titles should not be removed with
; NhlRemoveOverlay and NhlRemoveAnnotation.
;
begin
  opts = opt_arg      ; Make a copy of the resource list.

  no_titles  = get_res_value(opts,"NoTitles",False)     ; Do we want field titles?
  com_title  = get_res_value(opts,"CommonTitle",False)     ; Do we have a common title?
  if ( com_title ) then
    plot_title = get_res_value(opts,"PlotTitle","  ")
    no_titles = True
  end if

  call_draw  = True
  call_frame = get_res_value(opts,"FramePlot",True)     ; Do we want to frame the plot?
  panel_plot = get_res_value(opts,"PanelPlot",False)    ; Are we paneling?
  opts@gsnMaximize = get_res_value_keep(opts,"gsnMaximize", True)

  nplots = dimsizes(plots)

  base = plots(0)
  if(.not.no_titles) then
    getvalues plots(0)
      "tiMainString" : SubTitle
    end getvalues
    SubTitles = SubTitle
    setvalues plots(0)
      "tfDoNDCOverlay" : True
      "tiMainOn"       : False
    end setvalues
  else
    setvalues plots(0)
      "tfDoNDCOverlay" : True
    end setvalues
  end if

  if (nplots.eq.1) then
    blank = create "BlankPlot" logLinPlotClass wks
      ;"cnConstFLabelOn" : False
    end create
    overlay(base,blank)
  end if

  do i=1,nplots-1
    if(.not.ismissing(plots(i))) then
      if(.not.no_titles) then
        getvalues plots(i)
          "tiMainString" : SubTitle
        end getvalues
        if(i.eq.0) then
          SubTitles = SubTitle
        else
          SubTitles = SubTitles + "~C~" + SubTitle
        end if
      end if
      if(com_title .and. i .eq. nplots-1) then
        getvalues plots(i)
          "tiMainString" : SubTitle
        end getvalues
        SubTitles = plot_title
      end if
      setvalues plots(i)
        "tfDoNDCOverlay" : True
        "tiMainOn"       : False
      end setvalues
      overlay(base,plots(i))
    else
      print("wrf_overlays: Warning: overlay plot #" + i + " is not valid.")
    end if
  end do

  if(.not.no_titles .or. com_title) then
    font_height = get_res_value_keep(opts,"FontHeightF",0.01)

    txt = create "map_titles" textItemClass wks
      "txString"      : SubTitles
      "txFontHeightF" : font_height
    end create
    anno = NhlAddAnnotation(base,txt)
    setvalues anno
      "amZone"           : 3
      "amJust"           : "BottomLeft"
      "amSide"           : "Top"
      "amParallelPosF"   : 0.05
      "amOrthogonalPosF" : 0.03
      "amResizeNotify"   : False
    end setvalues
    base@map_titles = anno
  end if

;
; gsnDraw and gsnFrame should default to True if not a panel plot.
;
  if(panel_plot) then
    call_draw = False
    call_frame= False
  end if

  opts@gsnDraw     = get_res_value_keep(opts,"gsnDraw",     call_draw)
  opts@gsnFrame    = get_res_value_keep(opts,"gsnFrame",    call_frame)
  opts@gsnMaximize = get_res_value_keep(opts,"gsnMaximize", True)

  draw_and_frame(wks,base,opts@gsnDraw,opts@gsnFrame,False, \
                 opts@gsnMaximize)

  if(.not.no_titles.and..not.panel_plot) then
    NhlRemoveAnnotation(base,base@map_titles)
    delete(base@map_titles)
  end if

  if(.not.panel_plot) then
    if ( nplots .ge. 2 ) then
      do i=1,nplots-1
        if(.not.ismissing(plots(i))) then
          NhlRemoveOverlay(base,plots(i),False)
        else
          print("wrf_remove_overlays: Warning: overlay plot #" + i + " is not valid.")
          print("                        Nothing to remove.")
        end if
      end do
    end if
  end if

return(base)
end
; CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC
