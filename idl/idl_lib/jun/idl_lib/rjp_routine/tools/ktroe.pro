; $Id: ktroe.pro,v 1.1.1.1 2003/10/22 18:09:38 bmy Exp $
;-------------------------------------------------------------
;+
; NAME:
;        KTROE
;
; PURPOSE:
;        compute reaction rate coefficient for a 3rd order reaction
;        using Troe's formula as given in JPL97-4
;
; CATEGORY:
;        physical chemistry
;
; CALLING SEQUENCE:
;        k=KTROE(T,p,k0300,n,kinf300,m [,keywords])
;
; INPUTS:
;        T --> temperature in K
;
;        p --> pressure in mbars
;
;        k0300, n --> constants to get k0(T)  { see JPL97,table 2 }
;
;        kinf300, m --> constants to get kinf(T)  { see JPL97,table 2 }
;
; KEYWORD PARAMETERS:
;        k0, kinf, fc --> will return individual terms of the Troe expression
;
; OUTPUTS:
;        a rate coefficient
;
; SUBROUTINES:
;
; REQUIREMENTS:
;
; NOTES:
;        no error checking is done except for the correct number of arguments
;
; EXAMPLE:
;
; MODIFICATION HISTORY:
;        mgs, 20 Mar 1998: VERSION 1.00
;
;-
; Copyright (C) 1998, Martin Schultz, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author to arrange payment.
; Bugs and comments should be directed to mgs@io.harvard.edu
; with subject "IDL routine ktroe"
;-------------------------------------------------------------


function kdonahue,T,p,k0300,n,kinf300,m,fc,k0=k0,kinf=kinf
 
 
; compute reaction rate constant for a 3 body collision reaction
; (Troe formula as in Donahue et al., 1997 (JGR102/D5)

; seems to be a little faulty still !! ***********
; parameters for NO2+OH: 3.38313e-30, 2.9, 4.71363e-11, 0., 
;                        FcTemperatureScale 251.551207
;             paper gives Fc=0.3 !   

if (n_params() ne 7) then begin
    print,'KDONAHUE: must supply T,p,k0300,n,kinf300,m,fc !'
    return,-1
endif 

    ; formula:
    ; k = k0*(beta M / ( 1 + beta M/MC ) ) * F
    ; F = Fc ^ (1/B)
    ; B = 1+(log(beta*M/Mc)-0.12/(N+deltaN) )^2
    ; N = 0.75-1.27log(Fc)
    ; deltaN = +/- ( 0.1+0.6*log(Fc) )


    beta = 1         ; for nitrogen (and air)

    k0 = k0300*(T/300.)^(-n)
    kinf = kinf300*(T/300.)^(-m)
    MM = 2.69e19*(273./T)*(p/1013.25)
    MC = kinf/k0
    x  = beta*MM/MC
   
    ; first part 
    kk = k0 * ( beta*MM / ( 1.+x ) )


    ; calculate F
    NN = 0.75-1.27*alog10(Fc)
    DN = 0.1+0.6*alog10(Fc)
    if (x lt 1.) then DN = -(DN)
    
    B = 1. + ( (alog10(x)-0.12) / (NN+DN) )^2
    F = Fc^(1./B)

    k = kk*F
 
return,k
 
end


 
function ktroe,T,p,k0300,n,kinf300,m,k0=k0,kinf=kinf,fc=fc
 
 
; compute reaction rate constant for a 3 body collision reaction
; (Troe formula as in JPL97-4)

if (n_params() ne 6) then begin
    print,'KTROE: must supply T,p,k0300,n,kinf300,m !'
    return,-1
endif 
 
    k0 = k0300*(T/300.)^(-n)
    kinf = kinf300*(T/300.)^(-m)
    MM = 2.69e19*(273./T)*(p/1013.25)
 
    koM = k0*MM  ; do it once
    
    fc = 0.6^(1./(1+(alog10(koM/kinf))^2 ))
 
   
    k = koM/(1.+koM/kinf)*fc
 
return,k
 
end
 
