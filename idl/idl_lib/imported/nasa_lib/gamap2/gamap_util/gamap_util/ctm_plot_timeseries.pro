; $Id: ctm_plot_timeseries.pro,v 1.1.1.1 2007/07/17 20:41:26 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        CTM_PLOT_TIMESERIES
;
; PURPOSE:
;        Plots station timeseries data (e.g. from the GEOS-CHEM
;        ND48 diagnostic) contained in binary punch file format.
;        %%%% MAY NEED UPDATING %%%%%
;
; CATEGORY:
;        GAMAP Utilities, GAMAP Plotting
;
; CALLING SEQUENCE:
;        CTM_PLOT_TIMESERIES, CATEGORY [ , Keywords ] 
;
; INPUTS:
;        CATEGORY -> The diagnostic number (e.g. ND22, ND45, etc or 
;             category name (e.g. "JV-MAP-$", "IJ-AVG-$") for which to 
;             read data from the punch file. 
;
; KEYWORD PARAMETERS:
;        BOTTOM -> The lowest color index of the colors to be loaded
;             used in the color map and color bar.  The default is
;             to use the value in system variable !MYCT.BOTTOM.
;
;        COLOR -> Color of the plot window and/or data.  The default
;             is to use the system variable !MYCT.BLACK.
;
;        LABELSTRU -> Returns to the calling program the structure
;             of label information obtained by CTM_LABEL.
;
;        LEV -> An index array of sigma levels *OR* a two-element
;             vector specifying the min and max sigma levels to be 
;             included in the plot.  Default is [ 1, GRIDINFO.LMX ].
; 
;        OVERPLOT -> Plot data atop the previous plot window, instead
;             of erasing the screen and plotting in a new window.
;
;        RESULT -> A named variable will contain the data subset that
;             was plotted together with the X and/or Y coordinates in
;             a  structure.  
;
;        TITLE -> Top title string for the plot.  If not passed, 
;             then a default title string will be printed.
;
;        UNIT -> Name of the unit that the DATA array will be converted
;             to. If not specified, then no unit conversion will be done.
;
;        XTITLE -> X-Axis title string for the plot.  If not passed, 
;             then a default title string will be printed.
;
;        YTITLE -> Y-Axis title string for the plot.  If not passed, 
;             then a default title string will be printed.
;
;        YRANGE -> range of y values for color scaling (default:
;             scale each plot seperately with data min and max)
;
;        _EXTRA=e -> Picks up extra keywords for routines called
;             by CTM_PLOT_TIMESERIES.
;
; OUTPUTS:
;        None
;
; SUBROUTINES:
;        External Subroutines Required:
;        ===========================================================
;        CTM_GET_DATA              CTM_INDEX           (function)
;        CTM_LABEL    (function)   GETMODELANDGRIDINFO (function)
;        UNDEFINE                  REPLACE_TOKEN       (function)         
;
; REQUIREMENTS:
;        None
;
; NOTES:
;        None
;
; EXAMPLE:
;
; MODIFICATION HISTORY:
;        bmy, 16 Apr 2004: GAMAP VERSION 2.03
;                          - Initial version
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
; or phs@io.harvard.edu with subject "IDL routine ctm_plot_timeseries"
;-----------------------------------------------------------------------


pro CTM_Plot_TimeSeries, Category,                             $
                         Bottom=Bottom,       Color=MColor,    $ 
                         LabelStru=LabelStru, Lev=LLev,        $
                         OverPlot=OverPlot,   Result=Result,   $
                         Title=Title,         Unit=Unit,       $          
                         XTitle=XTitle,       YRange=YRange,   $
                         YTitle=YTitle,       _EXTRA=e
                                
   ;===================================================================
   ; Initialization
   ;===================================================================

   ; External functions
   FORWARD_FUNCTION Replace_Token

   ; Local common block for axis parameters of most recent plot
   ; (needed for OverPlot option)
   COMMON TS_LastPlot_AxisParam, XPar, YPar, PPar

   ; Initialize local common block (if necessary
   if ( N_Elements( XPar ) eq 0 ) then begin
      XPar = !X
      YPar = !Y
      PPar = !P
   endif

   ; Default arguments
   if ( N_Elements( Category  ) eq 0 ) then Category = 'IJ-AVG-$'

   ; Default levels
   if ( N_Elements( LLev      ) eq 0 ) then LLev = 1
   if ( N_Elements( LLev      ) eq 2 ) then $
      if ( LLev[0] eq LLev[1] ) then LLev = LLev[0]

   ; Default top title
   if ( N_Elements( Title     ) eq 0 ) $
      then Title  = '%MODEL% %TRACERNAME% at %LATLON%' + $
                    '  %LEV% (%ALT%)  Starting from %YMD0%'
   
   ; Default X and Y title strings
   if ( N_Elements( YTitle  ) eq 0 ) then YTitle = '%TRACERNAME% [%UNIT%]'
 
   ; Colors
   if ( N_Elements( Bottom  ) ne 1 ) then Bottom = !MYCT.BOTTOM  
   if ( N_Elements( MColor  ) ne 1 ) then MColor = !MYCT.BLACK

   ; Other plot parameters
   if ( N_Elements( XStyle  ) ne 1 ) then XStyle = 1
   if ( N_Elements( YStyle  ) ne 1 ) then YStyle = 1

   ; Number of plot panels per page
   NPanels = !P.MULTI[1] * !P.MULTI[2]

   ;===================================================================
   ; Read data into arrays
   ;===================================================================

   ; Read data blocks from the file
   CTM_Get_Data, DataInfo, Category, _EXTRA=e

   ; Get corresponding MODELINFO and GRIDINFO structures
   GetModelAndGridInfo, DataInfo[0], ModelInfo, GridInfo

   ; Take unit string from DATAINFO if undefined
   if ( N_Elements( Unit ) eq 0 ) then Unit = StrTrim( DataInfo[0].Unit, 2 )

   ; Last element of DATAINFO
   N_Data = N_Elements( DataInfo ) -1L 
 
   ; Create arrays
   Data   = FltArr( N_Data )
   Tau    = FltArr( N_Data )

   ; Loop over all data points 
   for D = 0L, N_Data-1L do begin

      ; Only take data if it has been read in
      if ( Ptr_Valid( DataInfo[D].Data ) ) $
         then TmpData = *( DataInfo[D].Data )
         
      ; Store data in 
      Data[D] = Temporary( TmpData[LLev-1] )

      ; Index of hours since the starting time
      Tau[D]  = DataInfo[D].Tau0 - DataInfo[0].Tau0
   endfor

   ; Get longitude and latitude
   CTM_Index, ModelInfo, DataInfo[0].First[0], DataInfo[0].First[1], $
      Center=Center, /Non_Interactive, /Get_Coordinates

   ;===================================================================
   ; If there is more than 4 days of data, choose title accordingly
   ;===================================================================

   if ( Tau[N_Data-1L] - Tau[0] gt 96 ) then begin

      ; More than 4 days of data: plot X-axis in days
      Time = Tau / 24d0
      if ( N_Elements( XTitle ) eq 0 ) then XTitle = 'Days since %DATE%' 
      if ( N_Elements( XMinor ) eq 0 ) then XMinor = 2

   endif else begin

      ; Otherwise plot data in hours
      Time = Tau
      if ( N_Elements( XTitle ) eq 0 ) then XTitle = 'Hours since %DATE%'  
      if ( N_Elements( XMinor ) eq 0 ) then XMinor = 4 

   endelse

   ;===================================================================
   ; Create plot labels
   ;===================================================================

   ; Get altitude & pressure variables
   if ( not ChkStru(GridInfo,'LMX') ) then begin
      Prs    = 1013.25    ; *** FIXED *** 
      Alt    =    0.
   endif else if ( N_Elements( Lev ) eq 1 ) then begin
      Alt    = GridInfo.ZMid[ LLev[0] - 1 ]
      Prs    = GridInfo.PMid[ LLev[0] - 1 ]
   endif else begin
      MinLev = ( Min( LLev, Max=MaxLev ) > 0 )
      MaxLev = MaxLev < ( GridInfo.LMX - 1)
      Alt    = [ GridInfo.ZMid( MinLev-1 ), GridInfo.ZMid( MaxLev - 1 ) ]
      Prs    = [ GridInfo.PMid( MinLev-1 ), GridInfo.PMid( MaxLev - 1 ) ]
   endelse

   ; Call CTM_LABEL to return the LABELSTRU structure
   LabelStru = CTM_Label( DataInfo[0],   ModelInfo,     Unit=Unit, $
                          Lat=Center[0], Lon=Center[1], Lev=LLev,  $
                          Alt=Alt,       Prs=Prs,       _EXTRA=e )

   ; Replace tokens in the title strings
   NewTitle  = Replace_Token( Title,  LabelStru )
   NewXTitle = Replace_Token( XTitle, LabelStru )
   NewYTitle = Replace_Token( YTitle, LabelStru )

   ;===================================================================
   ; Plot data
   ;===================================================================

   if ( not Keyword_Set( OverPlot ) ) then begin

      ; Plot data and axes 
      Plot, Time, Data,                                      $
         Color=MColor,     YRange=YRange,                    $
         XStyle=XStyle,    YStyle=YStyle,                    $
         XTitle=NewXTitle, YTitle=NewYTitle, Title=NewTitle, $
         XMinor=XMinor,    _EXTRA=e

      ; Save plot parameters in common block
      XPar = !X
      YPar = !Y
      PPar = !P

   endif else begin

      ; Restore X-axis parameters from common block
      !X = XPar
      !Y = YPar
      !P = PPar

      ; Overplot data
      OPlot, Tau, Data, Color=MColor, _EXTRA=e

   endelse
   
   ;====================================================================
   ; Cleanup and quit
   ;====================================================================

   ; Undefine variables
   UnDefine, Tau
   UnDefine, Time
   UnDefine, Data

end
