; $Id: bpch_test.pro,v 1.2 2004/01/29 19:33:35 bmy Exp $
;-------------------------------------------------------------
;+
; NAME:
;        BPCH_TEST
;
; PURPOSE:
;        Reads header and data block information from binary
;        punch files and prints the file pointer locations.
;
; CATEGORY:
;        I/O -- Binary punch files
;
; CALLING SEQUENCE:
;        BPCH_TEST [, FILENAME, [ Keywords ] ]
;
; INPUTS:
;        FILENAME (optional) -> Name of the binary punch file to read.
;             If omitted, a dialog box will prompt the user to make
;             a selection.
;             
; KEYWORD PARAMETERS:
;        /NOPAUSE -> If set, will not pause after displaying information   
;             about each data block.  Default is to pause to allow the
;             user to examine each data blocks header information.
;
; OUTPUTS:
;        None
;
; SUBROUTINES:
;        External Subroutines Required:
;        ------------------------------
;        LITTLE_ENDIAN (function)
;
; REQUIREMENTS:
;        References routines from the TOOLS package.
;
; NOTES:
;        BPCH_TEST does not return any data values from the binary
;        punch file.  It is meant to be used for debugging purposes.
;
; EXAMPLE:
;        BPCH_TEST, 'my.bpch'
;               
;             ; will print info about each data block in 'my.bpch'
;
; MODIFICATION HISTORY:
;        bmy, 10 Dec 1999: VERSION 1.00
;        bmy, 25 May 2000: VERSION 1.45
;                          - allow user to quit after viewing 
;                            each data block header
;                          - add FILENAME keyword, so that the filename  
;                            can be passed as a parameter or a keyword
;        bmy, 21 Jul 2000: VERSION 1.46
;                          - now print locations of min, max data values
;                          - changed FILETYPE to reflect new definitions
;                            from CTM_OPEN_FILE 
;
;-
; Copyright (C) 1999, 2000, Bob Yantosca, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author.
; Bugs and comments should be directed to bmy@io.harvard.edu
; with subject "IDL routine bpch_test"
;-------------------------------------------------------------


