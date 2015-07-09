;   Example script to produce plots for a WRF real-data run,
;   with the ARW coordinate dynamics option.
;   Plot data on a cross section
;   This script will plot data from point A to point B
;   Add some label info to the Y-axis

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin
;
; The WRF ARW input file.  
; This needs to have a ".nc" appended, so just do it.
  a = addfile("/media/disk/data/wrfchem/200805_sepanf/wrfout_d01_2008-05-01_00:00:00_1200sepanf.nc","r")


; We generate plots, but what kind do we prefer?
  type = "x11"
; type = "pdf"
; type = "ps"
; type = "ncgm"
; type = "png"
  wks = gsn_open_wks(type,"1plt_contour_h_2008-05-01")


; Set some basic resources
  res = True
  res@MainTitle = "REAL-TIME WRF"
  res@Footer = False
  pltres = True


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  times  = wrf_user_list_times(a)   ; get times in the file
  ntimes = dimsizes(times)          ; number of times in the file
  FirstTime = True

  mdims = getfilevardimsizes(a,"P") ; get some dimension sizes for the file
  nd = dimsizes(mdims)

;---------------------------------------------------------------

  do it = 0,ntimes-1,3                  ; TIME LOOP

    print("Working on time: " + times(it) )
    res@TimeLabel = times(it)           ; Set Valid time to use on plots

    lat= wrf_user_getvar(a,"XLAT",it); XLAT
    lon= wrf_user_getvar(a,"XLONG",it); XLONG
    tc  = wrf_user_getvar(a,"tc",it)     ; T in C
    rh = wrf_user_getvar(a,"rh",it)      ; relative humidity
    z   = wrf_user_getvar(a, "z",it)     ; grid point height
    pm25 = wrf_user_getvar(a, "PM2_5_DRY",it)     ; PM2.5

;print(max(z(0:15,:,:)))
    if ( FirstTime ) then                ; get height info for labels
      zmin = 0.
      zmax = max(z)/1000.
;     zmax = max(z(0:15,:,:))/1000.
      nz   = floattoint(zmax/2 + 1)
      FirstTime = False
    end if

;---------------------------------------------------------------

; Plot a cross session that run from point A to point B

        plane = new(4,float)
;       plane = (/ 2,2, mdims(nd-1)-2, mdims(nd-2)-2 /)    ; start x;y & end x;y point           
        plane = (/ 0,0,100,98 /)    ; start x;y & end x;y point
;       plane = (/ 100,0,100,99 /)    ; start x;y & end x;y point
;       plane = (/ 0,50,100,60 /)    ; start x;y & end x;y point
;       plane = (/ 2,90,155,65 /)    ; start x;y & end x;y point
;       print(lat)
;       print(lat(33, 1))
;       print(lon(33, 1))
;       print(lat(33, 98))
;       print(lon(33, 98))
        opts = True                                        ; start and end points specified

        rh_plane = wrf_user_intrp3d(rh,z,"v",plane,0.,opts)
        tc_plane = wrf_user_intrp3d(tc,z,"v",plane,90.,opts)
;       tc_plane = wrf_user_intrp3d(tc(0:15,:,:),z(0:15,:,:),"v",plane,0.,opts)
        pm25_plane = wrf_user_intrp3d(pm25,z,"v",plane,90.,opts)
;       pm25_plane = wrf_user_intrp3d(pm25(0:15,:,:),z(0:15,:,:),"v",plane,0.,opts)

        dim = dimsizes(rh_plane)                      ; Find the data span - for use in labels
        zspan = dim(0)

      ; Options for XY Plots
        opts_xy                         = res
        opts_xy@tiYAxisString           = "Height (km)"
        opts_xy@cnMissingValPerimOn     = True
        opts_xy@cnMissingValFillColor   = 0
        opts_xy@cnMissingValFillPattern = 11
        opts_xy@tmYLMode                = "Explicit"
        opts_xy@tmYLValues              = fspan(0,zspan,nz)                    ; Create tick marks
        opts_xy@tmYLLabels              = sprintf("%.1f",fspan(zmin,zmax,nz))  ; Create labels
        opts_xy@tiXAxisFontHeightF      = 0.015
        opts_xy@tiYAxisFontHeightF      = 0.015
        opts_xy@tmXBMajorLengthF        = 0.02
        opts_xy@tmYLMajorLengthF        = 0.02
        opts_xy@tmYLLabelFontHeightF    = 0.015
        opts_xy@PlotOrientation         = tc_plane@Orientation
        

      ; Plotting options for RH
        opts_rh = opts_xy
        opts_rh@ContourParameters       = (/ 10., 90., 10. /)
        opts_rh@pmLabelBarOrthogonalPosF = -0.07
        opts_rh@cnFillOn                = True
        opts_rh@cnFillColors            = (/"White","White","White", \
                                            "White","Chartreuse","Green", \
                                            "Green3","Green4", \
                                            "ForestGreen","PaleGreen4"/)
      ; Plotting options for PM2.5
        opts_pm25 = opts_xy
        opts_pm25@ContourParameters       = (/ 5., 50., 5. /)
        opts_pm25@pmLabelBarOrthogonalPosF = -0.07
        opts_pm25@cnFillOn                = True
        ;opts_pm25@cnFillColors         = (/"White","White","DarkOliveGreen1", \
        ;                           "DarkOliveGreen2", "Chartreuse","Chartreuse1", \
        ;                            "Chartreuse3","Green","ForestGreen", \
        ;                            "Yellow","Orange","Red","Violet"/)

      ; Plotting options for Temperature
        opts_tc = opts_xy
        opts_tc@cnInfoLabelOrthogonalPosF = 0.00
        opts_tc@ContourParameters  = (/ 5. /)


      ; Get the contour info for the rh and temp
        contour_tc = wrf_contour(a,wks,tc_plane,opts_tc)
        contour_rh = wrf_contour(a,wks,rh_plane,opts_rh)
        contour_pm25 = wrf_contour(a,wks,pm25_plane,opts_pm25)


      ; MAKE PLOTS         
;        plot = wrf_overlays(a,wks,(/contour_rh,contour_tc/),pltres)
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

