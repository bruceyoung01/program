; $Id: find_unit.pro,v 1.1.1.1 2003/10/22 18:09:36 bmy Exp $
;-------------------------------------------------------------
;+
; NAME:
;        FIND_UNIT
;
; PURPOSE:
;        Return classification and conversion information for
;        physical units. You pass a unit name, and you will
;        get a standard form of that name as well as a factor
;        and an offset that convert the unit to SI standard.
;        To convert one unit to another, use FIND_UNIT twice
;        (see example below).
;
; CATEGORY:
;        Tools
;
; CALLING SEQUENCE:
;        FIND_UNIT,NAME,STDNAME,FACTOR,OFFSET,CATEGORY [,keywords]
;
; INPUTS:
;        NAME -> A string containing the name to search for
;
; KEYWORD PARAMETERS:
;        /GET_SI -> Return the name of the SI unit of the category of 
;            the given unit. Factor and offset will always be 1.0 and 
;            0.0, CATEGORY will contain the category number.
; 
;        /NO_STANDARD -> Do not return the standard name of a unit. The
;            standard spelling is identified as the first occurrence
;            of a given unit with the same conversion factor and offset
;            in the same category and normally replaces the input name.
;
;        /TEST -> Check standard unit strings for consistency
;            This keyword is only useful when you add extra units.
;
; OUTPUTS:
;        STDNAME -> The unit name as saved in the stdunits array
;            (e.g. 'KG' is returned as 'kg')
;
;        FACTOR -> A conversion factor to SI 
;
;        OFFSET -> A conversion offset
;
;        CATEGORY -> The class to which the unit belongs:
;           -1 : unit not found
;            0 : distance
;            1 : area
;            2 : volume
;            3 : time
;            4 : frequency
;            5 : speed
;            6 : accelaration
;            7 : temperature
;            8 : weight
;            9 : pressure
;           10 : force
;           11 : energy
;           12 : power
;           13 : mixing ratio
;           14 : currency
;           15 : voltage
;
; SUBROUTINES:
;
; REQUIREMENTS:
;
; NOTES:
;
; EXAMPLE:
;        FIND_UNIT,'kM/H',stdname,factor,offset,category
;        print,stdname,factor,offset,category
;        ; prints km/h     0.277780      0.00000       5
;
;        ; conversion from Fahrenheit to Celsius
;        temp = [ 0., 32., 80., 100. ]
;        FIND_UNIT,'F',fromname,fromfac,fromoff,fromcat
;        FIND_UNIT,'C',toname,tofac,tooff,tocat
;        if (fromcat ne tocat) then print,'bullsh...'
;        ctemp = ((fromfac*temp+fromoff) - tooff) / tofac
;        print,ctemp
;        ; prints  -17.7778  0.000152588   26.6670   37.7782
;
;        ; find name of corresponding SI unit 
;        FIND_UNIT,'mph',stdname,/get_si
;        print,stdname
;        ; prints  m/s
;
;        ; find standard form of any unit
;        FIND_UNIT,'miles/hour',stdname
;        print,stdname
;        ; prints  mph
;
; MODIFICATION HISTORY:
;        mgs, 26 Aug 1998: VERSION 1.00
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
; with subject "IDL routine find_unit"
;-------------------------------------------------------------


