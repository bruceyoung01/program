;  $ID: contour_pixel_seviri_oper_cot.ncl V01 09/20/2015 10:07 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM contour_pixel_seviri_oper_cot.ncl READS SEVIRI OPER DATA, AND PLOTS 
;  THE CONTOUR IMAGE.
;
;  DATA:
;  ============================================================================
;  (1 ) SEVIRI OPER DATA:
;       SOURCE: ftp://msgcpp-ogc-archive.knmi.nl/0001/
;       FILE NAME: 
;       SEVIR_OPER_R___MSGCPP__L2__20130702T000000_20130703T000000_0001.nc
;       STATEMENT:
;       SPATIAL RESOLUTION: 1km;
;       TIME RESOLUTION: 15min;
;       REGION: 
;
;  FLOW CHART:
;  ============================================================================
;  (1 ) SETUP THE BASIC INFO, INCLUDING OUTPUT FILENAME, INPUT DATA DIRECTORY, 
;       DEFAULT MISSING VALUES, STUDY REGION LIMITS, TIME PERIOD, AND SWITCHES
;  (2 ) DO itime LOOP;
;  (3 ) DO iyear, imonth, AND iday LOOP;
;  (4 ) SPECIFY THE FILENAME BASED ON THE YEAR, MONTH, AND DAY;
;  (5 ) READ VARIABLES FROM THE SPECIFIED FILE NAME;
;  (6 ) PLOT THE CONTOUR IMAGE FOR SPECIFIC PARAMETER AT itime @iday;
;  (7 ) END OF iday;
;  (8 ) PLOT THE CONTOUR IMAGE FOR SPECIFIC PARAMETER AT itime @imonth;
;  (9 ) END OF imonth;
;  (10) PLOT THE CONTOUR IMAGE FOR SPECIFIC PARAMETER AT itime @iyear;
;  (11) END OF iyear.
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (09/25/2015)
;******************************************************************************
;
;  LOAD FUNCTIONS AND PROCEDURES
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRF_contributed.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/universal/gsn_csm_epa.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/universal/polygon_map.ncl"
load "/home/vy57456/zzbatmos_user/program/ncl/ncl_lib/procedure/aca_diurnal/plot_contour_grid_landmask_seviri_oper.ncl"

begin
;  OPEN A WORKSTATION AND CHOOSE COLORMAP
;  type       = "x11"
   type       = "pdf"
;  type       = "png"
   plot_dir   = "/home/vy57456/zzbatmos_user/program_plot/ncl/aca_diurnal/contour_pixel_seviri_oper_cot/"
   wks        = gsn_open_wks(type, plot_dir + "1plot_contour_pixel_seviri_oper_cot_v03")
   gsn_define_colormap(wks,"WhBlGrYeOrReVi202")

;  DATA DIRECTORY
   dir        = "/home/vy57456/zzbatmos_common/Data/SEVIRI/SEVIR_OPER_R/"

;  DEFINE BAD VALUE
   bv1        = -9999
   bv2        = -9999.

;  SET UP LIMITED REGION
   minlat     =-40.0
   maxlat     = 20.0
   minlon     =-30.0
   maxlon     = 30.0
;  LATTITUDE AND LONGITUDE FOR STUDY REGION
   lat_pg     = (/minlat, minlat, maxlat, maxlat, minlat/)
   lon_pg     = (/minlon, maxlon, maxlon, minlon, minlon/)

;  SET UP THE START TIME AND END TIME
   start_year   = 2013
   end_year     = 2013
   start_month  = 7
   end_month    = 7
   start_day    = 1
   ntime        = 96

;  SELECT WHICH PARAMETER TO PLOT
   element      = "cot"

;  WHICH PLOT IS TO BE PLOTTED
   logic_plot_daily   = True
   logic_plot_monthly = True
   logic_plot_yearly  = True

;  SWITCH FOR BACKGROUND MAP
   switch_pg    = False

;  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;  START TO PROCESS DATA
;  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;  DO TIME LOOP
   do itime = 50, 51;ntime-1

;  DO YEAR LOOP
      do iyear = start_year, end_year
         siyear = sprinti("%0.4i", iyear)

