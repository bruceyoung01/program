; $Id: w_calc.pro,v 1.50 2002/05/24 14:10:17 bmy v150 $

;+
; NAME:
;     w_calc
; PURPOSE:
;     creates a widget that defines a calculation that is to be
;     done lateron
;
; CATEGORY:
;   Modal widgets.
;
; CALLING SEQUENCE:
;   widget = w_calc(parent)
;
; INPUTS:
;       PARENT - The ID of the parent widget.
;
; KEYWORD PARAMETERS:
;   UVALUE - Supplies the user value for the widget.
;     VALUE  - Supplies the initial entries of the list (string array)
;
; OUTPUTS:
;       The ID of the created widget is returned.
;       And an event value field that contains necessary information on
;       the requested calculation
;
; COMMON BLOCKS:
;   None.
;
; SIDE EFFECTS:
;     AS OF 07 JULY, THIS ROUTINE MUST KNOW FUNCTION wheremissing !!
;
; PROCEDURE:
;   WIDGET_CONTROL, id, SET_VALUE=value can be used to change the
;       current value displayed by the widget.
;
;   WIDGET_CONTROL, id, GET_VALUE=var can be used to obtain the current
;       value displayed by the widget.
;
; MODIFICATION HISTORY:
;     mgs, 19 Dec 1998: - removed size specification for where... fields
;            This was necessary because they would not appear in droplist
;            mode.
;     mgs, 05 Apr 1999: - make sure all array indices are LONG
;                       - add SQRT function
;-



;-----------------------------------------------------------------------------

; ==== routines that do the actual work =====

pro handle_calc,data,header,info,label=label

common calcstr,fstr,ostr,wopstr

label = ''

; make sure name is valid and - if new - unique
if(strtrim(info.yname,2) eq '') then begin
   info.yname = 'xcalc1'
   count = 1L
   xcnum = 2
   while (count gt 0) do begin
      nindex = where(info.yname eq header, count)
      if(count gt 0) then begin
         info.yname = 'xcalc'+strtrim(xcnum,2)
         xcnum = xcnum+1
      endif
   endwhile
   nindex = -1L
endif else begin
   nindex = where(info.yname eq header, count)
   if(count ge 1) then begin
      nindex = nindex(0)
      if (not !quiet) then $
         if(widget_message('OK to overwrite '+info.yname+' ?',/cancel) $
            eq 'Cancel') then return
   endif
   if(count gt 1) then print,'*** MULTIPLE NAME *** : selected first one.'
endelse


; extract data for x1, x2 and wspec
x1 = 0
if(info.x1 ge 0) then x1 = data(info.x1,*) $
else x1 = transpose(findgen(n_elements(data(0,*))))
x2 = 0
if(info.x2 ge 0) then x2 = data(info.x2,*)
wspec = 0
if(info.wspec ge 0) then wspec = data(info.wspec,*)   $
else wspec = transpose(findgen(n_elements(data(0,*))))

; NOTE: x1, wspec ALWAYS contain n_elements(data(i,*)) elements
; x2 may be 0 if not selected !

; filter out missing data
; everything le -666 is handled as missing (that includes LOD stuff)
; ind1 = where(x1 le -666,c1)
; ind2 = where(x2 le -666,c2)
ind1 = wheremissing(x1)
if(max(ind1) ge 0) then c1 = n_elements(ind1) else c1 = 0L
ind2 = wheremissing(x2)
if(max(ind2) ge 0) then c2 = n_elements(ind2) else c2 = 0L
cind = lindgen(n_elements(data(0,*)))  ; array to hold indices of valid data
if (c1 gt 0) then cind(ind1) = -1L
if (c2 gt 0 AND info.x2 ge 0) then cind(ind2) = -1L
i = where(cind ge 0,count)
if (count gt 0) then cind = cind(i) else cind = -1L

; indw = where(wspec gt -666,wcount)    ; array with valid indices for "where"

; get indices of missing data (reverse indices of cind)
mind = lindgen(n_elements(data(0,*)))
if(count gt 0) then mind(cind) = -1L
tmpi = where(mind ge 0,c)
if (c gt 0) then mind = mind(tmpi) else mind = -1L

