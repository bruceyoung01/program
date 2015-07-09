;   Example script to produce plots for a WRF real-data run,
;   with the ARW coordinate dynamics option.
;   Plot data on a cross section
;   This script will plot data from point A to point B
;   Add some label info to the Y-axis

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "/home/bruce/program/ncl/tutorial/test/wrf_contour_h/WRFUserARW.ncl"
load "/home/bruce/program/ncl/tutorial/test/wrf_contour_h/intrp_v01.ncl"

begin
;
; The WRF ARW input file.  
; This needs to have a ".nc" appended, so just do it.
  a = addfile("/media/disk/data/wrfchem/sahel/sahel200802_f/wrfout_d01_2008-02-05_00:00:00.nc","r")

; We generate plots, but what kind do we prefer?
  type = "x11"
; type = "pdf"
; type = "ps"
; type = "ncgm"
; type = "png"
  wks = gsn_open_wks(type,"1plt_contour_h_2008-02-05_sahelf")


; Set some basic resources
  pltres = True

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  times1    = a->Times(:,:)             ; get time from the file
  FirstTime = True

  mdims = getfilevardimsizes(a,"P")      ; get some dimension sizes for the file
  nd = dimsizes(mdims)

;---------------------------------------------------------------
  do it = 0,23-1,1                       ; TIME LOOP
    times= times1(it,:)
    print("Working on time: " + times )
    pltres@TimeLabel = times                ; Set Valid time to use on plots

    lat  = getvar(a,"XLAT",it)           ; XLAT
    lon  = getvar(a,"XLONG",it)          ; XLONG
    tc   = getvar(a,"tc",it)             ; T in C
    rh   = getvar(a,"rh",it)             ; relative humidity
    z    = getvar(a, "z",it)             ; grid point height(unit is meter)
    pm25 = getvar(a, "PM2_5_DRY",it)     ; PM2.5

    if ( FirstTime ) then                ; get height info for labels
      zmin = 0.
;     zmax = max(z)/1000.
      zmax = max(z(0:15,:,:))/1000.
      nz   = floattoint(zmax/2 + 1)
      FirstTime = False
    end if

;---------------------------------------------------------------

; Plot a cross session that run from point A to point B

        plane = new(4,float)
;       plane = (/ 2,2, mdims(nd-1)-2, mdims(nd-2)-2 /)    ; start x;y & end x;y point           
        plane = (/ 45,0,60,73 /)     ; start x;y & end x;y point(SAHEL)
;       plane = (/ 0,64,155,90 /)    ; start x;y & end x;y point
;       plane = (/ 100,0,100,99 /)   ; start x;y & end x;y point
;       plane = (/ 0,50,100,60 /)    ; start x;y & end x;y point
;       plane = (/ 2,90,155,65 /)    ; start x;y & end x;y point
;       print(lat)
;       print(lat(45, 0))
;       print(lon(45, 0))
;       print(lat(33, 98))
;       print(lon(33, 98))
        opts = True                                        ; start and end points specified

        rh_plane = intrp3d(rh,z,"v",plane,0.,opts)
;       tc_plane = intrp3d(tc,z,"v",plane,0.,opts)
        tc_plane = intrp3d(tc(0:15,:,:),z(0:15,:,:),"v",plane,0.,opts)
;       pm25_plane = intrp3d(pm25,z,"v",plane,0.,opts)
        pm25_plane = intrp3d(pm25(0:15,:,:),z(0:15,:,:),"v",plane,0.,opts)

        dim = dimsizes(rh_plane)                      ; Find the data span - for use in labels
        zspan = dim(0)

      ; Options for XY Plots
        opts_xy                         = pltres
        opts_xy@tiYAxisString           = "Height (km)"
        opts_xy@cnMissingValPerimOn     = True
        opts_xy@cnMissingValFillColor   = 0
        opts_xy@cnMissingValFillPattern = 11
        opts_xy@tmYLMode                = "Explicit"
        opts_xy@tmYLValues              = fspan(0,zspan,nz)                    ; Create tick marks
        opts_xy@tmYLLabels              = sprintf("%.1f",fspan(zmin,zmax,nz))  ; Create labels
        opts_xy@tiXAxisFontHeightF      = 0.02
        opts_xy@tiYAxisFontHeightF      = 0.02
        opts_xy@tmXBMajorLengthF        = 0.02
        opts_xy@tmYLMajorLengthF        = 0.02
        opts_xy@tmYLLabelFontHeightF    = 0.02
        opts_xy@PlotOrientation         = tc_plane@Orientation

      ; Plotting options for PM2.5
        opts_pm25 = opts_xy
        opts_pm25@ContourParameters       = (/ 1., 10., 1. /)
        opts_pm25@pmLabelBarOrthogonalPosF = -0.07
        opts_pm25@cnFillOn                = True

      ; Plotting options for Temperature
        opts_tc = opts_xy
        opts_tc@cnInfoLabelOrthogonalPosF = 0.00
        opts_tc@ContourParameters  = (/ 5. /)

      ; Get the contour info for the tc and PM2.5
        contour_tc = wrf_contour(a,wks,tc_plane,opts_tc)
        contour_pm25 = wrf_contour(a,wks,pm25_plane,opts_pm25)

      ; MAKE PLOTS         
         plot = wrf_overlays(a,wks,(/contour_pm25,contour_tc/),pltres)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Draw text on plot using plot coordinates.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;        txres = opts_xy
;        txres@txFontHeightF = 0.01
;        gsn_text(wks,plot,"Latitude/Longitude",10,0,txres)
;        frame(wks)

  end do        ; END OF TIME LOOP

end

