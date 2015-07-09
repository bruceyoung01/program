; $Id: ctm_sum_emissions.pro,v 1.4 2004/06/03 17:58:08 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        CTM_SUM_EMISSIONS
;
; PURPOSE:
;        Computes totals of emissions in Tg [or Tg C] for the
;        following diagnostics: ND28, ND29, ND32, ND36, ND46, ND13, etc.
;
; CATEGORY:
;        CTM Tools
;
; CALLING SEQUENCE:
;        CTM_SUM_EMISSIONS, DIAGN [, Keywords ]
;
; INPUTS:
;        DIAGN -> A diagnostic category name to restrict 
;             the record selection (default is "ANTHSRCE").
;
; KEYWORD PARAMETERS:
;        FILENAME -> Punch file (ASCII or Binary) from which to 
;             read CTM emissions data.  If omitted, the user
;             will be prompted to select a file via a dialog box.
;
;        TRACER -> The tracer number (or a 1-D array of tracer
;             numbers) to compute emission totals for.
;
;        /CUM_ONLY -> If this switch is set, SUM_EMISSIONS will
;             only print out cumuluative totals (and skip individual
;             totals for each data block).
;
;        RESULT -> An array of structures (tag names: NAME, SUM, UNIT) 
;             that returns, the name of each tracer, its cumulative
;             total, and its unit to the calling program.
;           
;        /NO_SECONDS -> Set this switch if the data to be summed is
;             independent of seconds (e.g. molec/cm2).  CTM_SUM_EMISSIONS
;             will not multiply the data by the number of seconds in the 
;             interval when converting to Tg.
;
;        /KG -> Set this switch if the data to be summed is in kg
;             instead of molec/cm2 or molec/cm2/s.  CTM_SUM_EMISSIONS
;             will not multiply the data by the surface area of each
;             grid box when converting to Tg.
;
;        _EXTRA=e -> Picks up any extra keywords for CTM_GET_DATA
;             or CTM_TRACERINFO.
; 
; OUTPUTS:
;        Prints totals in Tg or Tg C for each tracer to the screen
;
; SUBROUTINES:
;        Internal Subroutines:
;        ==================================================
;        CSE_GetUnit (function)  CSE_GetAreaCm2 (function)
;        CSE_GetInfo
;
;        External Subroutines Required:
;        ==================================================
;        CTM_DIAGINFO            CTM_TRACERINFO
;        CTM_GETDATA             CTM_BOXSIZE    (function)
;        CTM_GRID    (function)  GAMAP_CMN
;        TAU2YYMMDD  (function)  UNDEFINE
;
; REQUIREMENTS:
;        References routines from both GAMAP and TOOLS packages.
;
; NOTES:
;        (1) Most of the time there will be 1 data block per month,
;            and the cumulative total will be a yearly total.
;
;        (2) For NOx, a molecular weight of 14e-3 kg/mole will report
;            results in Tg N.  A molecular weight of 46e-3 will report
;            results in Tg NOx.  This can be changed in the file
;            "tracerinfo.dat".
;
;        (3) Should now be compatible with any model type and grid
;            resolution.  As of 6/19/01, has only been tested using
;            GEOS-CHEM diagnostic output.
;   
; EXAMPLE:
;        CTM_SUM_EMISSIONS, 'ANTHSRCE', $
;                           FILENAME='ctm.bpch', TRACER=1, $
;                           MODELNAME='GEOS1', RESOLUTION=4
;
;             ; Will print emission totals for tracer #1 (NOx)
;             ; for the ANTHSRCE (ND36) diagnostic, using data
;             ; in file "ctm.bpch".  The data is from a GEOS-1 
;             ; simulation on a 4x5 grid.
;
; MODIFICATION HISTORY:
;        bmy, 26 Apr 2001: GAMAP VERSION 1.47
;        bmy, 08 Jun 2001: - now uses correct tracer name, unit,
;                            and molecular weight for CO--SRCE
;        bmy, 19 Jun 2001: GAMAP VERSION 1.48
;                          - added internal function CSE_GETUNIT
;                            to return the proper unit string
;                            ("Tg N", "Tg C", or "Tg").
;                          - added internal function CSE_GETAREACM2
;                            which gets the proper surface area
;                            for each data block
;                          - removed MODELNAME, RESOLUTION keywords
;        bmy, 03 Jul 2001: - now can sum emissions from GENERIC grids
;        bmy, 16 Aug 2001: - added /NO_SECONDS and /KG keywords
;        bmy, 26 Sep 2001: GAMAP VERSION 1.49
;                          - set XNUMOL = 1d-3 if /KG is set; this
;                            will convert from g/cm2 to Tg correctly
;        bmy, 21 Nov 2001: - added internal routine CSE_GETINFO
;                          - now call CTM_EXTRACT to restrict the
;                            totaling to any arbitrary lat/lon rectangle
;        bmy, 10 Jan 2002: GAMAP VERSION 1.50
;                          - Bug fix: Don't call CTM_EXTRACT if /KG is, 
;                            set, since AREACM2 will be 1 in that case 
;        bmy, 31 Jan 2002: - change output format from f10.4 to f12.4
;        bmy, 10 Jun 2002: GAMAP VERSION 1.51
;                          - added "kludge" for biomass burning files
;                            if /NO_SECONDS is set; will use proper
;                            mol wts & units for ACET, C3H8, C2H6
;        bmy, 14 Jan 2003: GAMAP VERSION 1.52
;                          - added another quick fix to get the unit strings
;                            correct for sulfate and nitrogen tracers for ND13
;        bmy, 19 Sep 2003: GAMAP VERSION 1.53
;                          - now call PTR_FREE to free the pointer memory
;        bmy, 19 Nov 2003: GAMAP VERSION 2.01
;                          - now get the spacing between diagnostic
;                            offsets from CTM_DIAGINFO
;        bmy, 26 Mar 2004: GAMAP VERSION 2.02
;                          - added FORMAT keyword
;
;-
; Copyright (C) 2001-2004, Bob Yantosca, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author.
; Bugs and comments should be directed to bmy@io.harvard.edu
; with subject "IDL routine ctm_sum_emissions"
;-----------------------------------------------------------------------