pro Bpch_Test, FileName, FileName=FileName2, NoPause=NoPause

   ;====================================================================
   ; External functions / Keyword settings
   ;====================================================================
   FORWARD_FUNCTION Little_Endian

   NoPause = Keyword_Set( NoPause )

   ; If there are no parameters passed, take FILENAME from the keyword
   if ( N_Params() eq 0 AND N_Elements( FileName2 ) gt 0 ) $
      then FileName = FileName2

   ;====================================================================
   ; Define some variables for the punch file format
   ;====================================================================
   FTI        = BytArr( 40 )
   TopTitle   = BytArr( 80 )
   ModelName  = BytArr( 20 )
   ModelRes   = FltArr(  2 )
   Unit       = BytArr( 40 )
   Reserved   = BytArr( 40 ) 
   Dim        = LonArr(  6 )
   MHalfPolar = -1L
   MCenter180 = -1L
   Skip       = -1L
 
   ;====================================================================
   ; Open the binary punch file for reading.
   ;
   ; Place file pointer at top of file and read the file type 
   ; identifier string (FTI).
   ;
   ; If this is binary punch file format v. 1.0, set FILETYPE = 101 
   ; If this is binary punch file format v. 2.0, set FILETYPE = 102
   ;====================================================================
   Open_File, FileName, Ilun, /F77, /Get_LUN, Swap_Endian=Little_Endian()

   Point_LUN, Ilun, 0L
   ReadU, Ilun, FTI 
 
   case ( StrTrim( FTI, 2 ) ) of
      'CTM binary' : begin
         print, 'Binary Punch File v. 1.0'
         FileType = 101
      end

      'CTM bin 02' : begin
         print, 'Binary Punch File v. 2.0'
         FileType = 102
      end
 
      else         : begin
         Message, 'Invalid binary punch file format!', /Continue
         return
      end
   endcase

   ;====================================================================
   ; Get the location of the file pointer after reading FTI 
   ; and print it to the screen.
   ;====================================================================
   Point_LUN, -Ilun, NewPos
 
   Print, '----------------------------------------------------------------'
   Print, 'FTI       : ', StrTrim( FTI, 2 ) 
   Print, 'After FTI : ', NewPos
   
   ;====================================================================
   ; Read the top title from the binary punch file and print it
   ; Also get the file pointer position after reading toptitle
   ;====================================================================
   ReadU, Ilun, TopTitle
   Print, 'Title:', StrTrim( TopTitle, 2 )
 
   Point_LUN, -Ilun, NewPos
   Print, 'After title : ', NewPos
 
   ;====================================================================
   ; If this is binary punch file format v. 1.0, read the model name
   ; and resolution (which are stored once at the top of the file).
   ;
   ; Get the file pointer position after reading these in.
   ;====================================================================
   if ( FileType eq 101 ) then begin
      ReadU, Ilun, ModelName, ModelRes
      Point_LUN, -Ilun, NewPos
      Print, 'After Model name and resolution: ', NewPos
   endif
 
   ;====================================================================
   ; Loop through the file, reading information about each data block
   ;====================================================================
   while ( not EOF( ilun ) ) do begin 
 
      ;=================================================================
      ; Define additional variables
      ;=================================================================
      Category = BytArr( 40 )
      Tracer   = 0L
      Skip     = 0L
      Tau0     = 0D
      Tau1     = 0D
 
      ;=================================================================
      ; Get file pointer at top of the data block
      ;=================================================================
      point_lun, -ilun, newpos
      Print, '----------------------------------------------------------------'
      print, 'Top of data block   : ', NewPos
       
      ;=================================================================
      ; Read variables that describe each data block, for
      ; both binary punch file versions
      ;=================================================================
      if ( FileType eq 101 ) then begin
         ReadU, Ilun, Category, Tracer, Tau0, Tau1, Skip
         ReadU, Ilun, Dim
 
      endif else if ( FileType eq 102 ) then begin
         ReadU, Ilun, Modelname, Modelres, MHalfPolar, MCenter180
         ReadU, Ilun, Category, Tracer, Unit, Tau0, Tau1, $
                      Reserved, Dim,    Skip
 
      endif
 
      ;=================================================================
      ; Get file pointer position after reading in the crap above
      ;=================================================================
      Point_lun, -Ilun, NewPos    
      Print, 'At location of data : ', newpos
 
      ;=================================================================
      ; Print variables as read in from the punch file
      ;=================================================================
      print, 'Ilun      : ', Ilun
      print, 'ModelName : ', StrTrim( ModelName, 2 )
      print, 'ModelRes  : ', ModelRes  
      print, 'MHalfPolar: ', MHalfPolar
      print, 'MCenter180: ', MCenter180
      print, 'Category  : ', StrTrim( Category, 2 )
      print, 'Tracer    : ', Fix( tracer )
      print, 'Unit      : ', StrTrim( Unit, 2 )
      print, 'Reserved  : ', StrTrim( Reserved, 2 )
      print, 'TAU0, TAU1: ', Tau0, Tau1
      print, 'Dim       : ', Dim
      print, 'Skip      : ', Skip
 
      ;=================================================================
      ; Read the data block
      ; Pause to allow user to examine info unless /NOPAUSE is set
      ; Also print out locations of min, max data (bmy, 7/21/00)
      ;=================================================================
      Data = FltArr( Dim[0], Dim[1], Dim[2] )
      ReadU, Ilun, Data

      MinData = Min( Data, Max=MaxData )
      Ind_Min = Where( Data eq MinData )
      Ind_Max = Where( Data eq MaxData )

      Print, MinData, MaxData, $
         Format='(''Min and Max of Data    :'', 2e13.6)'

      Print, Convert_Index( Ind_Min[0], Dim[0:2], /Fortran ), $
         Format='(''First Min Data Location: '', 3i5)'

      Print, Convert_Index( Ind_Max[0], Dim[0:2], /Fortran ), $
         Format='(''First Max Data Location: '', 3i5)'

      if ( not NoPause ) then begin
         DumStr = ''
         Read, DumStr, Prompt='<<< Hit RETURN to continue or Q to Quit >>> '
         if ( StrUpCase( StrTrim( DumStr, 2 ) ) eq 'Q' ) then goto, Quit
         
      endif

    endwhile
 
    ;====================================================================
    ; Close file and return
    ;====================================================================   
Quit:
    Close,    Ilun
    Free_LUN, Ilun

    return
end
 
 
 
