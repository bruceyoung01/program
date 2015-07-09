; $Id: bpch_link.pro,v 1.2 2008/04/02 15:19:01 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        BPCH_LINK
;
; PURPOSE:
;        Copies data from several binary punch files into a single
;        binary punch file.  Also can trim data down to nested-grid
;        resolution if necessary
;
; CATEGORY:
;        File & I/O, BPCH Format
;
; CALLING SEQUENCE:
;        BPCH_LINK, INFILES, OUTFILE [, Keywords ]
;
; INPUTS:
;        INFILES -> A path name or file mask (with wildcards) 
;             which indicates the names of the individual files
;             to be linked together in a single bpch file.
;
;        OUTFILE -> Name of the bpch file that will contain data
;             from the individual bpch files specified by INFILES.
;
; KEYWORD PARAMETERS:
;        /CREATE_NESTED --> If set, then BPCH_LINK will trim data
;             to the nested grid resolution as specified by the
;             XRANGE and YRANGE keywords.
;
;        XRANGE -> A 2-element vector containing the minimum and
;             maximum box center longitudes which define the nested
;             model grid. Default is [-180,180].
;
;        YRANGE -> A 2-element vector containing the minimum and
;             maximum box center latitudes which define the nested
;             model grid. Default is [-90,90].
;
; OUTPUTS:
;        None
;
; SUBROUTINES:
;        External Subroutines Required:
;        ==============================
;        OPEN_FILE      UNDEFINE
;        CTM_DIAGINFO
;
; REQUIREMENTS:
;        Requires routines from the GAMAP and TOOLS packages.
;
; NOTES:
;        None
;
; EXAMPLE:
;        BPCH_LINK, 'ctm.bpch.*', 'new.ctm.bpch'
;
;             ; Consolidates data from the 'ctm.bpch.*' files
;             ; into a single file named 'new.ctm.bpch'
;
; MODIFICATION HISTORY:
;        bmy, 31 Jan 2003: VERSION 1.00
;        bmy, 09 Apr 2003: VERSION 1.01
;                          - now can save to nested grid 
;        bmy, 15 May 2003: VERSION 1.02
;                          - now can pass a list of files via INFILES
;        bmy, 20 Nov 2003: GAMAP VERSION 2.01
;                          - now gets the spacing between diagnostic
;                            offsets from CTM_DIAGINFO
;        bmy, 28 May 2004: GAMAP VERSION 2.02
;                          - Now use MFINDFILE to get INLIST regardless
;                            of the # of elements of INFILES 
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
;        bmy, 02 Apr 2008: GAMAP VERSION 2.12
;                          - Now read/write bpch as big-endian
;
;-
; Copyright (C) 2003-2007, 
; Bob Yantosca and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of 
; this software. If this software shall be used commercially or 
; sold as part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.as.harvard.edu with subject "IDL routine bpch_link"
;-----------------------------------------------------------------------


