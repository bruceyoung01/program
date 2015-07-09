; $Id: create_nested_met.pro,v 1.3 2008/04/02 15:19:04 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        CREATE_NESTED_MET
;
; PURPOSE:
;        Reads GEOS-Chem binary met data files at global resolution
;        and creates new files that have been "cut down" to a 
;        particular nested-grid region (e.g. China, North America,
;        Europe).  Vertical resolution is not affected.
;
; CATEGORY:
;        Regridding
;
; CALLING SEQUENCE:
;        CREATE_NESTED_MET [, Keywords ]
;
; INPUTS:
;        None
;
; KEYWORD PARAMETERS:
;        INFILENAME -> Name of the input file containing data to be 
;             trimmed down to "nested" model grid resolution.  If 
;             omitted, a dialog box will prompt the user to supply
;             a filename.
;
;        OUTFILENAME -> Name of the file that will contain trimmed
;             data on the "nested" model grid.  OUTFILENAME will be
;             in binary punch resolution.  If omitted, a dialog box 
;             will prompt the user to supply a filename.
;
;        /CHINA -> Set this switch to create nested-grid met data
;             files for the CHINA region.
;
;        /NAMER -> Set this switch to create nested-grid met data
;             files for the NORTH AMERICA region.
;
;        /EUROPE -> Set this switch to create nested-grid met data
;             files for the EUROPE region.
;             ### NOTE: Need to define the region as of 10/4/07 ###
;
;        /VERBOSE -> Set this switch to print extra informational
;             messages to the screen.
;
; OUTPUTS:
;        None
;
; SUBROUTINES:
;        Internal Subroutines:
;        ================================================
;        CNM_GETGRID            CNM_GETCORNERS
;
;        External Subroutines Required:
;        ================================================
;        CTM_INDEX
;        CTM_TYPE  (function)   CTM_GRID (function)
;
; REQUIREMENTS:
;        None
;
; NOTES:
;        (1) Works for the following types of data blocks:
;            (a) 2-D "horizontal" (longitude-latitude)
;            (b) 3-D "global"     (longitude-latitude-altitude)
;
; EXAMPLE:
;        CREATE_NESTED_MET, INFILENAME='20021031.i6.1x1',      $
;                           OUTFILENAME='20021031.i6.1x1.USA', $
;                           /NAMER
;
;             ; Trims DAO met data from "20021031.i6.1x1" to a nested 
;             ; grid from 150W to 30W and 10N to 70N (in this example,
;             ; this covers the US and parts of Canada and Mexico).
;
; MODIFICATION HISTORY:
;        bmy, 18 Jan 2003: VERSION 1.00
;                          - adapted from "create_nested.pro"  
;        bmy, 25 Sep 2003: VERSION 1.01
;                          - also added GEOS-4 met fields
;  bmy & phs, 24 Sep 2007: GAMAP VERSION 2.10
;                          - Rewritten for compatibility with
;                            GAMAP internal routine CTM_READ_GMAO
;        bmy, 02 Apr 2008: GAMAP VERSION 2.12
;                          - Make sure we create big-endian binary files
;
;-
; Copyright (C) 2003-2008, 
; Bob Yantosca, and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of this 
; software. If this software shall be used commercially or sold as 
; part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.as.harvard.edu with subject "IDL routine create_nested_met"
;-----------------------------------------------------------------------

pro CNM_GetGrid, Ident, InType, InGrid

   ;====================================================================
   ; Internal routine CNM_GETGRID returns the MODELINFO and GRIDINFO
   ; structures, given the information in the met field IDENT string.
   ; (bmy, 9/24/07)
   ;====================================================================

   ; Parse the IDENT string
   if ( StrMid( Ident, 0, 2 ) eq 'G4' ) then begin

      ;-----------------
      ; GEOS-4 grids
      ;-----------------

      ; Get GEOS-4 resolution from IDENT string
      case ( StrMid( Ident, 3, 2 ) ) of 
         '11' : Res = [ 1.25,  1.0 ]
         '22' : Res = [ 2.5,   2.0 ]
         '45' : Res = [ 5.0,   4.0 ]
         '56' : Res = [ 0.625, 0.5 ]
         else : Message, 'Could not find resolution in GEOS-4 ident string!'
      endcase
        
      ; Create MODELINFO structure
      InType = CTM_Type( 'GEOS4', Res=Res )

   ; Parse the IDENT string
   endif else if ( StrMid( Ident, 0, 2 ) eq 'G5' ) then begin

      ;-----------------
      ; GEOS-5 grids
      ;-----------------

      ; Get GEOS-4 resolution from IDENT string
      case ( StrMid( Ident, 3, 2 ) ) of
         '10' : Res = [ 1.25,    1.0   ] 
         '11' : Res = [ 1.25,    1.0   ]
         '22' : Res = [ 2.5,     2.0   ]
         '45' : Res = [ 5.0,     4.0   ]
         '56' : Res = [ 2d0/3d0, 0.5d0 ]
         else : Message, 'Could not find resolution in GEOS-5 ident string!'
      endcase

      ; Create MODELINFO structure
      InType = CTM_Type( 'GEOS5', Res=Res )

   endif else if ( StrMid( Ident, 0, 2 ) eq 'GP' ) then begin

      ;-----------------
      ; GCAP 4x5 grid
      ;-----------------

      ; Create MODELINFO structure
      InType = CTM_Type( 'GCAP', Res=4 )

   endif

   ; Return GRIDINFO structure
   InGrid = CTM_Grid( InType )
   
