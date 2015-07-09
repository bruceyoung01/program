;  $ID: pixel_to_grid_ESMF_9var.ncl V01 06/30/2015 22:06 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE pixel_to_grid_ESMF_9var.ncl CONVERTS THE PIXEL DATA INTO REGULAR GRID 
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
;  (9 ) src_data1        (2-D):SOURCE DATA1                               [   ]
;  (10) src_data2        (2-D):SOURCE DATA2                               [   ]
;  (11) src_data3        (2-D):SOURCE DATA3                               [   ]
;  (12) src_data4        (2-D):SOURCE DATA4                               [   ]
;  (13) src_data5        (2-D):SOURCE DATA5                               [   ]
;  (14) src_data6        (2-D):SOURCE DATA6                               [   ]
;  (15) src_data7        (2-D):SOURCE DATA7                               [   ]
;  (16) src_data8        (2-D):SOURCE DATA8                               [   ]
;  (17) src_data9        (2-D):SOURCE DATA9                               [   ]
;  (18) dst_data1        (2-D):DESTINATION DATA1                          [   ]
;  (19) dst_data2        (2-D):DESTINATION DATA2                          [   ]
;  (20) dst_data3        (2-D):DESTINATION DATA3                          [   ]
;  (21) dst_data4        (2-D):DESTINATION DATA4                          [   ]
;  (22) dst_data5        (2-D):DESTINATION DATA5                          [   ]
;  (23) dst_data6        (2-D):DESTINATION DATA6                          [   ]
;  (24) dst_data7        (2-D):DESTINATION DATA7                          [   ]
;  (25) dst_data8        (2-D):DESTINATION DATA8                          [   ]
;  (26) dst_data9        (2-D):DESTINATION DATA9                          [   ]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (06/30/2015)
;******************************************************************************
undef("pixel_to_grid_ESMF_9var")
procedure pixel_to_grid_ESMF_9var \
          (src_lat       :float,   src_lon       :float,   \;INPUT
           minlat        :float,   maxlat        :float,   \;INPUT
           minlon        :float,   maxlon        :float,   \;INPUT
           lat_grid_size :float,   lon_grid_size :float,   \;INPUT
           src_data1     :numeric, src_data2     :numeric, \;INPUT
           src_data3     :numeric, src_data4     :numeric, \;INPUT
           src_data5     :numeric, src_data6     :numeric, \;INPUT
           src_data7     :numeric, src_data8     :numeric, \;INPUT
           src_data9     :numeric,                         \;INPUT
           dst_data1     :numeric, dst_data2     :numeric, \;OUTPUT
           dst_data3     :numeric, dst_data4     :numeric, \;OUTPUT
           dst_data5     :numeric, dst_data6     :numeric, \;OUTPUT
           dst_data7     :numeric, dst_data8     :numeric, \;OUTPUT
           dst_data9     :numeric)                          ;OUTPUT

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

   Opt1                  = True
   Opt1                  = Opt
   Opt1@SrcMask2D        = where(.not.ismissing(src_data1), 1, 0)
   dst_data1 = (/ESMF_regrid(src_data1, Opt1)/)


   Opt2                  = True
   Opt2                  = Opt
   Opt2@SrcMask2D        = where(.not.ismissing(src_data2), 1, 0)
   dst_data2 = (/ESMF_regrid(src_data2, Opt2)/)


   Opt3                  = True
   Opt3                  = Opt
   Opt3@SrcMask2D        = where(.not.ismissing(src_data3), 1, 0)
   dst_data3 = (/ESMF_regrid(src_data3, Opt3)/)


   Opt4                  = True
   Opt4                  = Opt
   Opt4@SrcMask2D        = where(.not.ismissing(src_data4), 1, 0)
   dst_data4 = (/ESMF_regrid(src_data4, Opt4)/)


   Opt5                  = True
   Opt5                  = Opt
   Opt5@SrcMask2D        = where(.not.ismissing(src_data5), 1, 0)
   dst_data5 = (/ESMF_regrid(src_data5, Opt5)/)


   Opt6                  = True
   Opt6                  = Opt
   Opt6@SrcMask2D        = where(.not.ismissing(src_data6), 1, 0)
   dst_data6 = (/ESMF_regrid(src_data6, Opt6)/)


   Opt7                  = True
   Opt7                  = Opt
   Opt7@SrcMask2D        = where(.not.ismissing(src_data7), 1, 0)
   dst_data7 = (/ESMF_regrid(src_data7, Opt7)/)


   Opt8                  = True
   Opt8                  = Opt
   Opt8@SrcMask2D        = where(.not.ismissing(src_data8), 1, 0)
   dst_data8 = (/ESMF_regrid(src_data8, Opt8)/)


   Opt9                  = True
   Opt9                  = Opt
   Opt9@SrcMask2D        = where(.not.ismissing(src_data9), 1, 0)
   dst_data9 = (/ESMF_regrid(src_data9, Opt9)/)

return
end
