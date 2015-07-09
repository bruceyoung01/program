; $Id: geteta.pro,v 1.1.1.1 2007/07/17 20:41:46 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        GETETA
;
; PURPOSE:
;        Defines the eta levels for the various hybrid model grids.
;        GETETA is called by function CTM_GRID.
;
; CATEGORY:
;        GAMAP Internals
;
; CALLING SEQUENCE:
;        RESULT = GETETA( MNAME [, NLAYERS [, Keywords ] ] )
;
; INPUTS:
;        MNAME -> The name of the model for which eta level
;             information is desired ('GEOS4' or 'GEOS4_30L').
;
;        NLAYERS -> Specifies the number of eta layers for the 
;             model type.  Default is 55 layers.
;
; KEYWORD PARAMETERS:
;        PSURF -> Surface pressure in mb.  If PSURF is not specified,
;             GETETA will use 984.0 mb, which is the globally-averaged
;             surface pressure (this takes the terrain into account).
;
;        /CENTER -> Returns to the calling program an array 
;             containing the eta centers (i.e. eta at box centers).
;
;        /EDGES -> Returns to the calling program an array 
;             containing the eta edges (i.e eta at box edges).
;
; OUTPUTS:
;        RESULT -> contains the array of eta edges (if /EDGES is
;             set), or eta centers (if /CENTERS is set).
;
; SUBROUTINES:
;        None
;
; REQUIREMENTS:
;        Called by CTM_GRID.PRO
;
; NOTES:
;        Supported models:
;        ----------------------------------------------------
;        (1 ) GCAP,         23-layer (name: "GCAP"         )
;        (1 ) GEOS-4,       55-layer (name: "GEOS4"        )
;        (2 ) GEOS_4        30-layer (name: "GEOS4_30L"    )
;        (3 ) GISS_II_PRIME 23-layer (name: "GISS_II_PRIME")
;        (4 ) MATCH         52-layer (name: "MATCH"        )
;
;        For GEOS-5 we have to read the pressure edges from disk,
;        as it is not possible to construct this from an equation
;        with A's and B's, as is done for the above models.
;
; EXAMPLE:
;        EETA = GETETA( 'GEOS4' PSURF=984.0, /EDGES );
;             ; assigns GEOS-1 eta edges to array EETA
;
;        CETA = GETETA( 'GEOS4', /CENTER )
;             ; assigns GISS-II eta centers to array CETA
;
; MODIFICATION HISTORY:
;        bmy, 06 Nov 2001: GAMAP VERSION 1.49
;                          - based on routine "getsigma.pro"
;        bmy, 04 Nov 2003: GAMAP VERSION 2.01
;                          - now supports "GEOS4_30L" grid
;                          - now tests for model name using STRPOS 
;                            instead of just a straight match
;                          - stop w/ an error for non-hybrid grids
;                          - now supports 23-layer GISS_II_PRIME model
;                          - now supports 52-layer MATCH model
;        bmy, 18 Jun 2004: GAMAP VERSION 2.02a
;                          - now supports GCAP 23-layer hybrid grid
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
;                          - Updated comments
;
;-
; Copyright (C) 2001-2007, 
; Bob Yantosca and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of this 
; software. If this software shall be used commercially or sold as
; part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.as.harvard.edu with subject "IDL routine geteta"
;-----------------------------------------------------------------------


