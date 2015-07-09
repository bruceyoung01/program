; $ID modis_viirs_scatter_grid.ncl V01 05/06/2012 22:55 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM modis_viirs_scatter_grid 
;  (1 ) READS MODIS AOD DATA
;  (2 ) CONVERTS MODIS AOD PIXEL DATA TO GRID DATA
;  (3 ) READS NPP VIIRS AOD DATA AND GEOLOCATION DATA
;  (4 ) CONVERTS NPP VIIRS AOD PIXEL DATA TO GRID DATA
;  (5 ) PLOTS MAP WITH AEROENT SITE ON IT
;  (6 ) USING MODIS GRIDED AOD DATA AND NPP VIIRS GRIDED AOD DATA, PLOTS 
;       SCATTER PLOT WITH CORRELATION INFO ON IT
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (05/06/2012)
;******************************************************************************

; LOAD FUNCTIONS AND PROCEDURES
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/function/ndectobin.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/function/add_markers.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/function/correlation.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/universal/ydn2md.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/wa/read_modis_aod_day.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/wa/filename_match_viirs.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/wa/read_viirs_va_day.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/wa/pixel_to_grid_degree.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/universal/map.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/wa/plot_scatter_modis_viirs.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/wa/plot_contour.ncl"


begin

;  OPEN A WORKSTATION AND CHOOSE COLORMAP
   type       = "x11"
;  type       = "pdf"
;  type       = "png"
   wks        = gsn_open_wks(type,"1plt_modis_viirs_scatter_grid_wa_qf_Aqua_v01")
   gsn_define_colormap(wks,"BlAqGrYeOrReVi200")

;  DEFINE MISSING VALUE
   bv1        = -9999
   bv2        = -9999.
   bv3        =  65529.
   bv4        =  65535.

   sitename   = "West US"
   sitem      = 0
   msatellite = "Aqua"
   vsatellite = "VIIRS"
;  SET UP MODIS DATA DIRECTORY AND FILE NAME LIST
   mdir       = "/home/bruce/sshfs/pfw/data/satellite/MODIS/wa/201202_03/"
   mflist     = "myd04_list"
   mfname     = asciiread(mdir + mflist, -1, "string")
   nmfname    = dimsizes(mfname)


;  SET UP NPP VIIRS DATA DIRECTORY AND FILE NAME LIST
   vdir       = "/home/bruce/sshfs/pfw/data/satellite/NPP/wa/"
   vflist     = "va_list"
   vfname     = asciiread(vdir + vflist, -1, "string")
   nvfname    = dimsizes(vfname)
;  SET UP NPP VIIRS GEOLOCATION INFO
   gflist     = "gaero_list"
   gfname     = asciiread(vdir + gflist, -1, "string")
   ngfname    = dimsizes(gfname)

;  DEFINE START AND END OF YEAR, MONTH, DAY, AND HOUR
   start_year = 2012
   end_year   = 2012
   start_month= 2
   end_month  = 2
   start_day  = 1
   end_day    = 1
   start_hour = 0
   end_hour   = 23
;  CALCULATE TOTAL DAYS
   start_jul  = greg2jul(start_year, start_month, start_day, -1)
   end_jul    = greg2jul(end_year, end_month, end_day, -1)
   nday       = end_jul - start_jul + 1

;  DEFINE MODIS VARIABLES FOR SUBROUTINE read_modis_aod_day.ncl
   mnp        = 203
   mnl        = 135
   mfactor    = 10
   tmnp       = mnp*mfactor
   myear      = new((/tmnp, mnl, nday/), integer, bv1)
   mmonth     = new((/tmnp, mnl, nday/), integer, bv1)
   mday       = new((/tmnp, mnl, nday/), integer, bv1)
   mhour      = new((/tmnp, mnl, nday/), integer, bv1)
   mlat       = new((/tmnp, mnl, nday/), float, bv2)
   mlon       = new((/tmnp, mnl, nday/), float, bv2)
   maod       = new((/tmnp, mnl, nday/), float, bv2)
   maod_qf    = new((/tmnp, mnl, nday/), integer, bv1)