; copy x1 into result column
result = x1
if (c gt 0) then result(mind) = -999.99

if (count eq 0) then return ; no valid data, return array with missing values

; multiply constant c (inner scaling factor)
nind = n_elements(cind)
for i=0L,n_elements(cind)-1 do  begin
   if (i lt 0 OR i ge nind) then STOP,'CAUGHT BAD I'
   if(result(cind(i)) ne -999.99) then   $
           result(cind(i)) = result(cind(i))*info.c
endfor

; apply function (caution with arithmetic errors !!)
for i=0L,n_elements(cind)-1 do begin
   if (info.f1 eq 1) then result(cind(i)) = -result(cind(i))
   if (info.f1 eq 2) then $
      if(abs(result(cind(i))) gt 1.e-30) then $
                   result(cind(i)) = 1./result(cind(i)) $
      else result(cind(i)) = -999.99
   if (info.f1 eq 3) then $
      if(result(cind(i)) gt 1.e-30) then $
                   result(cind(i)) = alog(result(cind(i)))   $
      else result(cind(i)) = -999.99
   if (info.f1 eq 4) then $
      if(result(cind(i)) gt 1.e-30) then $
                   result(cind(i)) = alog10(result(cind(i)))   $
      else result(cind(i)) = -999.99
   if (info.f1 eq 5) then $
      if(result(cind(i)) lt 80.0 AND result(cind(i)) gt -80.0) then $
                   result(cind(i)) = exp(result(cind(i))) $
      else result(cind(i)) = -999.99
   if (info.f1 eq 7) then result(cind(i)) = fix(result(cind(i)))
   if (info.f1 eq 8) then result(cind(i)) = round(result(cind(i)))
   if (info.f1 eq 9) then $
      if(result(cind(i)) ge 0.) then $
                   result(cind(i)) = sqrt(result(cind(i))) $
      else result(cind(i)) = -999.99
endfor

if(info.f1 eq 6) then begin       ; QQNORM - special treatment
      bla = moment(result(cind))
      mean = bla(0)
      sigma = sqrt(bla(1))
; procedure: sort the data, assign actual "probability" and calculate
; the expected deviation from the mean
      tmp = result(cind)
      tmpind = sort(tmp)
      N = n_elements(tmp)
      for i=0L,n-1 do tmp(tmpind(i)) = gauss_cvf( 1.-(i+0.5)/N )
      for i=0L,n-1 do result(cind(i)) = tmp(i)
endif


; apply operator if x2 selected (watch for arithmetic errors !)
if (info.x2 ge 0) then begin
   if (info.op eq 0) then result(cind) = result(cind)+x2(cind)
   if (info.op eq 1) then result(cind) = result(cind)-x2(cind)
   if (info.op eq 2) then result(cind) = result(cind)*x2(cind)
   if (info.op eq 3) then $
      for i=0L,n_elements(cind)-1 do begin
         if(abs(x2(cind(i))) gt 1.e-30) then $
                result(cind(i)) = result(cind(i))/x2(cind(i))   $
         else result(cind(i)) = -999.99
      endfor
endif

; multiply constant (scaling factor) and add offset
for i=0L,n_elements(cind)-1 do  $
   if(result(cind(i)) ne -999.99) then   $
           result(cind(i)) = result(cind(i))*info.a + info.b

; apply selection of where statement (default : index ge 0, i.e. ALL values)
; NOTE: inverse index is calculated and respective values set to missing
; if wspec is missing, the result must be missing as well !
   if(info.wop eq 0) then indw = where(wspec ne info.wval,c)
   if(info.wop eq 1) then indw = where(wspec eq info.wval,c)
   if(info.wop eq 2) then indw = where(wspec ge info.wval,c)
   if(info.wop eq 3) then indw = where(wspec le info.wval,c)
   if(info.wop eq 4) then indw = where(wspec gt info.wval,c)
   if(info.wop eq 5) then indw = where(wspec lt info.wval,c)
   indw = [ indw, wheremissing(wspec) ]
   indw = indw(sort(indw))
   indw = indw(uniq(indw))
   if (max(indw) ge 0) then indw = indw(where(indw ge 0))

; if calculation overwrites a species, pick original values
   if (nindex ge 0 AND c gt 0) then begin
      result(indw) = data(nindex,indw)
