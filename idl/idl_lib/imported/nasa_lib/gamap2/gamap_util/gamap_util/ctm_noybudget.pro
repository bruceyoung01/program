; $Id: ctm_noybudget.pro,v 1.1.1.1 2007/07/17 20:41:26 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        CTM_NOYBUDGET
;
; PURPOSE:
;        Computes the NOy budget within a given 3-D region.
;
; CATEGORY:
;        GAMAP Utilities, GAMAP Data Manipulation
;
; CALLING SEQUENCE:
;        CTM_NOYBUDGET [, BATCHFILE [, Keywords ] ]
;
; INPUTS:
;        BATCHFILE (optional) -> Name of the batch file which 
;             contains inputs that defines the 3-D region and NOy
;             constituents.  If BATCHFILE is omitted, then the user
;             will be prompted to supply a file name via a dialog box.
;
; KEYWORD PARAMETERS:
;        LOGFILENAME (optional) -> Name of the log file where output 
;             will be sent.  Default is "noy_budget.log".
;
; OUTPUTS:
;        None
;
; SUBROUTINES:
;        Internal Subroutines:
;        --------------------------------------------------------------
;        ErrorNOy                       (function)
;        TruncateAndWrapForNOy          (function)
;        GetNoxEmissionsForNOy          (function)  
;        GetHNO3WetDepForNOy            (function)
;        GetDryDepositionForNOy         (function)  
;        GetNetExportForNOy             (function)
;        GetNetChemicalProductionForNOy (function)  
;        ReadBatchFileForNOy            (procedure)
;
;        External Subroutines:
;        --------------------------------------------------------------
;        CTM_Get_Datablock (function)  CTM_BoxSize (function)
;
; REQUIREMENTS:
;        None
;
; NOTES:
;        (1) CTM_NOYBUDGET was developed for use with the GEOS-CTM,
;            there might be some adaptation required for use with
;            other models.
;
;        (2) Only 5 "families" are considered: 
;            Dry Deposition, NOx, PAN, HNO3, R4N2.
;
;        (3) Wrapping around the date line seems to work but you
;            should always double-check.
;
; EXAMPLE:
;        CTM_NOYBUDGET, 'box1.dat', LogFileName='box1.log'
;           
;             ; Computes NOy budgets for the region specified in
;             ; the file "box1.dat" and sends output to the 
;             ; "box1.log" log file.
;
; MODIFICATION HISTORY:
;        bmy, 28 Jan 2000: VERSION 1.00
;                          - adapted original code from Isabelle Bey
;        bmy, 25 May 2000: VERSION 1.45
;                          - now allow the user to specify diagnostic
;                            category names in the batch file
;                          - added internal function "TruncateAndWrapForNOy"
;                            to wrap arrays around the date line
;                          - added internal procedure "ErrorNOy"
;                            to do error checking for CTM_GET_DATABLOCK
;                          - now can create budgets for more than one
;                            diagnostic interval
;                          - now allow user not to compute chemical 
;                            production data for given families
;        acs, 26 May 2000: - bug fixes: now do not stop the run if 
;                            data blocks are not found
;        bmy, 01 Aug 2000: VERSION 1.46
;                          - use abs( Total( X ) ) > 0 when testing if 
;                            transport fluxes are all nonzero
;        bmy, 24 Jan 2001: GAMAP VERSION 1.47
;                          - now no longer require all types of emissions
;                            to be nonzero in order to sum them
;                          - now no longer require both HNO3 LS and
;                            convective wetdep to be zero in order to 
;                            sum them
;        bmy, 17 Jan 2002: GAMAP VERSION 1.50
;                          - now call STRBREAK wrapper routine from
;                            the TOOLS subdirectory for backwards
;                            compatiblity for string-splitting
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
;
;-
; Copyright (C) 1999-2007, Martin Schultz,
; Bob Yantosca and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of 
; this software. If this software shall be used commercially or 
; sold as part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.harvard.edu with subject "IDL routine ctm_noybudget"
;-----------------------------------------------------------------------

pro ErrorNOy, Diag_Name, Tracer, Tau0, _EXTRA=e

   ;====================================================================
   ; Procedure "ErrorNOy" prints error output if CTM_GET_DATABLOCK
   ; cannot find a data block for a given diagnostic, tracer, & time.
   ;====================================================================

   ; Error string
   S = 'No data found!  Category = ' + StrTrim( Diag_Name, 2 )         + $
       ',  Tracer = ' + StrTrim( String( Tracer, Format='(i6)'  ), 2 ) + $
       ',  Tau0 = '   + StrTrim( String( Tau0, Format='(f10.2)' ), 2 )
   
   ; Display error and stop
   Message, S, _EXTRA=e
end

;-----------------------------------------------------------------------------

function TruncateAndWrapForNOy, Data, EW_Flux=EW_Flux, NS_Flux=NS_Flux
   
   ;====================================================================
   ; Function "TruncateAndWrapForNOy" truncates the DATA array to the
   ; size of the region specified by IMIN:IMAX, JMIN:JMAX, LMIN:LMAX.
   ; Also accounts for regions that span the date line.
   ;====================================================================
   common BoxNOy_Save, Imin, Imax, Jmin, Jmax, Lmin, Lmax, Seconds

   ; Get size of input data block
   SData = Size( Data, /Dim   )
   N_Dim = Size( Data, /N_Dim )

   ; Store IMAX, JMAX in temp variables
   TmpImax = Imax
   TmpJmax = Jmax
   TmpLmax = Lmax

   ; TMPLMAX should not exceed the actual 3rd dimension of the data!
   if ( N_Dim eq 3 ) then TmpLmax = TmpLmax < ( SData[2] - 1 ) 

   ; Add extra longitude element for EW fluxes
   if ( Keyword_Set( EW_Flux ) ) then TmpImax = ( TmpImax + 1 ) mod SData[0]

   ; Add extra latitude element for NS fluxes
   if ( Keyword_Set( NS_Flux ) ) then TmpJmax = ( TmpJmax + 1 ) < SData[1]
 
   ;====================================================================
   ; Here we are wrapping around the date line!
   ;====================================================================
   if ( Imin gt TmpImax ) then begin

      ; Get sections for world wrapping
      I1 = N_Elements( Data[ Imin:*,    Jmin, Lmin ] ) 
      I2 = N_Elements( Data[ 0:TmpImax, Jmin, Lmin ] )

      ; Size of NEWDATA array
      NI = I1 + I2
      NJ = TmpJmax - Jmin + 1
      if ( N_Dim eq 3 ) then NL = TmpLmax - Lmin + 1 

      ; Copy the proper elements of DATA into NEWDATA
      case ( N_Dim ) of

         ; Data is 1-D -- a vector
         1: begin
            NewData = DblArr( NI ) 

            NewData[0:I1-1 ] = Data[IMin:*]
            NewData[I1:NI-1] = Data[0:TmpIMax]
         end
 
         ; Data is 2-D -- a plane
         2: begin
            NewData = DblArr( NI, NJ )

            NewData[0:I1-1,  0:NJ-1] = Data[IMin:*,    Jmin:TmpJmax]
            NewData[I1:NI-1, 0:NJ-1] = Data[0:TMpImax, Jmin:TmpJmax]
         end

         ; Data is 3-D -- a cube
         3: begin
            NewData = DblArr( NI, NJ, NL )

            NewData[0:I1-1,  0:NJ-1, 0:NL-1] = $
               Data[Imin:*, Jmin:TmpJmax, Lmin:TmpLmax]

            NewData[I1:NI-1, 0:NJ-1, 0:NL-1] = $
               Data[0:TmpImax, Jmin:TmpJmax, Lmin:TmpLmax]
         end
      endcase

   ;====================================================================
   ; Here we are NOT wrapping around the date line!
   ;====================================================================
   endif else begin

      ; Copy the proper elements of DATA into NEWDATA
      case ( N_Dim ) of

         ; Data is 1-D -- a vector
         1: NewData = Double( Data[Imin:TmpImax] )            
        
         ; Data is 2-D -- a plane
         2: NewData = Double( Data[Imin:TmpImax, Jmin:TmpJmax] )
        
         ; Data is 3-D -- a cube
         3: NewData = Double( Data[IMin:TmpImax, Jmin:TmpJmax, Lmin:TmpLMax] )
      endcase

   endelse
      
   ; Return truncated and world-wrapped array
   return, NewData
end
 
;-----------------------------------------------------------------------------