pro find_unit,name,stdname,factor,offset,category,   $
           get_si=get_si,no_standard=no_standard,test=test
 
 
    ; set up arrays 
    ; conversion factors go from unit to standard (which is first 
    ; entry)
    ; Units are searched case insensitive, but replaced with new unit
    ; in the standard writing 
    ; micro... is expressed as either u.. or y..
 
    ;  0 : length
    stdlen = [ 'm', 'cm', 'mm', 'um', 'ym', 'nm', 'km', $
               'yd', 'yard', 'ft', 'feet', 'kft', 'in', 'inch',  $
               'mi', 'miles', 'nmi', 'n mi', 'ly', 'AU' ]
    faclen = [ 1.0, 0.01, 0.001, 1.0E-6, 1.0E-6, 1.0E-9, 1000., $
               0.9144, 0.9144, 0.3048, 0.3048, 3.048E-4, 0.0254, 0.0254, $
               1609.344, 1609.344, 1852., 1852., 9.4607E15, 1.49597870E11 ]
 
 
    ;  1 : area
    stdarea = [ 'm2', 'cm2', 'mm2', 'um2', 'ym2', 'nm2', 'ha', 'km2', $
                'sqft', 'square feet', 'sqkft', 'sqin', 'square inch',  $
                'sqmi', 'square miles', 'acres' ]
    facarea = [ 1.0, 1.0E-4, 1.0E-6, 1.0E-12, 1.0E-12, 1.0E-18, 1.0E4, 1.0E6, $
                0.092903, 0.092903, 9.2903E-8, 6.4516E-4, 6.4516E-4, $
                2.58999E6, 2.58999E6, 4047. ]
 
 
    ;  2 : volume
    stdvol = [ 'm3', 'cm3', 'mm3', 'ltr', 'l', 'gal' ]
    facvol = [ 1.0, 1.0E-6, 1.0E-9, 1.0E-3, 1.0E-3, 3.785E-3 ]
 
 
    ;  3 : time 
    stdtime = [ 's', 'secs', 'min', 'mn', 'h', 'd', 'month',  $
                'y', 'year' ]
    factime = [ 1.0, 1.0, 60., 60., 3600., 86400., 2.592E6,   $
                3.15576E7, 3.15576E7 ] 
 
 
    ;  4 : frequency
    stdfreq = [ 'Hz', 'kHz', 'MHz', 'GHz', 'THz' ]
    facfreq = [ 1.0, 1.0E3, 1.0E6, 1.0E9, 1.0E12 ]
 
 
    ;  5 : speed
    stdspeed = [ 'm/s', 'km/s', 'km/h', 'mph', 'miles/hour',  $
                 'kn', 'knots', 'knts' ]
    facspeed = [ 1.0, 1000., 0.27778, 0.44704, 0.44704,   $
                 0.51444, 0.51444, 0.51444 ]
 
 
    ;  6 : acceleration
    stdacc = [ 'm/s2' ]
    facacc = [ 1.0 ]
 
 
    ;  7 : Temperatures: convert as TEMPNEW = FAC*OLDTEMP+OFFSET
    stdtemp = [ 'K', 'C', 'degC', 'deg C', 'F', 'degF', 'deg F' ]
    factemp = [ 1.0, 1.0, 1.0, 1.0, 0.55556, 0.55556, 0.55556 ]
    offtemp = [ 0.0, 273.15, 273.15, 273.15, 255.37222, 255.37222, 255.37222 ]
 
 
    ;  8 : weight
    stdweight = [ 'kg', 'g', 't', 'kt', 'Mt', 'Gt', 'Tg',   $
                  'oz', 'ounces', 'lbs', 'short tons', 'tons', 'metric tons' ]
    facweight = [ 1.0, 1.0E-3, 1000., 1.0E6, 1.0E9, 1.0E12, 1.0E9, $
                  0.028349523, 0.028349523, 0.4535924, 907.8, 907.8, 1000. ]
 
 
    ;  9 : pressure
    stdpress = [ 'Pa', 'hPa', 'bar', 'mbar', 'mb', 'mmHg', 'torr',  $
                 'inH2O', 'inHg', 'lbf/in2', 'lb/in2' ]
    facpress = [ 1.0, 100., 1.0E5, 100., 100., 133.322, 133.322,  $
                 249.089, 338.639, 6894.76, 6894.76 ]
 
 
    ; 10 : force
    stdforce = [ 'N', 'kg*m/s2', 'dyn', 'kp' ]  
    facforce = [ 1.0, 1.0, 1.0E-5, 9.80665 ]
 
 
    ; 11 : energy
    stdenergy = [ 'J', 'N*m', 'kg*m2/s2', 'eV', 'erg', 'cal', 'Wh', 'kWh' ]
    facenergy = [ 1.0, 1.0, 1.0, 1.6021892E-19, 1.E-7, 4.1868, 3600., 3.6E6 ]
 
 
    ; 12 : power
    stdpower = [ 'W', 'kg*m2/s3', 'kW', 'MW', 'GW', 'TW', 'PS', 'hp' ]
    facpower = [ 1.0, 1.0, 1000., 1.0E6, 1.0E9, 1.0E12, 735.499, 745.70  ]
 
 
    ; 13 : mixing ratios
    stdmix =  [ 'v/v', '%', 'pp', 'ppmv', 'ppm', 'ppbv', 'ppb', $
                'pptv', 'ppt',  $
                '#/cm3(@298K,1013hPa)', '#/cm3(@273K,1013hPa)', $
                'g/kg(H2O)' ]
    facmix = [ 1.0, 1.0E-2, 1.0E-3, 1.0E-6, 1.0E-6, 1.0E-9, 1.0E-9, $
               1.0E-12, 1.0E-12,  $
               0.406E-19, 0.372E-19, $
               1.6078E-3 ]


    ; 14 : currency
    stdcur = [ 'A', 'mA', 'uA', 'yA', 'kA' ]
    faccur = [ 1.0, 1.0E-3, 1.0E-6, 1.0E-6, 1000. ] 
 
 
    ; 15 : voltage
    stdvltg = [ 'V', 'mV', 'uV', 'yV', 'kV' ]
    facvltg = [ 1.0, 1.0E-3, 1.0E-6, 1.0E-6, 1000. ] 
 
 
    ; ============================================================ 
    ; Put them all together and make categories and offsets
    ; ============================================================ 
 
    stdunits = [ stdlen, stdarea, stdvol, stdtime, stdfreq, stdspeed, $
                 stdacc, stdtemp, stdweight, stdpress, stdforce, $
                 stdenergy, stdpower, stdmix, stdcur, stdvltg ]
 
    n_units = n_elements(stdunits)
 
    facunits = [ faclen, facarea, facvol, factime, facfreq, facspeed, $
                 facacc, factemp, facweight, facpress, facforce, $
                 facenergy, facpower, facmix, faccur, facvltg ]
 
    ; default offset is 0.0 - replace only temperature offsets
    offunits = fltarr(n_units)
    ind = where(stdunits eq 'K')
    offunits[ind[0]] = offtemp  ; Will replace all temp offsets !
 
    catunits = [ replicate(0,n_elements(stdlen)), $
                 replicate(1,n_elements(stdarea)), $
                 replicate(2,n_elements(stdvol)), $
                 replicate(3,n_elements(stdtime)), $
                 replicate(4,n_elements(stdfreq)), $
                 replicate(5,n_elements(stdspeed)), $
                 replicate(6,n_elements(stdacc)), $
                 replicate(7,n_elements(stdtemp)), $
                 replicate(8,n_elements(stdweight)), $
                 replicate(9,n_elements(stdpress)), $
                 replicate(10,n_elements(stdforce)), $
                 replicate(11,n_elements(stdenergy)), $
                 replicate(12,n_elements(stdpower)), $
                 replicate(13,n_elements(stdmix)), $
                 replicate(14,n_elements(stdcur)), $
                 replicate(15,n_elements(stdvltg))  ]
 
 
    ; ============================================================ 
    ; Little test section:
    ; for now only checks that all names are uniqe
    ; ============================================================ 
 
    if (keyword_set(test)) then begin
       uunits = uniq(stdunits,sort(stdunits))
       if (n_elements(uunits) ne n_units) then $
          message,'Standard unit strings contain double entries !'
    endif
 
 
    ; ============================================================ 
    ; Find name in standard strings
    ; ============================================================ 
 
    if (n_params() lt 1) then begin
        message,'Parameters: NAME,stdname,FACTOR,OFFSET [,CATEGORY]', $
             /CONT
        return
    endif
 
 
    stdname = name    ; initialize with no change
    factor = 1.0
    offset = 0.0
    category = -1     ; unknown category
 
    ; is name contained in standard units?
    test = where(strlowcase(stdunits) eq strlowcase(name))
 
    if (test[0] ge 0) then begin
       stdname = stdunits[test[0]]    ; "format" unit name
       category = catunits[test[0]]
       if (keyword_set(get_si)) then begin

          index = where(catunits eq category)
          stdname = stdunits[index[0]]

       endif else begin  

          factor = facunits[test[0]]
          offset = offunits[test[0]]

          ; replace unit name with standard (e.g. 'degF'->'F')
          if (not keyword_set(no_standard)) then begin
             index = where(catunits eq category AND $
                           facunits eq factor AND $
                           offunits eq offset)
             stdname = stdunits[index[0]]
          endif

       endelse

       return
    endif 
 
    ; nope, unit not found in any category!
 
    return
end
 
 
 
