;  $ID: contour_pixel_seviri_cot.ncl V01 06/25/2015 16:46 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM contour_pixel_seviri_cot.ncl READS SEVIRI DATA, WHICH HAVE ONE RECORD 
;  PER 15MIN. AND PLOTS THEM AS CONTOUR OVER A MAP.
;
;  PROGRAM FLOW CHART:
;  ============================================================================
;  (1 ). READ SEVIRI FILE NAME BASED ON YEAR, MONTH, DAY, HOUR, AND MIN.
;  (2 ). PLOT THE IMAGE FOR EVERY 15 MIN.
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (06/25/2015)
;******************************************************************************
;
;  LOAD FUNCTIONS AND PROCEDURES
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/universal/gsn_csm_epa.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/universal/polygon_map.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/plot_contour_grid_landmask_seviri.ncl"

begin

;  OPEN A WORKSTATION AND CHOOSE COLORMAP
   type       = "x11"
;  type       = "pdf"
;  type       = "png"
   wks        = gsn_open_wks(type,"1plot_contour_pixel_seviri_cot_v02")
   gsn_define_colormap(wks,"WhBlGrYeOrReVi202")

;  DATA DIRECTORY FOR SEVIRI
   dir        = "/home/vy57456/zzbatmos_common/Data/SEVIRI/SEV_06-CLD-L2.v1.03/"

;  DEFINE BAD VALUE
   bv1        = -9999
   bv2        = -9999.
   bv3        = -999.999

;  SET UP LIMITED REGION
   minlat     =-40.0
   maxlat     = 20.0
   minlon     =-30.0
   maxlon     = 30.0
;  LATTITUDE AND LONGITUDE FOR STUDY REGION
   lat_pg     = (/minlat, minlat, maxlat, maxlat, minlat/)
   lon_pg     = (/minlon, maxlon, maxlon, minlon, minlon/)

;  SET UP THE START TIME AND END TIME
   start_year = 2008
   end_year   = 2008
   start_month= 6
   end_month  = 6
   start_day  = 1
   start_hour = 0
   end_hour   = 23
   start_min  = 0
   end_min    = 45
   min_stride = 15
   start_ind_lat = 1400
   end_ind_lat   = 3000
   start_ind_lon = 1100
   end_ind_lon   = 2600

;  SELECT WHICH PARAMETER TO PLOT
   element    = "cot16"

;  WHICH PLOT IS TO BE PLOTTED
   logic_plot_daily    = True

;  SWITCH FOR BACKGROUND MAP
   switch_pg  = False

;  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;  START TO PROCESS DATA
;  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;  DO YEAR LOOP
   do iyear = start_year, end_year

;  DO MONTH LOOP
      do imonth = start_month, end_month

;  CALCULATE THE NUMBER OF DAYS IN THIS MONTH
         nday_month = days_in_month(iyear, imonth)
;  DO DAY LOOP
         do iday = start_day, 5;nday_month
;  DO HOUR LOOP
            do ihour = start_hour, end_hour
;  DO MINUTE LOOP
               do imin = start_min, end_min, min_stride
print("aa")
                  siyear  = sprinti("%0.4i", iyear)
                  simonth = sprinti("%0.2i", imonth)
                  siday   = sprinti("%0.2i", iday)
                  sihour  = sprinti("%0.2i", ihour)
                  simin   = sprinti("%0.2i", imin)
                  symd1   = siyear + "_" + simonth + "_" + siday
                  symd2   = siyear + "-" + simonth + "-" + siday
                  stime   = sihour + "-" + simin + "-00"
;  BUILD FILE NAME BASED ON YEAR, MONTH, DAY, HOUR, MINUTE
                  filename= "SEV_06-CLD-L2_" + symd2 + "T" + stime + "_V1-03.hdf"
;  CHECK WHETHER THE FILENAME EXISTS OR NOT
                  if (fileexists(dir + siyear + "/" + symd1 + "/" + filename)) then
                     print("Now Processing = " + filename)
;  READ VARIABLES FROM HDF FILE
                     a     = addfile(dir + siyear + "/" + symd1 + "/" + filename, "r")
                     if (.not.isdefined("lat")) then
                        lat   = (/a->MSG_Latitude(start_ind_lat:end_ind_lat, start_ind_lon:end_ind_lon)/)
                        lon   = (/a->MSG_Longitude(start_ind_lat:end_ind_lat, start_ind_lon:end_ind_lon)/)
                        lat!0 = "lat"
                        lat!1 = "lon"
                        lon!0 = "lat"
                        lon!1 = "lon"
                        lat@_FillValue = bv3
                        lon@_FillValue = bv3
print("bb")
                     end if
print("cc")
                     Cloud_Optical_Thickness_16 = a->Cloud_Optical_Thickness_16(start_ind_lat:end_ind_lat, start_ind_lon:end_ind_lon)
                     cot16 = Cloud_Optical_Thickness_16*Cloud_Optical_Thickness_16@scale_factor
                     cot16@_FillValue = bv2
                     cot16!0     = "lat"
                     cot16!1     = "lon"
                     cot16@lat2d = lat
                     cot16@lon2d = lon
                     delete([/Cloud_Optical_Thickness_16/])
print("dd")
                     if (all(ismissing(cot16))) then
                        print("----------------------------------------------")
                        print("VARIABLES ARE ALL MISSING VALUES!!!!!!!!!")
                        continue
                     end if
;printVarSummary(lat)
;printVarSummary(Cloud_Optical_Thickness_16)
;printVarSummary(cot16)
;print(max(cot16))
;print("max = " + max(lat))
;print("min = " + min(lat))
;print("max = " + max(lon))
;print("min = " + min(lon))
                  else
                     print("-------------------------------------------------")
                     print("SEVIRI FILE DOESN'T EXIST = " + filename)
                     continue
                  end if

;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;  PLOT DAILY IMAGE
;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
                  if (logic_plot_daily) then
print("ee")
                     sdaily = symd2 + " " + stime
;  CALL SUBROUTINE plot_contour_grid_landmask_seviri.ncl TO PLOT MONTHLY IMAGE WITH BACKGROUND MAP ON IT
                     plot_contour_grid_landmask_seviri     \
                     (wks, minlat, maxlat, minlon, maxlon, \
                     element, cot16, sdaily)
print("ff")
                  if (switch_pg) then
;  CALL SUBROUTINE polygon_map.ncl TO PLOT MAP WITH POLYGON ON IT
                     polygon_map \
                     (wks, minlat, maxlat, minlon, maxlon, \
                     lat_pg, lon_pg)
                  end if
                  end if

print("gg")
                  delete([/cot16/])
               end do ;imin
            end do ;ihour
         end do ;iday
      end do ;imonth
   end do ;iyear

end
