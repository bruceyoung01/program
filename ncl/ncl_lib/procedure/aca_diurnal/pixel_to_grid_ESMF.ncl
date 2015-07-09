;  $ID: pixel_to_grid_ESMF.ncl V01 06/30/2015 22:06 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE pixel_to_grid_ESMF.ncl CONVERTS THE PIXEL DATA INTO REGULAR GRID 
;  DATA USING ESMF REGRIDDING.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) src_lat          (2-D):SOURCE LATITUDE                            [DEG]
;  (2 ) src_lon          (2-D):SOURCE LONGITUDE                           [DEG]
;  (3 ) minlat        (scalar):MINIMUM LATITUDE IN THE STUDY REGION       [DEG]
;  (4 ) maxlat        (scalar):MAXIMUM LATITUDE IN THE STUDY REGION       [DEG]
;  (5 ) minlon        (scalar):MINIMUM LONGITUDE IN THE STUDY REGION      [DEG]
;  (6 ) maxlon        (scalar):MAXIMUM LONGITUDE IN THE STUDY REGION      [DEG]
;  (7 ) lat_grid_size (scalar):LATITUDE GRID SIZE                         [DEG]
;  (8 ) lon_grid_size (scalar):LONGITUDE GRID SIZE                        [DEG]
;  (9 ) src_data         (2-D):SOURCE DATA                                [   ]
;  (10) dst_data         (2-D):DESTINATION DATA                           [   ]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (06/30/2015)
;******************************************************************************
undef("pixel_to_grid_ESMF")
procedure pixel_to_grid_ESMF \
          (bv2           :float,                       \;INPUT
           src_lat       :float, src_lon       :float, \;INPUT
           minlat        :float, maxlat        :float, \;INPUT
           minlon        :float, maxlon        :float, \;INPUT
           lat_grid_size :float, lon_grid_size :float, \;INPUT
           src_data      :numeric,                     \;INPUT
           dst_data      :numeric)                      ;OUTPUT

begin

;  SETUP ESMF RESOURCE
   Opt                   = True

;  SETUP FOR THE SOURCE DATA
;  "bilinear" is the default. 
;  "patch" and "conserve" are other options.
   Opt@InterpMethod      = "bilinear"
   Opt@SrcGridLat        = src_lat
   Opt@SrcGridLon        = src_lon
   Opt@SrcRegional       = True
   Opt@SrcMask2D         = where(.not.ismissing(src_data(0, :, :)), 1, 0)

;  SETUP FOR THE DESTINATION DATA
   slat_grid_size        = flt2string(lat_grid_size)
   slon_grid_size        = flt2string(lon_grid_size)
   Opt@DstGridType       = slat_grid_size + "x" + slon_grid_size
   Opt@DstLLCorner       = (/minlat, minlon/)
   Opt@DstURCorner       = (/maxlat, maxlon/)
   Opt@DstRegional       = True
   Opt@ForceOverwrite    = True
   Opt@PrintTimings      = True
   Opt@Debug             = True

   dst_data = (/ESMF_regrid(src_data, Opt)/)

   dst_data = where(dst_data .eq. default_fillvalue("float"), bv2, dst_data)
return
end
