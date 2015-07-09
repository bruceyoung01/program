;  $ID: viirs_contour_pixel_dnb_point_polyline_direc_group.ncl V01 
;       02/19/2014 23:14 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM viirs_contour_pixel_dnb_point_polyline_direc_group READS VIIRS 
;  PIXEL DATA, PLOTS IT AS CONTOUR AND ADD A POINT AND POLYLINE WITH SCANNING 
;  DIRECTION ON IT.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (02/19/2014)
;******************************************************************************

;  LOAD FUNCTIONS AND PROCEDURES
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "/Users/bruce/Documents/A/program/ncl/ncl_lib/function/int2string_format.ncl"
load "/Users/bruce/Documents/A/program/ncl/ncl_lib/procedure/atlanta/read_group_number_site.ncl"
load "/Users/bruce/Documents/A/program/ncl/ncl_lib/procedure/atlanta/read_visualized_cloudmask_date_site.ncl"
load "/Users/bruce/Documents/A/program/ncl/ncl_lib/procedure/atlanta/process_day_viirs.ncl"
load "/Users/bruce/Documents/A/program/ncl/ncl_lib/procedure/atlanta/read_viirs_rad_1day.ncl"
load "/Users/bruce/Documents/A/program/ncl/ncl_lib/procedure/atlanta/read_select_pixel_index.ncl"
load "/Users/bruce/Documents/A/program/ncl/ncl_lib/procedure/atlanta/match_group_number_site_pickup_cloudmask.ncl"
load "/Users/bruce/Documents/A/program/ncl/ncl_lib/procedure/atlanta/select_viirs_point_hourly_pixel_polyline.ncl"
load "/Users/bruce/Documents/A/program/ncl/ncl_lib/procedure/atlanta/plot_viirs_pixel_rad_point_polyline_direc_group.ncl"


begin
;  OPEN A WORKSTATION AND CHOOSE COLORMAP 
;  type       = "x11"
   type       = "pdf"
;  type       = "png"
;  wks        = gsn_open_wks(type,"1plt_viirs_contour_pixel_dnb_point_polyline_direc_group_v01")
;  gsn_define_colormap(wks,"gsdtol")

;  DEFINE MISSING VALUE
   bv0        = "Fillvalue"
   bv1        = -999
   bv2        = -999.
   logic_leap = "leap"
   nfactor    = 100000000

;  SET DIRECTORY AND FILE NAME FOR VIIRS RADIANCE
   dir        = "/Volumes/TOSHIBA_3B/iproject/atlanta/viirs/night/"
   gflist     = "GDNBO_list_jun"
   vflist     = "SVDNB_list_jun"
   gfname     = asciiread(dir + gflist, -1, "string")
   vfname     = asciiread(dir + vflist, -1, "string")
   ngfname    = dimsizes(gfname)
   nvfname    = dimsizes(vfname)

;  SET UP DIRECTORY INFO FOR CLOUD MASK
   dirc       = "/Users/bruce/Documents/A/program/idl/atlanta/NPP/DNB/picked/"
;  filenamec  = "Site_cloudmask_clear.txt"
   filenamec  = "Site_cloudmask.txt"

;  SET UP DIRECTORY INFO FOR SELECTED RADIANCE INDEX
   dirind     = "/Users/bruce/Documents/A/program/idl/atlanta/npp/Bruce_data/scatter_plot_data/"
;  filelistind= "select_pixel_index_all"
   filelistind= "select_pixel_index"
   filenameind= asciiread(dirind + filelistind, -1, "string")

;  SET UP DIRECTORY INFO FOR GROUP NUMBER ON EACH SITE
   dirg       = "/Users/bruce/Documents/A/program/idl/atlanta/npp/Bruce_data/scatter_plot_data/"
   filenameg  = "group_number_site"

   siteid     = (/"A", "B", "C", "D", "E", "CTR"/)

;  SET UP LIMITED REGION FOR ATLANTA
   minlat     = 25.0
   maxlat     = 45.0
   minlon     =-110.0
   maxlon     =-65.0

;  DECLARE VARIABLES FOR SUBROUTINE process_day_viirs
   tmpnday    = 182
   nday       = new((/1/), integer, bv1)
   startinx   = new((/tmpnday/), integer, bv1)
   endinx     = new((/tmpnday/), integer, bv1)
   year       = new((/tmpnday/), integer, bv1)
   mon        = new((/tmpnday/), integer, bv1)
   date       = new((/tmpnday/), integer, bv1)
   times      = new((/tmpnday/), integer, bv1)
   timee      = new((/tmpnday/), integer, bv1)
   dayname    = new((/tmpnday/), string,  bv0)
   daynum     = new((/tmpnday/), integer, bv1)
   day        = new((/4, tmpnday/), integer, bv1)

;  DEFINE ARRAY FOR SUBROUTINE read_visualized_cloudmask_date_site.ncl
   nsite      = 6
   cdate      = new((/4, tmpnday/), integer, bv1)
   cmask      = new((/nsite, tmpnday/), float, bv2)

;  DEFINE VARIABLE RELATED TO GROUP CALCULATION
;  DEFINE # OF DAYS IN EACH GROUP ON EACH SITE
   ng         = 16
   ngsite     = new((/ng, nsite/), integer, bv1)

;  CALL SUBROUTINE read_group_number_site.ncl TO READ GROUP NUMBER IN EACH SITE
   read_group_number_site \
   (dirg, filenameg, ngsite)

;  CALL SUBROUTINE read_visualized_cloudmask_date_site.ncl TO READ VISUALIZED CLOUD MASK
   read_visualized_cloudmask_date_site \
   (dirc, filenamec, cdate, cmask)

