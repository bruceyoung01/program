; $Id: choice.pro,v 1.1.1.1 2007/07/17 20:41:40 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        CHOICE
;
; PURPOSE:
;        Allows user to choose interactively from several options.
;
; CATEGORY:
;        General
;
; CALLING SEQUENCE:
;        RESULT = CHOICE( VALUES [,options] )
;
; INPUTS:
;        VALUES  -> a string array containing the selectable options
;
; KEYWORD PARAMETERS:
;        TITLE -> title to be displayed on top of the selection menu
;
;        DEFAULT -> a default selection (to allow user to simply 
;             press enter)
;
;        BY_INDEX  -> return selection index rather than value
;
;        /NOABORT -> prevents addition of 'ABORT' to selection
;
; OUTPUTS:
;        CHOICE returns a string containing the selected value or
;            the index of the selection if keyword /BY_INDEX is set.
;
; SUBROUTINES:
;        None
;
; REQUIREMENTS:
;        None
;
; NOTES:
;        CHOICE automatically adds 'ABORT' to the list of selections.
;        If keyword BY_INDEX is set then ABORT will return -1
;        (unless /NOABORT keyword is set)
;
; EXAMPLE:
;        DIRNAMES = [ '~my/dir/','~your/dir/','~any/dir']
;        DIR      = CHOICE( DIRNAMES, TITLE='Select Directory' )
;
;        IF (DIR ne 'ABORT') THEN BEGIN
;            OPENR, U1, DIR+FILE, /GET_LUN
;            READF, U1, DATA
;            CLOSE, U1
;            FREE_LUN,U1
;        ENDIF ELSE PRINT,'ABORTED !'
;
;             ; Allow user to pick a directory and then
;             ; read a file from that directory.
;
; MODIFICATION HISTORY:
;        mgs, 26 Sep 1997: VERSION 1.00
;        mgs, 17 Nov 1998: - added DEFAULT and NOABORT keywords
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
; or phs@io.harvard.edu with subject "IDL routine choice"
;-------------------------------------------------------------


function choice,values,title=title,default=default,by_index=by_index, $
          noabort=noabort

 
;=============================================================================
;  Check for errors and initialize some local variables
;=============================================================================
	on_error, 2
 
	chosen = -1

      if (n_elements(values) le 0) then begin
          print,'CHOICE must be given some values !'
          return,chosen
      endif

      if (not keyword_set(title)) then title = 'Selection Menu'

; make a backup copy of values and add 'ABORT' option to the end   
      selvals = values
      if (not keyword_set(NOABORT)) then selvals = [ selvals, 'ABORT' ]

      ; add default indicator
      if (n_elements(default) gt 0) then begin
         default = fix(default[0])
         if (default ge 0 AND default lt n_elements(selvals)) then $
            selvals[default] = selvals[default] + ' <---  Default'
      endif

; display menu (loop) 
directory_menu:
      on_ioerror,null

	print 
	print, title
	print, '---------------------'
      for i=0,n_elements(selvals)-1 do   $
	    print, string(i,format='(i3)'),' = ',selvals(i)
      print
      choicestr = ''
	read, choicestr, prompt='Your Choice ==> '
      if (choicestr eq '') then begin
         if (n_elements(default) gt 0) then $
            choicestr = string(default) $
         else $
            choicestr = '0'    ; first item as auto-default
      endif
       
      on_ioerror,directory_menu 
      chosen = fix(choicestr) 

;=============================================================================
; Make sure CHOICE is a valid selection
;=============================================================================
      if (chosen lt 0 OR chosen ge n_elements(selvals)) then begin
	   print, 'Invalid selection...please choose again'
	   goto, directory_menu
	endif

;=============================================================================
; Return the selection (value or index) the user has chosen
;=============================================================================
      if (not keyword_set(by_index)) then   $
          return,selvals(chosen)  $
      else begin
          if (chosen eq n_elements(values) AND not keyword_set(NOABORT)) then $
             return,-1  $   ; aborted
          else return,chosen
      endelse
 
end

