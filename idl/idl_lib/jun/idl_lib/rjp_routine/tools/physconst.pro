; $Id: physconst.pro,v 1.1.1.1 2003/10/22 18:09:39 bmy Exp $



pro physconst


    ; create a system variable with physical constants

    defsysv,'!PHYSCONST',exists=i

    if (i eq 1) then return    ; already defined


    ; define sample structure 

    defsysv,'!PHYSCONST', $
         { c:2.9979D8,    speed_of_light:2.9979D8,  $     ; m s-1
           h:6.626D-34,   planck:6.626D-34,  $            ; J s
           e:1.602D-19,   elementary_charge:1.602D-19, $  ; C
           me:9.109D-31,  electron_mass:9.109D-31,  $     ; kg
           NA:6.022D23,   avogadro:6.022D23,  $           ; mol-1
           R:8.314D0,     molar_gas:8.314D0,  $           ; J mol-1 K-1
           k:1.381D-23,   boltzmann:1.381D-23,  $         ; J K-1
           sigma:5.671D-8, stefan_boltzmann:5.671D-8,  $  ; W m-2 K-4
           g:9.80665D0,   acceleration_due_to_gravity:9.80665D0 } 
                                                          ; m s-2


    return
end

