;  $ID: rewrite_nc_1file.ncl V01 09/13/2012 10:04 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM rewrite_nc_1file READS AND REWRITE WRFCHEM OUTPUT .nc FILES, WITH 
;  SELECTED VARIABLES
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (09/13/2012)
;******************************************************************************
;
;  LOAD FUNCTIONS AND PROCEDURES
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm_epa.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin
   sfactor1   = 1.8
   sfactor2   = 2.0
   sfactor3   = 1.2
   sfactor4   = 2.0

;  READ WRFCHEM OUTPUT NC FILE
;  THIS NEEDS TO HAVE A ".nc" APPENDED
   dirn      = "/home/bruce/sshfs/shw/data/wrf_output/wrfout_cmaq_2007_winter/wrfout_test/"
   filelistn = "2007_wrfout_d01"
   namen     = asciiread(dirn+filelistn, -1, "string")
   nfnamen   = dimsizes(namen)
   diro      = "./"

;  READ VARIABLES AND WRITE TO A NEW .nc FILE
   do i = 0, nfnamen-1
    fn       = addfile(dirn + namen(i), "w")
    time     = fn->Times
    print("NOW WORKING ON : " + time)
;  READ VARIABLES
    pm25     = fn->PM2_5_DRY
    tauaer1  = fn->TAUAER1
    tauaer2  = fn->TAUAER2
    tauaer3  = fn->TAUAER3
    tauaer4  = fn->TAUAER4

;  PROCESS THE DATA IN EACH LEVEL
    ndim     = dimsizes(tauaer1)
    nlevel   = ndim(1)
    nlat     = ndim(2)
    nlon     = ndim(3)

    do j = 0, nlevel-1
     pm25(0, j, :, :)    = pm25(0, j, :, :)*sfactor3    - 0.001/((j+1)^sfactor4)
     tauaer1(0, j, :, :) = tauaer1(0, j, :, :)*sfactor1 - 0.001/((j+1)^sfactor2)
     tauaer2(0, j, :, :) = tauaer2(0, j, :, :)*sfactor1 - 0.001/((j+1)^sfactor2)
     tauaer3(0, j, :, :) = tauaer3(0, j, :, :)*sfactor1 - 0.001/((j+1)^sfactor2)
     tauaer4(0, j, :, :) = tauaer4(0, j, :, :)*sfactor1 - 0.001/((j+1)^sfactor2)
    end do
;  REWRITE VARIABLES
    fn->PM2_5_DRY = pm25
    fn->TAUAER1   = tauaer1
    fn->TAUAER2   = tauaer2
    fn->TAUAER3   = tauaer3
    fn->TAUAER4   = tauaer4

   end do

end
