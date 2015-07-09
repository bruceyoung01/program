; $Id: ctm_boxsize.pro,v 1.1.1.1 2003/10/22 18:06:01 bmy Exp $
;-------------------------------------------------------------
;+
; NAME:
;        CTM_BOXSIZE  (function)
;
; PURPOSE:
;        Computes the size of CTM grid boxes.
;
; CATEGORY
;        CTM tools
;
; CALLING SEQUENCE:
;        result = CTM_BOXSIZE( GRIDINFO [,RADIUS [,KEYWORDS] ] ) 
;
; INPUTS:
;        GRIDINFO -> the structure returned by function CTM_GRID,
;             which contains the following necessary fields:
;	      IMX   (int   ) -> Maximum I (longitude) dimension 
;             JMX   (int   ) -> Maximum J (latitude ) dimension
;             YMID  (fltarr) -> Array of latitude  centers
;
;        RADIUS -> The radius of the earth in km.  This may be 
;             passed as an input parameter, or can be specified via 
;             the GEOS_RADIUS, GISS_RADIUS, or FSU_RADIUS keywords.
;             As default, the GEOS value of 6375.0 km is used.
;
; OUTPUT:
;        CTM_BOXSIZE returns a 2-D (or 1D) array of CTM surface areas,
;        or a 3-D array for CTM grid box volumes.  The default unit 
;        is square kilometers or cubic kilometers.
;
; KEYWORD PARAMETERS:
;        /CM2 -> Return ctm surface areas in square centimeters.
;             [default: km^2].  NOTE: /CM2 is now deprecated, but
;             is kept for backward compatibility.
;
;        /M2 -> Return ctm_surface areas in square meters.
;             [default: km^2].  
;
;        /CM3 -> Return grid box volumes in cubic centimeters.  
;             [default: km^3].
; 
;        /M3 -> Return grid box volumes in cubic meters.  
;             [default: km^3].
;
;        /VOLUME -> Will cause CTM_BOXSIZE to return grid box volumes 
;             instead of grid box surface areas.
;       
;        GEOS_RADIUS -> selects GEOS value for earth radius (6375.0 km) 
;             [default]
;
;        GISS_RADIUS -> selects GISS value for earth radius (6371.4 km)
;
;        FSU_RADIUS -> selects FSU value for earth radius (6371.4 km)
;      
;        IJ, IL, JL -> determine which area shall be computed [default: IJ]
;             NOTE: IL computes area of southern boundary
;
;        XLEN, YLEN, ZLEN -> Returns length of linear segments 
;             (lat, lon, alt) to calling program.  If /CM2 or /CM3 is 
;             specified, then XLEN, YLEN, ZLEN will be in centimeters.
;             If /M2 or /M3 are specified, then XLEN, YLEN, ZLEN will
;             be in meters. (Default unit is km).
;
;        NO_2D -> return 1D vector instead of 2D array
;
;        LATIND -> for IL and JL: return result for given latitude index
;             [default is equator]. This implies NO_2D. The index must
;             be provided as FORTRAN index (e.g. 1..72).
; 
; SUBROUTINES:
;
; REQUIREMENTS:
;        CTM_GRID and CTM_TYPE must first be called in order to 
;        define the GRIDINFO structure.
;
;        uses CHKSTRU
;
; NOTES:
;
; EXAMPLES:
;        ; (1) Compute surface grid box areas for GISS II model in
;        ;     standard resolution (4x5):
;
;        Areakm2 = CTM_BOXSIZE( CTM_GRID( CTM_TYPE( 'GISS_II' ), /GISS )
;
;        ; (2) Compute ctm surface areas in cm2 for GEOS 4x5 grid, return
;        ;     a vector with 1 value per latitude :
;
;        ModelInfo = CTM_TYPE( 'GEOS1', res=4 )
;        GridInfo  = CTM_GRID( ModelInfo )
;        AreaCm2   = CTM_BOXSIZE( GridInfo, /GEOS, /cm, /NO_2D )
;
;        ; (3) Compute ctm grid box volumes in cm3 for GEOS 4x5 grid,
;        ;     and return a 3-D array
;
;        ModelInfo = CTM_TYPE( 'GEOS1', res=4 )
;        GridInfo  = CTM_GRID( ModelInfo )
;        VolumeCm3 = CTM_BOXSIZE( GridInfo, /GEOS, /Volume, /cm3 )
;        
;
; MODIFICATION HISTORY:
;        bmy, 27 Mar 1998: VERSION 1.00 (algorithm from mgs)
;        mgs, 27 Mar 1998: - added NO_2D keyword
;        mgs, 07 May 1998: VERSION 1.10
;                          - added IJ, IL, JL, LATIND, XLEN, 
;                            YLEN, and ZLEN keywords
;                          - corrected polar box sizes 
;                            (now uses gridinfo information)
;        mgs, 08 May 1998: - corrected latindex, now uses FORTRAN convention
;        mgs, 24 May 1998: - changed IL so it computes area of 
;                            southern boundary
;        mgs, 17 Nov 1998: - changed keywords GISS and GEOS to .._RADIUS
;        bmy, 27 Jul 1999: VERSION 1.42
;                          - updated comments
;        bmy, 27 Jan 2000: VERSION 1.45
;                          - added /CM and /M keywords,
;                            deprecated /CM2 and /M2 keywords.
;                          - now return a 3-D array for grid box volumes
;                          - updated comments
;
;-
; Copyright (C) 1998, 1999, 2000,
; Bob Yantosca and Martin Schultz, Harvard University.
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author to arrange payment.
; Bugs and comments should be directed to bmy@io.harvard.edu
; or mgs@io.harvard.edu with subject "IDL routine ctm_boxsize"
;-------------------------------------------------------------

pro use_ctm_boxsize
   print,'   Usage :'
   print,'      result = ctm_boxsize( GRIDINFO [,RADIUS [,keywords] ] )'
   print
   print,'   Inputs:'
   print,'      GRIDINFO -> the structure returned by function DEFINE_GRID'
   print,'      RADIUS   -> Optional: The radius of the earth in km. '
   print,'                  This may also be specified by /GISS or /GEOS'
   print,'   Keywords:'
   print,'      CM2      -> return ctm surface areas in square centimeters'
   print,'      M2       -> return ctm surface areas in square meters'
   print,'      CM3      -> return ctm box volumes   in cubic centimeters'
   print,'      M3       -> return ctm box volumes   in cubic meters'
   print,'      GEOS_RADIUS -> selects GEOS value for earth radius (6375.0 km) [default]'
   print,'      GISS_RADIUS -> selects GISS value for earth radius (6371.4 km)'
   print,'      FSU_RADIUS  -> selects FSU  value for earth radius (6371.4 km)'
   print,'      IJ, IL, JL  -> specify which area to compute'
   print,'      XLEN, YLEN, ZLEN -> return length of segments'
   print,'      NO_2D  -> return 1D vector instead of 2D array'
   print,'      LATIND -> (for IL and JL) return vector at given latitude only'
   print

   return
end
  


function ctm_boxsize, GridInfo,  Radius,                                  $
                      cm2=cm2, m2=m2, cm3=cm3, m3=m3,                     $
                      GEOS_RADIUS=GEOS, GISS_RADIUS=GISS, FSU_Radius=FSU, $
                      IJ=IJ, IL=IL, JL=JL, VOLUME=VOLUME,                 $
                      XLEN=Dx, YLEN=Dy, ZLEN=dz,                          $
                      NO_2D=NO_2D , LATIND=LATIND
   
   ; Return to caller if error
   on_error, 2

   ; Safety first!
   area = -1L
  
   ; External functions
   FORWARD_FUNCTION ChkStru

   ; Make sure at least the GridInfo structure is passed
   if ( N_Elements( GridInfo ) eq 0 ) then begin
      print, 'The GridInfo structure must be specified...'
      use_ctm_boxsize
      return, -1L
   endif

   ; determine which areas shall be computed
   IJ = keyword_set(IJ)
   IL = keyword_set(IL)
   JL = keyword_set(JL)
   VOLUME = keyword_set(VOLUME)


   ; only one mode is valid
   if (total([IJ,IL,JL,VOLUME]) gt 1) then begin
       print,'CTM_BOXSIZE: ** Conflicting arguments! ' + $
               'Only one of IJ, IL, JL, VOLUME allowed.'
       return,-1
   endif


   ; default to IJ if no mode given
   if (total([IJ,IL,JL]) eq 0) then IJ = 1

   ; vertical information needed ?
   vertical = (IL OR JL OR VOLUME)

   ; default latind(ex) if not passed (only used for NO_2D)
   if (n_elements(latind) eq 0) then latind = fix(gridinfo.jmx/2) $
   else no_2d = 1
   latind = (latind > 1) < gridinfo.jmx 
   lati = latind - 1 ; array index for IDL



   ; Make sure all the necessary fields are in the GridInfo structure!
   fields = ['IMX', 'JMX', 'YMID', 'YEDGE']
   if (vertical) then fields = [ fields , 'ZEDGE']

   if ( not chkstru( GridInfo, fields, /VERBOSE ) ) then begin
      use_ctm_boxsize
      return, -1
   endif

   ; Earth radius in km (default to GEOS value of 6375.0 km)
   if ( n_elements( RADIUS ) eq 0 ) then begin
      GEOS = keyword_set(GEOS)
      GISS = keyword_set(GISS)
      FSU  = Keyword_Set(FSU )
      if ( ( GEOS + GISS + FSU ) eq 0 ) then GEOS = 1
      if ( GISS ) then RADIUS = 6371.4
      if ( GEOS ) then RADIUS = 6375.0
      if ( FSU  ) then RADIUS = 6375.0
   endif
      
   ; Define scale factor to return in units of km, m, or cm
   ScaleFactor = 1.0
   if ( keyword_set( m2  ) OR Keyword_Set( m3  ) ) then ScaleFactor = 1e3  
   if ( keyword_set( cm2 ) OR Keyword_Set( cm3 ) ) then ScaleFactor = 1e5 
  
   ; ========================================================================  
   ; compute length of grid box edges. DX and DY are always computed,
   ; DZ only for IL or JL modes
   ; ========================================================================  
   ; Dx is the meridional (E-W) extent of the grid box in unit km, m, or cm
   ; dimension is JMX:
   ; Recall that the circumference of a parallel of latitude has to 
   ; be multiplied by the cosine of the latitude to take into account
   ; the Earth's curvature
   if (IL) then $
     Dx = RADIUS*2.*!PI * cos(GridInfo.Yedge*!PI/180.) / GridInfo.Imx $
   else $
     Dx = RADIUS*2.*!PI * cos(GridInfo.Ymid*!PI/180.) / GridInfo.Imx
   Dx = Dx * ScaleFactor

   ; Dy is the zonal (N-S) extent of the grid box in km
   ; dimension is JMX, because polar boxes may be smaller
   arg = ( GridInfo.Yedge-shift(GridInfo.Yedge,1) )(1:*)
   Dy = RADIUS * !PI / 180. * arg
   Dy = Dy * ScaleFactor

   ; Dz is altitude spans
   ; dimension is LMX
   if (vertical) then begin
      Dz = ( GridInfo.Zedge-shift(GridInfo.Zedge,1) )(1:*)
      Dz = Dz * ScaleFactor
   endif


   ; ========================================================================  
   ; Compute the area
   ; Use "dot product" multiplication to return a 2-D array!
   ; ========================================================================  
   if (IJ) then begin
      area = Dx * Dy                       ; dimension JMX
      if (not keyword_set(NO_2D)) then $
         area = ( fltarr( GridInfo.IMX ) + 1. ) # area
   endif

   if (IL) then begin
      area = Dx # transpose(Dz)            ; dimension JMX*LMX
      if (keyword_set(NO_2D)) then $
          area = reform(area(lati,*))
   endif

   if (JL) then begin
      area = Dy # transpose(Dz)            ; dimension JMX*LMX
      if (keyword_set(NO_2D)) then $
          area = reform(area(lati,*))
   endif

   if (VOLUME) then begin
      ; Prior to 1/27/2000:
      ;area = (Dx * Dy) # transpose(Dz)    ; dimension JMX*LMX

      ; This is the brute force way, but it returns 
      ; a 3-D array of grid box volumes (bmy, 1/27/2000)
      Area = FltArr( GridInfo.IMX, GridInfo.JMX, GridInfo.LMX )

      for L = 0L, GridInfo.LMX - 1L do begin
      for J = 0L, GridInfo.JMX - 1L do begin
         Area[*, J, L] = ( Dx[J] * Dy[J] ) * Dz[L] 
      endfor
      endfor
   endif
   
   return, area

end
