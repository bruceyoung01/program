; $ID: interpolate_aod.ncl V01 04/19/2012 15:50 BRUCE EXP$
;
;******************************************************************************
;  PROCEDURE interpolate_aod INTERPOLATES AOD OF ONE SPECIFIC WAVELENGTH FROM 
;  THE AOD OF ONE BIGGER WAVEMENGTH AND THE AOD OF ONE SMALLER WAVELENGTH 
;  USING ANGSTROM EXPONENT.
;
;  VARIABLES:
;  ============================================================================
;  (1 ) lambda1   (float):WAVELENGTH 1 OF KNOWN AOD 1                   [um ]
;  (2 ) aod1      (float):KNOWN AOD 1                                   [---]
;  (3 ) lambda2   (float):WAVELENGTH 2 OF KNOWN AOD 2                   [um ]
;  (4 ) aod2      (float):KNOWN AOD 2                                   [---]
;  (5 ) lambda    (float):WAVELENGTH OF UNKNOWN AOD                     [um ]
;  (6 ) aod       (float):UNKNOWN AOD                                   [---]
;
;  NOTES:
;  ============================================================================
;  (1 ) ORIGINALLY WRITTEN BY BRUCE. (04/19/2012)
;  (2 ) ADD IF STATEMENT TO JUDGE AOD1 .NE. 0.0. (06/19/2012)
;******************************************************************************

undef("interpolate_aod")
procedure interpolate_aod(lambda1  :float, aod1    :float, ; \ INPUT
                          lambda2  :float, aod2    :float, ; \ INPUT
                          lambda   :float,                 ; \ INPUT
                          aod      :float)                 ; \ OUTPUT

begin
;  FILTER ZERO VALUE OF aod1
   alpha     = new(dimsizes(aod1), typeof(aod1))
   beta      = new(dimsizes(aod1), typeof(aod1))
   oned_aod1 = ndtooned(aod1)
   oned_aod2 = ndtooned(aod2)
   oned_alpha= ndtooned(alpha)
   oned_beta = ndtooned(beta)
   index     = ind(oned_aod1 .gt. 0.0)
;  CALCULATE ALPHA AND BETA DEPENDING ON ANGSTROM'S EMPIRICAL EXPRESSION
   if (.not.all(ismissing(index)))then
    oned_alpha(index) = log(oned_aod2(index)/oned_aod1(index)) \
                       /log(lambda2/lambda1)
   else if (all(ismissing(index)))then
    oned_alpha = 0.0
   end if
   end if
   alpha = onedtond(oned_alpha, dimsizes(aod1))
   beta  = aod1*lambda^alpha
   aod   = beta*lambda^(-alpha)

return
end
