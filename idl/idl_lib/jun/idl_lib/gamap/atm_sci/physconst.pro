; $Id: physconst.pro,v 1.1.1.1 2007/07/17 20:41:36 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        PHYSCONST
;
; PURPOSE:
;        Creates a system variable named !PHYSCONST which contains 
;        various physical constants.
;
; CATEGORY:
;        Atmospheric Sciences
;
; CALLING SEQUENCE:
;        PHYSCONST
;
; INPUTS:
;        None
;
; KEYWORD PARAMETERS:
;        None
;
; OUTPUTS:
;        None
;
; SUBROUTINES:
;        None
;
; REQUIREMENTS:
;
; NOTES:
;        The !PHYSCONST system variable contains both the short names
;        (e.g. C) and long names (e.g. SPEED_OF_LIGHT) for the various
;        physical constatnts.
;
; EXAMPLE:
;        PHYSCONST
;        HELP, !PHYSCONST, /STRU
;
;        ** Structure <108c0378>, 18 tags, length=144, data length=144, refs=2:
;        C                            DOUBLE   2.9979000e+08
;        SPEED_OF_LIGHT               DOUBLE   2.9979000e+08
;        H                            DOUBLE   6.6260000e-34
;        PLANCK                       DOUBLE   6.6260000e-34
;        E                            DOUBLE   1.6020000e-19
;        ELEMENTARY_CHARGE            DOUBLE   1.6020000e-19
;        ME                           DOUBLE   9.1090000e-31
;        ELECTRON_MASS                DOUBLE   9.1090000e-31
;        NA                           DOUBLE   6.0220000e+23
;        AVOGADRO                     DOUBLE   6.0220000e+23
;        R                            DOUBLE   8.3140000
;        MOLAR_GAS                    DOUBLE   8.3140000
;        K                            DOUBLE   1.3810000e-23
;        BOLTZMANN                    DOUBLE   1.3810000e-23
;        SIGMA                        DOUBLE   5.6710000e-08
;        STEFAN_BOLTZMANN             DOUBLE   5.6710000e-08
;        G                            DOUBLE   9.8066500
;        ACCELERATION_DUE_TO_GRAVITY  DOUBLE   9.8066500
;          
;
; MODIFICATION HISTORY:
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
;                          - Updated comments, cosmetic changes
;
;-
; Copyright (C) 1997-2007, Martin Schultz, 
; Bob Yantosca and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of 
; this software. If this software shall be used commercially or 
; sold as part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.as.harvard.edu with subject "IDL routine physconst"
;-----------------------------------------------------------------------


pro PhysConst
 
   ; Create a system variable with physical constants
   Defsysv, '!PHYSCONST', Exists=It_Exists
   
   ; Return if it has already been defined
   if ( It_Exists ) then return 
    
   ; Define the !PHYSCONST system variable 
   DefSysV, '!PHYSCONST', $
      { c                           : 2.9979D8,    $   ; m s-1
        speed_of_light              : 2.9979D8,    $   ; m s-1
                                                   $   
        h                           : 6.626D-34,   $   ; J s 
        planck                      : 6.626D-34,   $   ; J s
                                                   $   
        e                           : 1.602D-19,   $   ; C
        elementary_charge           : 1.602D-19,   $   ; C
                                                   $   
        me                          : 9.109D-31,   $   ; kg
        electron_mass               : 9.109D-31,   $   ; kg
                                                   $   
        NA                          : 6.022D23,    $   ; mol-1
        avogadro                    : 6.022D23,    $   ; mol-1
                                                   $   
        R                           : 8.314D0,     $   ; J mol-1 K-1 
        molar_gas                   : 8.314D0,     $   ; J mol-1 K-1
                                                   $   
        k                           : 1.381D-23,   $   ; J K-1
        boltzmann                   : 1.381D-23,   $   ; J K-1
                                                   $   
        sigma                       : 5.671D-8,    $   ; W m-2 K-4
        stefan_boltzmann            : 5.671D-8,    $   ; W m-2 K-4
                                                   $
        g                           : 9.80665D0,   $   ; m s-2
        acceleration_due_to_gravity : 9.80665D0 }      ; m s-2
    
   return
end
 
