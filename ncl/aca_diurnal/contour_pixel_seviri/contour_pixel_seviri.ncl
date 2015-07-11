;  $ID: contour_pixel_seviri.ncl V01 07/10/2015 18:29 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM contour_pixel_seviri.ncl READS SEVIRI PIXEL-LEVEL DATA AND PLOTS 
;  THEM OUT.
;
;  FLOW CHART:
;  ============================================================================
;  (1 ) READ SEVIRI DATA ONE BY ONE;
;  (2 ) PLOT VARIOUS VARIABLES BASED ONE THE USER'S PURPOSE.
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY DANNIS SHEA (06/30/2015)
;  (2 ) MODIFIED BY BRUCE THROUGH OPTIMISING THE CODE. (07/10/2015)
;******************************************************************************

;  LOAD FUNCTIONS AND PROCEDURES
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

begin

   bv2      = -999.999

;  DATA DIRECTORY AND DATA FILE NAME
   dir      = "/home/vy57456/zzbatmos_common/Data/SEVIRI/SEV_06-CLD-L2.v1.03/2008/2008_06_02/"
   filename = systemfunc("cd " + dir + "; ls *hdf")
   nfilename= dimsizes(filename)

;  DO FILE NAME LOOP
   do ifilename = 0, nfilename-1
      f      = addfile(dir + filename(ifilename), "r")
      var   := "Cloud_Top_Temperature"
      lat2d := f->MSG_Latitude
      lon2d := f->MSG_Longitude

      lat2d@_FillValue = bv2
      lon2d@_FillValue = bv2
      dim    = dimsizes(lat2d)
      npts   = product(dim)
      CTT   := f->$var$

      kfill  = num(ismissing(CTT))

;  valid_range : 0~20000 SHORT TYPE
      vrng   = CTT@valid_range
      krng   = num(CTT .lt. vrng(0) .or. \
                   CTT .gt. vrng(1))

;  SET ALL OUTSIDE OF VALID RANGE TO _FillValue
      CTT = where(CTT .ge. vrng(0) .and. \
                  CTT .le. vrng(1), CTT, CTT@_FillValue)

      ctt_1 := CTT@scale_factor*(CTT + CTT@add_offset)

;*********************************
; Overall staistics
;*********************************

  opt = True
  opt@PrintStat = True
  ctt_stat = stat_dispersion(ctt_1, opt )

;*********************************
; Use information from stat_dispersion to filter outliers
;*********************************

  ctt_1  = where(ctt_1.lt.-80.0 .and. CTT.gt.-9.0, ctt_1, ctt_1@_FillValue)

;*********************************
; create plot
;*********************************
   sfx     = get_file_suffix(filename(ifilename),0)           ; use file name         
   froot   = sfx@fBase                         ; file name without extension

   pltName = "SEVERI_SOURCE_" + ifilename

   pltType = "png"                             ; "ps", "eps", "pdf", "png", "x11"
   pltDir  = "/home/vy57456/zzbatmos_user/program_plot/ncl/aca_diurnal/contour_pixel_seviri/"

   wks = gsn_open_wks(pltType, pltDir+pltName)
   gsn_define_colormap(wks,"amwg256")        ; specify a color map (optional)

   res                     = True
   res@gsnMaximize         = True            ; ps, pdf, pdf    

   res@cnFillOn            = True            ; turn on color
   res@cnFillMode          = "RasterFill"    ; cell mode
   res@cnLinesOn           = False           ; Turn off contour lines

   res@gsnAddCyclic        = False           ; data not cyclic
   res@pmTickMarkDisplayMode = "Always"      ; use NCL default 
  ;res@lbOrientation       = "Vertical"      ; vertical label bar
   res@lbLabelAutoStride   = True            ; let NCL decide spacing

   res@mpMinLatF           = min(lat2d)    ; region to zoom in on
   res@mpMaxLatF           = max(lat2d)
   res@mpMinLonF           = min(lon2d)
   res@mpMaxLonF           = max(lon2d)
   res@mpFillOn            = False

   res@sfXArray            = lon2d
   res@sfYArray            = lat2d
  ;res@mpOutlineBoundarySets = "USStates"    ; turn on state boundaries
  ;res@mpOutlineBoundarySets = "AllBoundaries"
  ;res@mpOutlineBoundarySets = "National"    ; turn on country boundaries
   res@trGridType          = "TriangularMesh"   ; Necessary b/c lat, lon
                                                ; arrays have missing values.
   res@tiMainString        = filename(ifilename)

   pStrt = get_cpu_time()
   plot  = gsn_csm_contour_map_ce(wks,ctt_1, res)
   print("plot took " + (get_cpu_time() - pStrt) + " seconds")

end do   ; ifilename

end
