; $Id: regridv.pro,v 1.50 2002/05/24 14:10:17 bmy v150 $
;-------------------------------------------------------------
;+
; NAME:
;        REGRIDV  (function)
;
; PURPOSE:
;        Regrids a vertical profile of data from one
;        pressure grid to another.
;
; CATEGORY:
;        Regridding
;
; CALLING SEQUENCE:
;        RESULT = REGRIDV( DATA, [ P_OLD, [ P_NEW [ , KEYWORDS ] ] )
;
; INPUTS:
;        DATA -> the 1-D vertical column of data to be regridded
;
;        P_OLD -> The pressure centers (in mb) corresponding
;             to each element of DATA.  P_OLD is superseded by the 
;             ZEDGE_OLD keyword, which contains pressure-altitude 
;             edges that will be used to define the input grid.
;
;        P_NEW -> The pressure centers (in mb) that 
;             defines the grid onto which DATA will be placed.
;             P_NEW is superseded by the ZEDGE keyword, which 
;             contains pressure-altitude edges that will be
;             used to define the output grid.
;             
; KEYWORD PARAMETERS:
;        PSURF -> Vector containing [ PSURFACE(old), PSURFACE(new) ]
;             for the old and new grids.  If PSURF is passed as a
;             scalar, then the same surface pressure will be used
;             for both old and new grids.  Default is [ 1000.0, 1000.0 ].
;
;        ZEDGE_OLD -> Contains pressure-altitude edges (see Note #2 below) 
;             which define the input grid.  Input data is assumed to
;             be at the center point between successive 
;             pressure-altitude edges.
;
;        ZEDGE_NEW -> Contains pressure-altitude edges (see Note #2 below) 
;             which define the output grid.  Regridded data will be 
;             returned at the center point between successive
;             pressure-altitude edges.
;
;        MIN_VALID -> the minimum valid data value that shall be accepted.
;             Values lower than MIN_VALID will be assigned a value of 
;             MIN_VALID. Default is 0. (since this routine will be mostly
;             used to regrid concentration data which shouldn't become
;             negative).
;
;        MAX_VALID -> the maximum valid data value that shall be accepted.
;             (see MIN_VALID). Default for MAX_VALID is 9.99E30.
;
;        /VERBOSE -> Prints detailed information.
;        
;        /TOTAL -> If set, will return the total of regridded data
;              in each grid box, instead of the average.
;
;        N_BINS -> Specifies the number of bins in an intermediate
;              "fine" grid used for interpolating between the input and 
;              output grids.  The fine grid will contain N_BINS
;              equally spaced points between 0 and ZTOP km (pressure-alt
;              coordinates).  Default is 100.
;
;        ZTOP -> Upper limit in pressure-altitude for the number of
;              bins specified by the N_BINS keyword.  The default is
;              48 km.  Model grids with tops above 0.1 km will need to
;              have a higher value of ZTOP specified.
;
;        MISSING -> Value used to indicate "missing" data points
;              (i.e. data points that are not to be considered in 
;              further analysis).  Default is MIN_VALID.
; 
;        /NO_EXTRAPOLATION -> Will not extrapolate data beyond the 
;              of the grid specified by POLD (or, equivalently,
;              ZEDGE).  Data points higher than this will be treated
;              as "missing" data points and will be given the value
;              specified by the MISSING keyword.  This extrapolation
;              of data will be done automatically, unless the
;              /NO_EXTRAPOLATION keyword is set.
;
; OUTPUTS:
;        RESULT contains the regridded data.
;
; SUBROUTINES:
;
; REQUIREMENTS:
;        External subroutines required:
;        ------------------------------
;        PEDGE (function)
;        ZMID  (function)
;        ZSTAR (function)
;
; NOTES: 
;        (1) REGRIDV references routines in the TOOLS package.
; 
;        (2) Regridding is done in pressure-altitude units, which are
;            defined as:
;
;                 Z* = 16 * log10[ 1000 / P(mb) ]
;
;            which, by the laws of logarithms, is equivalent to:
;
;                 Z* = 48 - ( 16 * log10[ P(mb) ] ).
;
;        (3) REGRIDV only handles one column at a time.  One must loop 
;            over the surface grid boxes to process the entire globe.
;
;        (4) If the new grid has a higher top than the old grid,
;            a linear extrapolation of the data is attempted (unless
;            the /NO_EXTRAPOLATION keyword is set...see above!)  If
;            the extrapolated data at the top is lower than MIN_VALID,
;            these data are replaced by MIN_VALID.
;
;        (5) It is adviseable to call REGRIDV to do vertical
;            regridding before calling CTM_REGRID to do horizontal
;            regridding.
;
;        (6) The present algorithm is sure but slow.  To improve
;            execution time, decrease the value of N_BINS.  The
;            current value of NBINS=100 produces good results and is 
;            relatively fast.  
; 
;        (7) WARNING!  Repeated application of REGRIDV can produce a 
;            vertical profile that diverges from the original profile,
;            For example, if you do
; 
;                 D  = D0                    ; save for reference
;                 D1 = REGRIDV( D0, P0, P1 )
;                 D0 = REGRIDV( D1, P1, P0 ) ; one full cycle
;                 D1 = REGRIDV( D0, P0, P1 )
;                 D0 = REGRIDV( D1, P1, P0 ) ; two full cycles
;                 D1 = REGRIDV( D0, P0, P1 )
;                 D0 = REGRIDV( D1, P1, P0 ) ; three full cycles
;
;            then the peak value of D0 will be lower than the
;            original peak value in D.  Although, for most
;            applications, one does not need repeated
;            interpolation on the same array, the user should be
;            aware of this. (bmy, 6/17/99)
;      
; EXAMPLES:
;        (1) 
;        OldGrid = CTM_GRID( CTM_TYPE( 'GEOS1',   NLayers=20, Psurf=1000.0 ) ) 
;        NewGrid = CTM_GRID( CTM_TYPE( 'GISS_II', NLayers=9,  PSurf=1000.0 ) )
;        Data    = FLTARR( OldGrid.LMX ) + 1
;        NewData = REGRIDV( Data, OldGrid.PMID, NewGrid.PMID )
;        print, NewData
;            1.00000      1.00000      1.00000      1.00000      1.00000 
;            1.00000      1.00000      1.00000      1.00000
;
;            ; Regrids a vector containing all 1's from the 20-layer 
;            ; GEOS-1 grid to the 9-layer GISS-II grid.  Returns the 
;            ; average value in each GISS-II grid box.
;
;        (2) 
;        NewData = REGRIDV( Data, OldGrid.PMID, NewGrid.PMID, /Total )
;        print, NewData
;            10.2670      16.4270      27.5154      34.9076      32.8542 
;            27.7208      21.5606      16.4270      11.3204
;
;            ; Same grids as (1), but this time returns the total 
;            ; of data in each GISS-II grid box.  
;
;        (3)
;        NewData = REGRIDV( Data, OldGrid.PMID, ZEDGE_NEW=[ 0, 4, 8, 12 ]  )
;        print, Newdata
;            1.0000000       1.0000000       1.0000000
;
;            ; Same input grid as in (1), but this time returns
;            ; regridded data on a pressure-altitude grid with
;            ; centers at [ 2, 6, 10 ] km.
;
; MODIFICATION HISTORY:
;        bmy, 18 Jun 1999: VERSION 1.00
;        mgs, 21 Jun 1999: - minor header changes
;                          - replaced QUIET keyword by VERBOSE
;        bmy, 21 Jul 1999: VERSION 1.01
;                          - added /NO_EXTRAPOLATION and MISSING
;                            keywords
;        bmy, 05 Oct 1999: VERSION 1.43 
;                          - highlight debug output in boxes
;        bmy, 20 Oct 1999: VERSION 1.44
;                          - Change POLD to P_OLD and PNEW to P_NEW
;                          - Added ZEDGE_OLD keyword
;                          - Renamed ZEDGE keyword to ZEDGE_NEW
;                          - Added more debug output
;        bmy, 29 Jun 2000: VERSION 1.46
;                          - added ZTOP keyword to allow a higher
;                            model top altitude for CTM grids
;          
;-
; Copyright (C) 1999, 2000, Bob Yantosca, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author.
; Bugs and comments should be directed to bmy@io.harvard.edu
; with subject "IDL routine regridv"
;-------------------------------------------------------------


function RegridV, Data, P_Old, P_New,                                     $
                  PSurf=PSurf,         Missing=Missing,                   $    
                  ZEdge_Old=ZEdge_Old, ZEdge_New=ZEdge_New,               $
                  Verbose=Verbose,     Total=TTotal,                      $
                  Min_Valid=Min_Valid, Max_Valid=Max_Valid,               $
                  N_Bins=N_Bins,       No_Extrapolation=No_Extrapolation, $
                  ZTop=ZTop,           _EXTRA=e 
            
   ;====================================================================
   ; Error Checking / Keyword Settings
   ;====================================================================    
   FORWARD_FUNCTION PEdge, ZMid, ZStar

   ; Missing DATA vector
   if ( N_Elements( Data ) eq 0 ) then begin
      Message, 'Must supply the DATA vector!!', /Continue
      return, -1.0
   endif

   ; Missing P_OLD vector AND Missing ZEDGE_OLD keyword
   if ( N_Elements( P_Old ) eq 0 ) then begin
      if ( N_Elements( ZEdge_Old ) eq 0 ) then begin
         Message, 'Must supply either POLD or ZEDGE_OLD!!', /Continue
         return, -1.0
      endif
   endif

   ; Missing P_NEW vector AND Missing ZEDGE_NEW keyword
   if ( N_Elements( P_New ) eq 0 ) then begin
      if ( N_Elements( ZEdge_New ) eq 0 ) then begin
         Message, 'Must supply either PNEW or ZEDGE_NEW!!', /Continue
         return, -1.0 
      endif
   endif
      
   ; Other Keywords
   Verbose          = Keyword_Set( Verbose          )
   TTotal           = Keyword_Set( TTotal           )
   No_Extrapolation = Keyword_Set( No_Extrapolation )

   if ( N_Elements( N_Bins    ) ne 1 ) then N_Bins    = 100
   if ( N_Elements( Min_Valid ) ne 1 ) then Min_Valid = 0.
   if ( N_Elements( Max_Valid ) ne 1 ) then Max_Valid = 9.99E30
   if ( N_Elements( Missing   ) eq 0 ) then Missing   = Min_Valid
   if ( N_Elements( PSurf     ) eq 0 ) then PSurf     = [ 1000.0, 1000.0 ]
   if ( N_Elements( PSurf     ) eq 1 ) then PSurf     = [ PSurf,  PSurf  ]
   if ( N_Elements( ZTop      ) ne 1 ) then Ztop      = 48.0
   
   ;====================================================================
   ; OLDZMID  = Pressure-altitude centers of old grid
   ; OLDZEDGE = Pressure-altitude edges   of old grid
   ;
   ; Define OLDZMID and OLDZEDGE either from P_OLD or ZEDGE_OLD,
   ; whichever one is given.  ZEDGE_OLD will supersede P_OLD.
   ;====================================================================
   if ( N_Elements( ZEdge_Old ) gt 0 ) then begin
      OldZEdge = ZEdge_Old
      OldZMid  = ZMid( OldZEdge )
   endif else begin
      OldZEdge = ZStar( PEdge( P_Old, PSurf[0] ) )       
      OldZMid  = ZStar( P_Old                    )
   endelse

   ;====================================================================
   ; Interpolate data to a finer grid (from 0-48 km) using a cubic 
   ; spline fit.  The finer grid contains N_BINS grid boxes, equally 
   ; spaced in pressure-altitude coordinates.  
   ;
   ; Only do the cubic spline fit where FINEZMID <= MAX( OLDZMID ).
   ; 
   ; FINEZBINSIZE = Width of a fine grid box, in pressure-altitude
   ; FINEZMID     = Pressure-altitudes at fine grid box centers
   ; FINEZEDGE    = Pressure-altitudes at fine grid box edges
   ; FINEDATA     = Data interpolated from OLDGRID to the fine grid
   ;====================================================================   
   ;--------------------------------------------------------------------
   ; Prior to 6/29/00:
   ;FineZBinSize   = 48.0d0 / Double( N_Bins )
   ;--------------------------------------------------------------------
   FineZBinSize   = Double( ZTop ) / Double( N_Bins )
   FineZEdge      = ( FIndGen( N_Bins + 1 ) * FineZBinSize ) - 0.1
   FineZMid       = FineZEdge[ 0:N_Bins-1 ] + ( FineZBinSize / 2.0 )
   FineData       = FltArr( N_Elements( FineZMid ) )

   Ind1           = Where( FineZMid le Max( OldZMid ), CInd1 )
   Ind2           = Where( FineZMid gt Max( OldZMid ), CInd2 )

   Y2             = Spl_Init(   OldZMid, Data, /Double )
   
   ;--------------------------------------------------------------------
   ; Debug output...uncomment if necessary 
   ;help, OldZMid
   ;help, Data
   ;help, Y2
   ;--------------------------------------------------------------------

   FineData[Ind1] = Spl_Interp( OldZMid, Data, Y2, FineZMid[ Ind1 ], /Double )
   
   ;====================================================================   
   ; If /NO_EXTRAPOLATION is set, then truncate arrays so that they
   ; do not extend above the top edge of OLDGRID.  Also set CIND2
   ; to zero so that the following block of code is not executed.
   ;====================================================================   
   if ( No_Extrapolation ) then begin
      FineData = FineData[ Ind1 ]
      FineZMid = FineZMid[ Ind1 ]
      CInd2    = 0
   endif

   ;====================================================================   
   ; Extrapolate data for altitudes where FINEZMID > Max( OLDZMID )
   ;
   ; (1) Compute DX = the difference between DATA at the last two
   ;     points of the OLDZMID grid
   ;
   ; (2) Compute DZ = difference in pressure altitude at the last two
   ;     points of the OLDZMID grid
   ;
   ; (3) Compute the slope DX/DZ
   ;
   ; (4) Use the point-slope formula to continue the interpolation
   ;     onto the fine grid, for FINEZMID > OLDZMID
   ;====================================================================   
   if ( CInd2 gt 0 ) then begin
      N  = N_Elements( OldZMid ) - 1 
      Dz = OldZMid[ N ] - OldZMid[ N-1 ]  
      Dx = Data[ N ]    - Data[ N-1 ]    
      
      if ( Dz lt 1e-20 ) then begin
         Message, 'DZ is too small for extrapolation!', /Continue
         return, -1.0
      endif

      DxDz = Dx / Dz
      Z0   = FineZMid[ Ind1[ CInd1-1 ] ]
      X0   = FineData[ Ind1[ CInd1-1 ] ]

      for J = 0, N_Elements( Ind2 ) - 1 do begin
         Z1 = FineZMid[ Ind2[ J ] ]
         X1 = X0 + DxDz * ( Z1 - Z0 )

         FineData[ Ind2[ J ] ] = X1 > MIN_VALID

         Z0 = Z1
         X0 = X1
      endfor
   endif

   ;--------------------------------------------------------------------
   ; Debug output...uncomment if necessary (bmy, 10/5/99)
   ;plot, FineData, FineZMid, Color=1, thick=2, /Xstyle, /YStyle, $
   ;   Title='Fine data grid'
   ;oplot, [60, 180], [ OldZMid[ N ], OldZMid[ N ] ], Color=1
   ;dumstr = ''
   ;read,  dumstr
   ;--------------------------------------------------------------------

   ;====================================================================
   ; NEWZEDGE = pressure-altitude edges   of output grid
   ; NEWZMID  = pressure-altitude centers of output gridd
   ;
   ; Define NEWZEDGE and NEWZMID from either P_NEW or ZEDGE_NEW,
   ; whichever one is given.
   ;
   ; If ZEDGE_NEW is given, make sure NEWZEDGE starts at 0 km.
   ;====================================================================
   if ( N_Elements( ZEdge_New ) gt 0 ) then begin
      NewZEdge = Double( ZEdge_New )

      ; Comment out for now (bmy, 10/21/99)
      ;if ( NewZEdge[0] gt 0 ) then NewZEdge = [ 0, NewZEdge ]

      NewZMid = ZMid( NewZEdge )

   endif else begin
      NewZMid  = ZStar( P_New                    )
      NewZEdge = ZStar( PEdge( P_New, PSurf[1] ) )

   endelse

   ;--------------------------------------------------------------------
   ; Debug output...uncomment if necessary (bmy, 10/5/99)
   ;print, '### PSURF    : ', PSurf
   ;if ( N_Elements( P_NEW ) gt 0 ) then begin
   ;   print, '### PNEW     : ', P_New
   ;   print, '### PEDGE    : ', PEdge( P_New, PSurf[1] )
   ;endif
   ;print, '### NEWZEDGE : ', NewZEdge
   ;print, '### NEWZMID  : ', NewZMid
   ;--------------------------------------------------------------------

   ;====================================================================
   ; Loop over each of the fine grid boxes.  Place each fine grid
   ; box into the proper coarse grid box.  If a fine grid box should
   ; straddle the boundary between two coarse grid boxes, then compute
   ; the fraction 
   ;
   ; NEWDATA is the output data vector, on the grid specified by
   ; the NEWGRID structure.  NEWCOUNT is the number of fine grid
   ; boxes that occupy each of the coarse grid boxes from NEWGRID.
   ;====================================================================
   NewLevels = N_Elements( NewZMid )
   NewData   = DblArr( NewLevels ) 
   NewCount  = DblArr( NewLevels )
   N         = 0L

   ; Loop over number of output grid boxes
   for J = 0L, N_Elements( FineData ) - 1L do begin

      ; Parameters for fine grid
      FData       = Double( FineData[ J ]    )  
      Mid         = Double( FineZMid[ J ]    )
      Bot         = Double( FineZEdge[ J ]   )
      Top         = Double( FineZEdge[ J+1 ] )

      ; Parameters for output grid
      NewMid      = Double( NewZMid[ N ]     )
      NewBot      = Double( NewZEdge[ N ]    )
      NewTop      = Double( NewZEdge[ N+1 ]  )

      ; Take care of MIN_VALID and MAX_VALID
      if ( FData lt Min_Valid ) then FData = Min_Valid
      if ( FData gt Max_Valid ) then FData = Max_Valid

      ;-----------------------------------------------------------------
      ; Debug output...uncomment if necessary (bmy, 10/5/99)
      ;print, '########################################## J, N = ',  J, N
      ;print, '### Bot,    Mid,    Top   : ', Bot,    Mid,    Top
      ;print, '### NewBot, NewMid, NewTop: ', NewBot, NewMid, NewTop
      ;print, '### NewTop - NewBot       : ', NewTop - NewBot
      ;-----------------------------------------------------------------

      ;=================================================================
      ; "Outside" case
      ;
      ; This fine grid box lies totally outside the coarse grid box.
      ; Skip and go to the next fine grid box.
      ;=================================================================
      if ( Bot gt NewTop and Top gt NewTop ) then begin

         ;--------------------------------------------------------------
         ; Debug output...uncomment if necessary (bmy, 10/5/99)         
         ; print, '### SKIP THIS BOX!!!'
         ;--------------------------------------------------------------

         goto, NextJ
      endif

      ;=================================================================
      ; "Normal" case 
      ;
      ;  This fine grid box fits entirely within the coarse grid box 
      ;  NEWDATA[N].  Add the data from the fine grid box to 
      ;  NEWDATA[N].  Increment NEWCOUNT[N} by one whole grid box.
      ;=================================================================
      if ( Bot ge NewBot AND Top le NewTop ) then begin
         NewData[ N ]  = NewData[ N ] + FData 
         NewCount[ N ] = NewCount[ N ] + 1d0

         ;--------------------------------------------------------------
         ; Debug output...uncomment if necessary (bmy, 10/5/99)
         ;print, '### NORMAL: '
         ;print, '### ZMid, Data       : ', Mid, FData
         ;print, '### NewData[ N ],  N : ', NewData[ N ], N
         ;print, '### NewCount[ N ], N : ', NewCount[ N ], N
         ;--------------------------------------------------------------

         goto, NextJ
      endif
       
      ;=================================================================
      ; "Top" case
      ;
      ; Top edge out of bounds
      ;
      ; J           = Index for fine grid boxes 
      ;
      ; N           = Index for coarser grid boxes (e.g the 
      ;               grid that is specified by NEWGRID)
      ;
      ; BOTFRAC     = fraction of fine grid box J that is located 
      ;               within coarse grid box N
      ;
      ; TOPFRAC     = fraction of fine grid box J that is located
      ;               within coarse grid box N + 1
      ;
      ; NEWDATA[N]  = Regridded data that lies within the Nth
      ;               coarse grid box
      ; 
      ; NEWCOUNT[N] = Number of fine grid boxes that fit within
      ;               the Nth coarse grid box
      ;=================================================================
      if ( Top gt NewTop ) then begin

         ; Data from fine grid that falls into NEWGRID[ N ]
         BotFrac = ( NewTop - Bot ) / FineZBinSize 

         if ( BotFrac lt 0 ) then begin
            Message, 'ERROR!  Check PSURF!', /Continue
            print, BotFrac
            return, -1
         endif

         NewData[ N ]  = NewData[ N ] + ( FData * BotFrac )
         NewCount[ N ] = NewCount[ N ] + BotFrac

         ;--------------------------------------------------------------
         ; Debug output...uncomment if necessary (bmy, 10/5/99)
         ;print, '### Top OOB: NewTop - Bot: ', NewTop - Bot
         ;print, '### Top OOB: Frac        : ', BotFrac
         ;print, '### Top OOB: Data * Frac : ', FData * BotFrac
         ;print, '### Top OOB: Newdata,  N : ', NewData[ N ],   N
         ;print, '### Top OOB: Newcount, N : ', NewCount[ N ],  N
         ;print, '### Top OOB: Avg Data, N  : ', $
         ;   NewData[ N ] / NewCount[ N ], N
         ;--------------------------------------------------------------

         ; Go to the next higher grid box in NEWGRID!
         ; If we exceed the number of levels in NEWGRID, quit here!
         N  = N + 1L 
         if ( N gt NewLevels-1 ) then goto, Quit

         ; Data from fine grid that falls into NEWGRID[ N+1 ]
         TopFrac       = 1d0 - BotFrac
         NewData[ N ]  = NewData[ N ] + ( FData * TopFrac )
         NewCount[ N ] = NewCount[ N ] + TopFrac

         ;--------------------------------------------------------------
         ; Debug output...uncomment if necessary (bmy, 10/5/99)
         ;print
         ;print, '### Top OOB: Top - NewBot: ', Top - NewZEdge[ N ]
         ;print, '### Top OOB: Frac        : ', TopFrac
         ;print, '### Top OOB: Data * Frac : ', FData * TopFrac
         ;print, '### Top OOB: Newdata, N  : ', NewData[ N ],  N
         ;print, '### Top OOB: Newcount, N : ', NewCount[ N ], N
         ;--------------------------------------------------------------

         goto, NextJ
      endif

      ;=================================================================
      ; "Bottom" case
      ;
      ; Bottom edge out of bounds
      ;
      ; This case can happen for the first level 
      ;
      ; Compute the fraction of the fine grid box that falls into
      ; the coarse grid box
      ;=================================================================
      if ( Bot lt NewBot ) then begin
         BotFrac       = ( Top - NewBot ) / FineZBinSize 
         NewData[ N ]  = NewData[ N ] + ( FData * BotFrac )
         NewCount[ N ] = NewCount[ N ] + BotFrac

         ;--------------------------------------------------------------
         ; Debug output...uncomment if necessary (bmy, 10/5/99)
         ;print, '### Bot OOB: Top - NewBot : ', Top - NewBot
         ;print, '### Bot OOB: Frac         : ', BotFrac
         ;print, '### Top OOB: Data * Frac  : ', FData * BotFrac
         ;print, '### Bot OOB: Newdata,  N  : ', NewData[ N ],  N
         ;print, '### Bot OOB: Newcount, N  : ', NewCount[ N ], N
         ;--------------------------------------------------------------

         goto, NextJ
      endif

NextJ:     
      ;-----------------------------------------------------------------
      ; Debug output...uncomment if necessary (bmy, 10/5/99)
      ;dumstr = ''
      ;read, dumstr
      ;-----------------------------------------------------------------
   endfor

   ;====================================================================
   ; If /TTOTAL is set, then return the total of NEWDATA
   ; Otherwise, divide NEWDATA by NEWCOUNT to get the average
   ;
   ; Where NEWCOUNT = 0 denotes levels of NEWDATA where there are no 
   ; valid data points.  Set these levels to the "missing data" value,
   ; as specified in the MISSING keyword.
   ;====================================================================
Quit:
   if ( not TTotal ) then begin
      Ind1 = Where( NewCount gt 0.0 )
      if ( Ind1[0] ge 0 ) then NewData[Ind1] = NewData[Ind1] / NewCount[Ind1]   
      Ind2 = Inv_Index( Ind1, N_Elements( NewCount ) )
      if ( Ind2[0] ge 0 ) then NewData[Ind2] = Missing
   endif
  
   ;====================================================================
   ; If /VERBOSE is set, then echo totals by level to the user
   ;====================================================================
   if ( VERBOSE ) then begin
      for N = 0L, NewLevels-1 do begin
         S = 'Regridded Data for Level ' +                       $
            StrTrim( String( N+1, Format='(i3)' ), 2 ) + ' = ' + $
            StrTrim( String( Max( NewData[N] ), Format='(e13.6)' ), 2 )

         Message, S, /Info
      endfor
      S = 'Total of Regridded Data ' +                       $
            StrTrim( String( Total( NewData ), Format='(e13.6)' ), 2 )
      Message, S, /Info
   endif

   ;====================================================================
   ; Return regridded data to calling program
   ;====================================================================
   return, NewData

end

 
 
