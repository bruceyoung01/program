; $Id: bpch2pch.pro,v 1.1.1.1 2007/07/17 20:41:39 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        BPCH2PCH
;
; PURPOSE:
;        Translates data from GAMAP-readable binary punch
;        file v. 2.0 format to the ancient ASCII-punch
;        file standard.
;       
; CATEGORY:
;        File & I/O, BPCH Format
;
; CALLING SEQUENCE:
;        BPCH2PCH, FILENAME [, OUTFILENAME [, Keywords ] ]
;
; INPUTS:
;        FILENAME -> Name of the binary punch file from which 
;             to read data.  FILENAME may be a file mask, and may
;             contain wild card characters (e.g. ~/ctm.bpch.*). If
;             FILENAME is omitted or contains a wild card character,
;             the user will be prompted to pick a file via a dialog box.
;
;        OUTFILENAME (optional) -> Name of the output ASCII punch
;             file.  Default is 'ASCIIfile.pch' 
;
; KEYWORD PARAMETERS:
;        DIAGN -> A diagnostic category name (e.g. "IJ-AVG-$") or
;              array of names which will restrict the data block 
;              selection.  If DIAGN is omitted, then all data blocks 
;              within INFILE will be saved in ASCII punch format
;              to OUTFILE.
;
;         /EXTRA_SPACE -> If set, will put an extra space between
;             the numbers in the ASCII punch file.  This might 
;             be necessary when using MATLAB or S-PLUS to read
;             in the ASCII punch file.
;
; OUTPUTS:
;         Writes data to ASCII punch file format
;
; SUBROUTINES:
;         CTM_GET_DATA 
;
; REQUIREMENTS:
;         References routines from both GAMAP and TOOLS packages.
;
; NOTES:
;         Some limitations:
;         (1) Works only for global lon-lat diagnostics.           
;         (2) The top header line might be inaccurate (but nobody
;             really reads that anyway, so forget it for now...)
;
; EXAMPLE:
;         BPCH2PCH, '~/bmy/ctm.bpch', '~/bmy/ctm.pch'
;        
;             ; Reads data from binary punch file '~/bmy/ctm.bpch'
;             ; and writes it to ASCII punch file '~/bmy/ctm.pch'. 
;
;
; MODIFICATION HISTORY:
;        bmy, 08 Nov 1999: VERSION 1.00
;        bmy, 03 Jun 2004: GAMAP VERSION 2.02
;                          - now pass extra keywords to CTM_GET_DATA
;                            via _EXTRA=e keyword;
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
;
;-
; Copyright (C) 1999-2007, 
; Bob Yantosca and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of 
; this software. If this software shall be used commercially or 
; sold as part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.as.harvard.edu with subject "IDL routine bpch2pch"
;-----------------------------------------------------------------------


