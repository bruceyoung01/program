; $Id: ctm_oxbudget.pro,v 1.1.1.1 2003/10/22 18:06:03 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        CTM_OXBUDGET
;
; PURPOSE:
;        Computes the Ox budget within a given 3-D region.
;
; CATEGORY:
;        CTM Tools
;
; CALLING SEQUENCE:
;        CTM_OXBUDGET [, BATCHFILE [, Keywords ] ]
;
; INPUTS:
;        BATCHFILE (optional) -> Name of the batch file which 
;             contains inputs that defines the 3-D region and NOy
;             constituents.  If BATCHFILE is omitted, then the user
;             will be prompted to supply a file name via a dialog box.
;
; KEYWORD PARAMETERS:
;        LOGFILENAME (optional) -> Name of the log file where output 
;             will be sent.  Default is "ox_budget.log".
;
; OUTPUTS:
;        None
;
; SUBROUTINES:
;        Internal Subroutines:
;        --------------------------------------------------------------
;        ErrorOx                       (function)
;        TruncateAndWrapForOx          (function)
;        GetHNO3WetDepForOx            (function)             
;        GetDryDepositionForOx         (function)  
;        GetNetChemicalProductionForOx (function)  
;        GetNetExportForOx             (function)
;        ReadBatchFileForOx            (procedure)
;
;        External Subroutines Required:
;        --------------------------------------------------------------
;        CTM_Get_Datablock (function)  CTM_BoxSize (function)
;
; REQUIREMENTS:
;        References routines from the GAMAP and TOOLS packages.
;
; NOTES:
;        (1) CTM_OXBUDGET was developed for use with the GEOS-CTM,
;            there might be some adaptation required for use with
;            other models.  
;
;        (2) Only 2 "families" are considered: Dry Deposition and Ox.
;
;        (3) Wrapping around the date line seems to work but you
;            should always double-check.
;
;        (4) Currently, the box of consideration must be less than
;            global size in order to m
;       
; EXAMPLE:
;        CTM_OXBUDGET, 'box1.ox', LogFileName='box1.log'
;           
;             ; Computes Ox budgets for the region specified in
;             ; the file "box1.ox" and sends output to the 
;             ; "box1.log" log file.
;
; MODIFICATION HISTORY:
;        bmy, 28 Jan 2000: VERSION 1.00
;                          - adapted original code from Isabelle Bey
;        bmy, 25 May 2000: GAMAP VERSION 1.45
;                          - now allow the user to specify diagnostic
;                            category names in the batch file
;                          - added internal function "TruncateAndWrapForOx"
;                            to wrap arrays around the date line
;                          - added internal procedure "ErrorOx"
;                            to do error checking for CTM_GET_DATABLOCK
;                          - now can create budgets for more than one
;                            diagnostic interval  
;                          - now allow user not to compute chemical 
;                            production data for given families
;        acs, 26 May 2000: - bug fixes: now do not stop the run if 
;                            data blocks are not found.  
;        bmy, 01 Aug 2000: GAMAP VERSION 1.46
;                          - use abs( Total( X ) ) > 0 when testing if 
;                            transport fluxes are all nonzero
;        bmy, 13 Dec 2001: GAMAP VERSION 1.49
;                          - Now do not require all transport fluxes
;                            to be nonzero in order to compute budgets
;                          - now truncate data blocks correctly for
;                            E/W and N/S transport fluxes
;                          - Now compute the total number of seconds
;                            over the entire diagnostic interval
;                          - Now divide fluxes by the number of diagnostic
;                            time intervals in order to get average fluxes
;        bmy, 17 Jan 2002: GAMAP VERSION 1.50
;                          - now call STRBREAK wrapper routine from
;                            the TOOLS subdirectory for backwards
;                            compatiblity for string-splitting;
;-
; Copyright (C) 2000, 2001, 2002, 
; Bob Yantosca, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author.
; Bugs and comments should be directed to bmy@io.harvard.edu
; with subject "IDL routine ctm_oxbudget"
;-----------------------------------------------------------------------

pro ErrorOx, Diag_Name, Tracer, Tau0, _EXTRA=e

   ;====================================================================
   ; Procedure "ErrorOx" prints error output if CTM_GET_DATABLOCK
   ; cannot find a data block for a given diagnostic, tracer, & time.
   ;====================================================================

   ; Error string
   S = 'No data found!  Category = ' + StrTrim( Diag_Name, 2 )           + $
       ',  Tracer = ' + StrTrim( String( Tracer, Format='(i6)'    ), 2 ) + $
       ',  Tau0 = '   + StrTrim( String( Tau0,   Format='(f10.2)' ), 2 )
   
   ; Display error and stop
   Message, S, _EXTRA=e
end

;-----------------------------------------------------------------------------