;  DEFINE ARRAY FOR SUBROUTINE filename_match_viirs.ncl
   n_new      = 2000
   new_vfname = new(n_new, string)
   new_gfname = new(n_new, string)
   nfiles     = new(1, integer, bv1)

;  DEFINE NPP VIIRS VARIABLES FOR SUBROUTINE read_viirs_va_day.ncl
   vnp        = 96
   vnl        = 400
   vfactor    = 40
   tvnl       = vnl*vfactor
   vyear      = new((/vnp, tvnl, nday/), integer, bv1)
   vmonth     = new((/vnp, tvnl, nday/), integer, bv1)
   vday       = new((/vnp, tvnl, nday/), integer, bv1)
   vhour      = new((/vnp, tvnl, nday/), integer, bv1)
   vlat       = new((/vnp, tvnl, nday/), float, bv2)
   vlon       = new((/vnp, tvnl, nday/), float, bv2)
   vaod       = new((/vnp, tvnl, nday/), float, bv2)
   vaod_qf    = new((/vnp, tvnl, nday/), integer, bv1)

;  DEFINE VARIABLES FOR SUBROUTINE pixel_to_grid.ncl
;  DEFINE NEW GRID SIZE
   minpixel   = 1
   new_grid   = 0.25
;  SET UP STUDY REGION
;                        TEXAS    ; WA     ; SAHEL   GLOBAL
   maxlat     = 45.0     ;40.0    ; 45.0   ; 35.0     90.0
   minlat     = 30.0     ;25.0    ; 30.0   ;-10.0    -90.0
   maxlon     =-110.0    ;-90.0   ;-110.0  ; 45.0    180.0
   minlon     =-130.0    ;-110.0  ;-130.0  ;-25.0   -180.0 
;  GRID SIZE 
   gridsize_lat = floattoint((maxlat-minlat)/new_grid)+1
   gridsize_lon = floattoint((maxlon-minlon)/new_grid)+1
   grid_lat     = new((/gridsize_lon, gridsize_lat/), float, bv2)
   grid_lon     = new((/gridsize_lon, gridsize_lat/), float, bv2)

;  ASSIGN VALUE TO GRIDED LATITUDE AND LONGITUDE
   do l = 0, gridsize_lon-1
    do k = 0, gridsize_lat-1
     grid_lat(l, k) = minlat + new_grid*k
     grid_lon(l, k) = minlon + new_grid*l
    end do
   end do

;  DEFINE 3-DIMENSIONAL ARRAY FOR LATITUDE, LONGITUDE, AND 
;  MEAN OF AOD
   gmlat  = new((/gridsize_lon, gridsize_lat, nday/), float, bv2)
   gmlon  = new((/gridsize_lon, gridsize_lat, nday/), float, bv2)
   gmaod  = new((/gridsize_lon, gridsize_lat, nday/), float, bv2)
   gmcon  = new((/gridsize_lon, gridsize_lat, nday/), integer, bv1)
   gmstd  = new((/gridsize_lon, gridsize_lat, nday/), float, bv2)
   gvlat  = new((/gridsize_lon, gridsize_lat, nday/), float, bv2)
   gvlon  = new((/gridsize_lon, gridsize_lat, nday/), float, bv2)
   gvaod  = new((/gridsize_lon, gridsize_lat, nday/), float, bv2)
   gvcon  = new((/gridsize_lon, gridsize_lat, nday/), integer, bv1)
   gvstd  = new((/gridsize_lon, gridsize_lat, nday/), float, bv2)

   mpplot = new(1, graphic)
   awplot = new(1, graphic)
   mcplot = new(1, graphic)
   vcplot = new(1, graphic)

