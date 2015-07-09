; $Id: bpch_sep.pro,v 1.2 2008/04/02 15:19:01 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        BPCH_SEP
;
; PURPOSE:
;        Separates data from one binary punch file into another binary 
;        punch file by time (TAU0), tracer, or location indices.  Useful 
;        for making smaller bpch files so that we don't run out of IDL 
;        memory when reading/processing them.
;
; CATEGORY:
;        File & I/O, BPCH Format
;
; CALLING SEQUENCE:p
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
;        TRACER -> Tracer number(s) for which to save to OUTFILE.  
;             Default is to save all tracers.
;
;        II, JJ, KK -> Longitude, latitude, altitude index arrays used
;             to cut down the data block to less than global size.
;
; OUTPUTS:
;        None
;
; SUBROUTINES:
;        External Subroutines Required:
;        ===============================================
;        CTM_DIAGINFO    LITTLE_ENDIAN (function)
;        OPEN_FILE       UNDEFINE 
;
; REQUIREMENTS:
;        None
;
; NOTES:
;        (1) Assumes that II, JJ, LL contain consecutive indices in
;            longitude, latitude, and altitude, respectively.
;
;        (2) Also assumes that II, JJ, LL are in IDL notation
;            (i.e. starting from zero).  This is so that you can
;            pass the output from the WHERE command to BPCH_SEP.
;
; EXAMPLES:
;        (1)
;        BPCH_SEP, 'ctm.bpch.big', 'ctm.bpch.small', tau0=140256D
;
;             ; Pulls out data blocks for TAU0=140256 (1/1/2001) from
;             ; "ctm.bpch.big" and saves them in "ctm.bpch.small"
;
;
;        (2) 
;        INTYPE = CTM_TYPE( 'GEOS4', RES=4 )
;        INGRID = CTM_GRID( INTYPE )
;  
;        INDX = WHERE( INGRID.XMID ge -60 AND INGRID.XMID le 60 )
;        INDY = WHERE( INGRID.YMID ge   0 AND INGRID.YMID le 60 )
;         
;        BPCH_SEP, 'ctm.bpch.big', 'ctm.bpch.small', II=INDX, JJ=INDY
;
;             ; Pulls out all data blocks for the geographical area
;             ; from 60W - 60E longitude and 0-60N latitude.
;
; MODIFICATION HISTORY:
;        bmy, 18 Sep 2003: GAMAP VERSION 1.53
;        bmy, 20 Nov 2003: GAMAP VERSION 2.01
;                          - now gets the spacing between diagnostic
;                            offsets from CTM_DIAGINFO
;        bmy, 07 Jul 2005: GAMAP VERSION 2.04
;                          - minor bug fix; now can save out data
;                            blocks for more than one matching TAU0
;        phs, 24 Oct 2006: GAMAP VERSION 2.05
;                          - Added the II, JJ, LL keywords for
;                            selecting a smaller geographical area.  
;                            These must be index arrays.
;                          - Added the TRACERN keyword
;                          - Added SWAP_ENDIAN=LITTLE_ENDIAN() in 
;                            the call to OPEN_FILE
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
;        bmy, 02 Apr 2008: GAMAP VERSION 2.12
;                          - Cosmetic changes
;
;-
; Copyright (C) 2002-2008, 
; Bob Yantosca and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of 
; this software. If this software shall be used commercially or 
; sold as part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.as.harvard.edu with subject "IDL routine bpch_sep"
;-----------------------------------------------------------------------


