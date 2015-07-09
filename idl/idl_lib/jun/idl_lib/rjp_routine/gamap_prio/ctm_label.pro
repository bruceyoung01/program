; $Id: ctm_label.pro,v 1.2 2004/01/29 19:33:36 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        CTM_LABEL (function)
;
; PURPOSE:
;        Returns strings for several CTM quantities.
;
; CATEGORY:
;        CTM Tools
;
; CALLING SEQUENCE:
;        result = CTM_LABEL(DataInfo, ModelInfo [, Keywords ])
;
; INPUTS:
;        DATAINFO -> Structure returned from CTM_GET_DATA, which
;             contains information about one data block
;                      
;        MODELINFO -> Structure returned from CTM_TYPE, which
;             contains information about the particular model 
;
;
; KEYWORD PARAMETERS:
;        AVERAGE -> Bit flag indicating the dimensions over which
;                   to average the data:
;                      1 :  longitudinal
;                      2 :  latitudinal
;                      4 :  vertical
;             These values can be combined. E.g., to average over
;             longitude and latitude use 3. A bit set in AVERAGE 
;             supersedes the corresponding bit in  TOTAL (see below). 
;
;        LAT -> Scalar value or array of latitudes used in the plot.
; 
;        LON -> Scalar value or array of longitudes used in the plot.
; 
;        LEV -> Scalar value or array of latitudes used in the plot.
;
;        ALT -> Scalar value or array of altitudes used in the plot.
;
;        PRS -> Scalar value or array of pressures used in the plot.
;
;        TOTAL -> Bit flag indicating the dimensions over which
;                 to sum the data:
;                      1 :  longitudinal
;                      2 :  latitudinal
;                      4 :  vertical
;             These values can be combined. E.g., to integrate over 
;             longitude and latitude use 3. A bit set in AVERAGE 
;             supersedes the corresponding bit in TOTAL (see above).
;
;
;        FORMAT -> Specifies format for converting numeric values into
;             string values, for selected fields (such as LAT and LON).
;             Default is I14 (strings are trimmed).
;
;        /NO_SPECIAL -> If set, will not place any special superscript
;             or subscript characters into the strings returned in
;             LABELSTRU.