pro Bpch_Link, InFiles, OutFile, $
               Create_Nested=Create_Nested, XRange=XRange, YRange=YRange

   ;====================================================================
   ; Initialization
   ;====================================================================

   ; External functions
   FORWARD_FUNCTION CTM_Grid, CTM_Type, MFindFile, Little_Endian

   ; Keywords
   Create_Nested = Keyword_Set( Create_Nested )
   if ( N_Elements( XRange ) eq 0 ) then XRange = [-180,180]
   if ( N_Elements( YRange ) eq 0 ) then YRange = [ -90, 90]

   ; Are we on a little-endian machine?
   SE = Little_Endian()

   ; Open the output file (write as big-endian)
   Open_File, OutFile, Ilun_OUT, /F77, /GET_LUN, /Write, Swap_Endian=SE
   
   ; Halt execution if INFILES is not passed
   if ( N_Elements( InFiles ) eq 0 ) $
      then Message, 'INFILES not passed!'

   ; Get the file listing based on the file mask (bmy, 5/28/04)
   InList = MFindFile( InFiles )

   ; Error check
   if ( N_Elements( InList ) eq 0 ) $
      then Message, 'Could not locate input files!'
      
   ; First-time flag
   FirstTime = 1L

   ; Get the spacing between diagnostic offsets
   ; This is the same for all category names (bmy, 11/20/03)
   CTM_DiagInfo, 'IJ-AVG-$', Spacing=Spacing

   ;====================================================================
   ; Loop thru all of the INPUT FILES
   ;====================================================================
   for N = 0L, N_Elements( InList ) - 1L do begin
 
      ; Name of the Nth INPUT FILE
      ThisFile = StrTrim( InList[N], 2 )

      ; Echo info to screen
      Print, 'Now Reading ' + ThisFile
 
      ; Open the Nth INPUT FILE (read as big-endian)
      Open_File, ThisFile, Ilun, /F77, /Get_LUN, Swap_Endian=SE
 
      ; Define header variables
      FTI      = BytArr(40)
      TopTitle = BytArr(80)
 
      ; Read the FTI and TOPTITLE from the Nth INPUT FILE
      ReadU, Ilun, FTI 
      ReadU, Ilun, TopTitle
         
      ; Write the FTI and TOPTITLE to the OUTFILE (first-time only)
      if ( FirstTime ) then begin
         WriteU, Ilun_OUT, FTI
         WriteU, Ilun_OUT, TopTitle
         FirstTime = 0L
      endif
 
      ;=================================================================
      ; Copy each data block to the OUTPUT FILE
      ;=================================================================
      while ( not EOF( Ilun ) ) do begin 
 
         ; Define data block header variables
         Modelname  = BytArr(20)
         Modelres   = Fltarr(2)
         MhalfPolar = -1L
         Mcenter180 = -1L
         Unit       = BytArr(40)
         Reserved   = BytArr(40)
         Dim        = Lonarr(6)
         Skip       = -1L
         Category   = BytArr(40)
         Tracer     = 0L
         Tau0       = 0D
         Tau1       = 0D
         Skip       = 0L
 
         ; Read data block header from the Nth INPUT FILE
         ReadU, Ilun, Modelname,Modelres,Mhalfpolar,Mcenter180
         ReadU, Ilun, Category,Tracer,Unit,Tau0,Tau1,Reserved,Dim,Skip
 
         ; Read data array from the Nth INPUT FILE
         Data = FltArr( Dim[0], Dim[1], Dim[2] )
         ReadU, Ilun, Data
 
         ;==============================================================
         ; Cut data down to nested grid size if necessary
         ;==============================================================
         if ( Create_Nested ) then begin

            ; Model and grid info structures
            InType = CTM_Type( StrTrim( ModelName, 2 ), Res=ModelRes )
            InGrid = CTM_Grid( InType )

            ; Get index array for longitude
            IndX = Where( InGrid.XMid ge XRange[0] AND $
                          InGrid.XMid le XRange[1], Nx )

            ; Get Index array for latitude
            IndY = Where( InGrid.YMid ge YRange[0] AND $
                          InGrid.YMid le YRange[1], Ny )

            ; Trim data array
            Data = Data[IndX,*,*]
            Data = Data[*,IndY,*]

            ; Redefine DIM and SKIP fields
            Dim  = [ Nx, Ny, Dim[2], IndX[0]+1L, IndY[0]+1L, 1L ]
            Skip = 4L *  ( Dim[0] * Dim[1] * Dim[2]  ) + 8L
         endif

         ;==============================================================
         ; Write data to output file
         ;==============================================================

         ; Don't store high tracer numbers
         Tracer = Tracer mod Spacing
 
         ; Write data
         WriteU, Ilun_OUT, Modelname,Modelres,Mhalfpolar,Mcenter180
         WriteU, Ilun_OUT, Category,Tracer,Unit,Tau0,Tau1,Reserved,Dim,Skip
         WriteU, Ilun_OUT, Data
 
         ; Undefine Stuff
         UnDefine, Data
         UnDefine, Modelname  
         UnDefine, Modelres   
         UnDefine, MhalfPolar 
         UnDefine, Mcenter180 
         UnDefine, Unit       
         UnDefine, Reserved   
         UnDefine, Dim        
         UnDefine, Skip       
         UnDefine, Category   
         UnDefine, Tracer     
         UnDefine, Tau0       
         UnDefine, Tau1       
         UnDefine, Skip       
         UnDefine, IndX
         UnDefine, IndY
         UnDefine, ModelInfo
         UnDefine, GridInfo
       
      endwhile
 
      ; Undefine header variables
      UnDefine, FTI
      UnDefine, TopTitle
      
      ; Close the Nth INPUT FILE
      Close,    Ilun
      Free_LUN, Ilun
      
   endfor
 
   ;====================================================================
   ; Close the OUTPUT FILE and quit
   ;====================================================================
   Close,    Ilun_OUT
   Free_LUN, Ilun_OUT
 
end
 
 
 
