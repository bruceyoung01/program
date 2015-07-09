; $Id: regridh_aircraft_fuel.pro,v 1.2 2008/04/02 15:19:04 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        REGRIDH_AIRCRAFT_FUEL
;
; PURPOSE:
;        Regrids aircraft  emissions to GEOS-CHEM grid resolution.
;        Can also trim to nested-grid resolution if necessary.
;
; CATEGORY:
;        Regridding
;
; CALLING SEQUENCE:
;        REGRIDH_AIRCRAFT_FUEL [, Keywords ]
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
;        OUTMODELNAME -> A string containing the name of the model 
;             grid onto which the NOx emissions will be regridded.
;             Default is 'GEOS3'.
;
;        OUTRESOLUTION -> Specifies the resolution of the model grid
;             onto which the NOX emissions will be regridded.  
;             OUTRESOLUTION can be either a 2 element vector with 
;             [ DI, DJ ] or a scalar (DJxDI: 8=8x10, 4=4x5, 2=2x2.5, 
;             1=1x1, 0.5=0.5x0.5).  Default is 1.
;
;        XRANGE -> A 2-element vector containing the minimum and
;             maximum box center longitudes which define the nested
;             model grid. Default is [-180,180].
;
;        YRANGE -> A 2-element vector containing the minimum and
;             maximum box center latitudes which define the nested
;             model grid. Default is [-180,180].
;
;        /USE_SAVED_WEIGHTS -> Set this flag to tell CTM_REGRIDH to
;             use previously-saved mapping weights.  Useful if you
;             are regridding many files at once.  
;
; OUTPUTS:
;        None
;
; SUBROUTINES:
;        External Subroutines Required:
;        ================================================
;        CTM_TYPE    (function)   CTM_GRID (function)
;        CTM_REGRIDH (function)   OPEN_FILE
;
; REQUIREMENTS:
;        References routines from both GAMAP and TOOLS packages
;
; NOTES:
;
; EXAMPLE:
;        REGRIDH_AIRCRAFT_FUEL, INFILENAME='total_1992_apr.kg_day.3d', $
;                               OUTFILENAME='airapr.1x1',              $
;                               OUTMODELNAME='GEOS3',                  $
;                               OUTRESOLUTION=1,                       $
;                               XRange=[-140,40],                      $
;                               YRange=[10,60] 
;
;             ; Regrids aircraft fuel emissions to a GEOS-3 1x1
;             ; nested grid resolution given by 
;
; MODIFICATION HISTORY:
;        bmy, 10 Apr 2003: VERSION 1.00
;        bmy, 29 Nov 2006: VERSION 1.01
;                          - Updated for SO2 output
;
;-
; Copyright (C) 2003-2006 Bob Yantosca, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author.
; Bugs and comments should be directed to bmy@io.harvard.edu
; with subject "IDL routine regridh_aircraft_fuel"
;-----------------------------------------------------------------------


