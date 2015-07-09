;   Example script to produce plots for a WRF real-data run,
;   with the ARW coordinate dynamics option.
;   Interpolating to specified height levels

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin
;
; The WRF ARW input file.  
; This needs to have a ".nc" appended, so just do it.

  a = addfile("/work/jwang7/bruceyoung01/model/met_em/200305_ca_60/met_em.d01.2003-04-29_00:00:00.nc","r")
; We generate plots, but what kind do we prefer?
  type = "x11"
; type = "pdf"
; type = "ps"
; type = "ncgm"
  wks = gsn_open_wks(type,"met_Height")


; Set some basic resources
  res = True
  res@MainTitle = "REAL-TIME WRF"
  res@Footer = False

  pltres = True
  mpres = True
  mpres@mpGeophysicalLineColor = "Black"
  mpres@mpNationalLineColor    = "Black"
  mpres@mpUSStateLineColor     = "Black"
  mpres@mpGridLineColor        = "Black"
  mpres@mpLimbLineColor        = "Black"
  mpres@mpPerimLineColor       = "Black"


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; What times and how many time steps are in the data set?
  times  = wrf_user_list_times(a)  ; get times in the file
  ntimes = dimsizes(times)         ; number of times in the file

; The specific height levels that we want the data interpolated to.
;  height_levels = (/ 250., 2000./)   ; height levels to plot - in meter
;  nlevels       = dimsizes(height_levels)     ; number of height levels

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;  do it = 0,ntimes-1,2             ; TIME LOOP
   it=0
    print("Working on time: " + times(it) )
    res@TimeLabel = times(it)   ; Set Valid time to use on plots

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; First get the variables we will need        

    p  = wrf_user_getvar(a, "pressure",it) ; pressure is our vertical coordinate
    z = wrf_user_getvar(a,"height",it)
;    pm25a= wrf_user_getvar(a,"PM2_5_DRY",it)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;    do level = 0,nlevels-1                 ; LOOP OVER LEVELS
      level=0

       z_plane = wrf_user_intrp3d(z,p,"h",700.,0.,False)

    ; Plotting options for T                
    opts = res                          

       opts@cnLineColor         = "Blue"
       opts@cnFillOn            = True
       opts@pmLabelBarOrthogonalPosF = -0.1
       opts@cnLevelSelectionMode = "ExplicitLevels"

       opts@cnLevels             = (/ 10, 50, 150, 250/)

;       opts@cnFillColors         = (/"White","blue","lightblue1","cyan","greenyellow","green", \
;                                      "Yellow","Orange","coral","Red"/)
      opts@cnFillColors         = (/"White","blue","green", \
                                      "Yellow","Red"/)

;      contour_tc = wrf_contour(a,wks,pm25a(level,:,:),opts)
      delete(opts)

    ; Plotting options for Pressure
      opts = res                          

   opts@cnLineLabelPerimOn = False
   opts@cnLineLabelFontHeightF = 0.02

      opts@cnLineColor = "Blue"
      opts@gsnContourLineThicknessesScale = 1.0
     ;opts@ContourParameters = (/ 2980, 3180,20. /)
      contour_p = wrf_contour(a,wks,z_plane,opts)
      delete(opts)

    ; MAKE PLOTS                                       
;     plot = wrf_map_overlays(a,wks,(/contour_p,contour_tc/),pltres,mpres)
plot = wrf_map_overlays(a,wks,(/contour_p/),pltres,mpres)


;    end do      ; END OF LEVEL LOOP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;  end do        ; END OF TIME LOOP

end

