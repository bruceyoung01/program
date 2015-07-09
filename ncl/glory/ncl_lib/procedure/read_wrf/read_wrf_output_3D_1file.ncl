; $ID: read_wrf_output_3D_1file.ncl V01 05/18/2012 10:45 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE read_wrf_output_3D_1file READS OUT VARIABLES FROM WRF OUTPUT FILE 
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
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (05/18/2012)
;  (2 ) THE LENGTH OF TIME STRING IS 19. FORMAT IS AS FOLLOWING:
;       YYYY-MM-DD_HH:00:00. (05/19/2012)
;  (3 ) 3-D VARIABLES' FORMAT IS AS FOLLOWING:
;       data(nlevel, nlat, nlon). (05/19/2012)
;******************************************************************************

undef("read_wrf_output_3D_1file")
procedure read_wrf_output_3D_1file \
          (dir        :string,  filename     :string, \ ; INPUT
           tname      :string,  vname        :string, \ ; INPUT
           time       :string,  data         :float)    ; OUPUT

begin

;  ADD FILE NAME
   a = addfile(dir + filename + ".nc", "r")
   ctime = a->Times
   time  = charactertostring(ctime)
;  READ VARIABLES
   print("-----3-Dimensional Variables-----")
   if (vname .eq. "U") then
    print(" READING === U WIND ")
    data = a->U(0, :, :, :)
   else if (vname .eq. "V") then
    print(" READING === V WIND ")
    data = a->V(0,:, :, :)
   else if (vname .eq. "W") then
    print(" READING === W WIND ")
    data = a->W(0,:, :, :)
   else if (vname .eq. "PM2_5_DRY") then
    print(" READING === PM2_5_DRY")
    data = a->PM2_5_DRY(0, :, :, :)
   else if (vname .eq. "PM10") then
    print(" READING === PM10")
    data = a->PM10(0, :, :, :)
   else if (vname .eq. "TAUAER1")then
    print(" READING === TAUAER1")
    data = a->TAUAER1(0,:, :, :)
   else if (vname .eq. "TAUAER2")then
    print(" READING === TAUAER2")
    data = a->TAUAER2(0,:, :, :)
   else if (vname .eq. "TAUAER3")then
    print(" READING === TAUAER3")
    data = a->TAUAER3(0,:, :, :)
   else if (vname .eq. "TAUAER4")then
    print(" READING === TAUAER4")
    data = a->TAUAER4(0,:, :, :)
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