function RF_Read_AirFuel, GridInfo, FileName

   ;====================================================================
   ; Internal function RF_READ_AIRFUEL reads the aircraft fuel data on
   ; its original grid from disk.  Units are kg/day. (bmy, 4/10/03)
   ;
   ; Data File Format
   ; =================
   ; The format for the emissions scenarios data files is:
   ;
   ; line 1:  text information
   ;
   ; Succeeding lines contain data in the format:
   ;
   ; lat lon alt fuel NOx HC CO
   ;
   ;   where
   ;   
   ;    lat   is the latitude in the band from i to i + 1
   ;          and values run from -90 to 90, where -90 corresponds to 
   ;          90S-89S  and 89 corresponds to 89N-90N.
   ; 
   ;    lon   is the longitude in the band from j to j+1
   ;          and values run from -180 to 180, where -180 corresponds to
   ;          180W-179W and 179 corresponds to 179E-180E
   ;
   ;    alt   is the pressure altitude in the band from k to k+1
   ;          and values run from 0 to 25.  Altitude is geopotential
   ;          height and corresponds to pressures using the 1976 U.S.
   ;          Standard Atmosphere.  These values are:
   ;
   ;
   ;                Alt(km)   Pressure (mb)
   ;
   ;                0           1013.25
   ;                1           898.74
   ;                2           794.95
   ;                3           701.08
   ;                4           616.40
   ;                5           540.19
   ;                6           471.81
   ;                7           410.60
   ;                8           355.99
   ;                9           307.42
   ;                10          264.36
   ;                11          226.32
   ;                12          193.30
   ;                13          165.10
   ;                14          141.01
   ;                15          120.44
   ;                16          102.87
   ;                17          87.866
   ;                18          75.048
   ;                19          64.1
   ;                20          54.748
   ;                21          46.778
   ;                22          39.997
   ;                23          34.224
   ;                24          29.304
   ;                25          25.110
   ;====================================================================

   ; Define data array -- 1 x 1 x 1 km grid
   Data = DblArr( GridInfo.IMX, GridInfo.JMX, 26 )
   
   ; Open file
   Open_File, FileName, Ilun, /Get_LUN
   
   Line  = ''
   I     = 0L
   J     = 0L
   L     = 0L
   Value = 0D

   ; echo info
   S = 'Reading ' + StrTrim( FileName, 2 ) + ' ...'
   Message, S, /Info

   ; Read header line
   ReadF, Ilun, Line

   ; Read data lines
   ; I, J, L are first 3 values, NOx is the 5th value
   while ( not EOF( Ilun ) ) do begin

      ; Read each line
      ReadF, Ilun, Line
      
      ; Break the line up
      Result = StrBreak( Line, ' ' )

      ; Indices in IDL notation
      J = Long( Result[0] ) +  90 
      I = Long( Result[1] ) + 180
      L = Long( Result[2] )  

      ; Assign into DATA array, 
      ; I, J are in FORTRAN indices, convert to IDL indices
      Data[I,J,L] = Double( Result[3] )

   endwhile
   
   ; Close file
   Close, Ilun
   Free_LUN, Ilun

   ; Exit
   return, Data
end

;-----------------------------------------------------------------------------

pro RF_Write_AirFuel, Data, GridInfo, FileName

   ;====================================================================
   ; Internal function RF_WRITE_AIRFUEL writes the regridded
   ; aircraft NOx data to disk. (bmy, 4/10/03, 11/29/06)
   ;====================================================================

   ; Open the file
   Open_File, FileName, Ilun, /Get_LUN, /Write

   ; Write header file
   PrintF, Ilun, 'Total aircraft fuel combustion (kg/day) at km0 to km0+1 apr'
   PrintF, Ilun, '   i   j  km0 E(kg/day)'

   ; Only write out the nonzero data
   for L = 0L, 25L             do begin
   for J = 0L, GridInfo.JMX-1L do begin
   for I = 0L, GridInfo.IMX-1L do begin
            
      ; Only write out nonzero points
      if ( Data[I,J,L] gt 0D ) then begin
         PrintF, Ilun, I+1, J+1, L, Data[I,J,L], Format='(3i4,1x,e10.3)'
      endif
   endfor
   endfor
   endfor

   ; Close the file
   Close,    Ilun
   Free_LUN, Ilun
   
end

;-----------------------------------------------------------------------------

pro RegridH_Aircraft_Fuel, InFileName=InFileName,       $
                           OutFileName=OutFileName,     $
                           OutModelName=InModelName,    $
                           OutResolution=OutResolution, $
                           XRange=XRange, YRange=YRange, $
                           Use_Saved_Weights=Use_Saved_Weights
   
   ;====================================================================
   ; Initialization
   ;====================================================================

   ; External functions
   FORWARD_FUNCTION CTM_Grid, CTM_Type, CTM_RegridH

   ; Keywords
   if ( N_Elements( OutModelName  ) eq 0 ) then OutModelName  = 'GEOS3'
   if ( N_Elements( OutResolution ) eq 0 ) then OutResolution = 1
   Use_Saved_Weights = Keyword_Set( Use_Saved_Weights )

   ; Input Grid
   InType  = CTM_Type( 'Generic', res=[1,1], HalfPolar=0, Center180=0 )
   InGrid  = CTM_Grid( InType, /No_Vertical )
   
   ; Output Grid
   OutType = CTM_Type( OutModelName, Res=OutResolution )
   OutGrid = CTM_Grid( OutType )

   ;====================================================================
   ; Process data
   ;====================================================================

   ; Read input data array on generic 1 x 1 grid
   InData = RF_Read_AirFuel( InGrid, InFileName )
   print, Total( InData  )

   ; Regrid to GEOS 1 x 1 grid
   OutData = CTM_RegridH( InData, InGrid, OutGrid, $
                          /Double, Use_Saved_Weights=Use_Saved_Weights )

   ; Truncate and write to output file
   RF_Write_AirFuel, OutData, OutGrid, OutFileName
     
   ; Quit
   return
end
