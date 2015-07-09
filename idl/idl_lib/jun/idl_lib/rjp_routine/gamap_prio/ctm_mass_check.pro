; $Id: ctm_mass_check.pro,v 1.1.1.1 2003/10/22 18:06:01 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        CTM_MASS_CHECK
;
; PURPOSE:
;        Plots the time evolution of % difference of tracer mass and 
;        air mass from a CTM simulation.  Used to assess mass
;        conservation in CTM transport codes.
;
; CATEGORY:
;        CTM Tools
;
; CALLING SEQUENCE:
;        CTM_MASS_CHECK [, Keywords ]
;
; INPUTS:
;        None
;
; KEYWORD PARAMETERS:
;        FILENAME -> Name of the CTM output file containing air mass
;             and tracer concentrations.  FILENAME can be either an
;             ASCII punch file or a BINARY punch file.  If omitted,
;             the user will be prompted to supply FILENAME via a 
;             dialog box.
;
;        TRACER -> Number of the tracer that you wish to check for
;             mass conservation.
;
;        /PS -> Set this switch to create PostScript plot output.
;
;        OUTFILENAME -> If /PS is set, OUTFILENAME will be the name of
;             the PostScript plot output file.  Default is "mass_check.ps".
;
;        _EXTRA=e -> Catches extra keywords for routines OPEN_DEVICE
;             and CLOSE_DEVICE.
;
; OUTPUTS:
;        None
;
; SUBROUTINES:
;        External Subroutines Required:
;        ===============================
;        CLOSE_DEVICE   CTM_GET_DATA
;        MULTIPANEL     OPEN_DEVICE    
;        UNDEFINE
;
; REQUIREMENTS:
;        References routines from both GAMAP and TOOLS packages.
;
; NOTES:
;        (1) Assumes that the tracer concentration has been saved
;            under the IJ-AVG-$ diagnostic category.  Also assumes 
;            that the airmass has been saved under the BXHGHT-$
;            diagnostic category.  
;
; EXAMPLE:
;        CTM_MASS_CHECK, FILENAME='ctm.bpch.geos4', TRACER=4
;
;            ; Plots the evolution of % difference of both
;            ; tracer and air mass for CO from a GEOS-4 simulation.
;
; MODIFICATION HISTORY:
;  bdf & bmy, 26 Jun 2003: VERSION 1.00
;
;-
; Copyright (C) 2003, Bob Yantosca, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author.
; Bugs and comments should be directed to bmy@io.harvard.edu
; with subject "IDL routine ctm_mass_check"
;-----------------------------------------------------------------------


pro CTM_Mass_Check, FileName=FileName,       Tracer=Tracer, $
                    OutFileName=OutFileName, PS=PS,         $
                    _EXTRA=e
 
   ;====================================================================
   ; Initialization
   ;====================================================================
   
   ; Keywords
   if ( N_Elements( Tracer      ) ne 1 ) then Tracer = 1
   if ( N_Elements( OutFileName ) ne 1 ) then OutFileName = 'mass_check.ps'

   ;====================================================================
   ; Read data from disk
   ;====================================================================
 
   ; Get DATAINFO structure for boxheights
   CTM_Get_Data, DataInfo_A, 'BXHGHT-$', FileName=FileName, Tracer=2      
 
   ; Get DATAINFO structure for Filenames
   CTM_Get_Data, DataInfo_T, 'IJ-AVG-$', FileName=FileName, Tracer=Tracer
 
   ; We assume that there's an airmass data block for each tracer data block
   if (  N_Elements( DataInfo_A ) ne N_Elements( DataInfo_T ) ) $
      then Message, 'Data blocks are not compatible!'
 
   ;====================================================================
   ; Define variables
   ;====================================================================
 
   ; Number of days in the punch file
   N_Days   = N_Elements( DataInfo_A )
 
   ; Tracer mass and air mass
   Kg_Tra   = Dblarr( N_Days )
   Kg_Air   = Dblarr( N_Days )
 
   ; Tracer mass and air mass % difference
   Perc_Tra = Dblarr( N_Days )
   Perc_Air = Dblarr( N_Days )
 
   ; Day index for Plotting
   Days     = DblArr( N_Days )
 
   ;====================================================================
   ; Read data from disk and compute % difference from initial mass
   ;====================================================================
 
   ; Loop over data blocks
   for D = 0L, N_Days-1L do begin
 
      ; Get tracer name and starting time
      if ( D eq 0 ) then begin
         TrcName  = DataInfo_T[0].TracerName 
         Tau0     = DataInfo_T[0].Tau0
      endif
 
      ; Get air mass [kg] and tracer concentration [v/v]
      AirMass     = *( DataInfo_A[D].Data )
      Conc        = *( DataInfo_T[D].Data )
 
      ; Compute tracer mass [kg] and air mass [kg]
      Kg_Tra[D]   = Total( AirMass * Conc )
      Kg_Air[D]   = Total( AirMass        )
 
      ; Compute % difference of tracer and air mass from start of run
      Perc_Tra[D] = 100D * ( Kg_Tra[D] - Kg_Tra[0] ) / Kg_Tra[0]
      Perc_Air[D] = 100D * ( Kg_Air[D] - Kg_Air[0] ) / Kg_Air[0]
 
      ; Day index for plotting
      Days[D]     = ( DataInfo_T[D].Tau0 - DataInfo_T[0].Tau0 ) / 24d0
 
      ; Undefine arrays
      UnDefine, AirMass
      UnDefine, Conc
   endfor
   
   ;====================================================================
   ; Plot results
   ;====================================================================
 
   ; Open the plot device
   Open_Device, /Color, Bits=8, PS=PS, FileName=OutFileName, _EXTRA=e
 
   ; Number of panels
   MultiPanel, Rows=2, Cols=1
 
   ; Convert starting time to date
   Result = Tau2YYMMDD( Tau0, /NFormat )
 
   ;------------------
   ; Tracer mass plot
   ;------------------
 
   ; Create title for top of plot
   Title = 'Mass of '        + StrTrim( TrcName, 2 )                + $
           ' (start date = ' + String( Result[0], Format='(i8.8)' ) + ')' 
 
   ; X-axis range
   XRange = [ 0, Max( Days ) ]
 
   ; Tracer mass plot
   Plot, Days, Perc_Tra,                              $
      Color=1,              Title=Title,              $
      XTitle='Time [days]', Ytitle='Percentage [%]',  $
      XRange=XRange,        /XStyle
 
   ; Plot dashed line at 0
   Oplot, XRange, [0, 0], LineStyle=2, Thick=2, Color=1
 
   ;------------------
   ; Air mass plot
   ;------------------
 
   ; Create title for top of plot
   Title = 'Mass of AIR (start date = '         + $
           String( Result[0], Format='(i8.8)' ) + ')' 
 
   ; Air mass plot
   Plot, Days, Perc_Air,                              $
      Color=1,              Title=Title,              $
      XTitle='Time [days]', Ytitle='Percentage [%]',  $
      XRange=XRange,        /XStyle
 
   ; Plot dashed line at 0
   Oplot, XRange, [0, 0], LineStyle=2, Thick=2, Color=1
 
   ; Close the plot device
   Close_Device, _EXTRA=e
 
end
