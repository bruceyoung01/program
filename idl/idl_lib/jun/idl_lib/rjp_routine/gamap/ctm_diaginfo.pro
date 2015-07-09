; $Id: ctm_diaginfo.pro,v 1.3 2004/03/26 17:02:24 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        CTM_DIAGINFO
;
; PURPOSE:
;        Return information about one or all of the diagnostic 
;        used by GEOS-CHEM, GISS, or other CTM's.  
;
; CATEGORY:
;        GAMAP
;
; CALLING SEQUENCE:
;        CTM_DIAGINFO, DIAGN, DIAGSTRU [ , Keywords ]
;
; INPUTS:
;        DIAGN -> Diagnostic category name for which to extract the 
;             information.  To retrieve information about all CTM
;             diagnostic categories use the /ALL_DIAGS keyword.
;
; KEYWORD PARAMETERS:
;        /ALL_DIAGS -> Retrieves information about all diagnostics.
;
;        CATEGORY -> Returns to the calling program the punch
;             file category name of the requested diagnostic(s)
;
;        FILENAME -> Name of the diaginfo file (default diaginfo.dat)
;             The file will be searched in the current directory first, 
;             then in the directory where CTM_DIAGINFO.PRO is located.
;             If not found in either location, a standard data block is
;             retrieved from this file.
;
;        /FORCE_READING -> Read from the diaginfo file (specified in
;             FILENAME) and overwrite the contents of the common block.
;
;        MAXTRACER -> Returns to the calling program the maximum
;             number of tracers stored in the requested diagnostic(s).
;             NOTE: This is now only necessary for backwards 
;             compatibility with the GISS-II ASCII punch files.
;
;        OFFSET -> Returns to the calling program the offset constant 
;             that is used to locate tracers in the "tracerinfo.dat"
;             file.  OFFSET is needed to locate the proper index from
;             the "tracerinfo.dat" file.
;
;        SPACING -> Returns to the calling program the interval
;             between diagnostic offsets.
;
; OUTPUTS:
;        DIAGSTRU -> returns a structure or structure array with the 
;             following tags:
;             Category  : Category name for this diagnostic
;             Offset    : Offset factor used in "tracerinfo.dat" file
;             Spacing   : Spacing between diagnostic offsets 
;             MaxTracer : Max # of tracers stored in this diagnostic
;
; SUBROUTINES:
;        Internal Subroutines:
;        =============================================
;        CD_Is_MaxTracer (function)
;
;        External Subroutines Required:
;        =============================================
;        FILE_EXIST   (function)   OPEN_FILE
;        ROUTINE_NAME (funciton)   STRBREAK (function)
;
; REQUIREMENTS:
;        Requires routines from the TOOLS package.
;
; NOTES:
;        (1) At first call, the tracer information structure array is
;        read from a file.  Thereafter, the information is stored in a 
;        common block where it is accessible in subsequent calls.
;
;        (2) 
;
; EXAMPLES:
;        (1)
;        CTM_DIAGINFO, 'BIOGSRCE', R
;        PRINT, R.CATEGORY, ':', R.MAXTRACER, ':',R.OFFSET
;        IDL prints "BIOGSRCE:           0:        4700"
; 
;             ; Returns a structure containing tags CATEGORY,
;             ; MAXTRACER, OFFSET for the "BIOGSRCE" diagnostic.
;             ; as listed in the file "diaginfo.dat".
;
;        (2)
;        CTM_DIAGINFO, /ALL, CATEGORY=CATEGORY
;        PRINT, CATEGORY
;        IDL prints "IJ-AVG-$ IJ-24H-$ IJ-INS-$ INST-MAP ..."
;
;             ; Return information about all category names
;             ; listed in the file "diaginfo.dat".
;
; MODIFICATION HISTORY:
;        bmy, 19 May 1998: VERSION 1.00
;                          - developed from CTM_TRACERINFO.PRO v. 2.0 by
;                            Martin Schultz (08 May 1998)
;                            see comments to CTM_TRACERINFO.PRO for 
;                            modification history of that subroutine
;        bmy, 20 May 1998: - removed SCALE and UNIT structure tags & keywords
;                          - added OFFSET structure tag & keyword
;        bmy, 27 May 1998: - changed "tracers" to "diagnostics" in 
;                            print statement.
;        mgs, 13 Aug 1998: - now returns only first diagnostics for a
;                            given number.  This permits to keep old
;                            and new diagnostics in one file and use
;                            the old diagnostics by name.
;                          - introduced extra search one level above 
;                            current dir.
;        mgs, 17 Aug 1998: - changed defaults vor void return
;                          - diaginfo.dat: MAXTRACER meaning changed!
;        bmy, 17 Nov 2003: GAMAP VERSION 2.01
;                          - Removed INDEX and TYPE, they're obsolete
;                          - Now use new file format for "diaginfo.dat"
;                            which allows for 8-digit offset numbers
;                          - Added internal function CD_IS_MAXTRACER
;                          - No longer read defaults from internal datablock
;                          - Added SPACING keyword
;                          - Updated comments 
;
;-
; Copyright (C) 1998, 2003, 
; Martin Schultz and Bob Yantosca, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author to arrange payment.
; Bugs and comments should be directed to mgs@io.harvard.edu
; or "bmy@io.harvard.edu" with subject "IDL routine ctm_diaginfo"
;-----------------------------------------------------------------------