function TruncateAndWrapForOx, Data, EW_Flux=EW_Flux, NS_Flux=NS_Flux
   
   ;====================================================================
   ; Function "TruncateAndWrapForOx" truncates the DATA array to the
   ; size of the region specified by IMIN:IMAX, JMIN:JMAX, LMIN:LMAX.
   ; Also accounts for regions that span the date line.
   ;====================================================================
   common BoxOx_Save, Imin, Imax, Jmin, Jmax, Lmin, Lmax

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
   ; For global size region, then we don't need to add an extra row!
   if ( Keyword_Set( EW_Flux ) ) then TmpImax = ( TmpImax + 1 ) mod SData[0]

   ; Add extra latitude element for NS fluxes
   if ( Keyword_Set( NS_Flux ) ) then TmpJmax = ( TmpJmax + 1 ) < SData[1]

   ; Kludge: Make sure TMPJMAX does not exceed JMAX
   TmpJMax = TmpJMax < JMax

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
            NewData          = DblArr( NI ) 
            NewData[0:I1-1 ] = Data[IMin:*]
            NewData[I1:NI-1] = Data[0:TmpIMax]
         end
 
         ; Data is 2-D -- a plane
         2: begin
            NewData                  = DblArr( NI, NJ )
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
         1: begin
            NewData = Double( Data )

            ; Add an extra longitude for E/W fluxes
            if ( Keyword_Set( EW_Flux ) ) then begin
               if ( TmpImax eq Imax + 1 )               $
                  then NewData = NewData[Imin:TmpImax]  $
                  else NewData = [ NewData[Imin:Imax], NewData[IMin] ]
            endif else begin
               NewData = NewData[ Imin:IMax, *, * ]
            endelse
         end

         ; Data is 2-D -- a plane
         2: begin
            NewData = Double( Data )

            ; Add an extra longitude for E/W fluxes
            if ( Keyword_Set( EW_Flux ) ) then begin
               if ( TmpImax eq Imax + 1 )                  $
                  then NewData = NewData[Imin:TmpImax,*,*] $
                  else NewData = [ NewData[Imin:Imax,*,*], NewData[IMin,*,*] ]
            endif else begin
               NewData = NewData[ Imin:IMax, *, * ]
            endelse

            NewData = NewData[ *, Jmin:TmpJmax ] 

         end

         ; Data is 3-D -- a cube
         3: begin
            NewData = Double( Data )

            ; Add an extra longitude for E/W fluxes
            if ( Keyword_Set( EW_Flux ) ) then begin
               if ( TmpImax eq Imax + 1 )                    $
                  then NewData = NewData[Imin:TmpImax,*,*]   $
                  else NewData = [ NewData[Imin:Imax,*,*], NewData[IMin,*,*] ]
            endif else begin
               NewData = NewData[ Imin:IMax, *, * ]
            endelse

            NewData = NewData[ *, Jmin:TmpJmax, * ]
            NewData = NewData[ *, *, Lmin:TmpLmax ]
         end
          
      endcase

   endelse
      
   ; Return truncated and world-wrapped array
   return, NewData
end
 
;-----------------------------------------------------------------------------

function GetHNO3WetDepForOx, FileName, Tau0, Diag_Names, Tracer
 
   ;====================================================================
   ; Function "GetHNO3WetDepForOx" reads the punch file and computes
   ; the total HNO3 wet deposition (from both large-scale and moist-
   ; convective processes).
   ;
   ; NOTE: Wet deposition of HNO3 is originally in [kg/s],
   ;       and is converted to [Gmol/day] here.
   ;====================================================================
   common BoxOx_Save, Imin, Imax, Jmin, Jmax, LMin, LMax

   ; Loop over all diagnostic intervals
   for T = 0L, N_Elements( Tau0 ) - 1L do begin

      ;=================================================================
      ; Get wet deposition of HNO3 in moist convection in kg/s
      ;=================================================================
      Success = CTM_Get_DataBlock(  WetMC, Diag_Names.CV_WetDep, $
                                    Use_FileInfo=Use_FileInfo,   $
                                    Use_DataInfo=Use_DataInfo,   $
                                    ThisDataInfo=ThisDataInfo,   $
                                    GridInfo=GridInfo,           $
                                    Tracer=Tracer,               $
                                    Tau0=Tau0[T],                $
                                    FileName=FileName )
 
      ; Error checking 
      if ( not Success ) then begin
         ErrorOx, Diag_Names.CV_WetDep, Tracer, Tau0[T], /Continue

         ; If not found, set to zero (acs, 5/26/00)
         WetMC = 0D
      endif else begin
         ; Truncate to size of region (and wrap around date line!)
         WetMC = TruncateAndWrapForOx( WetMC )
      endelse

      ;=================================================================
      ; Get large scale loss of HNO3 in kg/s
      ;=================================================================
      Success = CTM_Get_DataBlock( WetLS, Diag_Names.LS_WetDep,  $
                                   Use_FileInfo=Use_FileInfo,    $ 
                                   Use_DataInfo=Use_DataInfo,    $
                                   Tracer=Tracer,                $
                                   Tau0=Tau0[T],                 $
                                   FileName=FileName )
 
      ; Error checking 
      if ( not Success ) then begin
         ErrorOx, Diag_Names.LS_WetDep, Tracer, Tau0[T], /Continue
         
         ; If not found, set WETLS to zero (acs, 5/26/00)
         WetLs = 0D
      endif else begin 
         ; Truncate to size of region (and wrap around date line!)
         WetLS = TruncateAndWrapForOx( WetLS )
      endelse

      ;=================================================================
      ; Convert from [kg/s] to [moles/s] and then to [Gmol/day]
      ;
      ; NOTE: Only proceed if wetdep fluxes are nonzero (acs, 5/26/00)
      ;=================================================================
      if ( Total( WetMC ) gt 0 and Total( WetLS ) gt 0 ) then begin
         WetMC = WetMC / 63d-3
         WetLS = WetLS / 63d-3
 
         ; Define summing arrays on the first iteration
         if ( T eq 0L ) then begin
            Tot_WetMC = Total( WetMC ) * 8.64d-5
            Tot_WetLS = Total( WetLS ) * 8.64d-5
         endif else begin
            Tot_WetMC = Tot_WetMC + ( Total( WetMC ) * 8.64d-5 )
            Tot_WetLS = Tot_WetMC + ( Total( WetLS ) * 8.64d-5 )
         endelse

      endif $
         
      ;=================================================================
      ; If wetdep fluxes are zero, return zeroes (acs, 5/26/00)
      ;=================================================================
      else begin
         Tot_WetMC = 0D 
         Tot_WetLS = 0D  
      endelse
   endfor

   ; Since we have looped over multiple TAU0's, we have to divide by the
   ; number of elements in TAU0 to get an avg flux (mje, cas, bmy, 12/13/01)
   Tot_WetMC = Tot_WetMC / N_Elements( Tau0 )
   Tot_WetLS = Tot_WetLS / N_Elements( Tau0 )

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
 
