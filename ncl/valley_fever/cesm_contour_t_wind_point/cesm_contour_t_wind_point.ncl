; $ID: cesm_contour_t_wind_point.ncl V01 04/13/2014 11:31 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM cesm_contour_t_wind_point READS AND PLOTS CESM TEMPERATURE 
;  CONTOUR AND OVERLAID WITH WIND.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) 
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (04/13/2014)
;******************************************************************************

;  LOAD FUNCTIONS AND PROCEDURES
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm_epa.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "/Users/bruce/Documents/A/program/ncl/ncl_lib/function/double2string.ncl"
load "/Users/bruce/Documents/A/program/ncl/ncl_lib/procedure/valley_fever/plot_cesm_contour_vector_t_point.ncl"


begin
;  SET UP THE PLOT PLATFORM
;  type      = "x11" 
   type      = "pdf"
;  type      = "ps"
;  type      = "png"
   wks       = gsn_open_wks(type, "1plt_cesm_contour_t_wind_point_v01")
   gsn_define_colormap(wks,"WhGrYeOrReVi200")

;  DEFINE BAD VALUES
   bv1       = -9999
   bv2       = -9999.
   bv3       = "missingvalue"
   str       = "string"

;  SPECIFY WRF OUTPUT DIRECTORY
   dir       = "/Volumes/TOSHIBA_3B/iproject/valley_fever/cesm_output/"
   filelist  = "cam_d01_list"
   filename  = asciiread(dir + filelist, -1, str)
   nfile     = dimsizes(filename)

;  SET UP LIMITED REGION
   domain     = str_get_cols(filelist, -8, -6)
;  MOTHER DOMAIN (d01)
   if (domain .eq. "d01") then
      minlat =  25.0
      maxlat =  45.0
      minlon = -125.0
      maxlon = -95.0
;  NEST DOMAIN (d02)
   else if (domain .eq. "d02") then
      minlat =  30.0
      maxlat =  37.0
      minlon = -122.0
      maxlon = -110.0
   end if
   end if

;  SET UP SITE INFO
   longitude = (/-112.0667, -118.25/)
   latitude  = (/33.45, 34.05/)
   plot      = new(1, graphic)

;  DO FILE NAME LOOP TO READ AND PLOT EACH FILE
   do i = 0, nfile-1
      a     = addfile(dir + filename(i) + ".nc", "r")
      time  = a->time
      stime = double2string(time)
      lat   = a->lat
      lon   = a->lon
      lev   = a->lev
      slev  =double2string(lev)
      t     = a->T
      u     = a->U
      v     = a->V

;  GET DIMENSION SIZES
      ntime  = dimsizes(stime)
      nlat   = dimsizes(lat)
      nlon   = dimsizes(lon)
      nlev   = dimsizes(lev)

;  DO TIME AND LEVEL LOOP TO PLOT CONTOUR AND VECTOR IN TIMES AND LEVELS
      do j = 0, 0;ntime-1
         do k = 0, nlev-1
            print("NOW WORKING ON : " + "Sigma Pressure : " + slev(k) + "Time: " + stime(j))
            printMinMax(t, False)
;  CALL SUBROUTINE plot_cesm_contour_vector_t_point.ncl TO PLOT CONTOUR 
;  AND VECTOR
            plot_cesm_contour_vector_t_point \
            (wks, minlat, maxlat, minlon, maxlon, latitude, longitude, stime(j), \
             slev(k), u(j, k, :, :), v(j, k, :, :), t(j, k, :, :), \
             plot)
         end do
      end do
   end do
end
