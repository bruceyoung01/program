; $Id: rh.pro,v 1.1.1.1 2003/10/22 18:09:39 bmy Exp $
;-------------------------------------------------------------
;+
; NAME:
;        RH     
;
; PURPOSE:
;        calculate relative humidity from temperature and
;        dew/frostpoint
;
; CATEGORY:
;        atmospheric sciences
;
; CALLING SEQUENCE:
;        RH(DEWPOINT,TEMPERATURE [,/WATER] [,/ICE])
;
; INPUTS:
;        DEWPOINT --> dewpoint (or frostpoint) temperature in K
;        TEMPERATURE --> dry (or static) air temperature
;
; KEYWORD PARAMETERS:
;        /WATER --> always calculate dewpoint temperature
;
;        /ICE --> always calculate frostpoint temperature
;
; OUTPUTS:
;        the relative humidity in percent   
;
; SUBROUTINES:
;
; REQUIREMENTS:
;        function E_H2O is called
;
; NOTES:
;
; EXAMPLE:
;        PRINT,RH(266.,278.)
;
;        IDL prints:   41.4736
;
; MODIFICATION HISTORY:
;        mgs, 23 Feb 1997: VERSION 1.00
;        mgs, 03 Aug 1997: split e_h2o and rh, renamed, added template
;-
; Copyright (C) 1997, Martin Schultz, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author to arrange payment.
; Bugs and comments should be directed to mgs@io.harvard.edu
; with subject "IDL routine h2osat"
;-------------------------------------------------------------


function rh, td, tt, water=water, ice=ice
 
if (td gt tt) then begin
  print,"ERROR in rh: dew-/frostpoint greater than static air temperature"
  return,-1
  end

if (not(keyword_set(water) or keyword_set(ice))) then begin
   e = e_h2o(td,tt=tt)
   esat = e_h2o(tt,tt=tt)
   end
if (keyword_set(water)) then begin
   e = e_h2o(td,tt=tt,/water)
   esat = e_h2o(tt,tt=tt,/water)
   end
if (keyword_set(ice)) then begin
   e = e_h2o(td,tt=tt,/ice)
   esat = e_h2o(tt,tt=tt,/ice)
   end

return,e/esat*100.

end

 
 
