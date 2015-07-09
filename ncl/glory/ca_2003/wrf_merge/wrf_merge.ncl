; PURPOSE OF THIS PROGRAM :
; READ wrfinput AND wrfrst FILES
; OVERWRITE THE CHEMICAL DATA IN wrfinput USING CHEMICAL DATA IN wrfrst
; BRUCE APRIL 05 0211


   load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
   load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
   load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

;  READ wrfinput DATA
   filei  = systemfunc("ls /home/bruce/sshfs/pf/model/wrfchem3/WRFV311/test/em_nest/2003_ca_60_zhang/hourly/wrfout_d01_2003-03-22*.nc")
   in     = addfiles(filei, "r")

   fileo  = "/home/bruce/sshfs/pf/model/wrfchem3/WRFV311/test/em_nest/2003_ca_60_zhang/day/wrfout_d01_2003-03-22_00:00:00.nc"
   out    = addfile(fileo,"w")
    
;  READ ALL THE DATA FROM HOURLY WRFOUT FILE IN ONE DAY
   print ("Read all variables via include file.") 
   load "statements_read_out1.ncl" ; in effect this reads all included variabes, 
                            ; preserving the names from the input file. 
   printVarSummary (PM2_5_DRY)

;  WRITE ALL THE HOURLY DATA INTO ONE DAY WRFOUT
   print ("Overwrite all variables via include file.")
   load "statements_write_out1.ncl" ; in effect this reads all included variabes,
                            ; preserving the names from the input file.

end
