; $Id: e_h2o.pro,v 1.1.1.1 2007/07/17 20:41:36 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        E_H2O  
;
; PURPOSE:
;        Calculate water vapour pressure for a given temperature
;
; CATEGORY:
;        Atmospheric Sciences
;
; CALLING SEQUENCE:
;        RESULT = E_H2O( TEMPERATURE [,/WATER,/ICE,minval=minval] )
;
; INPUTS:
;        TEMPERATURE --> dew or frostpoint reading in K. If you supply
;              the dry air temperature (or static air temperature),
;              you will get a value for the water vapor saturation 
;              pressure.
;
; KEYWORD PARAMETERS:
;        /WATER --> interprete temperature as dewpoint (default)
;
;        /ICE --> interpret temperature as frostpoint
;
;        MINVAL -> minimum valid data value (default -1.0E30)
;
; OUTPUTS:
;        RESULT -> The water vapour pressure [hPa]
;
; SUBROUTINES:
;        None
;
; REQUIREMENTS:
;        None
;
; NOTES:
;        The algorithm has been taken from the NASA GTE project data
;        description.
;
; EXAMPLE:
;        PH2O = E_H2O(266.)
;
;             ; Calculate water vapor pressure for a 
;             ; dewpoint reading of 266 K
;
;        RH = PH2O/E_H2O(283.)
;
;             ; Compute relative humidity 
;             ; (divide ph2o by saturation pressure of DRY temperature)
;
;        PRINT,PH2O,RH
;          3.61742     0.294607
; 
;             ; Prints values        
;
; MODIFICATION HISTORY:
;        mgs, 23 Feb 1997: VERSION 1.00
;        mgs, 03 Aug 1997: split e_h2o and rh, renamed, added template
;        mgs, 23 May 1998: changed default behaviour to set reference
;               temperature to given TD value
;        mgs, 29 Aug 1998: VERSION 2.00
;          - much simpler and more logical interface
;          - no automatic detection of dew- or frostpoint any longer
;          - can now accomodate arrays
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
; or phs@io.as.harvard.edu with subject "IDL routine e_h2o";
;-----------------------------------------------------------------------


function e_h2o, TEMPERATURE, water=water, ice=ice, minval=minval


    if (n_elements(minval) eq 0) then minval = -1.0E30

    ; constants for water 
    if (keyword_set(water) OR not keyword_set(ice)) then begin
       a = 23.5518
       b = 2937.4
       c = 4.9283
       if (keyword_set(ICE)) then $
          message,'/WATER and /ICE specified together. Will use /WATER.',/INFO
    endif else begin
      a = 11.4816
      b = 2705.21
      c = 0.32286
    endelse


    ; create result(array) and initialize with missing
    res = 0.*temperature - 9.99E30   

    ; find valid data
    okind = where(temperature gt minval)

    if (okind[0] lt 0) then return,res

    ; quick test if temperature is in correct unit
    if (min(temperature[okind]) le 0.) then begin
        message,"Temperature must be given in K !",/CONT
        return,0
    end

    ; compute vapor pressure
    res[okind] = 10^(a-b/temperature[okind])*temperature[okind]^(-c)

    return,res
 
end
 
 
