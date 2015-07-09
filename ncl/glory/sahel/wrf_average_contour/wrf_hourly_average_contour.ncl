; $ID: wrf_hourly_average_contour.ncl V01 01/17/2012 20:40 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM wrf_hourly_average_contour IS USED TO PLOT WRFCHEM OUTPUT FILE AS 
;  CONTOUR PLOT.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (01/17/2012)
;******************************************************************************

;  LOAD LIBRARIES
   load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
   load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
   load "/home/bruce/program/ncl/tutorial/test/ncl_lib/calculate_wrfchem_hourly_average.ncl"
   load "/home/bruce/program/ncl/tutorial/test/ncl_lib/plot_wrfchem_map_contour.ncl"
   load "/home/bruce/program/ncl/tutorial/test/ncl_lib/plot_wrfchem_map_contour_diff.ncl"

begin

;  WORK STATION
   type     = "x11"
;  type     = "pdf"
   wks      = gsn_open_wks(type,"1plt_wrf_hourly_average_map_contour_sahel_t2_diff")
   gsn_define_colormap(wks,"WhBlGrYeOrReVi200")

;  SET UP DIRECTORY
   dir      = "/home/bruce/sshfs/pfw/model/wrfchem2/WRFV3/test/em_real/wrfout_sahel_800/"
   filelist = "wrfout_d01_2008"
   dir2     = "/home/bruce/sshfs/pfw/model/wrfchem2/WRFV3/test/em_real/wrfout_sahel_800_nfb_ndust/"
   filelist2= "wrfout_d01_2008"

;  SET UP CONSTANTS
   bv1      = -999
   bv2      = -999.0
   nhour    = 24

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
   t2_hourly= new((/nhour, nlat, nlon/), float, bv2)
   t2_hourly2=new((/nhour, nlat, nlon/), float, bv2)
   t2_hourlyd=new((/nhour, nlat, nlon/), float, bv2)
   pm25_hourly = new((/nhour, nlev, nlat, nlon/), float, bv2)
   pm25_hourly2= new((/nhour, nlev, nlat, nlon/), float, bv2)

;  CALL SUBROUTINE calculate_wrfchem_hourly_average.ncl TO CALCULATE HOURLY 
;  AVERAGE OF THE WHOLE FEB 2008 SAHEL
   calculate_wrfchem_hourly_average(dir, filename, nfiles, bv1, bv2, nhour, \
                                    date, wlat, wlon, t2_hourly, pm25_hourly)
   calculate_wrfchem_hourly_average(dir2, filename, nfiles, bv1, bv2, nhour, \
                                    date, wlat, wlon, t2_hourly2, pm25_hourly2)
   t2_hourlyd = t2_hourly - t2_hourly2
;  DO HOUR LOOP
   do i = 0, nhour-1
;  CALL SUBROUTINE plot_wrfchem_map_contour.ncl TO PLOT THE RESULT OUT
    plot_wrfchem_map_contour_diff(wks, date, i, wlat, wlon, t2_hourlyd, plot)
   end do
end

