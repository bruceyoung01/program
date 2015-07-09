; $Id: get_geos5_press.pro,v 1.2 2008/03/24 14:51:19 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        GET_GEOS5_PRESS
;
; PURPOSE:
;        Returns zonal mean pressure edges and pressure centers
;        for the GEOS-5 grid (47 layers or 72 layers).  Because in
;        GEOS-5 we cannot compute the pressures at grid box edges
;        and centers, we must read them in from disk.
;
; CATEGORY:
;        GAMAP Internals, GAMAP Models & Grids
;
; CALLING SEQUENCE:
;        GET_GEOS5_PRESS, PEDGE, PMID [, Keywords ]
;
; INPUTS:
;        None
;
; KEYWORD PARAMETERS:
;        FILENAME -> Specifies the name of the file containing
;             average pressures on the GEOS-5 grid.  If FILENAME
;             is omitted, then GET_GEOS5_PRESS will use the default
;             filename: "pedge.geos5.{RESOLUTION}.year".  
;
;        NLAYERS -> Specifies the number of layers in the GEOS-5 
;             grid.  NLAYERS can be either 47 or 72.  Default is 47.
;
;        RESOLUTION -> Specifies the resolution of the GEOS-5 grid. 
;             Default is 4x5.
;
;        PSURF -> If specified, then PEDGE and PMID will be 1-D
;             vectors, with the surface pressure (i.e. PEDGE[0])
;             being closest to the passed value of PSURF. 
;
;        /VERBOSE -> Set this switch to toggle verbose output.
;
; OUTPUTS:
;        PEDGE -> Array (or vector if PSURF is specified) of pressures 
;             at GEOS-5 grid box edges.  The PEDGE values have been 
;             averaged over 12 months and also averaged over longitudes 
;             (i.e. zonal mean).
; 
;        PMID -> Array (or vector if PSURF is specified) of pressures 
;             at GEOS-5 grid box centers.  The pressures have been 
;             averaged over 12 months and also averaged over longitudes 
;             (i.e. zonal mean).
;
; SUBROUTINES:
;        External Subroutines Required:
;        ===================================
;        CTM_GET_DATA   CTM_TYPE (function) 
;
; REQUIREMENTS:
;        Requires routines from both GAMAP and TOOLS packages.
;
; NOTES:
;        (1) At present, we only have saved out a file containing
;            pressure edges from the GEOS-5 47-layer model.
;
; EXAMPLE:
;        (1)
;        GET_GEOS5_PRESS, PEDGE, PMID, RES=2
;
;             ; Returns pressues at grid box edges (PEDGE) and centers
;             ; (PMID) for the GEOS-5 47L model at 2 x 2.5 resolution.
;             ; PEDGE is a 2-D array of size 91x48.  PMID is also a
;             ; 2-D array of size 91x47.
;
;        (2)
;        GET_GEOS5_PRESS, PEDGE, PMID, RES=2, PSURF=1000.0
;
;             ; Returns pressues at grid box edges (PEDGE) and centers
;             ; (PMID) for the GEOS-5 47L model at 2 x 2.5 resolution.
;             ; for the column with the closest surface pressure to
;             ; PSURF=1000 hPa.  PEDGE is a 1-D vector w/ 48 elements.  
;             ; PMID is also a 1-D vector w/ 47 elements.
;
; MODIFICATION HISTORY:
;  bmy & phs, 20 Jun 2007: GAMAP VERSION 2.10
;        phs, 25 Feb 2008: - check on File_Which output
;
;-
; Copyright (C) 2007, 
; Bob Yantosca, and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of this 
; software. If this software shall be used commercially or sold as 
; part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.as.harvard.edu with subject "IDL routine get_geos5_press"
;-----------------------------------------------------------------------
 

pro Get_Geos5_Press, Pedge,             PMid,                  $
                     FileName=FileName, Resolution=Resolution, $
                     NLayers=NLayers,   PSurf=PSurf,           $
                     Verbose=Verbose,   _EXTRA=e
 
   ;====================================================================
   ; Initialization
   ;====================================================================
 
   ; External functions
   FORWARD_FUNCTION CTM_Type, File_Exist

   ; Turn on verbose output?
   Verbose = Keyword_Set( Verbose )
 
   ; Default # of levels and resolution
   if ( N_Elements( NLayers    ) eq 0 ) then NLayers    = NLayers
   if ( N_Elements( Resolution ) eq 0 ) then Resolution = 4
 
   ; Make a MODELINFO structure
   if ( NLayers eq 47 )                                      $
      then InType = CTM_Type( 'GEOS5_47L', Res=Resolution )  $
      else InType = CTM_Type( 'GEOS5',     Res=Resolution )
 
   ; Default filename for either 47L or 72L grid
   if ( N_Elements( FileName ) eq 0 ) then begin

      ; Define default file name
      FileName = 'pedge.' + StrLowCase( InType.Name ) + $
                 '.'      + CTM_ResExt( InType      ) + '.sav'

      ; First look for the file name in the current directory, then
      ; if not found, then search all directories in the !PATH variable
      FileName = File_Which( FileName, /Include_Current_Dir )

   endif
   
   ; Verbose output
   if ( Verbose ) then Message, 'Reading ' + FileName,  /Info

   ;====================================================================
   ; Get GEOS-5 level edge pressures and level center pressures
   ;====================================================================

   ; Error check - now check for Null string that can be returned by
   ;               FILE_WHICH (phs, 2/21/08)
   if ( not File_Exist( FileName ) or StrLen( FileName ) eq 0 ) $
      then Message, 'Could not find file containing PEDGE data!'

   ; Use IDL restore to read in the PEDGE data.  This avoids the problem 
   ; of reading 2 files at once with the CTM_GET_DATA subroutine.
   Restore, FileName

   ; Get the dimensions of PEDGE
   S     = Size( PEdge, /Dim )

   ; Error check size of the array
   if ( N_Elements( S ) ne 2 ) then Message, 'PEDGE must be a 2-D array!'

   ; Get annual zonal mean pressure centers
   PMid  = 0.5e0 * ( PEdge[*,0:S[1]-2] + PEdge[*,1:S[1]-1] ) 
 
   ;====================================================================
   ; If PSURF is passed, then return the GEOS-5 level edge and level
   ; center pressures of the column where the surface pressure from
   ; the file is closest to the value of PSURF.
   ;====================================================================

   if ( N_Elements( PSurf ) gt 0 ) then begin
      
      ; Locate the column where the surface pressure 
      ; is closest to the requested value PSURF
      Press    = Abs( PEdge[*,0] - PSurf )
      MinPress = Min( Press )
      Ind      = Where( Press eq MinPress )

      ; Return PEDGE and PMID as a column such that 
      ; surface pressure is closest to PSURF
      if ( Ind[0] ge 0 ) then begin
         PEdge = Reform( PEdge[Ind,*] )
         PMid  = Reform( PMid[Ind,*]  )
      endif
   endif

end