; OUTPUTS:
;        LABELSTRU -> Structure containing the following label fields:
;             LAT:        String for latitude(s)     
;             LON:        String for longitude(s)
;             LEV:        String for vertical level(s)
;             ALT:        String for altitude level(s)
;             PRS:        String for pressure level(s)
;             LATLON:     String that has format "(Lat,Lon)"
;             TRACERNAME: String for the tracer name
;             SCALE:      String for the tracer's scale factor
;             UNIT:       String for the tracer's unit
;             TAU0:       String representation of TAU0
;             TAU1:       String representation of TAU1
;             YMD0:       String representation of (YY)YYMMDD
;                           corresponding to TAU0
;             YMD1:       String representation of (YY)YYMMDD
;                           corresponding to TAU1
;             HMS0:       String representation of HHMMSS
;                           corresponding to TAU0
;             HMS1:       String representation of HHMMSS
;                           corresponding to TAU1
;             YEAR0:      String for the starting year (e.g. 1994)
;             YEAR1:      String for the ending year 
;             MONTH0:     String for the starting month name 
;                          (e.g. "Jan", "Feb", "Mar", etc..)
;             MONTH1:     String for the ending month name
;             DAY0:       String for the starting day number (1-31)
;             DAY1:       String for the ending day number (1-31)
;             DATE:       String for the date (see below)
;             MODEL:      String for the model name
;             FAMILY      String for the model's family
;             RES:        String for the resolution of the model 
;
; SUBROUTINES:
;        CHKSTRU (function)     STRCHEM (function)
;        STRSCI  (function)     TAU2YYMMDD (function)
;   
; REQUIREMENTS:
;        DATAINFO and MODELINFO must be passed to CTM_LABEL.  These
;        structures are computed by the GAMAP package subroutines.
;
; NOTES:
;        DATAINFO is created e.g. by CTM_GET_DATA (or CTM_GET_DATABLOCK)
;        MODELINFO is created by CTM_TYPE
;
; EXAMPLE:
;        CTM_LABEL, DataInfo, ModelInfo, LabelStru, Lat=10, Lon=48
;       
;        print, LabelStru.LAT
;            prints 'Lat=10!UN!N'       
;
; MODIFICATION HISTORY:
;         bmy, 23 Sep 1998: VERSION 1.00
;         bmy, 24 Sep 1998: - now ensure that RES is a scalar string
;                           - place TAU2YYMMDD in FORWARD_FUNCTION call
;         bmy, 28 Sep 1998: VERSION 1.01
;                           - formats for LatStr, LonStr, LevStr
;                             changed to be more consistent.
;         mgs, 29 Sep 1998: - changed a few comments and fixed bug in 
;                             MinLon/MaxLon
;         bmy, 03 Nov 1998: - changed NAME to TRACERNAME for
;                             the sake of consistency
;         bmy, 12 Nov 1998: - added LABELSTRU structure tags: YEAR0,
;                             YEAR1, MONTH0, MONTH1, DAY0, DAY1, and DATE
;                           - now reports lats as S/N instead of -/+ 
;                             and reports lons as W/E instead of -/+
;         bmy, 17 Nov 1998: - now use function N_UNIQ to test for
;                             the number of unique elements in
;                             LAT, LON, LEV, ALT, PRS
;                           - Added FORMAT keyword to specify 
;                             format for LAT and LON strings
;                           - updated comments
;         bmy, 15 Jan 1999: - added NO_SPECIAL keyword
;         bmy, 17 Feb 1999: - Now add GMT to date string for timeseries
;                             animation plots (interval < 1 day)
;                           - make sure that HMS0STR and HMS1STR have
;                             string lengths of 6 characters
;         bmy, 18 Feb 1999: - fix default DATE string for February
;         mgs, 16 Mar 1999: - cosmetic changes
;                           - removed SUBTRACT_ONE keyword and improved
;                             choice of date format
;         bmy, 13 Jul 2001: GAMAP VERSION 1.48
;                           - Use updated version of STRREPL.PRO from mgs 
;         bmy, 07 Nov 2001: GAMAP VERSION 1.49
;                           - now use 8-digit YYYYMMDD format for
;                             date variables YMD0, YMD1
;         bmy, 02 Oct 2002: GAMAP VERSION 1.53
;                           - now write GEOS3 instead of GEOS3_30L
;         bmy, 05 Nov 2003: GAMAP VERSION 2.01
;                           - now write GEOS4 instead of GEOS3_30L
;                           - now use the proper time epoch for each
;                             model family in call to TAU2YYMMDD
;                           - updated comments
;
;-
; Copyright (C) 1998-2003,  
; Bob Yantosca and Martin Schultz, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author to arrange payment.
; Bugs and comments should be directed to bmy@io.harvard.edu
; or mgs@io.harvard.edu with subject "IDL routine ctm_label"
;-----------------------------------------------------------------------


