; $Id: bpch_sep.pro,v 1.3 2004/01/29 19:33:35 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        BPCH_SEP
;
; PURPOSE:
;        Separates data from one binary punch file into another
;        binary punch file by time (TAU0).  Useful to make smaller
;        bpch files so that we don't run out of IDL memory when
;        reading/processing them.
;
; CATEGORY:
;        File Tools
;
; CALLING SEQUENCE:
;        BPCH_SEP, INFILE, OUTFILE [, Keywords ]
;
; INPUTS:
;        INFILE -> A path name or file mask (with wildcards) 
;             which indicates the names of the individual files
;             to be linked together in a single bpch file.
;
;        OUTFILE -> Name of the bpch file that will contain data
;             from the individual bpch files specified by INFILES.
;
; KEYWORD PARAMETERS:
;        DIAGN -> Array of diagnostic categories for which to 
;             save out to OUTFILE  Default is to save all diagnostic
;             categories to OUTFILE.
;
;        TAU0 -> Time index (hours from 1 Jan 1985) denoting the
;             data blocks to be saved from INFILE to OUTFILE.  You
;             can use NYMD2TAU to compute this from a YYYYMMDD date.
;
; OUTPUTS:
;        None
;
; SUBROUTINES:
;        External Subroutines Required:
;        ==============================
;        OPEN_FILE   UNDEFINE
;
; REQUIREMENTS:
;        Requires routines from the TOOLS package.
;
; NOTES:
;        None
;
; EXAMPLE:
;        BPCH_SEP, 'ctm.bpch.big', 'ctm.bpch.small', tau0=140256D
;
;             ; Pulls out data blocks for TAU0=140256 (1/1/2001) from
;             ; "ctm.bpch.big" and saves them in "ctm.bpch.small"
;
; MODIFICATION HISTORY:
;        bmy, 18 Sep 2003: GAMAP VERSION 1.53
;        bmy, 20 Nov 2003: GAMAP VERSION 2.01
;                          - now gets the spacing between diagnostic
;                            offsets from CTM_DIAGINFO
;
;-
; Copyright (C) 2003, Bob Yantosca, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; k BPCH_SEP, 'ctm.bpch.big', 'ctm.bpch.small', tau0=140256Dept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author.
; Bugs and comments should be directed to bmy@io.harvard.edu
; with subject "IDL routine bpch_sep"
;-----------------------------------------------------------------------


pro Bpch_Sep, InFile, OutFile, Tau0=ThisTau0, DiagN=DiagN

   ;====================================================================
   ; Initialization
   ;====================================================================

   ; Keywords
   if ( N_Elements( InFile  ) eq 0 ) then Message, 'INFILE not passed!'
   if ( N_Elements( OutFile ) eq 0 ) then Message, 'OUTFILE not passed!'

   ; First-time flag
   FirstTime = 1L

   ; Get the spacing between diagnostic offsets 
   ; This is the same for all category names (bmy, 11/20/03)
   CTM_DiagInfo, 'IJ-AVG-$', Spacing=Spacing

   ;====================================================================
   ; Loop thru all of the INPUT FILES
   ;====================================================================

   ; Echo info to screen
   Print, 'Now Reading ' + StrTrim( InFile, 2 )
 
   ; Open the Nth INPUT FILE
   Open_File, InFile, Ilun, /F77, /Get_LUN
 
   ; Open the Nth INPUT FILE
   Open_File, OutFile, Ilun_OUT, /F77, /Get_LUN, /Write

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
 
   ;====================================================================
   ; Copy each data block for the given time to the OUTPUT FILE
   ;====================================================================
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
      
      ;=================================================================
      ; Write data to output file
      ;=================================================================

      ; Don't store high tracer numbers
      Tracer = Tracer mod 100L
      
      ; Logical flags
      IsGoodTau = 0
      IsGoodCat = 0

      ; If THISTAU0 is passed, then write data blocks w/ matching TAU0
      ; Otherwise, write all data blocks 
      if ( N_Elements( ThisTau0 ) gt 0 )        $
         then IsGoodTau = ( ThisTau0 eq Tau0 )  $
         else IsGoodTau = 1L

      ; If DIAGN is passed, then only write data blocks /w maching CATEGORY
      ; Otherwise, write all data blocks
      if ( N_Elements( DiagN ) gt 0 ) then begin
         Ind = Where( StrTrim( DiagN, 2 ) eq StrTrim( Category, 2 ) )
         if ( Ind[0] ge 0 ) then IsGoodCat = 1L
      endif else begin
         IsGoodCat = 1L
      endelse

      ; Write data if the TAU0 value matches
      if ( IsGoodTau and IsGoodCat ) then begin
         WriteU, Ilun_OUT, Modelname,Modelres,Mhalfpolar,Mcenter180
         WriteU, Ilun_OUT, Category,Tracer,Unit,Tau0,Tau1,Reserved,Dim,Skip
         WriteU, Ilun_OUT, Data         
      endif
 
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
      
   ; Close the INPUT FILE
   Close,    Ilun
   Free_LUN, Ilun

   ; Close the OUTPUT file
   Close,    Ilun_OUT
   Free_LUN, Ilun_OUT
 
end
 
 
 