end

;------------------------------------------------------------------------------

pro CNM_GetCorners, ModelInfo, China, NAmer, Europe, LL, UR

   ;====================================================================
   ; Internal routine CNM_GETCORNERS returns the (lat,lon) at the lower
   ; left and upper right corners of the nested grid region for China,
   ; Europe, or North America.  This is essentially the same algorithm
   ; as is used in CTM_READ_GMAO. (bmy, 9/24/07)
   ;====================================================================

   if ( China ) then begin

      ;-------------------------
      ; China nested grid
      ;-------------------------
      LL    = [ -11,  70 ]
      UR    = [  55, 150 ]

   endif else if ( NAmer ) then begin

      ;-------------------------
      ; N. America nested grid
      ;-------------------------

      ; GEOS-5 nested grid goes up to 70N
      if ( ModelInfo.Name eq 'GEOS3' ) then begin
         LL    = [ 10, -140 ] 
         UR    = [ 60,  -40 ]
      endif else begin
         LL    = [ 10, -140 ] 
         UR    = [ 70,  -40 ]
      endelse

   endif else if ( Europe ) then begin

      ;-------------------------
      ; Europe nested grid
      ;-------------------------
      LL    =  [ 1, 1 ]  ; define these later
      UR    =  [ 1, 1 ]

   endif
end

;-----------------------------------------------------------------------------

