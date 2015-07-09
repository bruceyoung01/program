; $Id: ctm_column_du.pro,v 1.1.1.1 2007/07/17 20:41:26 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        CTM_COLUMN_DU
;
; PURPOSE:
;        Calculates columns in Dobson Units for a given tracer.
;
; CATEGORY:
;        GAMAP Utilities
;
; CALLING SEQUENCE:
;        RESULT = CTM_COLUMN_DU( DiagN, [ Keywords ] )
;
; INPUTS:
;        DIAGN -> Diagnostic category name (or number) containing the
;             tracer data for which columns will be computed.  The
;             default is 'IJ-AVG-$' (i.e. v/v mixing ratios).
;             
; KEYWORD PARAMETERS:
;        FILENAME -> (OPTIONAL) File containing CTM data for which 
;             to compute columns.  If omitted, then the user will
;             be prompted to select a file via a dialog box.
;
;        TAU0 -> Starting TAU value of the desired data block (will
;             be passed to CTM_GET_DATABLOCK).  If omitted, then 
;             CTM_COLUMN_DU will read data for the first time in
;             the data file.
;
;        TRACER -> Number of tracer for which to compute columns.
;
;        PFILENAME -> Name of the file containing surface pressure
;             data (this is necessary in order to compute column
;             sums).  If PFILENAME is omitted, then CTM_COLUMN_DU
;             will look for surface pressure data in FILENAME.
;
;        PTAU0 -> TAU0 value by which surface pressure data in
;             PFILENAME is indexed.  If PTAU0 is omitted, then
;             CTM_COLUMN_DU will use TAU0.  
;
;        PTRACER -> Tracer number for the surface pressure data.
;             Default is 1.  (For some GISS-CTM punch files, surface
;             pressure is saved as tracer #0). 
;
;        TROPFILENAME -> Name of the file containing the annual mean
;             tropopause data for the GEOS-Chem model.  If TROPFILENAME
;             is supplied, then columns will be computed from the
;             surface up to the annual mean tropopause height.
;             Otherwise, columns will be computed for the full
;             vertical extent of the data.
;
;        /DOUBLE -> If set, will return column sums as double
;             precision.  Otherwise, will return column sums as
;             single precision.
;
;        MODELINFO -> Returns to the calling program the MODELINFO
;             structure (i.e. output from CTM_TYPE) corresponding to 
;             the data.
;
;        GRIDINFO -> Returns to the calling program the GRIDINFO 
;             structure (i.e. output from CTM_GRID) corresponding
;             to the data.
;
;        XMID -> Returns to the calling program the longitude centers
;             in degrees for the extracted data block.
; 
;        YMID -> Returns to the calling program the latitude centers
;             in degrees for the extracted data block.
;
;        ZMID -> Returns to the calling program the altitude centers
;             in # of levels for the extracted data block.
;       
;        _EXTRA=e -> Picks up any extra keywords.
;
;
; OUTPUTS:
;        RESULT -> a 2-D array containing the columns for TRACER
;             in Dobson Units (DU).  1 DU = 2.69e16 molec/cm2.
;
; SUBROUTINES:
;        Internal Subroutines:
;        =============================================================
;        CCD_GetAirMass (function)   CCD_Consistency_Check (function)
;    
;
;        External Subroutines Required:
;        =============================================================
;        CHKSTRU          (function)   CTM_BOXSIZE       (function)
;        CTM_EXTRACT      (function)   CTM_GET_DATABLOCK (function)
;        EXTRACT_FILENAME (function) 
;
; REQUIREMENTS:
;        References routines in both GAMAP and TOOLS packages.
;
; NOTES:
;        (1) An internal consistency check is now done to make sure
;            the tracer data block is of the same model and resolution
;            as the surface pressure and annual mean tropopause data blocks.
;
; EXAMPLE:
;        Result = CTM_COLUMN_DU( 'IJ-AVG-$',          $
;                                FileName='ctm.bpch'  $
;                                Tracer=20,           $
;                                Tau0=80304.0 )
;
;             ; Returns O3 columns in DU from the file "ctm.bpch", 
;             ; for March 1994 (TAU0 = 80304 for GEOS date 3/1/1994).
;
; MODIFICATION HISTORY:
;        bmy, 26 Jul 1999: VERSION 1.00
;        bmy, 20 Apr 2000: GAMAP VERSION 1.45
;                          - renamed from "rvm_o3col"
;                          - removed hardwiring, added comments
;                          - added internal subroutine "CCD_Consistency_Check
;                          - now can sum up to the annual mean tropopause
;                            for GEOS model data blocks
;        bmy, 30 Jul 2001: GAMAP VERSION 1.48
;                          - bug fix: make sure to extract the same
;                            lat/lon region for PS, tropopause heights
;                            as we do for tracers
;                          - added XMID, YMID, ZMID keywords to return
;                            XMID, YMID, ZMID arrays from CTM_GET_DATABLOCK
;                            to the calling program
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
;                          - Rewritten for hybrid grids, and to compute 
;                            DU for a data block of less than global size
;
;-
; Copyright (C) 1999-2007,
; Bob Yantosca and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of 
; this software. If this software shall be used commercially or 
; sold as part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.harvard.edu with subject "IDL routine ctm_column_du"
;-----------------------------------------------------------------------


function CCD_GetAirMass, IMX, JMX, VEdge, Area, P, g100

   ;====================================================================
   ; Internal function CCD_GETAIRMASS returns a 3-D array of air mass
   ; given the vertical edges, surface area, and surface pressure. 
   ; (bmy, 12/19/03)
   ;====================================================================

   ; Number of vertical levels (1 less than edges)
   LMX     = N_Elements( VEdge ) - 1L

   ; Define airmass array
   AirMass = DblArr( IMX, JMX, LMX )

   ; Loop over levels
   for L = 0L, LMX-1L do begin
      AirMass[*,*,L] = P[*,*] * Area[*,*] * ( VEdge[L] - VEdge[L+1] ) * g100
   endfor

   ; Return
   return, AirMass
end

;------------------------------------------------------------------------------

function CCD_Consistency_Check, File1, ModelInfo1, File2, ModelInfo2

   ;====================================================================
   ; Internal routine CCD_Consistency_Check makes sure that two files 
   ; come from the same model family and have the same resolution 
   ;====================================================================

   ; External functions
   FORWARD_FUNCTION ChkStru

   ; Make sure both files come from the same model
   if ( StrUpCase( StrTrim( ModelInfo1.Name, 2 ) )   ne $
        StrUpCase( StrTrim( ModelInfo2.Name, 2 ) ) ) then begin

      ; Extract the file names from File1 and File2
      Str1 = Extract_FileName( File1 )
      Str2 = Extract_FileName( File2 )

      ; Display error message and return
      S = StrTrim( Str1 ) + ' and ' + StrTrim( Str2 ) + $
         ' do not come from the same model!'
      
      Message, S, /Continue
      return, 0L
   endif

   ; Make sure both files have the same horizontal resolution
   if ( ( ModelInfo1.Resolution[0] ne ModelInfo2.Resolution[0] )   OR $
        ( ModelInfo1.Resolution[1] ne ModelInfo2.Resolution[1] ) ) then begin

      ; Extract the file names from File1 and File2
      Str1 = Extract_FileName( File1 )
      Str2 = Extract_FileName( File2 )

      ; Display error message and return
      S = StrTrim( Str1 ) + ' and ' + StrTrim( Str2 ) + $
         ' do not have the same horizontal resolution!'
      
      Message, S, /Continue
      return, 0L
   endif

   ; Successful return!
   return, 1L
end

;------------------------------------------------------------------------------

function CTM_Column_DU, DiagN,                                           $
                        FileName=FileName,         Tracer=Tracer,        $
                        Lon=Lon,                   Lat=Lat,              $
                        Tau0=Tau0,                 PFileName=PFileName,  $
                        PTau0=PTau0,               PTracer=PTracer,      $   
                        TropFileName=TropFileName, Double=Double,        $
                        ModelInfo=ModelInfo,       GridInfo=GridInfo,    $
                        XMid=XXMid,                YMid=YYMid,           $
                        ZMid=ZZMid,                _EXTRA=e
 
   ;====================================================================
   ; Initialization
   ;====================================================================

   ; External functions
   FORWARD_FUNCTION CTM_BoxSize, CTM_Get_DataBlock, $
                    CTM_Extract, Extract_FileName

   ; Default settings
   if ( N_Elements( DiagN   ) eq 0 ) then DiagN   = 'IJ-AVG-$'
   if ( N_Elements( PTracer ) eq 0 ) then PTracer = 1
   if ( N_Elements( Lon     ) eq 0 ) then Lon     =  [ -180, 180 ]
   if ( N_Elements( Lat     ) eq 0 ) then Lat     =  [ -180, 180 ]

   ; Make sure we only specify 1 tracer
   if ( N_Elements( Tracer ) gt 1 ) then begin
      Message, 'TRACER can only have one element!', /Continue
      return, -1L
   endif

   ; Make sure we only specify 1 time
   if ( N_Elements( Tau0 ) gt 1 ) then begin
      Message, 'TAU0 can only have one element!', /Continue
      return, -1L
   endif

   ; Make sure we only specify 1 value for PTRACER!
   if ( N_Elements( PTracer ) gt 1 ) then begin
      Message, 'PTRACER can only have one element!', /Continue
      return, -1L
   endif 

   ; Make sure we only specify 1 value for PTAU0!
   if ( N_Elements( PTau0 ) gt 1 ) then begin
      Message, 'PTAU0 can only have one element!', /Continue
      return, -1L
   endif

   ;====================================================================   
   ; Read tracer concentration data block
   ;====================================================================

   ; Read data (get lons, lats, levs in XXMID, YYMID, ZZMID)
   Success = CTM_Get_DataBlock( Data, DiagN,                        $
                                XMid=XXMid, YMid=YYMid, ZMid=ZZMid, $
                                ThisDataInfo=ThisDataInfo1,         $
                                ModelInfo=ModelInfo1,               $
                                GridInfo=GridInfo1,                 $
                                Lon=Lon,           Lat=Lat,         $
                                Tracer=Tracer,     Tau0=Tau0,       $
                                FileName=FileName, /Quiet,          $
                                /NoPrint,          _EXTRA=e )

   ; Error check
   if ( not Success ) then Message, 'Could not find concentrations!'


   ; Make sure DATA has units of [v/v]
   Unit = StrUpCase( StrTrim( ThisDataInfo1.Unit, 2 ) )
   if ( StrPos( Unit, 'PPB' ) ge 0 ) then Data = Data * 1d-9
   if ( StrPos( Unit, 'PPT' ) ge 0 ) then Data = Data * 1d-12

   ;----------------------------
   ; For resizing data blocks
   ;----------------------------

   ; Define the lon & lat ranges so that we can extract the surface pressure
   ; & tropopause data to the same dimensions of the tracer data block
   DataLon = [ Min( XXMid, Max=M ), M ]
   DataLat = [ Min( YYMid, Max=M ), M ]

   ; Get the size of the tracer data block
   IMX     = N_Elements( XXMid )
   JMX     = N_Elements( YYMid )
   LMX     = N_Elements( ZZMid )

   ;====================================================================
   ; Get grid box surface areas
   ;====================================================================  

   ; Keywords for model type
   GISS  = ( ModelInfo1.FAMILY eq 'GISS' )
   FSU   = ( ModelInfo1.FAMILY eq 'FSU'  )
   GEOS  = ( ModelInfo1.FAMILY eq 'GEOS' )

   ; Grid box surface area [cm2]
   A_Cm2 = CTM_BoxSize( GridInfo1, GEOS=GEOS, GISS=GISS, FSU=FSU, /Cm2 )

   ; Grid box surface area [m2]
   A_M2  = A_Cm2 / 1d4

   ; Resize A_CM2 to the same dimensions as the tracer data block
   A_Cm2 = CTM_Extract( A_Cm2, Model=ModelInfo1, Grid=GridInfo1, $
                        Lev=1, Lon=DataLon,      Lat=DataLat )

   ; Resize A_M2 to the same dimensions as the tracer data block
   A_M2  = CTM_Extract( A_M2,  Model=ModelInfo1, Grid=GridInfo1, $
                        Lev=1, Lon=DataLon,      Lat=DataLat )

   ;====================================================================   
   ; Get surface pressure data block
   ;====================================================================

   ; If PFILENAME is not passed, get surface pressure from the 
   ; same file where we are reading the tracer data
   if ( N_Elements( PFileName ) eq 0 ) then PFileName = FileName
  
   ; Read data (will be the same size as the tracer data block)
   Success = CTM_Get_DataBlock( Press, 'PS-PTOP',           $
                                ThisDataInfo=ThisDataInfo2, $   
                                ModelInfo=ModelInfo2,       $
                                Tracer=1,                   $
                                Tau0=PTau0,                 $
                                FileName=PFileName,         $
                                Lon=DataLon, Lat=DataLat,   $
                                /Quiet,      /NoPrint )

   ; Error check 
   if ( not Success ) then Message, 'Could not find surface pressure data!'

   ; Check tracer and surface pressure data blocks for consistency
   Success = CCD_Consistency_Check( FileName,  ModelInfo1, $
                                    PFileName, ModelInfo2 )

   ; Error check
   if ( not Success ) $
      then Message, 'Tracer and surface pressure data blocks are incompatible!'
     
   ; GEOS now stores Psurface - PTOP, so add in the PTOP
   if ( GEOS ) then Press = Press + ModelInfo2.PTOP 

   ;===================================================================    
   ; Get tropopause location data block
   ;===================================================================

   ; If the troposphere file is passed ...
   if ( GEOS and N_Elements( TropFileName ) gt 0 ) then begin

      ; Read tropopause location (will be the same size as the tracer data)
      Success = CTM_Get_DataBlock( Trop, 'TR-PAUSE',           $
                                   ThisDataInfo=ThisDataInfo3, $
                                   ModelInfo=ModelInfo3,       $
                                   GridInfo=GridInfo3,         $
                                   Tracer=1,                   $
                                   FileName=TropFileName,      $
                                   Lon=DataLon, Lat=DataLat,   $
                                   /Quiet,      /NoPrint )

      ; Error check
      if ( not Success ) $
         then Message, 'Could not find tropopause location data!'

      ; Check tracer and ann mean trop data blocks for consistency
      Success = CCD_Consistency_Check( FileName,     ModelInfo1, $
                                       TropFileName, ModelInfo3 )

      ; Error check
      if ( not Success ) $
         then return, 'Tracer and tropopause data blocks are incompatible!'

      ; Subtract 1 to convert TROP from FORTRAN to IDL indexing
      Trop = Trop - 1L
   endif

   ;====================================================================
   ; Compute the air mass from the surface pressure
   ;====================================================================

   ; G0_100 is 100 / the gravity constant 
   G0_100    = 100d0 / 9.81d0

   ; Molecules air / kg air
   XNumolAir = 6.022d23 / 28.97d-3

   ; Vertical edge coordinates 
   if ( ModelInfo1.Hybrid )                                         $
      then InVertEdge = GridInfo1.EtaEdge[ 0:ThisDataInfo1.Dim[2] ] $
      else InVertEdge = GridInfo1.SigEdge[ 0:ThisDataInfo1.Dim[2] ] 

   ; Get the air mass in each grid box [kg]
   AirMass = CCD_GetAirMass( IMX, JMX, InVertEdge, A_M2, Press, G0_100 )

   ; Convert air mass from [kg] to [molec]
   AirMass = AirMass * XNumolAir

   ; Resize AIRMASS to the same dimensions as the tracer data block
   AirMass = CTM_Extract( AirMass,     Model=ModelInfo1, Grid=GridInfo1, $
                          Lev=[1,LMX], Lon=DataLon,      Lat=DataLat )
   
   ;====================================================================
   ; Compute number density in molec/cm2 and convert to DU
   ;
   ; AirMass = air mass in [molec air]
   ;
   ; C       = column in the grid box (I,J,L)
   ;         = [v/v] * [molec air] / [area of grid box in cm2]
   ;
   ; NOTES: 
   ; (1) The box heights cancel out when we do the algebra, so we 
   ;     are left w/ the above expression for Column!
   ;====================================================================

   ; Create array for column 
   C  = DblArr( IMX, JMX, LMX )

   ; Test if we need to sum total column or tropospheric column
   if ( GEOS and N_Elements( TropFileName ) gt 0 ) then begin

      ;--------------------------------------------
      ; Compute column from surface to tropopause
      ;--------------------------------------------

      for L = 0L, LMX-1L do begin
      for J = 0L, JMX-1L do begin
      for I = 0L, IMX-1L do begin
         if ( L lt Trop[I,J] ) then begin
            C[I,J,L] = ( Data[I,J,L] * AirMass[I,J,L] ) / A_Cm2[I,J]      
         endif
      endfor
      endfor
      endfor
      
   endif else begin
      
      ;--------------------------------------------
      ; Compute total tropospheric column
      ;--------------------------------------------

      for L = 0L, LMX-1L do begin
         C[*,*,L]  = ( Data[*,*,L] * AirMass[*,*,L] ) / A_Cm2
      endfor

   endelse

   ;-----------------------------------------------
   ; Convert from [molec/cm2] -> [DU]
   ;-----------------------------------------------
   DU = Total( C, 3 ) / 2.69d16

   ;===================================================================
   ; Cleanup & quit
   ;===================================================================
Quit:

   ; Return the MODELINFO and GRIDINFO structures via keywords
   ModelInfo = ModelInfo1
   GridInfo  = GridInfo1

   ; If /DOUBLE is set, return DU as double precision.
   ; Otherwise return DU as single precision.
   if ( Keyword_Set( Double ) ) $
      then return, DU $
      else return, Float( DU )
end
