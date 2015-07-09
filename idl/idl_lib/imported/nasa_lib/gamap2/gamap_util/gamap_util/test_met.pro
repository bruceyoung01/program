; $Id: test_met.pro,v 1.5 2008/02/28 19:41:08 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        TEST_MET
;
; PURPOSE:
;        Prints out the name, time, and min/max of data of GMAO or
;        GISS/GCAP met data files which are used as input to GEOS-Chem.
;
; CATEGORY:
;        GAMAP Utilities
;
; CALLING SEQUENCE:
;        TEST_MET, MODELINFO [, Keywords ]
;
; INPUTS:
;        MODELINFO -> Structure from CTM_TYPE which defines the model
;             name, resolution, and other parameters.  NOTE: If the 
;             met field files contain an IDENT string then TEST_MET
;             will ignore the MODELINFO structure passed and instead
;             will parse the IDENT string to obtain the model name
;             and resolution.  (NOTE: GEOS-4, GEOS-5, and GCAP met
;             fields contain an identification string which is read in
;             to determine the proper model name.  For these met fields
;             you won't need to supply MODELINFO.)
;
; KEYWORD PARAMETERS:
;        FILENAME -> Name of the binary met field file to examine.  If 
;             FILENAME is not passed, then the user will be prompted
;             to supply a file name via a dialog box query.
;
;        /VERBOSE -> If set, then will echo extra information
;             to the screen.
;
;        XINDEX -> A 2-element vector containing the minimum and
;             maximum longitude indices (in FORTRAN notation) which 
;             define the nested model grid.
;
;        YINDEX -> A 2-element vector containing the minimum and
;             maximum longitude indices (in FORTRAN notation) which 
;             define the nested model grid.
;
;        XRANGE -> A 2-element vector containing the minimum and
;             maximum box center longitudes which define the nested
;             model grid. Default is [-180,180].
;
;        YRANGE -> A 2-element vector containing the minimum and
;             maximum box center latitudes which define the nested
;             model grid. Default is [-90,90].
;
;        PLOTLEVEL -> If specified, then TEST_MET will plot a lon-lat
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
;        None
;
; NOTES:
;        None
;
; EXAMPLE:
;        TEST_MET, CTM_TYPE( 'GEOS3', res=2 ), FILE='20010115.i6.2x25'
;
;             ; Prints out information from the 2 x 2.5
;             ; GEOS-3 I-6 met field file for 2001/01/15. 
;
; MODIFICATION HISTORY:
;        bmy, 24 May 2005: GAMAP VERSION 2.04
;                          - now renamed from "test_dao.pro"
;                          - added fields for GISS/GCAP model
;                          - now looks for an IDENT string 
;        bmy, 12 Dec 2006: GAMAP VERSION 2.06
;                          - Modifications for GEOS-5 met fields
;                          - Added XINDEX, YINDEX keywords
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
;                          - Added extra GEOS-5 fields
;        bmy, 21 Feb 2008: GAMAP VERSION 2.12
;                          - Now be sure to swap the endian when 
;                            opening the file on little-endian 
;                            machines
;
;-
; Copyright (C) 2005-2007,
; Bob Yantosca and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of 
; this software. If this software shall be used commercially or 
; sold as part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.harvard.edu with subject "IDL routine test_met"
;-----------------------------------------------------------------------


pro Test_Met, ModelInfo, $
              FileName=FileName,     Verbose=Verbose,       $
              XIndex=XIndex,         YIndex=YIndex,         $
              XRange=XRange,         YRange=YRange,         $
              PlotLevel=PlotLevel,   Zonal=Zonal,           $
              China=China,           NAmerica=NAmerica,     $
              ExpFormat=ExpFormat,    _EXTRA=e
      
   ;=====================================================================
   ; Initialization
   ;=====================================================================

   ; External function
   FORWARD_FUNCTION CTM_Grid, CTM_Type, Little_Endian
   
   ; Keywords
   Verbose = Keyword_Set( Verbose )
   if ( N_Elements( XRange ) eq 0 ) then XRange = [-180,180]
   if ( N_Elements( YRange ) eq 0 ) then YRange = [ -90, 90]

   ; Define the format string - default is floating point
   if ( Keyword_Set( ExpFormat ) )                   $
      then PrtFormat='( i8,1x,i6.6,1x,a8,1x,2e15.6)' $
      else PrtFormat='( i8,1x,i6.6,1x,a8,1x,2f15.6)'

   ; For China nested grid
   if ( Keyword_Set( China ) ) then begin
      XRange = [  70, 150 ]
      YRange = [ -11,  55 ]
   endif

   ; For N. America nested grid
   if ( Keyword_Set( NAmerica ) ) then begin
      XRange = [ -140, -40 ]
      YRange = [   10,  60 ]
   endif

   ; Variables
   Ident = '12345678'
   Name  = '12345678'

   ;=====================================================================
   ; Open file and check for IDENT string
   ;=====================================================================

   ; Open file (prompt user if FILENAME is not passed)
   Open_File, FileName, Ilun, /Get_Lun, /F77, FileName=ThisFileName,  $
      Title='Select a met field file (CANCEL quits!)', _EXTRA=e,      $
      Swap_Endian=Little_Endian()
 
   ; Return if file not found
   if ( ThisFileName eq '' ) then return

   ; Read the 1st 8 bytes of the file
   ReadU, Ilun, Ident
      
   ; Echo info if /VERBOSE is set
   if ( Verbose ) then print, 'Ident string: ', Ident

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

   endif else begin

      ;-----------------
      ; All other grids
      ;-----------------

      ; Make sure MODELINFO is passed via the arg list
      if ( not ChkStru( ModelInfo, ['NAME','RESOLUTION'] ) ) $
         then Message, 'Invalid MODELINFO structure!'

      ; Copy MODELINFO to INTYPE
      InType = ModelInfo

      ; Place file pointer at top of file
      Point_LUN, Ilun, 0L

   endelse

   ;=====================================================================
   ; Define grid parameters
   ;=====================================================================

   ; Grid type
   InGrid = CTM_Grid( InType )

   ; Number of levels
   NL = InGrid.LMX

   ;-------------------------------------------
   ; Longitude dimension and longitude centers
   ;-------------------------------------------
   if ( N_Elements( XIndex ) gt 0   AND $
        N_Elements( XIndex ) le 2 ) then begin

      ; Longitude indices are passed
      if ( N_Elements( XIndex ) eq 1 )                          $
         then XMid = InGrid.XMid[ XIndex[0]-1L                ] $
         else XMid = InGrid.XMid[ XIndex[0]-1L : XIndex[1]-1L ] 
        
      NI   = N_Elements( XMid )

   endif else if ( N_Elements( XRange ) gt 0 ) then begin

      ; Longitude values are passed
      IndX = Where( InGrid.XMid ge XRange[0] AND $
                    InGrid.XMid le XRange[1], NI )
      XMid = InGrid.XMid[IndX]

   endif else begin

      ; Use global longitudes
      NI   = InGrid.IMX
      XMid = InGrid.XMid

   endelse

   ;-------------------------------------------
   ; Latitude dimension and latitude centers
   ;-------------------------------------------
   if ( N_Elements( YIndex ) gt 0   AND $
        N_Elements( YIndex ) le 2 ) then begin

      ; Latitude indices are passed
      if ( N_Elements( YIndex ) eq 1 )                          $
         then YMid = InGrid.YMid[ YIndex[0]-1L                ] $
         else YMid = InGrid.YMid[ YIndex[0]-1L : YIndex[1]-1L ] 
        
      NJ   = N_Elements( YMid )

   endif else if ( N_Elements( YRange ) gt 0 ) then begin

      ; Latitude values are passed
      IndY = Where( InGrid.YMid ge YRange[0] AND $
                    InGrid.YMid le YRange[1], NJ )
      YMid = InGrid.YMid[IndY]

   endif else begin

      ; Use global latitudes
      NJ   = InGrid.JMX
      YMid = InGrid.Ymid

   endelse

   ; GEOS-1 and GEOS-STRAT have REAL*4  date/time variables
   ; GEOS-3 and GEOS-4     have INTEGER date/time variables 
   if ( InType.Name eq 'GEOS1'        OR $
        InType.Name eq 'GEOS_STRAT' ) then begin
      XYMD = 0.0              
      XHMS = 0.0              
   endif else begin
      XYMD = 0L
      XHMS = 0L
   endelse
   
   ; Set a flag if it's GEOS-5 (bmy, 12/12/06)
   ItsGeos5 = ( InType.Name eq 'GEOS5' )
   ;NG5      = 45L
   NG5 = 72L

   ;=====================================================================
   ; Loop thru file, read data, print times, name, max & min
   ;=====================================================================

   ; Read data from file
   while ( not EOF( Ilun ) ) do begin
  
      ; Read the name
      ReadU, Ilun, Name
      StrName = StrUpCase( StrCompress( Name, /Remove_all ) )
 
      ; Echo info if /VERBOSE is set
      if ( Verbose ) then print,'Read Label : ',StrName
      
      ; Size the data array for either 2-D or 3-D fields
      case ( StrName ) of
 
         ; 2-D fields (add more as necessary)
         'ALBD'      : Data = FltArr( NI, NJ     )
         'ALBEDO'    : Data = FltArr( NI, NJ     )
         'CLDFRC'    : Data = FltArr( NI, NJ     )
         'EVAP'      : Data = FltArr( NI, NJ     )
         'GRN'       : Data = FltArr( NI, NJ     )
         'GWET'      : Data = FltArr( NI, NJ     )
         'GWETROOT'  : Data = FltArr( NI, NJ     )
         'GWETTOP'   : Data = FltArr( NI, NJ     )
         'HFLUX'     : Data = FltArr( NI, NJ     )
         'LAI'       : Data = FltArr( NI, NJ     ) 
         'LWGNET'    : Data = FltArr( NI, NJ     )
         'LWI'       : Data = FltArr( NI, NJ     )
         'MOLENGTH'  : Data = FltArr( NI, NJ     )
         'OICE'      : Data = FltArr( NI, NJ     )
         'PARDF'     : Data = FltArr( NI, NJ     )
         'PARDIF'    : Data = FltArr( NI, NJ     )
         'PARDR'     : Data = FltArr( NI, NJ     )
         'PARDIR'    : Data = FltArr( NI, NJ     )
         'PBL'       : Data = FltArr( NI, NJ     )
         'PBLH'      : Data = FltArr( NI, NJ     )
         'PS'        : Data = FltArr( NI, NJ     )
         'PHIS'      : Data = FltArr( NI, NJ     )
         'PREACC'    : Data = FltArr( NI, NJ     )
         'PRECON'    : Data = FltArr( NI, NJ     )
         'PRECCON'   : Data = FltArr( NI, NJ     )
         'PRECSNO'   : Data = FltArr( NI, NJ     )
         'PRECTOT'   : Data = FltArr( NI, NJ     )
         'RADLWG'    : Data = FltArr( NI, NJ     )
         'RADSWG'    : Data = FltArr( NI, NJ     )
         'RADSWT'    : Data = FltArr( NI, NJ     )
         'SLP'       : Data = FltArr( NI, NJ     )
         'SNICE'     : Data = FltArr( NI, NJ     )
         'SNODP'     : Data = FltArr( NI, NJ     )
         'SNOMAS'    : Data = FltArr( NI, NJ     )
         'SNOW'      : Data = FltArr( NI, NJ     )
         'SNOWD'     : Data = FltArr( NI, NJ     )
         'SOIL'      : Data = FltArr( NI, NJ     )
         'SURFTYPE'  : Data = FltArr( NI, NJ     )
         'SWGNET'    : Data = FltArr( NI, NJ     )
         'TROPP'     : Data = FltArr( NI, NJ     )
         'T2M'       : Data = FltArr( NI, NJ     )
         'TGROUND'   : Data = FltArr( NI, NJ     )
         'TO3'       : Data = FltArr( NI, NJ     )
         'TS'        : Data = FltArr( NI, NJ     )
         'TTO3'      : Data = FltArr( NI, NJ     )
         'TSKIN'     : Data = FltArr( NI, NJ     )
         'U10M'      : Data = FltArr( NI, NJ     )
         'USTAR'     : Data = FltArr( NI, NJ     )
         'USS'       : Data = FltArr( NI, NJ     )
         'V10M'      : Data = FltArr( NI, NJ     )
         'VSS'       : Data = FltArr( NI, NJ     )
         'Z0'        : Data = FltArr( NI, NJ     )
         'Z0M'       : Data = FltArr( NI, NJ     )
 
         ; 3-D fields (add more as necessary)
         'CLDF'      : Data = FltArr( NI, NJ, NL    ) 
         'CLDMAS'    : Data = FltArr( NI, NJ, NL    )
         'CLMOLW'    : Data = FltArr( NI, NJ, NL    )
         'CLROLW'    : Data = FltArr( NI, NJ, NL    )
         'CMFDTR'    : Data = FltArr( NI, NJ, NL    )
         'CMFETR'    : Data = FltArr( NI, NJ, NL    )
         'CMFMC'     : Data = FltArr( NI, NJ, NL+1L )
         'DELP'      : Data = FltArr( NI, NJ, NL    )
         'DETRAINE'  : Data = FltArr( NI, NJ, NL    )
         'DETRAINN'  : Data = FltArr( NI, NJ, NL    )
         'DNDE'      : Data = FltArr( NI, NJ, NL    )
         'DNDN'      : Data = FltArr( NI, NJ, NL    )
         'ENTRAIN'   : Data = FltArr( NI, NJ, NL    )
         'HKBETA'    : Data = FltArr( NI, NJ, NL    )
         'HKETA'     : Data = FltArr( NI, NJ, NL    )
         'KZZ'       : Data = FltArr( NI, NJ, NL    )
         'MFXC'      : Data = FltArr( NI, NJ, NL    )
         'MFYC'      : Data = FltArr( NI, NJ, NL    )
         'MFZ'       : Data = FltArr( NI, NJ, NL+1L )
         'PL'        : Data = FltArr( NI, NJ, NL    )
         'PLE'       : Data = FltArr( NI, NJ, NL+1L )
         'PV'        : Data = FltArr( NI, NJ, NL    )
         'Q'         : Data = FltArr( NI, NJ, NL    )
         'QI'        : Data = FltArr( NI, NJ, NL    )
         'QL'        : Data = FltArr( NI, NJ, NL    )
         'QV'        : Data = FltArr( NI, NJ, NL    )
         'RH'        : Data = FltArr( NI, NJ, NL    )
         'TAUCLD'    : Data = FltArr( NI, NJ, NL    )
         'T'         : Data = FltArr( NI, NJ, NL    )
         'TMPU'      : Data = FltArr( NI, NJ, NL    )
         'SPHU'      : Data = FltArr( NI, NJ, NL    )
         'U'         : Data = FltArr( NI, NJ, NL    )
         'UPDE'      : Data = FltArr( NI, NJ, NL    )
         'UPDN'      : Data = FltArr( NI, NJ, NL    )
         'UWND'      : Data = FltArr( NI, NJ, NL    )
         'V'         : Data = FltArr( NI, NJ, NL    )
         'VWND'      : Data = FltArr( NI, NJ, NL    )
         'ZMEU'      : Data = FltArr( NI, NJ, NL    )
         'ZMMD'      : Data = FltArr( NI, NJ, NL    )
         'ZMMU'      : Data = FltArr( NI, NJ, NL    ) 

         ;--------------------------------------------------------------
         ; Special handling for certain GEOS-5 fields
         ;--------------------------------------------------------------

         ; These GEOS-5 fields are saved up to the L_CLD_MAX
         'CLOUD'     : Data = FltArr( NI, NJ, NG5 )
         'DQIDTMST'  : Data = FltArr( NI, NJ, NG5 )
         'DQLDTMST'  : Data = FltArr( NI, NJ, NG5 )
         'DQRCON'    : Data = FltArr( NI, NJ, NG5 ) 
         'DQRLSC'    : Data = FltArr( NI, NJ, NG5 )
         'DQVDTMST'  : Data = FltArr( NI, NJ, NG5 )

         ; NOTE: GEOS-5 "CLDTOT" is a 2-D field, but in GEOS-3 
         ; and GEOS-4 it's a 3-D field (bmy, 11/20/06)
         'CLDTOT'    : begin
                          if ( ItsGeos5 )                       $
                             then Data = FltArr( NI, NJ      )  $
                             else Data = FltArr( NI, NJ, NL  ) 
                       end
   
         'DTRAIN'    : begin
                          if ( ItsGeos5 )                       $
                             then Data = FltArr( NI, NJ, NG5 )  $
                             else Data = FltArr( NI, NJ, NL  ) 
                       end

         'MOISTQ'    : begin
                          if ( ItsGeos5 )                       $
                             then Data = FltArr( NI, NJ, NG5 )  $
                             else Data = FltArr( NI, NJ, NL  ) 
                       end

         'OPTDEPTH'  : begin
                          if ( ItsGeos5 )                       $
                             then Data = FltArr( NI, NJ, NG5 )  $
                             else Data = FltArr( NI, NJ, NL  ) 
                       end

         'TAUCLI'    : begin
                          if ( ItsGeos5 )                       $
                             then Data = FltArr( NI, NJ, NG5 )  $
                             else Data = FltArr( NI, NJ, NL  ) 
                       end

         'TAUCLW'    : begin
                          if ( ItsGeos5 )                       $
                             then Data = FltArr( NI, NJ, NG5 )  $
                             else Data = FltArr( NI, NJ, NL  ) 
                       end
      endcase
  
      ; Size of data
      S_Data = Size( Data, /Dim   )
      N_Dims = Size( Data, /N_Dim )

      ; Read the data!
      ReadU, Ilun, XYMD, XHMS, Data
      Print, XYMD, XHMS, Name, Min( Data, Max=M ), M, Format=PrtFormat

      ; Test for NAN
      Ind = Where( not Float( Finite( Data ) ) )
      if ( Ind[0] ge 0 ) then print, 'Non-finite data values found!'
  
      ;### Debug
      ;if ( Ind[0] ge 0 ) then begin
      ;   print, 'Non-finite data values found!'
      ;   for N=0L, N_Elements( Ind )-1L do begin
      ;      Ind2 = Convert_Index( Ind[N], [NI, NJ, NL], /Fortran )
      ;      print, Reform( Ind2 ), Data[ Ind[N] ]
      ;   endfor
      ;endif

      ;### Debug
      ;if ( StrName eq 'PLE' ) then begin
      ;   print, Format='(6(f9.4,1x))', data[1-1,1-1,*]
      ;   print, '---'
      ;   print, Format='(6(f9.4,1x))', data[36-1,23-1,*]
      ;   print, '---'
      ;   print, Format='(6(f9.4,1x))', data[23-1,34-1,*]
      ;   print, '---'
      ;endif
             
      ;if ( StrName eq 'PS' ) then begin
      ;   print, Format='(6(f9.4,1x))', data[23-1,34-1]
      ;endif

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
         case ( N_Dims ) of

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
         Pause

      endif

      ;=================================================================
      ; If ZONAL is specified, then plot the given level
      ;=================================================================
      if ( Keyword_Set( Zonal ) and N_Dims eq 3 ) then begin

         ; Make a title for the plot
         Title = StrName                                 + ' '   + $
                 String( Long( XYMD ), Format='(i8.8)' ) + ' '   + $
                 String( Long( XHMS ), Format='(i6.6)' ) + ' Zonal mean'

         ; Zonal mean
         TmpData = Total( Data, 1 ) / Float( S_Data[0] )

         ; Vertical coordinate (some fields have NL+1)
         case ( StrName ) of
            'CMFMC' : Zmid = InGrid.ZEdge[0:S_Data[2]-1]
            'MFZ'   : Zmid = InGrid.ZEdge[0:S_Data[2]-1]
            'PLE'   : Zmid = InGrid.ZEdge[0:S_Data[2]-1]
            else    : Zmid = InGrid.ZMid[0:S_Data[2]-1]
         endcase

         ; Make the plot
         TvPlot, TmpData, YMid, ZMid, Title=Title, $
            /CBar, /Sample, /Countries, /Coasts, /Grid, /Iso, Div=4
         
         ; Pause to allow user time to view the plot or quit
         Pause

         ; Undefine stuff
         UnDefine, TmpData
         UnDefine, ZMid

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
 
