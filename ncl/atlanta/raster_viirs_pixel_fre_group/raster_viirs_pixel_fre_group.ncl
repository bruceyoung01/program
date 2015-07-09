;  $ID: raster_viirs_pixel_fre_group.ncl V01 02/12/2014 10:59 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM raster_viirs_pixel_fre_group READS SELECTED VIIRS DATA AND PLOT IT 
;  AS RASTER, WHICH IS WITH THE SAME POSITION AS REAL. ALSO INCLUDING FREQUENCY 
;  FOR EACH PIXEL, SEPERATED WITH DIFFERENT GROUPS.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (02/09/2014)
;  (2 ) MODIFIED FROM raster_viirs.ncl BY ADDING PIXEL IN THE REAL POSITION.
;       (02/09/2014)
;  (3 ) ADD FREQUENCY FOR EACH PIXEL BY BRUCE. (02/10/2014)
;  (4 ) ADD SEPERATED WITH DIFFERENT GROUPS. (02/12/2014)
;******************************************************************************

;  LOAD FUNCTIONS, PROCEDURES AND LIBRARIES.
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "/Users/bruce/Documents/A/program/ncl/ncl_lib/function/int2string.ncl"
load "/Users/bruce/Documents/A/program/ncl/ncl_lib/function/int2string_format.ncl"
load "/Users/bruce/Documents/A/program/ncl/ncl_lib/procedure/atlanta/read_group_number_site.ncl"
load "/Users/bruce/Documents/A/program/ncl/ncl_lib/procedure/atlanta/read_visualized_cloudmask_date_site.ncl"
load "/Users/bruce/Documents/A/program/ncl/ncl_lib/procedure/atlanta/read_viirs_pickup_pixel.ncl"
load "/Users/bruce/Documents/A/program/ncl/ncl_lib/procedure/atlanta/read_select_pixel_index.ncl"
load "/Users/bruce/Documents/A/program/ncl/ncl_lib/procedure/atlanta/match_group_number_site_pickup_cloudmask.ncl"
load "/Users/bruce/Documents/A/program/ncl/ncl_lib/procedure/atlanta/calculate_viirs_select_pixel_index_fre.ncl"
load "/Users/bruce/Documents/A/program/ncl/ncl_lib/procedure/atlanta/plot_raster_viirs_pixel.ncl"
load "/Users/bruce/Documents/A/program/ncl/ncl_lib/procedure/atlanta/plot_raster_viirs_pixel_fre_group.ncl"

begin

;  SETUP WORKSTATION
;  type = "x11"
   type = "pdf"
;  type = "png"
   wks  = gsn_open_wks(type, "1plt_raster_viirs_pixel_fre_group_v05")
;  gsn_define_colormap(wks, "BlAqGrYeOrReVi200")
   gsn_define_colormap(wks, "MPL_gist_yarg")
   gsn_reverse_colormap(wks)
   setvalues NhlGetWorkspaceObjectId()
    "wsMaximumSize": 100000000
   end setvalues

;  DEFINE MISSING VALUE
   bv0        = "Fillvalue"
   bv1        = -9999
   bv2        = -9999.

;  SET UP SELECTED VIIRS DATA INFO
   dir        = "/Users/bruce/Documents/A/program/idl/atlanta/NPP/DNB/picked/"
   filelist   = "pickup.txt"
   filename   = asciiread(dir + filelist, -1, "string")
   nsite      = dimsizes(filename)

;  SET UP DIRECTORY INFO FOR CLOUD MASK
   dirc       = "/Users/bruce/Documents/A/program/idl/atlanta/NPP/DNB/picked/"
   filenamec  = "Site_cloudmask.txt"

;  SET UP DIRECTORY INFO FOR SELECTED RADIANCE INDEX
   dirind     = "/Users/bruce/Documents/A/program/idl/atlanta/npp/Bruce_data/scatter_plot_data/data_index/"
   filelistind= "select_pixel_index"
   filenameind= asciiread(dirind + filelistind, -1, "string")

;  SET UP DIRECTORY INFO FOR GROUP NUMBER ON EACH SITE
   dirg       = "/Users/bruce/Documents/A/program/idl/atlanta/npp/Bruce_data/scatter_plot_data/"
   filenameg  = "group_number_site"
   
   tmpnday    = 153
   
;  DEFINE ARRAY FOR SUBROUTINE read_visualized_cloudmask_date_site.ncl
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

;  DO # OF SITE LOOP TO PLOT GRID IMAGE
   do i = 0, nsite - 1
      isite = i

