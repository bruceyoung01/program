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
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/pro_fun.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/calipso_classification.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/calculate_calipso_frequency.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/plot_vertical_profile.ncl"

begin

;  SET UP THE PLOT WORKSTATION
;  type     = "x11"
   type     = "pdf"
   plot_name= "1plt_calipso_aerosol_cloud_profile"
   wks      = gsn_open_wks(type, plot_name)
   gsn_define_colormap(wks, "BlAqGrYeOrReVi200")

;  READ THE CALIPSO LEVEL 2 DATA : CAL_LID_L2_05kmAPro-Prov-V3-01
   cdir     = "/home/bruce/sshfs/pfw/satellite/CALIPSO/sahel/2008/CAL_LID_L2_05kmAPro-Prov-V3-01/"
   cfilelist= "CAL_LID_L2_05kmAPro-Prov-V3-01"

;  DEFINE UNIVERSAL SYMBOLS AND CONSTANTS
   nfv      = "No_FillValue"
   str      = "string"
;  DEFINE BAD VALUE
   bv1      = -599.94
   bv2      = -9999.
   bv3      = -9999
;  SEAS : 20N~10S, 95E~125E 
;  SAHEL: 35N~15S, 25W~30E
   maxlat   =  10.0
   minlat   = -10.0
   maxlon   =  30.0
   minlon   = -25.0
;  DEFINE HEIGHT
   n_layer     = 399
   n_old_layer = 330
   stride      = 5
   strh        = 0.3
   endh        = 19.8
   n_new_layer = n_old_layer/stride
   height      = fspan(strh, endh, n_new_layer)
   ostrh       = 0.0
   oendh       = 19.8
   oheight     = fspan(ostrh, oendh, n_old_layer)

;  DEFINE ARRAY TO HOLD SELECTED DATA IN DIFFERENT TYPES
   n              = 100000
   sn             = new((/n, n_new_layer/), float, bv1)
   snan           = new((/n, n_new_layer/), float, bv1)
   snacn          = new((/n, n_new_layer/), float, bv1)
   sncn           = new((/n, n_new_layer/), float, bv1)
   sncan          = new((/n, n_new_layer/), float, bv1)
   sncacn         = new((/n, n_new_layer/), float, bv1)
   sncacan        = new((/n, n_new_layer/), float, bv1)
   in             = new((/n, n_new_layer/), integer, bv3)
   inan           = new((/n, n_new_layer/), integer, bv3)
   inacn          = new((/n, n_new_layer/), integer, bv3)
   incn           = new((/n, n_new_layer/), integer, bv3)
   incan          = new((/n, n_new_layer/), integer, bv3)
   incacn         = new((/n, n_new_layer/), integer, bv3)
   incacan        = new((/n, n_new_layer/), integer, bv3)
   tssdim         = new(1, integer, bv3)
   npts           = 7
   fnttype        = new((/npts/), float, bv2)
   atype          = (/"N", "NAN", "NACN", "NCN", "NCAN", "NCACN", "NCACA"/)
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

;  CALL SUBROUTINE calipso_classification.ncl TO DISTINGUISH 
;  DIFFERENT VERTICLE DISTRIBUTIONS.
   calipso_classification(cdir, cfilelist, minlat, maxlat, minlon, maxlon,\
                          n_layer, n_old_layer, n_new_layer, stride, oheight, str, \
                          bv1, bv2, bv3,                                  \
                          sn, in, snan, inan, snacn, inacn, sncn, incn,   \
                          sncan, incan, sncacn, incacn, sncacan, incacan, \
                          tssdim, fnttype)

;  CALL SUBROUTINE calculate_calipso_frequency.ncl TO CALCULATE 
;  DATA AVERAGE AND FREQUENCY IN EACH LAYER.
   calculate_calipso_frequency(snan, inan, n_new_layer, tssdim, bv1, \
                               avgsnan, stdsnan, freinan_aer, freinan_cld)
   calculate_calipso_frequency(snacn, inacn, n_new_layer, tssdim, bv1, \
                               avgsnacn, stdsnacn, freinacn_aer, freinacn_cld)
   calculate_calipso_frequency(sncn, incn, n_new_layer, tssdim, bv1, \
                               avgsncn, stdsncn, freincn_aer, freincn_cld)
   calculate_calipso_frequency(sncan, incan, n_new_layer, tssdim, bv1, \
                               avgsncan, stdsncan, freincan_aer, freincan_cld)
   calculate_calipso_frequency(sncacn, incacn, n_new_layer, tssdim, bv1, \
                               avgsncacn, stdsncacn, freincacn_aer, freincacn_cld)
   calculate_calipso_frequency(sncacan, incacan, n_new_layer, tssdim, bv1, \
                               avgsncacan, stdsncacan, freincacan_aer, freincacan_cld)

;  CALL SUBROUTINE plot_vertical_profile.ncl TO PLOT VERTICAL PROFILE OF 
;  5 DIFFERENT TYPES
   plot_vertical_profile(wks, atype(1), height, avgsnan, stdsnan, freinan_aer, freinan_cld)
   plot_vertical_profile(wks, atype(2), height, avgsnacn, stdsnacn, freinacn_aer, freinacn_cld)
   plot_vertical_profile(wks, atype(4), height, avgsncan, stdsncan, freincan_aer, freincan_cld)
   plot_vertical_profile(wks, atype(5), height, avgsncacn, stdsncacn, freincacn_aer, freincacn_cld)
   plot_vertical_profile(wks, atype(6), height, avgsncacan, stdsncacan, freincacan_aer, freincacan_cld)
end