function GetDryDepositionForOx, FileName, Tau0, DryDep_Flux_Name, Name, Tracer
   
   ;====================================================================
   ; Function "GetDryDepositionForOx" reads the punch file and computes
   ; the combined dry deposition losses of all Ox species.
   ;
   ; NOTE: Dry deposition fluxes are originally in [molec/cm2/s],
   ;       and are converted to [Gmol/day] here.
   ;====================================================================
   common BoxOx_Save, Imin, Imax, Jmin, Jmax, LMin, LMax
 
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
      ; Get the drydep flux in [molec/cm2/s] for this tracer & time
      ;=================================================================
      Success = CTM_Get_DataBlock( DryD, DryDep_Flux_Name,    $
                                   Use_FileInfo=Use_FileInfo, $
                                   Use_DataInfo=Use_DataInfo, $
                                   ModelInfo=ModelInfo,       $
                                   GridInfo=GridInfo,         $
                                   Tracer=Tracer[N],          $
                                   Tau0=Tau0[T],              $
                                   FileName=FileName )
 
      ; Error checking 
      if ( not Success ) then begin
         ErrorOx, DryDep_Flux_Name, Tracer[N], Tau0[T], /Continue
         
         ; Set drydep to zero if it is not found (acs, 5/26/00)
         DryD = 0d0
      endif else begin

         ; Truncate to size of region (and wrap around date line!)
         DryD = TruncateAndWrapForOx( DryD )
      endelse

      ;=================================================================
      ; Compute grid box surface areas in cm2 -- on the first iteration
      ;
      ; NOTE: Only do the following if there is drydep flux present
      ;       from the Nth tracer. (acs, 5/26/00)
      ;=================================================================
      if ( Total( DryD ) gt 0 ) then begin
         if ( Count eq 0L ) then begin
            GEOS = ( ModelInfo.Family eq 'GEOS' )
            GISS = ( ModelInfo.Family eq 'GISS' )
            FSU  = ( ModelInfo.Family eq 'FSU'  )
   
            A_Cm2 = CTM_BoxSize( GridInfo, /Cm2, $
                                 GEOS=GEOS, GISS=GISS, FSU=FSU )
   
            ; Truncate to size of region (and wrap around date line!)
            A_Cm2 = TruncateAndWrapForOx( A_Cm2 )
         endif

         ;=================================================================
         ; Convert drydep flux from [molec/cm2/s] to [moles/s]
         ;=================================================================
         DryD = DryD * ( A_Cm2 / Avo )

         ;=================================================================
         ; Sum drydep fluxes in [moles/s].  Only do the sum if the box
         ; we are considering extends to the surface level.
         ;
         ; Multiply [moles/s] by 8.64d-5 to get [Gmol/day]. 
         ;=================================================================
         if ( LMin eq 0 ) then begin
            TmpTotal[N] = TmpTotal[N] + ( Total( DryD ) * 8.64d-5 )
         endif else begin
            TmpTotal[N] = 0D
         endelse

         Result[N].Total = TmpTotal[N]

         ; Undefine DRYD to save memory
         UnDefine, DryD

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
 
   ; Since we have looped over multiple TAU0's, we have to divide by the
   ; number of elements in TAU0 to get an avg flux (mje, cas, bmy, 12/13/01)
   Result[*].Total = ( Result[*].Total ) / N_Elements( Tau0 )

   ; Return to calling program
   return, Result
end
 
;-----------------------------------------------------------------------------
 
