;  $ID: trend_line_site_wrfchem.ncl V01 11/07/2012 22:00 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM trend_line_site_wrfchem READS OBSERVATION DATA FROM SITES AND 
;  WRFCHEM, AND PLOT TREND LINE WITH CORRELATION INFO.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (11/07/2012)
;******************************************************************************

;  LOAD LIBRARIES AND FUNTIONS
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm_epa.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

;  OPEN A WORKSTATION AND CHOOSE COLORMAP 
   type       = "x11"
;  type       = "pdf"
;  type       = "png"
   wks        = gsn_open_wks(type,"1plt_trend_line_site_wrfchem_v01")
   gsn_define_colormap(wks,"BlAqGrYeOrReVi200")

;  SET SITE DATA DIRECTORY
   site_dir             = "/home/bruce/sshfs/tw/parallel/data/atlanta/sample_Liu/201208/"
   site_aodlist         = "aod.list"
   site_pmlist          = "pm.list"
   site_countlist       = "count.list"
   site_aodfilename     = asciiread(site_dir + site_aodlist,   -1, "string")
   n_site_aodfilename   = dimsizes(site_aodfilename)
   site_pmfilename      = asciiread(site_dir + site_pmlist,    -1, "string")
   n_site_pmfilename    = dimsizes(site_pmfilename)
   site_countfilename   = asciiread(site_dir + site_countlist, -1, "string")
   n_site_countfilename = dimsizes(site_countfilename)

;  SET WRFCHEM DATA DIRECTORY
   wrfchem_dir        = "/home/bruce/sshfs/tw/model/wrfchem33_1/WRFV3/test/em_real/wrfout_atlanta/wrfout/"
   wrfchem_filelist   = "2012_wrfout_d03"
   wrfchem_filename   = asciiread(wrfchem_dir + wrfchem_filelist, -1, "string")
   nwrfchem_filename  = dimsizes(wrfchem_filename)

;  DO THE SITE LOOP TO PROCESS DATA




end
