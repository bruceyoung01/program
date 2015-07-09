; $Id: ctm_printdiff.pro,v 1.1.1.1 2003/10/22 18:06:04 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        CTM_PRINTDIFF
;
; PURPOSE:
;        Prints the sum of the differences between two CTM
;        output files.  This is a quick way of ensuring that
;        two model versions are producing identical results.
;
; CATEGORY:
;        CTM Tools

; CALLING SEQUENCE:
;        CTM_PRINTDIFF, DIAGN [, Keywords ]
;
; INPUTS:
;        DIAGN -> A diagnostic number or category to restrict
;             the record selection (default is: "IJ-AVG-$").        
;
; KEYWORD PARAMETERS:
;        FILE1 -> Name of the first CTM output file (the "old" file).
;             If FILE1 is not given, or if it contains wildcard 
;             characters (e.g. "*"), then the user will be prompted 
;             to supply a file name via a pickfile dialog box.
;
;        FILE2 ->  Name of the second CTM output file (the "new" file).  
;             If FILE2 is not given, or if it contains wildcard 
;             characters (e.g. "*"), then the user will be prompted 
;             to supply a file name via a pickfile dialog box.
;
;        TRACER -> Number of the tracer for which differences
;             will be plotted.
;
;        _EXTRA=e -> Picks up other keywords for CTM_GET_DATABLOCK.
;
; OUTPUTS:
;        Prints the quantity:
;
;             DIFF[L] = TOTAL( DATA2[*,*,L] - DATA1[*,*,L] ) 
;
;        for each level L.  If DIFF[L] = 0 for all levels L, then
;        FILE1 and FILE2 contain identical data.
;
; SUBROUTINES:
;        External Subroutines Required:
;        ==============================
;        CTM_CLEANUP
;        CTM_GET_DATABLOCK (function)
;
; REQUIREMENTS:
;        References routines from both the GAMAP and TOOLS packages.
;
; NOTES:
;        (1) If DATA1 corresponds to the "old" data, and DATA2
;            corresponds to the "new" data, then CTM_DIFF will 
;            compute the following:
;         
;            Abs. Diff = ( new - old )
;
;        (2) CTM_PRINTDIFF calls CTM_CLEANUP each time to remove
;            previously read datablock info from the GAMAP common
;            block.
;
; EXAMPLE:
;        FILE1 = 'ctm.bpch.v4-30'      ; the "old" file
;        FILE2 = 'ctm.bpch.v4-31'      ; the "new" file
;        CTM_PRINTDIFF, 'IJ-AVG-$', $
;             FILE1=FILE1, FILE2=FILE2, TRACER=1
;
;        IDL prints:
;             Level:  26 Difference: -2.3841858e-07
;             Level:  25 Difference:  0.0000000e+00
;             Level:  24 Difference:  0.0000000e+00
;             Level:  23 Difference:  0.0000000e+00
;             Level:  22 Difference: -1.4901161e-08
;             Level:  21 Difference:  0.0000000e+00
;             Level:  20 Difference:  0.0000000e+00
;             Level:  19 Difference:  0.0000000e+00
;             Level:  18 Difference:  0.0000000e+00
;             Level:  17 Difference:  0.0000000e+00
;             Level:  16 Difference:  0.0000000e+00
;             Level:  15 Difference:  0.0000000e+00
;             Level:  14 Difference: -7.4505806e-09
;             Level:  13 Difference:  0.0000000e+00
;             Level:  12 Difference:  0.0000000e+00
;             Level:  11 Difference:  0.0000000e+00
;             Level:  10 Difference:  0.0000000e+00
;             Level:   9 Difference:  0.0000000e+00
;             Level:   8 Difference:  0.0000000e+00
;             Level:   7 Difference:  0.0000000e+00
;             Level:   6 Difference:  0.0000000e+00
;             Level:   5 Difference:  0.0000000e+00
;             Level:   4 Difference:  0.0000000e+00
;             Level:   3 Difference:  0.0000000e+00
;             Level:   2 Difference:  0.0000000e+00
;             Level:   1 Difference:  0.0000000e+00
;
;             ; Prints the sum of differences at each level 
;             ; betweeen two GEOS-STRAT binary punch files 
;             ; for NOx (tracer=1).
;            
; MODIFICATION HISTORY:
;        bmy, 04 Apr 2002: GAMAP VERSION 1.50
;        bmy, 22 Apr 2002: - now takes diff of DATA2 - DATA1, in order
;                            to be consistent with CTM_PLOTDIFF.
;
;-
; Copyright (C) 2002, Bob Yantosca, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author.
; Bugs and comments should be directed to bmy@io.harvard.edu
; with subject "IDL routine ctm_printdiff"
;-----------------------------------------------------------------------


pro CTM_PrintDiff, DiagN, File1=File1, File2=File2, Tracer=Tracer, _EXTRA=e
 
   ;====================================================================
   ; External functions / Keyword settings
   ;====================================================================
   FORWARD_FUNCTION CTM_Get_DataBlock 

   if ( N_Elements( DiagN  ) ne 1 ) then DiagN  = 'IJ-AVG-$'
   if ( N_Elements( Tracer ) eq 0 ) then Tracer = 1

   ;====================================================================
   ; Read data from disk
   ; If filenames are not passed, or contain wildcard characters, 
   ; then the user will be prompted via a pickfile dialog box.
   ;====================================================================

   ; Clean up all files
   CTM_CleanUp

   ; Read data from first file
   Success = CTM_Get_DataBlock( Data1, DiagN,                  $
                                FileName=File1,                $
                                Tracer=Tracer,                 $
                                Title='Select the first file', $
                                _EXTRA=e )
   
   ; Error check
   if ( not Success ) then begin
      S = StrTrim( File1, 2 ) + 'not found!'
      Message, S
   endif
 
   ; Read data from 2nd file
   Success = CTM_Get_DataBlock( Data2, DiagN,                   $
                                FileName=File2,                 $
                                Tracer=Tracer,                  $
                                Title='Select the second file', $
                                _Extra=e )

   ; Error check
   if ( not Success ) then begin
      S = StrTrim( File2, 2 ) + 'not found!'
      Message, S
   endif
 
   ;====================================================================
   ; Validate data arrays
   ;====================================================================

   ; Make sure arrays are compatible
   SData1 = Size( Data1, /Dim )
   SData2 = Size( Data2, /Dim )
 
   if ( Total( SData1 ) ne Total( SData2 ) ) then begin
      Message, 'Arrays are not compatible!'
   endif
 
   ; Compute number of levels 
   if ( N_Elements( SData1 ) eq 2 ) then N_Levels = 1
   if ( N_Elements( SData1 ) eq 3 ) then N_Levels = SData1[2]
 
   ;====================================================================
   ; Print the sum of differences at each level.  If all levels 
   ; yield "0", then the two output files contain identical results.
   ;====================================================================
   for L = N_Levels-1L, 0L, -1L do begin 
     
      ; Compute difference at each level
      Diff = Total( Data2[*, *, L] - Data1[*, *, L] )
           
      ; Print difference
      print, L+1, Diff, $
         Format='(''Level: '', i3, '' Difference: '', e14.7)'
 
   endfor

Quit:
   return

end
 
 