function GetNetExportForOx, FileName, Tau0, Diag_Names, $
                            Tracer,   Mw,   CNum

   ;====================================================================
   ; Function "GetNetExportForOx" reads the punch file and computes
   ; the total export from both transport and convective processes.
   ;
   ; NOTE: Transport & convective fluxes are originally in 
   ;       [molec/cm2/s], and are converted to [Gmol/day] here.
   ;====================================================================
   common BoxOx_Save, Imin, Imax, Jmin, Jmax, LMin, LMax
 
   ; Iteration counter
   Count = 0L

   ; Loop over each diagnostic interval and tracer
   for T = 0L, N_Elements( Tau0   ) - 1L do begin 
   for N = 0L, N_Elements( Tracer ) - 1L do begin
      
      ;=================================================================
      ; Get the E-W transport fluxes in [molec/cm2/s]
      ;=================================================================
      Success = CTM_Get_DataBlock( EW, Diag_Names.EW_Flux,             $
                                   Use_FileInfo=Use_FileInfo,          $
                                   Use_DataInfo=Use_DataInfo,          $
                                   GridInfo=GridInfo,                  $
                                   Tracer=Tracer[N],                   $
                                   Tau0=Tau0[T],                       $
                                   FileName=FileName )
 
      ; Error checking 
      if ( not Success ) then begin
         ErrorOx, Diag_Names.EW_Flux, Tracer[N], Tau0[T], /Continue

         ; If not found, set EW to zero (acs, 5/26/00)
         EW = 0D
      endif else begin
         ; Truncate to size of region (and wrap around date line!)
         ; Add an extra row of longitudes since this is an E-W flux field!
         EW = TruncateAndWrapForOx( EW, /EW_Flux )
      endelse

      ;=================================================================
      ; Get the N-S transport fluxes in [molec/cm2/s]
      ;=================================================================
      Success = CTM_Get_DataBlock( NS, Diag_Names.NS_Flux,          $
                                   Use_FileInfo=Use_FileInfo,       $
                                   Use_DataInfo=Use_DataInfo,       $
                                   Tracer=Tracer[N],                $
                                   Tau0=Tau0[T],                    $
                                   FileName=FileName )
 
      ; Error checking 
      if ( not Success ) then begin
         ErrorOx, Diag_Names.NS_Flux, Tracer[N], Tau0[T], /Continue

         ; If not found, set NS to zero (acs, 5/26/00)
         NS = 0
      endif else begin
         ; Truncate to size of region (and wrap around date line!)
         ; Add an extra row of latitudes since this is a N-S flux field!
         NS = TruncateAndWrapForOx( NS, /NS_Flux )
      endelse

      ;=================================================================
      ; Get the upward transport fluxes in [molec/cm2/s]
      ;=================================================================
      Success = CTM_Get_DataBlock( Up, Diag_Names.UP_Flux,          $
                                   Use_FileInfo=Use_FileInfo,       $
                                   Use_DataInfo=Use_DataInfo,       $
                                   Tracer=Tracer[N],                $
                                   Tau0=Tau0[T],                    $
                                   FileName=FileName )

      ; Error checking 
      if ( not Success ) then begin
         ErrorOx, Diag_Names.UP_Flux, Tracer[N], Tau0[T], /Continue

         ; If not found, set UP to zero (acs, 5/26/00) 
         Up = 0D
      endif else begin
         ; Truncate to size of region (and wrap around date line!)
         Up = TruncateAndWrapForOx( Up )
      endelse

      ;=================================================================
      ; Get the fluxes from wet convection in [molec/cm2/s]
      ;=================================================================
      Success = CTM_Get_DataBlock( Conv, Diag_Names.CV_Flux,        $
                                   Use_FileInfo=Use_FileInfo,       $
                                   Use_DataInfo=Use_DataInfo,       $
                                   Tracer=Tracer[N],                $
                                   Tau0=Tau0[T],                    $
                                   FileName=FileName )
      
      ; Error checking 
      if ( not Success ) then begin
         ErrorOx, Diag_Names.CV_Flux, Tracer[N], Tau0[T], /Continue

         ; If not found, set CONV to zero (acs, 5/26/00)
         Conv = 0D
      endif else begin
         ; Truncate to size of region (and wrap around date line!)
         Conv = TruncateAndWrapForOx( Conv )
      endelse

      ;=================================================================
      ; Get the mass change from boundary layer mixing in [molec/cm2/s]
      ;=================================================================
      Success = CTM_Get_DataBlock( Turb, Diag_Names.TU_Flux,        $
                                   Use_FileInfo=Use_FileInfo,       $
                                   Use_DataInfo=Use_DataInfo,       $
                                   Tracer=Tracer[N],                $  
                                   Tau0=Tau0[T],                    $
                                   FileName=FileName )
 
      ; Error checking 
      if ( not Success ) then begin
         ErrorOx, Diag_Names.TU_Flux, Tracer[N], Tau0[T], /Continue

         ; If not found, set TURB to zero (acs, 5/26/00)
         Turb = 0
      endif else begin
         ; Truncate to size of region (and wrap around date line!)
         Turb = TruncateAndWrapForOx( Turb )
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
      ; Sum contributions from all tracers & times into TOT_* arrays
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

      ; Undefine arrays for safety's sake
      UnDefine, EW
      UnDefine, NS
      UnDefine, UP
      UnDefine, Conv
      UnDefine, Turb

      ; Increment iteration counter
      Count = Count + 1L
   endfor

      ; Since we have looped over multiple TAU0's, we have to divide by the
      ; number of elements in TAU0 to get an avg flux (mje, cas, bmy, 12/13/01)
      Tot_EW = Tot_EW/N_Elements( Tau0   )
      Tot_NS = Tot_NS/N_Elements( Tau0   )
      Tot_UP = Tot_UP/N_Elements( Tau0   )
      Tot_Conv = Tot_Conv/N_Elements( Tau0   )
      Tot_Turb = Tot_Turb/N_Elements( Tau0   )
   endfor

   ;=================================================================
   ; Compute transport fluxes in [Gmol/day]
   ;
   ; TOP    = Total transport flux leaving top of box
   ; BOTTOM = Total transport flux leaving bottom of box
   ;=================================================================
   if ( Abs( Total( Tot_UP ) ) gt 0 ) then begin

      ; Size of the UP array 
      SData = Size( Tot_UP, /Dim )
      NI    = SData[0] 
      NJ    = SData[1]
      NL    = SData[2]

      Top = Total( Tot_UP[0:NI-1, 0:NJ-1, NL-1] ) * 8.64d-5
 
      ; Do not compute Bottom if the bottom of the box is at the surface
      if ( LMin eq 0 ) $
         then Bottom = 0d0  $
         else Bottom = Total( Tot_UP[0:NI-1, 0:NJ-1, 0] ) * 8.64d-5
   endif else begin
      Top    = 0d0
      Bottom = 0d0
   endelse
         
   ;=================================================================
   ; Compute transport fluxes in [Gmol/day]
   ;
   ; EAST = Total transport flux leaving east side of box
   ; WEST = Total transport flux leaving west side of box
   ;=================================================================
   if ( Abs( Total( Tot_EW ) ) gt 0 ) then begin

      ; Size of the EW array (this has one more longitude than normal)
      SData = Size( Tot_EW, /Dim )
      NI    = SData[0]
      NJ    = SData[1]
      NL    = SData[2]
      East  = Total( Tot_EW[NI-1, 0:NJ-1, 0:NL-1] ) * 8.64d-5
      West  = Total( Tot_EW[0,    0:NJ-1, 0:NL-1] ) * 8.64d-5
   endif else begin
      East  = 0d0
      West  = 0d0
   endelse

   ;=================================================================
   ; Compute transport fluxes in [Gmol/day]
   ;
   ; NORTH = Total transport flux leaving north side of box
   ; SOUTH = Total transport flux leaving sourth side of box
   ;=================================================================         
   if ( Abs( Total( Tot_NS ) ) gt 0 ) then begin 

      ; Size of the NS array (this has one more latitude than normal)
      SData = Size( Tot_NS, /Dim )
      NI    = SData[0] 
      NJ    = SData[1]
      NL    = SData[2]
      North = Total( Tot_NS[0:NI-1, NJ-1, 0:NL-1] ) * 8.64d-5   
      South = Total( Tot_NS[0:NI-1, 0,    0:NL-1] ) * 8.64d-5
   endif else begin
      North = 0d0
      South = 0d0
   endelse

   ;====================================================================
   ; Compute convective fluxes in [Gmol/day]
   ; Convective fluxes are positive going upward
   ;
   ; CONVTOP    = Total convective flux leaving top of box
   ; CONVBOTTOM = Total convective flux leaving bottom of box
   ;====================================================================
   if ( Abs( Total( Tot_Conv ) ) gt 0.0 ) then begin

      ; Size of the TOT_CONV array 
      SData = Size( Tot_Conv, /Dim )
      NI    = SData[0] 
      NJ    = SData[1]
      NL    = SData[2]

      ConvTop = Total( Tot_Conv[0:NI-1, 0:NJ-1, NL-1] ) * 8.64d-5
         
      ; Do not compute CONVBOTTOM if the box reaches down to the surface
      if ( LMin eq 0 ) then begin
         ConvBottom = 0d0
      endif else begin
         ConvBottom = Total( Tot_Conv[0:NI-1, 0:NJ-1, 0] ) * 8.64d-5
      endelse
   endif else begin
      ConvTop    = 0d0
      ConvBottom = 0d0
   endelse

   ;====================================================================
   ; Compute fluxes due to boundary layer mixing in [Gmol/day]
   ; (these come from subroutine TURBDAY)
   ;====================================================================
   if ( Abs( Total( Tot_Turb ) ) gt 0.0 ) then begin
      Turbday = Total( Tot_Turb ) * 8.64d-5
   endif else begin
      Turbday = 0d0
   endelse

   ;====================================================================
   ; Compute net flux out of box over all diagnostic intervals
   ; Return net and individual fluxes to calling program
   ;====================================================================
   Net = ( Top   - Bottom ) + ( West    - East       ) + $
         ( South - North  ) - ( ConvTop + ConvBottom ) + TurbDay
 
   ; Return result structure
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

   return, Result
