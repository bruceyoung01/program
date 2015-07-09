; $Id: struaddvar.pro,v 1.1.1.1 2007/07/17 20:41:35 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        STRUADDVAR (function)
;
; PURPOSE:
;        Add additional variables (tags) to an exisiting
;        structure. The new variables will be inserted after
;        the old ones, '__' tags will be appended at the end.
;        The function renames new tags if they would cause 
;        duplicate names by adding a '_A'.
;
; CATEGORY:
;        Structures
;
; CALLING SEQUENCE:
;        NEWSTRU = STRUADDVAR( OLDSTRU, NEWVAR [, NEWNAME, Keywords ] )
;
; INPUTS:
;        OLDSTRU -> the exisiting structure. This must be a structure, 
;             otherwise the program will complain and exit.
;
;        NEWVAR -> A new variable (any type) or a new structure
;             that shall be incorporated into OLDSTRU. If NEWVAR
;             is *not* a structure, then NEWNAME must be present.
;             If you want to add an array with several named columns,
;             use Arr2Stru first.
;
;        NEWNAME -> The name of the new variable. Only used if 
;             NEWVAR is no structure.
;
; KEYWORD PARAMETERS:
;        /WARNNELEMENTS -> If this flag is set,  the program will print out 
;             a warning if the number of elements in the new variable does 
;             not match the number of elements in the last variable of the 
;             old structure.
;
; OUTPUTS:
;        NEWSTRU -> A structure that combines the information from 
;             OLDSTRU and NEWVAR.
;
; SUBROUTINES:
;        External Subroutines Required:
;        ==============================
;        CHKSTRU (function)
; 
;
; REQUIREMENTS:
;        None
;
; NOTES:
;        (1) NEWNAME (or the tag names from NEWVAR) will be added to 
;            the __NAMES__ tag if present. __EXTRA__ entries will be 
;            combined only if tags within __EXTRA__ structures are 
;            different.  If __EXTRA__ contains a non-structure
;            variable it will be converted to a structure with tag 
;            name 'EXTRA_N' where N is a number from 1-9, A-Z (the 
;            first tag is just 'EXTRA').
;
; EXAMPLES:
;        (1)
;        NSTRU = STRUADDVAR( STRU, FINDGEN(100), 'DUMMY' )
;
;             ; Adds a 100 element floating-point array
;             ; to structure STRU under the tag name "DUMMY"
;             ; and returns the result as NSTRU.
;
;        (2) 
;
;        X     = { A :0L,             B:STRARR(10),     $
;                  C : FINDGEN(100),  __EXTRA__:'TEST' }
;        OSTRU = STRUADDVAR( NSTRU, X )
;
;             ; Adds the structure X (with tag names A, B, C, and
;             ; __EXTRA__) to the structure NSTRU and returns
;             ; the result as OSTRU. 
;            
;
; MODIFICATION HISTORY:
;        mgs, 03 May 1999: VERSION 1.00
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
;
;-
; Copyright (C) 1999-2007, Martin Schultz,
; Bob Yantosca and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of 
; this software. If this software shall be used commercially or 
; sold as part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.harvard.edu with subject "IDL routine struaddvar"
;-----------------------------------------------------------------------


function StruAddVar_SecureName,namelist,item,numbers=numbers
 
   ; make sure new name is unique
   result = item
   impossible = 0
   achar = 65B  ; 'A'
   if (keyword_set(numbers)) then achar = 49B
 
   repeat begin
      ind = where(strupcase(namelist) eq strupcase(result))
      if (ind[0] ge 0) then begin
         result = item + '_' + string(achar)
         achar = achar+1B
         if (achar eq 58B) then achar = 65B    ; jump from 9 to A
         if (achar gt 96B) then impossible = 1 
      endif
   end until (ind[0] lt 0 OR impossible)
 
   if (impossible) then $
      message,'Canot find unique name for '+item+' !'
 
   return,result
end

 
 
function StruAddVar, stru, newvar, newname, WarnNElements=WarnNElements
 
   ; add a new variable (or a structure with new variables) to an exisiting
   ; structure. 
   ; If newvar is itself a structure, all tags will be appended
 
   ; If the old structure has a __NAMES__ tag, the new variable name(s) will 
   ; be added to it.
 
   ; If both the old and the new structure have an __EXTRA__ tag, these
   ; will be combined.
 
   FORWARD_FUNCTION ChkStru
 
   ; In case of an error, stru is returned unchanged
   if (not ChkStru(stru)) then begin
      message,'Argument is not a structure!',/Continue
      return, stru
   endif
 
   if (n_elements(newvar) eq 0) then begin
      message,'Nothing to add!',/Continue
      return, stru
   endif
 
 
   ; Test if new variable is in itself a structure
   IsNewStru = ChkStru(newvar)
 
   ; If no new name(s) are given:
   ; - if newvar is not a structure, you must supply names
   ; - if it is a structure, take the structure tags as names
   if (n_elements(newname) eq 0) then begin
      if (not IsNewStru) then begin
         message,'NewVar must be structure if no name is given!',/Continue
         return, stru
      endif else begin
         newname = Tag_Names(newvar)
         newname = newname [ where( strpos(newname,'__') lt 0 ) ] ; take only valid variable names
      endelse
   endif
 
 
   ; rebuild structure. Loop through tags of old structure until name
   ; starts with '__'. Insert new stuff here, then append the rest.
 
   ntags = N_Tags(stru)
   TagNames = [ Tag_Names(stru), '' ]  ; add extra name as dummy
   result = create_struct( TagNames[0], stru.(0) )
 
   if (IsNewStru) then begin
      NewNTags = N_Tags(newvar)
      NewTagNames = Tag_Names(newvar)
   endif
 
   already_inserted = 0
 
   for i=1,ntags do begin
      ; select operation mode