;  CALL SUBROUTINE process_day_viirs.ncl TO READ OUT INFO FROM VIIRS FILE NAME
   process_day_viirs(dir, gflist, logic_leap,          \
                     nday, startinx, endinx, year, mon,\
                     date, times, timee, dayname, daynum)
   day = (/year, mon, date, times/)

;  DECLARE VARIABLES FOR SUBROUTINE read_viirs_rad_1day.ncl
   mnp        = 768
   mnl        = 4064
   mfactor    = 1
   tmnp       = mnp*mfactor
   date_title = new((/1/), string, bv0)
   mlat       = new((/tmnp, mnl/), float, bv2)
   mlon       = new((/tmnp, mnl/), float, bv2)
   mrad       = new((/tmnp, mnl/), float, bv2)
   mrad_qf    = new((/tmnp, mnl/), integer, bv1)
   msza       = new((/tmnp, mnl/), float, bv2)
   msaa       = new((/tmnp, mnl/), float, bv2)
   mmp        = new((/tmnp, mnl/), float, bv2)
   mlza       = new((/tmnp, mnl/), float, bv2)
   mlaa       = new((/tmnp, mnl/), float, bv2)
   mlatn      = new((/tmnp/), float, bv2)
   mlonn      = new((/tmnp/), float, bv2)
   mradn      = new((/tmnp/), float, bv2)
   mlatl      = new((/mnl/), float, bv2)
   mlonl      = new((/mnl/), float, bv2)
   mradl      = new((/mnl/), float, bv2)

;  ATLANTA INFO
   npoint        = 1
   point_lat     = new((/npoint/), float, bv2)
   point_lon     = new((/npoint/), float, bv2)
   select_rad    = new((/npoint/), float, bv2)
   select_radstd = new((/npoint/), float, bv2)
   select_pm     = new((/npoint/), float, bv2)
   select_pmstd  = new((/npoint/), float, bv2)
   select_sza    = new((/npoint/), float, bv2)
   select_mp     = new((/npoint/), float, bv2)
   select_lza    = new((/npoint/), float, bv2)
   point_lat     =  33.745
   point_lon     = -84.390

;  DO SITE LOOP
   do i = 0, nsite - 1
      isite    = i
      ssite    = int2string_format(isite, False, 2, 2)
      plotname = "1plt_viirs_contour_pixel_dnb_point_polyline_direc_group_" + siteid(isite) + "_v03"
      wks      = gsn_open_wks(type, plotname)
      gsn_define_colormap(wks,"gsdtol")

;  DECLARE ARRAY FOR SUBROUTINE read_select_pixel_index.ncl
      nselect = 160
      dateind = new((/4, nselect/), integer, bv1)
      index   = new((/nselect/), integer, bv1)

;  CALL SUBROUTINE read_select_pixel_index.ncl TO READ SELECTED VIIRS PIXEL INDEX
      read_select_pixel_index \
      (dirind, filenameind(i), dateind, index)

;  DO # OF GROUP NUMBER
      icountg = 0
      do ig = 0, ng - 1
         print("Now processing : Site" + siteid(isite) + "  Group" + ig)
         plot = new((/ngsite(ig, isite)/), graphic)

;  DO # OF DAY LOOP TO PLOT GRID IMAGE
         do j = 0, ngsite(ig, isite) - 1
            icount = j

;  DECLARE ARRAY FOR SUBROUTINE match_group_number_site_pickup_cloudmask.ncl
            index1 = new((/1/), integer, bv1)

;  CALL SUBROUTINE match_group_number_site_pickup_cloudmask.ncl TO MATCH GROUP NUMBER SITE WITH PICKUP
;  AND VISUALIZED CLOUD MASK
            match_group_number_site_pickup_cloudmask \
           (isite, dateind(:, icountg), day, cdate, cmask(isite, :), index1)

            if (.not.all(ismissing(index1))) then
               system("date")
               date_display = year(index1) + "-" + mon(index1) + "-" + date(index1)
               print("DATE : " + date_display)
;  CALL SUBROUTINE read_viirs_rad_1day.ncl TO READ ALL THE LATITUDE, LONGITUDE, 
;  RADIANCE QUALITY FLAG, AND RADIANCE FOR ONE DAY.
               read_viirs_rad_1day \
              (dir, bv0, index1, startinx, endinx, gfname, vfname, \
               date_title, mlat, mlon, mrad_qf, mrad, msza, msaa, mmp, mlza, mlaa)
               mrad = mrad*nfactor

;  CALL SUBROUTINE select_viirs_point_hourly_pixel_polyline.ncl TO SELECT AND CALCULATE VIIRS DATA 
;  AND SITE OBSERVED DATA
               select_viirs_point_hourly_pixel_polyline \
              (index1, bv2, point_lat, point_lon, mlat, mlon, mrad, msza, mmp, mlza, \
               mlatn, mlonn, mlatl, mlonl, \
               select_rad, select_radstd, select_sza, select_mp, select_lza, mradn, mradl)

;  CALL SUBROUTINE plot_viirs_pixel_rad_point_polyline_direc_group.ncl TO PLOT RADIANCE CONTOUR
               plot_viirs_pixel_rad_point_polyline_direc_group  \
              (wks, date_title, npoint, minlat, maxlat, minlon, maxlon, point_lat, point_lon, \
               mlatn, mlonn, mlatl, mlonl, avg(select_sza), avg(select_mp), avg(select_lza), mrad, plot(icount))
            end if
            icountg = icountg + 1
         end do
         if (.not.all(ismissing(plot))) then
            gres            = True
            gres@txString   = "Site" + siteid(isite) + " Group" + ig
            gsn_panel(wks, plot, (/3, 2/), gres)
         end if
         delete([/plot/])
      end do
   end do

end