function CTM_Label, DataInfo, ModelInfo,                                 $
                    Lat=Lat,       Lon=Lon,       Lev=Lev,               $
                    Alt=Alt,       Prs=Prs,       Average=Average,       $
                    Total=FTotal,  Format=Format, No_Special=No_Special, $
                    _EXTRA=e

   ;====================================================================
   ; Initialization
   ;====================================================================
   
   ; Pass external functions
   FORWARD_FUNCTION ChkStru, N_Uniq, StrSci, StrChem, Tau2YYMMDD
   
   ; Keyword settings
   if ( ChkStru( ModelInfo, [ 'NAME', 'FAMILY' ] ) lt 0 ) then begin
      Message, 'Invalid MODELINFO structure!', /Continue
      return, -1
   endif
 
   if ( ChkStru( DataInfo, [ 'FILEPOS', 'CATEGORY' ] ) lt 0 ) then begin
      Message, 'Invalid DATAINFO structure!', /Continue
      return, -1
   endif
   
   ; Average and Total
   if ( N_Elements( Average ) eq 0 ) then Average = 0
   if ( N_Elements( FTotal  ) eq 0 ) then FTotal  = 0
   
   Flag = ( Average OR FTotal )

   ; Default Format
   if ( N_Elements( Format ) eq 0 ) then Format = '(I14)'

   ; Suppress superscripts in strings
   No_Special = Keyword_Set( No_Special )

   ;====================================================================
   ; Latitude and Longitude labels
   ; Report Latitudes  as S/N instead of -/+
   ; Report Longitudes as W/E instead of -/+
   ;====================================================================
   LatStr    = ''
   LonStr    = ''
   LonLatStr = ''

   ;-----------------------------------------
   ; Degree symbol 
   ;-----------------------------------------
   if ( No_Special )       $
      then Degree = ''     $
      else Degree = '!uo!n' 
 
   ;-----------------------------------------
   ; Single Lat: LAT has one unique element
   ;-----------------------------------------
   if ( N_Uniq( Lat ) eq 1  ) then begin
      ThisLatStr = StrTrim( String( Abs( Lat[0] ), Format=Format ), 2 )
      if ( Lat[0] lt 0 ) then ThisLatStr = ThisLatStr + Degree + 'S'
      if ( Lat[0] gt 0 ) then ThisLatStr = ThisLatStr + Degree + 'N'

      LatStr = 'Lat=' + ThisLatStr
   endif

   ;-----------------------------------------
   ; Single Lon: LON has one unique element
   ;-----------------------------------------
   if ( N_Uniq( Lon ) eq 1 ) then begin
      ThisLonStr = StrTrim( String( Abs( Lon[0] ), Format=Format ), 2 )
      if ( Lon[0] gt -180 AND Lon[0] lt 0 ) $
         then ThisLonStr = ThisLonStr + Degree + 'W'
      if ( Lon[0] gt 0 AND Lon[0] lt 180 ) $
         then ThisLonStr = ThisLonStr + Degree + 'E'

      LonStr = 'Lon=' + ThisLonStr
   endif

   ;--------------------------------------------------------
   ; If there is only one latitude and one longitude, then
   ; create LATLONSTR, which has the format "(lat,lon)"
   ;--------------------------------------------------------
   if ( N_Uniq( Lat ) eq 1 and N_Uniq( Lon ) eq 1 ) $
      then LatLonStr = '(' + ThisLatStr + ',' + ThisLonStr + ')'    $
      else LatLonStr = ''
 
   ;----------------------------------------------
   ; Range Of Lat: LAT has two distinct elements
   ;----------------------------------------------
   if ( N_Uniq( Lat ) gt 1 ) then begin
      MinLat = Min( Lat, Max=MaxLat )

      ; String for minimum of lat range ( e.g. 30S, 0, 30N )
      MinLatStr = StrTrim( String( Abs( MinLat ), Format=Format ), 2 ) 
      if ( MinLat lt 0 ) then MinLatStr = MinLatStr + Degree + 'S' 
      if ( MinLat gt 0 ) then MinLatStr = MinLatStr + Degree + 'N'

      ; String for maximum of lat range ( e.g. 30S, 0, 30N ) 
      MaxLatStr = StrTrim( String( Abs( MaxLat ), Format=Format ), 2 )
      if ( MaxLat lt 0 ) then MaxLatStr = MaxLatStr + Degree + 'S' 
      if ( MaxLat gt 0 ) then MaxLatStr = MaxLatStr + Degree + 'N'

      ; Overall Latitude string
      LatStr = 'Lat= ' + MinLatStr + '-' + MaxLatStr
   endif
 
   ;----------------------------------------------
   ; Range of Lon: LON has two distinct elements
   ;----------------------------------------------
   if ( N_Uniq( Lon ) gt 1 ) then begin
      ;MinLon = Min( Lon, Max=MaxLon )
      MinLon = Lon[0]
      MaxLon = Lon[n_elements(Lon)-1]

      ; String for minimum of lon range ( e.g. -180, 60W, 0, 60E, 180 )
      MinLonStr = StrTrim( String( Abs( MinLon ), Format=Format ), 2 ) 
      if ( MinLon gt -180 AND MinLon lt 0 ) $
         then MinLonStr = MinLonStr + Degree + 'W' 
      if ( MinLon gt 0 AND MinLon lt 180 ) $
         then MinLonStr = MinLonStr + Degree + 'E'

      ; String for maximum of lat range ( e.g. -180, 60W, 0, 60E, 180 ) 
      MaxLonStr = StrTrim( String( abs( MaxLon ), Format=Format ), 2 )
      if ( MaxLon gt -180 AND MaxLon lt 0 ) $
         then MaxLonStr = MaxLonStr + Degree + 'W' 
      if ( MaxLon gt 0 AND MaxLon lt 180 ) $
         then MaxLonStr = MaxLonStr + Degree + 'E'

      ; Overall Longitude string
      LonStr = 'Lon= ' + MinLonStr + '-' + MaxLonStr
   endif
 
   ;====================================================================
   ; Labels for Vertical Levels
   ;====================================================================
   LevStr = ''
   
   ; Single Level
   if ( N_Uniq( Lev ) eq 1 ) $
      then LevStr = 'L=' + StrTrim( String( Lev, Format='(i6)' ), 2 )
 
   ; Range of levels
   if ( N_Uniq( Lev ) gt 1 ) then begin
      MinLev = Min( Lev, Max=MaxLev )
      LevStr = 'L=' + StrTrim( String( MinLev, Format='(i6)' ), 2 ) + $
                '-' + StrTrim( String( MaxLev, Format='(i6)' ), 2 ) 
   endif
 
   ;====================================================================
   ; Labels for altitudes
   ;====================================================================
   AltStr = ''

   ; Single altitude
   if ( N_Uniq( Alt ) eq 1 ) then begin
      AltStr = StrTrim( String( Alt[0], Format='(f6.1)' ), 2 ) + ' km'
   endif

   ; Range of altitudes
   if ( N_Uniq( Alt ) gt 1 ) then begin
      MinAlt = Min( Alt, Max=MaxAlt )
      AltStr = StrTrim( String( MinAlt, Format='(f6.1)' ), 2 ) + '-' + $
               StrTrim( String( MaxAlt, Format='(f6.1)' ), 2 ) + ' km'
   endif
 
   ;====================================================================
   ; Labels for pressures
   ;====================================================================
   PrsStr = ''

   ; Single pressure
   if ( N_Uniq( Prs ) eq 1 ) then begin
      PrsStr = StrTrim( String( Prs[0], Format='(f6.1)' ), 2 ) + ' mb'    
   endif

   ; Range of pressures
   if ( N_Uniq( Prs ) gt 1 ) then begin
      MinPrs = Min( Prs, Max=MaxPrs )
      PrsStr = StrTrim( String( MaxPrs, Format='(i4)' ), 2 ) + '-' + $
               StrTrim( String( MinPrs, Format='(i4)' ), 2 ) + ' mb'
   endif
 
   ;====================================================================
   ; Also prepend AVERAGE and TOTAL to labels
   ;====================================================================
   if ( ( Flag AND 1 ) gt 0 ) then begin
      if ( ( Average AND 1 ) gt 0 )            $
         then LonStr = 'Avg from '   + LonStr $
         else LonStr = 'Total from ' + LonStr
   endif

   if ( ( Flag AND 2 ) gt 0 ) then begin
      if ( ( Average AND 2 ) gt 0 )            $
         then LatStr = 'Avg from '   + LatStr $
         else LatStr = 'Total from ' + LatStr
   endif

   if ( ( Flag AND 4 ) gt 0 ) then begin
      if ( ( Average AND 4 ) gt 0 )            $
         then LevStr = 'Avg from '   + LevStr $
         else LevStr = 'Total from ' + LevStr
   endif

   ;====================================================================
   ; Labels for model name, family, and resolution
   ;====================================================================
   Name      = ModelInfo.Name                        
   if ( Name eq 'GEOS3_30L' ) then Name = 'GEOS3'
   if ( Name eq 'GEOS4_30L' ) then Name = 'GEOS4'
   ModelStr  = StrTrim( Name,   2 )    
   ModelStr  = StrRepl( ModelStr, '_', ' ' )
   FamStr    = StrTrim( ModelInfo.Family, 2 )
   Str1      = StrTrim( String( ModelInfo.Resolution[1], Format='(f5.1)' ), 2 )
   Str2      = StrTrim( String( ModelInfo.Resolution[0], Format='(f5.1)' ), 2 )
   ResStr    = Str1 + ' x ' + Str2
 
   ;====================================================================
   ; Labels for tracer name, unit, and scale factor
   ; If /NO_SPECIAL is set then do not superscript
   ; the labels via STRCHEM or STRSCI
   ;====================================================================
   if ( No_Special ) then begin
      NameStr   = StrTrim( DataInfo.TracerName, 2 )
      UnitStr   = StrTrim( DataInfo.Unit,       2 )
      ScaleStr  = StrTrim( DataInfo.Scale,      2 )
   endif else begin
      NameStr   = StrChem( DataInfo.TracerName, /Sub,   /Trim       )
      UnitStr   = StrChem( DataInfo.Unit,       /Super, /Trim       )
      ScaleStr  = StrSci ( DataInfo.Scale,      /Short, /Trim, /POT )
   endelse

   if ( ScaleStr eq '1'    ) then ScaleStr = '' else ScaleStr = ScaleStr + ' '
   if ( UnitStr  eq 'none' ) then UnitStr  = ''

   ;====================================================================
   ; Labels for day, month, and time 
   ;====================================================================

   ; Define flags for either GEOS or GISS time epoch
   GEOS  = ( FamStr eq 'GEOS' OR FamStr eq 'MOPITT'                   )
   GISS  = ( FamStr eq 'GISS' OR FamSTr eq 'MATCH' OR FamStr eq 'FSU' )

   ; compute decimal number of days between tau0 and tau1
   DateDiff = double(DataInfo.Tau1 - DataInfo.Tau0 - 1.1574D-5 ) / 24.0D0

   ; TAU0 and TAU1 strings
   Tau0Str  = StrTrim( String( DataInfo.Tau0 ), 2 )
   Tau1Str  = StrTrim( String( DataInfo.Tau1 ), 2 )
 
   ; YYMMDD, HHMMSS strings corresponding to TAU0
   ;------------------------------------------------------------------------
   ; Uncomment these lines for YYMMDD format
   YMD0     = Tau2YYMMDD( DataInfo.Tau0, /Short, GISS=GISS, GEOS=GEOS )
   YMD0Str  = String( YMD0[0], format='(I6.6)' ) 
   ;------------------------------------------------------------------------
   ; Uncomment these lines for YYYYMMDD format -- still a few things
   ; that need fixing, so deal w/ this later (bmy, 11/5/03)
   ;YMD0     = Tau2YYMMDD( DataInfo.Tau0, /NFormat, GISS=GISS, GEOS=GEOS ) 
   ;YMD0Str  = String( YMD0[0], format='(I8.8)' )
   ;------------------------------------------------------------------------
   HMS0Str  = String( YMD0[1] , format='(I6.6)' )

   ; YYMMDD, HHMMSS strings corresponding to TAU1
   ; subtract 1 second from TAU1 for nicer labels if Datediff > 1 day
   tau1 = DataInfo.Tau1
   if (DateDiff gt 1.) then tau1 = tau1 - 1.1574D-5
   ;------------------------------------------------------------------------
   ; Uncomment these lines for YYMMDD format
   YMD1     = Tau2YYMMDD( Tau1, /Short, GISS=GISS, GEOS=GEOS )
   YMD1Str  = String( YMD1[0], format='(I6.6)' )
   ;------------------------------------------------------------------------
   ; Uncomment these lines for YYYYMMDD format -- still a few things
   ; that need fixing, so deal w/ this later (bmy, 11/5/03)
   ;YMD1     = Tau2YYMMDD( Tau1, /NFormat, GISS=GISS, GEOS=GEOS )
   ;YMD1Str  = String( YMD1[0], format='(I8.8)' )
   ;------------------------------------------------------------------------
   HMS1Str  = String( YMD1[1], format='(I6.6)' )

   ; Months of the year
   Months   = [ 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', $
                'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec' ]

   ; Number of days in month (don't worry about leap years ...)
   MDays = [ 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 ]

   ; Two-digit year numbers (e.g. 94, 98, 01) for start & end years
   YearNum0 = YMD0[0] / 10000L
   YearNum1 = YMD1[0] / 10000L

   ; Two-digit month numbers (e.g. 1, 10, 12) for start & end months
   Tmp0      = ( YMD0[0] - ( YearNum0 * 10000L ) )
   MonthNum0 = Tmp0 / 100L

   Tmp1      = ( YMD1[0] - ( YearNum1 * 10000L ) ) 
   MonthNum1 = Tmp1 / 100L

   ; Two-digit day number (e.g. 1-31) for start & end days
   DayNum0   = Tmp0 - ( Tmp0 / 100L ) * 100L
   DayNum1   = Tmp1 - ( Tmp1 / 100L ) * 100L

   ; Strings for start & end days
   DayStr0   = StrTrim( String( DayNum0 ), 2 )
   DayStr1   = StrTrim( String( DayNum1 ), 2 )

   ; Strings for start & end months
   MonthStr0 = Months( MonthNum0 - 1 )
   MonthStr1 = Months( MonthNum1 - 1 )

   ; Strings for start & end years (make sure they are Y2K compliant!)
   if ( YearNum0 ge 80 ) $
      then YearStr0 = StrTrim( String( YearNum0 + 1900 ), 2 ) $
      else YearStr0 = StrTrim( String( YearNum0 + 2000 ), 2 )

   if ( YearNum1 ge 80 ) $
      then YearStr1 = StrTrim( String( YearNum1 + 1900 ), 2 ) $
      else YearStr1 = StrTrim( String( YearNum1 + 2000 ), 2 )

   ;--------------------------------------------------------------------
   ; Date string:
   ; If the interval  < 2 hours   print YYMMDD0 at HHMM
   ; If the interval  < 2 days,   print YYMMDD0 HHMM - YYMMDD1 HHMM
   ; If the interval  = 1 day starting at 000000,  print YYMMDD0
   ; If the interval  < 6 months, print YYMMDD0 - YYMMDD1
   ; If the interval  = 1 month starting on the first,  print month & year 
   ; If the interval  > 2 months, print start & end months & years
   ; If the interval  > 5 years,  print start & end years
   ;--------------------------------------------------------------------

   ; determine whether Datediff spans exactly one month
   extraday = (MonthNum0 eq 2 AND (YearNum0 mod 4) eq 0)
   ismonth = ( (DayNum0 eq 1) AND  $
               abs(DateDiff - MDays[MonthNum0-1]+extraday) lt 0.9 )

   if (ismonth) then begin
      DateStr = 'for ' + MonthStr0 + ' ' + YearStr0

   endif else if ( DateDiff lt 0.084 ) then begin
      ; add HOURSTR to DATESTR for timeseries animation (bmy, 2/17/99 )
      HourStr = StrTrim( StrMid( HMS0Str, 0, 2 ), 2 ) + ':' + $
                StrTrim( StrMid( HMS0Str, 2, 2 ), 2 ) + ' GMT'
      
      DateStr = YMD0Str + ' at ' + HourStr 

   endif else if ( abs(DateDiff-1.) lt 1.0D-4 AND YMD0[1] lt 100L) then begin

      DateStr = 'for ' + YMD0Str

   endif else if ( DateDiff lt 2. ) then begin
      ; add HOURSTR to DATESTR for very short output
      HourStr0 = StrTrim( StrMid( HMS0Str, 0, 2 ), 2 ) + ':' + $
                 StrTrim( StrMid( HMS0Str, 2, 2 ), 2 ) + ' GMT'
      HourStr1 = StrTrim( StrMid( HMS1Str, 0, 2 ), 2 ) + ':' + $
                 StrTrim( StrMid( HMS1Str, 2, 2 ), 2 ) + ' GMT'
      
      DateStr = YMD0Str + ' ' + HourStr0 + ' - ' $
                + YMD1Str + ' ' + HourStr1

   endif else if ( DateDiff le 180. ) then begin
      DateStr = YMD0Str + ' - ' + YMD1Str

   endif else if ( DateDiff le 1825. ) then begin
      DateStr = MonthStr0 + ' ' + YearStr0 + ' - ' + $
                MonthStr1 + ' ' + YearStr1  
      
   endif else begin
      DateStr = YearStr0 + ' - ' + YearStr1

   endelse

   ;====================================================================
   ; Create output structure with all label strings, so 
   ; that the user can have access to all of them at once
   ;====================================================================
   LabelStru = { Lat       :LatStr,    Lon    :LonStr,    Lev   :LevStr,    $
                 Alt       :AltStr,    Prs    :PrsStr,    LatLon:LatLonStr, $
                 TracerName:NameStr,   Scale  :ScaleStr,  Unit  :UnitStr,   $
                 Tau0      :Tau0Str,   Tau1   :Tau1Str,   YMD0  :YMD0Str,   $
                 YMD1      :YMD1Str,   HMS0   :HMS0Str,   HMS1  :HMS1Str,   $
                 Year0     :YearStr0,  Year1  :YearStr1,  Month0:MonthStr0, $
                 Month1    :MonthStr1, Day0   :DayStr0,   Day1  :DayStr1,   $
                 Date      :DateStr,   Model  :ModelStr,  Family:FamStr,    $
                 Res       :ResStr }

   ; Return to calling program        
   return, LabelStru
end
 
