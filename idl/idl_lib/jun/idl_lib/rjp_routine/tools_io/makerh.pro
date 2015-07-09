 Function MAKERH, sphu=sphu, pres=pres, temp=temp

 if N_elements(sphu) eq 0 then return, -1
 if n_elements(pres) eq 0 then return, -1
 if n_elements(temp) eq 0 then return, -1

; if sphu lt 0. or pres le 0. or temp le 0. then return, -1

; pressure in mb
; temperautre in K
; sphu in g/kg

    A =   23.5518d0
    B = 2937.4d0
    C =   -4.9283d0

    ; Saturation water vapor pressure in mbar 
    ; (from NASA GTE PEM-Tropics handbook)
    ESAT = ( 10d0^( A - ( B / TEMP ) ) ) * ( TEMP^C )
            
    ; Specific humidity in mb
    SHMB = SPHU * 1.6072d-3 * PRES
            
    ; Relative humidity as a percentage
    RH = ( SHMB / ESAT ) * 100d0 

  Return, RH

 END

 
