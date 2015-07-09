; $Id: w_sort.pro,v 1.50 2002/05/24 14:10:17 bmy v150 $
;-------------------------------------------------------------
;+
; NAME:
;        W_SORT
;
; PURPOSE:
;     hierarchical sorting of a data set, each column can be sorted 
;     reversely. W_SORT is a widget interface for MULTISORT that handles 
;     up to three sort levels/columns.
;
; CATEGORY:
;	Modal widgets.
;
; CALLING SEQUENCE:
;	widget = w_sort(NAMES [,uval=uval])
;
; INPUTS:
;     NAMES --> a string array with variable names which will fill
;         the 3 selection lists of the W_SORTR widget.
;
; KEYWORD PARAMETERS:
;
; OUTPUTS:
;     The function returns a widget ID. 
;
; SUBROUTINES:
;     handle_sort : interpret results from widget call W_SORT and call
;         multisort procedure.
;
; REQUIREMENTS:
;     This routine requires MULTISORT.PRO in order to actually do the
;     sorting.
;
; NOTES:
;
; EXAMPLE:
;        This is how to call the sort widget:
;            dlg = w_sort(NAMES=header)   ; pass the variable names
;            widget_control,dlg,/realize
;            event = widget_event(dlg)
;            if(event.value) then begin   ; OK returned
;               info = event.info
;               handle_sort,data,event.info  ; do the sorting
;            endif
;            widget_control,event.top,/destroy
;
; MODIFICATION HISTORY:
;        mgs, 30 Jun 1997: VERSION 1.00
;        mgs, 06 Apr 1998: - improved documentation
;        mgs, 09 Apr 1998: - extracted multisort as stand-alone routine
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
; with subject "IDL routine w_sort"
;-------------------------------------------------------------
 
 
 
 
pro handle_sort,data,info

   ; handle result from widget - call multisort
 
ind = where(info.index ge 0,count)
if (count le 0) then return  ; no valid selection
 
index = info.index(ind)
revert = info.revert(ind)
 
multisort,data,index=index,revert=revert
 
return
end
 

; ----------------------------------------------------------------------  
 
; ===== and here comes the widgety stuff =====
 
FUNCTION xsort_event, event
 
returnval = 0     ; default: behave like a procedure
 
; get state
stateholder = widget_info(event.handler,/child)
widget_control,stateholder,get_uvalue=state,/no_copy
 
 
if (event.id eq state.ids(0)) then begin  ; button pressed (OK or cancel)
  if(event.value eq 0) then begin
     ids = state.ids
     ltype = state.ltype
     if(ltype) then begin
        x1 = widget_info(ids(1),/list_select)-1
        x2 = widget_info(ids(2),/list_select)-1
        x3 = widget_info(ids(3),/list_select)-1
     endif else begin
        x1 = widget_info(ids(1),/droplist_select)-1
        x2 = widget_info(ids(2),/droplist_select)-1
        x3 = widget_info(ids(3),/droplist_select)-1
     endelse
     widget_control,ids(4),get_value=r1
     widget_control,ids(5),get_value=r2
     widget_control,ids(6),get_value=r3
 
     index = [x1, x2, x3]
     revert = [r1, r2, r3 ]
     result = { index:index, revert:revert }
  endif else result = 0
 
  returnval = { id:0L, top:event.top, $
                handler:0L, value:1-event.value, info:result } 
endif
 
; restore state
widget_control,stateholder,set_uvalue=state,/no_copy
 
return,returnval
end
 
;-----------------------------------------------------------------------------
 
 
FUNCTION w_sort, NAMES, UVALUE=uval
 
; pass a NAMES list that provides the variable names
 
 
 
  ON_ERROR, 2					;return to caller
 
	; Defaults for keywords
  IF (n_elements(uval) eq 0)  THEN uval = 0
  if (n_elements(NAMES) eq 0) then title = ''
 
sstr = NAMES
; decide whether to use droplist or list for NAMES
if (n_elements(sstr) gt 25) then ltype=1 else ltype=0
sstr = [' ', sstr]
 
base = widget_base(/column,uvalue=uval,event_func="xsort_event",  $
                   title='SORT')
 
if(ltype) then lower = widget_base(base,/row)  $
else lower = widget_base(base,/row,ysize=80)
 
dumbase = widget_base(lower,/column)
dum = widget_label(dumbase,value = 'PRIMARY KEY')
if(ltype) then begin
   x1 = widget_list(dumbase,value = sstr,ysize=9)
   widget_control,x1,set_list_select=1
endif else begin
   x1 = widget_droplist(dumbase,value = sstr)
   widget_control,x1,set_droplist_select=1
endelse
r1 = cw_bgroup(dumbase,/nonexclusive,['reverse'])
 
dumbase = widget_base(lower,/column)
dum = widget_label(dumbase,value = 'SECONDARY KEY')
if(ltype) then begin
   x2 = widget_list(dumbase,value = sstr,ysize=9)
   widget_control,x1,set_list_select=1
endif else begin
   x2 = widget_droplist(dumbase,value = sstr)
   widget_control,x1,set_droplist_select=1
endelse
r2 = cw_bgroup(dumbase,/nonexclusive,['reverse'])
 
dumbase = widget_base(lower,/column)
dum = widget_label(dumbase,value = 'TERTIARY KEY')
if(ltype) then begin
   x3 = widget_list(dumbase,value = sstr,ysize=9)
   widget_control,x1,set_list_select=1
endif else begin
   x3 = widget_droplist(dumbase,value = sstr)
   widget_control,x1,set_droplist_select=1
endelse
r3 = cw_bgroup(dumbase,/nonexclusive,['reverse'])
 
 
; OK and Cancel buttons
but = cw_bgroup(base,/row,['  OK  ','Cancel'],space=10)
 
; set ids in state structure
ids = [ but, x1, x2, x3, r1, r2, r3 ]
state = { ltype:ltype, ids:ids }
widget_control,widget_info(base,/child),set_uvalue=state,/no_copy
 
return,base
end
 
 
 
 
 
