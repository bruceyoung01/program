;  $ID: raster_viirs_pixel.ncl V01 02/09/2014 23:42 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM raster_viirs_pixel READS SELECTED VIIRS DATA AND PLOT IT AS RASTER, 
;  WHICH IS WITH THE SAME POSITION AS REAL.
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
;******************************************************************************

;  LOAD FUNCTIONS, PROCEDURES AND LIBRARIES.
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "/Users/bruce/Documents/A/program/ncl/ncl_lib/function/int2string.ncl"
load "/Users/bruce/Documents/A/program/ncl/ncl_lib/function/int2string_format.ncl"
load "/Users/bruce/Documents/A/program/ncl/ncl_lib/procedure/atlanta/read_viirs_pickup_pixel.ncl"
load "/Users/bruce/Documents/A/program/ncl/ncl_lib/procedure/atlanta/plot_raster_viirs_pixel.ncl"

begin

;  SETUP WORKSTATION
;  type = "x11"
   type = "pdf"
;  type = "png"
   wks  = gsn_open_wks(type, "1plt_raster_viirs_pixel_v01")
   gsn_define_colormap(wks, "BlAqGrYeOrReVi200")
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
      tmpnday = 153
      x       = new((/nl+1/), float, bv2)
      y       = new((/np+1/), float, bv2)
      x       = fspan(0., nl, nl+1)
      y       = fspan(0., np, np+1)
      sitename= new((/1/), string, bv0)
      date    = new((/4, tmpnday/), integer, bv1)
      rad     = new((/np, nl, tmpnday/), float, bv2)

;  CALL SUBROUTINE read_viirs_pickup_pixel.ncl TO PICKED VIIRS PIXEL RADIANCES
      read_viirs_pickup_pixel \
     (bv2, isite, dir, filename(i), np, nl, sitename, date, rad)
;     print(date(0, :) + "-" + date(1, :) + "-" + date(2, :) + "-" + date(3, :))

;  DO # OF SITE LOOP TO PLOT GRID IMAGE
      do j = 0, tmpnday - 1
         icount = j
         print( icount + " : " + sitename +  " " + \
               int2string_format(date(0, j), False, 4, 4) + "-" + \
               int2string_format(date(1, j), False, 2, 2) + "-" + \
               int2string_format(date(2, j), False, 2, 2) + "-" + \
               int2string_format(date(3, j), False, 2, 2))

;  CALL SUBROUTINE plot_raster_viirs_pixel.ncl TO PLOT RASTER IMAGE
         if (.not.all(ismissing(rad(:, :, icount))))
            plot_raster_viirs_pixel \
           (wks, icount, x, y, date(:, icount), isite, sitename, rad(:, :, icount))
         end if
      end do
      delete([/x, y, rad/])
   end do

end