end
  
;-----------------------------------------------------------------------------
 
function GetNetChemicalProductionForOx, FileName,      Tau0, $
                                        ProdLoss_Name, Tracer, Unit
 
   ;====================================================================
   ; Function "GetNetChemicalProductionForOx" reads the punch file and 
   ; computes the net chemical production for the given family.
   ;
   ; NOTE: Transport & convective fluxes are originally in 
   ;       [molec/s], and are converted to [Gmol/day] here.
   ;====================================================================
   common BoxOx_Save, Imin, Imax, Jmin, Jmax, LMin, LMax
   
   ; Error checking
   if ( N_Elements( Tracer ne 2 ) ) $
      then Message, 'TRACER must have 2 elements!'
 
   ; Create output structure
   Result = { Prod : 0D, $
              Loss : 0D, $
              Net  : 0D }

   ; If both tracers are negative, it means that there is no
   ; prodloss data stored in the punch file -- so return zeros
   if ( Tracer[0] lt 0 AND Tracer[1] lt 0 ) then return, Result
   
   ; First time flag
   First = 1L

   ; Loop over each diagnostic interval
   for T = 0L, N_Elements( Tau0 ) - 1L do begin

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
         ErrorOx, ProdLoss_Name, Tracer[0], Tau0[T], /Continue

         ; If not found, set PROD to zero (acs, 5/26/00)
         Prod = 0D
      endif else begin
         ; Truncate to size of region (and wrap around date line!)
         Prod = TruncateAndWrapForOx( Prod )
      endelse

      ;====================================================================
      ; Get chemical loss in [molec/s]
      ;====================================================================
      Success = CTM_Get_DataBlock( Loss, ProdLoss_Name,       $
                                   Use_FileInfo=Use_FileInfo, $
                                   Use_DataInfo=Use_DataInfo, $
                                   ThisDataInfo=ThisDataInfo, $
                                   Tracer=Tracer[1],          $
                                   Tau0=Tau0[T],              $
                                   FileName=FileName )
      
      ; Error checking 
      if ( not Success ) then begin
         ErrorOx, ProdLoss_Name, Tracer[1], Tau0[T], /Continue

         ; If not found, set LOSS to zero (acs, 5/26/00)
         Loss = 0D
      endif else begin
         ; Truncate to size of region (and wrap around date line!)
         Loss = TruncateAndWrapForOx( Loss )
      endelse

      ;=================================================================
      ; Convert PROD, LOSS arrays to [moles/s] 
      ; and sum over the 3-D region
      ;
      ; Only proceed if production and loss are nonzero (acs, 5/26/99)
      ;=================================================================
      Avo = 6.023d23

      if ( Abs( Total( Prod ) ) gt 0   AND $
           Abs( Total( Loss ) ) gt 0 ) then begin
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
               if ( First ) then begin
                  BoxVol = CTM_BoxSize( GridInfo,  /Volume,   /Cm3,    $
                                        GEOS=GEOS, GISS=GISS, FSU=FSU )

                  ; Truncate BOXVOL to size of region 
                  ; (and wrap around date line!)
                  BoxVol = TruncateAndWrapForOx( BoxVol )
               endif

               ; Convert to [moles/s]
               Prod = Prod * BoxVol / Avo
               Loss = Loss * BoxVol / Avo
            end
 
            else: Message, 'Invalid P-L unit selection!'
         endcase
      
         ;=================================================================
         ; Convert total production & loss to [Gmol/day]
         ; Define summing arrays for the first iteration
         ;=================================================================
         if ( First ) then begin
            Tot_Prod = Total( Prod ) * 8.64d-5
            Tot_Loss = Total( Loss ) * 8.64d-5
         endif else begin
            Tot_Prod = Tot_Prod + ( Total( Prod ) * 8.64d-5 )
            Tot_Loss = Tot_Loss + ( Total( Loss ) * 8.64d-5 )
         endelse

      ;====================================================================
      ; If fluxes are zero, just return zeroes (5/26/00)
      ;====================================================================
      endif else return, Result

      ; Reset first time flag
      First = 0L
   endfor

   ; Since we have looped over multiple TAU0's, we have to divide by the
   ; number of elements in TAU0 to get an avg flux (mje, cas, bmy, 12/13/01)
   Tot_Prod = Tot_Prod / N_Elements( Tau0 )
   Tot_Loss = Tot_Loss / N_Elements( Tau0 )

   ;====================================================================
   ; Compute net production over all diagnostic intervals
   ; Return TOT_PROD, TOT_LOSS and NET to the calling program
   ;====================================================================
   Result.Prod = Tot_Prod
   Result.Loss = Tot_Loss
   Result.Net  = Tot_Prod - Tot_Loss
 
   return, Result
