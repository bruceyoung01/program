; $Id: rh.pro,v 1.1.1.1 2007/07/17 20:41:36 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        RH     
;
; PURPOSE:
;        Calculates relative humidity from temperature and
;        dew/frostpoint
;
; CATEGORY:
;        Atmospheric Sciences
;
; CALLING SEQUENCE:
;        RESULT = RH( DEWPOINT, TEMPERATURE [,/WATER] [,/ICE] )
;
; INPUTS:
;        DEWPOINT --> dewpoint (or frostpoint) temperature [K]
;
;        TEMPERATURE --> dry (or static) air temperature [K]
;
; KEYWORD PARAMETERS:
;        /WATER --> always calculate dewpoint temperature
;
;        /ICE --> always calculate frostpoint temperature
;
; OUTPUTS:
;        RESULT -> Relative humidity [%]
;
; SUBROUTINES:
;        External Subroutines Required:
;        ===============================
;        E_H2O (function)
;
; REQUIREMENTS:
;        None
;
; NOTES:
;        None
;
; EXAMPLE:
;        PRINT, RH( 266., 278. )
;          41.4736
;
;             ; Prints the RH for dewpoint=266K and temp=278K.
;
; MODIFICATION HISTORY:
;        mgs, 23 Feb 1997: VERSION 1.00
;        mgs, 03 Aug 1997: split e_h2o and rh, renamed, added template
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
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
; or phs@io.as.harvard.edu with subject "IDL routine rh"
;-----------------------------------------------------------------------


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

 
 
