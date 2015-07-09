  function get_airden, p1=p1, p2=p2, temp=temp, Area_m2=Area_m2

     ; Pressure at bottom edge of grid box [hPa] = p1

     ; Pressure at top edge of grid box [hPa] = p2

     g0       =   9.8d0    
     Rd       = 287.0d0      
     Rdg0     =   Rd / g0
     g0_100   = 100d0 / g0

     ; Molecules air / kg air    
     XNumolAir = 6.022d23 / 28.97d-3

     ; AIRMW : Molecular weight of air [28.97 g/mole]
     AIRMW    =  28.97d-3
       
         ;===========================================================
         ; BXHEIGHT is the height (Delta-Z) of grid box (I,J,L) 
         ; in meters. 
         ;
         ; The formula for BXHEIGHT is just the hydrostatic eqn.  
         ; Rd = 287 J/K/kg is the value for the ideal gas constant
         ; R for air (M.W = 0.02897 kg/mol),  or 
         ; Rd = 8.31 J/(mol*K) / 0.02897 kg/mol. 
         ;===========================================================
           DELP = P1 - P2
           BXHEIGHT = Rdg0 * TEMP * ALOG( P1 / P2 )
           AIRVOL   = BXHEIGHT * AREA_M2

         ;===========================================================
         ; AD = (dry) mass of air in grid box (I,J,L) in kg, 
         ; given by:        
         ;
         ;  Mass    Pressure        100      1        Surface area 
         ;        = difference   *  ---  *  ---   *   of grid box 
         ;          in grid box      1       g          AREA_M2
         ;
         ;   kg         mb          Pa      s^2           m^2
         ;  ----  =    ----      * ----  * -----  *      -----
         ;    1          1          mb       m             1
         ;===========================================================
           AD = DELP * G0_100 * AREA_M2 / AIRMW  ; Airmass in mole

         ;===========================================================
         ; AIRDEN = density of air (AD / AIRVOL) in mole / m^3 
         ;===========================================================

           AIRDEN = AD / AIRVOL

      Return, Airden

  END