function CSE_GetUnit, TracerName, MolWt, CarbonNum

   ;====================================================================
   ; Internal function GetUnit returns the correct unit 
   ; (Tg N, Tg, or Tg C) for the given tracer.
   ;====================================================================

   case ( StrUpCase( StrTrim( TracerName, 2 ) ) ) of 

      ; First check NOx for Tg NOx or Tg N, depending on the
      ; molecular weight specified in "tracerinfo.dat"
      'NOX'  : begin
                  if ( MolWt gt 14.0 )   $ 
                    then Unit = 'Tg NOx' $
                    else Unit = 'Tg N'
               end
            
      'NH3'  : begin
                  if ( MolWt gt 14.0 )   $ 
                    then Unit = 'Tg NH3' $
                    else Unit = 'Tg N'
               end

      'NH4'  : begin
                  if ( MolWt gt 14.0 )   $ 
                    then Unit = 'Tg NH4' $
                    else Unit = 'Tg N'
               end

      'NIT'  : begin
                  if ( MolWt gt 14.0 )   $ 
                    then Unit = 'Tg NIT' $
                    else Unit = 'Tg N'
               end

      'SO2'  : begin
                  if ( MolWt gt 32.0 )   $ 
                    then Unit = 'Tg' $
                    else Unit = 'Tg S'
               end

      'SO4'  : begin
                  if ( MolWt gt 32.0 )   $ 
                    then Unit = 'Tg' $
                    else Unit = 'Tg S'
               end

      'DMS'  : begin
                  if ( MolWt gt 32.0 )   $ 
                    then Unit = 'Tg' $
                    else Unit = 'Tg S'
               end
   
      ; If the Carbon number listed in "tracerinfo.dat" > 1, then 
      ; the tracer is carried as molecules of carbon.  Otherwise it 
      ; is carried as molecules of tracer.
      else   : begin
                  if ( CarbonNum gt 1.0 ) $
                     then Unit = 'Tg C'   $
                     else Unit = 'Tg'
               end
   endcase

   ; Return to main program
   return, Unit

end

;-----------------------------------------------------------------------------

