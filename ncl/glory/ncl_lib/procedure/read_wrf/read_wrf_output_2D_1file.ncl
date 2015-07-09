; $ID: read_wrf_output_2D_1file.ncl V01 05/19/2012 09:10 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE read_wrf_output_2D_1file READS OUT VARIABLES FROM WRF OUTPUT FILE 
;  GIVEN VARIABLES NAME (STRING).
;
;  VARIABLES:
;  ============================================================================
;  (1 ) dir       (string): WRF OUTPUT FILE DIRECTORY                   [---]
;  (2 ) filename  (string): WRF OUTPUT FILE NAME (1 FILE)               [---]
;  (3 ) tname     (string): TIME NAME                                   [---]
;  (4 ) vname     (string): VARIABLE NAME                               [---]
;  (5 ) time      (string): TIME STRING                                 [---]
;  (6 ) data      (float) : WRF OUTPUT VARIABLE                         [---]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (05/19/2012)
;  (2 ) MODIFIED FROM read_wrf_output_3D_1file.ncl. (05/19/2012)
;  (3 ) THE LENGTH OF TIME STRING IS 19. FORMAT IS AS FOLLOWING:
;       YYYY-MM-DD_HH:00:00. (05/19/2012)
;  (4 ) 2-D VARIABLES' FORMAT IS AS FOLLOWING:
;       data(nlat, nlon). (05/19/2012)
;******************************************************************************

undef("read_wrf_output_2D_1file")
procedure read_wrf_output_2D_1file \
          (dir        :string,  filename     :string, \ ; INPUT
           tname      :string,  vname        :string, \ ; INPUT
           time       :string,  data         :float)    ; OUPUT

begin

;  ADD FILE NAME
   a = addfile(dir + filename + ".nc", "r")
   ctime = a->Times
   time  = charactertostring(ctime)
;  READ VARIABLES
   print("-----2-Dimensional Variables-----")
   if (vname .eq. "T2") then
    print(" READING === 2m TEMPERATURE ")
    data = a->T2(0, :, :)
   else if (vname .eq. "TH2") then
    print(" READING === 2m POTENTIAL TEMPERATURE ")
    data = a->TH2(0, :, :)
   else if (vname .eq. "LANDMASK") then
    print(" READING === LAND MASK ")
    data = a->LANDMASK(0, :, :)
   else if (vname .eq. "VEGFRA") then
    print(" READING === VEGETATION FRACTION")
    data = a->VEGFRA(0, :, :)
   else if (vname .eq. "SST") then
    print(" READING === SEA SURFACE TEMPERATURE")
    data = a->SST(0, :, :)
   else if (vname .eq. "HGT")then
    print(" READING === TERRAIN HEIGHT")
    data = a->HGT(0, :, :)
   else if (vname .eq. "RAINC")then
    print(" READING === ACCUMULATED TOTAL CUMULUS PRECIPITATION")
    data = a->RAINC(0, :, :)
   else if (vname .eq. "RAINNC")then
    print(" READING === ACCUMULATED TOTAL GRID SCALE PRECIPITATION")
    data = a->RAINNC(0, :, :)
   else if (vname .eq. "PBLH")then
    print(" READING === PLANETARY BOUNDARY LAYER HEIGHT")
    data = a->PBLH(0, :, :)
   else if (vname .eq. "LH")then
    print(" READING === LATENT HEAT FLUX AT THE SURFACE")
    data = a->LH(0, :, :)
   end if
   end if
   end if
   end if
   end if
   end if
   end if
   end if
   end if
   end if

return
end
