; $Id: widget_edit.pro,v 1.50 2002/05/24 14:10:17 bmy v150 $
;-------------------------------------------------------------
;+
; NAME:
;        WIDGET_EDIT
;
; PURPOSE:
;        creates a simple text editor with an OK and Cancel button
;        and handles the events of this widget. Additional buttons 
;        can be added via keywords.
;
; CATEGORY:
;        general purpose widgets - modal widgets
;
; CALLING SEQUENCE:
;        dlg = WIDGET_EDIT(parent, [keywords])
;
; INPUTS:
;        PARENT --> widget ID of the parent widget
;
; KEYWORD PARAMETERS:
;        TITLE --> window title for the editor window (default blank)
;
;        TEXT --> initial text in the editor window (string array)
;
;        PROMPT --> a prompt string for single line text fields. If
;             this keyword is provided, the line length will be reduced
;             by the length of prompt.
;
;        YOFFSET --> position of the editor base widget.
;
;        XSIZE --> default line length o fthe input field/text window.
;             If a prompt i ssupplied, then this length will be reduced.
;             Default value is 80 characters.
;
;        LINES --> number of lines in edit line/text window. If not given,
;             the vertical extent of the text field will be determined by
;             the number of lines in TEXT (limited to 8..60). The maximum
;             limit of LINES is 60.
;
;        /NO_EDIT --> set this keyword to prevent editing of the text.
;
;        EXTRABUTTONS --> a string array with optional additional button
;             labels. OK (result=1) and Cancel (result=0) will be set
;             automatically. The extra buttons wil return values starting
;             from 2.
;
;        GROUP_LEADER --> if this widget shall be used as a simple display
;             window, you can specify a GROUP_LEADER (= widget-ID of a 
;             dialog box). The window will then disappear as soon as the
;             dialog box is closed. NOTE: the OK and Cancel buttons will
;             not be shown in this case.
;
; OUTPUTS:
;        widget_edit returns a widget ID of the editor. For implementation
;        see example below.
;
; SUBROUTINES:
;     WEDIT_EVENT --> handles editor events. Reacts only to OK or Cancel.
;
; REQUIREMENTS:
;
; NOTES:
;
; EXAMPLE:
;     create an edit dialog for a text array called comments
;     and analyze results. Overwrite array contents only if 
;     OK was pressed and a non-empty editor window is returned.
;
;     dlg = widget_edit(title='Edit comments',text=comments)
;     widget_control,dlg,/realize
;     event = widget_event(dlg)
;     if(event.value eq 1) then begin
;         newcomments = event.info
;         if (n_elements(newcomments) gt 1 OR newcomments(0) ne '') then $
;              comments = newcomments
;     endif
;     widget_control,event.top,/destroy
;
; MODIFICATION HISTORY:
;        mgs, 01 Dec 1997: VERSION 1.00
;        mgs, 21 Dec 1997: - added group_leader keyword
;        mgs, 08 Aug 1998: - added a couple of keywords, now makes
;              w_simpleedit and XDisplayfile obsolete.
;           - also handles more than one input field now if prompt 
;             is given
;        mgs, 29 Apr 1998: 
;           - now modal widget, following example in D. Fanning's
;             book, now uses xmanager internally
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
; with subject "IDL routine widget_edit"
;-------------------------------------------------------------

 
 
 
PRO wedit_event, event
 
 
  parent=event.handler

  ; Retrieve the structure from the child that contains the sub ids.
  stash = WIDGET_INFO(parent, /CHILD)
  WIDGET_CONTROL, stash, GET_UVALUE=state   ; , /NO_COPY
 

print,'Event:',event
help,state

s=size(state)
if (s(n_elements(s)-2) ne 8) then stop
 
  ; ----------------------------------
  ; button pressed ("OK" or "Cancel") 
  ; - other events will be ignored
  ; ----------------------------------
  if(event.id eq state.bID) then begin 

      ; retrieve information if button ne 1 (i.e. not CANCEL)
      if (event.value ne 1) then begin 
         nfields = state.nfields
print,'nfields:',nfields
         ; if more than one field set up text field in pointer as string array
     ;   if (nfields gt 1) then $
     ;      (*state.ptr).text = strarr(nfields)
help,state,*state.ptr,/stru
   
         for i = 0,nfields-1 do begin
            widget_control,state.textID(i),get_value=text
            ; enter text in info (ATTENTION: text may be string array if
            ; only one field is present)
            if (nfields gt 1) then $
               (*state.ptr).text(i) = text(0) $
            else begin  
               (*state.ptr) = { text:text, button:0L }
            endelse
         endfor
      endif
print,'Text:',(*state.ptr).text

      ; store button number in button field of pointer 
      ; NOTE: switch OK and Cancel (1=OK, 0=Cancel)
      value = event.value
      if (value le 1) then value = 1-value 
      (*state.ptr).button = value 
print,'button:',(*state.ptr).button

      ; if OK or Cancel was pressed, destroy dialog
      ; else notify event handler for other buttons
      if (value le 1) then  $
         widget_control,event.top,/destroy  $
      else begin
         print,'Button:',event.value
         ; Restore the state structure
         WIDGET_CONTROL, stash, SET_UVALUE=state, /NO_COPY
      endelse
  endif 
 
 

  return
 
