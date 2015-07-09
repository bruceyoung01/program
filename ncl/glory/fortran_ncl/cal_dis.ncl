; $ID CAL_DIS.NCL V01 10/23/2011 15:08:00 BRUCE EXP $
;
;******************************************************************************
;  PROGRAM CAL_DIS IS A NCL SCRIPT WHICH CALLS A FORTRAN SUBROUTINE TO 
;  CALCULATE THE DISTANCE BETWEEN TWO POINTS ON THE EARTH.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) FLAT1        (FLOAT) : LATITUDE OF POINT A
;  (2 ) FLAT2        (FLOAT) : LATITUDE OF POINT B
;  (3 ) FLON1        (FLOAT) : LONGITUDE OF POINT A
;  (4 ) FLON2        (FLOAT) : LONGITUDE OF POINT B
;  (5 ) DIS          (FLOAT) : GEOMETRIC DISTANCE BETWEEN POINTS A AND B
;
;  NOTES:
;  (1 ) ORIGINALLY WRITTEN BY BRUCE (BRUCE, 10/23/2011)
;
;******************************************************************************
;  CALL FORTRAN SUBROUTINE FROM NCL PROGRAM TEST

;  LAOD LIBRARIES USED IN THIS PROGRAM
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW_epa.ncl"

; CALL CALCULATE DISTANCE FRUNCTION
external cal_dis "/home/bruce/program/fortran/test/cal_dis.so"

begin

   flat1 = 40.8
   flat2 = 40.9
   flon1 = -96.7
   flon2 = -97.0
   dis   = new(1, float)
;  EXECUTE THE FORTRAN SUBROUTINE CAL_DIS
   cal_dis::cal_dis(flat1, flat2, flon1, flon2, dis)
   print("DISTANCE OF THESE TWO POINTS : " + dis)

end
