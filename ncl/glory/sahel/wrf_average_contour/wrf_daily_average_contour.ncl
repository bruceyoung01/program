; $ID: wrf_daily_average_contour.ncl V01 01/18/2012 16:43 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM wrf_daily_average_contour IS USED TO PLOT WRFCHEM OUTPUT DAILY 
;  AVERAGE AS CONTOUR PLOT.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (01/18/2012)
;******************************************************************************

;  LOAD LIBRARIES
   load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
   load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
   load "/home/bruce/program/ncl/tutorial/test/ncl_lib/calculate_wrfchem_daily_average.ncl"
   load "/home/bruce/program/ncl/tutorial/test/ncl_lib/plot_wrfchem_map_contour.ncl"
   load "/home/bruce/program/ncl/tutorial/test/ncl_lib/plot_wrfchem_map_contour_diff.ncl"

begin

;  WORK STATION
;  type     = "x11"
   type     = "pdf"
   wks      = gsn_open_wks(type,"1plt_wrf_daily_average_map_contour_sahel_t2_diff")
   gsn_define_colormap(wks,"WhBlGrYeOrReVi200")

;  SET UP DIRECTORY
   dir      = "/home/bruce/sshfs/pfw/model/wrfchem2/WRFV3/test/em_real/wrfout_sahel_800_fb_ndust/"
   filelist = "wrfout_d01_2008"
   dir2     = "/home/bruce/sshfs/pfw/model/wrfchem2/WRFV3/test/em_real/wrfout_sahel_800_nfb_ndust/"
   filelist2= "wrfout_d01_2008"

;  SET UP CONSTANTS
   bv1      = -999
   bv2      = -999.0
   nday     = 29

;  READ WRFCHEM OUTPUT FILE NAMES LIST
   filename = asciiread(dir + filelist, -1, "string")
   nfiles   = dimsizes(filename)
;  READ ONE WRFCHEM FILE TO GET THE DIMENSION FOR LATER DEFINE NEW ARRAY
   b        = addfile(dir + filename(0), "r")
   c        = b->PM2_5_DRY
   ndim     = dimsizes(c)
   nlev     = ndim(1)
   nlat     = ndim(2)
   nlon     = ndim(3)
   plot     = new(1, graphic)
   date     = new((/nfiles, 4/), integer, bv1)
   wlat     = new((/nlat, nlon/), float, bv2)
   wlon     = new((/nlat, nlon/), float, bv2)
   t2_daily = new((/nday, nlat, nlon/), float, bv2)
   t2_daily2= new((/nday, nlat, nlon/), float, bv2)
   t2_dailyd= new((/nday, nlat, nlon/), float, bv2)
   pm25_daily = new((/nday, nlev, nlat, nlon/), float, bv2)
   pm25_daily2= new((/nday, nlev, nlat, nlon/), float, bv2)

;  CALL SUBROUTINE calculate_wrfchem_daily_average.ncl TO CALCULATE DAILY 
;  AVERAGE OF THE WHOLE FEB 2008 SAHEL
   calculate_wrfchem_daily_average(dir, filename, nfiles, bv1, bv2, nday, \
                                   date, wlat, wlon, t2_daily, pm25_daily)
   calculate_wrfchem_daily_average(dir2, filename, nfiles, bv1, bv2, nday, \
                                   date, wlat, wlon, t2_daily2, pm25_daily2)
   t2_dailyd = t2_daily - t2_daily2
;  DO DAY LOOP
   do i = 0, nday-1
;  CALL SUBROUTINE plot_wrfchem_map_contour.ncl TO PLOT THE RESULT OUT
    plot_wrfchem_map_contour_diff(wks, date, i, wlat, wlon, t2_dailyd, plot)
   end do
end

