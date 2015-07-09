; $Id: getsigma.pro,v 1.1.1.1 2007/07/17 20:41:46 bmy Exp $
;------------------------------------------------------------------------
;+
; NAME:
;        GETSIGMA (function)
;
; PURPOSE:
;        Defines the sigma levels for the various grids.
;        GETSIGMA is called by function CTM_GRID.
;
; CATEGORY:
;        GAMAP Internals
;
; CALLING SEQUENCE:
;        RESULT = GETSIGMA( MNAME [ NLAYERS [ , keywords ] ] )
;
; INPUTS:
;        MNAME -> The name of the model for which sigma level
;             information is desired (e.g. 'geos1', 'giss_ii', etc.)
;
;        NLAYERS -> Specifies the number of sigma layers for the 
;             GISS family of models.  Default is 9 layers.
;
; KEYWORD PARAMETERS:
;        CENTER -> Returns to the calling program an array 
;             containing the sigma centers. 
;
;        EDGES -> Returns to the calling program an array 
;             containing the sigma edges.
;
;        /HELP -> Prints a help screen and returns a value
;             of -1 to the calling program.
;
; OUTPUTS:
;        RESULT contains the array of sigma edges (if /EDGES is
;        set), or sigma centers (if /CENTERS is set).
;
; SUBROUTINES:
;
; REQUIREMENTS:
;
; NOTES:
;        Supported models:
;        -------------------------------------------------------
;        (1 ) GEOS-1     20-layer   (6 ) GEOS-3        30-layer
;        (2 ) GEOS-STRAT 46-layer   (7 ) GISS-II        9-layer    
;        (3 ) GEOS-STRAT 26-layer   (8 ) GISS-II-PRIME  9-layer 
;        (4 ) GEOS-2     70-layer   (9 ) GISS-II-PRIME 23-layer
;        (5 ) GEOS-2     47-layer   (10) FSU           14-layer   
;        (6 ) GEOS-3     48-layer   (11) MOPITT         7-layer
;
;        You can add more grids as is necessary.
;        
; EXAMPLE:
;        ESIG = GETSIGMA( 'GEOS1' /EDGES );
;           ; assigns GEOS-1 sigma edges to array ESIG
;
;        CSIG = GETSIGMA( 'GISS_II', 9, /CENTERS )
;           ; assigns GISS-II sigma centers (9 layer model) to array CSIG 
; 
; MODIFICATION HISTORY:
;        mgs, 02 Mar 1998: VERSION 1.00
;        bmy, 19 Jun 1998: - added dummy FSU sigma edges and centers
;                          - brought comments up to date
;        bmy, 16 Oct 1998: - added 26 layer GEOS-STRAT sigma levels
;        mgs, 25 Nov 1998: - improved defaulting of NLayers
;        bmy, 24 Feb 1999: - updated FSU sigma centers & edges
;                            with values provided by Amanda Staudt
;        bmy, 27 Jul 1999: GAMAP VERSION 1.42
;                          - added GISS-II-PRIME 23-layer sigma levels
;                          - updated comments, cosmetic changes
;        bmy, 16 May 2000: GAMAP VERSION 1.45
;                          - added GEOS-2 grids (47 and 70 layers)
;        bmy, 19 Jun 2000: - added GEOS-2 36 pressure-layer grid
;        bmy, 26 Jul 2000: GAMAP VERSION 1.46
;                          - added GEOS-3 grid (48 layers)
;        bmy, 26 Jul 2001: GAMAP VERSION 1.48
;                          - added GEOS-3 grid (30 layers, regridded)
;        bmy, 18 Dec 2003: GAMAP VERSION 2.01
;                          - Now recognizes GEOS3_30L grid name
;                          - Now sets 30 layers as default for GEOS3_30L
;                          - Removed HELP keyword, you can use usage.pro
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
;
;-
; Copyright (C) 1998-2007, Martin Schultz,
; Bob Yantosca, and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of this 
; software. If this software shall be used commercially or sold as
; part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.as.harvard.edu with subject "IDL routine getsigma"
;-----------------------------------------------------------------------


