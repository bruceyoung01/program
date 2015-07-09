;   Example script to produce plots for a WRF real-data run,
;   with the ARW coordinate dynamics option.
;   Interpolating to specified pressure levels

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"



begin
;
; The WRF ARW input file.
; This needs to have a ".nc" appended, so just do it.
  a = addfile("/mnt/sdd/data/wrfchem/200805_sepanf/wrfout_d01_2008-05-18_00:00:00_1200sepanf.nc","r")


  res   = True
  gsres = True
  mpres = True
  pltres= True

  mpres@mpGeophysicalLineThicknessF = 2.0
  mpres@mpGridLineThicknessF        = 2.0
  mpres@mpLimbLineThicknessF        = 2.0
  mpres@mpNationalLineThicknessF    = 2.0
  mpres@mpUSStateLineThicknessF     = 2.0

;-----------------------PLOT WRFCHEM OUTPUT------------------------------
; We generate plots, but what kind do we prefer?
  type = "x11"
; type = "pdf"
; type = "ps"
; type = "ncgm"
; type = "png"
  wks = gsn_open_wks(type,"plt_wrf_pm25_p_i_2008-05-18_nf_epa")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; What times and how many time steps are in the data set?
  times  = wrf_user_list_times(a)  ; get times in the file
  ntimes = dimsizes(times)         ; number of times in the file


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    pm25=a->PM2_5_DRY

  do it = 0,0;ntimes-1,3             ; TIME LOOP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; First get the variables we will need

    pm25=a->PM2_5_DRY
    ;print(pm25)
    ;pm25= wrf_user_getvar(a,"PM2_5_DRY",it); PM2.5
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

      ; Plotting options for PM2.5
        opts = res
        opts@ContourParameters = (/ 2., 20., 2. /)
        opts@cnFillOn            = True
        opts = set_cn_resources(pm25(it,0,:,:),opts)
        opts = set_lb_resources(pm25(it,0,:,:),opts)
        contourpm25 = gsn_contour(wks,pm25(it,0,:,:),opts)
        plot = wrf_map_overlays(a,wks,(/contourpm25/),pltres,mpres)

        ;plot=wrf_overlays(a,wks,(/contourpm25,scatter_epapm25\
        ;                             /),mpres)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  end do        ; END OF TIME LOOP

end

