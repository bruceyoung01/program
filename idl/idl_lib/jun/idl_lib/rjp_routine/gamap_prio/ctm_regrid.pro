; $Id: ctm_regrid.pro,v 1.1.1.1 2003/10/22 18:06:02 bmy Exp $
;-------------------------------------------------------------
;+
; NAME:
;        CTM_REGRID  (function)
;
; PURPOSE:
;        Change 2-dimensional data fields from one grid to another.
;        Currently, only horizontal regridding is supported, and the
;        grid must be supported by CTM_Grid (this means especially that
;        it has to start at or near -180 longitude and be defined 
;        south to north).
;
;        An area weighted average is performed for all grid boxes
;        (unless the /NO_NORMALIZE keyword is set).
;
; CATEGORY:
;        CTM tools
;
; CALLING SEQUENCE:
;        NEWDATA = CTM_REGRID( DATA, OLDGRID, NEWGRID )
;
; INPUTS:
;        DATA -> the 2-D data field to be regridded.  Data can be
;             either in single-precision or double-precision.
;
;        OLDGRID, NEWGRID -> gridinfo structures (use ctm_grid to create
;             one) defining the old and new grid.
;
; KEYWORD PARAMETERS:
;        MIN_VALID -> the minimum valid data value that shall be accepted.
;             Values lower than MIN_VALID will be assigned a weight of 0.
;             If the total weigth for a resulting grid box is zero, it's
;             value will be set to -999. Default for MIN_VALID is 0.    
;
;        MAX_VALID -> the maximum valid data value that shall be accepted.
;             (see MIN_VALID). Default for MAX_VALID is 9.99E30 for
;             single precision, or 9.99D300 for double precision (if
;             the /DOUBLE keyword is set).
;
;        QUIET -> Suppresses printing of the maximum value in each
;              latitude band to the screen.
;
;        /DOUBLE -> Set this keyword to return NEWDATA as double-precision.
;              Default is to return NEWDATA as single-precision.
;
;        /NO_NORMALIZE -> Set this keyword to prevent CTM_REGRID from
;              normalizing weighting factors by grid box area.  This
;              is necessary if you are summing mass and not concentration.
;        
; OUTPUTS:
;        NEWDATA contains the regridded data.
;
; SUBROUTINES:
;        External subroutines required:
;        ---------------------------------------
;        CTM_INDEX       CTM_BOXSIZE (function)
;
; REQUIREMENTS:
;        References routines from the GAMAP & TOOLS packages.
;
; NOTES:
;        (1) As of 6/11/99, only works when going from a finer grid
;            to a coarser grid. 
;
;        (2) If you are regridding in terms of molecules or mass,
;            then it is recommended to use the /NO_NORMALIZE keyword
;            to prevent CTM_REGRID from performing an area-weighted
;            average.
;
; EXAMPLE:
;        OldType = CTM_Type( 'generic',   Res=[1.0, 1.0], $
;                            HalfPolar=0, Center180=0 )
;
;        OldGrid = CTM_Grid( OldGrid, /No_Vertical )
; 
;        NewGrid = CTM_Grid( CTM_Type( 'GEOS1', Res=4 ), /No_Vertical )
;
;        NewData = CTM_Regrid( OldData, OldGrid, NewGrid )
;
;             ; Regrids data from generic 1 x 1 grid (e.g. emissions
;             ; inventory style grid) edged on the date line to the
;             ; GEOS-1 4 x 5 grid.
;
; MODIFICATION HISTORY:
;        mgs, 02 Mar 1999: VERSION 1.00
;  mgs & bmy, 10 Jun 1999: - severe bug fix. Glad I wrote this 
;                            test_regrid routine ;-)
;                          - Added MIN_VALID and MAX_VALID keywords.
;        bmy, 11 Jun 1999: - added QUIET keyword
;                          - add error messages for XOVERLAP, YOVERLAP
;        bmy, 08 May 2000: VERSION 1.45
;                          - added /DOUBLE keyword for double precision data
;                          - added /NO_NORMALIZE keyword to prevent
;                            doing an area-weighted average
;                          - added some error checks 
;                          - cosmetic changes, updated comments
;
;-
; Copyright (C) 1999, 2000, 
; Martin Schultz and Bob Yantosca, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author to arrange payment.
; Bugs and comments should be directed to mgs@io.harvard.edu
; or bmy@io.harvard.edu with subject "IDL routine ctm_regrid"
;-------------------------------------------------------------


