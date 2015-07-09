; $Id: ctm_column_du.pro,v 1.49 2001/12/17 15:37:31 bmy v1.49 $
;-----------------------------------------------------------------------
;+
; NAME:
;        CTM_Burden
;
; PURPOSE:
;        Calculates burden in Tg for a given
;        CTM tracer.
;
; CATEGORY:
;        CTM_Tools
;
; CALLING SEQUENCE:
;        RESULT = CTM_BURDEN( [ FileName ], [ DiagN ], [ Keywords ] )
;
; INPUTS:
;        FILENAME -> File containing CTM data for which to compute
;             columns.  FILENAME is optional; if omitted the user will
;             be prompted to select a file via a dialog box.
;
;        DIAGN -> Diagnostic category name (or number) containing the
;             tracer data for which columns will be computed.  The
;             default is 'IJ-AVG-$' (i.e. v/v mixing ratios).
;             
; KEYWORD PARAMETERS:
;        TAU0 -> Starting TAU value of the desired data block (will
;             be passed to CTM_GET_DATABLOCK).  
;
;        TRACER -> Number of the tracer for which a column sum be
;             computed.  
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
;             tropopause data for the GEOS-CTM model.  If TROPFILENAME
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
;        RESULT -> a 3-D array containing the columns for TRACER
;             in Dobson Units (DU).  1 DU = 2.69e16 molec/cm2.
;
; SUBROUTINES:
;        Internal Subroutines:
;        ---------------------------------
;        CCD_CONSISTENCY_CHECK (function)
;
;        External Subroutines Required:
;        ---------------------------------
;        CHKSTRU           (function)
;        CTM_GET_DATABLOCK (function)
;        CTM_BOXSIZE       (function)
;
; REQUIREMENTS:
;        References routines in both GAMAP and TOOLS packages.
;
; NOTES:
;        (1) The data block for tracer can be of less than global size.
;            Surface pressure and annual mean tropopause data blocks
;            are assumed to be of global size. 
;
;        (2) An internal consistency check is now done to make sure
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
;
;-
; Copyright (C) 1999, 2000, 2001, Bob Yantosca, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author.
; Bugs and comments should be directed to bmy@io.harvard.edu
; with subject "IDL routine ctm_column_du"
;-----------------------------------------------------------------------


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

