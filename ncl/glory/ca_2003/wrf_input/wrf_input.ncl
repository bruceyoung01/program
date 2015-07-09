; PURPOSE OF THIS PROGRAM :
; READ wrfinput AND wrfrst FILES
; OVERWRITE THE CHEMICAL DATA IN wrfinput USING CHEMICAL DATA IN wrfrst
; BRUCE APRIL 05 0211


   load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
   load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
   load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

;  READ wrfinput DATA
   dir    = "/home/bruce/sshfs/pf/model/wrfchem3/WRFV311/test/em_nest/"
   filei  = "wrfinput_d01.nc"
   filer  = "wrfrst_d01_2003-05-13_00:00:00.nc"
   infile = dir+filer
   outfile= dir+filei
   in     = addfile(infile, "r") 
   out    = addfile(outfile,"w")
    
   print ("Check for possible conflicts with existing variables.") 
   varnames = getfilevarnames (in) 
   conflicts = isdefined (varnames) 
   if (any (conflicts)) then 
      print ("*** These variables are already in use in this program,") 
      print ("*** so they can't be read in with the same names:") 
      print (" " + varnames(ind (conflicts))) 
      print ("*** Abort.") 
      exit 
   else 
      print ("... No conflicts detected.") 
   end if 
    
   print ("Read all variables via include file.") 
   load "statements_read.ncl" ; in effect this reads all included variabes, 
                            ; preserving the names from the input file. 
   printVarSummary (so2) ; check status of expected data variables 
   printVarSummary (sulf) 
   printVarSummary (no2)

;  WRITE THE CHEMICAL DATA READ FROM wrfrst FILE TO wrfinput FILE
   print ("Overwrite all the chemical variables via include file.")
   load "statements_write.ncl" ; in effect this reads all included variabes,
                            ; preserving the names from the input file.

end