;  DO MONTH LOOP
         do imonth = start_month, end_month
            simonth = sprinti("%0.2i", imonth)

;  CALCULATE THE NUMBER OF DAYS IN THIS MONTH
            nday_month = days_in_month(iyear, imonth)

print("a1")
;  DO DAY LOOP
            do iday = start_day, 2;nday_month
               siday = sprinti("%0.2i", iday)
;  BUILD FILE NAME BASED ON THE YEAR, MONTH, DAY
               start_yyyymmdd = siyear + simonth + siday
;  CONSIDER THE SITUATION THAT THE iday IS THE LAST DAY OF THAT MONTH, IF IT 
;  IS THE CASE, CONSIDER TO MOVE THE MONTH TO THE NEXT MONTH AND USING THE 
;  FIRST DAY OF THAT MONTH. FOR VERY SPECIFIC CASE, IF THIS DAY IS THE LAST DAY 
;  OF THE YEAR, IN THIS CASE, WE ALSO NEED TO MOVE ON THE YEAR TO THE NEXT YEAR
               if (iday .lt. nday_month) then
                  iyear2  = iyear
                  imonth2 = imonth
                  iday2   = iday + 1
               else if (iday .eq. nday_month .and. \
                        imonth .lt. 12) then
                  iyear2  = iyear
                  imonth2 = imonth + 1
                  iday2   = 1
               else if (iday .eq. nday_month .and. \
                        imonth .eq. 12) then
                  iyear2  = iyear + 1
                  imonth2 = imonth + 1
                  iday2   = 1
               end if
               end if
               end if
               siyear2  = sprinti("%0.4i", iyear2)
               simonth2 = sprinti("%0.2i", imonth2)
               siday2   = sprinti("%0.2i", iday2)
               end_yyyymmdd = siyear2 + simonth2 + siday2

               filename  = "SEVIR_OPER_R___MSGCPP__L2__" + \
                           start_yyyymmdd + "T000000_"   + \
                           end_yyyymmdd   + "T000000_"   + \
                           "0001.nc"
               if (.not.fileexists(dir + "/" + siyear + "/"  + \
                                   simonth + "/" + siday + "/" \
                                   + filename))
                  continue
               end if
               print("NOW PROCESSING : " + filename)
print("y1")

;  START TO READ THE VARIABLES FROM SEVIRI FILE NAME
               a     = addfile(dir + "/" + siyear + "/"    + \
                               simonth + "/" + siday + "/" + \
                               filename, "r")
               if (.not.isdefined("lat"))
                  lat   = (/a->lat/)
                  lon   = (/a->lon/)
printVarSummary(lat)
printVarSummary(lon)
print("b2")
;                 lat!0 = "lat"
;                 lat!1 = "lon"
;                 lon!0 = "lat"
;                 lon!1 = "lon"
;printMinMax("lat = " + lat, 0)
print("b3")
               end if
print("b1")
               time  = a->time
               cth   = a->cth(itime, :, :)
               cot0  = a->cot(itime, :, :)
printMinMax(cot0, 0)
print("b4")
               cot   = (/short2flt(cth)/)
print("b5")
               cot@_FillValue = bv2
               cot!0     = "lat"
               cot!1     = "lon"
               cot@lat2d = lat
               cot@lon2d = lon
printMinMax(cot, 0)


;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;  PLOT DAILY IMAGE
;  @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
               if (logic_plot_daily) then
;  CALL SUBROUTINE plot_contour_grid_landmask_seviri_oper.ncl TO PLOT DAILY 
;  IMAGE WITH BACKGROUND MAP ON IT
                  plot_contour_grid_landmask_seviri_oper\
                  (wks, minlat, maxlat, minlon, maxlon, \
                  element, cot, end_yyyymmdd)

               if (switch_pg) then
;  CALL SUBROUTINE polygon_map.ncl TO PLOT MAP WITH POLYGON ON IT
                  polygon_map \
                  (wks, minlat, maxlat, minlon, maxlon, \
                  lat_pg, lon_pg)
               end if
               end if
                      
            end do ;iday
         end do ;imonth
      end do ;iyear
   end do ;itime

end
