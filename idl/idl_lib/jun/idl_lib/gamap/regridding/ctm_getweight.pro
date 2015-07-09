; $Id: ctm_getweight.pro,v 1.2 2007/10/04 18:54:23 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        CTM_GETWEIGHT
;
; PURPOSE:
;        Computes the "mapping weights" for regridding data from
;        a "fine" CTM grid to a CTM grid of equal or coarser 
;        horizontal resolution.
;
; CATEGORY:
;        Regridding
;
; CALLING SEQUENCE:
;        CTM_GETWEIGHT, OLDGRID, NEWGRID, WEIGHT, XX_IND, YY_IND [, Keywords ]
;
; INPUTS:
;        OLDGRID -> GRIDINFO structure (use ctm_grid to create one) 
;             which defines the old ("fine") grid.
;
;        NEWGRID -> GRIDINFO structure (use ctm_grid to create one) 
;             which defines the new ("coarse") grid.
; 
;
; KEYWORD PARAMETERS:
;        WEIGHTFILE (optional) -> Name of the file to which WEIGHT,
;             XX_IND, and YY_IND will be written.  If WEIGHTFILE is
;             not given, then
;
; OUTPUTS:
;        WEIGHT -> Array of mapping weights which defines the fraction
;             of each "fine" grid box that fits into each "coarse" 
;             grid box.
;
;        XX_IND -> Array of "longitude" grid box indices of the "fine" 
;             grid boxes that fit into each "coarse" grid box.  
;
;        YY_IND -> Array of "latitude" grid box indices of the "fine" 
;             grid boxes that fit into each "coarse" grid box.
;
; SUBROUTINES:
;        External Subroutines Required:
;        ================================
;
; REQUIREMENTS:
;        References routines from both GAMAP and TOOLS packages.
;
; NOTES:
;        (1) This routine was adapted from CTM_REGRID.  It is
;            sometimes computationally expedient to compute the
;            mapping weights once for the entire horizontal grid 
;            and save them to a file for future use.
;            
;        (2) Right now this only works in regridding from a "fine" 
;            grid to a grid of equal horiziontal resolution (i.e. with
;            shifted grid boxes) or coarser horizontal resolution.
;
; EXAMPLE:
;        OLDTYPE = CTM_TYPE( 'GENERIC', RES=1, HALFPOLAR=0, CENTER180=0 )
;        OLDGRID = CTM_GRID( OLDTYPE, /NO_VERTICAL )
;        NEWTYPE = CTM_TYPE( 'GEOS4', RES=4 )
;        NEWGRID = CTM_GRID( NEWTYPE, /NO_VERTICAL )
;
;        CTM_GETWEIGHT, OLDGRID, NEWGRID, WEIGHT, XX_IND, YY_IND, $
;             WEIGHTFILE = 'weights.1x1.to.geos1.4x5']
;
;             ; Precomputes the mapping weights for regridding a
;             ; 1 x 1 grid to the GEOS-1 4 x 5 grid, and saves them
;             ; to an ASCII file named "weights.1x1.to.geos1.4x5"
;
; MODIFICATION HISTORY:
;        bmy, 11 Aug 2000: VERSION 1.01
;                          - adapted from CTM_REGRID
;        bmy, 21 Jan 2003: VERSION 1.02
;                          - Added fix for GEOS 1 x 1.25 grid
;        bmy, 04 May 2006: GAMAP VERSION 2.05
;                          - Added fix for GENERIC 2.5 x 2.5 grid
;        bmy, 29 Jun 2006: - Added fix for GEOS 1x1 -> GENERIC 1x1 
;  bmy & phs, 04 Oct 2007: GAMAP VERSION 2.10
;                          - added fix for GENERIC 0.5 x 0.5 grid
;                          - general fix for over-the-dateline cases
;
;-
; Copyright (C) 2000-2007, 
; Bob Yantosca and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of 
; this software. If this software shall be used commercially or 
; sold as part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.harvard.edu with subject "IDL routine ctm_getweight"
;-----------------------------------------------------------------------


