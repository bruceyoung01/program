; $Id: distribute.pro,v 1.1.1.1 2003/10/22 18:09:36 bmy Exp $
;-------------------------------------------------------------
;+
; NAME:
;        DISTRIBUTE
;
; PURPOSE:
;        collect all the routine names and file names that are
;        used in a given program.
;
; CATEGORY:
;        library managment routines
;
; CALLING SEQUENCE:
;        DISTRIBUTE,ROUTINENAME
;
; INPUTS:
;        ROUTINENAME --> The name of the routine to be searched.
;
; KEYWORD PARAMETERS:
;        OUTFILE --> name of an output file where the output will be saved.
;
; OUTPUTS:
;        A list of filenames with full pathnames and a list of routinenames
;        together with the filenames where they can be found.
;        Sorry, for local files, no pathname is provided.
;
; SUBROUTINES:
;
; REQUIREMENTS:
;
; NOTES:
;        Unfortunately there is no way to figure out which routines
;        really belong to a givenroutinenname, so DISTRIBUTE will always
;        return too many routinenames and filenames, including itself
;        and FILE_EXIST, as well as a couple of IDL standard library
;        routines (The latter can be left out with the keyword NO_IDL).
;        In order to get th eclosest results, run DISTRIBUTE only at the
;        start of an IDL session.
;
; EXAMPLE:
;        get all routines that belong to ITERATE.PRO:
;
;            DISTRIBUTE,'iterate'
;
;        A subsequent call with routinename 'create_master' will return
;        both, the routines for create_master and the routines for iterate.
;
; MODIFICATION HISTORY:
;        mgs, 16 Nov 1997: VERSION 1.00
;        mgs, 20 Nov 1997: - added OUTFILE and NO_IDL keywords
;
;-
; Copyright (C) 1997, Martin Schultz, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author to arrange payment.
; Bugs and comments should be directed to mgs@io.harvard.edu
; with subject "IDL routine distribute"
;-------------------------------------------------------------


pro distribute,routinename,outfile=outfile,no_idl=no_idl 
 
; first compile the routine of interest
 
     resolve_routine,routinename
 
; and all the routines called therein
 
     resolve_every
 
; then obtain information on all the routines and functions
; that are currently compiled
 
     r1 = routine_info(/source)
     r2 = routine_info(/source,/functions)
 
; seperate path and name information
 
     path = [ r1.path, r2.path ]
     name = [ r1.name, r2.name ]
 
 
; get uniq path (i.e. single files)
     si = path(sort(path))
     upath = si(uniq(si))

; open outfile if desired:
     if(keyword_set(outfile)) then $
          openw,ilun,outfile,/get_lun

; print out results (filenames and sorted routine names):
;   1. routines in local directory
     ind = where(strpos(upath,'/') lt 0)
     if (ind(0) ge 0) then $
        for i=0,n_elements(ind)-1 do begin
            print,upath(ind(i))
            if(keyword_set(outfile)) then printf,ilun,upath(ind(i))
        endfor
;   2. routines in directories that do not contain "lib" or "rsi"
     ind = where(strpos(upath,'lib') lt 0 AND strpos(upath,'rsi') lt 0 $
                 AND strpos(upath,'/') ge 0)
     if (ind(0) ge 0) then $
        for i=0,n_elements(ind)-1 do begin
            print,upath(ind(i))
            if(keyword_set(outfile)) then printf,ilun,upath(ind(i))
        endfor
;   3. routines in directories that contain "lib" but not "rsi"
     ind = where(strpos(upath,'lib') ge 0 AND strpos(upath,'rsi') lt 0 $
                 AND strpos(upath,'/') ge 0)
     if (ind(0) ge 0) then $
        for i=0,n_elements(ind)-1 do begin
            print,upath(ind(i))
            if(keyword_set(outfile)) then printf,ilun,upath(ind(i))
        endfor
;   4. routines in directories that contain "rsi"
     ind = where(strpos(upath,'rsi') ge 0 $
                 AND strpos(upath,'/') ge 0)
     if (ind(0) ge 0 and not(keyword_set(no_idl))) then $
        for i=0,n_elements(ind)-1 do begin
            print,upath(ind(i))
            if(keyword_set(outfile)) then printf,ilun,upath(ind(i))
        endfor

     if(keyword_set(outfile)) then close,ilun
     if(keyword_set(outfile)) then free_lun,ilun

 
     si = sort(name)
     print,';'
     for i=0,n_elements(path)-1 do $
         print,'; ',name(si(i)),' : ',path(si(i))
 
return
end
 
 
