;  $ID: raster_viirs.ncl V01 01/31/2014 10:09 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM raster_viirs READS SELECTED VIIRS DATA AND PLOT IT AS RASTER.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (01/31/2014)
;******************************************************************************

;  LOAD FUNCTIONS, PROCEDURES AND LIBRARIES.
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/function/int2string.ncl"
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/function/int2string_format.ncl"
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/procedure/atlanta/read_viirs_pickup.ncl"
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/procedure/atlanta/plot_raster_viirs.ncl"

begin

;  SETUP WORKSTATION
;  type = "x11"
   type = "pdf"
;  type = "png"
   wks  = gsn_open_wks(type, "1plt_raster_viirs_v01")
   gsn_define_colormap(wks, "BlAqGrYeOrReVi200")
   setvalues NhlGetWorkspaceObjectId()
    "wsMaximumSize": 100000000
   end setvalues

;  DEFINE MISSING VALUE
   bv0        = "Fillvalue"
   bv1        = -9999
   bv2        = -9999.

;  SET UP SELECTED VIIRS DATA INFO
   dir        = "/work/jwang7/bruceyoung01/parallel/data/atlanta/jun/picked/"
   filelist   = "pickup.txt"
   filename   = asciiread(dir + filelist, -1, "string")
   nsite      = dimsizes(filename)

   npixel     = 25
   tmpnday    = 153
   x          = new((/6/), float, bv2)
   y          = new((/6/), float, bv2)
   x          = fspan(0., 5.0, 6)
   y          = fspan(0., 5.0, 6)

;  DO # OF SITE LOOP TO PLOT GRID IMAGE
   do i = 0, nsite - 1

;  DECLARE ARRAY FOR SUBROUTINE read_viirs_pickup.ncl
      np      = 5
      nl      = 5
      sitename= new((/1/), string, bv0)
      date    = new((/4, tmpnday/), integer, bv1)
      rad     = new((/np, nl, tmpnday/), float, bv2)

;  CALL SUBROUTINE read_viirs_pickup.ncl TO PICKED VIIRS PIXEL RADIANCES
      read_viirs_pickup \
     (bv2, dir, filename(i), np, nl, sitename, date, rad)
;     print(date(0, :) + "-" + date(1, :) + "-" + date(2, :) + "-" + date(3, :))

;  DO # OF SITE LOOP TO PLOT GRID IMAGE
      do j = 0, tmpnday - 1
         icount = j
         print( icount + " : " + sitename +  " " + \
               int2string_format(date(0, j), False, 4, 4) + "-" + \
               int2string_format(date(1, j), False, 2, 2) + "-" + \
               int2string_format(date(2, j), False, 2, 2) + "-" + \
               int2string_format(date(3, j), False, 2, 2))

;  CALL SUBROUTINE plot_raster_viirs.ncl TO PLOT RASTER IMAGE
         if (.not.all(ismissing(rad(:, :, icount))))
            plot_raster_viirs \
           (wks, icount, x, y, date(:, icount), sitename, rad(:, :, icount))
         end if
      end do
   end do

end