pro CSE_GetInfo, ThisDataInfo, ModelInfo, GridInfo

   ;====================================================================
   ; Internal subroutine CSE_GetInfo returns the MODELINFO and 
   ; GRIDINFO structures for a given data block (bmy, 11/21/01)
   ;====================================================================

   ; Include GAMAP common block
   @gamap_cmn

   ; Get the global FILEINFO structure
   FileInfo  = *( PGlobalFileInfo )
   
   ; Find out the FILEINFO entry that matches THISDATAINFO
   Ind       = Where( FileInfo.Ilun eq ThisDataInfo.Ilun )

   ; Error check
   if ( Ind[0] lt 0 ) then begin
      Message, 'FILEINFO and DATAINFO are not consistent!'
   endif
   
   ; Get MODELINFO & GRIDINFO structures
   ; If MODELINFO.NLAYERS = 0, CTM_TYPE will automatically return
   ; a GRIDINFO structure w/ no vertical layer info (bmy, 7/3/01)
   ModelInfo = FileInfo[Ind].ModelInfo
   GridInfo  = CTM_Grid( ModelInfo ) 

   ; Return to calling program
   return

end

;-----------------------------------------------------------------------------

function CSE_GetAreaCm2, ThisDataInfo

   ;====================================================================
   ; Internal subroutine CSE_GetAreaCm2 computes the grid box surface
   ; areas in cm2.  CSE_GetAreaCm2 gets the proper surface area that
   ; corresponding to each data block's model type and grid resolution.
   ;====================================================================

   ; Get MODELINFO and GRIDINFO structures for this data block
   CSE_GetInfo, ThisDataInfo, ModelInfo, GridInfo

   ; Get surface area in cm2
   ; For generic grid, use same radius as for GEOS grid (bmy, 7/2/01)
   GEOS      = ( ModelInfo.Family eq 'GEOS' OR ModelInfo.Family eq 'GENERIC' )
   GISS      = ( ModelInfo.Family eq 'GISS' )
   FSU       = ( ModelInfo.Family eq 'FSU'  )
   AreaCm2   = CTM_BoxSize( GridInfo, GEOS=GEOS, GISS=GISS, FSU=FSU, /Cm2 )

   ; Undefine stuff for safety's sake
   UnDefine, FileInfo
   UnDefine, ModelInfo
   UnDefine, GridInfo
   UnDefine, GEOS
   UnDefine, GISS
   UnDefine, FSU

   ; Return to main program   
   return, AreaCm2
end

;-----------------------------------------------------------------------------

