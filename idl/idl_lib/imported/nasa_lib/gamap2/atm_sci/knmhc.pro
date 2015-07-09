; $Id: knmhc.pro,v 1.1.1.1 2007/07/17 20:41:36 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        KNMHC
;
; PURPOSE:
;        Returns an array of reaction rates for various non-methane 
;        hydrocarbon reactions as a function of temperature and pressure.
;
;        NOTE: Reaction rates may need updating to the latest JPL dataset.
;
; CATEGORY:
;        Atmospheric Sciences
;
; CALLING SEQUENCE:
;        RESULT = KNMHC( T, P [, Keywords ] )
;
; INPUTS:
;        T -> Temperature in [K].
;
;        P -> Pressure in [hPa].
;
; KEYWORD PARAMETERS:
;        NAMES -> Returns to the calling program a list of the names
;             for the various chemical species 
;
; OUTPUTS:
;        RESULT -> An array of rate constants corresponding to
;             the species contained in NAMES.
;        
;
; SUBROUTINES:
;        External Subroutines Required:
;        ================================
;        KTROE (function)
;
; REQUIREMENTS:
;        None
;
; NOTES:
;        (1) This should probably be rewritten to return a structure.
;        (2) Definitely needs updating of rate constants.
;
; EXAMPLE:
;        RESULT = KNMHC( 300, 1000, NAMES=NAMES  )
;        PRINT, NAMES
;          CO CH4 C2H2 C2H4 C2H6 C3H6 C3H8 i-BUT CH3CL
;        PRINT, RESULT
;          2.40000e-13  6.60071e-15  7.55980e-13  8.14644e-12  
;          2.45774e-13  5.08118e-11  1.10803e-12  2.34511e-12
;          3.76143e-14
;
;             ; Compute rate constants for 300K and 1000hPa pressure
;
; MODIFICATION HISTORY:
;        mgs, 1998?        INITIAL VERSION
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
;                          - added std doc header
;                          - updated comments, cosmetic changes
;-
; Copyright (C) 1998-2007, Martin Schultz 
; Bob Yantosca and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of 
; this software. If this software shall be used commercially or 
; sold as part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.as.harvard.edu with subject "IDL routine knmhc"
;-----------------------------------------------------------------------


function knmhc, T, P, names=names
 
   ; External functions
   FORWARD_FUNCTION Ktroe
 
   ; Species names
   names = [ 'CO', 'CH4', 'C2H2', 'C2H4', 'C2H6', 'C3H6', 'C3H8', 'i-BUT', $
              'CH3CL'  ]
 
   ;------------------------------------
   ; Rxn parameters
   ;------------------------------------
   kkco   = [ 1.5e-13 ]                   ; NOTE: p dependence
   
   kkch4  = [ 2.45e-12, 1775. ]           ; JPL97
   
   kkc2h2 = [ 5.5e-30, 0., 8.3e-13, -2. ] ; JPL97 (Troe)
   
   kkc2h4 = [ 1.0e-28, 0.8, 8.8e-12, 0. ] ; JPL97 (Troe)
   
   kkc2h6 = [ 8.7e-12, 1070. ]            ; JPL97
   
   kkc3h6 = [ 9.47e-12, -504. ]           ; from Atkinson 1994
   
   kkc3h8 = [ 1.0e-11, 660. ]             ; JPL97
   
   kkibut = [ 11.1e-18, -256. ]           ; from Atkinson 1994 
                                          ; (different formula !) 
   
   kkch3cl = [ 4.0e-12, 1400. ]           ; JPL97
 
 
   ;------------------------------------
   ; Now compute rate constants
   ;------------------------------------
 
   kco    = kkco(0) * (6.e-4*p + 1.)
 
   kch4   = kkch4(0) * exp(-kkch4(1)/T)
 
   kc2h2  = ktroe(T,p,kkc2h2(0),kkc2h2(1),kkc2h2(2),kkc2h2(3))
   
   kc2h4  = ktroe(T,p,kkc2h4(0),kkc2h4(1),kkc2h4(2),kkc2h4(3))
   
   kc2h6  = kkc2h6(0) * exp(-kkc2h6(1)/T)
 
   kc3h6  = kkc3h6(0) * exp(-kkc3h6(1)/T)
 
   kc3h8  = kkc3h8(0) * exp(-kkc3h8(1)/T)
 
   kibut  = kkibut(0) * T * T * exp(-kkibut(1)/T)
 
   kch3cl = kkch3cl(0) * exp(-kkch3cl(1)/T)
 
   ;------------------------------------
   ; Return everything as one big array
   ;------------------------------------
   n = n_elements( kco )
    
   if (n eq 1) then return, [kco,kch4,kc2h2,kc2h4,kc2h6,kc3h6,kc3h8, $
                              kibut,kch3cl]
 
   ; (else)
   res = fltarr(9,n)
   res(0,*) = kco
   res(1,*) = kch4
   res(2,*) = kc2h2
   res(3,*) = kc2h4
   res(4,*) = kc2h6
   res(5,*) = kc3h6
   res(6,*) = kc3h8
   res(7,*) = kibut
   res(8,*) = kch3cl
   
   return,res
end
 
