;  $ID: rewrite_nc2txt.ncl V01 09/13/2012 10:04 BRUCE EXP$
;
;******************************************************************************
;  PROGRAM rewrite_nc2bin READS AND REWRITE WRFCHEM OUTPUT .nc FILES, WITH 
;  SELECTED VARIABLES TO TEXT FILE
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
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

begin
;  ASSIGNMENT CONSTANT AND ABBRAVIATION
   bv1       = -9999.
   bv2       = -9999
   nfv       = "No_FillValue"
   str       = "string"

;  READ WRFCHEM OUTPUT NC FILE
;  THIS NEEDS TO HAVE A ".nc" APPENDED
   dirn      = "/home/bruce/sshfs/shw/data/wrf_output/wrfout_sahel_85_smoke_dust_650/wrfout/"
   filelistn = "2008_wrfout_d01"
   namen     = asciiread(dirn+filelistn, -1, str)
   nfnamen   = dimsizes(namen)
   diro      = "./"
   var       = (/"u", "v", "pm25"/)
   nvar      = dimsizes(var)

;  READ VARIABLES AND WRITE TO A NEW .nc FILE
   do i = 0, 0;nfnamen-1
    fn       = addfile(dirn + namen(i) + ".nc", "r")
    time     = fn->Times
    print("NOW WORKING ON : " + time)
    pm25n    = fn->PM2_5_DRY(0, :, :, :)
    ndim     = dimsizes(pm25n)
    nlevel   = ndim(0)
    nlat     = ndim(1)
    nlon     = ndim(2)
    u        = fn->U(0, 0:nlevel-1, 0:nlat-1, 0:nlon-1)
    v        = fn->V(0, 0:nlevel-1, 0:nlat-1, 0:nlon-1)
    total    = sprintf("%20.10f", u) + \
               sprintf("%20.10f", v) + \
               sprintf("%20.10f", pm25n)

;   OPEN AND WRITE OUTPUT FILE
    fileo    = namen(i)
    system("/bin/rm -f " + diro + fileo)
    asciiwrite(fileo, total)
   end do

end