pro CTM_Sum_Emissions, DiagN,                                $
                       FileName=FileName,     Tracer=Tracer, $
                       Cum_Only=Cum_Only,     Result=Result, $
                       No_Seconds=No_Seconds, Kg=Kg,         $
                       Format=Format,         _EXTRA=e
 
   ; External functions
   FORWARD_FUNCTION CTM_BoxSize, Tau2YYMMDD, CSE_GetUnit, CSE_GetAreaCm2

   ;====================================================================
   ; Keyword Settings
   ;====================================================================
   if ( N_Elements( ModelName  ) ne 1 ) then ModelName  = 'GEOS1'
   if ( N_Elements( Resolution ) ne 1 ) then Resolution = 4 
   if ( N_Elements( DiagN      ) ne 1 ) then DiagN      = 'ANTHSRCE'
   if ( N_Elements( Tracer     ) eq 0 ) then Tracer     = 1L
   if ( N_Elements( Format     ) ne 1 ) then Format     = '(f12.4)'
   Kg         = Keyword_Set( Kg         )
   No_Seconds = Keyword_Set( No_Seconds )

   ; Diagnostic category
   DiagN  = StrUpCase( StrTrim( DiagN, 2 ) )

   ; Define output structure
   Result = Replicate( { Name : '', $
                         Sum  : 0e0, $
                         Unit : ''   }, N_Elements( Tracer ) )
   
   ;====================================================================
   ; Read data and compute totals
   ;====================================================================
 
   ; Get diagnostic offset & spacing from the "diaginfo.dat" file
   CTM_DiagInfo, DiagN, Offset=Offset, Spacing=Spacing

   ; Loop over tracers
   for T = 0L, N_Elements( Tracer ) - 1L do begin
 
      ;------------------------------------------------------
      ; Prior to 11/19/03:
      ;; Store temporary tracer # -- make sure it's not a multiple of 100
      ;TmpTracer = Tracer[T] mod 100L
      ;------------------------------------------------------
      ; Store temporary tracer # -- 
      ; make sure it's not a multiple of SPACING
      TmpTracer = Tracer[T] mod Spacing

      ; Read all datablocks for this tracer
      CTM_Get_Data, DataInfo, DiagN, FileName=FileName, Tracer=TmpTracer

      ; Error check -- skip to next tracer
      if ( N_Elements( DataInfo ) eq 0 ) then begin
         Result[T].Name = 'Undefined'
         Result[T].Sum  = 0d0
         Result[T].Unit = ''
         goto, Next_T
      endif

      ; Find the molecular weight, tracer name, and the 
      ; carbon number (for lumped species) from "tracerinfo.dat" 
      CTM_TracerInfo, TmpTracer+Offset, $
         MolWt=MolWt, Name=TracerName, MolC=CarbonNum

      ; Define some more variables
      Running_Total = 0d0
      This_Total    = DblArr( N_Elements( DataInfo ) )

      ; Loop fover each data block (usually 1 per month) for this tracer
      for D = 0L, N_Elements( DataInfo ) - 1L do begin 

         ; XNUMOL  = molec tracer / kg tracer
         ; AREACM2 = grid box surface area (cm2)
         ; If data is already in kilograms, set these to 1
         if ( Kg ) then begin
            XNumol  = 1d0
            AreaCm2 = 1d0                 
         endif else begin

            ;### Kludge -- for the "raw" biomass burning files, 
            ;### ACET, C3H8, and C2H6 are in Tg and not Tg C.
            ;### We must use the proper molecular weights...
            if ( No_Seconds ) then begin
               if ( StrTrim( DataInfo[D].Category, 2 ) eq 'BIOBSRCE' ) $
                  then begin
                  case ( TracerName ) of
                     'ACET' : MolWt = 58d-3
                     'C3H8' : MolWt = 44d-3
                     'C2H6' : MolWt = 30d-3
                     else   : ;nothing
                  endcase
               endif
            endif

            ; For tracers that have units of total biomass burned,
            ; then XNUMOL has to be 1d-3, in order to convert to Tg
            ; Otherwise XNUMOL is Molwt / Avogadro's number (bmy, 9/26/01)
            if ( StrLowCase( StrTrim( DataInfo[D].Unit, 2 ) ) eq 'g/cm2' ) $
               then XNumol = 1d-3                                          $
               else XNumol = ( MolWt / 6.023d23 )
               
            AreaCm2 = CSE_GetAreaCm2( DataInfo[D] )
         endelse

         ; Number of seconds in this diagnostic interval, if necessary
         if ( No_Seconds )                                                   $
            then Seconds = 1d0                                               $
            else Seconds = ( DataInfo[D].Tau1 - DataInfo[D].Tau0 ) * 3600.0d0

         ;-----------------------------------------------
         ; Prior to 9/18/03:
         ;; Pick off this data block
         ;Data    = *( DataInfo[D].Data )
         ;-----------------------------------------------

         ; Pointer to the data
         Pointer = DataInfo[D].Data

         ; Dereference the pointer to get the data
         Data    = *( Pointer )
         
         ; Free the memory pointed to by the pointer
         Ptr_Free, Pointer

         ; Get MODELINFO and GRIDINFO structures 
         CSE_GetInfo, DataInfo[D], ModelInfo, GridInfo

         ; Resize the DATA array if necessary
         Data    = CTM_Extract( Data,                    $
                                ModelInfo=ModelInfo,     $
                                GridInfo=GridInfo,       $
                                First=DataInfo[D].First, $
                                _EXTRA=e )

         ; Resize the AREACM2 array if necessary
         ; Bug fix: Don't call CTM_EXTRACT if /KG is set, 
         ; since AREACM2 will be 1 in that case (bmy, 1/10/02)
         if ( not Kg ) then begin
            AreaCm2 = CTM_Extract( AreaCm2,                 $
                                   ModelInfo=ModelInfo,     $
                                   GridInfo=GridInfo,       $
                                   First=DataInfo[D].First, $
                                   _EXTRA=e )
         endif
         
         ; Get number of dimensions of resized data array
         SData   = Size( Data, /Dim )

         ; Handle 2-D or 3-D array separately
         case ( N_Elements( SData ) ) of 
 
            3: begin
               for L = 0L, SData[2] - 1L do begin
                  ; Convert from molec/cm2/s to molec/s
                  Data[*,*,L] = ( Data[*,*,L] * AreaCm2 ) 
                  
                  ; Convert from molec/s to Tg 
                  Data[*,*,L] = Data[*,*,L] * ( XNumol * Seconds * 1d-9 )
               endfor
            end

            else: begin
         
               ; Convert from molec/cm2/s to molec/s
               Data = ( Temporary( Data ) * AreaCm2 ) 
 
               ; Convert from molec/s to Tg 
               Data = Temporary( Data ) * ( XNumol * Seconds * 1d-9 )

            end

         endcase
            
         ; Save total for this data block
         This_Total[D] = Total( Data )
 
         ; Save cumulative total
         Running_Total = Temporary( Running_Total ) + This_Total[D]

         ; Undefine stuff for safety's sake
         UnDefine, AreaCm2
         UnDefine, ModelInfo
         UnDefine, GridInfo
      endfor

      ; Get the proper unit string (Tg N, Tg C, or Tg) 
      ; NOTE: If the UNIT is contained w/in the punch file, use that!
      Unit = CSE_GetUnit( TracerName, MolWt, CarbonNum )

      ;### Kludge -- for the "raw" biomass burning files, 
      ;### ACET, C3H8, and C2H6 are in Tg and not Tg C.
      ;### We must use the proper unit strings...
      if ( No_Seconds AND StrUpCase( DiagN ) eq 'BIOBSRCE' ) then begin
         case ( TracerName ) of
            'ACET' : Unit = 'Tg'
            'C3H8' : Unit = 'Tg'
            'C2H6' : Unit = 'Tg'
            else   : ;nothing
         endcase
      endif

      ;### Another Kludge -- for ND13 diagnostic make sure we have the
      ;### right labels for sulfates (Tg S) and for nitrogen species
      ;### (Tg). (bmy, 1/14/03)
      if ( No_Seconds and Kg ) then begin
         case ( TracerName ) of
            'DMS' : Unit = 'Tg S'
            'SO2' : Unit = 'Tg S'
            'SO4' : Unit = 'Tg S'
            'MSA' : Unit = 'Tg S'
            'NH3' : Unit = 'Tg'
            'NH4' : Unit = 'Tg'
            'NIT' : Unit = 'Tg'
            else  : ; Nothing
         endcase
      endif
      

      ;=================================================================
      ; Print totals 
      ;=================================================================
 
      ; Title string (includes cumulative total)
      S = 'Category: '      + String( DiagN,         Format='(a8)'    ) + $
          '    Tracer: '    + String( TracerName,    Format='(a6)'    ) + $