pro Bpch_Sep, InFile,      OutFile,                          $
              DiagN=DiagN, Tau0=ThisTau0, Tracer=ThisTracer, $
              II=II,       JJ=JJ,         LL=LL

   ;====================================================================
   ; Initialization
   ;====================================================================

   ; External functions
   FORWARD_FUNCTION Little_Endian

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
 
   ; Are we on a little-endian machine?
   SE = Little_Endian()

   ; Open the Nth INPUT FILE
   Open_File, InFile, Ilun, /F77, /Get_LUN, Swap_Endian=SE
 
   ; Open the OUTPUT FILE
   Open_File, OutFile, Ilun_OUT, /F77, /Get_LUN, /Write, Swap_Endian=SE

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
      ; Cut down the data block to size, if II, JJ, LL are passed
      ; (phs, bmy, 10/24/06)
      ;=================================================================

      ;-----------------------------------
      ; Select out elements in longitude
      ;-----------------------------------
      if ( N_Elements( II ) gt 0 ) then begin

         ; First check that JJ doesn't exceed the actual dimension
         Ind = Where( II gt Dim[0]-1L, C )

         ; Then cut down DATA in longitude and adjust size parameters
         if ( C eq 0 ) then begin
            Data   = Data[II,*,*]
            Dim[0] = N_Elements( II )
            Dim[3] = II[0] + 1L
         endif
      endif

      ;-----------------------------------
      ; Select out elements in latitude
      ;-----------------------------------
      if ( N_Elements( JJ ) gt 0 ) then begin

         ; First check that JJ doesn't exceed the actual dimension
         Ind = Where( JJ gt Dim[1]-1L, C )

         ; Then cut down DATA in latitude and adjust size parameters
         if ( C eq 0 ) then begin
            Data   = Data[*,JJ,*]
            Dim[1] = N_Elements( JJ )
            Dim[4] = JJ[0] + 1L
         endif
      endif

      ;-----------------------------------
      ; Select out elements in altitude
      ;-----------------------------------
      if ( N_Elements( LL ) gt 0 ) then begin

         ; First check that LL doesn't exceed the actual dimension
         Ind = Where( LL gt Dim[2]-1L, C )

         ; Then cut down DATA in altitude and adjust size parameters
         if ( C eq 0 ) then begin
            Data   = Data[*,*,LL]
            Dim[2] = N_Elements( LL ) 
            Dim[5] = LL[0] + 1L
         endif
      endif

      ; Reset the SKIP parameter for the new dimensions
      Skip = 4L * ( Dim[0] * Dim[1] * Dim[2] ) + 8L
            
      ;=================================================================
      ; Write data to output file
      ;=================================================================

      ; Don't store high tracer numbers
      Tracer = Tracer mod 100L
      
      ; Logical flags
      IsGoodTau = 0L
      IsGoodCat = 0L
      IsGoodTra = 0L

      ; If THISTAU0 is passed, then write all data blocks w/ matching TAU0
      ; If THISTAU0 is not passed, then write all data blocks regardless
      if ( N_Elements( ThisTau0 ) gt 0 )                     $
         then IsGoodTau = ( Where( ThisTau0 eq Tau0 ) ge 0 ) $
         else IsGoodTau = 1L

      ; If DIAGN is passed, then only write data blocks /w maching CATEGORY
      ; If DIAGN is not passed, then write all data blocks regardless
      if ( N_Elements( DiagN ) gt 0 ) then begin
         Ind = Where( StrUpCase( StrTrim( DiagN, 2 ) ) eq  $
                      StrUpCase( StrTrim( Category, 2 ) ) )
         if ( Ind[0] ge 0 ) then IsGoodCat = 1L
      endif else begin
         IsGoodCat = 1L
      endelse

      ; If THISTRACER is passed, then only write data blocks /w matching TRACER
      ; Otherwise, write all data blocks regardless (phs, bmy, 10/24/06)
      if ( N_Elements( ThisTracer ) gt 0 ) then begin
         Ind = Where( ThisTracer eq Tracer )
         if ( Ind[0] ge 0 ) then IsGoodTra = 1L
      endif else begin
         IsGoodTra = 1L
      endelse

      ; Write data if the TAU0, CATEGORY, and TRACER values match
      if ( IsGoodTau and IsGoodCat and IsGoodTra ) then begin
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
 
 
 
