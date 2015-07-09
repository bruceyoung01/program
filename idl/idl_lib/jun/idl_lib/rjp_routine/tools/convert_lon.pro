; $Id: convert_lon.pro,v 1.1.1.1 2003/10/22 18:09:41 bmy Exp $
;-------------------------------------------------------------
;+
; NAME:
;        CONVERT_LON
;
; PURPOSE:
;        Convert longitudes from -180..180 to 0..360 or vice 
;        versa.
;
; CATEGORY:
;        Tools
;
; CALLING SEQUENCE:
;        CONVERT_LON,data,names,Pacific=Pacific,Atlantic=Atlantic, $
;                 minval=minval
;
; INPUTS:
;        DATA -> A data array (lines,vars) or vector containing 
;            longitude data. If DATA is a 2D array, the NAMES
;            parameter must be given to identify the LONgitude variable.
;
;        NAMES -> A string list of variable names. The longitude data
;            must be labeled 'LON', unless specified with the LONNAME
;            keyword. The NAMES parameter is not needed, if a data
;            vector is passed.
;
; KEYWORD PARAMETERS:
;        PACIFIC -> Convert longitudes from -180..180 to 0..360
;
;        ATLANTIC -> Convert from 0..360 to -180..180
;
;        LONNAME -> Name of the longitude variable if a name other
;            than 'LON' is used.
;
; OUTPUTS:
;        The longitude column in the data array will be changed.
;
; SUBROUTINES:
;
; REQUIREMENTS:
;
; NOTES:
;
; EXAMPLE:
;        londat = [ -180.,-179.,-0.1,0.1,179.,180.,270.,359.]
;        CONVERT_LON,londat,/Pacific
;        print,londat
;
;        CONVERT_LON,londat,/Atlantic
;        print,londat
;
; MODIFICATION HISTORY:
;        mgs, 25 Aug 1998: VERSION 1.00
;        mgs, 19 May 1999: - now makes sure that longitude range does
;                            not exceed -180..180 or 0..360
;        mgs, 24 Jun 1999: - bug fix: choked at missing values 
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
; with subject "IDL routine convert_lon"
;-------------------------------------------------------------


pro convert_lon,data,names,pacific=pacific,atlantic=atlantic, $
       lonname=lonname,min_valid=min_valid
 
 
 
    if (n_elements(min_valid) ne 1) then min_valid = -999.98
 
    if (n_elements(lonname) eq 0) then lonname = 'LON'

    if (n_elements(data) lt 2) then return

    ; get size information of data and find LON column
    s = size(data)
    if (s[0] eq 1) then ind = 0  $    ; data is vector
    else begin 
       ; Find LON variable
       ind = where(strupcase(names) eq lonname)
       if (ind[0] lt 0) then begin
          print,'*** CONVERT_LON: Cannot find ',lonname,' in data set!'
          return
       endif
    endelse


    ; Atlantic: Convert longitudes greater 180 by subtracting 360
    ; also add N*360 to longitude values less than -180
    if (keyword_set(Atlantic)) then begin
        repeat begin
           lon = data[*,ind[0]]
           index = where(lon gt 180.,count)
           if (index[0] ge 0) then data[index,ind[0]] = lon[index]-360.
        endrep until(count eq 0) 
        repeat begin
           lon = data[*,ind[0]]
           index = where(lon ge min_valid AND lon lt -180.,COUNT)
           if (index[0] ge 0) then data[index,ind[0]] = lon[index]+360.
        endrep until(count eq 0) 
    endif
 
    ; Pacific: convert negative longitudes by adding 360
    ; also subtract N*360 for longitude values greater than 360
    if (keyword_set(Pacific)) then begin
        repeat begin
           lon = data[*,ind[0]]
           index = where(lon ge min_valid AND lon lt 0.,COUNT)
           if (index[0] ge 0) then data[index,ind[0]] = lon[index]+360.
        endrep until(count eq 0)
        repeat begin
           lon = data[*,ind[0]]
           index = where(lon gt 360., count)
           if (index[0] ge 0) then data[index,ind[0]] = lon[index]-360.
        endrep until(count eq 0)
    endif
 
    return
end
 
