; $Id: test_dao.pro,v 1.2 2004/01/29 19:33:41 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        TEST_DAO
;
; PURPOSE:
;        Prints out the name, time, and min/max of data of DAO
;        data files which are used as input to GEOS-CHEM.
;
; CATEGORY:
;        CTM Tools
;
; CALLING SEQUENCE:
;        TEST_DAO, MODELINFO [, Keywords ]
;
; INPUTS:
;        MODELINFO -> Output structure from CTM_TYPE which defines
;             the input grid parameters.  
;
; KEYWORD PARAMETERS:
;        FILENAME -> Name of the binary met field file to examine.  If 
;             FILENAME is not passed, then the user will be prompted
;             to supply a file name via a dialog box query.
;
;        /VERBOSE -> If set, then will echo extra information
;             to the screen.
;
;        XRANGE -> A 2-element vector containing the minimum and
;             maximum box center longitudes which define the nested
;             model grid. Default is [-180,180].
;
;        YRANGE -> A 2-element vector containing the minimum and
;             maximum box center latitudes which define the nested
;             model grid. Default is [-90,90].
;
;        PLOTLEVEL -> If specified, then TEST_DAO will plot a lon-lat
;             map of the given vertical level of the data.  Useful for
;             debugging purposes.
;
;        _EXTRA=e -> Picks up extra keywords for OPEN_FILE.
;
; OUTPUTS:
;        None
;
; SUBROUTINES:
;        External Subroutines Required:
;        ================================
;        OPEN_FILE   CTM_GRID (function)
;
; REQUIREMENTS:
;        Requires routines from both GAMAP and TOOLS packages.
;
; NOTES:
;        None
;
; EXAMPLE:
;        TEST_DAO, CTM_TYPE( 'GEOS3', res=2 ), FILE='20010115.i6.2x25'
;
;             ; Prints out information from the 2 x 2.5
;             ; GEOS-3 I-6 met field file for 2001/01/15. 
;
; MODIFICATION HISTORY:
;        bmy, 13 Jun 2002: TOOLS VERSION 1.51
;        bmy, 17 Jan 2003: TOOLS VERSION 1.52
;                          - now make NESTED a 2-element array which
;                            passes the size of a nested CTM grid
;        bmy, 09 Apr 2003: TOOLS VERSION 1.53
;                          - added XRANGE, YRANGE, /PLOTLEVEL keywords
;                          - removed /NESTED keyword
;        bmy, 13 Jun 2003: - added title string to plot
;                          - now allow user to quit
;                          - added more fields for fvDAS
;
;-
; Copyright (C) 2002-2003, Bob Yantosca, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author.
; Bugs and comments should be directed to bmy@io.harvard.edu
; with subject "IDL routine test_dao"
;-----------------------------------------------------------------------