pro CTM_GetWeight, OldGrid, NewGrid, Weight, XX_Ind, YY_Ind, $
                   WeightFile=WeightFile, Normalize=Normalize
 
   ; Find the max & min dimensions on old & new grids
   MaxSize   = Float( NewGrid.IMX > OldGrid.IMX )
   MinSize   = Float( NewGrid.IMX < OldGrid.IMX )

   ; Make space for # of small boxes that fit into the big box
   N_Points  = ( MaxSize / MinSize ) + 2

   ; Set MIN_VALID and MAX_VALID
   MIN_VALID = 0.e0
   MAX_VALID = 9.99e30
 
   ; Array of mapping weights
   Weight = FltArr( NewGrid.IMX, NewGrid.JMX, N_Points, N_Points )
   XX_Ind = IntArr( NewGrid.IMX, NewGrid.JMX, N_Points           )
   YY_Ind = IntArr( NewGrid.IMX, NewGrid.JMX, N_Points           )
 
   ; If we are writing output to a file, open the output file
   if ( N_Elements( WeightFile ) ne 0 ) then begin
      Open_File, WeightFile, Ilun, /Get_LUN, /Write
   endif
 
   ; If /NORMALIZE is set, then divide by the sum of the weights
   ; so that the total of all weights is 1.0
   Normalize = Keyword_Set( Normalize )

   ;=====================================================================
   ; Loop through the target boxes (the "coarse" boxes of the new grid)
   ;=====================================================================
   for j = 0, newgrid.jmx-1 do begin
      for i = 0, newgrid.imx-1 do begin
         
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
         
         ; Save loop limits
         N_X = N_Elements( XInd )
         N_Y = N_Elements( YInd )

         ;===============================================================
         ; Loop over all of the old (fine) boxes 
         ; Compute overlap & weighting factors 
         ;===============================================================
         for jj=0,n_elements(yind)-1 do begin
            for ii = 0,n_elements(xind)-1 do begin                
 
               ; Copy elements into XX_IND and YY_IND
               XX_Ind[I, J, II] = XInd[II]
               YY_Ind[I, J, JJ] = YInd[JJ]
 
               ; NX1 and NX2 are consecutive X-edges for the new grid
               nx1 = Double( newgrid.xedge[i]   )
               nx2 = Double( newgrid.xedge[i+1] )
 
               ; OX1 and OX2 are consecutive X-edges for the old grid
               ox1 = Double( oldgrid.xedge[xind[ii]]     )
               ox2 = Double( oldgrid.xedge[(xind[ii]+1)] )
 
               ; Deal with over-the-dateline cases (phs, 9/26/07)
               ; That fixes a problem when going from GEOS-5
               ; 0.66667 x 0.5 to GENERIC 1 x 1.
               ; Maybe it fixes also the kludges below ?? ## need checking 
               if ( ox2 lt nx1 ) then begin
                  ox1 = ox1 + 360.
                  ox2 = ox2 + 360.
               endif

               if ( ox1 gt nx2 ) then begin
                  ox1 = ox1 - 360.
                  ox2 = ox2 - 360.
               endif

               ; ## The later if-then seems to generalize the next step:

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
              
               ;### Kludge for GISS 4x5 or for FSU 4x5 (bmy, 2/26/02)
               if ( XOverLap eq -70.5 ) then $
                  if ( xx_ind[i, j, ii] eq 0 ) then XOverLap = 0.5d0
                  
               ;### Kludge for GEOS-3 1 x 1.25 (bmy, 1/15/03)
               if ( XOverLap eq -358.25 ) then $
                  if ( XX_Ind[I, J, II] eq 0 ) then XOverLap = 0.5d0

               ;### Kludge for GEOS 2.5 x 2.5 generic or
               ;### for GEOS 0.5 x 0.5 generic (bmy, 3/7/07)
               ;-----------------------------------------------------
               ; Prior to 3/7/07:
               ;if ( XOverLap eq -142.5 ) then $
               ;-----------------------------------------------------
               if ( XOverLap ge -145 and XOverLap le -142 ) then $
                  if ( XX_Ind[I, J, II] eq 0 ) then XOverLap = 0.5d0

               ;### Kludge for GEOS 1x1 to GENERIC 1x1 (bmy, 6/29/06)
               if ( XOverLap eq -358.5 ) then $
                  if ( XX_Ind[I, J, II] eq 0 ) then XOverLap = 0.5d0

               ; Error if XOVERLAP is > 1!!
               if ( Abs( XOverLap ) gt 1d0 OR XOverLap lt 0d0 ) then begin
                  S = 'XOVERLAP (should be between 0 and 1 ) = '       + $
                     StrTrim( String( XOverLap ), 2 ) + ' I,J,II,JJ: ' + $
                     StrTrim( String( I        ), 2 ) + ' '            + $
                     StrTrim( String( J        ), 2 ) + ' '            + $
                     StrTrim( String( II       ), 2 ) + ' '            + $
                     StrTrim( String( JJ       ), 2 ) + ' '  
                  Message, S, /Continue

                  ;### Debug output
                  ;print, '### ov1, ov2, ov2-ov1:', ov1, ov2, ov2-ov1
                  ;print, '### nx1, nx2,        :', nx1, nx2
                  ;print, '### ox1, ox2, ox2-ox1:', ox1, ox2, ox2-ox1
                  ;print, ox1, nx1, ov1
                  ;print, ox2, nx2, ov2
                  ;print, 'xind: ', xind
                  ;print, 'yind: ', yind
                  ;stop
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
                  S = 'YOVERLAP (should be between 0 and 1 ) = '       + $
                     StrTrim( String( YOverLap ), 2 ) + ' I,J,II,JJ: ' + $
                     StrTrim( String( I        ), 2 ) + ' '            + $
                     StrTrim( String( J        ), 2 ) + ' '            + $
                     StrTrim( String( II       ), 2 ) + ' '            + $
                     StrTrim( String( JJ       ), 2 ) + ' ' 
                  Message, S, /Continue
                  stop
               endif
 
               ; Get weighting factors.  The weighting factor is the 
               ; amount of the old (fine) grid box that lies within
               ; the new (coarse) grid box.  
               weight[i, j, ii, jj] = xoverlap*yoverlap  
            endfor
         endfor
 
         ;==============================================================
         ; Normalize by the sum of the weights, if necessary
         ;==============================================================
         if ( Normalize ) then begin

            ; Compute sum of all weights for box [I,J]
            Sum_Weights = 0d0
            for jj = 0L, N_Y - 1L do begin
            for ii = 0L, N_X - 1L do begin          
               Sum_Weights = Sum_Weights + Weight[I,J,II,JJ]
            endfor
            endfor

            ; Divide by the sum of the weights
            for jj = 0L, N_Y - 1L do begin
            for ii = 0L, N_X - 1L do begin          
               Weight[I,J,II,JJ] = Weight[I,J,II,JJ] / Sum_Weights 
            endfor
            endfor
         endif

         ;==============================================================
         ; Write output to a file if WEIGHTFILE was passed
         ;==============================================================
         if ( N_Elements( WeightFile ) ne 0 ) then begin
 
            ;Write "coarse" grid box indices to file
            PrintF, Ilun, I, J, Format='(2i4)'
         
            ; Write indices of boxes that fall into each 
            PrintF, Ilun, XX_Ind[I, J, *], Format='(3x,12i4)'         
            PrintF, Ilun, YY_Ind[I, J, *], Format='(3x,12i4)'
 
            ; Write Weights
            PrintF, Ilun, Weight[I, J, *, *], Format='(3x,12f6.2)' 
         endif
 
      endfor ; (i)
   endfor    ; (j)
 
   ; Close file
   if ( N_Elements( WeightFile ) ne 0 ) then begin
      Close,    Ilun
      Free_LUN, Ilun
   endif
 
   return
end
