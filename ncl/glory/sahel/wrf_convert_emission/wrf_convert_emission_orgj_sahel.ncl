; $ID: wrf_convert_emission_orgj_sahel.ncl V01 06/03/2012 18:44 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM wrf_convert_emission_orgj_sahel READS AND PLOTS CONVERTED EMISSION 
;  FROM convert_emiss.exe OF WRFCHEM
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (06/03/2012)
;******************************************************************************


;  LOAD FUNCTIONS AND PROCEDURES
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm_epa.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/smoke_emission/plot_wrf_contour_variable_orgj.ncl"

begin
;  SET UP THE PLOT PLATFORM
   type      = "x11"
;  type      = "pdf"
;  type      = "png"
   wks       = gsn_open_wks(type, "1plt_convert_emission_orgj_sahel_gbbep_v01_d01")
   gsn_define_colormap(wks,"WhGrYeOrReVi200")

;  DEFINE BAD VALUES
   bv1       = -9999
   bv2       = -9999.
   bv3       = "missingvalue"
   str       = "string"

;  SPECIFY WRF EMISSION DIRECTORY
   dir       = "/home/bruce/sshfs/tw/parallel/data/wrf_input/convert_emission/2008sahel_650_85/"
   filelist  = "2008_wrfchemi_d01"
   filename  = asciiread(dir + filelist, -1, str)
   nfile     = dimsizes(filename)
   wdir      = "/home/bruce/sshfs/tw/model/wrfchem34_dust/WRFV3/test/em_real/wrfout/"
   wfilelist = "2008_wrfout_d01"
   wfilename = asciiread(wdir + wfilelist, -1, str)


;  SET UP LIMITED REGION
;                        OMALINK  NE_NEST2     NE_NEST1    NE      WA       CA     SAHEL 
   minlat    =-15.0      ;40.5    ;39.5       ; 30.0    ; 25.0   ; 30.0    ; 10    ;-15.0
   maxlat    = 35.0      ;41.5    ;42.0       ; 43.0    ; 45.0   ; 45.0    ; 45    ; 35.0
   minlon    =-25.0      ;-97.0   ;-99.0      ;-115.0   ;-115.0  ;-130.0   ;-115   ;-25.0
   maxlon    = 45.0      ;-95.5   ;-94.5      ;-93.0    ;-90.0   ;-110.0   ;-65    ; 45.0

   nhour     = 12
   factor    = 100.
   plot      = new(1, graphic)
;  DO FILE NAME LOOP TO READ AND PLOT EACH FILE
   do i = 0, nfile-1
    ;wks      = gsn_open_wks(type, "1plt_convert_emission_sahel_v01_d01_" + sprinti("%0.4i", i))
    ;gsn_define_colormap(wks,"WhGrYeOrReVi200")
    a     = addfile(dir + filename(i) + ".nc", "r")
    b     = addfile(wdir + wfilename(0) + ".nc", "r")
    do j = 0, nhour-1
     times = a->Times(j, :)
     print("NOW WORKING ON : " + times)
     cv    = a->E_ORGJ(j, 0, :, :)
     cv    = cv*factor
     cv@lat2d = b->XLAT(0,:,:)
     cv@lon2d = b->XLONG(0,:,:)
;  CALL SUBROUTINE plot_wrf_contour_variable_orgj TO PLOT CONTOUR
     plot_wrf_contour_variable_orgj \
     (wks, minlat, maxlat, minlon, maxlon, cv, times)
    end do
   end do
end
