;$Id: ctm_extract.pro,v 1.3 2007/12/10 20:14:51 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        CTM_EXTRACT (function)
;
; PURPOSE:
;        Extracts a block of data from a 3-D CTM data cube.
;
; CATEGORY:
;        GAMAP Utilities, GAMAP Data Manipulation
;
; CALLING SEQUENCE:
;        CTM_EXTRACT, DATA, MODELINFO, GRIDINFO [,Keywords]
;
; INPUTS:
;        DATA -> The data cube from which to extract a region.
;             DATA must be 3-dimensional (e.g. lon-lat-alt, or 
;             lon-lat-tracer, etc).
;
; KEYWORD PARAMETERS:
;        MODELINFO -> The MODELINFO structure returned from function 
;             CTM_TYPE.  
;
;        GRIDINFO -> The GRIDINFO structure returned from function
;             CTM_GRID.
;
;        AVERAGE -> Bit flag indicating the dimensions over which to
;             average the data:
;                1 :  longitudinal
;                2 :  latitudinal
;                4 :  vertical
;             These values can be combined. E.g., to average over 
;             longitude and latitude use 3. A bit set in AVERAGE 
;             superseeds the corresponding bit in TOTAL (see below).
; 
;        TOTAL -> Bit flag indicating the dimensions over which
;             to sum the data:
;                1 :  longitudinal
;                2 :  latitudinal
;                4 :  vertical
;             These values can be combined. E.g., to integrate over
;             longitude and latitude use 3. A bit set in AVERAGE
;             superseeds the corresponding bit in TOTAL (see above).
;
;        /INDEX -> If set, will interpret LAT, LEV, and LON as index 
;             arrays.  If not set, will interpret LAT, LEV, and LON as 
;             ranges (i.e. two-element vectors containing min and max values).
;
;        LAT -> An index array of latitudes *OR* a two-element vector 
;             specifying the min and max latitudes to be included in
;             the extracted data block.  Default is [ -90, 90 ].
;
;        LEV -> An index array of sigma levels *OR* a two-element vector 
;             specifying the min and max sigma levels to be included
;             in the extracted data block.  Default is [ 1, GRIDINFO.LMX ].
;
;        LON -> An index array of longitudes *OR* a two-element vector 
;             specifying the min and max longitudes to be included in
;             the extracted data block.  Default is [ -180, 180 ].
;
;        ALTRANGE -> A vector specifying the min and max altitude 
;             values (or a scalar specifying a single altitude) to
;             be included in the extracted data block.
;
;        PRANGE -> A vector specifying the min and max pressure levels 
;             (or a scalar specifying a single pressure level) to be
;             included in the extracted data block.
;
;        WE -> Returns to the calling program the index array of longitudes 
;             for the extracted data region, ordered from west to east.
;
;        SN -> Returns to the calling program the index array of latitudes
;             for the extracted data region, ordered from South to North.
; 
;        UP -> Returns to the calling program the index array of vertical  
;             levels for the extracted data region, ordered from surface
;             to top.
;
;        DIM -> A named variable will return the new dimension information 
;             of the data block after averaging or totaling.
;
;        _EXTRA=e   -> Picks up extra keywords for CTM_INDEX.
;
; OUTPUTS:
;        X, Y, Z -> Arrays of latitude, longitude, or altitude values 
;             corresponding to the the 1st, 2nd, and 3rd dimensions of 
;             the DATA array, respectively.
;
; SUBROUTINES:
;        CTM_INDEX 
;        DEFAULT_RANGE (function)
;
; REQUIREMENTS:
;        Uses GAMAP package subroutines.
;
; NOTES:
;        (1) CTM_EXTRACT returns the extracted data region as 
;        the function value.
;
;        (2) Assumes a 3-D data cube as input, of dimensions (lon, lat,
;        alt), or for some diagnostics (lon, lat, "tracer" number).
;
;        (3) In the calling program, CTM_TYPE and CTM_GRID must be 
;        called to compute the MODELINFO and GRIDINFO structures,
;        which can then be passed to CTM_EXTRACT.
;
;        (4) If any of the LAT, LON, LEV, ALTRANGE, PRANGE keywords are
;        explicity specified, then CTM_EXTRACT will return to the
;        calling program their original, unmodified values.  If any
;        of these are not explicitly specified , then CTM_EXTRACT 
;        will return to the calling program default values.  
;
; EXAMPLE:
;        (1)
;        MODELINFO  = CTM_TYPE( 'GEOS4', RES=4 )
;        GRIDINFO   = CTM_GRID( MODELINFO )
;        DATAREGION = CTM_EXTRACT( DATACUBE,                   $
;                                  MODELINFO=MODELINFO,        $
;                                  GRIDINFO=GRIDINFO           $
;                                  LON=[-180,0], LAT=[-30,30], $ 
;                                  LEV=[1,10] )
;
;               ; Extracts from a GEOS-4 4x5 data cube a region 
;               ; delimited by longitude = [-180, 0], 
;               ; latitude = [-30, 30], for levels 1 to 10.
;
;        (2)
;        LON = INDGEN( 36 )
;        LAT = INDGEN( 16 ) + 15
;        LEV = INDGEN( 10 ) 
;        MODELINFO  = CTM_TYPE( 'GEOS4' )
;        GRIDINFO   = CTM_GRID( MODELINFO )
;        DATAREGION = CTM_EXTRACT( DATACUBE,            $
;                                  MODELINFO=MODELINFO, $
;                                  GRIDINFO=GRIDINFO,   $
;                                  /INDEX,  LON=LON,    $
;                                  LAT=LAT, LEV=LEV )
;
;               ; Extracts same data region as in Example (1) but 
;               ; here passes explicit index arrays instead of ranges.
;
; MODIFICATION HISTORY:
;        bmy, 16 Sep 1998: VERSION 1.00
;        bmy, 17 Sep 1998: - now extracts data from data cube one 
;                            dimension at a time to avoid errors
;        bmy, 18 Sep 1998: VERSION 1.01
;                          - INDEX, SN, WE, UP keywords added
;                          - LATRANGE, LONRANGE, LEVRANGE renamed
;                            to LAT, LON, LEV (since they may now 
;                            contain arrays and not just ranges).
;        mgs, 21 Sep 1998: - some more error checking
;                          - removed MinData and MaxData 
;        bmy and mgs, 22 Sep 1998: VERSION 1.02
;                          - added AVERAGE and TOTAL keywords
;        bmy, 24 Sep 1998: VERSION 1.03
;                          - Now returns original values of LAT, LON, 
;                            LEV, ALTRANGE, and PRANGE if those keywords
;                            are specified.  Otherwise returns
;                            defaults.
;        MGS, 29 SEP 1998: - Introduced new DEFAULT_RANGE function.
;        bmy, 06 Oct 1998: - fixed bug: now S = size( NEWDATA )
;        bmy, 08 Oct 1998: VERSION 1.04
;                          - MODELINFO and GRIDINFO are now keywords
;                          - added X, Y, and Z as parameters
;        bmy, 11 Feb 1999: - updated comments
;        bmy, 19 Feb 1999: VERSION 1.05
;                          - added FIRST keyword so that the values of
;                            THISDATAINFO.FIRST can be passed from the
;                            calling routine.
;                          - now call ADJ_INDEX to adjust the WE,
;                            SN, and UP index arrays for data blocks
;                            that are less than global size.
;                          - added DEBUG keyword
;        mgs, 16 Mar 1999: - cosmetic changes
;        mgs, 02 Apr 1999: - bug fixes that prevented use with 2D fields
;                            (e.g. EPTOMS data)
;        mgs, 21 May 1999: - now catches error in multitracer diagnostics
;                            when user requests a level beyond LMX.
;        qli, 26 May 1999: - "max(newlev) ge" corrected to "gt"
;        bmy, 15 Sep 1999: VERSION 1.43
;                          - removed bugs that caused data blocks to
;                            always have MODELINFO.NTROP vertical
;                            layers
;        bmy, 04 Dec 2000: GAMAP VERSION 1.47
;                          - add code for future bug fix
;        bmy, 24 Apr 2001: - bug fix: now can handle longitudes
;                            greater than 180 degrees
;        bmy, 06 Jun 2001: - bug fix: Test if LON exists before
;                            assigning it to NEWLON.
;        bmy, 30 Jul 2001: GAMAP VERSION 1.48
;                          - bug fix: now extract proper latitude range
;                            for data blocks smaller than global size
;        bmy, 26 Jun 2002: GAMAP VERSION 1.51
;                          - Default value of FIRST is now [1,1,1], 
;                            since this has to be in Fortran notation.
;                          - also do error checking on FIRST near
;                            the beginning of the program.
;        bmy, 15 Nov 2002: GAMAP VERSION 1.52
;                          - now can handle total/average for MOPITT grid
;        bmy, 23 Aug 2004: GAMAP VERSION 2.03
;                          - now can handle single-point data blocks
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
;        bmy, 19 Nov 2007: GAMAP VERSION 2.11
;                          - Updated comments
;        bmy, 10 Dec 2007: GAMAP VERSION 2.12
;                          - Now pad ALTRANGE and PRANGE to 2 elements
;                            if they are passed w/ one element
;
;-
; Copyright (C) 1998-2007, Martin Schultz,
; Bob Yantosca and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of 
; this software. If this software shall be used commercially or 
; sold as part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.harvard.edu with subject "IDL routine "
;-----------------------------------------------------------------------