end
 
;-----------------------------------------------------------------------------
 
pro ReadBatchFileForOx, BatchFile,     Tau0,      FileName, $
                        DryDep_Family, Ox_Family, Diag_Names
 
   ;====================================================================
   ; Subroutine "ReadBatchFileForOx" reads the batch file which contains
   ; input conditions for CTM_OxBudget.pro
   ;====================================================================
   common BoxOx_Save, Imin, Imax, Jmin, Jmax, LMin, LMax
 
   ; Open the batch file
   Open_File, BatchFile, Ilun_IN, /Get_LUN
   
   ; Get Input file name
   Line = ''
   ReadF, Ilun_IN, Format='(a)',     Line
   ReadF, Ilun_IN, Format='(a)',     Line
   ReadF, Ilun_IN, Format='(a)',     Line
   ReadF, Ilun_IN, Format='(28x,a)', Line
   FileName = StrTrim( Line, 2 )
 
   ; Get TAU0 -- can be a vector!
   ReadF, Ilun_IN, Format='(28x,a)', Line
   ;Dum  = StrSplit( Line, ',', /Extract )
   Dum  = StrBreak( Line, ',' )
   Tau0 = Double( Dum )

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
   
   ; Get category name for EW Flux
   ReadF, ILun_IN, Line
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
   LS_WetDep_CatName = StrTrim( StrBreak( Line, ',' ), 2 )

   ; Get category name for chemical production - loss
   ReadF, Ilun_IN, Format='(28x,a)', Line
   ;ProdLoss_CatName = StrTrim( StrSplit( Line, ',', /Extract ), 2 )
   ProdLoss_CatName = StrTrim( StrBreak( Line, ',' ), 2 )

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
   
   ; Get Ox family names
   ReadF, ILun_IN, Line
   ReadF, Ilun_IN, Format='(28x,a)', Line
   ;Ox_Name = StrTrim( StrSplit( Line, ',', /Extract ), 2 )
   Ox_Name = StrTrim( StrBreak( Line, ',' ), 2 )
 
   ; Get Ox family tracer numbers
   ReadF, Ilun_IN, Format='(28x,a)', Line
   ;Dum       = StrSplit( Line, ',', /Extract )
   Dum       = StrBreak( Line, ',' )
   Ox_Tracer = Fix( Dum )
 
   ; Get Ox family molecular weights --
   ; Convert from [g/mole] to [kg/mole]
   ReadF, Ilun_IN, Format='(28x,a)', Line
   ;Dum   = StrSplit( Line, ',', /Extract )
   Dum   = StrBreak( Line, ',' )
   Ox_Mw = Double( Dum ) * 1d-3
 
   ; Get Ox family constituent numbers --
   ; number of moles of species per moles of Ox
   ReadF, Ilun_IN, Format='(28x,a)', Line
   ;Dum     = StrSplit( Line, ',', /Extract )
   Dum     = StrBreak( Line, ',' )
   Ox_CNum = Double( Dum ) 

   ; Get Ox Family P-L tracer numbers
   ReadF, Ilun_IN, Format='(28x,a)', Line
   ;Dum          = StrSplit( Line, ',', /Extract )
   Dum          = StrBreak( Line, ',' )
   Ox_PL_Tracer = Fix( Dum )
    
   ; Get Ox Family P-L tracer unit
   ReadF, Ilun_IN, Format='(28x,a)', Line
   ;Ox_PL_Unit = StrTrim( StrUpCase( StrSplit( Line, ',', /Extract ) ), 2 )
   Ox_PL_Unit = StrTrim( StrUpCase( StrBreak( Line, ',' ) ), 2 )
  
   ; Close batch file
   Close,    Ilun_IN
   Free_LUN, Ilun_IN
 
   ; Create DRYDEP return structure
   DryDep_Family = { Name   : DD_Name,   $
                     Tracer : DD_Tracer }
 
   ; Create NOx return structure
   Ox_Family  = { Name      : Ox_Name,      $
                  Tracer    : Ox_Tracer,    $
                  Mw        : Ox_Mw,        $
                  CNum      : Ox_CNum,      $
                  PL_Tracer : Ox_PL_Tracer, $
                  PL_Unit   : OX_PL_Unit }

   ; Create return structure for Category Names
   Diag_Names = { EW_Flux     : EW_Flux_CatName[0],     $
                  NS_Flux     : NS_Flux_CatName[0],     $
                  UP_Flux     : UP_Flux_CatName[0],     $
                  CV_Flux     : CV_Flux_CatName[0],     $
                  TU_Flux     : TU_Flux_CatName[0],     $
                  DryDep_Flux : DryDep_Flux_CatName[0], $
                  CV_WetDep   : CV_WetDep_CatName[0],   $
                  LS_WetDep   : LS_WetDep_CatName[0],   $
                  ProdLoss    : ProdLoss_CatName[0] }
   
   ; Return to calling program
   return
