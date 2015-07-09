; $ID: wrf_convert_emission_bc.ncl V01 06/03/2012 18:44 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM wrf_convert_emission_bc READS AND PLOTS CONVERTED EMISSION FROM 
;  convert_emiss.exe OF WRFCHEM
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
load "/home/bruce/program/ncl/tutorial/test/ncl_lib/procedure/seas/plot_wrf_contour_variable_bc.ncl"

begin
;  SET UP THE PLOT PLATFORM
   type      = "x11"
;  type      = "pdf"
;  type      = "png"
;  wks       = gsn_open_wks(type, "1plt_convert_emission_bc_seas_v01_d01")
;  gsn_define_colormap(wks,"WhGrYeOrReVi200")

;  DEFINE BAD VALUES
   bv1       = -9999
   bv2       = -9999.
   bv3       = "missingvalue"
   str       = "string"

;  SPECIFY WRF EMISSION DIRECTORY
   dir       = "/home/bruce/sshfs/tw/model/wrfchem33_5/WRFV3/test/em_real/"
;  dir       = "/home/bruce/sshfs/tw/parallel/data/wrf_input/convert_emission/2006_seas_test_v01/"
   filelist  = "2006_wrfchemi_d01"
   filename  = asciiread(dir + filelist, -1, str)
   nfile     = dimsizes(filename)
   wdir      = "/home/bruce/sshfs/tw/model/wrfchem33_5/WRFV3/test/em_real/wrfout/"
   wfilelist = "2006_wrfout_d01"
   wfilename = asciiread(wdir + wfilelist, -1, str)


;  SET UP LIMITED REGION
;                    
   minlat    = -20.0     ;
   maxlat    =  60.0     ;
   minlon    =  80.0     ;
   maxlon    = 150.0     ;
   nhour     = 12

; SET UP SITE INFO
   slat      = (/33.76/)
   slon      = (/-84.4/)

   plot      = new(1, graphic)
;  DO FILE NAME LOOP TO READ AND PLOT EACH FILE
   do i = 0, nfile-1
    wks      = gsn_open_wks(type, "1plt_convert_emission_seas_bc_v01_d01" + sprinti("%0.4i", i))
    gsn_define_colormap(wks,"WhGrYeOrReVi200")
    a     = addfile(dir + filename(i) + ".nc", "r")
    b     = addfile(wdir + wfilename(0) + ".nc", "r")
    do j = 0, nhour-1
     times = a->Times(j, :)
     print("bcW WORKING ON : " + times)
     cv    = a->E_ECJ(j, 0, :, :)
     cv    = cv*10e4
     lat      = b->XLAT(0,:,:)
     cv@lat2d = b->XLAT(0,:,:)
     cv@lon2d = b->XLONG(0,:,:)
;  CALL SUBROUTINE plot_wrf_contour_variable_bc TO PLOT CONTOUR
     plot_wrf_contour_variable_bc \
     (wks, minlat, maxlat, minlon, maxlon, cv, times)
    end do
   end do
end
