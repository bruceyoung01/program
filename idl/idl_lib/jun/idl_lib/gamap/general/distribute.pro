; $Id: distribute.pro,v 1.1.1.1 2007/07/17 20:41:40 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        DISTRIBUTE
;
; PURPOSE:
;        Collect all the routine names and file names that are
;        used in a given program.
;
; CATEGORY:
;        General
;
; CALLING SEQUENCE:
;        DISTRIBUTE [, ROUTINENAME ]
;
; INPUTS:
;        ROUTINENAME -> (OPTIONAL) The name of the routine to be 
;             searched.  If omitted, then the user will be prompted
;             to supply a file name via a dialog box.
;
; KEYWORD PARAMETERS:
;        OUTFILE -> Name of file where output will be sent.  If
;             OUTFILE is omitted then DISTRIBUTE will print the
;             information to the screen.
;
;        /NO_IDL -> Set this switch to exclude IDL library routines
;             from the search process.
;
; OUTPUTS:
;        A list of filenames with full pathnames and a list of 
;        routinenames together with the filenames where they can 
;        be found.  Sorry, for local files, no pathname is provided.
;
; SUBROUTINES:
;        External Subroutines Required:
;        ===============================
;        OPEN_FILE
;
; REQUIREMENTS:
;        Requires routines from the TOOLS package.
;
; NOTES:
;        Unfortunately there is no way to figure out which routines
;        really belong to a given ROUTINENNAME, so DISTRIBUTE will 
;        always return too many routinenames and filenames, including 
;        itself and FILE_EXIST, as well as a couple of IDL standard 
;        library routines (The latter can be left out with the keyword 
;        NO_IDL).  In order to get the closest results, run DISTRIBUTE 
;        only at the start of an IDL session.
;
; EXAMPLE:
;        DISTRIBUTE, 'iterate'
;        
;             ; Get all routines that belong to "iterate.pro". 
;             ; A subsequent call with routinename 'create_master' 
;             ; will return both, the routines for "create_master.pro" 
;             ; and the routines for "iterate.pro".
;
; MODIFICATION HISTORY:
;        mgs, 16 Nov 1997: VERSION 1.00
;        mgs, 20 Nov 1997: - added OUTFILE and NO_IDL keywords
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
;                          - Now use IDL routine RESOLVE_ALL
;                          - Now use OPEN_FILE instead of OPENW
;                          - Updated comments, cosmetic changes
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
; or phs@io.harvard.edu with subject "IDL routine distribute"
;-----------------------------------------------------------------------


pro Distribute, RoutineName, OutFile=OutFile, No_IDL=No_IDL 
 
   ;====================================================================
   ; Initialization
   ;====================================================================

   ; Keywords
   Do_Write = ( N_Elements( OutFile ) gt 0 )
   Do_IDL   = 1L - Keyword_Set( No_IDL )

   ; First compile the routine of interest
   Resolve_Routine, RoutineName
 
   ; And all the routines called therein
   Resolve_All

   ; Then obtain information on all the routines and functions
   ; that are currently compiled
   R1    = Routine_Info( /Source             )
   R2    = Routine_Info( /Source, /Functions )
 
   ; Separate path and name information
   Path  = [ R1.Path, R2.Path ]
   Name  = [ R1.Name, R2.Name ]
 
   ; Get uniq path (i.e. single files)
   Si    = Path( Sort( Path ) )
   UPath = Si( Uniq( Si ) )

   ; Open outfile if desired
   if ( Do_Write ) then Open_File, OutFile, Ilun, /Get_LUN, /Write

   ;====================================================================
   ; Print out results (filenames and sorted routine names):
   ; 
   ; First print the path, then print the name and path
   ;====================================================================

   ;---------------------------------------
   ; (1) Routines in local directory
   ;---------------------------------------
   Ind = Where( StrPos( UPath, '/' ) lt 0 )

   if ( Ind[0] ge 0 ) then begin
      for I = 0L, N_Elements( Ind )-1L do begin
         Print, UPath( Ind[I] )
         if( Do_Write ) then PrintF, Ilun, UPath( Ind[I] )
      endfor
   endif

   ;---------------------------------------
   ; (2) Routines in directories that 
   ;     do not contain "lib" or "rsi"
   ;---------------------------------------
   Ind = Where( StrPos( UPath, 'lib' ) lt 0  AND $
                StrPos( UPath, 'rsi' ) lt 0  AND $
                StrPos( UPath, '/'   ) ge 0 )

   if ( Ind[0] ge 0 ) then begin
      for I = 0L, N_Elements( Ind )-1L do begin
         Print, UPath( Ind[I] )
         if ( Do_Write ) then PrintF, Ilun, Upath( Ind[I] )
      endfor
   endif

   ;---------------------------------------
   ; (3) Routines in directories that 
   ;     contain "lib" but not "rsi"
   ;---------------------------------------
   Ind = Where( StrPos( UPath, 'lib') ge 0 AND $
                StrPos( UPath, 'rsi') lt 0 AND $
                StrPos( UPath, '/'  ) ge 0 )

   if ( Ind[0] ge 0 ) then begin
      for I = 0L, N_Elements( Ind )-1L do begin
         Print, UPath( Ind[I] )
         if( Do_Write ) then PrintF, Ilun, UPath( Ind[i] )
      endfor
   endif

   ;---------------------------------------
   ; (4) Routines in directories that 
   ;     contain "rsi"
   ;---------------------------------------
   ind = Where( StrPos( UPath, 'rsi') ge 0 AND $
                StrPos( UPath, '/'  ) ge 0 )

   if ( ( Ind[0] ge 0 ) and Do_IDL ) then begin
      for I = 0L, N_Elements( Ind )-1L do begin
         Print, Upath( Ind[I] )
         if( Do_Write ) then PrintF, Ilun, UPath( Ind[I] )
      endfor
   endif

   ; Close file if necessary
   if ( Do_Write ) then begin
      Close,    Ilun
      Free_LUN, Ilun
   endif
 
   ;---------------------------------------
   ; Print routine names and the path
   ;---------------------------------------

   ; Sort routine names alphabetically
   Si = Sort( Name )

   ; Write name and then full path of each routine
   Print,';'
   for I = 0L, N_Elements( Path )-1L do begin
      Print,'; ', Name( Si[I] ),' : ', Path( Si[i] )
   endfor

   ; Exit
   return
end
 
 
