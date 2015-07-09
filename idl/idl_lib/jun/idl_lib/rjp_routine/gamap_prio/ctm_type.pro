; $Id: ctm_type.pro,v 1.3 2004/02/18 15:56:37 bmy Exp $
;-------------------------------------------------------------
;+
; NAME:
;        CTM_TYPE (function)
;
; PURPOSE:
;        return basic parameters for various 3D models used in
;        the Harvard tropospheric modeling group. This information
;        should be sufficient for CTM_GRID to compute grid box edge
;        and center vectors.
;
; CATEGORY:
;        3D tools
;
; CALLING SEQUENCE:
;        mtype = CTM_TYPE(name [,family] [,keywords] )
;
; INPUTS:
;        NAME -> a string containing the name of the model 
;             (GISS_II, GISS_II_PRIME (or II_PRIME), GEOS1,
;             GEOS_STRAT, FSU, MOPITT, or GENERIC (=DUMMY) )
;
;        FAMILY -> model family (optional, will otherwise be extracted
;             from NAME). Possible values: GISS or GEOS or FSU or ''
;
; KEYWORD PARAMETERS:
;        NLAYERS -> number of vertical model layers. This number must
;             correspond to the number of layers in the model output
;             files and is used in conjunction with PTOP to convert
;             sigma levels into pressure altitudes.
;             [defaults: GEOS1=20, GEOS_STRAT=26, GISS=FSU=9 ]
;     
;        NTROP -> number of layers in the troposphere
;             [defaults: GEOS1=14, GISS=7, FSU=12]
;
;        PTOP -> pressure at model top
;             [default 10 mbar except for GEOS_STRAT=0.1 mbar]
;     
;        PSURF -> average surface pressure (needed for conversion of
;             sigma levels to altitudes) [default 984 mbar]
;     
;        RESOLUTION -> either a 2 element vector with [ DI, DJ ] or
;             a scalar (DJxDI: 8=8x10, 4=4x5, 2=2x2.5, 1=1x1, 0.5=0.5x0.5)
;             [default for all models is 4x5]
;     
;        HALFPOLAR = (1 | 0) -> indicates that polar boxes span 
;             (half | same) latitude as all other boxes (DJ=const.)
;             [default: 1]
;
;        HYBRID = (1 | 0) -> indicates that the model is a 
;             (sigma-pressure hybrid | pure sigma level ) model.
;             [default: 0]
;
;        /PRINT -> prints model parameters on the screen
;
; OUTPUTS:
;        A structure with the following field names will be returned:
;        name, family, nlayers, ptop, psurf, resolution,
;        halfpolar, center180, fullchem. If input parameters are not correct,
;        the function returns -1.
;
; SUBROUTINES:
;        Internal Subroutines:
;        =====================
;        USE_CTM_TYPE
;        YES_NO_VAL (function)
;        CHECK_RESOLUTION
;        
;
; REQUIREMENTS:
;
; NOTES:
;        If you update this routine by adding additional models, make
;        sure to update "select_model.pro" and "getsigma.pro" as well.
;
; EXAMPLE:
;        mtype = ctm_TYPE('GEOS1',resolution=2)
;
;        defines model parameters for the GEOS1 model in 2x2.5 degree
;        resolution.
;
;        For use in conjunction with CTM_GRID:
;        mtype = CTM_TYPE('GISS_II')
;        mgrid = CTM_GRID( mtype )
;
;        returns the grid structure for the standard GISS_II model.
;
; MODIFICATION HISTORY:
;        mgs, 02 Mar 1998: VERSION 1.00
;        bmy, 07 Apr 1998: - Renamed to ctm_TYPE to keep
;                            consistent with other CTM subroutines.
;        mgs, 24 Apr 1998: - made structure named
;        mgs, 19 May 1998: - added NTROP tag and keyword
;        bmy, 19 Jun 1998: - now computes FSU model parameters
;                          - GEOS_STRAT and GEOS-1 troposphere tops
;                            are now computed separately
;                          - added small bug fix for fullchem from mgs
;        mgs, 14 Aug 1998: - added DUMMY name
;        mgs, 15 Aug 1998: - added GEOS-1 as variant of GEOS1
;        bmy, 21 Dec 1998: - changed NLAYERS for GEOS STRAT
;        mgs, 22 Dec 1998: - small bug fix for GEOS family NTROP
;        mgs, 22 Feb 1999: - added GENERIC (same as DUMMY) and allow
;                            keyword settings for this name
;        bmy, 23 Feb 1999: - Implemented FSU grid information
;        mgs, 16 Mar 1999: VERSION 1.21 
;                          - cosmetic changes
;                          - changed function name yesno into yesno_val to
;                            avoid conflicts.
;                          - removed online tag because it's never
;                            used
;        bmy, 26 Jul 1999: VERSION 1.42
;                          - added HYBRID keyword and tag name
;                          - cosmetic changes 
;        bmy, 15 Sep 1999: VERSION 1.43
;                          - fixed bug for NTROP in GISS-II-PRIME, 9L
;        bmy, 15 Oct 1999: VERSION 1.44
;                          - now reset model names "GEOS-STRAT" and 
;                            "GEOS-2" to "GEOS_STRAT" and "GEOS2"
;        bmy, 03 Jan 2000: - added GEOS-2 model parameters
;                          - changed NTROP to 16 for GEOS1
;                          - changed NTROP to 22 for GEOS_STRAT
;        bmy, 16 May 2000: VERSION 1.45
;                          - reset NTROP to 19 for GEOS-STRAT    
;                          - now use GEOS-2 47 layer grid    
;        bmy, 01 Aug 2000: VERSION 1.46          
;                          - added GEOS-3 48-layer grid
;                          - added internal function CHECKRESOLUTION
;                          - cosmetic changes, updated comments
;        bmy, 26 Jun 2001: GAMAP VERSION 1.48
;                          - fixed NTROP for GEOS-3 met fields
;                          - for generic grids, return "GENERIC" in
;                            uppercase as model name and family name
;        bmy, 09 Oct 2001: GAMAP VERSION 1.49
;                          - now accepts modelname "GEOS3_30L", and
;                            returns a structure for 30-layer GEOS-3 grid
;        bmy, 06 Nov 2001: - now recognizes "GEOS-4" as a modelname
;                          - changed default PSURF from 986 mb to 984 mb
;  clh & bmy, 18 Oct 2002: GAMAP VERSION 1.52:
;                          - Now supports 7-layer MOPITT grid
;        bmy, 12 Dec 2003: GAMAP VERSION 2.01
;                          - Now supports "GEOS4_30L" grid
;                          - Set NTROP=18 for GEOS-4 grid   
;                          - Now set CENTER180=1 for GISS_II_PRIME 
;                          - Now supports 52-layer NCAR-MATCH model 
;                          - Cleaned up code and straightened out logic
;                          - Removed SMALLCHEM, HELP keywords
;        bmy, 18 Feb 2004: GAMAP VERSION 2.01a
;                          - The actual NTROP from the GEOS-4 annual
;                            mean tropopause is 17, not 18
;   
;-
; Copyright (C) 1998-2004,
; Martin Schultz and Bob Yantosca, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author to arrange payment.
; Bugs and comments should be directed to mgs@io.harvard.edu
; or bmy@io.harvard.edu with subject "IDL routine ctm_type"
;-------------------------------------------------------------