pro Test_DAO, ModelInfo, $
              FileName=FileName,     Verbose=Verbose,       $
              XRange=XRange,         YRange=YRange,         $
              PlotLevel=PlotLevel,   _EXTRA=e
      
   ;=====================================================================
   ; External functions and Keyword settings
   ;=====================================================================
   FORWARD_FUNCTION CTM_Grid
   
   if ( N_Elements( ModelInfo  ) ne 1 ) then Message, 'MODELINFO not passed!'
   if ( N_Elements( XRange     ) eq 0 ) then XRange     = [-180,180]
   if ( N_Elements( YRange     ) eq 0 ) then YRange     = [ -90, 90]

   ;=====================================================================
   ; Define variables
   ;=====================================================================

   ; Grid type
   GridInfo = CTM_Grid( ModelInfo )

   ; Number of levels
   NL = GridInfo.LMX

   ; Longitude dimension and longitude centers
   if ( N_Elements( XRange ) gt 0 ) then begin
      IndX = Where( GridInfo.XMid ge XRange[0] AND $
                    GridInfo.XMid le XRange[1], NI )
      XMid = GridInfo.XMid[IndX]
   endif else begin
      NI   = GridInfo.IMX
      XMid = GridInfo.XMid
   endelse

   ; Latitude dimension and latitude centers
   if ( N_Elements( YRange ) gt 0 ) then begin
      IndY = Where( GridInfo.YMid ge YRange[0] AND $
                    GridInfo.YMid le YRange[1], NJ )
      YMid = GridInfo.YMid[IndY]
   endif else begin
      NJ   = GridInfo.JMX
      YMid = GridInfo.Ymid
   endelse
 
   ; GEOS-1 and GEOS-STRAT have REAL*4  date/time variables
   ; GEOS-3 and GEOS-4     have INTEGER date/time variables 
   if ( ModelInfo.Name eq 'GEOS1'        OR $
        ModelInfo.Name eq 'GEOS_STRAT' ) then begin
      XYMD = 0.0              
      XHMS = 0.0              
   endif else begin
      XYMD = 0L
      XHMS = 0L
   endelse

   ;=====================================================================
   ; Open file
   ;=====================================================================
   Open_File, FileName, Ilun, /Get_Lun,                 $
      /F77_Unformatted, FileName=ThisFileName,          $
      Title='Select a DAO met field file (CANCEL quits!)', $
      _EXTRA=e
 
   if ( ThisFileName eq '' ) then return
   
   ;=====================================================================
   ; Loop thru file, read data, print times, name, max & min
   ;=====================================================================
   while ( not EOF( Ilun ) ) do begin
 
      ; NAME is an 8 character string
      Name = '12345678'
 
      ; Read the name
      ReadU, Ilun, Name
      StrName = StrUpCase( StrCompress( Name, /Remove_all ) )
 
      if ( Keyword_Set( Verbose ) ) $
         then print,'Read Label : ',StrName
      
      ; Size the data array for either 2-D or 3-D fields
      case ( StrName ) of
 
         ; 2-D fields
         'ALBD'      : Data = FltArr( NI, NJ     )
         'ALBEDO'    : Data = FltArr( NI, NJ     )
         'CLDFRC'    : Data = FltArr( NI, NJ     )
         'EVAP'      : Data = FltArr( NI, NJ     )
         'GWET'      : Data = FltArr( NI, NJ     )
         'GWETTOP'   : Data = FltArr( NI, NJ     )
         'HFLUX'     : Data = FltArr( NI, NJ     )
         'LAI'       : Data = FltArr( NI, NJ     ) 
         'LWI'       : Data = FltArr( NI, NJ     )
         'PARDF'     : Data = FltArr( NI, NJ     )
         'PARDR'     : Data = FltArr( NI, NJ     )
         'PBL'       : Data = FltArr( NI, NJ     )
         'PBLH'      : Data = FltArr( NI, NJ     )
         'PS'        : Data = FltArr( NI, NJ     )
         'PHIS'      : Data = FltArr( NI, NJ     )
         'PREACC'    : Data = FltArr( NI, NJ     )
         'PRECON'    : Data = FltArr( NI, NJ     )
         'RADLWG'    : Data = FltArr( NI, NJ     )
         'RADSWG'    : Data = FltArr( NI, NJ     )
         'RADSWT'    : Data = FltArr( NI, NJ     )
         'SLP'       : Data = FltArr( NI, NJ     )
         'SNOW'      : Data = FltArr( NI, NJ     )
         'SURFTYPE'  : Data = FltArr( NI, NJ     )
         'TROPP'     : Data = FltArr( NI, NJ     )
         'T2M'       : Data = FltArr( NI, NJ     )
         'TGROUND'   : Data = FltArr( NI, NJ     )
         'TS'        : Data = FltArr( NI, NJ     )
         'TSKIN'     : Data = FltArr( NI, NJ     )
         'U10M'      : Data = FltArr( NI, NJ     )
         'USTAR'     : Data = FltArr( NI, NJ     )
         'V10M'      : Data = FltArr( NI, NJ     )
         'Z0'        : Data = FltArr( NI, NJ     )
         'Z0M'       : Data = FltArr( NI, NJ     )
 
         ; 3-D fields
         'CLDMAS'    : Data = FltArr( NI, NJ, NL )
         'CLDTOT'    : Data = FltArr( NI, NJ, NL )
         'CLMOLW'    : Data = FltArr( NI, NJ, NL )
         'CLROLW'    : Data = FltArr( NI, NJ, NL )
         'CMFDTR'    : Data = FltArr( NI, NJ, NL )
         'CMFETR'    : Data = FltArr( NI, NJ, NL )
         'DELP'      : Data = FltArr( NI, NJ, NL )
         'DTRAIN'    : Data = FltArr( NI, NJ, NL )
         'HKBETA'    : Data = FltArr( NI, NJ, NL )
         'HKETA'     : Data = FltArr( NI, NJ, NL )
         'KZZ'       : Data = FltArr( NI, NJ, NL )
         'MOISTQ'    : Data = FltArr( NI, NJ, NL )
         'OPTDEPTH'  : Data = FltArr( NI, NJ, NL )
         'Q'         : Data = FltArr( NI, NJ, NL )
         'TAUCLD'    : Data = FltArr( NI, NJ, NL )
         'T'         : Data = FltArr( NI, NJ, NL )
         'TMPU'      : Data = FltArr( NI, NJ, NL )
         'SPHU'      : Data = FltArr( NI, NJ, NL )
         'U'         : Data = FltArr( NI, NJ, NL )
         'UWND'      : Data = FltArr( NI, NJ, NL )
         'V'         : Data = FltArr( NI, NJ, NL )
         'VWND'      : Data = FltArr( NI, NJ, NL )
         'ZMEU'      : Data = FltArr( NI, NJ, NL )
         'ZMMD'      : Data = FltArr( NI, NJ, NL )
         'ZMMU'      : Data = FltArr( NI, NJ, NL ) 

      endcase
  
      ; Read the data!!!
      ReadU, Ilun, XYMD, XHMS, Data
      print, xymd, xhms, Name, min( Data, Max=M ), M, $
         Format='( i8,1x,i6.6,1x,a8,1x,2f13.6)'
 
      ; Test for NAN
      Ind = Where( not Float( Finite( Data ) ) )
      if ( Ind[0] ge 0 ) then print, 'Non-finite data values found!'
      
      ;=================================================================
      ; If PLOTLEVEL is specified, then plot the given level
      ;=================================================================
      if ( N_Elements( PlotLevel ) gt 0 ) then begin

         ; Make sure PLOTLEVEL is in the right range
         PlotLevel = ( PlotLevel > 1 ) < NL 
         
         ; Make a title for the plot
         Title = StrName                                 + ' '   + $
                 String( Long( XYMD ), Format='(i8.8)' ) + ' '   + $
                 String( Long( XHMS ), Format='(i6.6)' ) + ' L=' + $
                 StrTrim( String( PlotLevel, Format='(i3)' ), 2 )

         ; Plot the data
         case ( Size( Data, /N_Dim ) ) of

            ; 2-D data
            2: TvMap, Data, XMid, YMid, /CBar, Title=Title, $
                  /Sample, /Countries, /Coasts, /Grid, /Iso, Div=4
      
            ; 3-D data
            3: TvMap, Data[*,*,PlotLevel-1L], XMid, YMid, Title=Title, $
                  /CBar, /Sample, /Countries, /Coasts, /Grid, /Iso, Div=4
            
            ; Error check
            else: Message, 'Invalid plot level'
         endcase

         ; Pause to allow user time to view the plot or quit
         Input = ''
         Read, 'Hit RETURN to continue, Q=QUIT > ', Input
         if ( StrUpCase( StrTrim( Input, 2 ) ) eq 'Q' ) then goto, Quit

      endif

      ; Delete data
      UnDefine, Data
 
   endwhile
 
   ;=====================================================================
   ; Close file and quit
   ;=====================================================================
Quit:
   Close, Ilun
   Free_LUN, Ilun
 
   return
end
 