pro Create_Nested_Met, InFileName=InFileName,   OutFileName=OutFileName,   $
                       China=China,             NAmer=NAmer,               $
                       Europe=Europe,           Verbose=Verbose,           $
                       _EXTRA=e

   ;====================================================================
   ; Initialization
   ;====================================================================
 
   ; External functions
   FORWARD_FUNCTION CTM_Type, CTM_Grid, Little_Endian
 
   ; Keyword Settings
   Verbose = Keyword_Set( Verbose )
   China   = Keyword_Set( China  )
   NAmer   = Keyword_Set( NAmer  )
   Europe  = Keyword_Set( Europe )

   ; Date and time variables
   XYMD    = 0L
   XHMS    = 0L

   ; Met field name & ident string are 8-chars long
   Name    = '12345678'
   Ident   = '12345678'

   ;=====================================================================
   ; Open the input & output files
   ;=====================================================================

   ; Hardwire unit numbers for safety's sake
   Ilun_IN  = 21
   Ilun_OUT = 23

   ; Are we on a little-endian machine?
   SE       = Little_Endian()

   ; Open INPUT and OUTPUT files (read/write as big-endian)
   Open_File, InFileName,  Ilun_IN,  /F77,         Swap_Endian=SE, _EXTRA=e
   Open_File, OutFileName, Ilun_OUT, /F77, /Write, Swap_Endian=SE, _EXTRA=e
   
   ; Read the identification string & write it to output file
   ReadU,  Ilun_IN,  Ident
   WriteU, Ilun_OUT, Ident

   ; Verbose output
   if ( Verbose ) then begin
      S = 'Ident string: ' + Ident
      Message, S, /Info
   endif

   ;=====================================================================
   ; Define model type and grid structures
   ;=====================================================================
   
   ; Get the modelinfo and gridinfo structures, given the IDENT string
   CNM_GetGrid, Ident, InType, InGrid

   ; Global dimensions of the input grid
   NI = InGrid.IMX              
   NJ = InGrid.JMX            
   NL = InGrid.LMX 

   ;=====================================================================
   ; Define model type and grid structures
   ;=====================================================================

   ; Get lower-left and upper-right corners of the region
   CNM_GetCorners, InType, China, NAmer, Europe, LL, UR
 
   ; Get (I,J) index of LL and UR corners of nested region
   ; NOTE: (I,J) are in FORTRAN notation (starting from 1)
   CTM_Index, InType, I0, J0, Center=LL, /Non_Interactive
   CTM_Index, InType, I1, J1, Center=UR, /Non_Interactive

   ; Convert (I,J) from Fortran to IDL notation
   I0 = I0 - 1L
   I1 = I1 - 1L
   J0 = J0 - 1L
   J1 = J1 - 1L

   ; Nx and Ny are the nested-grid dimensions
   Nx = I1 - I0 + 1
   Ny = J1 - J0 + 1

   ; Verbose output
   if ( Verbose ) then begin
      S = 'Nested-grid dimensions are ' + $
         String( Nx, Format='(i4)' )    + $
         String( Ny, Format='(i4)' )
      Message, S, /Info
   endif

   ;=====================================================================
   ; Loop thru file, read data, print times, name, max & min
   ;=====================================================================

   while ( not EOF( Ilun_IN ) ) do begin
 
      ; Read the name of the met field (8-char string)
      ReadU, Ilun_IN, Name
      StrName = StrUpCase( StrCompress( Name, /Remove_all ) )
 
      ; Verbose output
      if ( Verbose ) then begin
         S = 'Processing ' + StrName
         Message, S, /Info
      endif

      ; Size the data array for either 2-D or 3-D fields
      ; (add fields to the CASE statement as necessary)
      case ( StrName ) of
 
         ; 2-D fields
         'ALBD'      : InData = FltArr( NI, NJ     )
         'ALBEDO'    : InData = FltArr( NI, NJ     )
         'CLDFRC'    : InData = FltArr( NI, NJ     )    
         'EVAP'      : InData = FltArr( NI, NJ     )
         'GRN'       : InData = FltArr( NI, NJ     )
         'GWETROOT'  : InData = FltArr( NI, NJ     )
         'GWET'      : InData = FltArr( NI, NJ     )
         'GWETTOP'   : InData = FltArr( NI, NJ     )
         'HFLUX'     : InData = FltArr( NI, NJ     )
         'LAI'       : InData = FltArr( NI, NJ     ) 
         'LWGNET'    : InData = FltArr( NI, NJ     )
         'LWI'       : InData = FltArr( NI, NJ     ) 
         'MOLENGTH'  : InData = FltArr( NI, NJ     )
         'OICE'      : InData = FltArr( NI, NJ     )
         'PARDF'     : InData = FltArr( NI, NJ     ) 
         'PARDR'     : InData = FltArr( NI, NJ     ) 
         'PBL'       : InData = FltArr( NI, NJ     )
         'PBLH'      : InData = FltArr( NI, NJ     )
         'PS'        : InData = FltArr( NI, NJ     )
         'PHIS'      : InData = FltArr( NI, NJ     )
         'PREACC'    : InData = FltArr( NI, NJ     )
         'PRECON'    : InData = FltArr( NI, NJ     )
         'PRECCON'   : InData = FltArr( NI, NJ     )
         'PRECSNO'   : InData = FltArr( NI, NJ     )
         'PRECTOT'   : InData = FltArr( NI, NJ     )
         'RADLWG'    : InData = FltArr( NI, NJ     )
         'RADSWG'    : InData = FltArr( NI, NJ     )
         'RADSWT'    : InData = FltArr( NI, NJ     )
         'SLP'       : InData = FltArr( NI, NJ     )
         'SNICE'     : InData = FltArr( NI, NJ     )
         'SNODP'     : InData = FltArr( NI, NJ     )
         'SNOMAS'    : InData = FltArr( NI, NJ     )
         'SNOW'      : InData = FltArr( NI, NJ     )
         'SNOWD'     : InData = FltArr( NI, NJ     )
         'SOIL'      : InData = FltArr( NI, NJ     )
         'SURFTYPE'  : InData = FltArr( NI, NJ     )
         'TROPP'     : InData = FltArr( NI, NJ     )
         'T2M'       : InData = FltArr( NI, NJ     )
         'TGROUND'   : InData = FltArr( NI, NJ     )
         'TO3'       : InData = FltArr( NI, NJ     )
         'TS'        : InData = FltArr( NI, NJ     )
         'TTO3'      : InData = FltArr( NI, NJ     )
         'TSKIN'     : InData = FltArr( NI, NJ     )
         'U10M'      : InData = FltArr( NI, NJ     )
         'USTAR'     : InData = FltArr( NI, NJ     )
         'USS'       : InData = FltArr( NI, NJ     )
         'V10M'      : InData = FltArr( NI, NJ     )
         'VSS'       : InData = FltArr( NI, NJ     )
         'Z0'        : InData = FltArr( NI, NJ     )
         'Z0M'       : InData = FltArr( NI, NJ     )
 
         ; 3-D fields
         'CLDF'      : InData = FltArr( NI, NJ, NL    ) 
         'CLDMAS'    : InData = FltArr( NI, NJ, NL    )
         'CLDTOT'    : InData = FltArr( NI, NJ, NL    )
         'CLMOLW'    : InData = FltArr( NI, NJ, NL    )
         'CLROLW'    : InData = FltArr( NI, NJ, NL    )
         'CMFDTR'    : InData = FltArr( NI, NJ, NL    )
         'CMFETR'    : InData = FltArr( NI, NJ, NL    )
         'CMFMC'     : InData = FltArr( NI, NJ, NL+1L )
         'DELP'      : InData = FltArr( NI, NJ, NL    )
         'DETRAINE'  : InData = FltArr( NI, NJ, NL    )
         'DETRAINN'  : InData = FltArr( NI, NJ, NL    )
         'DNDE'      : InData = FltArr( NI, NJ, NL    )
         'DNDN'      : InData = FltArr( NI, NJ, NL    )
         'DTRAIN'    : InData = FltArr( NI, NJ, NL    )
         'ENTRAIN'   : InData = FltArr( NI, NJ, NL    )
         'HKBETA'    : InData = FltArr( NI, NJ, NL    )
         'HKETA'     : InData = FltArr( NI, NJ, NL    )
         'KZZ'       : InData = FltArr( NI, NJ, NL    )
         'MOISTQ'    : InData = FltArr( NI, NJ, NL    )
         'OPTDEPTH'  : InData = FltArr( NI, NJ, NL    )
         'MFXC'      : InData = FltArr( NI, NJ, NL    )
         'MFYC'      : InData = FltArr( NI, NJ, NL    )
         'MFZ'       : InData = FltArr( NI, NJ, NL+1L )
         'PL'        : InData = FltArr( NI, NJ, NL    )
         'PLE'       : InData = FltArr( NI, NJ, NL+1L )
         'PV'        : InData = FltArr( NI, NJ, NL    )
         'Q'         : InData = FltArr( NI, NJ, NL    )
         'QI'        : InData = FltArr( NI, NJ, NL    )
         'QL'        : InData = FltArr( NI, NJ, NL    )
         'QV'        : InData = FltArr( NI, NJ, NL    )
         'RH'        : InData = FltArr( NI, NJ, NL    )
         'T'         : InData = FltArr( NI, NJ, NL    )
         'TAUCLD'    : InData = FltArr( NI, NJ, NL    )
         'TMPU'      : InData = FltArr( NI, NJ, NL    )
         'SPHU'      : InData = FltArr( NI, NJ, NL    )
         'U'         : InData = FltArr( NI, NJ, NL    )
         'UWND'      : InData = FltArr( NI, NJ, NL    )
         'V'         : InData = FltArr( NI, NJ, NL    )
         'VWND'      : InData = FltArr( NI, NJ, NL    )
         'ZMEU'      : InData = FltArr( NI, NJ, NL    )
         'ZMMD'      : InData = FltArr( NI, NJ, NL    )
         'ZMMU'      : InData = FltArr( NI, NJ, NL    ) 

      endcase
  
      ; Read the INPUT data
      ReadU, Ilun_IN, XYMD, XHMS, InData

      ;### Debug
      ;print, xymd, xhms, Name, min( InData, Max=M ), M, $
      ;   Format='( i8,1x,i6.6,1x,a8,1x,2f13.6)'
 
      ; Test for NAN
      Ind = Where( not Float( Finite( InData ) ) )
      if ( Ind[0] ge 0 ) then Message, 'Non-finite data values found!'
 
      ; Trim data down to nested grid size
      case ( Size( InData, /N_Dim ) ) of 

         ;----------------------
         ; 2-D lon-lat data
         ;----------------------         
         2: begin
            OutData  = InData[I0:I1,*]
            UnDefine, InData
            OutData  = OutData[*,J0:J1]
         end

         ;----------------------
         ; 3-D lon/lat/alt data
         ;----------------------
         3: begin
            OutData  = InData[I0:I1,*,*]
            UnDefine, InData
            OutData  = OutData[*,J0:J1,*]
         end

         ; Error msg
	 else: Message, 'Invalid Dimensions of INDATA!'

      endcase

      ; Write trimmed data to OUTPUT file
      WriteU, Ilun_OUT, Name
      WriteU, Ilun_OUT, XYMD, XHMS, OutData

      ; Undefine stuff
      UnDefine, OutData

   endwhile
   
   ;====================================================================
   ; Close files and quit
   ;====================================================================
Quit:

   Close, Ilun_IN
   Close, Ilun_OUT

   ; Quit
   return
end
          
