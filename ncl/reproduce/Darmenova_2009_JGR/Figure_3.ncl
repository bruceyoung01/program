;  $ID: Figure_3.ncl V01 02/16/2015 16:58 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM Figure_3 REPRODUCES FIGURE 3 FROM DARMENOVA_2009_JGR PAPER.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTE: 
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (02/16/2015)
;******************************************************************************
;
;  LOAD FUNCTIONS AND PROCEDURES
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "/Users/bruceyoung01/Documents/A/program/ncl/ncl_lib/procedure/reproduce/MB_friction_velocity.ncl"
load "/Users/bruceyoung01/Documents/A/program/ncl/ncl_lib/procedure/reproduce/Shao_friction_velocity.ncl"
load "/Users/bruceyoung01/Documents/A/program/ncl/ncl_lib/procedure/reproduce/plot_trend_line4.ncl"

begin
;  SET UP THE PLOT PLATFORM
;  type      = "x11"
   type      = "pdf"
;  type      = "png"
   wks        = gsn_open_wks(type,"1plt_figure3")
   gsn_define_colormap(wks,"BlAqGrYeOrReVi200")

;  SET UP BASIC PRE-DEFINE
   bv2    = -9999.

;  CREATE AN FLOATING ARRAY FOR DIAMETER
   sstart = 0.0001
   send   = 0.1
   npts   = 10000
   D      = fspan(sstart, send, npts)
   D_um   = D*npts

;  DEFINE AN ARRAY FOR u
   ntau   = 3
   nu     = 4
   u_MB   = new(npts, float, bv2)
   u_Shao = new((/ntau, npts/), float, bv2)
   u      = new((/nu,   npts/), float, bv2)
   u_name = (/"MB", "Shao1.65e-4", "Shao3e-4", "Shao5e-4"/)
   
;  CALL PROCEDURE MB_friction_velocity TO CALCULATE THRESHOLD FRICTION 
;  VELOCITY BASED ON Marticorena's METHOD
   MB_friction_velocity (D, u(0, :))

;  CALL PROCEDURE Shao_friction_velocity TO CALCULATE THRESHOLD FRICTION 
;  VELOCITY BASED ON Shao_1996_JGR METHOD
   Shao_friction_velocity (D, u(1:3, :))

;  =====================================================================
;  CALL PROCEDURE plot_trend_line4.ncl TO PLOT IMAGE
   plot_trend_line4 (wks, u_name, D_um, u)

end
