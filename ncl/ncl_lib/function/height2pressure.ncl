;  $ID: height2pressure.ncl V01 08/14/2015 16:57 BRUCE EXP$
;
;******************************************************************************
;  FUNCTION height2pressure.ncl CALCULATES PRESSURE USING HEIGHT AND TEMPERATURE
;
;  VARIABLES:
;  ============================================================================
;  (1 ) h    (X-D):HEIGHT                                                 [m  ]
;  (2 ) t    (X-D):TEMPERATURE                                            [C  ]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (08/14/2015)
;******************************************************************************
undef("height2pressure")
function height2pressure \
         (h     :float, t    :float)\;INPUT

begin

;  SETUP PARAMETERS

;  HEIGHT AT THE BOTTOM OF ATMOSPHERIC LAYER [m]
   hb =
;  STANDARD TEMPERATURE LAPSE RATE [K/m]
   lb = -0.0065
;  UNIVERSAL GAS CONSTANT[N*m/(mol*K)]
   r  = 8.31432
;  GRAVITATIONAL ACCELERATION CONSTANT [m/s2]
   g0 = 9.80665
;  MOLAR MASS OF EARTH'S AIR [kg/mol]
   m  = 0.0289644

;  USING THE FOLLOWING FORMULA TO CALCULATE PRESSURE, WHICH IS FROM 
;  http://www.mide.com/products/slamstick/air-pressure-altitude-calculator.php
   p  = pb*(1+(lb-t)*(h-hb))^(-g0*m/(r*lb))

  return(p)
end
