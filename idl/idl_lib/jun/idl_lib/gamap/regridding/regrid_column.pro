; $Id: regrid_column.pro,v 1.1.1.1 2007/07/17 20:41:31 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        REGRID_COLUMN
;
; PURPOSE:
;        Vertically regrids a column quantity in such a way
;        as to preserve the total mass.
;
; CATEGORY:
;        Regridding
;
; CALLING SEQUENCE:
;        DATA2 = REGRID_COLUMN( DATA1, PEDGE1, PEDGE2 [, keywords ] )
;
; INPUTS:
;        DATA1 -> Column vector containing data on the original
;             grid.  DATA1 must be a mass-like quantity that does
;             not have any vertical dependence (e.g. molecules,
;             g, kg, kg/m2, molec/cm2, etc.) 
;
;        PEDGE1 -> Pressures [hPa] at the edges of each layer on 
;             the old vertical grid.  PEDGE1 will thus have one 
;             more element element than DATA1 (since DATA1 is 
;             specified on the midpoints of each layer).
;
;        PEDGE2 -> Pressures [hPa] at the edges of each layer on 
;             the new vertical grid.  PEDGE2 will thus have one 
;             more element element than DATA2 (since DATA2 is 
;             specified on the midpoints of each layer).
;
; KEYWORD PARAMETERS:
;        /DEBUG -> If set, will print debug information to the
;             screen, including totals before and after regridding.
;
;        /NO_CHECK -> If this keyword is set, then REGRID_COLUMN
;             will not check to see if the column sum was preserved
;             in going from the old grid to the new grid.  This is 
;             useful if you are regridding data from a grid with a
;             high model top to a grid with a lower model top 
;             (such as from GEOS-3 to GEOS-1).
;
; OUTPUTS:
;        DATA2 -> Column vector containing data on the new vertical 
;             grid.  The column sum of DATA2 will equal that of
;             DATA1. DATA2 will also be a mass-like quantity.
;
;
; SUBROUTINES:
;        None
;
; REQUIREMENTS:
;        None
;
; NOTES:
;        (1) Adapted from FORTRAN code by Amanda Staudt, Bob
;        Yantosca, and Dale Allen originally used to interpolate
;        GEOS-3 data from Pressure to Sigma coordinates.
;
;        (2) The algorithm is brute force, but it works for all 
;        kinds of grids.  It will even work for grids where the new
;        vertical resolution is smaller than the original vertical
;        resolution.
;
;        (3) Processes one column at a time.  For an entire lat/lon
;        region, you have to loop over each surface grid location
;        and call REGRID_COLUMN to process each column separately.
;
;        (4) Added /NO_CHECK keyword to facilitate regridding from
;        GEOS-3 to GEOS-1.  Otherwise, you should never use this
;        keyword.
;
; EXAMPLE:
; 
;        ; Surface pressure (assume same for both grids)
;        PSurf = 1000.0
;
;        ; Define Input grid -- use GAMAP routines
;        InType   = CTM_Type( 'GEOS_STRAT', res=2 )
;        InGrid   = CTM_Grid( InType )
;        InPEdge  = ( InGrid.SigEdge * ( PSurf - InType.PTOP ) ) + $
;                   Intype.PTOP
;        
;        ; Define Output grid -- use GAMAP routines
;        OutType  = CTM_Type( 'GEOS3', res=2, PSurf=1000.0 )
;        OutGrid  = CTM_Grid( OutType )
;        OutPEdge = ( OutGrid.SigEdge * ( PSurf - OutType.PTOP ) ) +
;                    OutType.PTOP
;
;        ; Assume INDATA is in [kg], OUTDATA will be too
;        OutData = Regrid_Column( InData, InPEdge, OutPEdge )
;
;             ; Regrid a column of mass from the 2 x 2.5
;             ; GEOS-STRAT grid to the 2 x 2.5 GEOS-3 grid
;
; MODIFICATION HISTORY:
;        bmy, 22 Jan 2002: TOOLS VERSION 1.50
;        bmy, 14 Mar 2002: - added /NO_CHECK keyword
;  bmy & phs, 20 Jun 2007: GAMAP VERSION 2.10
;
;-
; Copyright (C) 2002-2007, 
; Bob Yantosca, and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of this 
; software. If this software shall be used commercially or sold as 
; part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.as.harvard.edu with subject "IDL routine regrid_column"
;-----------------------------------------------------------------------


