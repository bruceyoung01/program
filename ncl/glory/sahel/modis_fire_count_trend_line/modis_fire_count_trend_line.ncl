; $ID: modis_fire_count_trend_line.ncl V01 06/09/2012 10:34 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM modis_fire_count_trend_line READS MODIS FIRE COUNT FILE (INCLUDING 
;  DAYTIME AND NIGHTTIME) AND PLOTS WITH TREND LINE.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (06/09/2012)
;******************************************************************************


;  LOAD PROCEDURES AND FUNCTIONS
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm_epa.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/sahel/plot_trend_daily2_firecount.ncl"


begin
;  SET UP THE PLOT PLATFORM
   type      = "x11"
;  type      = "pdf"
;  type      = "png"
   wks       = gsn_open_wks(type, "1plt_modis_fire_count_trend_line_sahel_v01") 
   gsn_define_colormap(wks,"BlAqGrYeOrReVi200")
    
;  DEFINE BAD VALUES
   bv1       = -9999
   bv2       = -9999.
   bv3       = "missingvalue"
   str       = "string"
   plot      = new(1, graphic)
   nday      = 29

;  SPECIFY MODIS FIRE COUNT FILE DIRECTORY
   dir       = "/home/bruce/program/idl/modis/code/mod_merge/plot/sahel/"
   dayfire   = "Aqua_fire_count_daytime_sahel"
   nightfire = "Aqua_fire_count_nighttime_sahel"
;  READ MODIS FIRE COUNT
   sdfire    = readAsciiTable(dir + dayfire, 1, "string", (/0, 0/))
   dfire     = stringtointeger(str_get_field(sdfire, 2, " "))
   snfire    = readAsciiTable(dir + nightfire, 1, "string", (/0, 0/))
   nfire     = stringtointeger(str_get_field(snfire, 2, " "))

;  CALCULATE MONTHLY AVERAGE OF FIRE COUNT
   mdfire    = avg(dfire)
   mnfire    = avg(nfire)

;  CALL SUBROUTINE plot_trend_daily2_firecount.ncl TO PLOT MODIS 
;  FIRE COUNT (DAYTIME AND NIGHTTIME)
   plot_trend_daily2_firecount \
   (wks, dfire(:, 0), nfire(:, 0), mdfire, mnfire, nday, plot)

end
