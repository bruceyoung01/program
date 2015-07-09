; $Id: schmidt.pro,v 1.1.1.1 2003/10/22 18:09:40 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        SCHMIDT
;
; PURPOSE:
;        Computes the SCHMIDT number for a given species.
;
; CATEGORY:
;        
;
; CALLING SEQUENCE:
;        SCHMIDT
;
; INPUTS:
;        TEMPERATURE -> Temperature in Kelvin.
;
;        XMV -> Molar volume of species
;
;
; KEYWORD PARAMETERS:
;
; OUTPUTS:
;
; SUBROUTINES:
;
; REQUIREMENTS:
;
; NOTES:
;
; EXAMPLE:
;
; MODIFICATION HISTORY:
;  pip & bmy, 27 Jun 2003: VERSION 1.00
;                          - Written by Paul Palmer
;
;-
; Copyright (C) 2003, Bob Yantosca, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author.
; Bugs and comments should be directed to bmy@io.harvard.edu
; with subject "IDL routine schmidt"
;-----------------------------------------------------------------------


Function Schmidt, Temperature, XMV, SeaWater
 
   ;====================================================================
   ; Initialization
   ;====================================================================

   ; Arguments
   if ( N_Elements( XMV         ) ne 1 ) then Message, 'Need to pass XMV!'
   if ( N_Elements( SeaWater    ) ne 1 ) then Message, 'Need to pass SEAWATER!'
   if ( N_Elements( Temperature ) ne 1 ) $
      then Message, 'Need to pass TEMPERATURE!'
  
   ;====================================================================
   ; Compute SCHMIDT number
   ;====================================================================

   ; Viscosity of water, cp
   ; Based on fitting temperature (0,10,20,30,40,50,60,80,100) with
   ; Viscosity (1.7834,1.3022,1.0019,0.7995,0.6513,0.5481,0.4687,0.3545,0.2813)
   ; Need T in Kelvin
   H2OViscosity =   25.36415d0                                   - $
                  ( 0.1405311d0    * Temperature               ) + $
                  ( 0.0001969059d0 * Temperature * Temperature )
 
   ; Molecular weight of water, g/mol
   H2OMass = 18.0d0
 
   ; Association factor of water, dimensionless
   AF = 2.26d0
 
   ; Molar volume of X at its normal boiling temperature
   XMV = XMV 
        
   ; Diffusion coefficient of species X in water, cm^2 /s
   ; Need T in Kelvin
   D = ( 7.4D-8 * ( AF * H2OMass )^(0.5D) * Temperature ) / $
       ( H2OViscosity * XMV^(0.6D) )
 
   ; The diffusion coefficient should be decreased by 6% to obtain
   ; the diffusion coefficient in seawater (See Wanninkhof 1992)
   If ( SeaWater EQ 1 ) Then Begin
      D = D * 0.94d0
   EndIf
 
   ; Kinematic viscosity of water, cm^2/s
   KinematicViscosity = H2OViscosity * 1e-2
 
   ; To get kinematic viscosity for seawater (3.5% salinity)
   ; Wanninkhof 1992
   ; Need T in Celsius
   Tc = Temperature - 273.15D0
   FA = 1.052d0 + ( 1.3d-3 * Tc ) + ( 5d-6 * Tc^2 ) - ( 5d-7 * Tc^3 )
 
   KinematicViscosity = FA * KinematicViscosity
 
   ; Return to calling program
   return, KinematicViscosity / D
        
End