;     indw = where(wspec le -666,c)
      indw = wheremissing(wspec)
   endif

; reset missing wspec to missing AND unfulfilled "where" if new variable
;  if (c gt 0) then result(indw) = -999.99
   if (max(indw) ge 0) then result(indw) = -999.99

; insert result into data or add a new column
if (nindex ge 0) then $  ; replace old data
   data(nindex,*) = result $
else begin
   data = [ data,result ]
   header = [ header, info.yname ]
endelse


; create string with function for logging purposes
if (info.x2 ge 0) then label = ostr(info.op)+header(info.x2)
if (info.x1 ge 0) then tmps = header(info.x1) else tmps = 'index'
if (info.c ne 1.0) then tmps = strtrim(info.c,2)+'*'+tmps
if (info.f1 gt 2) then label = fstr(info.f1)+'('+tmps+')' + label  $
else if (info.f1 gt 0) then label = fstr(info.f1)+tmps+ label  $
else label = tmps + label
if (info.a ne 1.0) then label = strtrim(info.a,2)+'*('+label+')'
if (info.b ne 0.0) then label = label+ '+' +strtrim(info.b,2)
; if a eq 0 then discard everything and only out info.b into the string
if (info.a eq 0.) then label = strtrim(info.b,2)

if (info.wspec ge 0) then tmps = header(info.wspec) else tmps = 'index'
label = label + '  where ' + tmps + ' ' + wopstr(info.wop) $
         + ' ' + strtrim(info.wval,2)
label = info.yname + ' = ' + label

return
end



pro test

FORWARD_FUNCTION w_calc

species=['NOX','O3','PAN','H2O','LAT','LON','Ozone Column']

for i = 0,n_elements(species)-1 do begin
   col = findgen(30)+i*100
   if(i eq 0) then data = transpose(col) else data=[data,transpose(col)]
endfor

repeat begin
dlg = w_calc(species=species)
   widget_control,dlg,/realize
   event = widget_event(dlg)

   if(event.value) then begin
      info = event.info
      if(info.x1 ge 0) then print,'X1:',species(info.x1)
      if(info.x2 ge 0) then print,'X2:',species(info.x2)

      handle_calc,data,species,event.info
   endif

   widget_control,event.top,/destroy


print,species
help,data

end until (event.value le 0)

return
end



; ==== the widgety stuff =====

FUNCTION xcalc_event, event

returnval = 0     ; default: behave like a procedure

; get state
stateholder = widget_info(event.handler,/child)
widget_control,stateholder,get_uvalue=state,/no_copy


if (event.id eq state.ids(0)) then begin  ; button pressed (OK or cancel)
  if(event.value eq 0) then begin
     ids = state.ids
     ltype = state.ltype
     widget_control,ids(1),get_value=yname
     if(ltype) then begin
        x1 = widget_info(ids(2),/list_select)-1
        x2 = widget_info(ids(3),/list_select)-1
        wspec = widget_info(ids(9),/list_select)-1
     endif else begin
        x1 = widget_info(ids(2),/droplist_select)-1
        x2 = widget_info(ids(3),/droplist_select)-1
        wspec = widget_info(ids(9),/droplist_select)-1
     endelse
     widget_control,ids(4),get_value=a
     widget_control,ids(5),get_value=b
     widget_control,ids(6),get_value=c
     f1 = widget_info(ids(7),/droplist_select)
     op = widget_info(ids(8),/droplist_select)
     wop = widget_info(ids(10),/droplist_select)
     widget_control,ids(11),get_value=wval

     result = { yname:yname, x1:x1, x2:x2, a:a, b:b, c:c, f1:f1, op:op, $
                wspec:wspec, wop:wop, wval:wval }
  endif else result = 0

  returnval = { id:0L, top:event.top, $
                handler:0L, value:1-event.value, info:result }
endif

; restore state
widget_control,stateholder,set_uvalue=state,/no_copy

return,returnval
end

;-----------------------------------------------------------------------------


FUNCTION w_calc, UVALUE=uval, SPECIES=species

; pass a species list that provides the possible arguments


