; $Id: ctm_sum.pro,v 1.2 2005/03/24 18:03:12 bmy Exp $
;-------------------------------------------------------------
;+
; NAME:
;        CTM_SUM
;
; PURPOSE:
;        Calculate the sum of several CTM output data blocks
;        and store them in a new datainfo structure as "derived 
;        data". The user can select data blocks by diagnostics,
;        tracer, tau0, or logical unit of the source file. With the
;        AVERAGE keyword averages will be computed instead of
;        totals.
;
; CATEGORY:
;        CTM tools
;
; CALLING SEQUENCE:
;        CTM_SUM [,diagn] [,keywords]
;
; INPUTS:
;        DIAGN -> the diagnostic name or number (e.g. 'IJ-AVG-$')
;
; KEYWORD PARAMETERS:
;        TRACER -> tracer number(s) to look for.
;
;        TAU0 -> beginning of time step to look for. You can
;            specify a date using function nymd2tau(YYMMDD,HHMMSS)
;
;        ILUN -> If you want to restrict summation to datablocks from
;            one particular file, set the ILUN keyword to the 
;            respective logical unit number.
;
;        NEWTRACER -> Tracer number for the new tracer. Default is 
;            to use the same number as the tracer in the first 
;            selected data block.
;
;        NEWTAU0 -> A new pair of values for the time stamp. Default 
;            is to use the minimum tau0 and maximum tau1 from the 
;            selected data blocks. If only one value is passed (tau0),
;            then tau1 will be set to tau0+1.
;
;        /AVERAGE -> set this keyword to compute a (simple) average
;            instead of the total.
;
; OUTPUTS:
;        This routne produces no output but stores a new datainfo 
;        and fileinfo structure into the global arrays.
;
; SUBROUTINES:
;        none.
;
; REQUIREMENTS:
;        uses gamap_cmn, ctm_get_data, ctm_grid, and ctm_make_datainfo
;
; NOTES:
;        All data blocks must originate from compatible models.
;        No test can be made whether an identical addition had been
;        performed earlier. Hence, it is a good idea to test the
;        existence of the "target" record before in order to avoid 
;        duplicates.
;
; EXAMPLE:
;        ; Add individual CH3I tracers for 03/01/1994 and store them
;        ; as total CH3I concentration. 
;        ; But first: test!
;        ctm_get_data,datainfo,'IJ-AVG-$',tracer=70,tau0=nymd2tau(940301L)
;        if (n_elements(datainfo) eq 0) then $
;           ctm_sum,'IJ-AVG-$',tracer=[71,72,73,74,75],  $
;              tau0=nymd2tau(940301L),newtracer=70
;
;        ; Compute annual averages from monthly means for Ox
;        ctm_sum,'IJ-AG-$',tracer=2,/AVERAGE 
;
; MODIFICATION HISTORY:
;        mgs, 18 May 1999: VERSION 1.00
;
;-
; Copyright (C) 1999, Martin Schultz, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author to arrange payment.
; Bugs and comments should be directed to mgs@io.harvard.edu
; with subject "IDL routine ctm_sum"
;-------------------------------------------------------------


pro ctm_sum,diagn,tracer=tracer,tau0=tau0,ilun=ilun,  $
            newtracer=newtracer,newtau=newtau,  $
            average=average
 
; computes sum of all selected data sets and stores it as a new
; datainfo entry
 
 
; **** primitive version, NO ERROR CHECKS !! ****
@gamap_cmn
 
   ctm_get_data,datainfo,diagn,tracer=tracer,tau0=tau0,ilun=ilun
 
   if (n_elements(datainfo) eq 0) then begin
       message,'No matching records found!',/Continue
       return
   endif
 
;### Debug output
;help,datainfo,/stru
;print,datainfo.tracer
;print,datainfo.category
;print,datainfo.tau0
 
   sum = *(datainfo[0].data)
   for i=1,n_elements(datainfo)-1 do $
      sum = sum + *(datainfo[i].data)
 
 
   if (keyword_set(average)) then sum = sum/float(n_elements(datainfo))
 
 
   if (n_elements(newtracer) eq 0) then  $
       newtracer = datainfo[0].tracer
   if (n_elements(newtau) eq 0) then   $
       newtau = [ min(datainfo.tau0), max(datainfo.tau1) ]
 
   if (n_elements(newtau) eq 1) then   $
       newtau = [ newtau, newtau+1 ]
 
 
   fileinfo = *pGlobalFileInfo
   ind = where(fileinfo.ilun eq datainfo[0].ilun)
   model = fileinfo[ind[0]].modelinfo
   if ( ptr_valid(fileinfo[ind[0]].gridinfo) ) then $
      grid  = *(fileinfo[ind[0]].gridinfo)  $
   else  $
      grid = ctm_grid(model)
 
   result = ctm_make_datainfo( sum,newd,newf, $
                    model=model,grid=grid,  $
                    diagn=datainfo[0].category, $
                    tracer=newtracer,  $
                    tau0=newtau[0],tau1=newtau[1], $
                    unit=datainfo[0].unit,  $
                    dim=datainfo[0].dim,  $
                    first=datainfo[0].first )
 
   if (result) then $
       message,'Successfully added selected datablocks.',/INFO  $
   else begin
       message,'Something went wrong! STOP.',/Cont
       stop
   endelse
 
 
 
return
end
 
