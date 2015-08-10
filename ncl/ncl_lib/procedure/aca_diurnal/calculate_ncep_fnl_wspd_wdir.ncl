;  $ID: calculate_ncep_fnl_wspd_wdir.ncl V01 08/08/2015 17:31 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE calculate_ncep_fnl_wspd_wdir.ncl CALCULATES WIND SPEED AND WIND 
;  DIRECTION BASED ON THE U-WIND AND V-WIND.
;
;  THE RELATIONSHIP BETWEEN WIND DIRECTION DEGREE AND U-WIND&V-WIND:
;  0~90    DEGREE : U>=0, V>=0;
;  90~180  DEGREE : U>=0, V<=0;
;  180~270 DEGREE : U<=0, V<=0;
;  270~360 DEGREE : U<=0, V>=0.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) u      (X-D):U WIND                                               [M/S]
;  (2 ) v      (X-D):V WIND                                               [M/S]
;  (3 ) wspd   (X-D):TOTAL WIND SPEED                                     [M/S]
;  (4 ) wdir   (X-D):TOTAL WIND DIRECTION                                 [DEG]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (08/08/2015)
;******************************************************************************
undef("calculate_ncep_fnl_wspd_wdir")
procedure calculate_ncep_fnl_wspd_wdir \
          (u        :float,       v      :float,\;INPUT
           wspd     :float,       wdir   :float)\;OUTPUT


begin
;  CALCULATE TOTAL SIND SPEED BASED ON THE U-WIND & V-WIND
   wspd = sqrt(u^2 + v^2)

;  CALCULATE THE INVERSE TANGENT, RETURN VALUE IS RADIANS (-PI/2, PI/2)
   watan = atan(u/v)

;  CONVERT THE RADIANS TO DEGREE
   watan_deg = watan*(180./pi)

;  BASED ON THE WIND DIRECTION DEFINITION, 
;  CALCULATE THE REAL WIND DIRECTION (0~360 DEGREE)
   if (u .ge. 0 .and. v .ge. 0) then
      wdir = watan_deg
   else if (u .ge. 0 .and. v .lt. 0) then
      wdir = 90.0-watan_deg
   else if (u .lt. 0 .and. v .le. 0) then
      wdir = 180.0+watan_deg
   else if (u .le. 0 .and. v .ge. 0) then
      wdir = 270.0-watan_deg
   end if
   end if
   end if
   end if

return
end
