; $ID: calipso_aerosol_cloud.ncl V01 01/26/2012 10:59 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM calipso_aerosol_cloud IS USED TO CLASSIFY AEROSOL CLOUD DIFFERENT 
;  VERTICAL DISTRIBUTION AND GET CLOUD AND AEROSOL FREQUENCY IN EACH LAYER AND 
;  PLOT THE VERTICLE PROFILE.
;
;  VARIABLE:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (01/26/2012)
;******************************************************************************

;  LOAD LIBRARIES
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm_epa.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/function/add_markers.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/zzbackup/read_asc6.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/zzbackup/plot_vertical_profile_1fre.ncl"

begin

;  SET UP THE PLOT WORKSTATION
;  type     = "x11"
   type     = "pdf"
   plot_name= "1plt_calipso_aerosol_cloud_profile"
   wks      = gsn_open_wks(type, plot_name)
   gsn_define_colormap(wks, "GaAqGrYeOrReVi200")

;  READ THE CALIPSO LEVEL 2 DATA : CAL_LID_L2_05kmAPro-Prov-V3-01
   cdir     = "/home/bruce/program/ncl/tutorial/test/ca_2003/calipso_aerosol_cloud/calipso_data/"
   cfilelist= "filelist"
   filename = asciiread(cdir + cfilelist, -1, "string")

;  DEFINE BAD VALUE
   bv1            = -599.94
   n_new_layer    = 33
   atype          = (/"NAN", "NACN", "NCAN", "NCACN", "NCACAN"/)
   height         = new(n_new_layer, float, bv1)
   avgsnan        = new(n_new_layer, float, bv1)
   stdsnan        = new(n_new_layer, float, bv1)
   freinan_aer    = new(n_new_layer, float, bv1)
   freinan_cld    = new(n_new_layer, float, bv1)
   avgsnacn       = new(n_new_layer, float, bv1)
   stdsnacn       = new(n_new_layer, float, bv1)
   freinacn_aer   = new(n_new_layer, float, bv1)
   freinacn_cld   = new(n_new_layer, float, bv1)
   avgsncn        = new(n_new_layer, float, bv1)
   stdsncn        = new(n_new_layer, float, bv1)
   freincn_aer    = new(n_new_layer, float, bv1)
   freincn_cld    = new(n_new_layer, float, bv1)
   avgsncan       = new(n_new_layer, float, bv1)
   stdsncan       = new(n_new_layer, float, bv1)
   freincan_aer   = new(n_new_layer, float, bv1)
   freincan_cld   = new(n_new_layer, float, bv1)
   avgsncacn      = new(n_new_layer, float, bv1)
   stdsncacn      = new(n_new_layer, float, bv1)
   freincacn_aer  = new(n_new_layer, float, bv1)
   freincacn_cld  = new(n_new_layer, float, bv1)
   avgsncacan     = new(n_new_layer, float, bv1)
   stdsncacan     = new(n_new_layer, float, bv1)
   freincacan_aer = new(n_new_layer, float, bv1)
   freincacan_cld = new(n_new_layer, float, bv1)

;  READ DATA
   read_asc6(cdir, filename(0), n_new_layer, height, avgsnan, freinan_aer, stdsnan)
   read_asc6(cdir, filename(1), n_new_layer, height, avgsnacn, freinacn_aer, stdsnacn)
   read_asc6(cdir, filename(2), n_new_layer, height, avgsncan, freincan_aer, stdsncan)
   read_asc6(cdir, filename(3), n_new_layer, height, avgsncacn, freincacn_aer, stdsncacn)
   read_asc6(cdir, filename(4), n_new_layer, height, avgsncacan, freincacan_aer, stdsncacan)

;  CALL SUBROUTINE plot_vertical_profile.ncl TO PLOT VERTICAL PROFILE OF 
;  5 DIFFERENT TYPES
   plot_vertical_profile_1fre(wks, atype(0), height, avgsnan, stdsnan, freinan_aer)
   plot_vertical_profile_1fre(wks, atype(1), height, avgsnacn, stdsnacn, freinacn_aer)
   plot_vertical_profile_1fre(wks, atype(2), height, avgsncan, stdsncan, freincan_aer)
   plot_vertical_profile_1fre(wks, atype(3), height, avgsncacn, stdsncacn, freincacn_aer)
   plot_vertical_profile_1fre(wks, atype(4), height, avgsncacan, stdsncacan, freincacan_aer)
end