function GetNOxEmissionsForNOy, FileName, Tau0, Diag_Names, Tracer
 
   ;====================================================================
   ; Function "GetNOxEmissionsForNOy" reads the punch file 
   ; and computes the total NOx emissions.
   ;
   ; NOTES: 
   ; (1) NOx emissions are originally in [molec/cm2/s],
   ;      and are converted to [GMol/day] here.
   ; (2) SECONDS is computed here and saved for later use.
   ; (3) Now all emissions no longer have to be nonzero to be counted.
   ;====================================================================
 
   common BoxNOy_Save, Imin, Imax, Jmin, Jmax, LMin, LMax, Seconds

   ; Number of seconds over all diagnostic periods
   Seconds  = 0D

   ; Avogadro's number
   Avo      = 6.023d23

   ; Summing variables
   Emi_Biom = 0D
   Emi_Soil = 0D
   Emi_Anth = 0D
   Emi_Airc = 0D
   Emi_Ligh = 0D

   ; Loop over all diagnostic intervals
   for T = 0L, N_Elements( Tau0 ) - 1L do begin

      ;=================================================================
      ; NOx from Anthropogenic sources in [molec/cm2/s]
      ;=================================================================
      Success = CTM_Get_DataBlock( Anthro, Diag_Names.NOx_Anthro, $
                                   GridInfo=GridInfo,             $
                                   Use_FileInfo=Use_FileInfo,     $
                                   Use_DataInfo=Use_DataInfo,     $
                                   ThisDataInfo=ThisDataInfo,     $
                                   Tracer=Tracer,                 $ 
                                   Tau0=Tau0[T],                  $
                                   FileName=FileName )

      ; Error checking 
      if ( not Success ) then begin
         ErrorNOy, Diag_Names.NOX_Anthro, Tracer, Tau0[T], /Continue

         ; If not found, set to zero (acs, 5/26/00)
         Anthro = 0D
      endif else begin
         ; Truncate to size of region (and wrap around the date line!)
         Anthro = TruncateAndWrapForNOy( Anthro )
      endelse
 
      ; Surface areas in cm2 -- only compute on the first iteration
      if ( T eq 0L ) then begin
         A_Cm2 = CTM_BoxSize( GridInfo, /GEOS, /Cm2 )
            
         ; Truncate to size of region (and wrap around the date line!)
         A_Cm2 = TruncateAndWrapForNOy( A_Cm2 )
      endif

      ; Total number of seconds over all diagnostic periods
      Seconds = Seconds + ( ThisDataInfo.Tau1 - ThisDataInfo.Tau0 ) * 3600d0

      ; Convert emissions from [molec/cm2/s] to [moles/s]
      if ( Total( Anthro ) gt 0 ) then begin
         S = Size( Anthro, /Dim )
         for L = 0, S[2]-1  do begin
            Anthro[*, *, L] = Anthro[*, *, L] * A_Cm2[*, *] / Avo
         endfor
      endif 
         
      ; ANTHRO is a surface array, don't count it
      ; unless the budget box reaches the surface
      if ( Lmin ne 0 ) then Anthro = 0d0

      ; Sum emissions -- Multiply [moles/s] by 8.64d-5 to get [GMol/day] 
      Emi_Anth = Emi_Anth + ( Total( Anthro ) * 8.64d-5 )       
      
      ;=================================================================
      ; NOx from Biomass Burning in [molec/cm2/s]
      ;=================================================================
      Success = CTM_Get_DataBlock( BioMass, Diag_Names.NOX_BioMass, $
                                   Use_FileInfo=Use_FileInfo,       $
                                   Use_DataInfo=Use_DataInfo,       $
                                   Tracer=Tracer,                   $
                                   Tau0=Tau0[T],                    $
                                   FileName=FileName )
      
      ; Error checking 
      if ( not Success ) then begin
         ErrorNOy, Diag_Names.NOX_BioMass, Tracer, Tau0[T], /Continue
         
         ; If not found, set to zero
         BioMass = 0D
      endif else begin
         ; Truncate to size of region (and wrap around the date line!)
         BioMass = TruncateAndWrapForNOy( BioMass )
      endelse

      ; Convert emissions from [molec/cm2/s] to [moles/s]
      if ( Total( BioMass ) gt 0 ) then BioMass = ( BioMass * A_Cm2 ) / Avo 

      ; BIOMASS is a surface array, don't count it
      ; unless the budget box reaches the surface
      if ( Lmin ne 0 ) then Biomass = 0d0
         
      ; Sum emissions -- Multiply [moles/s] by 8.64d-5 to get [GMol/day] 
      Emi_Biom = Emi_Biom + ( Total( BioMass ) * 8.64d-5 )

      ;=================================================================
      ; NOx from Aircraft Emissions in [molec/cm2/s] 
      ;=================================================================
      Success = CTM_Get_DataBlock( AirCraft, Diag_Names.NOX_AirCraft, $
                                   Use_FileInfo=Use_FileInfo,         $
                                   Use_DataInfo=Use_DataInfo,         $
                                   Tracer=Tracer,                     $
                                   Tau0=Tau0[T],                      $
                                   FileName=FileName )
 
      ; Error checking 
      if ( not Success ) then begin
         ErrorNOy, Diag_Names.NOX_AirCraft, Tracer, Tau0[T]

         ; If not found, set to zero
         AirCraft = 0D 
      endif else begin
         ; Truncate to size of region (and wrap around the date line!)
         AirCraft = TruncateAndWrapForNOy( AirCraft )
      endelse

      ; Convert emissions from [molec/cm2/s] to [moles/s]
      if ( Total( AirCraft ) gt 0 ) then begin
         S = Size( Aircraft, /Dim )
         for L = 0, S[2]-1 do begin
            AirCraft[*, *, L] = AirCraft[*, *, L] * A_Cm2[*, *] / Avo 
         endfor 
      endif

      ; Sum emissions -- Multiply [moles/s] by 8.64d-5 to get [GMol/day] 
      Emi_Airc = Emi_Airc + ( Total( AirCraft ) * 8.64d-5 )

      ;=================================================================
      ; NOx from Soils in [molec/cm2/s]
      ;=================================================================
      Success = CTM_Get_DataBlock( Soils, Diag_Names.NOX_Soil, $
                                   Use_FileInfo=Use_FileInfo,  $
                                   Use_DataInfo=Use_DataInfo,  $ 
                                   Tracer=Tracer,              $
                                   Tau0=Tau0[T],               $
                                   FileName=FileName )
      ; Error checking 
      if ( not Success ) then begin
         ErrorNOy, Diag_Names.NOX_Soil, Tracer, Tau0[T], /Continue

         ; If not found, set to zero
         Soils = 0D 
      endif else begin
         ; Truncate to size of region (and wrap around the date line!)
         Soils = TruncateAndWrapForNOy( Soils )
      endelse

      ; Convert emissions from [molec/cm2/s] to [moles/s]
      if ( Total( Soils) gt 0 ) $
         then Soils = ( Soils * A_Cm2 ) / Avo 

      ; SOILS is a surface array, don't count it
      ; unless the budget box reaches the surface
      if ( Lmin ne 0 ) then Soils = 0d0
         
      ; Sum emissions - Multiply [moles/s] by 8.64d-5 to get [GMol/day] 
      Emi_Soil = Emi_Soil + ( Total( Soils ) * 8.64d-5 )

      ;=================================================================
      ; NOx from Lightning in [molec/cm2/s]
      ;=================================================================
      Success = CTM_Get_DataBlock( Lightning, Diag_Names.NOX_Lightning, $
                                   Use_FileInfo=Use_FileInfo,           $
                                   Use_DataInfo=Use_DataInfo,           $
                                   Tracer=Tracer,                       $
                                   Tau0=Tau0[T],                        $
                                   FileName=FileName )
 
      ; Error checking 
      if ( not Success ) then begin
         ErrorNOy, Diag_Names.NOX_Lightning, Tracer, Tau0[T], /Continue
         
         ; If not found, set to zero (acs, 5/26/00)
         Lightning = 0D
      endif else begin
         ; Truncate to size of region (and wrap around the date line!)
         Lightning = TruncateAndWrapForNOy( Lightning )
      endelse

      ; Convert emissions from [molec/cm2/s] to [moles/s]
      if ( Total( Lightning ) gt 0 ) then begin
         S = Size( Lightning, /Dim )
         for L = 0, S[2]-1 do begin
            Lightning[*, *, L] = Lightning[*, *, L] * A_Cm2[*, *] / Avo 
         endfor 
      endif

      ; Sum emissions - Multiply [moles/s] by 8.64d-5 to get [GMol/day] 
      Emi_Ligh = Emi_Ligh + ( Total( Lightning ) * 8.64d-5 )
   endfor
 
   ;====================================================================
   ; Create a structure to hold the totals and overall sum
   ; Return to calling program
   ;
   ; Also save out the seconds in the diagnostic interval
   ; for future reference (in the common block)
   ;====================================================================
   Result = { BioMass   : Emi_Biom, $
              Soils     : Emi_Soil, $
              Anthro    : Emi_Anth, $
              AirCraft  : Emi_Airc, $
              Lightning : Emi_Ligh, $
              Total     : Emi_Biom + Emi_Soil + $
                          Emi_Anth + Emi_Airc + Emi_Ligh }
  
   return, Result
end
 
;-----------------------------------------------------------------------------
 
function GetHNO3WetDepForNOy, FileName, Tau0, Diag_Names, Tracer
 
   ;====================================================================
   ; Function "GetHNO3WetDepForNOy" reads the punch file and computes
   ; the total HNO3 wet deposition (from both large-scale and moist-
   ; convective processes).
   ;
   ; NOTE: Wet deposition of HNO3 is originally in [kg/s],
   ;       and is converted to [Gmol/day] here.
   ;====================================================================
   common BoxNOy_Save, Imin, Imax, Jmin, Jmax, LMin, LMax, Seconds
 
   ; Summing variables
   Tot_WetMC = 0D
   Tot_WetLS = 0D

   ; Loop over all diagnostic intervals
   for T = 0L, N_Elements( Tau0 ) - 1L do begin

      ;=================================================================
      ; Get wet deposition of HNO3 in moist convection in [kg/s]
      ;=================================================================
      Success = CTM_Get_DataBlock( WetMC, Diag_Names.CV_WetDep, $
                                   Use_FileInfo=Use_FileInfo,   $
                                   Use_DataInfo=Use_DataInfo,   $
                                   GridInfo=GridInfo,           $
                                   Tracer=Tracer,               $
                                   Tau0=Tau0[T],                $
                                   FileName=FileName )
  
      ; Error checking 
      if ( not Success ) then begin
         ErrorNOy, Diag_Names.CV_WetDep, Tracer, Tau0[T], /Continue

         ; If not found, set to zero (acs, 5/26/00)
         WetMC = 0D
      endif else begin
         ; Truncate to size of region (and wrap around date line!)
         WetMC = TruncateAndWrapForNOy( WetMC )
      endelse

      ; Convert from [kg/s] to [moles/s] 
      WetMC = WetMC / 63d-3
      
      ; Sum emissions -- multiply [moles/s] by 8.64d-5 to get [Gmol/day]
      Tot_WetMC = Tot_WetMC + ( Total( WetMC ) * 8.64d-5 )

      ;=================================================================
      ; Get large scale loss of HNO3 in [kg/s]
      ;=================================================================
      Success = CTM_Get_DataBlock( WetLS, Diag_Names.LS_WetDep, $
                                   Use_FileInfo=Use_FileInfo,   $ 
                                   Use_DataInfo=Use_DataInfo,   $
                                   Tracer=Tracer,               $
                                   Tau0=Tau0[T],                $
                                   FileName=FileName )
 
      ; Error checking 
      if ( not Success ) then begin
         ErrorNOy, Diag_Names.LS_WetDep, Tracer, Tau0[T], /Continue
         
         ; If not found, set WETLS to zero (acs, 5/26/00)
         WetLS = 0D
      endif else begin 
         ; Truncate to size of region (and wrap around date line!)
         WetLS = TruncateAndWrapForNOy( WetLS )
      endelse
 
      ; Convert from [kg/s] to [moles/s] 
      WetLS = WetLS / 63d-3
 
      ; Sum emissions -- multiply [moles/s] by 8.64d-5 to get [Gmol/day]
      Tot_WetLS = Tot_WetLS + ( Total( WetLS ) * 8.64d-5 )

   endfor

   ;====================================================================
   ; Create a structure to hold the total wet deposition
   ; Return to calling program
   ;====================================================================
   Result = { MoistConv  : Tot_WetMC, $
              LargeScale : Tot_WetLS, $
              Total      : Tot_WetMC + Tot_WetLS }
 
   return, Result