function CTM_mass, DiagN,                                        $
                        FileName=FileName,         Tracer=Tracer,     $        
                        Tau0=Tau0,                                    $
                        PFileName=PFileName,       PTau0=PTau0,       $
                        PTracer=PTracer,                              $       
                        TropFileName=TropFileName, Double=Double,     $
                        ModelInfo=ModelInfo,       GridInfo=GridInfo, $
                        XMid=XXMid,                YMid=YYMid,        $
                        ZMid=ZZMid,                _EXTRA=e,          $
                        Cmole = C,                 Area=A_M2,         $
                        Psfc = Press,              AIRD=AIRD
 
   ;===================================================================
   ; External functions / Keyword settings
   ;===================================================================
   FORWARD_FUNCTION CTM_Get_DataBlock, CTM_BoxSize

   if ( N_Elements( DiagN   ) eq 0 ) then DiagN   = 'IJ-AVG-$'
   if ( N_Elements( PTracer ) eq 0 ) then PTracer = 1

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

   ;===================================================================    
   ; Obtain data block for the given tracer and time
   ; XXMID, YYMID, ZZMID are the lon/lat/levels of each grid box
   ; Pass these back to the main program
   ;===================================================================
   Success = CTM_Get_DataBlock( Data, DiagN,                        $
                                XMid=XXMid, YMid=YYMid, ZMid=ZZMid, $
                                Use_FileInfo=Use_FileInfo,          $
                                Use_DataInfo=Use_DataInfo,          $
                                ThisDataInfo=ThisDataInfo1,         $
                                ModelInfo=ModelInfo1,               $
                                GridInfo=GridInfo1,                 $
                                Tracer=Tracer,                      $
                                Tau0=Tau0,                          $
                                FileName=FileName )

   ; Error check
   if ( not Success ) then begin
      Message, 'Could not find concentrations!!', /Continue
      return, -1L
   endif

   ; Make sure DATA has units of [v/v].
   Unit = StrUpCase( StrTrim( ThisDataInfo1.Unit, 2 ) )

   if ( StrPos( Unit, 'PPB' ) ge 0 ) then Data = Data * 1d-9
   if ( StrPos( Unit, 'PPT' ) ge 0 ) then Data = Data * 1d-12

   ;===================================================================
   ; Get surface areas for the given grid in both cm2 and m2
   ;===================================================================   
   GISS = ( ModelInfo1.FAMILY eq 'GISS' )
   FSU  = ( ModelInfo1.FAMILY eq 'FSU'  )
   GEOS = ( ModelInfo1.FAMILY eq 'GEOS' )

   A_Cm2 = CTM_BoxSize( GridInfo1, GEOS=GEOS, GISS=GISS, FSU=FSU, /Cm2 )
   A_M2  = A_Cm2 / 1d4

   ;===================================================================    
   ; Get surface pressures in mb -- Make sure to extract the 
   ; same region of the globe as we did for the tracer above
   ;===================================================================
   if ( N_Elements( PFileName ) eq 0 ) then PFileName = FileName

   Lon = [ Min( XXMid, Max=M ), M ]
   Lat = [ Min( YYMid, Max=M ), M ]

   If Keyword_set(AIRD) then $
   Success = CTM_Get_DataBlock( AIRDEN, 'BXHGHT-$',         $
                                Use_FileInfo=Use_FileInfo,  $
                                Use_DataInfo=Use_DataInfo,  $
                                ThisDataInfo=ThisDataInfo2, $   
                                ModelInfo=ModelInfo2,       $
                                Tracer=2004,                $
                                Tau0=PTau0,                 $
                                FileName=PFileName,         $
                                Lon=Lon,                    $
                                Lat=Lat )

   NewSuccess = CTM_Get_DataBlock( Press, 'PS-PTOP',           $
                                   Use_FileInfo=Use_FileInfo,  $
                                   Use_DataInfo=Use_DataInfo,  $
                                   ThisDataInfo=ThisDataInfo2, $   
                                   ModelInfo=ModelInfo2,       $
                                   Tracer=PTracer,             $
                                   Tau0=PTau0,                 $
                                   FileName=PFileName,         $
                                   Lon=Lon,                    $
                                   Lat=Lat )

   if ( not Success ) then begin
      ; If still not successful, return w/ error message
      if ( not NewSuccess ) then begin
         Message, 'Could not find surface pressures!!', /Continue
         return, -1L
      endif
   endif

   ; Check tracer and surface pressure data blocks for consistency
   Success = CCD_Consistency_Check( FileName,  ModelInfo1, $
                                    PFileName, ModelInfo2 )
   if ( not Success ) then return, -1L
     
   ; GEOS now stores Psurface - PTOP, so add in the PTOP
   if ( GEOS ) then Press = Press + ModelInfo2.PTOP 

   ;===================================================================    
   ; For the GEOS model, also obtain read the annual mean tropopause
   ; -- also make sure to pull out same lat/lon region as for tracer
   ;===================================================================
   if ( GEOS and N_Elements( TropFileName ) gt 0 ) then begin

      Success = CTM_Get_DataBlock( Trop, 'TR-PAUSE',           $
                                   Use_FileInfo=Use_FileInfo,  $
                                   Use_DataInfo=Use_DataInfo,  $
                                   ThisDataInfo=ThisDataInfo3, $
                                   ModelInfo=ModelInfo3,       $
                                   GridInfo=GridInfo3,         $
                                   Tracer=1,                   $
                                   FileName=TropFileName,      $
                                   Lon=Lon,                    $
                                   Lat=Lat )

      ; Error check
      if ( not Success ) then begin
         Message, 'Could not find surface pressures!!', /Continue
         return, -1L
      endif

      ; Check tracer and ann mean trop data blocks for consistency
      Success = CCD_Consistency_Check( FileName,     ModelInfo1, $
                                       TropFileName, ModelInfo3 )
      if ( not Success ) then return, -1L

      ; Subtract 1 to convert TROP from FORTRAN to IDL indexing
      Trop = Trop - 1L
   endif

   ;===================================================================
   ; Define some variables & constants for use below
   ;===================================================================

   ; Size of the tracer data block
   IMX    = ThisDataInfo1.Dim[0]
   JMX    = ThisDataInfo1.Dim[1]
   LMX    = ThisDataInfo1.Dim[2]

   ; Offsets of the tracer data block 
   I0     = ThisDataInfo1.First[0] - 1L
   J0     = ThisDataInfo1.First[1] - 1L

   ; G0_100 is 100 / the gravity constant 
   G0_100 =  100d0 / 9.81d0

   ; Compute thickness of each sigma level
   L      = LMX + 1
   DSig   = GridInfo1.SIGEDGE[0:L-1] - $
            ( Shift( GridInfo1.SIGEDGE, -1 ) )[0:L-2]
 
   ;-------------------------------------------------------------------
   ; Prior to 4/20/00:
   ; First compute AD in kg
   ;for L = 0L, LMX - 1L do begin
   ;   AD[*, *, L] = Press[*, *] * DSIG[L] * G0_100 * A_M2[*, *] 
   ;endfor
   ;
   ; Then convert to molecules air
   ;Ad = Ad * ( 6.022d23 / 28.97d-3 )
   ;-------------------------------------------------------------------

   ; Molecules air / kg air
   XNumolAir = 6.022d23 / 28.97d-3

   ;===================================================================
   ; Compute number density in molec/cm2
   ;
   ; AD = air mass in [molec air]
   ;
   ; C = column in the grid box (I,J,L)
   ;      = [v/v] * [molec air] / [area of grid box in cm2]
   ;
   ; NOTES: 
   ; (1) The box heights cancel out when we do the algebra, so we 
   ;     are left w/ the above expression for Column!
   ;
   ; (2) The tracer data block may be of less than global size.  We
   ;     assume that the data blocks for the surface pressure and
   ;     annual mean tropopause are ALWAYS of global size.  Therefore, 
   ;     use offsets IREF, JREF to reference these arrays.
   ;===================================================================
   Ad = FltArr( IMX, JMX, LMX )
   C  = FltArr( IMX, JMX, LMX )

   if ( GEOS and N_Elements( TropFileName ) gt 0 ) then begin

      ;================================================================
      ; For the GEOS model, if there was a specified annual mean 
      ; tropopause file, compute columns from the surface up to
      ; the height of the annual mean tropopause
      ;================================================================
      for L = 0L, LMX - 1L do begin
      for J = 0L, JMX - 1L do begin
         JREF = J + J0

      for I = 0L, IMX - 1L do begin
         IREF = I + I0

         ; Only process tropospheric boxes
         if ( L lt Trop[IREF, JREF] ) then begin

            ; AD is air mass [molec air]
            Ad[I, J, L] = Press[IREF, JREF] * DSIG[L] * $
                          G0_100 * A_M2[I, J] * XNumolAir 

            ; Compute concentrations in the grid box [mole]
            C[I, J, L] = Data[I, J, L] * AD[I, J, L] / 6.022d23
         endif
      endfor
      endfor
      endfor
      
   endif else begin
      
      ;================================================================
      ; Otherwise, sum up to the vertical extent of the data block
      ;================================================================
        Volume = CTM_BOXSIZE( GridInfo1, /GEOS, /Volume, /m3 )

      IF ( N_elements(AIRDEN) NE 0 ) THEN BEGIN
           AD = AIRDEN
      ENDIF ELSE BEGIN
         for L = 0L, LMX - 1L do begin
         ; Compute air mass [molec air]
           AD[*,*,L] = Press[*,*] * DSIG[L] * G0_100 * A_M2[*,*] $
                     * XNumolAir / Volume[*,*,L]
         Endfor
      END

     
      for L = 0L, LMX - 1L do begin
        ; Compute concentration of tracer
         C[*, *, L]  = Data[*, *, L] * AD[*, *, L] / 6.022d23 ; mol/m3
      endfor

   endelse

   ;===================================================================
   ; Construct total concentrations in moles
   ;===================================================================
   DU = Total( C * Volume )

   Undefine, AIRDEN
   Undefine, AD
   Undefine, Volume
   Ctm_cleanup, /data_only

   ;===================================================================
   ; Return to calling program
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