;  DECLARE ARRAY FOR SUBROUTINE read_viirs_pickup.ncl
      if (i .eq. 0) then
         np      = 3
         nl      = 4
      else if (i .eq. 1) then
         np      = 3
         nl      = 3
      else if (i .eq. 2) then
         np      = 2
         nl      = 4
      else if (i .eq. 3) then
         np      = 2
         nl      = 3
      else if (i .eq. 4) then
         np      = 5
         nl      = 3
      else if (i .eq. 5) then
         np      = 5
         nl      = 5
      end if
      end if
      end if
      end if
      end if
      end if
      npixel  = np*nl
      x       = new((/nl+1/), float, bv2)
      y       = new((/np+1/), float, bv2)
      x       = fspan(0., nl, nl+1)
      y       = fspan(0., np, np+1)

;  DECLARE ARRAY FOR SUBROUTINE read_viirs_pickup_pixel.ncl
      sitename= new((/1/), string, bv0)
      date    = new((/4, tmpnday/), integer, bv1)
      rad     = new((/np, nl, tmpnday/), float, bv2)

;  DECLARE ARRAY FOR SUBROUTINE read_select_pixel_index.ncl
      nselect = 160
      dateind = new((/4, nselect/), integer, bv1)
      index   = new((/nselect/), integer, bv1)

;  DECLARE ARRAY FOR SUBROUTINE calculate_viirs_select_pixel_index_fre.ncl
      fre     = new((/np ,nl/), float, bv2)
      countind= new((/1/), integer, bv1)

      plot    = new((/ng/), graphic)
;  CALL SUBROUTINE read_viirs_pickup_pixel.ncl TO PICKED VIIRS PIXEL RADIANCES
      read_viirs_pickup_pixel \
     (bv2, isite, dir, filename(i), np, nl, sitename, date, rad)
;     print(date(0, :) + "-" + date(1, :) + "-" + date(2, :) + "-" + date(3, :))

;  CALL SUBROUTINE read_select_pixel_index.ncl TO READ SELECTED VIIRS PIXEL INDEX
      read_select_pixel_index \
      (dirind, filenameind(i), dateind, index)

;  DO # OF GROUP NUMBER
      icountg = 0
      do ig = 0, ng - 1
         fre    = 0.0
         tmprad = new((/np, nl, ngsite(ig, isite)/), float, bv2)

;  CALL SUBROUTINE calculate_viirs_select_pixel_index_fre.ncl TO CALCULATE THE INDEX FREQUECY
         calculate_viirs_select_pixel_index_fre \
        (np, nl, rad, index(icountg:icountg+ngsite(ig, isite)-1), countind, fre)
;  DO # OF DAY LOOP TO PLOT GRID IMAGE
      do j = 0, ngsite(ig, isite) - 1
         icount = j
;  DECLARE ARRAY FOR SUBROUTINE match_group_number_site_pickup_cloudmask.ncl
         index1 = new((/1/), integer, bv1)

;  CALL SUBROUTINE match_group_number_site_pickup_cloudmask.ncl TO MATCH GROUP NUMBER SITE WITH PICKUP
;  AND VISUALIZED CLOUD MASK
         match_group_number_site_pickup_cloudmask \
         (isite, dateind(:, icountg), date, cdate, cmask(isite, :), index1)
         print( icountg + " : " + sitename +  " " + \
               int2string_format(date(0, j), False, 4, 4) + "-" + \
               int2string_format(date(1, j), False, 2, 2) + "-" + \
               int2string_format(date(2, j), False, 2, 2) + "-" + \
               int2string_format(date(3, j), False, 2, 2))
         if (.not.all(ismissing(index1))) then
            tmprad(:, :, icount) = rad(:, :, index1)
         end if
;  CALL SUBROUTINE plot_raster_viirs_pixel.ncl TO PLOT RASTER IMAGE
;        if (.not.all(ismissing(rad(:, :, index1))))
;           plot_raster_viirs_pixel \
;          (wks, icount, x, y, date(:, icount), isite, sitename, rad(:, :, icount))
;        end if
         icountg = icountg + 1
      end do
;  CALCULATE THE AVERAGE
      avgrad  = dim_avg_n(tmprad, 2)
      avgdate = (/2012, 08, 10, ig/)
      if (.not.all(ismissing(avgrad))) then
;  CALL SUBROUTINE plot_raster_viirs_pixel_fre_group.ncl TO PLOT RASTER IMAGE FOR AVERAGE
         plot_raster_viirs_pixel_fre_group \
        (wks, countind, x, y, avgdate, isite, sitename, avgrad, fre, plot(ig))
      end if
         delete([/tmprad/])
      end do
      gsn_panel(wks, plot, (/4, 4/), False)
      delete([/x, y, rad, fre, avgrad, plot/])
   end do

end
