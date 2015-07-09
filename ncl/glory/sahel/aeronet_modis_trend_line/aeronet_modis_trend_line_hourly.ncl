; $ID: aeronet_trend_line.ncl V01 01/16/2012 14:20 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM aeronet_trend_line IS USED TO PLOT THE TREND LINE
;  BETWEEN AERONET AOD AND WRFCHEM PM2.5 SIMULATED CONCENTRATION, AND PLOT IT 
;  OUT AS LINE PLOT.(BRUCE 01/16/2012)
;
;  VARIABLES:
;  ============================================================================
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (01/16/2012)
;  (2 ) ADD CORRELATION INFO. (02/19/2012)
;******************************************************************************
;

; LOAD LIBRARIES
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm_epa.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/pro_fun.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/read_aeronet_data.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/calculate_aeronet_hourly_average.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/marker_map.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/point_wrfchem_aeronet_hourly.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/plot_trend_hourly.ncl"

begin

;  OPEN A WORKSTATION AND CHOOSE COLORMAP
   type       = "x11"
;  type       = "pdf"
;  type       = "png"
   wks        = gsn_open_wks(type,"1plt_wrf_line_pm25_2008_0201_0205_hourly_v01_fb_ndust")
   gsn_define_colormap(wks,"BlAqGrYeOrReVi200")

;  SET DIRECTORY AND FILE NAME LIST
   dir        = "/media/disk/data/aeronet/sahel/2008/aeronet_sahel_200802/"
   fnamelist  = "lev20"
   fname      = asciiread(dir + fnamelist, -1, "string")
   nsites     = dimsizes(fname)

;  OPEN WRF/CHEM OUTPUT FILES
;  LIST THE NC FILES AND READ NC FILES
   wdir       = "/home/bruce/sshfs/pfw/model/wrfchem2/WRFV3/test/em_real/wrfout_sahel_800_fb_ndust/"
   sfile      = "wrfout_d01_2008-02*"
   nhour      = 24
   nitem      = 60
   nhourly    = 999 ; # OF HOURS PER MONTH
   nday       = 5  ; # OF DAYS
   sitem      = 6

;  DEFINE MISSING VALUE
   bv1        = -999
   bv2        = -999.
   sitename   = new(1, string)
   longitude  = new(1, float, bv2)
   latitude   = new(1, float, bv2)
   elevation  = new(1, float, bv2)
   nfiles     = new(1, integer, bv1)
   header     = new(  nitem, string)
   aod_hourly = new((/nhourly, nitem/), float, bv2)
   saod       = new((/nhourly, nitem/), float, bv2)
   swpm25     = new(  nhourly, float, bv2)
   date       = new((/nhourly, 4/), integer, bv1)
   mpplot     = new(1, graphic)
   plot       = new(1, graphic)
   awplot     = new(1, graphic)

;============================AERONET SITES=====================================
;  DO LOOP # OF SITES
   do i = 0, nsites-1
    system("date")
    iselect = 0
    print("WORKING ON : " + i + " OF " + nsites)
;  READ THE WHOLE FILE NAME LIST FOR AERONET AOD INFO
    sdata      = asciiread(dir + fname(i), -1, "string")
    nlines     = dimsizes(sdata)-5
    year       = new(nlines, integer, bv1)
    month      = new(nlines, integer, bv1)
    day        = new(nlines, integer, bv1)
    hour       = new(nlines, integer, bv1)
    aod_raw    = new((/nlines, nitem/), float, bv2)

;  CALL SUBROUTINE read_aeronet_data TO READ OUT AERONET SITE INFO AND AOD
    read_aeronet_data(dir, fname(i), year, month, day, hour, sitename, \
                      longitude, latitude, elevation, header, aod_raw)

;  CALL SUBROUTINE calculate_aeronet_hourly_average TO COMPUTE THE HOURLY 
;  AVERAGE OF AERONET AOD DATASETS
    calculate_aeronet_hourly_average(nlines, year, month, day, hour,    \
                                     aod_raw, date, aod_hourly)

;  CALL SUBROUTINE marker_map TO PLOT AEROENT SITES ON THE MAP
    marker_map(wks, longitude, latitude, mpplot, plot)

;  CALL SUBROUTINE point_wrfchem_aeronet TO SELECT WRFCHEM DATA 
;  DEPENDING ON AERONET SITE INFO
    point_wrfchem_aeronet_hourly(wdir, sfile, iselect, date, nhour, longitude, \
                          latitude, nhourly, aod_hourly, nfiles, saod, swpm25)

;  CALL SUBROUTINE plot_trend_line TO PLOT THE TREND LINE
    plot_trend_hourly(wks, sitename, year, month, date, nfiles, saod, swpm25,   \
                      sitem, nlines, nday, nhour, bv1, bv2, mpplot,     \
                      awplot)

    delete([/sdata, nlines, year, month, \
             day, hour, aod_raw/])
    system("date")
 end do ; END OF IS LOOP
end