end
 
;-----------------------------------------------------------------------------

function GetSecondsForOx, FileName, Tau0_In

   ;====================================================================
   ; Internal function GetSecondsForOx returns the elapsed seconds
   ; corresponding to the TAU0 values specified in BATCHFILE.
   ;====================================================================
   Message, 'Computing total seconds over all diagnostic intervals...', /Info

   ; Search for all data blocks w/ tracer #2
   CTM_Get_Data, DataInfo, FileName=FileName, Tra=2

   ; Search for all possible TAU0, TAU1 values
   Tau0 = DataInfo[*].Tau0
   Tau1 = DataInfo[*].Tau1

   ; Take unique TAU0, TAU1 values
   Tau0 = Tau0( Uniq( Sort( Tau0 ) ) )
   Tau1 = Tau1( Uniq( Sort( Tau1 ) ) )

   ; Match up all possible TAU0, TAU1 values with  
   ; the TAU0 values that we have specified in BATCHFILE
   Ind = Where( Tau0 eq Tau0_In )
   if ( Ind[0] ge 0 ) then begin
      Tau0 = Tau0[Ind]
      Tau1 = Tau1[Ind]
   endif else begin
      Message, 'Cannot find proper TAU0 values!'
   endelse

   ; Compute seconds
   Seconds = Total( ( Tau1 - Tau0 ) * 3600d0 )
   
   ; Remove DATAINFO structure
   UnDefine, DataInfo

   ; Return to calling program
   return, Seconds

end

;-----------------------------------------------------------------------------
 