;  CALL SUBROUTINE read_modis_aod_day.ncl TO READ MODIS AOD DATA
   read_modis_aod_day(mdir, mfname, nmfname, bv1, bv2, \
                      myear, mmonth, mday, mhour,  \
                      mlat, mlon, maod, maod_qf)

;  CALL SUBROUTINE pixel_to_grid.ncl TO GRID MODIS DATA
   pixel_to_grid_degree \
                (bv1, bv2, grid_lat, grid_lon, gridsize_lon, gridsize_lat, \
                 mlat, mlon, tmnp, mnl, minpixel, maod,                    \
                 gmaod, gmcon, gmstd)
   print("====================MODIS IS DONE===================================")

;  CALL SUBROUTINE filename_match_viirs.ncl TO MATCH
;  NPP VIIRS EDR AOD FILE NAME:
;  VAOOO_npp_d20120331_t2032472_e2034114_b02206_c20120401030451240471_noaa_ops.h5
;  NPP VIIRS EDR GEOLOCATION FILE NAME:
;  GAERO_npp_d20120201_t0909467_e0911109_b01362_c20120202145305252816_noaa_ops.h5
   filename_match_viirs(vdir, vfname, nvfname, gfname, ngfname, \
                        new_vfname, new_gfname, nfiles)

;  CALL SUBROUTINE read_viirs_va_day.ncl TO READ VIIRS AOD AND 
;  GEOLOCATION DATA
   read_viirs_va_day(bv1, bv2, bv3, bv4, vdir, new_vfname, new_gfname, nfiles, \
                     vyear, vmonth, vday, vhour, vlat, vlon, vaod, vaod_qf)

;  CALL SUBROUTINE pixel_to_grid.ncl TO GRID VIIRS DATA
   pixel_to_grid_degree \
                (bv1, bv2, grid_lat, grid_lon, gridsize_lon, gridsize_lat, \
                 vlat, vlon, vnp, tvnl, minpixel, vaod,                    \
                 gvaod, gvcon, gvstd)
   print(">>>>>>>>>>>>>>>>>>>>NPP VIIRS IS DONE<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<")

;  PLOT CONTOUR FOR BOTH OF MODIS AND VIIRS
   do i = 0, nday-1
;  CALL SUBROUTINE plot_contour TO PLOT CONTOUR
    plot_contour(wks, msatellite, grid_lat, grid_lon, gmaod(:, :, i), \
                 minlat, maxlat, minlon, maxlon, myear(:, :, i),      \
                 mmonth(:, :, i), mday(:, :, i), mcplot)
;  CALL SUBROUTINE plot_contour TO PLOT CONTOUR
    plot_contour(wks, vsatellite, grid_lat, grid_lon, gvaod(:,:,i), \
                 minlat, maxlat, minlon, maxlon, vyear(:, :, i),    \
                 vmonth(:, :, i), vday(:, :, i), vcplot)
   end do

;  CALL SUBROUTINE map TO PLOT THE MAP
   map(wks, minlat, maxlat, minlon, maxlon, mpplot)

;  CONVERT N-D TO 1-D ARRAY
   oned_gmaod = ndtooned(gmaod)
   oned_gmstd = ndtooned(gmstd)
   oned_gmavg = avg(oned_gmaod)
   ndim_oned_gmaod = dimsizes(oned_gmaod)
   oned_gvaod = ndtooned(gvaod)
   oned_gvstd = ndtooned(gvstd)
   oned_gvavg = avg(oned_gvaod)
;  CALL SUBROUTINE plot_scatter_modis_viirs.ncl TO PLOT SCATTER PLOT
   plot_scatter_modis_viirs \
               (wks, sitename, ndim_oned_gmaod, oned_gmaod, oned_gvaod,\
                oned_gmstd, oned_gvstd, oned_gmavg, oned_gvavg, mpplot,\
                awplot)
system("date")
print("WELL DONE BRUCE !!!")
end
