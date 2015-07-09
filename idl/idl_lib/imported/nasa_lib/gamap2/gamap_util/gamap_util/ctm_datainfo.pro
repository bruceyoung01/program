; $Id: ctm_datainfo.pro,v 1.1.1.1 2007/07/17 20:41:24 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        CTM_DATAINFO  (function)
;
; PURPOSE:
;        Return information about available categories, tracers or 
;        time steps in either a given or the global datainfo structure 
;        array.
;
; CATEGORY:
;        GAMAP Utilities, Structures
;
; CALLING SEQUENCE:
;        RESULT = CTM_DATAINFO( [DIAGN] [,DATAINFO] [,keywords] )
;
; INPUTS:
;        DIAGN -> A diagnostic number or category name for which
;             information shall be returned on available tracers 
;             or time steps. If not given, CTM_DATAINFO returns
;             information about all available diagnostics instead.
; 
;        DATAINFO -> An optional subset of the global DataInfo 
;             structure array. If given, the search will be 
;             restricted to the data records contained in DATAINFO.
;
; KEYWORD PARAMETERS:
;        /TRACER -> If set, CTM_DATAINFO returns all tracer numbers
;             that are available with the given diagnostics. This
;             keyword has no effect if no DIAGN is given.
;
;        /TAU0 -> Returns information about all available time steps
;             for a given diagnostics. This keyword has no effect if
;             either DIAGN is not given or /TRACER is set.
;    
;        /TAU1 -> Same as TAU0, but for the end of the time step.
;
;        If none of these keywords is set, CTM_DATAINFO returns the
;        index values for the DATAINFO structure array that match
;        the requested diagnostics.
;
;        STATUS -> restrict search to: 0=unread data, 1=read data.
;             Default is 2=no restriction
;
;        /EXPAND -> For multilevel diagnostics, CTM_DATAINFO normally
;             returns only the template (with the '$' character). Use
;             this keyword to get all individual levels as well.
;
; OUTPUTS:
;        Depending on the keywords and the DIAGN parameter, an array
;        with diagmostics numbers, index values, tracer numbers, or 
;        time steps is returned. 
;
; SUBROUTINES:
;        External Subroutines Required:
;        ====================================
;        CTM_SELECT_DATA, CTM_DIAGINFO
;
; REQUIREMENTS:
;        None
;
; NOTES:
;        None
;
; EXAMPLE:
;        ; Must read in some data first
;        CTM_GET_DATA, 'IJ-AVG-$', TRACER=1, FILE=''
;
;        ; print all tracers that are available for diag IJ-AVG-$
;        PRINT, CTM_DATAINFO( 'IJ-AVG-$', /TRACER )
;
;        ; print all time step endings for diagnostics IJ-AVG-$
;        PRINT, CTM_DATAINFO( 'IJ-AVG-$', /TAU0 )
;
;        ; print all diagnostics that are available in the file
;        ; (or in all files previously read)
;        PRINT, CTM_DATAINFO()
;
;        ; print all record indices for diagnostics IJ-AVG_$
;        PRINT, CTM_DATAINFO( 'IJ-AVG-$' )
;
; MODIFICATION HISTORY:
;        mgs, 07 Oct 1998: VERSION 1.00
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
;
;-
; Copyright (C) 1998-2007, Martin Schultz,
; Bob Yantosca and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of 
; this software. If this software shall be used commercially or 
; sold as part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.harvard.edu with subject "IDL routine ctm_datainfo"
;-----------------------------------------------------------------------


function ctm_datainfo,diagn,datainfo,tracer=tracer,tau0=tau0,tau1=tau1, $
           status=status,expand=expand
 
 
@gamap_cmn
 
    ; returns available information in datainfo
    if (n_elements(status) eq 0) then status = 2   ; return info about 
                                                   ; all parsed items

    ; Make sure we have some datainfo structure array
    if (n_elements(datainfo) eq 0) then $
          if (ptr_valid(pGlobalDataInfo)) then datainfo = *pGlobalDataInfo $
          else begin
              message,'No data has been read previously.',/Cont
              return,-1L
          endelse



    ; ================================================================ 
    ; handle case with no diagn seperately
    ; ================================================================ 
   
    if (n_elements(diagn) eq 0) then begin
        cats = datainfo.category

        ; filter out individual levels for multilevel diagnostics
        catindex = -1L
        if (not keyword_set(EXPAND)) then begin
            for i=0,n_elements(cats)-1 do begin
               ; check if category name is generic
               ctm_diaginfo,cats[i],index=tmp

               ; if not, it could still be a multilevel diagnostic
               ; which has not been read. Check for the 1st level
               if (tmp[0] lt 0) then begin
                   p = strpos(cats[i],'1')
                   if (p ge 0) then begin
                      cats[i] = strmid(cats[i],0,p)+'$'+  $
                                strmid(cats[i],p+1,255)
                      ctm_diaginfo,cats[i],index=tmp
                   endif
               endif

               ; add diagnostics number to list
               ; (-1 indicates not generic diagnostics!)
               catindex = [ catindex,tmp ]
            endfor

            ; remove first dummy value and get all generic diagnostics
            catindex = catindex[1:*]
            ok = where(catindex ge 0)
            if (ok[0] ge 0) then cats = cats[ok] $
            else return,-1L
        endif

        ; get unique elements
        ucats = cats(uniq(cats,sort(cats)))
  
        return,ucats
    endif 


    ; ================================================================ 
    ; if diagn is given, call ctm_select_data and extract unique values
    ; ================================================================ 

    index = ctm_select_data(diagn,datainfo,status=status)
 
    if (index[0] lt 0) then return,-1L
 
    if (DEBUG) then print,strtrim(n_elements(index),2),' data blocks found.'
 
help,datainfo
 
    if (keyword_set(tracer)) then begin
        result = datainfo[index].tracer
 
    endif else if (keyword_set(tau0)) then begin
        result = datainfo[index].tau0
 
    endif else if (keyword_set(tau1)) then begin
        result = datainfo[index].tau1
 
    endif else return,index    
 
    ; extract unique quantities
    ures = result(uniq(result,sort(result)))
 
    return,ures
 
end
 