function Regrid_Column, Data1, PEdge1, PEdge2, Debug=Debug, No_Check=No_Check
 
   ;====================================================================
   ; Parameters and Keywords
   ;====================================================================
   if ( N_Elements( Data1  ) eq 0L ) then Message, 'DATA1 not passed!'
   if ( N_Elements( PEdge1 ) eq 0L ) then Message, 'PEDGE1 not passed!'
   if ( N_Elements( PEdge2 ) eq 0L ) then Message, 'PEDGE2 not passed!'
   Debug = Keyword_Set( Debug )
   Check = 1L - Keyword_Set( No_Check )

   ;====================================================================
   ; Initialize variables
   ;====================================================================
   LM1      = N_Elements( PEdge1 ) - 1L
   LM2      = N_Elements( PEdge2 ) - 1L
   Data2    = DblArr( LM2 ) 
   Fraction = Dblarr( LM1, LM2 )
   First    = 1L
   Valid    = 0L
 
   ;### Debug output
   if ( Debug ) then begin
      print, '### LM1, LM2: ', LM1,  LM2
      print, '### Input Pressure Edges'
      print, Pedge1
      print, '### Input Data'
      print, Data1
      print, '### Input Data: column sum'
      print, Total( Data1 )
      print, '### Input layer    Output layer    fraction'
   endif
 
   ;====================================================================
   ; Determine fraction of each INPUT box 
   ; which contributes to each OUTPUT box
   ;====================================================================
 
   ; Loop over INPUT layers
   for L = 0L, LM1 - 1L do begin
       
      ; Reset VALID flag
      Valid = 0L
 
      ; If the thickness of this pressure level is zero, then this 
      ; means that this pressure level lies below the surface 
      ; pressure (due to topography), as set up in the calling
      ; program.  Therefore, skip to the next INPUT level.
      ; This also helps avoid divide by zero errors. (bmy, 8/6/01)
      IF ( ( PEdge1[L] - Pedge1[L+1] ) lt 1e-5 ) then goto, NextL
 
      ; Loop over OUTPUT layers
      for K = 0L, LM2 - 1L do begin
                  
         ;==============================================================
         ; No contribution if:
         ; -------------------
         ; Bottom of OUTPUT layer above Top    of INPUT layer  OR
         ; Top    of OUTPUT layer below Bottom of INPUT layer
         ;==============================================================
         if ( PEdge2[K]   lt PEdge1[L+1]   OR $
              PEdge2[K+1] gt PEdge1[L]   ) then goto, NextK
 
         ;==============================================================
         ; Contribution if: 
         ; ----------------
         ; Entire INPUT layer in OUTPUT layer
         ;==============================================================
         if ( PEdge2[K]   ge PEdge1[L]     AND $
              PEdge2[K+1] le PEdge1[L+1] ) then begin
               
            Fraction[L,K] = 1d0
 
            ;### Debug output
            ;print, L, K, Fraction[L,K], 1, Format='(2i12,6x,f13.6,i2)'
 
            ; Indicate a valid contribution from L to K
            Valid = 1L
 
            ; Go to next iteration
            goto, NextK
         endif
           
         ;==============================================================
         ; Contribution if: 
         ; ----------------
         ; Top of OUTPUT layer in INPUT layer
         ;==============================================================
         if ( PEdge2[K+1] le PEdge1[L]   AND $
              PEdge2[K]   ge PEdge1(L) ) THEN begin
 
            Fraction[L,K] = ( PEdge1[L] - PEdge2[K+1] ) / $
                            ( PEdge1[L] - PEdge1[L+1] ) 
 
            ;### Debug output
            ;print, L, K, Fraction[L,K], 2, Format='(2i12,6x,f13.6,i2)' 
 
            ; Indicate a valid contribution from L to K
            Valid = 1L
 
            ; Go to next iteration
            goto, NextK
         endif
            
         ;==============================================================
         ; Contribution if: 
         ; ----------------
         ; Entire OUTPUT layer in INPUT layer
         ;==============================================================
         if ( PEdge2[K]   le PEdge1[L]     AND $
              PEdge2[K+1] ge PEdge1[L+1] ) then begin
 
            Fraction[L,K] = ( PEdge2[K] - PEdge2[K+1] ) / $
                            ( PEdge1[L] - PEdge1[L+1] )
 
            ; Also add the to the first OUTPUT layer the fraction
            ; of the first INPUT layer that is below sigma = 1.0
            ; This is a condition that can be found in GEOS-3 data.
            if ( ( First                  )   AND  $
                 ( K eq 0L                )   AND  $ 
                 ( PEdge1[L] gt PEdge2[0] ) ) then begin
 
               Fraction[L,K] = Fraction[L,K] +               $
                               ( PEdge1[L] - PEdge2[0]   ) / $
                               ( PEdge1[L] - PEdge1[L+1] )                
 
               ; We only need to do this once...
               First = 0L
            endif
 
            ;### Debug output
            ;print, L, K, Fraction[L,K], 3, Format='(2i12,6x,f13.6,i2)'
 
            ; Indicate a valid contribution from L to K
            Valid = 1L
 
            ; Go to next iteration
            goto, NextK
         endif
            
         ;==============================================================
         ; Contribution if: 
         ; ----------------
         ; Bottom of OUTPUT layer in INPUT layer
         ;==============================================================
         if ( PEdge2[K]   ge PEdge1[L+1]   AND  $
              PEdge2[K+1] le PEdge1[L+1] ) then begin
            
            Fraction[L,K] = ( PEdge2[K] - PEdge1[L+1] ) / $
                            ( PEdge1[L] - PEdge1[L+1] )
            
            ; Also add the to the first OUTPUT layer the fraction
            ; of the first INPUT layer that is below sigma = 1.0
            ; This is a condition that can be found in GEOS-3 data.
            if ( ( First                 )   AND $  
                 ( K eq 0L               )   AND $ 
                 ( PEdge1[L] > PEdge2[0] ) ) then begin
               Fraction[L,K] = Fraction[L,K] +               $
                               ( PEdge1[L] - PEdge2[0]   ) / $
                               ( PEdge1[L] - PEdge1[L+1] )                
 
               ; We only need to do this once...
               First = 0L
            endif
 
            ;### Debug output
            ;Print, L, K, Fraction[L,K], 4, Format='(2i12,6x,f13.6,i2)'
 
            ; Indicate a valid contribution from L to K
            Valid = 1L
 
            ; Go to next iteration
            goto, NextK
         endif
 
