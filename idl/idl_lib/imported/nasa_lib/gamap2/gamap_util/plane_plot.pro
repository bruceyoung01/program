; $Id: plane_plot.pro,v 1.1.1.1 2007/07/17 20:41:25 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        PLANE_PLOT
;
; PURPOSE: 
;        Plots data from the GEOS-CHEM plane following diagnostic
;        atop a world map.  Multiple flights can be plotted.
;
; CATEGORY:
;        GAMAP Utilities, GAMAP Plotting
;
; CALLING SEQUENCE:
;        PLANE_PLOT, VAR, FLTID [, Keywords ]
;
; INPUTS:
;        VAR -> Variable name for which to plot data.  VAR should
;             match the variable names in the GEOS-CHEM input file
;             "Planeflight.dat" (e.g. TRA_001, GMAO_TEMP, REA_O1D, etc.)
;           
;        FLTID -> Flight ID(s) for which to plot data.  These should
;             match the flight ID's in the GEOS-CHEM input file
;             "Planeflight.dat" (e.g. P3B01, DC801, etc.)
;
; KEYWORD PARAMETERS:
;        FILENAME -> Name of the file containing GEOS-CHEM plane 
;             following diagnostic output.  If FILENAME is omitted,
;             then a dialog box will prompt the user to supply a file
;             name.
;
;        LIMIT -> A 4-element vector with [MINLAT,MINLON,MAXLAT,MAXLON],
;             which will specify the bottom left and top right corners
;             of the map plot in degrees.  Default is to plot the 
;             entire Northern Hemisphere [0,-180,90,180].
;
;        MPARAM -> A 3 element vector which specifies the LAT0, LON0,
;             and ROT values to be passed to MAP_SET.  Default is
;             [0,0,0].
;        
;        SYMBOL -> Number of the symbol used to plot each data point.
;             SYMBOL corresponds to the types of symbols defined with
;             the routine "sym.pro" in the TOOLS package.  Default is
;             1 (filled circle).
;
;        SYMSIZE -> Size of the plot symbol.  Default is 1.5
;
;        _EXTRA=e -> Passes extra keywords to MAP_SET, MAP_GRID,
;             and MAP_CONTINENTS.
;
; OUTPUTS:
;        None
;
; SUBROUTINES:
;        External Subroutines Required:
;        =================================
;        COLORBAR
;        CTM_READ_PLANEFLIGHT (function)
;        UNDEFINE
;
; REQUIREMENTS:
;        None
;
; NOTES:
;        None
;
; EXAMPLES:
;        PLANE_PLOT, 'O3', 'P3B04',           $
;                     LIMIT=[20,-120,50,-60], $
;                     FILENAME='plane.log'
;        
;             ; Plots GEOS-CHEM O3 data (stored in "plane.log) from
;             ; the model grid boxes corresponding to flight P3BO4 
;             ; over the USA.
; 
;        PLANE_PLOT, 'O3', ['P3B04','DC801'], $
;                     LIMIT=[20,-120,50,-60], $
;                     FILENAME='plane.log'
;
;             ; Plots GEOS-CHEM O3 data (stored in "plane.log) from
;             ; the model grid boxes corresponding to flights P3BO4 
;             ; and DC801 over the USA.
;
; MODIFICATION HISTORY:
;        bmy, 23 Apr 2004: GAMAP VERSION 2.03
;        bmy, 13 Mar 2006: GAMAP VERSION 2.05
;                          - Slight modifications for new version
;                            of ctm_read_planeflight.pro
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
;
;-
; Copyright (C) 2004-2007,
; Bob Yantosca and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of 
; this software. If this software shall be used commercially or 
; sold as part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.harvard.edu with subject "IDL routine plane_plot"
;-----------------------------------------------------------------------


pro Plane_Plot, Var, FltId, $
                FileName=FileName, Limit=Limit,   $
                Symbol=Symbol,     MParam=MParam, $
                _EXTRA=e
 
   ;====================================================================
   ; Initialization
   ;====================================================================
 
   ; External functions
   FORWARD_FUNCTION CTM_Read_PlaneFlight
 
   ; Keywords
   if ( N_Elements( Var     ) eq 0 ) then Message, 'Must pass VAR!'
   if ( N_Elements( FltId   ) eq 0 ) then Message, 'Must pass FLTID!'
   if ( N_Elements( Limit   ) eq 0 ) then Limit   = [ 0, -180, 90, 0 ]
   if ( N_Elements( MParam  ) eq 0 ) then MParam  = [ 0, 0, 0 ]
   if ( N_Elements( Symbol  ) eq 0 ) then Symbol  = 1 
   if ( N_Elements( SymSize ) eq 0 ) then SymSize = 1.5

   ; Define local vars for FLTID, VAR, strip blanks, convert to upcase
   FFltId  = StrUpCase( StrTrim( FltId, 2 ) )
   VVar    = StrUpCase( StrTrim( Var,   2 ) )
 
   ;====================================================================
   ; Read data.  Locate variable and time information.
   ;====================================================================
 
   ; Read plane flight data into an array of structures
   PlaneInfo = CTM_Read_PlaneFlight( FileName )
 
   ; Get plane platform names
   PlaneType = StrTrim( PlaneInfo[*].Platform, 2 )

   ; Number of flight ID's
   N_FltId = N_Elements( FFltId )

   ; Loop over the different flight tracks
   for F = 0L, N_FltId-1L do begin

      ; Match up this flight ID with the proper entry of PLANEINFO
      IndFlt  = Where( PlaneType eq FFltId[F] )

      ; Error check INDFLT
      if ( IndFlt[0] lt 0 ) then begin
         S = 'Could not find Flight ID #: ' + FFltId[F] + '!'
         Message, S
      endif
 
      ; Locate the proper variables
      IndVar  = Where( PlaneInfo[IndFlt].VarNames eq VVar )

      ; Error check INDVAR
      if ( IndVar[0] lt 0 ) then begin
         S = 'Could not find variable name: ' + VVar + '!'
         Message, S
      endif
 
      ; Flag if the tracer is a GMAO met field or a rxn rate
      Is_GMAO  = ( StrPos( VVar, 'GMAO_' ) ge 0 )
      Is_AOD   = ( StrPos( VVar, 'AOD_'  ) ge 0 )
      Is_Rxn   = ( StrPos( VVar, 'REA_'  ) ge 0 )   
 
      ; Also get date and times
      Ind_NYMD = Uniq( PlaneInfo[IndFlt].Date, Sort( PlaneInfo[IndFlt].Date ))
      Ind_NHMS = Uniq( PlaneInfo[IndFlt].Time, Sort( PlaneInfo[IndFlt].Time ))
      NYMD     = PlaneInfo[IndFlt].Date[Ind_NYMD] 
      NHMS     = PlaneInfo[IndFlt].Time[Ind_NHMS]
 
      ;=================================================================
      ; Plot data
      ;=================================================================
      
      ; Get lon, lat & data
      Lon  = PlaneInfo[IndFlt].Lon 
      Lat  = PlaneInfo[IndFlt].Lat
      Data = PlaneInfo[IndFlt].Data[*,IndVar] 
 
      ; Convert data to ppbv if necessary
      if ( Is_GMAO + Is_Rxn + Is_AOD eq 0 ) $
         then Data = Temporary( Data ) * 1e9

      ; Append into bigger arrays
      if ( F eq 0 ) then begin
         AllLons = Lon
         AllLats = Lat
         AllData = Data
      endif else begin
         AllLons = [ AllLons, Lon  ]
         AllLats = [ AllLats, Lat  ]
         AllData = [ AllData, Data ]
      endelse
      
      ; Undefine stuff
      UnDefine, IndFlt
      UnDefine, Lon
      UnDefine, Lat
      UnDefine, Data
      UnDefine, Is_GMAO
      UnDefine, Is_AOD
      UnDefine, Is_Rxn
      
   endfor

   ; Get min & max of data
   MinData = Min( AllData, Max=MaxData )

   ; Put data from all flight tracks onto the same color scale
   AllData = BytScl( Temporary( AllData ),    $
                     Top=!MYCT.NColors-1L,    $
                     Min=MinData, Max=MaxData )  + !MYCT.Bottom

   ;====================================================================
   ; Draw map and continents
   ;====================================================================
 
   Multipanel, 1, Margin=[0.05, 0.1, 0.05, 0.1], Position=P, _EXTRA=e

   ; Draw the map
   Map_Set, MParam[0], MParam[1], MParam[2],  $
           /Cylindrical,  Color=!MYCT.Black,  $
           Limit=Limit,   XMargin=[3, 3],     $
           /Isotropic,    _EXTRA=e, $
           Position=P
 
   ; Draw gray continents w/ black outline
   Map_Continents, Fill=1, Color=!MYCT.Gray50
   Map_Continents, /Countries, /Coasts, /USA, Color=!MYCT.Black, _EXTRA=e
 
   ; Add gridlines every 10 degrees
   Map_Grid, LonDel=10, LatDel=10, Color=!MYCT.Black, /Box_Axes, _EXTRA=e

   ;====================================================================
   ; Print map title and colorbar
   ;====================================================================
   
   ; Plot flight points as colored symbols
   for T = 0L, N_Elements( AllLons )-1L do begin
      PlotS, AllLons[T], AllLats[T], $
         Psym=Sym( Symbol ), SymSize=SymSize, Color=AllData[T]
   endfor
 
   ; Make Flight ID string
   Fstr = ''
   for F=0L, N_FltID-1L do begin
      FStr = FStr + FFltId[F] + ' ' 
   endfor
   FStr = StrTrim( FStr, 2 )
   
   ; Make date string
   DateStr = String( PlaneInfo[0].Date[0], Format='(i8.8)' )

   ; Title string
   if ( N_FltId gt 1 )                                                   $ 
      then Title = VVar + ' for flights ' + FStr + ' on date ' + DateStr $
      else Title = VVar + ' for flight '  + FStr + ' on date ' + DateStr
 
   ; Print map title
   Xp    = ( !X.WINDOW[1] + !X.WINDOW[0] ) / 2.0
   Yp    = !Y.WINDOW[1] + 0.05
   XyOutS, Xp, Yp, Title, Color=!MYCT.BLACK, /Normal, Align=0.5, Charsize=1.5

   ; Get proper unit string
   case ( VVar ) of 
      'REA_O1D'   : Unit = '[1/s]'
      'REA_299'   : Unit = '[1/s]'        ;??
      'REA_'      : Unit = '[molec/cm3]'  ;??
      'GMAO_TEMP' : Unit = '[K]'
      'GMAO_UWND' : Unit = '[m/s]'
      'GMAO_VWND' : Unit = '[m/s]'
      'GMAO_PSFC' : Unit = '[hPa]'
      'GMAO_ABSH' : Unit = '[fraction]'
      'AOD_SULF'  : Unit = '[unitless]'
      'AOD_BLKC'  : Unit = '[unitless]'
      'AOD_ORGC'  : Unit = '[unitless]'
      'AOD_SALA'  : Unit = '[unitless]'
      'AOD_SALC'  : Unit = '[unitless]'
      else        : Unit = '[ppbv]' 
   endcase
 
   ; Colorbar position
   CBPosition = [0.2, 0.05, 0.8, 0.07]
 
   ; Plot colorbar
   ColorBar, Div=4,                 Position=CBPosition, $
             Min=MinData,           Max=MaxData,         $
             NColors=!MYCT.NColors, Bottom=!MYCT.Bottom, $
             Unit=Unit,             _EXTRA=e
 
end