pro CTM_OxBudget, BatchFile, LogFileName=LogFileName
 
   ctm_cleanup

   ;====================================================================
   ; Start of main program -- common block & keyword settings
   ;====================================================================
   common BoxOx_Save, Imin, Imax, Jmin, Jmax, LMin, LMax
 
   if ( not Keyword_Set( LogFileName ) ) then LogFileName = 'ox_budget.log'
 
   ;=====================================================================
   ; Read the batch file -- returns structures with information
   ; about the names, tracer numbers, & MW's for each type of family
   ;=====================================================================
   ReadBatchFileForOx, BatchFile,     Tau0,      FileName, $
                       DryDep_Family, Ox_Family, Diag_Names
 
   ;=====================================================================
   ; Open log file for output 
   ;=====================================================================
   Open_File, LogFileName, Ilun_OUT, /Write, /Get_LUN
 
   PrintF,Ilun_OUT, 'Results from ctm_oxbudget.pro:'
   PrintF,Ilun_OUT
   PrintF,Ilun_OUT, Format='(''Input File:      : '', a     )', FileName
   PrintF,Ilun_OUT, Format='(''Tau0             : '', f10.3 )', Tau0
   PrintF,Ilun_OUT, Format='(''IMin, IMax       : '', 2i5   )', IMin, IMax
   PrintF,Ilun_OUT, Format='(''JMin, JMax       : '', 2i5   )', JMin, JMax
   PrintF,Ilun_OUT, Format='(''LMin, LMax       : '', 2i5   )', LMin, LMax
   PrintF,Ilun_OUT, Format='(''Box size (I-J-L) : '', 3i5   )', Imax-Imin+1, $
                                                                Jmax-Jmin+1, $
                                                                Lmax-Lmin+1
   Sep = '===================================================================='
   PrintF, Ilun_OUT, ''
   PrintF, Ilun_OUT, Sep
 
   ;=====================================================================
   ; Convert Fortran indices to IDL indices 
   ;=====================================================================
   IMin = IMin - 1  &  IMax = IMax - 1
   JMin = JMin - 1  &  JMax = JMax - 1
   LMin = LMin - 1  &  LMax = LMax - 1
 
   ;=====================================================================
   ; Get number of seconds in each diagnostic interval
   ;=====================================================================
   Seconds = GetSecondsForOx( FileName, Tau0 )
   
   ;====================================================================
   ; Get the wet deposition of HNO3 (TRACER index = 1)
   ;====================================================================
   Tracer = 1L
   HNO3wd = GetHNO3WetDepForOx( FileName, Tau0, Diag_Names, Tracer )

   ; Print to log file
   PrintF,Ilun_OUT, ''
   PrintF,Ilun_OUT, '*** HNO3 Wet Deposition ***'
   PrintF,Ilun_OUT, Format='(''Moist Conv     : '', f10.4 )', HNO3wd.MoistConv
   PrintF,Ilun_OUT, Format='(''Large Scale    : '', f10.4 )', HNO3wd.LargeScale
   PrintF,Ilun_OUT, Format='( 17x, ''----------'' )'
   PrintF,Ilun_OUT, Format='(''Net [Gmol/day] : '', f10.4 )', HNO3wd.Total
 
   ;====================================================================
   ; Get the dry deposition losses of the Ox family species
   ;====================================================================
   if ( Lmin eq 0 ) then begin
      DryDep = GetDryDepositionForOx( FileName, Tau0,         $
                                      Diag_Names.DryDep_Flux, $
                                      DryDep_Family.Name,     $
                                      DryDep_Family.Tracer )
 
      ; Print to log file
      PrintF,Ilun_OUT, ''
      PrintF,Ilun_OUT, ''
      PrintF,Ilun_OUT, '*** Dry Deposition ***'
 
      for N = 0L, N_Elements( DryDep ) - 1L do begin
         PrintF, Ilun_OUT, Format='( a4, 11x, '': '', f10.4 )', $
            DryDep[N].Name, DryDep[N].Total
      endfor
 
      PrintF,Ilun_OUT, Format='( 17x, ''----------'' )'
      PrintF,Ilun_OUT, Format='(''Net [Gmol/day] : '', f10.4 )', $
         Total( DryDep[*].Total )
   endif else $
      DryDep = { Name  : '', Total : 0d0 }
 
   ;====================================================================
   ; Get combined export of the Ox family
   ;====================================================================
   OxEx = GetNetExportForOx( FileName,     Tau0,             $
                             Diag_Names,   Ox_Family.Tracer, $
                             Ox_Family.Mw, Ox_Family.CNum )
   
   ; Create string for log file
   S     = ''
   N_Max = N_Elements( Ox_Family.Name ) - 1

   for N = 0, N_Max do begin
      if ( N eq N_Max ) then SepStr = ' ' else SepStr = '+'
      S = S + Ox_Family.Name[N] + SepStr
   endfor
 
   S = '*** Export of ' + S + '***'
 
   ; Print to log file
   PrintF,Ilun_OUT, ''
   PrintF,Ilun_OUT, ''
   PrintF,Ilun_OUT, S
   PrintF,Ilun_OUT, Format='(''Thru Top       : '', f10.4 )', OxEx.Top
   PrintF,Ilun_OUT, Format='(''Thru Bottom    : '', f10.4 )', OxEx.Bottom
   PrintF,Ilun_OUT, Format='(''Thru East      : '', f10.4 )', OxEx.East
   PrintF,Ilun_OUT, Format='(''Thru West      : '', f10.4 )', OxEx.West
   PrintF,Ilun_OUT, Format='(''Thru North     : '', f10.4 )', OxEx.North
   PrintF,Ilun_OUT, Format='(''Thru South     : '', f10.4 )', OxEx.South
   PrintF,Ilun_OUT, Format='(''Conv thru Top  : '', f10.4 )', OxEx.ConvTop
   PrintF,Ilun_OUT, Format='(''Conv thru Bot  : '', f10.4 )', OxEx.ConvBottom
   PrintF,Ilun_OUT, Format='(''Turbday        : '', f10.4 )', OxEx.Turbday
   PrintF,Ilun_OUT, Format='( 17x, ''----------'' )'
   PrintF,Ilun_OUT, Format='(''Net [Gmol/day] : '', f10.4 )', OxEx.Net
 
   ;====================================================================
   ; Get net chemical production of the Ox family
   ;====================================================================
   OxCh = GetNetChemicalProductionForOx( FileName, Tau0,      $
                                         Diag_Names.ProdLoss, $
                                         Ox_Family.PL_Tracer, $
                                         Ox_Family.PL_Unit )

   ; Create string for log file
   S     = ''
   N_Max = N_Elements( Ox_Family.Name ) - 1

   for N = 0, N_Max do begin
      if ( N eq N_Max ) then SepStr = ' ' else SepStr = '+'
      S = S + Ox_Family.Name[N] + SepStr
   endfor
 
   S = '*** Chemical Prod/Loss of ' + S + '***'
 
   ; Print to log file
   PrintF,Ilun_OUT, ''
   PrintF,Ilun_OUT, ''
   PrintF,Ilun_OUT, S
   PrintF,Ilun_OUT, Format='(''Production     : '', f10.4 )', OxCh.Prod
   PrintF,Ilun_OUT, Format='(''Loss           : '', f10.4 )', OxCh.Loss
   PrintF,Ilun_OUT, Format='( 17x, ''----------'' )'
   PrintF,Ilun_OUT, Format='(''Net [Gmol/day] : '', f10.4 )', OxCh.Net
  
   ;====================================================================
   ; Compute net budget in both [Gmol/day] and [moles]
   ;====================================================================
   NetGMolDay = OxEx.Net + OxCh.Net - HNO3wd.Total - Total( DryDep[*].Total )
   NetMoles   = ( NetGMolDay / 8.64d-5 ) * Seconds 
      
   ; Print to log file
   PrintF, Ilun_OUT, ''
   PrintF, Ilun_OUT, Sep
   PrintF, Ilun_OUT, ''
   PrintF, Ilun_OUT, Format='(''NET [Gmol/day] : '', e12.4)', NetGMolDay
   PrintF, Ilun_OUT, Format='(''NET [moles]    : '', e12.4)', NetMoles
   PrintF, Ilun_OUT, ''
   PrintF, Ilun_OUT, Format='(''# of days      : '', f12.3)', Seconds / 8.64d4

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
