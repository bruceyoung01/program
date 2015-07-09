; $Id: add_separator.pro,v 1.1.1.1 2007/07/17 20:41:40 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        ADD_SEPARATOR
;
; PURPOSE:
;        Adds a pathname separator to the last character of
;        a file name or path name.
;
; CATEGORY:
;        General
;
; CALLING SEQUENCE:
;        NEWPATH = ADD_SEPARATOR( PATH )
;
; INPUTS:
;        PATH -> Path name to append the separator character
;             to.  If Unix, will append a "/" character.  If
;             Windows, will append a "/" character.  If 
;             Macintosh, will append a ":" character.
;
; KEYWORD PARAMETERS:
;        None    
;
; OUTPUTS:
;        NEWPATH -> Path name with separator appended to
;             the last character.
;
; SUBROUTINES:
;        None
;
; REQUIREMENTS:
;        Supports Unix, Windows, and Macintosh platforms.
;
; NOTES:
;        None
;
; EXAMPLE:
;        (1) 
;        PATH    = '/scratch/bmy'
;        NEWPATH = ADD_SEPARATOR( PATH )
;          /scratch/bmy/ 
;
;             ; Adds a separator to the path "/scratch/bmy".
;
;        (2)
;        SEP = ADD_SEPARATOR()
;        PRINT, SEP
;          /
;
;             ; Returns the default separator string
;             ; (here we have assumed a Unix environment).
;           
;
; MODIFICATION HISTORY:
;        bmy, 03 May 2002: TOOLS VERSION 1.50
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
;
;-
; Copyright (C) 1998-2007, Martin Schultz, 
; Bob Yantosca, and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of this 
; software. If this software shall be used commercially or sold as
; part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.as.harvard.edu with subject "IDL routine gamap_init"
;-----------------------------------------------------------------------


function Add_Separator, Path
   
   ; Arguments
   if ( N_Elements( Path ) ne 1 ) then Message, 'PATH not specified!'

   ; Determine path separator for operating system
   case ( StrUpCase( StrTrim( !VERSION.OS_FAMILY, 2 ) ) ) of
      'UNIX'    : Sep = '/' 
      'WINDOWS' : Sep = '\'
      'MACOS'   : Sep = ':'
      else      : Message,  '*** Operating system not supported! ***'
   endcase

   ; Trim excess spaces from PATH
   NewPath = StrTrim( Path, 2 )
  
   ; Make sure the last character of PATH is a slash
   if ( StrMid( NewPath, StrLen( NewPath ) - 1, 1 ) ne Sep ) $
      then NewPath = NewPath + Sep
 
   ; Return
   return, NewPath
end
