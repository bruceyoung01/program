;  $ID: MB_friction_velocity.ncl V01 02/16/2015 18:20 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE MB_friction_velocity CALCULATES THE THRESHOLD FRICTION VELOCITY 
;  BASED ON Marticorena_1995_JGR PAPER.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) D     (float): PARTICLE DIAMETER                                  (CM)
;  (2 ) u     (float): THRESHOLD FRICTION VELOCITY                      (CM/S)
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (02/16/2015)
;******************************************************************************
undef("MB_friction_velocity")
procedure MB_friction_velocity \
          (D            :float,         \ ;INPUT
           u            :float)           ;OUTPUT

begin

;  =====================================================================
;  SET UP PARAMETERS FOR MB DUST EMISSION SCHEME TO CALCULATE 
;  THRESHOLD FRICTION VELOCITY OVER SMOOTH SURFACE
;  AIR DENSITY (g/cm3)
   rho_a  = 0.00123
;  DENSITY OF QUARTZ (g/cm3)
   rho_p  = 2.65
;  GRAVITATIONAL ACCELERATION (cm/s2)
   g      = 981.0
;  CALCULATE K
   K      = sqrt((rho_p*g*D)/rho_a)*sqrt(1+0.006/(rho_p*g*D^2.5))
;  print(K)

;  PARAMETERS FOR CALCULATING REYNOLDS NUMBER
;  UNIT IS cm^(-x)
   a      = 1331.0
   b      = 0.38
   x      = 1.56
   Re     = a*D^x + b

   ndim   = dimsizes(D)
   npts   = ndim(0)
;  CALCULATE u
   do i = 0, npts-1
;     print("Re = " + Re(i))
      if (Re(i) .gt. 0.03 .and. Re(i) .le. 10.0) then
         u(i)      = 0.129*K(i)/sqrt(1.928*Re(i)^0.092-1)
      end if
      if (Re(i) .gt. 10.0) then
         u(i)      = 0.129*K(i)*(1-0.0858*exp(-0.0617*(Re(i)-10)))
      end if
   end do
;  print(u)




end