NextK:
      endfor ; K
 
      ;=================================================================
      ; Consistency Check:
      ; ------------------
      ; If SUM( FRACTION(L,:) ) does not = 1, there is a problem.
      ; Test those INPUT layers (L) which make a contribution to 
      ; OUTPUT layers (K) for this criterion.
      ;
      ; NOTE: This will be skipped if /NO_CHECK is set (bmy, 3/14/02)
      ;=================================================================
      if ( Valid AND Check ) then begin
         if ( Abs( 1e0 - Total( Fraction[L,*] ) ) ge 1e-4 ) THEN begin
            print, 'Fraction does not add to 1;;'
            print, L, Total( Fraction[L,*] ), $
               Format='(''L, SUM( FRACTION(L,:) ): '', i4, 1x, f13.7 )'
            stop
         endif
      endif
 
NextL:
   endfor
 
   ;====================================================================
   ; Compute "new" data -- multiply "old" data by fraction of
   ; "old" data residing in the "new" layer
   ;====================================================================
   for K = 0L, LM2 - 1L do begin
   for L = 0L, LM1 - 1L do begin
      Data2[K] = Data2[K] + ( Data1[L] * Fraction[L,K] )
   endfor
   endfor
 
   ;### Debug output
   if ( Debug ) then begin
      print, '### Output Pressure Edges'
      print, PEdge2
      print, '### Output Data:'
      print, Data2
      print, '### Output Data: column sum'
      print, Total( Data2 )
      print, '### Output Data: ratio sum(new)/sum(old):'
      print, Total( Data2 ) / Total( Data1 )
   endif
   
   ;====================================================================
   ; Return DATA2 to calling program
   ;====================================================================
   return, Data2
end