end
 
;-----------------------------------------------------------------------------
 
function GetDryDepositionForNOy, FileName, Tau0, DryDep_Name, Name, Tracer
   
   ;====================================================================
   ; Function "GetDryDepositionForNOy" reads the punch file and computes
   ; the combined dry deposition losses of all NOy species.
   ;
   ; NOTE: Dry deposition fluxes are originally in [molec/cm2/s]
   ;       and are converted to [Gmol/day] here.
   ;====================================================================
   common BoxNOy_Save, Imin, Imax, Jmin, Jmax, LMin, LMax, Seconds
 
   ; Avogadro's number
   Avo = 6.023d23 
 
   ; RESULT is an array of structures to hold the return values
   Result = Replicate( { Name  : '', $
                         Total : 0d0 }, N_Elements( Tracer )  )
   
   ; Iteration counter
   Count = 0L

   ; Define total array for drydep species
   TmpTotal = DblArr( N_Elements( Tracer ) )

   ;====================================================================
   ; Loop over each diagnostic interval and tracer
   ;====================================================================
   for T = 0L, N_Elements( Tau0   ) - 1L do begin
   for N = 0L, N_Elements( Tracer ) - 1L do begin
 
      ; Save the name of this tracer in the proper element of RESULT
      Result[N].Name = Name[N]
 
      ;=================================================================
      ; Get the drydep flux in [molec/cm2/s] for the given tracer
      ;=================================================================
      Success = CTM_Get_DataBlock( DryD, DryDep_Name,         $
                                   Use_FileInfo=Use_FileInfo, $
                                   Use_DataInfo=Use_DataInfo, $
                                   GridInfo=GridInfo,         $
                                   Tracer=Tracer[N],          $
                                   Tau0=Tau0[T],              $
                                   FileName=FileName )
 
       ; Error checking 
      if ( not Success ) then begin
         ErrorNOy, DryDep_Flux_Name, Tracer[N], Tau0[T], /Continue
         
         ; Set drydep to zero if it is not found (acs, 5/26/00)
         DryD = 0d0
      endif else begin

         ; Truncate to size of region (and wrap around date line!)
         DryD = TruncateAndWrapForNOy( DryD )
      endelse
      
      ;=================================================================
      ; Compute grid box surface areas in cm2 -- on the first iteration
      ;
      ; NOTE: Only do the following if there is drydep flux present
      ;       from the Nth tracer. (acs, 5/26/00)
      ;=================================================================
      if ( Total( DryD ) gt 0 ) then begin
         if ( Count eq 0L ) then begin
            A_Cm2 = CTM_BoxSize( GridInfo, /GEOS, /Cm2 )
            
            ; Truncate to size of region (and wrap around the date line!)
            A_Cm2 = TruncateAndWrapForNOy( A_Cm2 ) 
         endif
 
         ; Convert drydep flux from [molec/cm2/s] to [moles/s]
         DryD = DryD * A_Cm2 / Avo
 
         ; Sum drydep fluxes in [moles/s].  Only do the sum if the
         ; box we are considering extends to the surface level.
         ; Multiply [moles/s] by 8.64d-5 to get [Gmol/day]. 
         if ( LMin eq 0 ) then begin
            TmpTotal[N] = TmpTotal[N] + ( Total( DryD ) * 8.64d-5 )
         endif else begin
            TmpTotal[N] = 0d0
         endelse

         Result[N].Total = TmpTotal[N]

      endif $
            
      ;=================================================================
      ; If there is no drydep flux from tracer N, then add zeroes
      ; to TMPTOTAL[N] and to RESULT[N].TOTAL (acs, 5/26/00)
      ;=================================================================
      else begin
         TmpTotal[N]     = 0D
         Result[N].Total = TmpTotal[N]
      endelse

      ; Increment iteration counter
      Count = Count + 1L
   endfor
   endfor
 
   ; Return to calling program
   return, Result
end
 
;-----------------------------------------------------------------------------
 