; string constants
common calcstr,fstr,ostr,wopstr
fstr = [ 'id','-','1/','LN','LOG','EXP','QQNORM','TRUNC','ROUND','SQRT' ]
ostr = [ '+','-','*','/' ]
wopstr = [ 'eq','ne','lt','gt','le','ge' ]

  ON_ERROR, 2                   ;return to caller

    ; Defaults for keywords
  IF NOT (KEYWORD_SET(uval))  THEN uval = 0
  if (not keyword_set(species)) then title = ''

   sstr = species
   ; decide whether to use droplist or list for species
   if (n_elements(sstr) gt 25) then ltype=1 else ltype=0

   ; determine field width for species lists and numerical fields
   mw = ( max(strlen(sstr))*!d.x_ch_size+32 ) < 120
   nw = 10


   base = widget_base(/column,uvalue=uval,event_func="xcalc_event",  $
                      title='CALCULATE')

   if(ltype) then lower = widget_base(base,/row)  $
   else lower = widget_base(base,/row,ysize=80)

   y = cw_field(lower,title='Y',/column,xsize=18)

   dumbase = widget_base(lower,/column)
   dum = widget_label(dumbase,value = ' = ')
   dum = widget_label(dumbase,value = ' ')

   a = cw_field(lower,/floating,value='1.0',title='A',/column,xsize=nw)

   dumbase = widget_base(lower,/column)
   dum = widget_label(dumbase,value = '*   (')
   dum = widget_label(dumbase,value = ' ')

   dumbase = widget_base(lower,/column)
   dum = widget_label(dumbase,value = ' f ')
   f1 = widget_droplist(dumbase,value = fstr)

   c = cw_field(lower,/floating,value='1.0',title='( C ',/column,xsize=nw)

   dumbase = widget_base(lower,/column)
   dum = widget_label(dumbase,value = ' * ')
   dum = widget_label(dumbase,value = ' ')

   dumbase = widget_base(lower,/column)
   dum = widget_label(dumbase,value = ' X1 ) ')
   if(ltype) then begin
      x1 = widget_list(dumbase,value = [ 'index',sstr ],ysize=9,scr_xsize=mw)
      widget_control,x1,set_list_select=1
   endif else begin
      x1 = widget_droplist(dumbase,value = [ 'index',sstr ],scr_xsize=mw)
      widget_control,x1,set_droplist_select=1
   endelse

   dumbase = widget_base(lower,/column)
   dum = widget_label(dumbase,value = ' <OP> ')
   op = widget_droplist(dumbase,value = ostr)

   dumbase = widget_base(lower,/column)
   dum = widget_label(dumbase,value = 'X2')
   if (ltype) then begin
     x2 = widget_list(dumbase,value = [ ' ',sstr ],ysize=9,scr_xsize=mw)
     widget_control,x2,set_list_select=0
   endif else x2 = widget_droplist(dumbase,value = [ ' ',sstr ],scr_xsize=mw)

   dumbase = widget_base(lower,/column)
   dum = widget_label(dumbase,value = ')  +')
   dum = widget_label(dumbase,value = ' ')

   b = cw_field(lower,/floating,value='0.0',title='B',/column,xsize=nw)

   ; where selection field
   if(ltype) then lower = widget_base(base,/row)  $
   else lower = widget_base(base,/row,ysize=80)
   dum = widget_label(lower,value = 'where')
   if (ltype) then begin
     wspec = widget_list(lower,value = [ 'index',sstr ],ysize=9,scr_xsize=mw)
     widget_control,wspec,set_list_select=0
   endif else wspec = widget_droplist(lower,  $
                            value = [ 'index',sstr ]) ; ,scr_xsize=mw)
   wop = widget_droplist(lower,value = wopstr)
   widget_control,wop,set_droplist_select=5
   wval = cw_field(lower,/floating,value='0.0',title=' ') ; ,xsize=nw)


   ; OK and Cancel buttons
   but = cw_bgroup(base,/row,['  OK  ','Cancel'],space=10)

   ; set ids in state structure
   ids = [ but, y, x1, x2, a, b, c, f1, op, wspec, wop, wval ]
   state = { ltype:ltype, ids:ids }
   widget_control,widget_info(base,/child),set_uvalue=state,/no_copy

return,base
end