function CTM_Extract, Data, X, Y, Z,                          $
                      ModelInfo=ModelInfo, GridInfo=GridInfo, $
                      Average=Average,     Total=FTotal,      $
                      Index=Index,         Lat=Lat,           $
                      Lev=Lev,             Lon=Lon,           $
                      AltRange=AltRange,   PRange=PRange,     $
                      WE=WE,               SN=SN,             $
                      UP=UP,               Dim=Dim,           $
                      First=First,         Debug=Debug,       $
                      _EXTRA=e

   ;=====================================================================
   ; Initialization
   ;=====================================================================

   ; External functions
   FORWARD_FUNCTION Adj_Index, Default_Range

   ; Keyword Settings
   if ( N_Elements( Data ) eq 0 ) then begin
      Message, 'Invalid DATA array!',  /Continue
      return, -1
   endif

   if ( not ChkStru( ModelInfo, [ 'NAME', 'FAMILY' ] ) ) then begin
      Message, 'Invalid MODELINFO structure!', /Continue
      return, -1
   endif
 
   if ( not ChkStru( GridInfo, [ 'XEDGE', 'YEDGE' ] ) ) then begin
      Message, 'Invalid GRIDINFO structure!', /Continue
      return, -1
   endif
 
   ; Pad to 2 elements if only one element is passed
   if ( N_Elements( AltRange ) eq 1 ) then AltRange = [ AltRange, AltRange ]
   if ( N_Elements( PRange   ) eq 1 ) then Prange   = [ Prange,   PRange   ]

   ; Flag settings for AVERAGE and TOTAL keywords
   if ( N_Elements( Average ) eq 0 ) then Average = 0
   if ( N_Elements( FTotal  ) eq 0 ) then FTotal  = 0

   ; Very hokey way to set FIRST.
   if ( N_Elements( First ) eq 0 ) then First = [1, 1, 1]

   ; Error check: Make sure FIRST starts from 1 (bmy, 6/26/02)
   First = First > 1

   Flag = ( Average OR FTotal )
   
   ; Debugging flag
   Debug = Keyword_Set( Debug )

   ; SDATA is the dimensions of the input data array (bmy, 12/4/00)
   SData = Size( Data, /Dim )

   ;=====================================================================
   ; Default setting for INDEX
   ;=====================================================================
   Index = Keyword_Set( Index )

   if ( Index ) then begin

      ;==================================================================
      ; If /INDEX is set, then interpret LON, LAT, and LEV as index 
      ; arrays instead of ranges.
      ;
      ; NOTE: Array indices are given in FORTRAN convention.  
      ;       Hence, 1 is subtracted to convert to IDL.
      ; 
      ; If array indices exceed allowed range, we end up with duplicate 
      ; entries!  Warn user...
      ;==================================================================
      WE = ((Lon - 1) > 0) < GridInfo.IMX
      SN = ((Lat - 1) > 0) < GridInfo.JMX
      UP = Lev       ; conversion below

      Test = Uniq( WE, Sort( WE ) )
      if ( N_Elements( Test ) ne N_Elements( WE ) ) then $
          Message, 'Invalid array indices for LON!', /Continue

      Test = Uniq( SN, Sort( SN ) )
      if ( N_Elements( Test ) ne N_Elements( SN ) ) then $
          Message, 'Invalid array indices for LAT!', /Continue

   endif else begin
 
      ;==================================================================
      ; If INDEX = 0, then interpret LAT, LON, and LEV as two-element 
      ; vectors containing the min and max extents of latitude, 
      ; longitude, and vertical levels.  Ditto for Altitude and Pressure.
      ; 
      ; Preserve original values of LAT, LON, LEV, ALTRANGE, PRANGE, 
      ; in temporary variables.  The original values might be needed
      ; to create labels for plot titles in the calling program.
      ;==================================================================
      if ( N_Elements( SData ) lt 3 ) then DLev = 1 else DLev = SData[2] 

      ;------------------------------------------------------------------
      ; NOTE: If you use the default ranges [-182.5,177.5] and
      ; [-90,90] for NEWLAT and NEWLON, then this will make program
      ; CTM_GET_DATABLOCK return a global data block even if the data
      ; block is less than global size.  Install this code for future
      ; expansion -- fix it later (bmy, 12/4/00)
      ;
      ; For future bug fix -- leave commented out for now (bmy, 12/4/00)
      ;Def_X_Range = [ GridInfo.XMid[ First[0] - 1            ], $
      ;                GridInfo.XMid[ First[0] + SData[0] - 2 ] ]
      ;

      ; Now account for single-point data blocks (bmy, 8/23/04)
      if ( N_Elements( SData ) gt 1 ) then begin
         Def_Y_Range = [ GridInfo.YMid[ First[1] - 1            ], $
                         GridInfo.YMid[ First[1] + SData[1] - 2 ] ]
      endif else begin
         Def_Y_Range = [ GridInfo.YMid[ First[1] - 1 ], $
                         GridInfo.YMid[ First[1] - 1 ] ]
      endelse

      ;if ( N_Elements( Lon ) gt 0 ) then print, '### CE: Lon: ', Lon
      ;if ( N_Elements( Lat ) gt 0 ) then print, '### CE: Lat: ', Lat
      ;
      ;NewLon      = Default_Range( Lon, Def_X_Range, /Limit2, /NOSORT )
      ;NewLat      = Default_Range( Lat, Def_Y_Range, /Limit2          )
      ;
      ;print, '### CE: Def_x_range: ', Def_X_Range
      ;print, '### CE: Def_y_range: ', Def_Y_Range
      ;------------------------------------------------------------------

      ; NEWLON needs to be in the range [-180,180] (bmy, 6/6/01)
      if ( N_Elements( Lon ) gt 0 ) then begin
         NewLon      = Lon
         Ind         = Where( NewLon gt 180 )
         if ( Ind[0] ge 0 ) then NewLon[Ind] = NewLon[Ind] - 360.0
      endif

      NewLon      = Default_Range( NewLon,   [-182.5,180.], /Limit2, /NOSORT )
      NewLat      = Default_Range( Lat,      Def_Y_Range,   /Limit2          )
      NewLev      = Default_Range( Lev,      [ 1, DLev ],   /Limit2          )
      NewAltRange = Default_Range( AltRange, [ -1.,-1.],    /Limit2          )
      NewPRange   = Default_Range( PRange,   [ -1.,-1.],    /Limit2, /NOSORT )

      ;### Debug (bmy, 12/4/00)
      if ( Debug ) then begin
         print, '### CTM_EXTRACT: NEWLON : ', newlon
         print, '### CTM_EXTRACT: NEWLAT : ', newlat
         print, '### CTM_EXTRACT: NEWLEV : ', newlev, dlev
      endif

      ;==================================================================
      ; Call CTM index to translate Lat/Lon ranges into I/J ranges
      ; WE = index array of longitudinal ( West  -> East  ) boxes
      ; SN = index array of latitudinal  ( South -> North ) boxes
      ;==================================================================
      CTM_Index, ModelInfo, $
         Edge=[ NewLat[0], NewLon[0], NewLat[1], NewLon[1] ], $
         WE_Index=WE, SN_Index=SN, /Non_Interactive, _EXTRA=e
   
      ;==================================================================
      ; UP     = index array of sigma levels for vertical direction 
      ; MAXLEV = maximum number of vertical levels allowed for this grid
      ; LEVIND = index array of vertical levels (starting from 0)
      ;==================================================================
      if ( ChkStru( GridInfo, 'LMX' ) ) $
         then MaxLev = GridInfo.LMX     $
         else MaxLev = 1

      LevInd = IndGen( MaxLev ) 

      if ( NewAltRange[0] ge 0 ) then begin

         ;===============================================================
         ; If ALTRANGE is specified, use the min and max altitude 
         ; values to compute the UP index array
         ;===============================================================
         NewAltRange = NewAltRange( Sort( NewAltRange ) )
         ;-------------------------------------------------------------------
         ; Prior to 12/10/07:
         ;Ind         = Where( GridInfo.ZEdge ge NewAltRange[0] and $
         ;                     GridInfo.ZEdge le NewAltRange[1] )
         ;-------------------------------------------------------------------

         ; Modified for when ALTRANGE contains the same number twice
         ; (bmy, 12/10/07)
         if ( NewAltRange[0] eq NewAltRange[1] ) then begin
            Ind = Where( GridInfo.ZEdge le NewAltRange[0], C )
            Ind = Ind[C-1]
         endif else begin
            Ind = Where( GridInfo.ZEdge ge NewAltRange[0] AND $
                         GridInfo.ZEdge le NewAltRange[1] )
         endelse

         if ( Ind[0] ge 0 ) $
            then UP = LevInd[ Ind ] $
            else UP = LevInd[ * ]
      
      endif else if ( NewPRange[0] ge 0 ) then begin
      
         ;===============================================================
         ; If PRANGE is specified, use the min and max altitude values 
         ; to compute the UP index array
         ;===============================================================
         NewPRange = NewPRange( Sort( NewPRange ) )
         ;------------------------------------------------------------------
         ; Prior to 12/10/07:
         ;Ind       = Where( GridInfo.PEdge le NewPRange[0] and $
         ;                   GridInfo.PEdge ge NewPRange[1] )
         ;------------------------------------------------------------------
         
         ; Modified for when PRANGE contains the same number twice
         ; (bmy, 12/10/07)
         if ( NewPRange[0] eq NewPRange[1] ) then begin
            Ind = Where( GridInfo.Pedge ge NewPRange[0], C )
            Ind = Ind[C-1]
         endif else begin
            Ind = Where( GridInfo.PEdge le NewPRange[0] AND $
                         GridInfo.PEdge ge NewPRange[1] )
         endelse

         if ( Ind[0] ge 0 ) $
            then UP = LevInd[ Ind ] $
            else UP = LevInd[ * ]

      endif else begin

         ;===============================================================
         ; Otherwise, use LEV to compute the UP array.
         ; 
         ; NOTE: Levels are given in FORTRAN convention:
         ;       Convert to IDL by subtracting 1
         ;===============================================================
         NewLev = NewLev( Sort( NewLev ) )

         ;-------------------------------------------------------------------
         ; Prior to 5/17/07:
         ; ### Leave this commented out ###
         ;; *** We can't handle these stupid multitracer diagnostics here
         ;; *** if they exceed GridInfo.LMX pseudo-levels. Warn and exit.
         ;if (max(NewLev) gt n_elements(LevInd)) then begin
         ;   message,"Don't you dare use a multitracer diagnostic!",/Continue
         ;   message,'You wanted to access a level higher than LMX.',  $ 
         ;       /INFO,/NONAME
         ;   message,'Aborting program execution.',/INFO,/NONAME
         ;   retall
         ;endif
         ;-------------------------------------------------------------------

         ; The MULTITRACER diagnostic are a vestige of the GISS model
         ; and ancient versions of GEOS-Chem.  For data blocks with more
         ; vertical levels than what is specified in GRIDINFO structure, 
         ; 99% of the time this is indicative that we have a tracer that
         ; is defined on the layer edges instead of at the layer centers.
         ; In this case, we now adjust MAXLEV and LEVIND to account for
         ; the extra levels and then use those to compute the UP array,
         ; (bmy, 5/18/07)
         if ( Max( NewLev ) gt N_Elements( LevInd ) ) then begin
            LDiff  = Max( NewLev ) - MaxLev 
            LevInd = [ LevInd, LevInd[MaxLev-1] + FindGen( LDiff ) + 1 ]
            MaxLev = MaxLev + LDiff
         endif

         UP = LevInd[ ( NewLev[0]-1 ) > 0 : ( NewLev[1]-1 ) < (MaxLev-1) ] 

      endelse

      ;==================================================================
      ; If LAT, LON, LEV, ALTRANGE, or PRANGE were not passed
      ; explicitly, then return the default values to the calling
      ; program.  Otherwise, do not modify the original values.
      ;==================================================================
      if ( N_Elements( Lat      ) eq 0 ) then Lat      = NewLat
      if ( N_Elements( Lon      ) eq 0 ) then Lon      = NewLon
      if ( N_Elements( Lev      ) eq 0 ) then Lev      = NewLev
      if ( N_Elements( AltRange ) eq 0 ) then AltRange = NewAltRange
      if ( N_Elements( PRange   ) eq 0 ) then PRange   = NewPRange

   endelse

   ;=====================================================================
   ; Now that we have computed the WE, SN, UP index arrays, extract the
   ; data region from the data cube.  Proceed one dimension at a time,  
   ; in order to avoid array subscript errors.
   ;
   ; WE, SN, and UP are "global" index arrays.  Thus for data blocks 
   ; that are smaller than global size, WE[0], SN[0], and UP[0] are 
   ; not necessarily zero.  Call ADJ_INDEX to adjust these indices 
   ; (and store them in separate index arrays) before selecting a 
   ; subset of the DATA array.
   ;
   ; NOTE: FIRST is in FORTRAN array notation, so we need to subtract 1.
   ; (but make sure it really is so ...)
   ;=====================================================================
   WE_Adj  = Adj_Index( WE, First[0]-1, GridInfo.IMX )
   SN_Adj  = Adj_Index( SN, First[1]-1, GridInfo.JMX )
   UP_Adj  = Adj_Index( UP, First[2]-1, MaxLev )

   NewData = Data   [ WE_Adj, *,      *      ]
   NewData = NewData[ *,      SN_Adj, *      ]
   NewData = NewData[ *,       *,     UP_Adj ]
   
   ;### Debug output (bmy, 2/19/99)
   if ( Debug ) then begin
      print, '### CTM_EXTRACT: WE    : ', WE
      print, '### CTM_EXTRACT: WE_Adj: ', WE_Adj
      print, '### CTM_EXTRACT: SN    : ', SN
      print, '### CTM_EXTRACT: SN_Adj: ', SN_Adj
      print, '### CTM_EXTRACT: UP    : ', UP
      print, '### CTM_EXTRACT: UP_Adj: ', UP_Adj
   endif

   ; get dimensions of data  (lon, lat, alt, time)
   S = Size( NewData, /N_Dimensions )
   if ( S eq 2 ) then begin    ; last filter removed one dim
      S = size(newdata, /Dimensions)
      NewData = Reform( NewData, S[0], S[1], 1 )
   endif
   S = Size( Newdata, /Dimensions )
   dim = [ S, 1 ]

   ;=====================================================================
   ; Compute totals and averages over selected dimensions
   ; Flag = 1 : longitude, 2 : latitude, 4 : altitude
   ; Any combination is possible
   ; DIMSHIFT keeps tracks of dimensions already lost
   ;
   ; NOTES: 
   ; (1 ) We do not have to call CTM_ADJ_INDEX here, since WE, SN, and
   ;       UP will be used to reference GRIDINFO.XMID, GRIDINFO.YMID,
   ;       and GRIDINFO.ZMID, which are of global size.
   ; (2 ) Add separate code for computing zonal means on the MOPITT
   ;       grid.  We have to exclude missing values from the total
   ;       or average of the data array (bmy, 11/14/02)
   ;=====================================================================
   DimShift = 0

   ;### Kludge for MOPITT grid -- since there are missing values we must
   ;### not include them into the total or zonal mean (bmy, 11/14/02)
   if ( ModelInfo.Name eq 'MOPITT' ) then begin

      ;-------------------------------------------------
      ; longitudinal total or average of MOPITT data?
      ;-------------------------------------------------
      if ( ( Flag AND 1 ) gt 0 ) then begin

         ; Create temporary arrays
         TmpData = FltArr( S[1], S[2] )
         GoodPts = FltArr( S[1], S[2] )
         
         ; Compute totals, excluding missing data 
         for L = 0L, S[2] - 1L do begin
         for J = 0L, S[1] - 1L do begin
         for I = 0L, S[0] - 1L do begin
            if ( NewData[I,J,L] gt -999L ) then begin
               TmpData[J,L] = TmpData[J,L] + NewData[I,J,L]
               GoodPts[J,L] = GoodPts[J,L] + 1e0
            endif
         endfor
         endfor
         endfor
         
         ; Compute zonal means -- avoid division by zero
         if ( ( Average AND 1 ) gt 0 ) then begin
            Ind = Where( GoodPts gt 0 )
            if ( Ind[0] ge 0 ) then TmpData[Ind] = TmpData[Ind] / GoodPts[Ind]

            Ind = Where( Fix( GoodPts ) eq 0 )
            if ( Ind[0] ge 0 ) then TmpData[Ind] = -999e0
         endif

         ; Reassign to NEWDATA and undefine the WE dimension
         NewData = Temporary( TmpData )
         WE      = -1L
      endif 

      ;-------------------------------------------------
      ; latitudinal total or average of MOPITT data?
      ;-------------------------------------------------
      if ( ( Flag AND 2 ) gt 0 ) then begin

         help, NewData

         ; Kludge: Assume MOPITT is a 3-D grid
         TmpData = FltArr( S[0], S[2] )
         GoodPts = FltArr( S[0], S[2] )
         
         ; Compute totals, excluding missing data 
         for L = 0L, S[2] - 1L do begin
         for J = 0L, S[1] - 1L do begin
         for I = 0L, S[0] - 1L do begin
            if ( NewData[I,J,L] gt -999L ) then begin
               TmpData[I,L] = TmpData[I,L] + NewData[I,J,L]
               GoodPts[I,L] = GoodPts[I,L] + 1e0
            endif
         endfor
         endfor
         endfor
         
         ; Compute zonal means -- avoid division by zero
         if ( ( Average AND 2 ) gt 0 ) then begin
            Ind = Where( GoodPts gt 0 )
            if ( Ind[0] ge 0 ) then TmpData[Ind] = TmpData[Ind] / GoodPts[Ind]

            Ind = Where( Fix( GoodPts ) eq 0 )
            if ( Ind[0] ge 0 ) then TmpData[Ind] = -999e0
         endif

         ; Reassign to NEWDATA and undefine the SN dimension
         NewData = Temporary( TmpData )
         SN      = -1L
      endif 

   endif $

   ;====================================================================
   ; Otherwise compute total/zonal means of normal CTM grids
   ;====================================================================
   else begin

      ; longitudinal total or average ?
      if ( ( Flag AND 1 ) gt 0) then begin
         NewData  = Total( NewData, 1 )
         Dim[0]   = 1
         DimShift = 1
         if ( ( Average AND 1 ) gt 0 ) then NewData = NewData / N_Elements(WE)
         WE       = -1L
      endif

      ; latitudinal total or average ?
      if ( ( Flag AND 2 ) gt 0 ) then begin
         NewData  = Total( NewData, 2 - DimShift )
         Dim[1]   = 1
         DimShift = DimShift+1
         if ( ( Average AND 2 ) gt 0 ) then NewData = NewData / N_Elements(SN)
         SN       = -1L
      endif
   
      ; altitude total or average ?
      if ( ( Flag AND 4 ) gt 0 ) then begin
         NewData = Total(NewData,3-DimShift)
         Dim[2]  = 1
         if ( ( Average AND 4 ) gt 0 ) then NewData = NewData / N_Elements(UP)
         UP      = -1L
      endif

   endelse

   ;=====================================================================
   ; X = index array of 1st dimension of NEWDATA
   ; Y = index array of 2nd dimension of NEWDATA
   ; Z = index array of 3rd dimension of NEWDATA
   ;=====================================================================
   X = -999
   Y = -999
   Z = -999

   if ( WE[0] ge 0 AND N_Elements( WE ) gt 1 ) then begin
      X = GridInfo.Xmid[ WE ]            
            
      if ( SN[0] ge 0 AND N_Elements( SN ) gt 1 )  then begin
         Y = GridInfo.YMid[ SN ]         

         if ( UP[0] ge 0 AND N_Elements( UP ) gt 1 ) $
            then Z = GridInfo.ZMid[ UP ]

      endif else begin

         if ( UP[0] ge 0 AND N_Elements( UP ) gt 1 ) $
            then Y = GridInfo.ZMid[ UP ]

      endelse                       

   endif else begin

      if ( SN[0] ge 0 AND N_Elements( SN ) gt 1 ) then begin
         X = GridInfo.YMid[ SN ]                
   
         if ( UP[0] ge 0 AND N_Elements( UP ) gt 1 ) $
            then Y = GridInfo.ZMid[ UP ]   

      endif else begin

         if ( UP[0] ge 0 AND N_Elements( UP ) gt 1 ) $
            then X = GridInfo.ZMid[ UP ]

      endelse                            

   endelse
   
   ;=====================================================================
   ; Call REFORM to get rid of extra dimensions and return
   ;=====================================================================
   if ( N_Elements( NewData ) gt 1 ) then NewData = Reform( NewData )

   return, NewData
end