function GetNetExportForNOy, FileName, Tau0, Diag_Names, Tracer, Mw, CNum
 
   ;====================================================================
   ; Function "GetNetExportForNOy" reads the punch file and computes
   ; the total export from both transport and convective processes.
   ;
   ; NOTE: Transport & convective fluxes are originally in 
   ;       [molec/cm2/s], and are converted to [Gmol/day] here.
   ;====================================================================
   common BoxNOy_Save, Imin, Imax, Jmin, Jmax, LMin, LMax, Seconds
 
   ; Iteration counter
   Count = 0L

   ; Loop over each diagnostic interval and tracer
   for T = 0L, N_Elements( Tau0   ) - 1L do begin    
   for N = 0L, N_Elements( Tracer ) - 1L do begin
      
      ;=================================================================
      ; Get the E-W transport fluxes in [molec/cm2/s]
      ;=================================================================
      Success = CTM_Get_DataBlock( EW, Diag_Names.EW_Flux,     $
                                   Use_FileInfo=Use_FileInfo,  $
                                   Use_DataInfo=Use_DataInfo,  $
                                   GridInfo=GridInfo,          $
                                   Tracer=Tracer[N],           $
                                   Tau0=Tau0[T],               $
                                   FileName=FileName )

      ; Error checking 
      if ( not Success ) then begin
         ErrorNOY, Diag_Names.EW_Flux, Tracer[N], Tau0[T], /Continue

         ; If not found, set EW to zero (acs, 5/26/00)
         EW = 0D
      endif else begin
         ; Truncate to size of region (and wrap around date line!)
         ; Add an extra row of longitudes since this is an E-W flux field!
         EW = TruncateAndWrapForNOy( EW, /EW_Flux )
      endelse

      ;=================================================================
      ; Get the N-S transport fluxes in [molec/cm2/s]
      ;=================================================================
      Success = CTM_Get_DataBlock( NS, Diag_Names.NS_Flux,    $
                                   Use_FileInfo=Use_FileInfo, $
                                   Use_DataInfo=Use_DataInfo, $
                                   Tracer=Tracer[N],          $
                                   Tau0=Tau0[T],              $
                                   FileName=FileName )
 
      ; Error checking 
      if ( not Success ) then begin
         ErrorNOy, Diag_Names.NS_Flux, Tracer[N], Tau0[T], /Continue

         ; If not found, set NS to zero (acs, 5/26/00)
         NS = 0
      endif else begin
         ; Truncate to size of region (and wrap around date line!)
         ; Add an extra row of latitudes since this is a N-S flux field!
         NS = TruncateAndWrapForNOy( NS, /NS_Flux )
      endelse

      ;=================================================================
      ; Get the upward transport fluxes in [molec/cm2/s]
      ;=================================================================
      Success = CTM_Get_DataBlock( Up, Diag_Names.UP_Flux,    $
                                   Use_FileInfo=Use_FileInfo, $
                                   Use_DataInfo=Use_DataInfo, $
                                   Tracer=Tracer[N],          $
                                   Tau0=Tau0[T],              $
                                   FileName=FileName )
       ; Error checking 
      if ( not Success ) then begin
         ErrorNOy, Diag_Names.UP_Flux, Tracer[N], Tau0[T], /Continue

         ; If not found, set UP to zero (acs, 5/26/00) 
         Up = 0D
      endif else begin
         ; Truncate to size of region (and wrap around date line!)
         Up = TruncateAndWrapForNOy( Up )
      endelse

      ;=================================================================
      ; Get the fluxes from wet convection in [molec/cm2/s]
      ;=================================================================
      Success = CTM_Get_DataBlock( Conv, Diag_Names.CV_Flux,  $
                                   Use_FileInfo=Use_FileInfo, $
                                   Use_DataInfo=Use_DataInfo, $
                                   Tracer=Tracer[N],          $
                                   Tau0=Tau0[T],              $
                                   FileName=FileName )
       ; Error checking 
      if ( not Success ) then begin
         ErrorNOy, Diag_Names.CV_Flux, Tracer[N], Tau0[T], /Continue

         ; If not found, set CONV to zero (acs, 5/26/00)
         Conv = 0D
      endif else begin
         ; Truncate to size of region (and wrap around date line!)
         Conv = TruncateAndWrapForNOy( Conv )
      endelse

      ;=================================================================
      ; Get the mass change from boundary layer mixing in [molec/cm2/s]
      ;=================================================================
      Success = CTM_Get_DataBlock( Turb, Diag_Names.TU_Flux,  $
                                   Use_FileInfo=Use_FileInfo, $
                                   Use_DataInfo=Use_DataInfo, $
                                   Tracer=Tracer[N],          $  
                                   Tau0=Tau0[T],              $
                                   FileName=FileName )
      ; Error checking 
      if ( not Success ) then begin
         ErrorNOy, Diag_Names.TU_Flux, Tracer[N], Tau0[T], /Continue

         ; If not found, set TURB to zero (acs, 5/26/00)
         Turb = 0
      endif else begin
         ; Truncate to size of region (and wrap around date line!)
         Turb = TruncateAndWrapForNOy( Turb )
      endelse

      ;=================================================================
      ; If this is the first iteration, then define blocks for summing
      ; contributions from each tracer.  Otherwise, just sum into
      ; the already existing arrays.
      ;
      ; Multiply each tracer by its constituent number before
      ; summing (e.g. N2O5 gives 2 N's to the NOy family, etc...)
      ;
      ; Convert fluxes from [molec/cm2/s] to [moles/s].
      ; Sum the contributions from all tracers -- store in TOT_* arrays
      ;=================================================================
      if ( Count eq 0L ) then begin
         Tot_EW   = ( EW   * CNum[N] / Mw[N] )
         Tot_NS   = ( NS   * CNum[N] / Mw[N] )
         Tot_UP   = ( UP   * CNum[N] / Mw[N] )
         Tot_Conv = ( Conv * CNum[N] / Mw[N] )
         Tot_Turb = ( Turb * CNum[N] / Mw[N] )
      endif else begin
         Tot_EW   = Tot_EW   + ( EW   * CNum[N] / Mw[N] )
         Tot_NS   = Tot_NS   + ( NS   * CNum[N] / Mw[N] )
         Tot_UP   = Tot_UP   + ( UP   * CNum[N] / Mw[N] )
         Tot_Conv = Tot_Conv + ( Conv * CNum[N] / Mw[N] )
         Tot_Turb = Tot_Turb + ( Turb * CNum[N] / Mw[N] )
      endelse

      ; Increment iteration counter
      Count = Count + 1L
   endfor
   endfor

   ;====================================================================
   ; Only proceed if all fluxes are non-zero (acs, 5/26/00)
   ;====================================================================
   if ( Abs( Total( Tot_EW   ) ) gt 0.0   AND $
        Abs( Total( Tot_NS   ) ) gt 0.0   AND $
        Abs( Total( Tot_UP   ) ) gt 0.0   AND $
        Abs( Total( Tot_Conv ) ) gt 0.0   AND $
        Abs( Total( Tot_Turb ) ) gt 0.0 ) then begin

      ; Sizes for the arrays (excluding extra elements!)
      SData = Size( UP, /Dim )
      NI    = SData[0] 
      NJ    = SData[1]
      NL    = SData[2]

      ;=================================================================
      ; Compute transport fluxes in [Gmol/day]
      ;
      ; TOP    = Total transport flux leaving top of box
      ; BOTTOM = Total transport flux leaving bottom of box
      ; EAST   = Total transport flux leaving east side of box
      ; WEST   = Total transport flux leaving west side of box
      ; NORTH  = Total transport flux leaving north side of box
      ; SOUTH  = Total transport flux leaving sourth side of box
      ;=================================================================
      Top = Total( Tot_UP[0:NI-1, 0:NJ-1, NL-1] ) * 8.64d-5
 
      ; Do not compute Bottom if the bottom of the box is at the surface
      if ( LMin eq 0 ) $
         then Bottom = 0d0  $
         else Bottom = Total( Tot_UP[0:NI-1, 0:NJ-1, 0] ) * 8.64d-5
 
      ; NOTE: The Eastward flux is the (NI+1)th row of EW!
      East  = Total( Tot_EW[NI, 0:NJ-1, 0:NL-1] ) * 8.64d-5
      West  = Total( Tot_EW[0,  0:NJ-1, 0:NL-1] ) * 8.64d-5
   
      ; NOTE: The Northward flux is the (NJ+1)th row of NS! 
      North = Total( Tot_NS[0:NI-1, NJ, 0:NL-1] ) * 8.64d-5   
      South = Total( Tot_NS[0:NI-1, 0,  0:NL-1] ) * 8.64d-5
 
      ;===============================================================
      ; Compute convective fluxes in [Gmol/day]
      ; Convective fluxes are positive going upward
      ;
      ; CONVTOP    = Total convective flux leaving top of box
      ; CONVBOTTOM = Total convective flux leaving bottom of box
      ;===============================================================
      ConvTop = Total( Tot_Conv[0:NI-1, 0:NJ-1, NL-1] ) * 8.64d-5
 
      ; Do not compute CONVBOTTOM if the box reaches down to the surface
      if ( LMin eq 0 ) then begin
         ConvBottom = 0d0
      endif else begin
         ConvBottom = Total( Tot_Conv[0:NI-1, 0:NJ-1, 0] ) * 8.64d-5
      endelse
 
      ;==============================================================
      ; Compute fluxes due to boundary layer mixing in [Gmol/day]
      ; (these come from subroutine TURBDAY)
      ;==============================================================
      Turbday = Total( Tot_Turb ) * 8.64d-5
 
      ;==============================================================
      ; Compute net flux out of box
      ; Return net and individual fluxes to calling program
      ;==============================================================
      Net = ( Top   - Bottom ) + ( West    - East       ) + $
            ( South - North  ) - ( ConvTop + ConvBottom ) + TurbDay
 
      Result = { East       : East,       $
                 West       : West,       $
                 North      : North,      $
                 South      : South,      $
                 Top        : Top,        $
                 Bottom     : Bottom,     $
                 ConvTop    : ConvTop,    $
                 ConvBottom : ConvBottom, $
                 TurbDay    : TurbDay,    $
                 Net        : Net }
   endif $

   ;====================================================================
   ; If all fluxes are zero, then return zeroes (acs, 5/26/00)
   ;====================================================================
   else begin
      Result = { East       : 0D,         $
                 West       : 0D,         $
                 North      : 0D,         $
                 South      : 0D,         $
                 Top        : 0D,         $
                 Bottom     : 0D,         $
                 ConvTop    : 0D,         $
                 ConvBottom : 0D,         $
                 TurbDay    : 0D,         $
                 Net        : 0D }
   endelse

   return, Result
end
 
;-----------------------------------------------------------------------------
 
function GetNetChemicalProductionForNOy, FileName,      Tau0, $
                                         ProdLoss_Name, Tracer, Unit
 
   ;====================================================================
   ; Function "GetNetChemicalProductionForNOy" reads the punch file 
   ; and computes the net chemical production for the given family.
   ;
   ; NOTE: Transport & convective fluxes are originally in 
   ;       [molec/s], and are converted to [Gmol/day] here.
   ;====================================================================
   common BoxNOy_Save, Imin, Imax, Jmin, Jmax, LMin, LMax, Seconds
   
   if ( N_Elements( Tracer ne 2 ) ) $
      then Message, 'TRACER must have 2 elements!'
   
   ; Create output structure
   Result = { Prod : 0D, $
              Loss : 0D, $
              Net  : 0D }
   
   ; If both tracers are negative, it means that there is no
   ; prodloss data stored in the punch file -- so return zeros
   if ( Tracer[0] lt 0 AND Tracer[1] lt 0 ) then return, Result
      
   ; Loop over each diagnostic interval
   for T = 0L, N_Elements( Tau0 )- 1L do begin

      ;=================================================================
      ; Get chemical production in [molec/s]
      ;=================================================================
      Success = CTM_Get_DataBlock( Prod, ProdLoss_Name,       $
                                   Use_FileInfo=Use_FileInfo, $
                                   Use_DataInfo=Use_DataInfo, $
                                   ThisDataInfo=ThisDataInfo, $
                                   ModelInfo=ModelInfo,       $
                                   GridInfo=GridInfo,         $
                                   Tracer=Tracer[0],          $
                                   Tau0=Tau0[T],              $
                                   FileName=FileName )

      ; Error checking 
      if ( not Success ) then begin
         ErrorNOy, ProdLoss_Name, Tracer[0], Tau0[T], /Continue

         ; If not found, set PROD to zero (acs, 5/26/00)
         Prod = 0D
      endif else begin
         ; Truncate to size of region (and wrap around date line!)
         Prod = TruncateAndWrapForNOy( Prod )
      endelse
 
      ;=================================================================
      ; Get chemical loss in [molec/s]
      ;=================================================================
      Success = CTM_Get_DataBlock( Loss, ProdLoss_Name,       $
                                   Use_FileInfo=Use_FileInfo, $
                                   Use_DataInfo=Use_DataInfo, $
                                   ThisDataInfo=ThisDataInfo, $
                                   Tracer=Tracer[1],          $
                                   Tau0=Tau0[T],              $
                                   FileName=FileName )

      ; Error checking 
      if ( not Success ) then begin
         ErrorNOy, ProdLoss_Name, Tracer[1], Tau0[T]

         ; If not found, set LOSS to zero (acs, 5/26/00)
         Loss = 0D
      endif else begin
         ; Truncate to size of region (and wrap around date line!)
         Loss = TruncateAndWrapForNOy( Loss )
      endelse

      ;=================================================================
      ; Convert PROD, LOSS arrays to [moles/s] and 
      ; sum over the 3-D region
      ;=================================================================
      Avo = 6.023d23

      if ( Total( Prod ) gt 0 and Total( Loss ) gt 0 ) then begin

         case ( Unit ) of 

            ; Convert from [molec/s] to [moles/s]   
            'MOLEC/S': begin
               Prod = Prod / Avo
               Loss = Loss / Avo
            end

            ; Convert from [molec/cm3/s] to [moles/s]
            ; Take the grid box volumes from CTM_BoxSize
            'MOLEC/CM3/S': begin
               GEOS = ( ModelInfo.Family eq 'GEOS' )
               GISS = ( ModelInfo.Family eq 'GISS' )
               FSU  = ( ModelInfo.Family eq 'FSU'  )
               
               ; Only compute BOXVOL on the first iteration
               if ( T eq 0L ) then begin
                  BoxVol = CTM_BoxSize( GridInfo,  /Volume,   /Cm3,    $
                                        GEOS=GEOS, GISS=GISS, FSU=FSU )
                  
                  ; Truncate BOXVOL to size of region 
                  ; (and wrap fordate line!)
                  BoxVol = TruncateAndWrapForNOy( BoxVol )
               endif

               Prod = Prod * BoxVol / Avo
               Loss = Loss * BoxVol / Avo
            end
 
            else: Message, 'Invalid P-L unit selection!'
         endcase
       
         ;==============================================================
         ; Convert total production & loss to [Gmol/day]
         ; Define summing arrays for the first iteration
         ;==============================================================
         if ( T eq 0L ) then begin
            Tot_Prod = Total( Prod ) * 8.64d-5
            Tot_Loss = Total( Loss ) * 8.64d-5
         endif else begin
            Tot_Prod = Tot_Prod + ( Total( Prod ) * 8.64d-5 )
            Tot_Loss = Tot_Loss + ( Total( Loss ) * 8.64d-5 )
         endelse

      ;====================================================================
      ; If fluxes are zero, just return zeroes (acs, 5/26/00)
      ;====================================================================
      endif else return, Result
   endfor

   ;====================================================================
   ; Compute net production
   ; Return TOT_PROD, TOT_LOSS and NET to the calling program
   ;====================================================================
   Result.Prod = Tot_Prod
   Result.Loss = Tot_Loss
   Result.Net  = Tot_Prod - Tot_Loss 
 
   return, Result
end
 
;-----------------------------------------------------------------------------
 
pro ReadBatchFileForNOy, BatchFile, Tau0, FileName, DryDep_Family, $
                         NOx_Family, PAN_Family, HNO3_Family, R4N2_Family, $
                         Diag_Names
 
   ;====================================================================
   ; Subroutine "ReadBatchFile" reads the batch file which contains
   ; input conditions for CTM_NOyBudget.pro
   ;====================================================================
   common BoxNOy_Save, Imin, Imax, Jmin, Jmax, LMin, LMax, Seconds
 
   ; Open the batch file
   Open_File, BatchFile, Ilun_IN, /Get_LUN
   
   ; Get Input file name
   Line = ''
   ReadF, Ilun_IN, Format='(a)',     Line
   ReadF, Ilun_IN, Format='(a)',     Line
   ReadF, Ilun_IN, Format='(a)',     Line
   ReadF, Ilun_IN, Format='(28x,a)', Line
   FileName = StrTrim( Line, 2 )
 
   ; Get TAU0
   ReadF, Ilun_IN, Format='(28x,a)', Line
   Tau0 = Double( Line )
 
   ; Get IMIN, IMAX
   ReadF, Ilun_IN, Format='(28x,a)', Line
   ;Dum  = StrSplit( Line, ',', /Extract )
   Dum  = StrBreak( Line, ',' )
   Imin = Fix( Dum[0] ) 
   IMax = Fix( Dum[1] )
 
   ; Get JMIN, JMAX
   ReadF, Ilun_IN, Format='(28x,a)', Line
   ;Dum  = StrSplit( Line, ',', /Extract )
   Dum  = StrBreak( Line, ',' )
   JMin = Fix( Dum[0] ) 
   Jmax = Fix( Dum[1] )
 
   ; Get LMIN, LMAX
   ReadF, Ilun_IN, Format='(28x,a)', Line
   ;Dum  = StrSplit( Line, ',', /Extract )
   Dum  = StrBreak( Line, ',' )
   LMin = Fix( Dum[0] ) 
   Lmax = Fix( Dum[1] )

   ; Get category name for Anthro NOx emissions
   ReadF, ILun_IN, Line
   ReadF, Ilun_IN, Format='(28x,a)', Line
   ;NOx_Anthro_CatName = StrTrim( StrSplit( Line, ',', /Extract ), 2 )
   NOx_Anthro_CatName = StrTrim( StrBreak( Line, ',' ), 2 )

   ; Get category name for aircraft NOx emissions
   ReadF, Ilun_IN, Format='(28x,a)', Line
   ;NOx_Aircraft_CatName = StrTrim( StrSplit( Line, ',', /Extract ), 2 )
   NOx_Aircraft_CatName = StrTrim( StrBreak( Line, ',' ), 2 )

   ; Get category name for lightning NOx emissions
   ReadF, Ilun_IN, Format='(28x,a)', Line
   ;NOx_Lightning_CatName = StrTrim( StrSplit( Line, ',', /Extract ), 2 )
   NOx_Lightning_CatName = StrTrim( StrBreak( Line, ',' ), 2 )

   ; Get category name for biomass NOx emissions
   ReadF, Ilun_IN, Format='(28x,a)', Line
   ;NOx_BioMass_CatName = StrTrim( StrSplit( Line, ',', /Extract ), 2 )
   NOx_BioMass_CatName = StrTrim( StrBreak( Line, ',' ), 2 )

   ; Get category name for soil NOx emissions
   ReadF, Ilun_IN, Format='(28x,a)', Line
   ;NOx_Soil_CatName = StrTrim( StrSplit( Line, ',', /Extract ), 2 )
   NOx_Soil_CatName = StrTrim( StrBreak( Line, ',' ), 2 )

   ; Get category name for EW Flux
   ReadF, Ilun_IN, Format='(28x,a)', Line
   ;EW_Flux_CatName = StrTrim( StrSplit( Line, ',', /Extract ), 2 )
   EW_Flux_CatName = StrTrim( StrBreak( Line, ',' ), 2 )

   ; Get category name for NS flux
   ReadF, Ilun_IN, Format='(28x,a)', Line
   ;NS_Flux_CatName = StrTrim( StrSplit( Line, ',', /Extract ), 2 )
   NS_Flux_CatName = StrTrim( StrBreak( Line, ',' ), 2 )

   ; Get category name for Upward flux
   ReadF, Ilun_IN, Format='(28x,a)', Line
   ;UP_Flux_CatName = StrTrim( StrSplit( Line, ',', /Extract ), 2 )
   UP_Flux_CatName = StrTrim( StrBreak( Line, ',' ), 2 )

   ; Get category name for convective flux
   ReadF, Ilun_IN, Format='(28x,a)', Line
   ;CV_Flux_CatName = StrTrim( StrSplit( Line, ',', /Extract ), 2 )
   CV_Flux_CatName = StrTrim( StrBreak( Line, ',' ), 2 )

   ; Get category name for turbulent flux
   ReadF, Ilun_IN, Format='(28x,a)', Line
   ;TU_Flux_CatName = StrTrim( StrSplit( Line, ',', /Extract ), 2 )
   TU_Flux_CatName = StrTrim( StrBreak( Line, ',' ), 2 )

   ; Get category name for dry deposition flux
   ReadF, Ilun_IN, Format='(28x,a)', Line
   ;DryDep_Flux_CatName = StrTrim( StrSplit( Line, ',', /Extract ), 2 )
   DryDep_Flux_CatName = StrTrim( StrBreak( Line, ',' ), 2 )

   ; Get category name for convective wetdep
   ReadF, Ilun_IN, Format='(28x,a)', Line
   ;CV_WetDep_CatName = StrTrim( StrSplit( Line, ',', /Extract ), 2 )
   CV_WetDep_CatName = StrTrim( StrBreak( Line, ',' ), 2 )

   ; Get category name for large-scale wetdep
   ReadF, Ilun_IN, Format='(28x,a)', Line
   ;LS_WetDep_CatName = StrTrim( StrSplit( Line, ',', /Extract ), 2 )
   LS_WetDep_CatName = StrTrim( StrSplit( Line, ',', /Extract ), 2 )

   ; Get category name for chemical production - loss
   ReadF, Ilun_IN, Format='(28x,a)', Line
   ProdLoss_CatName = StrTrim( StrSplit( Line, ',', /Extract ), 2 ) 
   
   ; Get dry deposition names
   ReadF, ILun_IN, Line
   ReadF, Ilun_IN, Format='(28x,a)', Line
   ;DD_Name = StrTrim( StrSplit( Line, ',', /Extract ), 2 )
   DD_Name = StrTrim( StrBreak( Line, ',' ), 2 )
   
   ; Get dry deposition tracer numbers
   ReadF, Ilun_IN, Format='(28x,a)', Line
   ;Dum       = StrSplit( Line, ',', /Extract )
   Dum       = StrBreak( Line, ',' )
   DD_Tracer = Fix( Dum )
   
   ; Get NOx family names
   ReadF, ILun_IN, Line
   ReadF, Ilun_IN, Format='(28x,a)', Line
   ;NOx_Name = StrTrim( StrSplit( Line, ',', /Extract ), 2 )
   NOx_Name = StrTrim( StrBreak( Line, ',' ), 2 )
 
   ; Get NOx family tracer numbers
   ReadF, Ilun_IN, Format='(28x,a)', Line
   ;Dum        = StrSplit( Line, ',', /Extract )
   Dum        = StrBreak( Line, ',' )
   NOx_Tracer = Fix( Dum )
 
   ; Get NOx family molecular weights --
   ; convert from [g/mole] to [kg/mole]
   ReadF, Ilun_IN, Format='(28x,a)', Line
   ;Dum    = StrSplit( Line, ',', /Extract )
   Dum    = StrBreak( Line, ',' )
   NOx_Mw = Double( Dum ) * 1d-3

   ; Get NOx family constituent numbers --
   ; number of moles of species per moles of NOx
   ReadF, Ilun_IN, Format='(28x,a)', Line
   ;Dum      = StrSplit( Line, ',', /Extract )
   Dum      = StrBreak( Line, ',' )
   NOx_CNum = Double( Dum ) 

   ; Get NOx Family P-L tracer numbers
   ReadF, Ilun_IN, Format='(28x,a)', Line
   ;Dum           = StrSplit( Line, ',', /Extract )
   Dum           = StrBreak( Line, ',' )
   NOx_PL_Tracer = Fix( Dum )
    
   ; Get NOx Family P-L units
   ReadF, Ilun_IN, Format='(28x,a)', Line
   ;NOx_PL_Unit = StrTrim( StrUpCase( StrSplit( Line, ',', /Extract ) ), 2 )
   NOx_PL_Unit = StrTrim( StrUpCase( StrBreak( Line, ',' ) ), 2 )
 
   ; Get PAN family names
   ReadF, ILun_IN, Line
   ReadF, Ilun_IN, Format='(28x,a)', Line
   ;PAN_Name = StrTrim( StrSplit( Line, ',', /Extract ), 2 )
   PAN_Name = StrTrim( StrBreak( Line, ',' ), 2 )
 
   ; Get PAN family tracer numbers
   ReadF, Ilun_IN, Format='(28x,a)', Line
   Dum        = StrSplit( Line, ',', /Extract ) 
   PAN_Tracer = Fix( Dum )
 
   ; Get PAN family molecular weights --
   ; convert from [g/mole] to [kg/mole]
   ReadF, Ilun_IN, Format='(28x,a)', Line
   ;Dum    = StrSplit( Line, ',', /Extract )
   Dum    = StrBreak( Line, ',' )
   PAN_Mw = Double( Dum ) * 1d-3

   ; Get PAN family constituent numbers --
   ; number of moles of species per moles of PAN
   ReadF, Ilun_IN, Format='(28x,a)', Line
   ;Dum      = StrSplit( Line, ',', /Extract )
   Dum      = StrBreak( Line, ',' )
   PAN_CNum = Double( Dum ) 
 
   ; Get PAN Family P-L tracer numbers
   ReadF, Ilun_IN, Format='(28x,a)', Line
   ;Dum           = StrSplit( Line, ',', /Extract )
   Dum           = StrBreak( Line, ',' )
   PAN_PL_Tracer = Fix( Dum )
   
   ; Get PAN Family P-L tracer numbers
   ReadF, Ilun_IN, Format='(28x,a)', Line
   ;PAN_PL_Unit = StrTrim( StrUpCase( StrSplit( Line, ',', /Extract ) ), 2 )
   PAN_PL_Unit = StrTrim( StrUpCase( StrBreak( Line, ',', /Extract ) ), 2 )
 
   ; Get HNO3 family names
   ReadF, ILun_IN, Line
   ReadF, Ilun_IN, Format='(28x,a)', Line
   ;HNO3_Name = StrTrim( StrSplit( Line, ',', /Extract ), 2 )
   HNO3_Name = StrTrim( StrBreak( Line, ',' ), 2 )
 
   ; Get HNO3 family tracer numbers
   ReadF, Ilun_IN, Format='(28x,a)', Line
   ;Dum         = StrSplit( Line, ',', /Extract )
   Dum         = StrBreak( Line, ',' )
   HNO3_Tracer = Fix( Dum )
 
   ; Get HNO3 family molecular weights --
   ; convert from [g/mole] to [kg/mole]
   ReadF, Ilun_IN, Format='(28x,a)', Line
   ;Dum     = StrSplit( Line, ',', /Extract )
   Dum     = StrBreak( Line, ',' )
   HNO3_Mw = Double( Dum ) * 1d-3
 
   ; Get HNO3 family constituent numbers --
   ; number of moles of species per moles of HNO3
   ReadF, Ilun_IN, Format='(28x,a)', Line
   ;Dum       = StrSplit( Line, ',', /Extract )
   Dum       = StrBreak( Line, ',' )
   HNO3_CNum = Double( Dum ) 

   ; Get HNO3 Family P-L tracer numbers
   ReadF, Ilun_IN, Format='(28x,a)', Line
   ;Dum            = StrSplit( Line, ',', /Extract )
   Dum            = StrBreak( Line, ',' )
   HNO3_PL_Tracer = Fix( Dum )
   
   ; Get HNO3 Family P-L tracer numbers
   ReadF, Ilun_IN, Format='(28x,a)', Line
   ;HNO3_PL_Unit = StrTrim( StrUpCase( StrSplit( Line, ',', /Extract ) ), 2 )
   HNO3_PL_Unit = StrTrim( StrUpCase( StrBreak( Line, ',' ) ), 2 )
 
   ; Get R4N2 family names
   ReadF, ILun_IN, Line
   ReadF, Ilun_IN, Format='(28x,a)', Line
   ;R4N2_Name = StrTrim( StrSplit( Line, ',', /Extract ), 2 )
   R4N2_Name = StrTrim( StrBreak( Line, ',' ), 2 )
 
   ; Get R4N2 family tracer numbers
   ReadF, Ilun_IN, Format='(28x,a)', Line
   ;Dum         = StrSplit( Line, ',', /Extract )
   Dum         = StrBreak( Line, ',' )
   R4N2_Tracer = Fix( Dum )
 
   ; Get R4N2 family molecular weights -- 
   ; convert from [g/mole] to [kg/mole]
   ReadF, Ilun_IN, Format='(28x,a)', Line
   ;Dum     = StrSplit( Line, ',', /Extract )
   Dum     = StrBreak( Line, ',' )
   R4N2_Mw = Double( Dum ) * 1d-3
 
   ; Get R4N2 family constituent numbers --
   ; number of moles of species per moles of R4N2
   ReadF, Ilun_IN, Format='(28x,a)', Line
   ;Dum       = StrSplit( Line, ',', /Extract )
   Dum       = StrBreak( Line, ',' )
   R4N2_CNum = Double( Dum ) 

   ; Get R4N2 Family P-L tracer numbers
   ReadF, Ilun_IN, Format='(28x,a)', Line
   ;Dum            = StrSplit( Line, ',', /Extract )
   Dum            = StrBreak( Line, ',' )
   R4N2_PL_Tracer = Fix( Dum )
   
   ; Get R4N2 Family P-L tracer numbers
   ReadF, Ilun_IN, Format='(28x,a)', Line
   ;R4N2_PL_Unit = StrTrim( StrUpCase( StrSplit( Line, ',', /Extract ) ), 2 )
   R4N2_PL_Unit = StrTrim( StrUpCase( StrBreak( Line, ',' ) ), 2) 
 
   ; Close batch file
   Close,    Ilun_IN
   Free_LUN, Ilun_IN
 
   ; Create DRYDEP return structure
   DryDep_Family = { Name   : DD_Name,   $
                     Tracer : DD_Tracer }
 
   ; Create NOx return structure
   NOX_Family  = { Name      : NOx_Name,      $
                   Tracer    : NOx_Tracer,    $
                   Mw        : NOX_Mw,        $
                   CNum      : NOx_CNum,      $
                   PL_Tracer : NOx_PL_Tracer, $
                   PL_Unit   : NOX_PL_Unit }
   
   ; Create PAN return structure
   PAN_Family  = { Name      : PAN_Name,      $
                   Tracer    : PAN_Tracer,    $
                   Mw        : PAN_Mw,        $
                   CNum      : PAN_CNum,      $
                   PL_Tracer : PAN_PL_Tracer, $
                   PL_Unit   : PAN_PL_Unit }
 
   ; Create HNO3 return structure
   HNO3_Family = { Name      : HNO3_Name,      $
                   Tracer    : HNO3_Tracer,    $
                   Mw        : HNO3_Mw,        $
                   CNum      : HNO3_CNum,      $
                   PL_Tracer : HNO3_PL_Tracer, $
                   PL_Unit   : HNO3_PL_Unit} 
 
   ; Create R4N2 return structure
   R4N2_Family = { Name      : R4N2_Name,      $
                   Tracer    : R4N2_Tracer,    $
                   Mw        : R4N2_Mw,        $
                   CNum      : R4N2_CNum,      $
                   PL_Tracer : R4N2_PL_Tracer, $
                   PL_Unit   : R4N2_PL_Unit }
 
   ; Create return structure for Category Names
   Diag_Names = { NOx_Anthro    : NOx_Anthro_CatName[0],    $
                  NOx_Aircraft  : NOx_Aircraft_CatName[0],  $
                  NOx_Lightning : NOx_Lightning_CatName[0], $
                  NOx_BioMass   : NOx_BioMass_CatName[0],   $
                  NOx_Soil      : NOx_Soil_CatName[0],      $
                  EW_Flux       : EW_Flux_CatName[0],     $
                  NS_Flux       : NS_Flux_CatName[0],     $
                  UP_Flux       : UP_Flux_CatName[0],     $
                  CV_Flux       : CV_Flux_CatName[0],     $
                  TU_Flux       : TU_Flux_CatName[0],     $
                  DryDep_Flux   : DryDep_Flux_CatName[0], $
                  CV_WetDep     : CV_WetDep_CatName[0],   $
                  LS_WetDep     : LS_WetDep_CatName[0],   $
                  ProdLoss      : ProdLoss_CatName[0] }

   ; Return to calling program
   return
end
 
;-----------------------------------------------------------------------------
 
pro CTM_NOyBudget, BatchFile, LogFileName=LogFileName
 
   ;====================================================================
   ; Start of main program -- common block & keyword settings
   ;====================================================================
   common BoxNOy_Save, Imin, Imax, Jmin, Jmax, LMin, LMax, Seconds
 
   if ( not Keyword_Set( LogFileName ) ) then LogFileName = 'noy_budget.log'
 
   ;=====================================================================
   ; Read the batch file -- returns structures with information
   ; about the names, tracer numbers, & MW's for each type of family
   ;=====================================================================
   ReadBatchFileForNOy, BatchFile, Tau0, FileName, $
      DryDep_Family, NOX_Family, PAN_Family, HNO3_Family, $
      R4N2_Family,   Diag_Names
 
   ;=====================================================================
   ; Open log file for output 
   ;=====================================================================
   Open_File, LogFileName, Ilun_OUT, /Write, /Get_LUN
 
   PrintF,Ilun_OUT, 'Results from ctm_noybudget.pro:'
   PrintF,Ilun_OUT
   PrintF,Ilun_OUT, Format='(''Input File:      : '', a     )', FileName
   PrintF,Ilun_OUT, Format='(''Tau0             : '', f10.3 )', Tau0
   PrintF,Ilun_OUT, Format='(''IMin, IMax       : '', 2i5   )', IMin, IMax
   PrintF,Ilun_OUT, Format='(''JMin, JMax       : '', 2i5   )', JMin, JMax
   PrintF,Ilun_OUT, Format='(''LMin, LMax       : '', 2i5   )', LMin, LMax
   PrintF,Ilun_OUT, Format='(''Box size (I-J-L) : '', 3i5   )', IMax-Imin+1, $
                                                                JMax-JMin+1, $
                                                                LMax-LMin+1
   Sep = '===================================================================='
   PrintF, Ilun_OUT, ''
   PrintF, Ilun_OUT, Sep
 
   ;=====================================================================
   ; Convert Fortran indices to IDL indices 
   ;=====================================================================
   IMin = IMin - 1  &  IMax = IMax - 1
   JMin = JMin - 1  &  JMax = JMax - 1
   LMin = LMin - 1  &  LMax = LMax - 1
 
   ;====================================================================
   ; Get the NOx emissions (TRACER index = 1)
   ;==================================================================== 
   Tracer = 1L
   NOxEm  = GetNOxEmissionsForNOy( FileName, Tau0, Diag_Names, Tracer )
 
   ; Print to log file
   PrintF,Ilun_OUT, ''
   PrintF,Ilun_OUT, '*** NOx Emissions ***'
   PrintF,Ilun_OUT, Format='(''Biomass        : '', f10.4 )', NOxEm.BioMass
   PrintF,Ilun_OUT, Format='(''Anthro         : '', f10.4 )', NOxEm.Anthro
   PrintF,Ilun_OUT, Format='(''Aircraft       : '', f10.4 )', NOxEm.AirCraft
   PrintF,Ilun_OUT, Format='(''Soils          : '', f10.4 )', NOxEm.Soils
   PrintF,Ilun_OUT, Format='(''Lightning      : '', f10.4 )', NOxEm.Lightning
   PrintF,Ilun_OUT, Format='( 17x, ''----------'' )'
   PrintF,Ilun_OUT, Format='(''Net [Gmol/day] : '', f10.4 )', NOxEm.Total
   
   ;====================================================================
   ; Get the wet deposition of HNO3 (TRACER index = 1)
   ;====================================================================
   Tracer = 1L
   HNO3wd = GetHNO3WetDepForNOy( FileName, Tau0, Diag_Names, Tracer )
 
   ; Print to log file
   PrintF,Ilun_OUT, ''
   PrintF,Ilun_OUT, ''
   PrintF,Ilun_OUT, '*** HNO3 Wet Deposition ***'
   PrintF,Ilun_OUT, Format='(''Moist Conv     : '', f10.4 )', HNO3wd.MoistConv
   PrintF,Ilun_OUT, Format='(''Large Scale    : '', f10.4 )', HNO3wd.LargeScale
   PrintF,Ilun_OUT, Format='( 17x, ''----------'' )'
   PrintF,Ilun_OUT, Format='(''Net [Gmol/day] : '', f10.4 )', HNO3wd.Total
 
   ;====================================================================
   ; Get the dry deposition
   ;====================================================================
   DryDep = GetDryDepositionForNOy( FileName, Tau0,         $
                                    Diag_Names.DryDep_Flux, $
                                    DryDep_Family.Name,     $
                                    DryDep_Family.Tracer )
 
   ; Print to log file
   PrintF, Ilun_OUT, ''
   PrintF, Ilun_OUT, ''
   PrintF, Ilun_OUT, '*** Dry Deposition ***'
 
   for N = 0L, N_Elements( DryDep ) - 1L do begin
      PrintF, Ilun_OUT, Format='( a4, 11x, '': '', f10.4 )', $
         DryDep[N].Name, DryDep[N].Total
   endfor
 
   PrintF,Ilun_OUT,Format='( 17x, ''----------'' )'
   PrintF,Ilun_OUT,Format='(''Net [Gmol/day] : '', f10.4 )', $
      Total( DryDep[*].Total )
 
   ;====================================================================
   ; Get combined export of the NOx family
   ;====================================================================
   NOxEx = GetNetExportForNOy( FileName,      Tau0,              $
                               Diag_Names,    NOX_Family.Tracer, $
                               NOX_Family.Mw, NOX_Family.CNum )
 
   ; Create string for log file
   S     = ''
   N_Max = N_Elements( NOx_Family.Name ) - 1

   for N = 0, N_Max do begin
      if ( N eq N_Max ) then SepStr = ' ' else SepStr = '+'
      S = S + NOx_Family.Name[N] + SepStr
   endfor
 
   S = '*** Export of ' + S + '***'
 
   ; Print to log file
   PrintF,Ilun_OUT, ''
   PrintF,Ilun_OUT, ''
   PrintF,Ilun_OUT, S
   PrintF,Ilun_OUT, Format='(''Thru Top       : '', f10.4 )', NOxEx.Top
   PrintF,Ilun_OUT, Format='(''Thru Bottom    : '', f10.4 )', NOxEx.Bottom
   PrintF,Ilun_OUT, Format='(''Thru East      : '', f10.4 )', NOxEx.East
   PrintF,Ilun_OUT, Format='(''Thru West      : '', f10.4 )', NOxEx.West
   PrintF,Ilun_OUT, Format='(''Thru North     : '', f10.4 )', NOxEx.North
   PrintF,Ilun_OUT, Format='(''Thru South     : '', f10.4 )', NOxEx.South
   PrintF,Ilun_OUT, Format='(''Conv thru Top  : '', f10.4 )', NOxEx.ConvTop
   PrintF,Ilun_OUT, Format='(''Conv thru Bot  : '', f10.4 )', NOxEx.ConvBottom
   PrintF,Ilun_OUT, Format='(''Turbday        : '', f10.4 )', NOxEx.Turbday
   PrintF,Ilun_OUT, Format='( 17x, ''----------'' )'
   PrintF,Ilun_OUT, Format='(''Net [Gmol/day] : '', f10.4 )', NOxEx.Net
 
   ;====================================================================
   ; Get combined export of the PAN family
   ;====================================================================
   PANex = GetNetExportForNOy( FileName,      Tau0,              $
                               Diag_Names,    PAN_Family.Tracer, $
                               PAN_Family.Mw, PAN_Family.CNum )
 
   ; Create string for log file
   S     = ''
   N_Max = N_Elements( PAN_Family.Name ) - 1

   for N = 0, N_Max do begin
      if ( N eq N_Max ) then SepStr = ' ' else SepStr = '+'
      S = S + PAN_Family.Name[N] + SepStr
   endfor
 
   S = '*** Export of ' + S + '***'
 
   ; Print to log file
   PrintF,Ilun_OUT, ''
   PrintF,Ilun_OUT, ''
   PrintF,Ilun_OUT, S
   PrintF,Ilun_OUT,Format='(''Thru Top       : '', f10.4 )', PANex.Top
   PrintF,Ilun_OUT,Format='(''Thru Bottom    : '', f10.4 )', PANex.Bottom
   PrintF,Ilun_OUT,Format='(''Thru East      : '', f10.4 )', PANex.East
   PrintF,Ilun_OUT,Format='(''Thru West      : '', f10.4 )', PANex.West
   PrintF,Ilun_OUT,Format='(''Thru North     : '', f10.4 )', PANex.North
   PrintF,Ilun_OUT,Format='(''Thru South     : '', f10.4 )', PANex.South
   PrintF,Ilun_OUT,Format='(''Conv thru Top  : '', f10.4 )', PANex.ConvTop
   PrintF,Ilun_OUT,Format='(''Conv thru Bot  : '', f10.4 )', PANex.ConvBottom
   PrintF,Ilun_OUT,Format='(''Turbday        : '', f10.4 )', PANex.Turbday
   PrintF,Ilun_OUT,Format='( 17x, ''----------'' )'
   PrintF,Ilun_OUT,Format='(''Net [Gmol/day] : '', f10.4 )', PANex.Net
 
   ;====================================================================
   ; Get export of HNO3
   ;====================================================================
   HNO3ex = GetNetExportForNOy( FileName,       Tau0,               $
                                Diag_Names,     HNO3_Family.Tracer, $
                                HNO3_Family.Mw, HNO3_Family.CNum )

   ; Create string for log file
   S     = ''
   N_Max = N_Elements( HNO3_Family.Name ) - 1

   for N = 0, N_Max do begin
      if ( N eq N_Max ) then SepStr = ' ' else SepStr = '+'
      S = S + HNO3_Family.Name[N] + SepStr
   endfor 
 
   S = '*** Export of ' + S + '***'
 
   ; Print to log file
   PrintF,Ilun_OUT, ''
   PrintF,Ilun_OUT, ''
   PrintF,Ilun_OUT, S
   PrintF,Ilun_OUT, Format='(''Thru Top       : '', f10.4 )', HNO3ex.Top
   PrintF,Ilun_OUT, Format='(''Thru Bottom    : '', f10.4 )', HNO3ex.Bottom
   PrintF,Ilun_OUT, Format='(''Thru East      : '', f10.4 )', HNO3ex.East
   PrintF,Ilun_OUT, Format='(''Thru West      : '', f10.4 )', HNO3ex.West
   PrintF,Ilun_OUT, Format='(''Thru North     : '', f10.4 )', HNO3ex.North
   PrintF,Ilun_OUT, Format='(''Thru South     : '', f10.4 )', HNO3ex.South
   PrintF,Ilun_OUT, Format='(''Conv thru Top  : '', f10.4 )', HNO3ex.ConvTop
   PrintF,Ilun_OUT, Format='(''Conv thru Bot  : '', f10.4 )', HNO3ex.ConvBottom
   PrintF,Ilun_OUT, Format='(''Turbday        : '', f10.4 )', HNO3ex.Turbday
   PrintF,Ilun_OUT, Format='( 17x, ''----------'' )'
   PrintF,Ilun_OUT, Format='(''Net [Gmol/day] : '', f10.4 )', HNO3ex.Net
 
   ;====================================================================
   ; Get export of R4N2
   ;====================================================================
   R4N2ex = GetNetExportForNOy( FileName,       Tau0,               $
                                Diag_Names,     R4N2_Family.Tracer, $
                                R4N2_Family.Mw, R4N2_Family.CNum )

   ; Create string for log file
   S     = ''
   N_Max = N_Elements( R4N2_Family.Name ) - 1

   for N = 0, N_Max do begin
      if ( N eq N_Max ) then SepStr = ' ' else SepStr = '+'
      S = S + R4N2_Family.Name[N] + SepStr
   endfor 
 
   S = '*** Export of ' + S + '***'
 
   ; Print to log file
   PrintF,Ilun_OUT, ''
   PrintF,Ilun_OUT, ''
   PrintF,Ilun_OUT, S
   PrintF,Ilun_OUT,Format='(''Thru Top       : '', f10.4 )', R4N2ex.Top
   PrintF,Ilun_OUT,Format='(''Thru Bottom    : '', f10.4 )', R4N2ex.Bottom
   PrintF,Ilun_OUT,Format='(''Thru East      : '', f10.4 )', R4N2ex.East
   PrintF,Ilun_OUT,Format='(''Thru West      : '', f10.4 )', R4N2ex.West
   PrintF,Ilun_OUT,Format='(''Thru North     : '', f10.4 )', R4N2ex.North
   PrintF,Ilun_OUT,Format='(''Thru South     : '', f10.4 )', R4N2ex.South
   PrintF,Ilun_OUT,Format='(''Conv thru Top  : '', f10.4 )', R4N2ex.ConvTop
   PrintF,Ilun_OUT,Format='(''Conv thru Bot  : '', f10.4 )', R4N2ex.ConvBottom
   PrintF,Ilun_OUT,Format='(''Turbday        : '', f10.4 )', R4N2ex.Turbday
   PrintF,Ilun_OUT,Format='( 17x, ''----------'' )'
   PrintF,Ilun_OUT,Format='(''Net [Gmol/day] : '', f10.4 )', R4N2ex.Net
 
   ;====================================================================
   ; Get net chemical production of NOx
   ;====================================================================
   NOxCh = GetNetChemicalProductionForNOy( FileName, Tau0,       $
                                           Diag_Names.ProdLoss,  $
                                           NOX_Family.PL_Tracer, $
                                           NOX_Family.PL_Unit )

   ; Create string for log file
   S     = ''
   N_Max = N_Elements( NOX_Family.Name ) - 1

   for N = 0, N_Max do begin
      if ( N eq N_Max ) then SepStr = ' ' else SepStr = '+'
      S = S + NOX_Family.Name[N] + SepStr
   endfor 
 
   S = '*** Chemical Prod/Loss of ' + S + '***'
 
   ; Print to log file
   PrintF,Ilun_OUT, ''
   PrintF,Ilun_OUT, ''
   PrintF,Ilun_OUT, S
   PrintF,Ilun_OUT,Format='(''Production     : '', f10.4 )', NOxCh.Prod
   PrintF,Ilun_OUT,Format='(''Loss           : '', f10.4 )', NOxCh.Loss
   PrintF,Ilun_OUT,Format='( 17x, ''----------'' )'
   PrintF,Ilun_OUT,Format='(''Net [Gmol/day] : '', f10.4 )', NOxCh.Net
 
   ;====================================================================
   ; Get net chemical production of the PAN family
   ;====================================================================
   PANch = GetNetChemicalProductionForNOy( FileName, Tau0,       $
                                           Diag_Names.ProdLoss,  $
                                           PAN_Family.PL_Tracer, $
                                           PAN_Family.PL_Unit )

   ; Create string for log file
   S     = ''
   N_Max = N_Elements( PAN_Family.Name ) - 1

   for N = 0, N_Max do begin
      if ( N eq N_Max ) then SepStr = ' ' else SepStr = '+'
      S = S + PAN_Family.Name[N] + SepStr
   endfor 
 
   S = '*** Chemical Prod/Loss of ' + S + '***'
 
   ; Print to log file
   PrintF,Ilun_OUT, ''
   PrintF,Ilun_OUT, ''
   PrintF,Ilun_OUT, S
   PrintF,Ilun_OUT,Format='(''Production     : '', f10.4 )', PANch.Prod
   PrintF,Ilun_OUT,Format='(''Loss           : '', f10.4 )', PANch.Loss
   PrintF,Ilun_OUT,Format='( 17x, ''----------'' )'
   PrintF,Ilun_OUT,Format='(''Net [Gmol/day] : '', f10.4 )', PANch.Net
 
   ;====================================================================
   ; Get net chemical production of HNO3
   ;====================================================================
   HNO3ch = GetNetChemicalProductionForNOy( FileName, Tau0,        $
                                            Diag_Names.ProdLoss,   $
                                            HNO3_Family.PL_Tracer, $
                                            HNO3_Family.PL_Unit )
   
   ; Create string for log file
   S     = ''
   N_Max = N_Elements( HNO3_Family.Name ) - 1

   for N = 0, N_Max do begin
      if ( N eq N_Max ) then SepStr = ' ' else SepStr = '+'
      S = S + HNO3_Family.Name[N] + SepStr
   endfor 
 
   S =  '*** Chemical Prod/Loss of ' + S +  '***'
 
   ; Print to log file
   PrintF,Ilun_OUT, ''
   PrintF,Ilun_OUT, ''
   PrintF,Ilun_OUT, S
   PrintF,Ilun_OUT,Format='(''Production     : '', f10.4 )', HNO3ch.Prod
   PrintF,Ilun_OUT,Format='(''Loss           : '', f10.4 )', HNO3ch.Loss
   PrintF,Ilun_OUT,Format='( 17x, ''----------'' )'
   PrintF,Ilun_OUT,Format='(''Net [Gmol/day] : '', f10.4 )', HNO3ch.Net
 
   ;====================================================================
   ; Get net chemical production of R4N2
   ;====================================================================
   R4N2ch = GetNetChemicalProductionForNOy( FileName, Tau0,        $
                                            Diag_Names.ProdLoss,   $
                                            R4N2_Family.PL_Tracer, $
                                            R4N2_Family.PL_Unit )
 
   ; Create string for log file
   S     = ''
   N_Max = N_Elements( R4N2_Family.Name ) - 1

   for N = 0, N_Max do begin
      if ( N eq N_Max ) then SepStr = ' ' else SepStr = '+'
      S = S + R4N2_Family.Name[N] + SepStr
   endfor 

   S =  '*** Chemical Prod/Loss of ' + S +  '***'
 
   ; Print to log file
   PrintF,Ilun_OUT, ''
   PrintF,Ilun_OUT, ''
   PrintF,Ilun_OUT, S
   PrintF,Ilun_OUT,Format='(''Production     : '', f10.4 )', R4N2ch.Prod
   PrintF,Ilun_OUT,Format='(''Loss           : '', f10.4 )', R4N2ch.Loss
   PrintF,Ilun_OUT,Format='( 17x, ''----------'' )'
   PrintF,Ilun_OUT,Format='(''Net [Gmol/day] : '', f10.4 )', R4N2ch.Net
 
   ;====================================================================
   ; Compute net budget in both [Gmol/day] and [moles]
   ;====================================================================
   NetGMolDay = NOxEm.Total - Total( DryDep[*].Total ) - HNO3wd.Total + $  
                ( NOxCh.Net + PANch.Net + HNO3ch.Net + R4N2ch.Net )   + $ 
                ( NOxEx.Net + PANex.Net + HNO3ex.Net + R4N2ex.Net )  
 
   NetMoles = ( NetGMolDay / 8.64d-5 ) * Seconds 
   
   ; Print to log file
   PrintF,Ilun_OUT, ''
   PrintF,Ilun_OUT, Sep
   PrintF,Ilun_OUT, ''
   PrintF,Ilun_OUT,Format='(''NET [Gmol/day] : '', e12.4)', NetGMolDay
   PrintF,Ilun_OUT,Format='(''NET [moles]    : '', e12.4)', NetMoles
   PrintF,Ilun_OUT, ''
   PrintF,Ilun_OUT,Format='(''# of days      : '', f12.3)', Seconds / 8.64d4

   ;error = ((DELTA - NET2)/DELTA)*100.
   ;PrintF, Ilun_OUT, 'DELTA  (moles)    = ', DELTA
   ;PrintF, Ilun_OUT, 'CHANGE (%)        = ', change
   ;PrintF, Ilun_OUT, 'ERROR  (%)        = ', error
 
   ;====================================================================
   ; Close log file and end program
   ;====================================================================
Quit:   
   Close,    Ilun_OUT
   Free_LUN, Ilun_OUT
end