;----------------------------------------------------------------------------
; Prior to 3/26/04:
; Now use FORMAT string passed as keyword (bmy, 3/26/04)
;          '    Cum Total: ' + String( Running_Total, Format='(f12.4)') + $
;----------------------------------------------------------------------------
          '   Cum Total: '  + String( Running_Total, Format=Format    ) + $
          ' '               + Unit
      print
      print, S

      ; Print totals for each data block (usually 1/month)     
      ; only if keyword CUM_ONLY is not set
      if ( not Keyword_Set( Cum_Only ) ) then begin
         
         print, '-------------------------------------', $
                '-------------------------------------'

         for D = 0L, N_Elements( This_Total ) - 1L  do begin
            Tau0 = DataInfo[D].Tau0
            Nymd = ( Tau2YYMMDD( Tau0, /GEOS, /NFormat ) )[0]
         
            S = 'TAU0 = '      + String( Tau0,          Format='(f10.2)' ) + $
               ',    NYMD = '  + String( Nymd,          Format='(i8.8)'  ) + $
;------------------------------------------------------------------------------
; Prior to 3/26/04:
; Now use FORMAT string passed as keyword (bmy, 3/26/04)
;               ',    Total = ' + String( This_Total[D], Format='(f12.4)'  ) + $
;------------------------------------------------------------------------------
               ',    Total = ' + String( This_Total[D], Format=Format    ) + $
               ' '             + Unit
            
            print, S
         endfor
      endif

      ;=================================================================
      ; Append cumulative totals into the RESULT array
      ;=================================================================
      Result[T].Name = TracerName
      Result[T].Sum  = Running_Total
      Result[T].Unit = Unit
      
      ;=================================================================
      ; Undefine variables for safety's sake
      ;=================================================================
Next_T:
      UnDefine, DataInfo
      UnDefine, Data
      UnDefine, Running_Total
      UnDefine, This_Total
      UnDefine, XNumol
      UnDefine, TracerName
      UnDefine, MolWt
   endfor
 
   ; Quit
   return
end
