; $Id: myct_setcolor.pro,v 1.1.1.1 2003/10/22 18:09:40 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        MYCT_SETCOLOR
;
; PURPOSE:
;        Calls MYCT with default values -- convenience routine!
;
; CATEGORY:
;        Color table manipulation
;
; CALLING SEQUENCE:
;        MYCT_SETCOLOR [, Keywords ]
;
; INPUTS:
;        None
;
; KEYWORD PARAMETERS:
;        DEFAULT -> Returns to the calling program the structure of
;             MYCT defaults returned by MYCT_DEFAULTS().
;
;        /DIAL -> Set this switch to load the DIAL colortable.
; 
;        /VERBOSE -> If set, will print the number of colors defined
;             for this IDL session, plus the values of BOTTOM and
;             NCOLORS obtained from MYCT_DEFAULTS.
; 
;        _EXTRA=e -> Picks up the /GRAYSCALE and NCOLORS keywords 
;             for the MYCT_DEFAULTS function.
;
; OUTPUTS:
;        None
;
; SUBROUTINES:
;        External Subroutines Required:
;        ==============================
;        MYCT_DEFAULTS (function)   
;        MYCT
;        DIAL_CT
;
; REQUIREMENTS:
;        References routines from the TOOLS package.
;
; NOTES:
;        See comments to MYCT_DEFAULTS and MYCT for more info.       
;
; EXAMPLES:
;        (1)
;        MYCT_SETCOLOR, /GRAYSCALE, /VERBOSE, NCOLORS=200
;
;        Prints to screen:
;        % Color table      : 25
;        % Available Colors :       144
;        % Bottom for MYCT  :        18
;        % NColors for MYCT :       120
;
;             ; Calls MYCT with default grayscale table for 200 
;             ; colors and prints information to the screen.
;
;        (2)
;        MYCT_SETCOLOR, /DIAL
;
;             ; Loads DIAL LIDAR colortable with its native
;             ; number of colors (26).  
;
;
;        (3) 
;        MYCT_SETCOLOR, /DIAL, 
; 
;
; MODIFICATION HISTORY:
;        bmy, 23 Jul 2001: TOOLS VERSION 1.48
;        bmy, 27 Aug 2001: - expanded integer formats to I9; this is
;                            necessary for true-color systems
;        bmy, 26 Sep 2002: TOOLS VERSION 1.51
;                          - Now pass _EXTRA=e to MYCT
;
;-
; Copyright (C) 2001, Bob Yantosca, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author.
; Bugs and comments should be directed to bmy@io.harvard.edu
; with subject "IDL routine myct_setcolor"
;-----------------------------------------------------------------------


pro MYCT_SetColor, Default=C, Verbose=Verbose, Dial=Dial, _EXTRA=e
 
   ; We can't set colors for NULL devices!
   if ( !D.NAME ne 'NULL' ) then begin
 
      ; Get a structure of default values for MYCT
      C = MYCT_Defaults( _EXTRA=e )
    
      ;=================================================================
      ; Call MYCT to load a colortable
      ;=================================================================
      if ( Keyword_Set( Dial ) ) then begin
         
         ; Load DIAL/LIDAR colortable
         MyCT, /Dial, _EXTRA=e

         ; Save table name for printout
         Table = 'DIAL/LIDAR'

      endif else begin

         ; Load an IDL colortable w/ default values
         MyCT, C.TABLE,    $
            Bottom=C.BOTTOM, NColors=C.NCOLORS, $
            Range=C.RANGE, Reverse=C.REVERSE, Sat=C.SAT,    $
            Value=C.VALUE, _EXTRA=e

         ; Save table name for printout
         Table = StrTrim( String( Fix( C.TABLE ) ), 2 )

      endelse

      ;=================================================================
      ; If /VERBOSE is set, then echo info about the color table
      ;=================================================================
      if ( Keyword_Set( Verbose ) ) then begin
         Print, Table, Format='(''% Color table      : '', a)'

         Print, StrTrim( String( Long( !D.N_COLORS ) ), 2 ), $
            Format='(''% Available Colors : '', a)'

         Print, StrTrim( String( Long( C.Bottom ) ), 2 ), $
            Format='(''% Bottom for MYCT  : '', a)'

         Print, StrTrim( String( Long( C.NColors ) ), 2 ), $
            Format='(''% NColors for MYCT : '', a)'
      endif

   endif
 
   ; Return to calling program
   return
end