pro Bpch2Pch, FileName, OutFileName, $
              Extra_Space=Extra_Space, DiagN=DiagN, _EXTRA=e
   
   ;====================================================================
   ; Keyword Settings
   ;====================================================================
   if ( N_Elements( OutFileName ) eq 0 ) then OutFileName = 'ASCIIfile.pch'

   if ( Keyword_Set( Extra_Space ) )     $
      then DataFormat = '( 12( f6.2, 1x ) )' $
      else DataFormat = '( 12f6.2 )'
   
   ;====================================================================
   ; Header for the top of the punch file
   ; and strings for the individual levels
   ;====================================================================
   Header = 'Created by IDL program BPCH2PCH' + Systime( 0 )

   Levels = [ '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', $
              'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', $
              'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U' ]
   
   ;====================================================================
   ; Call CTM_GET_DATA to read all data blocks from 
   ; the binary punch file
   ;====================================================================
   if ( N_Elements( DiagN ) gt 0 )                                 $
      then CTM_Get_Data, DataInfo, DiagN, File=InFile, _EXTRA=e $
      else CTM_Get_Data, DataInfo,        File=InFile, _EXTRA=e

   ;====================================================================
   ; N_TRACER is the total number of tracers found in the punch file
   ; *** this is a hokey way of finding the total # of tracers ***
   ;====================================================================
   N_Tracer = N_Elements( Uniq( DataInfo.Tracer ) )

   ;====================================================================
   ; Open the output file and loop over each data block
   ;====================================================================   
   Open_File, OutFileName, Ilun, /Get_LUN, /Write

   for N=0, N_Elements( DataInfo ) - 1 do begin
 
      ; Extract header variables as well as the data
      ; from the current data block
      Category = StrTrim( DataInfo[N].Category, 2 )
      Dim      = DataInfo[N].Dim
      Tracer   = DataInfo[N].Tracer
      Tau0     = DataInfo[N].Tau0
      Tau1     = DataInfo[N].Tau1
      Data     = *( DataInfo[N].Data )
      Unit     = StrUpCase( StrTrim( DataInfo[N].Unit, 2 ) )
     
      ; Make sure concentrations are in mixing ratio
      ; since CTM_GET_DATA will pull the data block out
      ; in ppm, ppb, or ppt.         
      case ( StrMid( Unit, 0, 3 ) ) of
         'PPM' : Data = Data * 1e-6
         'PPB' : Data = Data * 1d-9
         'PPT' : Data = Data * 1d-12
         else  : ; Null command
      endcase

      ; Number of lines of formatted output for this data block
      N_Lines = ( Dim[0] * Dim[1] + 11 ) / 12

      ;-----------------------------------------------------------------
      ; Debug output...uncomment if necessary
      ;print, '### N          : ', N
      ;print, '### Category   : ', Category
      ;print, '### Dim        : ', Dim
      ;print, '### Tracer     : ', Tracer
      ;print, '### Tau0       : ', Tau0
      ;print, '### Tau1       : ', Tau1
      ;print, '### Data range : ', Min( Data, Max=M ), M 
      ;print, '### N_Lines    : ', N_Lines
      ;goto, Next
      ;-----------------------------------------------------------------

      ; If this is the first timestep, then print out the
      ; header line to the punch file
      if ( N eq 0 ) then begin
         PrintF, Ilun, Header, N_Tracer, Dim[0:2], 0,  0, 1985, $
            Format='( a60, 6i3, i8 )' 
      endif
   
      ;=================================================================      
      ; Loop over the number of levels in the data block
      ;=================================================================      
      for L = 0L, Dim[2] - 1 do begin

         ; Save the category name in a temp variable
         TmpCategory = Category

         ; If this category is a multi-level, then we have to write
         ; out the data for each level separately
         Ind         = StrPos( TmpCategory, '$' )
         if ( Ind[0] ge 0 ) then StrPut, TmpCategory, Levels[L], Ind[0]

         ; In the ASCII punch file, only 3 powers of 10 are 
         ; allowed.  Therefore, divide the data values by
         ; 3 powers of ten less than the maximum data value.
         TmpData    = Data[*, *, L] + 1D-27
         LogMaxData = Fix( ALog10( Max( TmpData ) ) ) + 1
         Scale      = 10d0 ^ ( LogMaxData - 3 )
         TmpData    = TmpData / Scale
 
         ;--------------------------------------------------------------
         ; Debug output...uncomment if necessary
         ;print, '### TmpCategory: ', TmpCategory
         ;print, '### LogMaxData : ', LogMaxData
         ;print, '### Scale      : ', Scale
         ;--------------------------------------------------------------
 
         ; Write the data block header to the ASCII punch file
         PrintF, Ilun, $
            TmpCategory, N_Lines, Tracer, Tau0, Tau1, Scale, $
            Dim[0], Dim[1], 1L, $
            Format='( 2X, A8, 2I5, 2I10, E10.3, 2X, 3I4 )'    
 
         ; Write the data block values to the ASCII punch file
         PrintF, Ilun, TmpData, Format=DataFormat
      endfor
Next: 
   endfor

   ;====================================================================     
   ; Close output file and quit
   ;====================================================================     
   Close,    Ilun
   Free_Lun, Ilun

Quit:
   return
end
