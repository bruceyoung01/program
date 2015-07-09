;  $ID: trend_line_viirs_epa_read.ncl V01 01/30/2014 09:19 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM trend_line_viirs_epa_read READS SELECTED VIIRS HIGHLIGHT PIXELS AND 
;  EPA PM DATA, AND PLOTS TREND LINE OF THEM TO INDICATE THE CORRELATION 
;  BETWEEN THEM.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (01/30/2014)
;******************************************************************************

;  LOAD FUNCTIONS, PROCEDURES AND LIBRARIES.
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "/lustre/work/jwang7/bruceyoung01/model/ncl/ncl_lib/function/correlation.ncl"
load "/lustre/work/jwang7/bruceyoung01/model/ncl/ncl_lib/procedure/universal/add_markers.ncl"
load "/lustre/work/jwang7/bruceyoung01/model/ncl/ncl_lib/procedure/universal/marker_map.ncl"
load "/lustre/work/jwang7/bruceyoung01/model/ncl/ncl_lib/procedure/atlanta/read_visualized_cloudmask_date_site.ncl"
load "/lustre/work/jwang7/bruceyoung01/model/ncl/ncl_lib/procedure/atlanta/read_viirs_epa_point_1.ncl"
load "/lustre/work/jwang7/bruceyoung01/model/ncl/ncl_lib/procedure/atlanta/read_viirs_epa_point_2.ncl"
load "/lustre/work/jwang7/bruceyoung01/model/ncl/ncl_lib/procedure/atlanta/match_viirs_epa_cloudmask_point_site.ncl"
load "/lustre/work/jwang7/bruceyoung01/model/ncl/ncl_lib/procedure/atlanta/plot_trend_daily2_viirs_epa_point.ncl"


begin

;  OPEN A WORKSTATION AND CHOOSE COLORMAP
;  type = "x11"
   type = "pdf"
;  type = "png"
   wks  = gsn_open_wks(type,"1plt_trend_line_viirs_epa_read_v01")
   gsn_define_colormap(wks,"BlAqGrYeOrReVi200")

;  DEFINE MISSING VALUE
   bv0        = "Fillvalue"
   bv1        = -9999
   bv2        = -9999.

;  SET UP DIRECTORY AND FILE NAME FOR SELECTED FILES
   dir        = "/lustre/work/jwang7/bruceyoung01/model/ncl/atlanta/viirs_contour_pixel_dnb_epa_liu_point_number/data/2012_v02/"
   filelist1  = "1.txt"
   filelist2  = "2.txt"
   filelist3  = "3.txt"
   filelist4  = "4.txt"

;  SET UP DIRECTORY INFO FOR CLOUDMASK FILE
   cdir       = "./"
   cfilename  = "Site_cloudmask_order.txt"

;  ATLANTA STUDY REGION
   minlat     =  33.0
   maxlat     =  34.5
   minlon     = -85.5
   maxlon     = -83.5

;  READ FILELIST
   filename1  = asciiread(dir + filelist1, -1, "string")
   filename2  = asciiread(dir + filelist2, -1, "string")
   filename3  = asciiread(dir + filelist3, -1, "string")
   filename4  = asciiread(dir + filelist4, -1, "string")
   nsite      = dimsizes(filename1)

;  DECLARE ARRAY FOR SUBROUTINE read_viirs_epa_read_1.ncl
   nday       = 153
   sdate      = new((/nsite, 4, nday/), integer, bv1)
   site_lat   = new((/nsite, nday/), float, bv2)
   site_lon   = new((/nsite, nday/), float, bv2)
   sza        = new((/nsite, nday/), float, bv2)
   saa        = new((/nsite, nday/), float, bv2)
   mp         = new((/nsite, nday/), float, bv2)
   lza        = new((/nsite, nday/), float, bv2)
   laa        = new((/nsite, nday/), float, bv2)
   pm         = new((/nsite, 4, nday/), float, bv2)
   p_rad      = new((/nsite, 16, nday/), float, bv2)
   p_lat      = new((/nsite, 16, nday/), float, bv2)
   p_lon      = new((/nsite, 16, nday/), float, bv2)

;  DECLARE ARRAY FOR SUBROUTINE match_viirs_epa_cloudmask_point_site.ncl TO FILTER CLOUD
   cpm        = new((/nsite, 4, nday/), float, bv2)
   cp_rad     = new((/nsite, 16, nday/), float, bv2)

   mpplot     = new((/1/), graphic)

;  DECLARE ARRAY FOR SUBROUTINE read_visualized_cloudmask_date_site.ncl
   cdate      = new((/4, nday/), integer, bv1)
   cmask      = new((/nsite, nday/), float, bv2)

;  CALL SUBROUTINE read_visualized_cloudmask_date_site.ncl TO READ CLOUD MASK
      read_visualized_cloudmask_date_site \
     (cdir, cfilename, cdate, cmask)

;  DO SITE LOOP TO READ VIIRS AND EPA DATA IN EACH SITE
   do i = 0, nsite-1

     sitename = str_get_cols(filename1(i), 4, 12)

;  CALL SUBROUTINE read_viirs_epa_read_1.ncl TO READ SELECTED DATA, 
;  INCLUDING DATE, SITE LATITUDE, LONGITUDE, SITELLITE INFO, MOON 
;  INFO AND PM
      read_viirs_epa_read_1 \
     (dir, filename1(i), sdate(i, :, :), site_lat(i, :), site_lon(i, :), \
      sza(i, :), saa(i, :), mp(i, :), lza(i, :), laa(i, :), pm(i, :, :))

;  CALL SUBROUTINE read_viirs_epa_read_2.ncl TO READ SELECTED DATA, 
;  INCLUDING VIIRS RADIANCE
      read_viirs_epa_read_2 \
     (dir, filename2(i), p_rad(i, :, :))

;  CALL SUBROUTINE read_viirs_epa_read_2.ncl TO READ SELECTED DATA,
;  INCLUDING VIIRS SELECTED LATITUDE
      read_viirs_epa_read_2 \
     (dir, filename3(i), p_lat(i, :, :))

;  CALL SUBROUTINE read_viirs_epa_read_2.ncl TO READ SELECTED DATA,
;  INCLUDING VIIRS SELECTED LONGITUDE
      read_viirs_epa_read_2 \
     (dir, filename4(i), p_lon(i, :, :))

;  CALL SUBROUTINE match_viirs_epa_cloudmask_point_site.ncl TO FILTER OUT CLOUDY DAYS
      match_viirs_epa_cloudmask_point_site \
      (bv2, sdate(i, :, :), cdate, pm(i, :, :), p_rad(i, :, :), cmask(i, :), \
       cpm(i, :, :), cp_rad(i, :, :))

;  CALL SUBROUTINE marker_map.ncl TO PLOT SITE LOCATION ON THE MAP
      marker_map \
     (wks, minlat, maxlat, minlon, maxlon, site_lon(i, 0), site_lat(i, 0), \
      mpplot)

;  CALL SUBROUTINE plot_trend_daily2_viirs_epa_point.ncl TO PLOT TREND LINE OF 
;  PM AND VIIRS RADIANCE
      plot_trend_daily2_viirs_epa_point \
     (wks, sitename, dim_avg_n(cpm(i, :, :), 0), cp_rad(i, 5, :), mpplot)



   end do

end
