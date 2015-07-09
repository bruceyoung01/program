; $Id: ctm_convert_unit.pro,v 1.1.1.1 2003/10/22 18:06:03 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        CTM_CONVERT_UNIT 
;
; PURPOSE:
;        Wrapper program for CONVERT_UNIT.PRO
;
; CATEGORY:
;        Unit Conversion
;
; CALLING SEQUENCE:
;        CTM_CONVERT_UNIT, Data [,Keywords] 
;
; INPUTS:
;        DATA      -> The data array (or value) on which to perform
;                     the unit conversion.  DATA will be converted.
;
; KEYWORD PARAMETERS:
;        CNUM      -> For hydrocarbons, CNUM is the following
;                     ratio: ( moles C / moles hydrocarbon ).
;                     CNUM is needed to convert from ppbC to ppbv.
;
;     Keyword Parameters Passed to CONVERT_UNIT:
;     ==========================================
;        FROM_UNIT -> An individual unit to search and replace. 
;                     If not given, any unit will be converted to 
;                     TO_UNIT, as long as the current unit belongs to 
;                     the same category. 
;
;        TO_UNIT   -> An individual unit to convert to. If not given, 
;                     all units that are converted (see FROM_UNIT)
;                     will be replaced by the standard SI unit of
;                     their category.
;
;        For the individual unit and categories see FIND_UNIT 
;
;        _EXTRA=e  -> Picks up any extra keywords for CTM_CONVERT_UNIT.
;
; OUTPUTS:
;        Returns 1 if conversion was successful, 0 otherwise.
;
; SUBROUTINES:
;        CONVERT_UNIT
;        CONVERT_MOLCM2_KG (function)
;        CONVERT_KG_MOLCM2 (function)
;
; REQUIREMENTS:
;        Uses GAMAP package subroutines
;
; NOTES:
;        Will first convert ppbC to ppbv
;
; EXAMPLE:
;        CTM_CONVERT_UNIT, Data, From='ppbC', To='ppbv', $
;                          CNum=5, Result=Result
;
;                ; converts Isoprene (5 mole C / 1 mole ISOP ) from
;                ; parts per billion of Carbon (ppbC) to parts per
;                ; parts per billion by volume of ISOP (ppbv).
;                ; RESULT = 1 if unit conversion was successful.
;
; MODIFICATION HISTORY:
;        bmy, 29 Sep 1998: VERSION 1.00
;        bmy, 07 Oct 1998: VERSION 1.01
;                          - Added unit conversion for mol/cm2 -> kg etc.. 
;        mgs, 11 Nov 1998: - bug fix if seconds not passed
;        bmy, 21 Jun 2002: GAMAP VERSION 1.51
;                          - now recognize string "molec/cm2/s"
;                          - updated comments, cosmetic changes
;
;-
; Copyright (C) 1998, 2002, Bob Yantosca, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author to arrange payment.
; Bugs and comments should be directed to bmy@io.harvard.edu
; with subject "IDL routine ctm_convert_unit"
;-----------------------------------------------------------------------


pro CTM_Convert_Unit, Data,                                 $
                      From_Unit=From_Unit, To_Unit=To_Unit, $
                      CNum=CNum,           AreaCm2=AreaCm2, $
                      MolWt=MolWt,         Seconds=Seconds, $
                      Result=Result,       _EXTRA=e

   ;====================================================================
   ; Initialization
   ;====================================================================
   From_PPBC   = 0
   To_PPBC     = 0
   From_MolCm2 = 0
   To_MolCm2   = 0
   Result      = 0

   ; For PPBC 
   if ( N_Elements( From_Unit ) gt 0 ) $
      then From_PPBC = ( StrUpCase( From_Unit ) eq 'PPBC' )
   
   if ( N_Elements( To_Unit ) gt 0 ) $
      then To_PPBC = ( StrUpCase( To_Unit ) eq 'PPBC' )

   ; For mol/cm2/s
   if ( N_Elements( From_Unit ) gt 0 ) $
      ;-----------------------------------------------------------------
      ; Prior to 6/21/02:
      ; Also recognize unit string "molec/cm2/s" (bmy, 6/21/02)
      ;then From_MolCm2 = ( StrUpCase( From_Unit ) eq 'MOL/CM2/S' )
      ;-----------------------------------------------------------------
      then From_MolCm2 = ( StrUpCase( From_Unit ) eq 'MOL/CM2/S' OR $
                           StrUpCase( From_Unit ) eq 'MOLEC/CM2/S' )

   if ( N_Elements( From_Unit ) gt 0 ) $
      ;-----------------------------------------------------------------
      ; Prior to 6/21/02:
      ; Also recognize unit string "molec/cm2/s" (bmy, 6/21/02)
      ;then To_MolCm2 = ( StrUpCase( To_Unit ) eq 'MOL/CM2/S' )
      ;-----------------------------------------------------------------
      then To_MolCm2 = ( StrUpCase( To_Unit ) eq 'MOL/CM2/S' OR $
                         StrUpCase( To_Unit ) eq 'MOLEC/CM2/S' )

   ;====================================================================
   ; First handle ppbC -> ppbv (or ppbv -> ppbC) unit conversion
   ;====================================================================
   if ( From_PPBC or To_PPBC ) then begin

      ; We need to have the carbon number to convert ppbC -> ppbv
      if ( N_Elements( CNum ) ne 1 ) then begin
         Message, 'Must supply number of carbon atoms for conversion '+ $
                  'from/to ppbC!', /Continue
         return
      endif
 
      ; Convert ppbC -> ppbV
      if ( From_PPBC ) then begin
         Data      = Data / CNum
         From_Unit = 'ppbv'
      endif
 
      ; Convert ppbv -> ppbC
      if ( To_PPBC  ) then begin
         Data    = Data * CNum
         To_Unit = 'ppbC'
      endif

   endif 
 
   ;====================================================================
   ; Next handle mol/cm2/s --> kg and/or Tg
   ;====================================================================
   if ( From_MolCm2 or To_MolCm2 ) then begin
      
      ; Error checking
      if ( N_Elements( AreaCm2 ) eq 0 ) then begin 
         Message, 'AREACM2 needs to be specified', /Continue
         return
      endif

      if ( N_Elements( MolWt ) eq 0 ) then begin
         Message, 'MOLWT (kg/mole) must be specified!', /Continue
         return
      endif

      ; Convert mol/cm2/s -> kg
      if ( From_MolCm2 ) then begin 
         if ( n_elements(Seconds) gt 0 ) then begin
            Data = Data * Seconds

            Convert_MolCm2_Kg, Data, AreaCm2, MolWt
            From_Unit = 'kg'
            To_Unit   = 'Tg'
         endif else $
 
            message,'SECONDS undefined ! -> No conversion',/Continue
      endif

      ; If the original unit is not in kg, then let's first 
      ; convert it to kg before we convert it to mol/cm2
      if ( To_MolCm2 ) then To_Unit = 'kg'
   endif
      
   ;====================================================================
   ; Call CONVERT_UNIT to do the unit conversion
   ;====================================================================
   Convert_Unit, Data, From_Unit=From_Unit, $
      To_Unit=To_Unit, Result=Result, _EXTRA=e
 
   ; Now that we have kg, we can convert to mol/cm2 if necessary
   if ( To_MolCm2 ) then begin
      Convert_Kg_MolCm2, Data, AreaCm2, MolWt
      ;-----------------------------------------------------------------
      ; Prior to 6/21/02:
      ;To_Unit = 'mol/cm2'
      ;-----------------------------------------------------------------
      To_Unit = 'molec/cm2'
   endif

   ; Return to the calling program 
   return
end
