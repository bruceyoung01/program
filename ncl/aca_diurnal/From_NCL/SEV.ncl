load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

  diri = "./"
  fili = systemfunc("cd "+diri+"; ls SEV_06-CLD-L2_2008-06-01*hdf")
  print(fili)
  nfil = dimsizes(fili)
do nf=0,nfil-1
  f    = addfile(diri+fili(nf), "r")

  var    := "Cloud_Top_Temperature"

  lat2d  := f->MSG_Latitude
  lon2d  := f->MSG_Longitude

  printVarSummary(lat2d)
  printVarSummary(lon2d)

  print("---")
  print("lat2d: min="+min(lat2d)+"  max="+max(lat2d))      ; lat2d: min=-999.999  max=81.2637
  print("lon2d: min="+min(lat2d)+"  max="+max(lon2d))      ; lon2d: min=-999.999  max=81.2005
                                                           ;            ^^^^^^^^
  lat2d@_FillValue = -999.999    ; NCL only understands _FillValue
  lon2d@_FillValue = -999.999

  print("---")
  print("lat2d: min="+min(lat2d)+"  max="+max(lat2d))      ; lat2d: min=-81.2637  max=81.2637
  print("lon2d: min="+min(lat2d)+"  max="+max(lon2d))      ; lon2d: min=-81.2637  max=81.2005

  dim  = dimsizes(lat2d)
  npts = product(dim)

  CTT := f->$var$                ; type short
  printVarSummary(CTT)

;;    short Cloud_Top_Temperature ( fakeDim69, fakeDim70 )   <======= type 'short'
;;       units :        K
;;       long_name :    Cloud Top Temperature from in-house  ...
;;       actual_range : ( -32699, 32657 )
;;       Num_Fill :     0
;;       Num_Valid :    13778944
;;       valid_range :  ( 0, 20000 )
;;       _FillValue :   -999
;;       scale_factor : 0.009999999776482582   <=========== 0.01
;;       scale_factor_err :        0
;;       add_offset :   -15000                 <===========
;;       add_offset_err :          0
;;       calibrated_nt :        22
;;       hdf_name :     Cloud_Top_Temperature

  kFill= num(ismissing(CTT))  
  print("kFill="+kFill)

       ; valid_range :  ( 0, 20000 ); type short
  vrng = CTT@valid_range
  krng = num(CTT.lt.vrng(0) .or. CTT.gt.vrng(1))
  print("krng="+krng+" outside_valid_range[%]="+((100.0*krng)/npts))

       ; set all outside valid range to _FillValue
  CTT  = where(CTT.ge.vrng(0) .and. CTT.le.vrng(1), CTT, CTT@_FillValue)  
  print("CTT: min="+min(CTT)+"  max="+max(CTT))    
  print("---")

  ctt_1 := CTT@scale_factor*(CTT + CTT@add_offset)

  print("ctt_1: min="+min(ctt_1)+"  max="+max(ctt_1))  
  print("---")

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
   sfx     = get_file_suffix(fili,0)           ; use file name         
   froot   = sfx@fBase                         ; file name without extension

   pltName = "SEVERI_SOURCE_"+nf

   pltType = "png"                             ; "ps", "eps", "pdf", "png", "x11"
   pltDir  = "./"

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
   res@tiMainString        = fili
   
   pStrt = get_cpu_time()
   plot  = gsn_csm_contour_map_ce(wks,ctt_1, res)
   print("plot took " + (get_cpu_time() - pStrt) + " seconds")

end do   ; nf