function yesno_val,value
   
   if (value) then return,'yes' else return,'no'
   
end
 
;------------------------------------------------------------------------------

pro CheckResolution, Resolution
   ; Expands and error checks the resolution vector

   ; if resolution "code" is given, complete the information
   if ( N_Elements( Resolution ) eq 1 ) then begin
      case ( Float( Resolution ) ) of 
         8.  : Resolution = [ 10.0, 8.0 ]
         4.  : Resolution = [  5.0, 4.0 ]
         2.  : Resolution = [  2.5, 2.0 ]
         1.  : Resolution = [  1.0, 1.0 ]
         0.5 : Resolution = [  0.5, 0.5 ]
         else : message,'CTM_TYPE : ** invalid resolution ! **'
      endcase
   endif

   ; We should now have two elements...
   if ( N_Elements( Resolution ) ne 2 ) then $
      message,'CTM_TYPE: ** invalid resolution ! **'

   return
end

;------------------------------------------------------------------------------
 
function ctm_type,name,family,  $
            nlayers=nlayers,ntrop=ntrop,ptop=ptop,psurf=psurf, $
            resolution=resolution,halfpolar=halfpolar,center180=center180, $
            hybrid=hybrid, $
            print=print
   
   ;-------------------------------------------------------------
   ; Prior to 12/12/03:
   ; Removed USE_CTM_TYPE function (bmy, 12/12/03)
   ;if (n_elements(name) eq 0 OR keyword_set(HELP)) then begin
   ;   use_ctm_type
   ;   return,-1
   ;endif
   ;-------------------------------------------------------------
 
   ; Convert NAME to uppercase
   Name = StrUpCase( Name )

   ;====================================================================
   ; Handle DUMMY or GENERIC model type first
   ;====================================================================
   if ( name eq 'DUMMY' OR name eq 'GENERIC' ) then begin
      
      ; Default settings (overridden by keywords)
      Name = 'GENERIC'
      if ( N_Elements( Family     ) eq 0 ) then Family     = 'GENERIC'
      if ( N_Elements( NLayers    ) eq 0 ) then NLayers    = 0
      if ( N_Elements( NTrop      ) eq 0 ) then NTrop      = 0
      if ( N_Elements( PTop       ) eq 0 ) then PTop       = 0.
      if ( N_Elements( PSurf      ) eq 0 ) then PSurf      = 0.
      if ( N_Elements( Resolution ) eq 0 ) then Resolution = [ 0., 0. ]
      if ( N_Elements( HalfPolar  ) eq 0 ) then HalfPolar  = 0
      if ( N_Elements( Center180  ) eq 0 ) then Center180  = 0
      if ( N_Elements( Hybrid     ) eq 0 ) then Hybrid     = 0
      FullChem = 0

      ; Error check on the resolution value
      CheckResolution, Resolution

      ; Skip model-specific stuff
      goto, build_struc
   endif

   ;====================================================================
   ; Standardize a few "historic" model names & special cases
   ;====================================================================

   ; (1) Change "II_PRIME" to "GISS_II_PRIME"
   if ( name eq 'II_PRIME'   ) then name = 'GISS_II_PRIME' 
   
   ; (2) Change "GEOS-1" to "GEOS1"
   if ( name eq 'GEOS-1'     ) then name = 'GEOS1'
   
   ; (3) Change GEOS-STRAT to GEOS_STRAT
   if ( name eq 'GEOS-STRAT' ) then name = 'GEOS_STRAT'

   ; (4) Change GEOS-2 to GEOS2 
   if ( name eq 'GEOS-2'     ) then name = 'GEOS2'

   ; (5) Change GEOS-3 to GEOS3 
   if ( name eq 'GEOS-3'     ) then name = 'GEOS3'

   ; (6) Change GEOS3_30L to GEOS-3 and set NLAYERS accordingly 
   if ( name eq 'GEOS3_30L'  ) then begin
      name    = 'GEOS3'
      nlayers = 30
   endif

   ; (7) GEOS-4 data 
   if ( name eq 'GEOS-4'     ) then name = 'GEOS4'
   if ( name eq 'GEOS_4'     ) then name = 'GEOS4'
   if ( name eq 'FVDAS'      ) then name = 'GEOS4'
   
   ; (8) GEOS-4 30 layer grid 
   if ( name eq 'GEOS4_30L'  ) then begin
      name    = 'GEOS4'
      nlayers = 30
   endif

   ; (9) NCAR MATCH model
   if ( name eq 'MACCM3'     ) then name = 'MATCH' 

   ;====================================================================
   ; Get family names corresponding to each model type
   ;====================================================================
   if ( N_Elements( Family ) eq 0 ) then begin
      if ( StrPos( Name, 'GEOS'   ) ge 0 ) then Family = 'GEOS'
      if ( StrPos( Name, 'GISS'   ) ge 0 ) then Family = 'GISS'
      if ( StrPos( Name, 'FSU'    ) ge 0 ) then Family = 'FSU'
      if ( StrPos( Name, 'MATCH'  ) ge 0 ) then Family = 'MATCH'
      if ( StrPos( Name, 'MOPITT' ) ge 0 ) then Family = 'MOPITT'
   endif

   ; extract other (??) model family from name
   if (n_elements(family) eq 0) then begin
      p = strpos(name,'_')
      if (p lt 1) then message,'CTM_TYPE: ** invalid model name ! **'
      family = strmid(name,0,p)
   endif
 
   family = strupcase(family)
   
   ; check validity of model family (we don't check the model name
   ; because new variations should easily be added)
   if ( family ne 'GEOS' and family ne 'GISS'   and $
        family ne 'FSU'  and family ne 'MOPITT' and $ 
        family ne 'MATCH' )                         $
      then message,'CTM_TYPE: ** invalid model family ! **'
 
   ;====================================================================
   ; set general default parameters (some of these may depend on
   ; model family or model name when new models are added)
   ;====================================================================
 
   ; typical average surface pressure 
   ; (mostly used to convert sigma levels to pressures)
   if ( N_Elements( PSURF ) ne 1 ) then PSurf = 984.0

   ; default resolution is 4x5  (stored as [ 5., 4.] )
   if (n_elements(RESOLUTION) eq 0) then resolution = [ 5., 4. ]
 
   ; Error check the resolution value
   CheckResolution, Resolution

   ;====================================================================
   ; Set default parameters according to model family or name
   ; NOTE: These are overridden if you pass the keyword(s) explicitly!
   ;====================================================================
    
   ;-----------------
   ; GISS family
   ;-----------------
   if ( Family eq 'GISS' ) then begin

      ; Defaults are the GISS_II or GISS_II_PRIME 9-layer models
      if (    N_Elements( NLAYERS   ) eq 0 ) then NLayers   = 9

      ; GISS-II' 23L is a hybrid grid; the 9-layer models are pure sigma
      if ( Name eq 'GISS_II_PRIME' and NLayers eq 23 ) then begin
         if ( N_Elements( NTROP     ) eq 0 ) then NTrop     = 11 
         if ( N_Elements( PTOP      ) eq 0 ) then PTop      = 150.0 
         if ( N_Elements( HALFPOLAR ) eq 0 ) then HalfPolar = 1
         if ( N_Elements( CENTER180 ) eq 0 ) then Center180 = 1
         if ( N_Elements( HYBRID    ) eq 0 ) then Hybrid    = 1
      endif else begin
         if ( N_Elements( NTROP     ) eq 0 ) then NTrop     = 7
         if ( N_Elements( PTOP      ) eq 0 ) then Ptop      = 10.0 
         if ( N_Elements( HALFPOLAR ) eq 0 ) then HalfPolar = 1
         if ( N_Elements( CENTER180 ) eq 0 ) then Center180 = 1
         if ( N_Elements( HYBRID    ) eq 0 ) then Hybrid    = 0
      endelse

   endif
 
   ;-----------------
   ; GEOS family
   ;-----------------
   if ( Family eq 'GEOS' ) then begin

      ; GEOS-1: pure sigma
      if ( Name eq 'GEOS1' ) then begin
         if ( N_Elements( NLAYERS   ) eq 0 ) then NLayers   = 20 
         if ( N_Elements( NTROP     ) eq 0 ) then NTrop     = 16
         if ( N_Elements( PTOP      ) eq 0 ) then PTop      = 10.0
         if ( N_Elements( HALFPOLAR ) eq 0 ) then HalfPolar = 1
         if ( N_Elements( CENTER180 ) eq 0 ) then Center180 = 1
         if ( N_Elements( HYBRID    ) eq 0 ) then Hybrid    = 0

      ; GEOS-STRAT: pure sigma
      endif else if ( Name eq 'GEOS_STRAT' ) then begin
         if ( N_Elements( NLAYERS   ) eq 0 ) then NLayers   = 26 
         if ( N_Elements( NTROP     ) eq 0 ) then NTrop     = 19
         if ( N_Elements( PTOP      ) eq 0 ) then PTop      = 0.1
         if ( N_Elements( HALFPOLAR ) eq 0 ) then HalfPolar = 1
         if ( N_Elements( CENTER180 ) eq 0 ) then Center180 = 1
         if ( N_Elements( HYBRID    ) eq 0 ) then Hybrid    = 0

      ; GEOS-2: pure sigma
      endif else if ( Name eq 'GEOS2' ) then begin
         if ( N_Elements( NLAYERS   ) eq 0 ) then NLayers   = 47
         if ( N_Elements( NTROP     ) eq 0 ) then NTrop     = 32
         if ( N_Elements( PTOP      ) eq 0 ) then PTop      = 0.01
         if ( N_Elements( HALFPOLAR ) eq 0 ) then HalfPolar = 1
         if ( N_Elements( CENTER180 ) eq 0 ) then Center180 = 1
         if ( N_Elements( HYBRID    ) eq 0 ) then Hybrid    = 0

      ; GEOS-3: pure sigma
      endif else if ( Name eq 'GEOS3' ) then begin
         if ( N_Elements( NLAYERS   ) eq 0 ) then NLayers   = 48
         if ( N_Elements( NTROP     ) eq 0 ) then NTrop     = 20 
         if ( N_Elements( PTOP      ) eq 0 ) then PTop      = 0.01
         if ( N_Elements( HALFPOLAR ) eq 0 ) then HalfPolar = 1
         if ( N_Elements( CENTER180 ) eq 0 ) then Center180 = 1
         if ( N_Elements( HYBRID    ) eq 0 ) then Hybrid    = 0

      ; GEOS-4: hybrid
      endif else if ( Name eq 'GEOS4' ) then begin
         if ( N_Elements( NLAYERS   ) eq 0 ) then NLayers   = 55 
         ;--------------------------------------------------------------------
         ; Prior to 2/18/04:
         ; The actual NTROP from the GEOS-4 ann mean trop is 17 (bmy, 2/18/04)
         ;if ( N_Elements( NTROP     ) eq 0 ) then NTrop     = 18 
         ;--------------------------------------------------------------------
         if ( N_Elements( NTROP     ) eq 0 ) then NTrop     = 17
         if ( N_Elements( PTOP      ) eq 0 ) then PTop      = 0.01
         if ( N_Elements( HALFPOLAR ) eq 0 ) then HalfPolar = 1
         if ( N_Elements( CENTER180 ) eq 0 ) then Center180 = 1
         if ( N_Elements( HYBRID    ) eq 0 ) then Hybrid    = 1  

      ; Error msg
      endif else begin
         message,'CTM_TYPE : ** unknown layers for GEOS model ! **'
      endelse
   endif

   ;-----------------
   ; FSU family
   ;-----------------   
   if ( Family eq 'FSU' ) then begin
      if ( N_Elements( NLAYERS   ) eq 0 ) then NLayers   = 14   
      if ( N_Elements( NTROP     ) eq 0 ) then NTrop     = 12
      if ( N_Elements( PTOP      ) eq 0 ) then Ptop      = 10.0
      if ( N_Elements( HALFPOLAR ) eq 0 ) then HalfPolar = 0
      if ( N_Elements( CENTER180 ) eq 0 ) then Center180 = 0
      if ( N_Elements( HYBRID    ) eq 0 ) then Hybrid    = 0 
   endif

   ;-----------------
   ; MATCH family 
   ;-----------------    
   if ( Family eq 'MATCH' ) then begin
      if ( N_Elements( NLAYERS   ) eq 0 ) then NLayers   = 52  
      if ( N_Elements( NTROP     ) eq 0 ) then NTrop     = 18 ; bmy guess 
      if ( N_Elements( PTOP      ) eq 0 ) then PTop      = 0.00468101
      if ( N_Elements( HALFPOLAR ) eq 0 ) then HalfPolar = 1
      if ( N_Elements( CENTER180 ) eq 0 ) then Center180 = 1
      if ( N_Elements( HYBRID    ) eq 0 ) then Hybrid    = 1
   endif
   
   ;-----------------
   ; MOPITT family 
   ;-----------------   
   if ( Family eq 'MOPITT' ) then begin
      if ( N_Elements( NLAYERS   ) eq 0 ) then NLayers   = 7   
      if ( N_Elements( NTROP     ) eq 0 ) then NTrop     = 7
      ; Set PTOP the same as GEOS-3 for computing pressures correctly
      if ( N_Elements( PTOP      ) eq 0 ) then Ptop      = 0.01
      if ( N_Elements( HALFPOLAR ) eq 0 ) then HalfPolar = 1
      if ( N_Elements( CENTER180 ) eq 0 ) then Center180 = 1
      if ( N_Elements( HYBRID    ) eq 0 ) then Hybrid    = 0 
   endif

   ;--------------------------------------------
   ; Prior to 12/12/03:
   ; Removed SMALLCHEM keyword (bmy, 12/12/03)
   ;fullchem = 1 - keyword_set(smallchem) 
   ;--------------------------------------------
   FullChem = 1

   ;====================================================================
   ; return structure with all the information gathered 
   ;====================================================================
   
