; $Id: ctm_locatediff.pro,v 1.4 2004/06/03 17:58:07 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        CTM_LOCATEDIFF
;
; PURPOSE:
;        Locates data blocks which differ in two binary
;        punch files or GMAO met field files.  
;
; CATEGORY:
;        Debugging
;
; CALLING SEQUENCE:
;        CTM_LOCATEDIFF
;
; INPUTS:
;        FILE1 -> Name of the first file to be tested.  FILE1 may be
;             a binary punch file, and ASCII file, or a GMAO met field
;             file.
;
;        FILE2 -> Name of the second file to be tested.  FILE2 may be
;             a binary punch file, and ASCII file, or a GMAO met field
;             file.
;
; KEYWORD PARAMETERS:
;        DIAGN -> A diagnostic category name to restrict the selection
;             of data records.
;
;        OUTFILENAME -> Name of the output file which will contain
;             the location of differences found between data blocks
;             in FILE1 and FILE2.  If OUTFILENAME is not specified,
;             then CTM_LOCATEDIFF will print this information to
;             the screen.
;
;        _EXTRA=e -> Picks up any extra keywords for CTM_GET_DATA.
;
; OUTPUTS:
;        None
;
; SUBROUTINES:
;        External subroutines required:
;        ==============================
;        CTM_GET_DATA   UNDEFINE
;        CTM_DIAGINFO
;
; REQUIREMENTS:
;        References routines from both GAMAP and TOOLS directories.
;
; NOTES:
;        (1) Both FILE1 and FILE2 must contain the same diagnostic 
;            categories, listed in the same order.
;
; EXAMPLE:
;        CTM_LOCATEDIFF, FILE1='ctm.bpch.old', FILE2='ctm.bpch.new'
;
;             ; Locates data blocks which differ between ctm.bpch.old
;             ; and ctm.bpch.new.  You can investigate these further
;             ; with routines CTM_PRINTDIFF and CTM_PLOTDIFF.
;
; MODIFICATION HISTORY:
;        bmy, 24 Feb 2003: VERSION 1.00
;        bmy, 19 Nov 2003: GAMAP VERSION 2.01
;                          - Now get spacing between diagnostic
;                            offsets from CTM_DIAGINFO
;        bmy, 27 Feb 2004: GAMAP VERSION 2.02
;                          - Rewritten to also print out locations in
;                            FORTRAN notation where differences occur
;                          - added DIAGN keyword to specify category name
;                          - added OUTFILENAME to specify output file
;
;-
; Copyright (C) 2003-2004, Bob Yantosca, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author.
; Bugs and comments should be directed to bmy@io.harvard.edu
; with subject "IDL routine ctm_locatediff"
;-----------------------------------------------------------------------


pro CTM_LocateDiff, File1, File2, $
                    DiagN=DiagN, OutFileName=OutFileName, _EXTRA=e

   ;====================================================================
   ; Initialization
   ;====================================================================

   ; External Functions
   FORWARD_FUNCTION Convert_Index

   ; Keywords
   if ( N_Elements( File1 ) ne 1 ) then Message, 'Must pass FILE1!'
   if ( N_Elements( File2 ) ne 1 ) then Message, 'Must pass FILE2'
   Do_Write = ( N_Elements( OutFileName ) eq 1 )

   ;====================================================================
   ; Read data 
   ;====================================================================
 
   ; Read data from old & new files (use cat name if passed)
   if ( N_Elements( DiagN ) gt 0 ) then begin
      CTM_Get_Data, DInfo_Old, DiagN, File=File1, _EXTRA=e
      CTM_Get_Data, DInfo_New, DiagN, File=File2, _EXTRA=e
   endif else begin
      CTM_Get_Data, DInfo_Old,        File=File1, _EXTRA=e
      CTM_Get_Data, DInfo_New,        File=File2, _EXTRA=e
   endelse

   ; Get number of data blocks in old & new files
   N_Old = N_Elements( DInfo_Old )
   N_New = N_Elements( DInfo_New )
 
   ; Make sure old & new files have same # of data blocks
   ; (this is the cheap test for identical diagnostics!)
   if ( N_Old ne N_New ) then begin
      Message, 'FILE1 and FILE2 do not contain compatible diagnostics!'
   endif
    
   ; Get diagnostic spacing (same for all category names)
   CTM_DiagInfo, DInfo_Old[0].Category, Spacing=Spacing
   Spacing = Spacing[0]

   ;====================================================================
   ; Loop over corresponding data blocks in both files
   ;====================================================================

   ; Format string for use below
   S0 = '(''==> at ('',i4,'','',i4,'','',i4,'')  D1='', e14.7, '',  D2='', e14.7, '',  D2-D1='', e14.7)'

   ; If OUTFILENAME is specified, then open file for output 
   if ( Do_Write ) then Open_File, OutFileName, Ilun, /Get_LUN, /Write
      
   ; Loop over data blocks
   for D = 0L, N_Old-1L do begin
 
      ;-------------------------------
      ; Test for differences
      ;-------------------------------

      ; Get data blocks from old & new files
      Data_Old  = *( DInfo_Old[D].Data )
      Data_New  = *( DInfo_New[D].Data )
 
      ; Sum the differences between the two arrays.  
      ; DATA_DIFF will equal zero if both arrays are identical
      Data_Diff = Data_New - Data_Old

      ; Index of points which have differences
      IndDiff   = Where( Abs( Data_Diff ) gt 0.0 )

      ;--------------------------------
      ; Print locations of differences
      ;--------------------------------
      if ( IndDiff[0] ge 0 ) then begin
         
         ; GAMAP tracer number
         Tracer = DInfo_Old[D].Tracer mod Spacing
         Unit   = StrTrim( DInfo_Old[D].Unit, 2 )

         ; Format string with cat name, tracer, TAU
         S = 'Diff in '   + String( DInfo_Old[D].Category, Format='(a8)'    )+$
           ' ['  + StrTrim( DInfo_Old[D].Unit, 2 ) + ']'                     +$
           ' for tracer ' + String( Tracer,                Format='(i4)'    )+$
           ' at TAU = '   + String( DInfo_Old[D].Tau0,     Format='(f13.3)' )

         ; Write to output file or to screen
         if ( Do_Write ) then begin
            PrintF, Ilun
            PrintF, Ilun, S
         endif else begin
            Print
            Print, S 
            pause
         endelse

         ;--------------------------------
         ; Convert 1-D to 3-D indices
         ;--------------------------------
         for N = 0L, N_Elements( IndDiff )-1L do begin
            
            ; Fortran coordinates (starting from 1)
            Coords = Convert_Index( IndDiff[N], DInfo_Old[D].Dim[0:2] ) + 1L
            Diff   = Data_Diff[ IndDiff[N] ]
            D1     = Data_Old[ IndDiff[N] ]
            D2     = Data_New[ IndDiff[N] ]
            
            ; Write location and difference to output file or screen
            if ( Do_Write )                                       $
               then PrintF, Ilun, Coords, D2, D1, Diff, Format=S0 $
               else Print,        Coords, D2, D1, Diff, Format=S0

         endfor

         ; Stop for examination (if not writing to file)
         if ( not Do_Write ) then Pause
      endif
 
      ; Undefine stuff
      UnDefine, IndDiff
      UnDefine, Data_Old
      UnDefine, Data_New
      UnDefine, Data_Diff
   endfor

   ;====================================================================
   ; Cleanup and quit
   ;====================================================================
   if ( Do_Write ) then begin
      Close,    Ilun
      Free_LUN, Ilun
   endif

end