function getsigma,mname,nlayers,CENTER=CENTER,EDGES=EDGES
  
   ; default NLAYERS
   if (n_elements(NLAYERS) ne 1) then NLAYERS = -1
 
   ; set sigma levels depending on model type
 
   ;====================================================================
   ; GEOS-1 model
   ;====================================================================
   if (strupcase(mname) eq 'GEOS1') then begin

      ; 20 layer grid
      CSIG = [  .993936, .971301, .929925, .874137, .807833,  $
                .734480, .657114, .578390, .500500, .424750,  $
                .352000, .283750, .222750, .172150, .132200,  $
                .100050, .073000, .049750, .029000, .009500 ]
      
      ESIG = [ 1.000000, .987871, .954730, .905120, .843153,  $
                .772512, .696448, .617779, .539000, .462000,  $
                .387500, .316500, .251000, .194500, .149800,  $
                .114600, .085500, .060500, .039000, .019000,  $
                .000000 ]
 
   endif
 
   ;====================================================================
   ; GEOS-STRAT model
   ;==================================================================== 
   if (strupcase(mname) eq 'GEOS_STRAT') then begin
      if ( NLayers lt 0 ) then NLayers = 26 ; default to "chemistry"
      
      case ( NLayers ) of 

         ; 46-layer grid (original resolution)
         46: begin
            CSIG = [  .993935, .971300, .929925, .875060, .812500, $
                      .745000, .674500, .604500, .536500, .471500, $
                      .410000, .352500, .301500, .257977, .220273, $
                      .187044, .157881, .132807, .111722, .094035, $
                      .079233, .066873, .056574, .048012, .040910, $
                      .034927, .029792, .025395, .021663, .018439, $
                      .015571, .013036, .010808, .008864, .007181, $
                      .005737, .004510, .003480, .002625, .001928, $
                      .001369, .000929, .000593, .000344, .000167, $
                      .000047 ]
 
            ESIG = [ 1.000000, .987871, .954730, .905120, .845000, $
                      .780000, .710000, .639000, .570000, .503000, $
                      .440000, .380000, .325000, .278000, .237954, $
                      .202593, .171495, .144267, .121347, .102098, $
                      .085972, .072493, .061252, .051896, .044128, $
                      .037692, .032162, .027422, .023367, .019958, $
                      .016919, .014223, .011848, .009767, .007960, $
                      .006402, .005072, .003948, .003011, .002240, $
                      .001616, .001121, .000737, .000449, .000239, $
                      .000094, .000000 ]

         end

         ; 26-layer grid (vertically regridded resolution (
         26 : begin

            ESIG = [ 1.000000, .987871, .954730, .905120, .845000, $
                      .780000, .710000, .639000, .570000, .503000, $
                      .440000, .380000, .325000, .278000, .237954, $
                      .202593, .171495, .144267, .121347, .102098, $
                      .085972, .072493, .061252, .051896, .037692, $
                      .019958, .000000 ]
            
            CSIG = [  .993935, .971300, .929925, .875060, .812500, $
                      .745000, .674500, .604500, .536500, .471500, $
                      .410000, .352500, .301500, .257977, .220273, $
                      .187044, .157881, .132807, .111722, .094035, $
                      .079233, .066873, .056574, .044794, .028825, $
                      .009979 ]
         end

         else: begin
            Message, '** invalid number of layers for GEOS-STRAT model ! **', $
               /Info
         end
      endcase
   endif
 
   ;====================================================================
   ; GEOS-2 model (added by bmy, 1/3/00, 5/16/00)
   ;==================================================================== 
   if ( StrUpCase( MName ) eq 'GEOS2' ) then begin
      
      ; The 47 layer GEOS-2 grid is the operational grid
      if ( NLayers lt 0 ) then NLayers = 47
      
      case ( NLayers ) of 
         
         ; 47-layer grid (regridded resolution)
         47: begin
            ESIG = [ 1.000000e+00, 9.970951e-01, 9.914000e-01, 9.829000e-01, $
                     9.715000e-01, 9.570000e-01, 9.392300e-01, 9.179000e-01, $
                     8.927438e-01, 8.635700e-01, 8.303000e-01, 7.929700e-01, $
                     7.519437e-01, 7.078959e-01, 6.615992e-01, 6.138495e-01, $
                     5.654188e-01, 5.170351e-01, 4.694000e-01, 4.230300e-01, $
                     3.784500e-01, 3.360700e-01, 2.962800e-01, 2.595500e-01, $
                     2.262500e-01, 1.965500e-01, 1.703000e-01, 1.471300e-01, $
                     1.267550e-01, 1.088781e-01, 9.325208e-02, 7.963646e-02, $
                     6.781108e-02, 5.757372e-02, 4.872000e-02, 4.107631e-02, $
                     3.451000e-02, 2.891042e-02, 1.877039e-02, 1.218564e-02, $
                     7.909625e-03, 5.132859e-03, 3.329678e-03, 2.158725e-03, $
                     1.398330e-03, 9.045439e-04, 5.838880e-04, 0.000000e+00 ]

            CSIG = [ 9.985475e-01, 9.942475e-01, 9.871500e-01, 9.772000e-01, $
                     9.642500e-01, 9.481150e-01, 9.285650e-01, 9.053219e-01, $
                     8.781569e-01, 8.469350e-01, 8.116350e-01, 7.724569e-01, $
                     7.299198e-01, 6.847475e-01, 6.377244e-01, 5.896341e-01, $
                     5.412270e-01, 4.932176e-01, 4.462150e-01, 4.007400e-01, $
                     3.572600e-01, 3.161750e-01, 2.779150e-01, 2.429000e-01, $
                     2.114000e-01, 1.834250e-01, 1.587150e-01, 1.369425e-01, $
                     1.178165e-01, 1.010651e-01, 8.644427e-02, 7.372377e-02, $
                     6.269240e-02, 5.314686e-02, 4.489815e-02, 3.779315e-02, $
                     3.171021e-02, 2.329529e-02, 1.512403e-02, 9.817761e-03, $
                     6.371968e-03, 4.134332e-03, 2.681253e-03, 1.737650e-03, $
                     1.124892e-03, 7.269780e-04, 6.706442e-05 ]
         end

         ; 70-layer grid (original resolution)
         70: begin
            ESIG = [ 1.000000, 0.997095, 0.991400, 0.982900, 0.971500, $
                     0.957000, 0.939230, 0.917900, 0.892744, 0.863570, $ 
                     0.830300, 0.792970, 0.751944, 0.707896, 0.661599, $
                     0.613850, 0.565419, 0.517035, 0.469400, 0.423030, $
                     0.378450, 0.336070, 0.296280, 0.259550, 0.226250, $
                     0.196550, 0.170300, 0.147130, 0.126755, 0.108878, $
                     0.093252, 0.079636, 0.067811, 0.057574, 0.048720, $
                     0.041076, 0.034510, 0.028910, 0.024144, 0.020102, $
                     0.016686, 0.013808, 0.011392, 0.009370, 0.007683, $
                     0.006280, 0.005118, 0.004158, 0.003367, 0.002719, $
                     0.002188, 0.001755, 0.001403, 0.001118, 0.000888, $
                     0.000702, 0.000553, 0.000434, 0.000338, 0.000262, $
                     0.000202, 0.000155, 0.000118, 0.000089, 0.000066, $
                     0.000048, 0.000034, 0.000023, 0.000014, 0.000006, $
                     0.000000 ]

            CSIG = [ 0.998548, 0.994248, 0.987150, 0.977200, 0.964250, $
                     0.948115, 0.928565, 0.905322, 0.878157, 0.846935, $
                     0.811635, 0.772457, 0.729920, 0.684748, 0.637724, $
                     0.589634, 0.541227, 0.493218, 0.446215, 0.400740, $
                     0.357260, 0.316175, 0.277915, 0.242900, 0.211400, $
                     0.183425, 0.158715, 0.136943, 0.117817, 0.101065, $
                     0.086444, 0.073724, 0.062692, 0.053147, 0.044898, $
                     0.037793, 0.031710, 0.026527, 0.022123, 0.018394, $
                     0.015247, 0.012600, 0.010381, 0.008526, 0.006982, $
                     0.005699, 0.004638, 0.003763, 0.003043, 0.002453, $
                     0.001971, 0.001579, 0.001261, 0.001003, 0.000795, $
                     0.000628, 0.000494, 0.000386, 0.000300, 0.000232, $
                     0.000179, 0.000136, 0.000103, 0.000077, 0.000057, $
                     0.000041, 0.000028, 0.000018, 0.000010, 0.000003 ]

         end

         ; 36 pressure levels, converted to sigma levels
         ; Assuming a surface pressure of 1000 mb
         36: begin
            CSIG = [ 1.00000,    0.975000,    0.950000,    0.924999,   $
                     0.899999,   0.874999,    0.849998,    0.824998,   $
                     0.799998,   0.749997,    0.699997,    0.649997,   $
                     0.599996,   0.549995,    0.499995,    0.449995,   $
                     0.399994,   0.349993,    0.299993,    0.249993,   $
                     0.199992,   0.149992,    0.0999910,   0.0699907,  $
                     0.0499905,  0.0399904,   0.0299903,   0.0199902,  $
                     0.00999010, 0.00699007,  0.00499005,  0.00299003, $
                     0.00199002, 0.000990010, 0.000390004, 9.00009e-05 ]

            ; For now, just fake ESIG 
            ESIG = [ CSIG, 0.0 ]

         end
         
         else: begin
            Message, '** invalid number of layers for GEOS-2 model ! **', /Info
         end

      endcase
   endif

   ;====================================================================
   ; GEOS-3 model (added by bmy, 7/26/00)
   ;==================================================================== 
   if ( StrUpCase( MName ) eq 'GEOS3' OR $
        StrUpCase( MName ) eq 'GEOS3_30L' ) then begin
      
      ; The 48 layer GEOS-3 grid is the operational grid
      if ( NLayers lt 0 ) then NLayers = 48
    
      ; Default # of layers for GEOS3_30L model (bmy, 12/18/03)
      if ( StrUpCase( MName ) eq 'GEOS3_30L' and $
           NLayers lt 0 ) then NLayers = 30

      case ( NLayers ) of 
         
         ; 48-layer grid (original resolution)
         48: begin
            ESIG = [ 1.000000,    0.997095,    0.991200,    0.981500,    $
                     0.967100,    0.946800,    0.919500,    0.884000,    $
                     0.839000,    0.783000,    0.718200,    0.647600,    $
                     0.574100,    0.500000,    0.427800,    0.359500,    $
                     0.297050,    0.241950,    0.194640,    0.155000,    $
                     0.122680,    0.0969000,   0.0764800,   0.0603500,   $
                     0.0476100,   0.0375400,   0.0296000,   0.0233300,   $
                     0.0183800,   0.0144800,   0.0114050,   0.00897500,  $
                     0.00704000,  0.00550000,  0.00428000,  0.00330000,  $
                     0.00253000,  0.00190000,  0.00144000,  0.00106000,  $
                     0.000765000, 0.000540000, 0.000370000, 0.000245000, $
                     0.000155000, 9.20000e-05, 4.75000e-05, 1.76800e-05, $
                     0.00000 ]

            CSIG = [ 0.998548,    0.994148,    0.986350,    0.974300,    $
                     0.956950,    0.933150,    0.901750,    0.861500,    $
                     0.811000,    0.750600,    0.682900,    0.610850,    $
                     0.537050,    0.463900,    0.393650,    0.328275,    $
                     0.269500,    0.218295,    0.174820,    0.138840,    $
                     0.109790,    0.0866900,   0.0684150,   0.0539800,   $
                     0.0425750,   0.0335700,   0.0264650,   0.0208550,   $
                     0.0164300,   0.0129425,   0.0101900,   0.00800750,  $
                     0.00627000,  0.00489000,  0.00379000,  0.00291500,  $
                     0.00221500,  0.00167000,  0.00125000,  0.000912500, $
                     0.000652500, 0.000455000, 0.00030750,  0.000200000, $
                     0.000123500, 6.97500e-05, 3.25900e-05, 8.84000e-06 ]
         end

         
         ; 31-layer grid (regridded resolution)
         30: begin
            ESIG = [ 1.000000,    0.997095,    0.991200,    0.981500,    $
                     0.967100,    0.946800,    0.919500,    0.884000,    $
                     0.839000,    0.783000,    0.718200,    0.647600,    $
                     0.574100,    0.500000,    0.427800,    0.359500,    $
                     0.297050,    0.241950,    0.194640,    0.155000,    $
                     0.122680,    0.0969000,   0.0764800,   0.0476100,   $
                     0.0296000,   0.0183800,   0.00704000,  0.00253000,  $
                     0.000765000, 0.000155000, 0.00000 ]

            CSIG = [ 0.998548,    0.994148,    0.986350,    0.974300,    $
                     0.956950,    0.933150,    0.901750,    0.861500,    $
                     0.811000,    0.750600,    0.682900,    0.610850,    $
                     0.537050,    0.463900,    0.393650,    0.328275,    $
                     0.269500,    0.218295,    0.174820,    0.138840,    $
                     0.109790,    0.0866900,   0.0620450,   0.0386050,   $
                     0.0239900,   0.0127100,   0.00478500,  0.00164750,  $
                     0.000460000, 7.75000e-05 ]
         end

         else: begin
            Message, '** invalid number of layers for GEOS-3 model ! **', /Info
         end
      endcase
   endif

   ;====================================================================
   ; FSU model (added by bmy, 6/19/98)
   ;==================================================================== 
   if ( strupcase( MName ) eq 'FSU' ) then begin
 
      ; 14-layer grid
      ; Sigma edges and centers from acs (bmy, 2/24/99)
      ESIG = [ 1.000000, 0.980100, 0.920824, 0.879647, 0.821353, $ 
               0.779202, 0.628848, 0.572475, 0.436700, 0.366384, $
               0.245644, 0.162837, 0.085000, 0.050000, 0.000000 ]
      
      CSIG = [ 0.99, 0.95, 0.90, 0.85, 0.80, 0.70, 0.60, 0.50, $
               0.40, 0.30, 0.20, 0.10, 0.07, 0.03 ]
 
   endif
 
   ;====================================================================
   ; GISS-II and GISS-II-PRIME models
   ;==================================================================== 
   if (strupcase(mname) eq 'GISS_II' or   $
       strupcase(mname) eq 'GISS_II_PRIME') then begin
      
      ; check if NLAYERS was provided, if not return default of 9 layers
      if (NLAYERS lt 0) then nlayers = 9

      case ( NLAYERS ) of
         
         ; 9-layer grid
         9 : begin
            
            CSIG = [ 0.974333, 0.907598, 0.797741, 0.641684, 0.472279,  $
                     0.320842, 0.197638, 0.102669, 0.030801 ]
            
            ESIG = [ 1.000000, 0.948665, 0.866530, 0.728953, 0.554415,  $
                     0.390144, 0.251540, 0.143737, 0.061602, 0.000000 ]
            
         end
 
         ; 23-layer grid (added by bmy, 7/26/99)
         23: begin
            CSIG = [ 0.985611,   0.952638,   0.907074,   0.841127,   $
                     0.736811,   0.587530,   0.416667,   0.263189,   $
                     0.155276,   0.0821343,  0.0251799, -0.0197842,  $
                    -0.0580336, -0.0944844, -0.127218,  -0.150240,   $
                    -0.163189,  -0.171085,  -0.176205,  -0.178704,   $
                    -0.179493,  -0.179750,  -0.179836 ]
            
            ESIG = [ 1.000000,   0.971223,   0.934053,   0.880096,   $
                     0.802158,   0.671463,   0.503597,   0.329736,   $
                     0.196643,   0.113909,   0.0503597,  0.00000,    $
                    -0.0395683, -0.0764988, -0.112470,  -0.141966,   $
                    -0.158513,  -0.167866,  -0.174305,  -0.178106,   $
                    -0.179303,  -0.179682,  -0.179819,  -0.179854 ]
            
         end

         else : begin
            Message, '** invalid number of layers for GISS model ! **', /Info
         end
         
      endcase
      
   endif  ; GISS models
 
   ;====================================================================
   ; MOPITT grid (clh & bmy, 10/18/02)
   ;==================================================================== 
   if ( StrUpCase( MName ) eq 'MOPITT' ) then begin

      ; MOPITT levels (assumes 1000 hPa surface pressure)
      CSIG = [ 1.000000, 0.850000, 0.700000,           $
               0.500000, 0.350000, 0.250000, 0.150000 ]

      ; Set edges
      ESIG = CSIG

   endif

   ;====================================================================
   ; AIRS grid 
   ;==================================================================== 
   if ( StrUpCase( MName ) eq 'AIRS' ) then begin

      ; MOPITT levels (assumes 1000 hPa surface pressure)
      CSIG = fltarr(100)

      ; Set edges
      ESIG = fltarr(101)

   endif
 
   ; get number of layers from sigma arrays
   ; i.e. overwrite previous default
   NLAYERS = n_elements(CSIG)
 
   ; safety first: take care of NLAYERS = 0
   if (NLAYERS eq 0) then begin  
      CSIG=-1 & ESIG=-1 
   endif
 
   ; decide what to return
   if (keyword_set(EDGES)) then return,ESIG  $
   else return,CSIG
 
end
 
 