function CD_Is_MaxTracer, Comment

   ;====================================================================
   ; Internal function CD_IS_MAXTRACER tests the comment string to
   ; see if a diagnostic is an old GISS-II MAXTRACER diagnostic (e.g.
   ; one where a different tracer # is assigned to each level). 
   ;
   ; NOTE: This is only needed for backwards compatibility w/ the old
   ;       GISS-II or GISS-II' ASCII punch files. (bmy, 11/17/03)
   ;====================================================================

   ; MAXTRACER diagnostics are denoted by the string "MAXTRACER"
   if ( StrPos( StrUpCase( Comment ), 'MAXTRACER' ) ge 0 ) then begin
      
      ; Split the comment string along '=" delimiter
      Result = StrBreak( Comment, '=' )

      ; Return the max # of tracers to the main program
      return, Long( Result[1] )

   endif else begin

      ; Otherwise it's not an old GISS MAXTRACER diagnostic 
      return, 0L

   endelse
end

;------------------------------------------------------------------------------

pro CTM_DiagInfo, DiagN, DiagStru,                                  $    
                  All_Diags=All_Diags, Category=Category,           $
                  FileName=FileName,   Force_Reading=Force_Reading, $
                  Offset=Offset,       MaxTracer=MaxTracer,         $
                  Spacing=Spacing,     _EXTRA=e

   ;====================================================================  
   ; Initialization
   ;====================================================================  
                  
   ; External functions
   FORWARD_FUNCTION CD_Is_MaxTracer, File_Exist, StrBreak

   ; common block stores pointer to information for future calls
   common DiagCom, PDiagInfo
   
   ; Sample structure for void return
   Sample = { DStru,           $
              Category  : '',  $
              Offset    : 0L,  $
              Spacing   : 0L,  $
              MaxTracer : 0L }

   ; Initialize pointer at first call
   if ( N_Elements( PDiagInfo ) eq 0 ) then PDiagInfo = ptr_new()

   ;====================================================================  
   ; If PDIAGINFO contains no elements, then read the "diaginfo.dat"
   ; file -- first look in this directory, then one level higher, then
   ; and finally in the directory of this procedure.
   ;====================================================================  
   if ( Keyword_Set( Force_Reading ) OR  $
        not ptr_valid( PDiagInfo ) ) then begin
      
      ; Default file name
      if ( N_Elements( FileName ) eq 0 ) then FileName = 'diaginfo.dat'

      ; If FILENAME isn't found, try one directory level higher
      if ( not File_Exist( FileName, full=full ) ) then begin
         fpath = extract_path(FileName,filename=fname)
         TestFileName = fpath+'../'+fname

         ; If still not found, then look for FILENAME 
         ; in the directory of this procedure
         if ( not File_Exist( TestFileName, full=full ) ) then begin
            dum = Routine_name( FileName=ProFileName )
            if ( File_Exist( ProFileName, path=!PATH, full=full) ) then begin
               FileName = Extract_Path( Full ) + extract_filename(FileName)
               if (not File_Exist( FileName, Full=Full)) then FileName = ''
            endif 
         endif
      endif
 
      ;=================================================================
      ; Read data from FILENAME
      ;=================================================================  
      if ( FileName eq '' ) then begin

         ; Exit w/ error msg
         Message, 'FILENAME not passed!', /Continue
         return

      endif else begin

         ; Echo info
         S = 'reading ' + StrTrim( Full, 2 ) + ' ...'
         Message, S, /Info

         ; Open file for reading
         Open_File, Full, Ilun, /Get_LUN

         ; Initialize
         Line      = '#'
         FirstTime = 1L
         Spacing   = 100L

         ; Loop thru input file
         while ( not EOF( Ilun ) ) do begin
            
            ; Read a line from the file
            ReadF, Ilun, Line

            ; Comment lines begin with '#' in the first column
            if ( StrMid( Line, 0, 1 ) eq '#' ) then begin

               ; This is a comment line -- but also look to see if
               ; this is the line which specifies the diagnostic spacing
               if ( StrPos( Line, 'SPACING BETWEEN' ) ge 0 ) then begin
                  Result  = StrBreak( Line, '=' )
                  Spacing = Long( Result[1] )
               endif

            endif else begin

               ; This is not a comment line -- store into SDATA array 
               if ( FirstTime ) then begin
                  SData     = Line
                  FirstTime = 0L
               endif else begin
                  SData     = [ SData, Line ]
               endelse

            endelse

         endwhile

         ; Close input file
         Close,    Ilun
         Free_LUN, Ilun
      endelse
 
      ;=================================================================
      ; Extract data from string array SDATA   
      ;=================================================================
      if ( SData[0] eq ''  ) then begin
         Message, 'Could not retrieve diagnostic information !'
      endif

      ; Create array of structures
      DiagStru = Replicate( Sample, N_Elements( SData ) )
 
      ; Loop over all diagnostic category names read from disk
      for I = 0L, N_Elements( SData ) - 1L do begin

         ; Initialize
         Category  = ''
         Comment   = ''
         MaxTracer = 0L
         Offset    = 0L

         ; Extract fields -- new data format (bmy, 11/18/03)
         ReadS, SData[I], Offset, Category, Comment, Format='(i8,1x,a40,1x,a)' 

         ; Examine the comment string to determine if this
         ; diagnostic is an old GISS-II MAXTRACER diagnostic
         MaxTracer = CD_Is_MaxTracer( Comment )

         ; Store into the Ith element of DIAGSTRU array of structures
         DiagStru[I].Category  = StrTrim( Category, 2 )        
         DiagStru[I].MaxTracer = MaxTracer 
         DiagStru[I].Offset    = Offset
         DiagStru[I].Spacing   = Spacing
      endfor
 
      ; Echo information
      S = 'Retrieved information about ' + $
           StrTrim( String( N_Elements( DiagStru ), Format='(i10)' ), 2 ) + $
           ' diagnostics'
      Message, S, /Info

      ; store as pointer (delete old one)
      if ( Ptr_Valid( PDiagInfo ) ) then Ptr_Free, PDiagInfo

      PDiagInfo = Ptr_New( DiagStru, /no_copy )
   endif
    
   ;====================================================================
   ; Now return information that the user has selected
   ;====================================================================

   ; If /ALL_DIAGS is set, return info about all diagnostics
   if ( Keyword_Set( All_Diags ) ) then begin
      DiagStru  = *PDiagInfo
      Category  = DiagStru[*].Category
      MaxTracer = DiagStru[*].MaxTracer
      Offset    = DiagStru[*].Offset
      Spacing   = DiagStru[*].Spacing
      return
   endif

   ; Initialize return values for no valid diagnostic
   DiagStru  = Sample 
   Category  = ''
   MaxTracer = 0
   Offset    = 0
   Spacing   = 0
   Ind       = -1
 
   ; nothing requested, so return
   if ( N_Elements( DiagN ) eq 0 ) then return 

   ; check if DIAGN is numeric (i.e. index) or string (i.e. name)
   S = Size( DiagN )
   S = S[ n_elements( S ) - 2 ]

   ; invalid argument type
   if ( S eq 6 OR S gt 7 ) then return 

   ; loop through all DIAGN arguments and try to find them
   for I = 0L, N_Elements( DiagN )-1L do begin

      ; Match name
      Tind = where( strupcase( ( *PDiagInfo ).Category ) eq $
                    strupcase( DiagN[i] ) ) 
               
      ; Append matching indices into array
      Ind  = [ Ind, Tind[0] ]

   endfor

   ; Reform IND array
   Ind = temporary( Ind[1:*] )    
   
   ; Create array of structures for GAMAP common block
   DiagStru = Replicate( Sample, N_Elements( Ind ) )

   ; TInd is the array of matching categories
   Tind = Where( Ind ge 0 )

   ; Return information for each requested Category name
   if ( Tind[0] ge 0 ) then begin
      DiagStru[Tind] = ( *PDiagInfo ) [ Ind[Tind] ]
      Category       = DiagStru[*].Category
      MaxTracer      = DiagStru[*].MaxTracer
      Offset         = DiagStru[*].Offset
      Spacing        = DiagStru[*].Spacing
   endif

   ; Return as scalar if only one diagnostic was requested
   if ( N_Elements( Ind ) eq 1 ) then begin
      Category  = Category[0]
      MaxTracer = MaxTracer[0]
      Offset    = Offset[0]
      Spacing   = Spacing[0]
   endif
      
   return
end