; if (passevent) then $ 
;     return, { ID:parent, TOP:event.top, HANDLER:0L, VALUE:value ,  $
;               INFO:info  }  $
; else $
;     return,0
END
 
;-----------------------------------------------------------------------------
 
 
FUNCTION widget_edit, TITLE=title, TEXT=text, PROMPT=prompt, UVALUE=uval, $
         GROUP_LEADER=group_leader, XSIZE=xsize, $
         LINES=lines,NO_EDIT=no_edit,EXTRABUTTONS=extrabuttons
                   
 
; ON_ERROR,2                      ; return to caller
 
  ; Defaults for keywords
  IF (n_elements(uval) eq 0)  THEN uval = 0
  if (n_elements(title) eq 0) then title = ' '
  if (n_elements(text) eq 0) then text = ''
  if (n_elements(group_leader) eq 0) then group_leader = 0
  if (n_elements(xsize) eq 0) then xsize = 80

  ; position dialog at the center
  device,get_screen_size=screensize
  xcenter = fix(screensize(0)/2.)
  ycenter = fix(screensize(1)/2.)
  xoff = xcenter-150
  yoff = ycenter-150

  if (group_leader gt 0) then $      ; with a group leader, operate as modal
     base = WIDGET_BASE(TITLE=title, UVALUE = uval, $
              frame = 3, /column, XOFFSET=xoff, YOFFSET=yoff, $
              tlb_frame_attr = 0,  $
              GROUP_LEADER=group_leader, /MODAL, /FLOATING, /BASE_ALIGN_CENTER )   $
  else $                             ; top level dialog, not modal
     base = WIDGET_BASE(TITLE=title, UVALUE = uval, $
              frame = 3, /column, XOFFSET=xoff, YOFFSET=yoff, $
              tlb_frame_attr = 0 )     ; 3 ?

  ; determine width of text field if prompt is supplied
  ; and set ysize (number of lines per input field) to 1
  if (n_elements(prompt) gt 0) then begin
      xsize = xsize-1-max(strlen(prompt))
      lines = 1
  endif

  ; determine vertical size of text fields
  ; always 1 if prompts are given
  if (n_elements(lines) gt 0) then $     
      ysize = lines < 60 $
  else $ 
      ysize = (8 > n_elements(text)) < 60


  ; determine number of text fields :
  ;    1 for each entry of prompt or 1 large field
  nfields = n_elements(prompt) + (1 * (n_elements(prompt) eq 0))

  ; set up field array textf (may just have one element)
  textf = lonarr(nfields)
 
  ; make sure text array contains enough fields
  if (nfields gt 1) then begin
      if (n_elements(text) lt nfields) then $
          text = [ text, replicate('',nfields) ]
      text = text[0:nfields-1]
  endif


  ; set-up dialog box depending on whether prompt(s) are given
  if (keyword_set(NO_EDIT)) then editable=0 else editable=1 
  if (n_elements(prompt) gt 0) then begin
     for ff = 0,nfields-1 do begin

     ; insert sub-base with row alignment (needed only for prompt fields)
     subbase = WIDGET_BASE(base,/row)

     ; insert prompt label
     if (n_elements(prompt) gt 0) then begin
         promptf = widget_label(subbase,value=prompt(ff))
     endif 

     ; insert one line of text field 
     textf(ff) = widget_text(subbase,editable=editable,xsize=xsize, $
                         ysize=ysize,frame=3, $
                         scroll=0,value=text(ff))

     endfor
  endif else begin
  ; no prompt(s), simply insert one textfield but take care of 
  ; ysize and scrollbars
     if (n_elements(text) gt ysize) then scroll=1 else scroll=0
     textf(0) = widget_text(base,editable=editable,xsize=xsize, $
                         ysize=ysize,frame=3, $
                         scroll=scroll,value=text)
  endelse


  ; set up button field
  buttonnames = [' OK ',' Cancel ']

  if (n_elements(extrabuttons) gt 0) then $
        buttonnames = [ buttonnames, extrabuttons ]

; if (group_leader eq 0) then $ 
     buttons = cw_bgroup(base,/row,buttonnames) 
; else $
;    buttons = -1

  ; set OK as default button if multiple fields
  if (nfields gt 1) then $
     widget_control,base,default_button=buttons(0)

  ; create pointer to hold text information (string array) and button state
  ; make sure to initialize with safe return values (as these will be returned upon 
  ; cancel)
  ptr = ptr_new({ text:strarr(nfields), button:0L })
 
  state = { bID:buttons, nfields:nfields, textID:textf, ptr:ptr }
	; Save out the initial state structure into the first childs UVALUE.
  WIDGET_CONTROL, WIDGET_INFO(base, /CHILD), SET_UVALUE=state, /NO_COPY


  ; display the widget
  widget_control,base,/realize

  ; register widget
  xmanager,'widget_edit',base,event_handler='wedit_event'

print,'exited xmanager'

  ; getting here means widget is destroyed
  ; extract information to be returned
  info = *ptr
  ptr_free,ptr

 
  RETURN, info 
 
END
 
 
 
