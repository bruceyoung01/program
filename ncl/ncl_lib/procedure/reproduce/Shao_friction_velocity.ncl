;  ID: Shao_friction_velocity.ncl V01 02/16/2015 18:41 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE Shao_friction_velocity CALCULATES THRESHOLD FRICTION VELOCITY 
;  BASED ON Shao_1996_AJSR PAPER.
;
;  VARIABLES:
;  ============================================================================
;  (1 )
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (02/16/2015)
;******************************************************************************
undef("Shao_friction_velocity")
procedure Shao_friction_velocity \
          (D         :float,    \ ;INPUT
           u         :float)      ;OUTPUT

begin

;  SET UP PARAMETERS FOR Shao DUST EMISSION SCHEME TO CALCULATE 
;  THRESHOLD FRICTION VELOCITY OVER SMOOTH SURFACE
;  AIR DENSITY (g/cm3)
   rho_a  = 0.00123
;  DENSITY OF QUARTZ (g/cm3)
   rho_p  = 2.65
;  GRAVITATIONAL ACCELERATION (cm/s2)
   g      = 981.0
;  AN VALUE
   AN     = 0.0123
   tau    = (/1.65*10^(-4), 3*10^(-4), 5*10^(-4)/)
;  CONVERT tau FROM kg TO g
   tau    = tau*1000.0
   ndimtau= dimsizes(tau)
   ntau   = ndimtau(0)
   ndimD  = dimsizes(D)
   nD     = ndimD(0)

   do i = 0, ntau-1
      do j = 0, nD-1
         u(i, j) = sqrt(AN*((rho_p*g*D(j)/rho_a) + (tau(i)/rho_a*D(j))))
      end do
   end do
;  print(u)

end