function GetEta, MName, NLayers, PSurf=PSurf, Center=Center, Edges=Edges
 
   ; Keyword settings
   Edges  = Keyword_Set( Edges  )
   Center = Keyword_Set( Center )

   ; Default: pick centers
   if ( Center + Edges eq 0 ) then Center = 1 

   ; Use global average surface pressure if PSURF is not passed
   if ( N_Elements( PSurf ) ne 1 ) then PSurf = 984.0
 
   ; Save model name
   ModelName = StrUpCase( StrTrim( MName, 2 ) )

   ;====================================================================
   ; GEOS-4 model  
   ;====================================================================  
   if ( StrPos( ModelName, 'GEOS4' ) ge 0 ) then begin
 
      ; Model top pressure [hPa]
      PTop = 0.01
 
      ; Set default # of model layers
      if ( N_Elements( NLayers ) ne 1 ) then NLayers = 55
 
      ;-------------------------
      ; 55 vertical layer grid
      ;-------------------------
      if ( NLayers eq 55 ) then begin
 
         ; A parameter [hPa]
         A = [   0.000000,      0.000000,     12.704939,     35.465965, $ 
                66.098427,    101.671654,    138.744400,    173.403183, $
               198.737839,    215.417526,    223.884689,    224.362869, $ 
               216.864929,    201.192093,    176.929993,    150.393005, $ 
               127.837006,    108.663429,     92.365662,     78.512299, $ 
                66.603378,     56.387939,     47.643932,     40.175419, $ 
                33.809956,     28.367815,     23.730362,     19.791553, $ 
                16.457071,     13.643393,     11.276889,      9.292943, $ 
                 7.619839,      6.216800,      5.046805,      4.076567, $ 
                 3.276433,      2.620212,      2.084972,      1.650792, $ 
                 1.300508,      1.019442,      0.795134,      0.616779, $ 
                 0.475806,      0.365041,      0.278526,      0.211349, $ 
                 0.159495,      0.119703,      0.089345,      0.066000, $ 
                 0.047585,      0.032700,      0.020000,      0.010000 ]
         
         ; B parameter [unitless]
         B = [   1.000000,      0.985110,      0.943290,      0.867830, $ 
                 0.764920,      0.642710,      0.510460,      0.378440, $ 
                 0.270330,      0.183300,      0.115030,      0.063720, $ 
                 0.028010,      0.006960,      0.000000,      0.000000, $ 
                 0.000000,      0.000000,      0.000000,      0.000000, $ 
                 0.000000,      0.000000,      0.000000,      0.000000, $ 
                 0.000000,      0.000000,      0.000000,      0.000000, $ 
                 0.000000,      0.000000,      0.000000,      0.000000, $ 
                 0.000000,      0.000000,      0.000000,      0.000000, $ 
                 0.000000,      0.000000,      0.000000,      0.000000, $ 
                 0.000000,      0.000000,      0.000000,      0.000000, $ 
                 0.000000,      0.000000,      0.000000,      0.000000, $ 
                 0.000000,      0.000000,      0.000000,      0.000000, $ 
                 0.000000,      0.000000,      0.000000,      0.000000 ]

      ;-------------------------
      ; 30-layer vertical grid
      ;-------------------------
      endif else if ( NLayers eq 30 ) then begin

         ; A parameter [hPa]
         A = [   0.000000,      0.000000,     12.704939,     35.465965, $
                66.098427,    101.671654,    138.744400,    173.403183, $
               198.737839,    215.417526,    223.884689,    224.362869, $
               216.864929,    201.192093,    176.929993,    150.393005, $
               127.837006,    108.663429,     92.365662,     78.512299, $
                56.387939,     40.175419,     28.367815,     19.791553, $
                 9.292943,      4.076567,      1.650792,      0.616779, $
                 0.211349,      0.066000,      0.010000 ]

         ; B parameter [unitless]
         B = [   1.000000,      0.985110,      0.943290,      0.867830, $
                 0.764920,      0.642710,      0.510460,      0.378440, $
                 0.270330,      0.183300,      0.115030,      0.063720, $
                 0.028010,      0.006960,      0.000000,      0.000000, $
                 0.000000,      0.000000,      0.000000,      0.000000, $
                 0.000000,      0.000000,      0.000000,      0.000000, $
                 0.000000,      0.000000,      0.000000,      0.000000, $
                 0.000000,      0.000000,      0.000000 ]

      endif

   endif $

   ;====================================================================
   ; GISS-II-PRIME model or GCAP model
   ;====================================================================  
   else if ( StrPos( ModelName, 'GISS_II' ) ge 0   OR $
             StrPos( ModelName, 'GCAP'    ) ge 0 ) then begin

      ; Model top pressure [hPa]
      PTop = 150.0 

      ;-------------------------
      ; 23-layer vertical grid
      ;-------------------------      
      if ( NLayers eq 23 ) then begin

         ; A parameter [hPa]      
         A = [   0.000000,      4.316550,      9.892076,     17.985615, $
                29.676256,     49.280582,     74.460426,    100.539566, $
               120.503593,    132.913666,    142.446045,    150.000000, $
               116.999985,     86.199982,     56.200001,     31.599991, $
                17.800003,     10.000015,      4.630005,      1.459991, $
                 0.460999,      0.144989,      0.031204,      0.002075 ]

         ; B parameter [unitless]
         B = [   1.000000,      0.971223,      0.934053,      0.880096, $
                 0.802158,      0.671463,      0.503597,      0.329736, $
                 0.196643,      0.113909,      0.050360,      0.000000, $
                 0.000000,      0.000000,      0.000000,      0.000000, $
                 0.000000,      0.000000,      0.000000,      0.000000, $
                 0.000000,      0.000000,      0.000000,      0.000000 ] 
      endif

   endif $

   ;====================================================================
   ; NCAR MATCH model
   ;====================================================================  
   else if ( StrPos( ModelName, 'MATCH' ) ge 0 ) then begin

      ; Model top pressure [hPa]
      PTop = 0.00468101 

      ;-------------------------
      ; 52-layer vertical grid
      ;-------------------------      
      if ( NLayers eq 52 ) then begin

         ; A parameter [hPa]
         A = [   0.000000,      0.000000,      2.521400,      7.085000, $
                13.344399,     20.847401,     29.089499,     37.521999, $
                44.689598,     50.782299,     55.961098,     60.363201, $
                64.105103,     67.285698,     69.989304,     72.287399, $
                74.240898,     75.901299,     77.312698,     78.512398, $
                66.403999,     55.882801,     46.794102,     38.988098, $
                32.322300,     26.662500,     21.884001,     17.872400, $
                14.523300,     11.743000,      9.447599,      7.562900, $
                 6.024000,      4.774300,      3.765000,      2.954300, $
                 2.306600,      1.791900,      1.385100,      1.065300, $
                 0.815300,      0.620800,      0.470400,      0.339000, $
                 0.232400,      0.151600,      0.094021,      0.057026, $
                 0.034588,      0.020979,      0.012724,      0.007718, $
                 0.004681 ]

         ; B parameter [unitless]
         B = [   1.000000,      0.985112,      0.953476,      0.896215, $
                 0.817677,      0.723535,      0.620120,      0.514317, $
                 0.424382,      0.347936,      0.282956,      0.227722, $
                 0.180772,      0.140864,      0.106941,      0.078106, $
                 0.053596,      0.032762,      0.015053,      0.000000, $
                 0.000000,      0.000000,      0.000000,      0.000000, $
                 0.000000,      0.000000,      0.000000,      0.000000, $
                 0.000000,      0.000000,      0.000000,      0.000000, $
                 0.000000,      0.000000,      0.000000,      0.000000, $
                 0.000000,      0.000000,      0.000000,      0.000000, $
                 0.000000,      0.000000,      0.000000,      0.000000, $
                 0.000000,      0.000000,      0.000000,      0.000000, $
                 0.000000,      0.000000,      0.000000,      0.000000, $
                 0.000000 ]

      endif

   endif $

   ;====================================================================
   ; Stop with error msg if this is not a hybrid grid
   ;====================================================================
   else begin
      
      S = MName + ' is not a hybrid grid!  Cannot compute ETA coordinates!'
      Message, S

   endelse
 
   ;====================================================================
   ; Compute the ETA coordinate for the given grid and layers.
   ;
   ; For hybrid grids, the pressure at the box edges is given by
   ;
   ;    PEDGE(L) = A(L) + ( B(L) * PSURF(L) )
   ;
   ; Where A(L) and B(L) are specified at the bottom edge of level L.
   ; These are constants chosen to provide for a hybrid sigma/pressure
   ; vertical coordinate.  PSURF is the surface pressure in mb.
   ;
   ; The pressure at the center of layer L is given as the average 
   ; of the pressures at the bottom edge of layer L and the top edge
   ; of layer L (which is also the bottom edge of layer L+1):
   ;
   ;    PCENTER(L) = ( PEDGE(L) + PEDGE(L+1) ) / 2
   ;
   ; From PEDGE and PCENTER, we can construct the unitless coordinate
   ; ETA (which is very similar to the sigma coordinate) as follows:
   ;
   ;    ETA_EDGE(L)   = ( PEDGE(L)   - PTOP ) / ( PSURF - PTOP ) 
   ;
   ;    ETA_CENTER(L) = ( PCENTER(L) - PTOP ) / ( PSURF - PTOP )
   ; 
   ; For GAMAP plotting routines, we will use the ETA coordinate for 
   ; hybrid models instead of the sigma coordinate.
   ;
   ; NOTE: For GEOS-5 you must call GET_GEOS5_PRESS to return the values 
   ; of EPRESS and CPRESS.  Then you must construct EETA and CETA from 
   ; EPRESS and CPRESS.  This is now done in routine "ctm_grid.pro". 
   ; (bmy, 5/22/07)
   ;====================================================================

   ; Overwrite NLAYERS w/ the number of layers for the grid 
   NLayers = N_Elements( A ) - 1L
      
   ; Compute pressure at box edges
   EPress = A + ( B * PSurf ) 

   ; Compute pressure at box centers
   N      = N_Elements( EPress )
   CPress = 0.5e0 * ( EPress[0:N-2] + EPress[1:N-1]) 
 
   ; Compute ETA on box edges
   if ( Edges  ) then Eta = ( EPress - Ptop ) / ( PSurf - Ptop )
 
   ; Compute ETA on box centers
   if ( Center ) then Eta = ( Cpress - Ptop ) / ( PSurf - Ptop )
 
   ; Return ETA to calling program
   return, Eta
   
end
