;  $ID: select_wrfchem_point.ncl V01 06/13/2013 09:05 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM select_wrfchem_point.ncl READS WRFCHEM INPUT(met_em*) AND WRFCHEM 
;  OUTPUT(wrfout*) FILES, SELECT THE GRID BOX DEPENDING THE GIVEN SITE INFO 
;  (LATITUDE, LONGITUDE), REWRITE THE REQUIRED VARIABLES TO A TEXT FILE, 
;  INCLUDING DATE AND TIME.
;
;  SUBROUTINES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (06/13/2013)
;******************************************************************************

;  LOAD LIBRARIES, FUNCTIONS, AND PROCEDURES
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/procedure/atlanta/point_wrfchem_hourly.ncl"
load "/work/jwang7/bruceyoung01/model/ncl/ncl_lib/procedure/atlanta/write_wrfchem_site.ncl"

;  met_em DATA DIRECTORY AND FILE LIST
   mdir  = "/shared/aerosol/bruceyoung01/data/wrf_input/met_em/atlanta_2012/"
   mlist = "2012_met_em_d03"

;  WRFCHEM DATA DIRECTORY AND FILE LIST
   wdir  = "/shared/aerosol/bruceyoung01/data/wrf_output/wrfout_atlanta/"
   wlist = "2012_wrfout_d03"
   wname = asciiread(wdir + wlist, -1, "string")
   nname = dimsizes(wname)

;  MISSING VALUE
   bv1   = -9999
   bv2   = -9999.

;  SET UP STUDY SITES
   site  = (/"A", "B", "C", "D", "E", "CTR", "YANG"/)
   lat   = (/ 33.9631,  33.4040,  33.4336,  33.7206,  33.6881,  33.745,  33.7975/)
   lon   = (/-84.0692, -84.2902, -84.1617, -84.3574, -84.2902, -84.390, -84.3239/)
   nsite = dimsizes(site)

;  DO SITE LOOP TO REWRITE THE DATA INTO TEXT FILE
   j     = 0
   do i = 0, nsite-1
    j = i + 1
    system("date")
    print("Now Processing Site : " + j + " of " + nsite)

;  DEFINE ARRAY FOR SUBROUTINE point_wrfchem_hourly.ncl
    wyear   = new((/nname/), integer, bv1)
    wmon    = new((/nname/), integer, bv1)
    wday    = new((/nname/), integer, bv1)
    whour   = new((/nname/), integer, bv1)
    wrh     = new((/nname/), float,   bv2)
    wu      = new((/nname/), float,   bv2)
    wv      = new((/nname/), float,   bv2)
    wpblh   = new((/nname/), float,   bv2)
    wpsfc   = new((/nname/), float,   bv2)
    wtau400 = new((/nname/), float,   bv2)
    wtau600 = new((/nname/), float,   bv2)
    wpm25   = new((/nname/), float,   bv2)

;  CALL SUBROUTINE point_wrfchem_hourly.ncl TO READ WRFCHEM INPUT AND OUTPUT,
;  AND SELECT DATA BASED ON SITE INFO
    point_wrfchem_hourly \
    (mdir, wdir, mlist, wlist, lat(i), lon(i), \
     wyear, wmon, wday, whour, wrh, wu, wv,    \
     wpblh, wpsfc, wtau400, wtau600, wpm25)

;  CALL SUBROUTINE write_wrfchem_site.ncl TO WRITE DATE AND DATA OUT INTO A 
;  TEXT FILE
    write_wrfchem_site \
    (site(i), wyear, wmon, wday, whour,  \
     wrh, wu, wv, wpblh, wpsfc, wtau400, \
     wtau600, wpm25)

    delete([/wyear, wmon, wday, whour,  \
             wrh, wu, wv, wpblh, wpsfc, \
             wtau400, wtau600, wpm25/])
   end do