function CTM_Regrid, Data, OldGrid, NewGrid,                        $
                     MIN_VALID=MIN_VALID,      MAX_VALID=MAX_VALID, $
                     Quiet=Quiet,              Double=DDouble,      $
                     No_Normalize=No_Normalize

   ;=====================================================================
   ; regrids 2d (in the future also 3d) data from one grid to another.
   ; oldgrid and newgrid must be gridinfo structures (see ctm_grid.pro)
   ;
   ; the routine is relatively slow but save 
   ;=====================================================================
 
   ; External functions
   FORWARD_FUNCTION ChkStru, CTM_Boxsize
 
   ; Error checking
   if (n_params() ne 3) then begin
      message,'Must supply DATA,OLDGRID,NEWGRID!' ;,/Cont
      ;return, -1
   endif
   
   if ( not ChkStru( OldGrid, ['IMX', 'JMX'] ) ) then begin
      Message, 'OLDGRID is not a valid GRIDINFO structure!' ;, /Continue
      ;return, -1
   endif

   if ( not ChkStru( NewGrid, ['IMX', 'JMX'] ) ) then begin
      Message, 'NEWGRID is not a valid GRIDINFO structure!' ;, /Continue
      ;return, -1
   endif

   ; Make sure NEWGRID specifies a coarser grid than OLDGRID 
   ; (for the time being, CTM_REGRID can only go from fine to coarse!)
   if ( NewGrid.IMX gt OldGrid.IMX ) then begin
      S = 'NEWGRID cannot have a higher longitude resolution than OLDGRID!'
      Message, S, /Continue
      return, -1
   endif

   if ( NewGrid.IMX gt OldGrid.IMX ) then begin
      S = 'NEWGRID cannot have a higher latitude resolution than OLDGRID!'
      Message, S, /Continue
      return, -1
   endif

   ; Keyword settings
   Quiet        = Keyword_Set( Quiet   )
   DDouble      = Keyword_Set( DDouble )
   No_Normalize = Keyword_Set( No_Normalize )

   ; Set defaults for MIN_VALID & MAX_VALID for single & double precision
   if ( DDouble ) then begin
      if ( N_Elements( MIN_VALID ) ne 1 ) then MIN_VALID = 0.d0
      if ( N_Elements( MAX_VALID ) ne 1 ) then MAX_VALID = 9.99d300
   endif else begin
      if ( N_Elements( MIN_VALID ) ne 1 ) then MIN_VALID = 0.e0
      if ( N_Elements( MAX_VALID ) ne 1 ) then MAX_VALID = 9.99e30
   endelse

   ;=====================================================================
   ; can't use internal IDL rebin or congrid functions 
   ; because we need to take care of halfpolar boxes, and grid shifts ...
   ;=====================================================================

   ; Set RESULT to double precision by default.
   ; convert to single precision later if /DOUBLE Is not set
   Result = DblArr( NewGrid.IMX, NewGrid.JMX )

   ; get latitude box areas for old grid (to compute weighting factors)
   ; Also set OLDAREA to double precision for the internal computation
   oldarea = Double( ctm_boxsize(oldgrid, /NO_2D ) )

   oldxmax = n_elements(oldgrid.xmid)-1
   oldymax = n_elements(oldgrid.ymid)-1
 
   message,'starting regridding process ...',/INFO

   ;=====================================================================
   ; Loop through the target boxes (the "coarse" boxes of the new grid)
   ;=====================================================================
   for j = 0,newgrid.jmx-1 do begin
      for i = 0,newgrid.imx-1 do begin
         
         ; get old (fine) boxes that fit into new (coarse) box
         ; use ctm_index because it takes care of boxes spanning
         ; the dateline
         edge=[newgrid.yedge[j], newgrid.xedge[i], $
               newgrid.yedge[j+1],newgrid.xedge[i+1]]
         if (edge[1] lt -180.) then edge[1] = 360.+edge[1]
         if (edge[3] gt  180.) then edge[3] = edge[3]-360.
         ctm_index,oldgrid,edge=edge, $
            we=xind,sn=yind,/NON_INTERACTIVE
         
         if (xind[0] lt 0 OR yind[0] lt 0) then begin
            message,'Invalid indices !'
         endif
  
         ; WEIGHT is the array of weighting factors for the fine grid boxes
         ; Set WEIGHT to double precision for the internal computation
         Weight = DblArr( N_Elements( XInd ), N_Elements( YInd ) ) + 1d0

         ;===============================================================
         ; Loop over all of the old (fine) boxes 
         ; Compute overlap & weighting factors 
         ;===============================================================
         for jj=0,n_elements(yind)-1 do begin
            for ii = 0,n_elements(xind)-1 do begin                

               ; NX1 and NX2 are consecutive X-edges for the new grid
               nx1 = Double( newgrid.xedge[i]   )
               nx2 = Double( newgrid.xedge[i+1] )

               ; OX1 and OX2 are consecutive X-edges for the old grid
               ox1 = Double( oldgrid.xedge[xind[ii]]     )
               ox2 = Double( oldgrid.xedge[(xind[ii]+1)] ) ; < oldxmax ???

               ; convert to equivalent longitudes where necessary
               if (nx1 lt -90. AND sign(ox1) gt 0.) then nx1 = nx1 + 360.d0
               if (nx2 lt -90. AND sign(ox2) gt 0.) then nx2 = nx2 + 360.d0
               
               ; OV1 is the greater of OX1 and NX1
               ; OV2 is the lesser of OX2 and NX2
               ov1 = ox1 > nx1
               ov2 = nx2 < ox2 
               
               ; XOVERLAP is the % of the old (fine) grid box that  
               ; occupies the new (coarse) grid box in the X-direction.
               ; If XOVERLAP = 1.0 then the old grid box lies completely
               ; within the new grid box.
               xoverlap = (ov2-ov1)/(ox2-ox1)
                
               ; Error if XOVERLAP is > 1!!
               if ( Abs( XOverLap ) gt 1d0 OR XOverLap < 0d0 ) then begin
                  S = 'XOVERLAP (should be between 0 and 1 ) = ' + $
                     StrTrim( String( XOverLap ), 2 )
                  Message, S, /Continue
                  stop
               endif
                
               ; NY1 and NY2 are consecutive Y-edges for the new grid
               ny1 = Double( newgrid.yedge[j]   )
               ny2 = Double( newgrid.yedge[j+1] )

               ; OY1 and OY2 are consecutive Y-edges for the old grid
               oy1 = Double( oldgrid.yedge[yind[jj]]     )
               oy2 = Double( oldgrid.yedge[(yind[jj]+1)] ) ; < oldymax ???
               
               ; OV1 is the greater of OY1 and NY1
               ; OV2 is the lesser of OY2 and NY2
               ov1 = oy1 > ny1
               ov2 = ny2 < oy2 

               ; YOVERLAP is the % of the old (fine) grid box that 
               ; occupies the new (coarse) grid box in the Y-direction. 
               ; If YOVERLAP = 1.0 then the old grid box lies completely
               ; within the new grid box.
               yoverlap = (ov2-ov1)/(oy2-oy1)
 
               ; Error if YOVERLAP > 1!!
               if ( Abs( YOverLap ) gt 1 OR YOverLap < 0 ) then begin  
                  S = 'YOVERLAP (should be between 0 and 1 ) = ' + $
                     StrTrim( String( YOverLap ), 2 )
                  Message, S, /Continue
                  stop
               endif

               ; Get weighting factors.  The weighting factor is the 
               ; amount of the old (fine) grid box that lies within
               ; the new (coarse) grid box.  
               weight[ii, jj] = xoverlap*yoverlap  ;;; *latw[jj]

               ; If the data lies outside of the allowable range specified 
               ; by MIN_VALID and MAX_VALID, set its weight factor to zero.  
               ; This excludes it from the regridding.
               if (data[xind[ii], yind[jj]] lt MIN_VALID   OR $
                   data[xind[ii], yind[jj]] gt MAX_VALID ) then $
                  weight[ii, jj]= 0.d0
               
               ;-------------------------------------------------------------
               ; Debug output (bmy, 5/9/00)
               ;if ( J eq 22 and I eq 36 ) then begin
               ;   print, xind[ii], yind[jj], $
               ;          xoverlap, yoverlap, weight[ii, jj]
               ;endif
               ;-------------------------------------------------------------
            endfor

            ; If NO_NORMALIZE is not set, then normalize weighting 
            ; factors to the area of the old (fine) grid
            if ( No_Normalize eq 0 ) then begin
               weight[*,jj] = weight[*,jj] * oldarea[jj]
               tmp          = total(weight)
               weight       = weight/tmp
            endif
         endfor

         ; Multiply data from the old boxes by the appropriate
         ; weighting factor and sum together
         sum = 0d0
         for jj=0, N_Elements( YInd )-1 do begin
            for ii=0, N_Elements( Xind ) - 1 do begin
               if (data[xind[ii],yind[jj]] ge MIN_VALID  AND  $
                   data[xind[ii],yind[jj]] le MAX_VALID) then $
                  sum = sum + data[xind[ii],yind[jj]]*weight[ii,jj]  
            endfor
         endfor
         
         result[i,j] = sum

         ;-------------------------------------------------------------------
         ; Debug output (bmy, 5/8/00)
         ; print,'Total for grid box (I,J) = ',i,j,sum
         ; print,'i,j,edge,sum:',$
         ;     string(i,j,edge,sum,format='(2i5,4f8.2,f12.3)')
         ;-------------------------------------------------------------------

      endfor ; (i)

      ; Echo back some information to the screen
      if ( not Quiet ) then begin
         S = '(''Maximum for Latitude '',f7.2,'' (J = '', i3, '') = '',e13.6)'
         print, newgrid.ymid[j], j, max( result[*, j] ), Format=S
      endif
 
   endfor    ; (j)
 
   ; Return single precision if /DOUBLE is not set
   if ( not DDouble ) then Result = Float( Result )

   return, Result
end
 
 