build_struc: 

   ; Reset name to GEOS3_30L or GEOS4_30L after 
   ; internal processing is done (bmy, 10/31/03)
   if ( Name eq 'GEOS3' and NLayers eq 30 ) then Name = 'GEOS3_30L'
   if ( Name eq 'GEOS4' and NLayers eq 30 ) then Name = 'GEOS4_30L'

   result = { ctmmt, $
              name       : name,              $
              family     : family,            $
              nlayers    : fix(nlayers),      $
              ntrop      : fix(ntrop),        $
              ptop       : float(ptop),       $
              psurf      : float(psurf),      $
              resolution : float(resolution), $
              halfpolar  : fix(halfpolar),    $
              center180  : fix(center180),    $
              fullchem   : fix(fullchem),     $
              hybrid     : hybrid }
   
   
   ;====================================================================
   ; produce printout if requested
   ;====================================================================

   if (keyword_set(PRINT)) then begin
      print,'Parameters for model      : ',result.name
      print,'family                    : ',result.family
      print,'vertical layers           : ',result.nlayers,format='(A,i4)'
      print,'tropospheric layers       : ',result.ntrop,format='(A,i4)'
      print,'pressure at top           : ',result.ptop,format='(A,f6.1)'
      print,'av. surface pressure      : ',result.psurf,format='(A,f6.1)'
      print,'resolution                : ',  $
         strcompress(  $
                       string(result.resolution(1),format='(f6.1)')+' x '+ $
                       string(result.resolution(0),format='(f6.1)')  )
      if (result.halfpolar) then hpstr = 'half' else hpstr='full'
      print,'polar boxes               : ',hpstr,' size'
      print,'lon. grid centered at 180 : ',yesno_val(result.center180)
      print,'full chemistry active     : ',yesno_val(result.fullchem)
   endif
   
   return,result
 
end
 