select_mode:
      mode = 0  ; simple append  (1 = insert new stuff, 2 = handle __NAMES__, 3 = handle __EXTRA__)
      if ( StrMid(TagNames[i],0,2) eq '__'  OR i eq ntags) then begin
         if (not already_inserted) then  $
            mode = 1  $
         else begin
            if (i eq ntags) then goto,done_with_it
            if (TagNames[i] eq '__NAMES__') then mode = 2
            if (TagNames[i] eq '__EXTRA__' AND IsNewStru) then mode = 3
         endelse
      endif else $
         mode = 0
 
      case (mode) of
         0 : result = create_struct( result, TagNames[i], stru.(i) )
 
         1 : begin
                ; find out number of elements of last tag
                nrows = n_elements( result.(n_tags(result)-1) )
 
                if (IsNewStru) then begin
                ; if newvar is a structure: loop through and append anything 
                ; that does not start with '__'
                   for j=0,NewNTags-1 do begin 
                      if (strmid(NewTagNames[j],0,2) ne '__') then begin
                         item = StruAddVar_SecureName(Tag_Names(result),NewTagNames[j])
                         result = create_struct(result, item, newvar.(j) )
                         if (keyword_set(WarnNElements) AND nrows ne N_Elements(newvar.(j)) ) then $
                            message,'WARNING! number of elements of '+NewTagNames[j]+ $
                                    ' does not match old structure!',/INFO
                      endif
                   endfor
                endif else begin
                ; newvar is a single item 
                ; NOTE: if you want to add an aray, use arr2stru first and add the result
                    item = StruAddVar_SecureName(Tag_Names(result),newname[0])
                    result = create_struct(result, item, newvar) 
                    if (keyword_set(WarnNElements) AND nrows ne N_Elements(newvar) ) then $
                       message,'WARNING! number of elements of '+NewName+ $
                               ' does not match old structure!',/INFO
                endelse
 
                ; now need to see what  the '__' tag was that we just found
                already_inserted = 1
                goto,select_mode
             end
 
         2 : begin  
                ind = where(strmid(newname,0,2) ne '__')
                if (ind[0] ge 0) then $
                   names = [ stru.(i), newname[ where(strmid(newname,0,2) ne '__') ]  ] $
                else $
                   names = stru.(i)
                result = create_struct( result, '__NAMES__', names )
             end
 
         3 : begin
                extra = stru.(i)
                ; if newvar does have no extra block, simply append old extra block
                ; else merge them together
                ep = where(NewTagNames eq '__EXTRA__',count)
                if (count eq 1) then begin
                   ; first need to make sure that both __EXTRA__ tags are structures
                   if (not ChkStru(extra)) then extra = create_struct( 'EXTRA', extra )
                   etags = Tag_Names(extra)
                   tmpname = StruAddVar_SecureName(etags, 'EXTRA', /numbers )
                   tmp = newvar.(ep[0])
                   if (not ChkStru(tmp)) then tmp = create_struct( tmpname, tmp )
                   ; NOTE : could still crash here if both __EXTRA__ tags are structures and 
                   ; contain identical tags. That's why we have to loop. For __EXTRA__ assume
                   ; that we have identical information if tags are the same
                   tmptagnames = Tag_Names(tmp)
                   for j=0,N_Tags(tmp)-1 do begin
                      ind = where(Tag_Names(extra) eq tmptagnames[j],count)
                      if (count eq 0) then $
                         extra = create_struct( extra, tmptagnames[j], tmp.(j) )
                   endfor
                endif
                result = create_struct( result, '__EXTRA__', extra )
             end
      endcase

done_with_it:
   endfor
 
   ; finally add additional '__' tags from newvar if it is a structure
   if (IsNewStru) then begin
      for j=0,NewNTags-1 do begin
          if (strmid(NewTagNames[j],0,2) eq '__' AND $
              NewTagNames[j] ne '__NAMES__' AND $
              NewTagNames[j] ne '__EXTRA__' ) then begin
                 item = StruAddVar_SecureName(Tag_Names(result),NewTagNames[j])
                 result = create_struct(result, item, newvar.(j) )
          endif
      endfor
   endif
 
   return,result
end
 
