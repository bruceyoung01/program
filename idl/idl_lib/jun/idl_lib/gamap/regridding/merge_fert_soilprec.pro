; $Id: merge_fert_soilprec.pro,v 1.1.1.1 2007/07/17 20:41:30 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        MERGE_FERT_SOILPREC
;
; PURPOSE:
;        Merges nonzero soil fertilizer and soil precipitation 
;        data onto the same indexing scheme.  Also computes
;        NLAND, the number of land boxes used in "commsoil.h".
;        
; CATEGORY:
;        Regridding
;
; CALLING SEQUENCE:
;        MERGE_FERT_SOILPREC [, Keywords ]
;
; INPUTS:
;        None
;
; KEYWORD PARAMETERS:
;        FERTFILE -> Name of the binary punch file containing soil 
;             fertilizer data to be merged.  The default file name
;             is hardwired (change as necessary).
;
;        SOILPRECFILE -> Name of the binary punch file containing soil 
;             precipitation data to be merged.  The default file name
;             is hardwired (change as necessary).
;
;        OUTDIR -> Name of the directory where the output file will
;             be written.  Default is './'.  
;
; OUTPUTS:
;        Writes to ASCII output files:
;             fert_scale.dat.{MODELNAME}.{RESOLUTION}
;             climatprep{RESOLUTION}.dat.{MODELNAME} 
;  
; SUBROUTINES:
;        External Subroutines Required:
;        ==============================================
;        CTM_TYPE   (function)   CTM_GRID   (function)
;        CTM_NAMEXT (function)   CTM_RESEXT (function)
;
; REQUIREMENTS:
;        None
;
; NOTES:
;        (1) Input files must be binary punch files, created with
;            routines REGRID_FERT and REGRID_SOILPREC.
;
;        (2) Output files are in ASCII format and are compatible
;            with the existing Harvard CTM routines.
;
; EXAMPLE: 
;        MERGE_FERT_PRECIP, FERTFILE='nox_fert.geos1.2x25',      $
;                           PRECIPFILE='soil_precip.geos1.2x25', $
;                           OUTDIR='/scratch/bmy'
;
;             ; Will merge the soil fertilizer data contained in
;             ; "nox_fert.geos1.2x25" and the soil precip data 
;             ; contained in soil_precip.geos1.2x25".  Output files
;             ; will be sent to the /scratch/bmy directory.
;
; MODIFICATION HISTORY:
;        bmy, 04 Aug 2000: VERSION 1.00
;                          - adapted from older IDL code 
;  bmy & phs, 20 Jun 2007: GAMAP VERSION 2.10
;
;-
; Copyright (C) 2000-2007, 
; Bob Yantosca, and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of this 
; software. If this software shall be used commercially or sold as 
; part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.as.harvard.edu with subject "IDL routine merge_fert_soilprec"
;-----------------------------------------------------------------------


pro Merge_Fert_SoilPrec, FertFile=FertFile, SoilPrecFile=SoilPrecFile, $
                         OutDir=OutDir,     _EXTRA=e

   ;===================================================================
   ; Initialization
   ;===================================================================

   ; External functions
   FORWARD_FUNCTION CTM_Type, CTM_Grid, CTM_NamExt, CTM_ResExt

   ; Keywords
   if ( N_Elements( FertFile ) eq 0 ) then begin
      FertFile = '~bmy/archive/data/soil_NOx_200203/1x1_geos/nox_fert.geos.1x1'
   endif

   if ( N_Elements( SoilPrecFile ) eq 0 ) then begin
      SoilPrecFile = $
         '~bmy/archive/data/soil_NOx_200203/1x1_geos/soil_precip.geos.1x1'
   endif

   if ( N_Elements( OutDir ) ne 1 ) then OutDir = './' 

   ; Trim excess spaces from OUTDIR
   OutDir = StrTrim( OutDir, 2 )

   ; Make sure the last character of OUTDIR is a slash
   if ( StrMid( OutDir, StrLen( OutDir ) - 1, 1 ) ne '/' ) $
      then OutDir = OutDir + '/'

   ; TAU values (assume "generic" year 1985)
   Tau = [    0D,  744D, 1416D, 2160D, 2880D, 3624D, $
           4344D, 5088D, 5832D, 6552D, 7296D, 8016D, 8760D ] 

   ;===================================================================
   ; Read soil fertilizer data on CTM grid (aseasonal)
   ;===================================================================
   Success = CTM_Get_DataBlock( Fert, 'NOX-FERT',   $
                                ModelInfo=FertType, $
                                GridInfo=FertGrid,  $
                                FileName=FertFile,  $
                                Tracer=1L,          $
                                Tau0=0D,            $
                                Title='Select a soil fertilizer file' )

   ; Error check 
   if ( not Success ) then begin
      Message, 'Fertilizer data not found!', /Continue
      return
   endif

   ;===================================================================
   ; Read monthly soil precipitation data on CTM grid
   ;===================================================================
   for T = 0L, 11L do begin
      Success = CTM_Get_DataBlock( Temp, 'SOILPREC',      $
                                   ModelInfo=PrecipType,  $
                                   GridInfo=PrecipGrid,   $
                                   FileName=SoilPrecFile, $
                                   Tracer=1L,             $
                                   Tau0=Tau[T],           $
                                   Title='Select a soil precipitation file' )

      ; Error check 
      if ( not Success ) then begin
         S = 'Soil precipitation for month ' + $
            String( T+1, Format='(i2)' ) + ' not found!'
         Message, S, /Continue
         return
      endif
          
      ; Create array if this is the first month
      if ( T eq 0L ) $
         then Precip = FltArr( PrecipGrid.IMX, PrecipGrid.JMX, 12 )
      
      ; Save this month's soil precip into the PRECIP array
      Precip[*, *, T] = Temp
   endfor

   ;===================================================================
   ; Make sure the fertilizer and soil precip files have the same grid
   ;===================================================================
   if ( FertType.Name          ne PrecipType.Name            OR $
        FertType.Resolution[0] ne PrecipType.Resolution[0]   OR $
        FertType.Resolution[1] ne PrecipType.Resolution[1] ) then begin
      Message, 'Fertilizer & precipitation files have incompatible grids!', $
         /Continue
   endif

   ;===================================================================
   ; Open files for output
   ;===================================================================

   ; Soil fertilizer
   OutFileName = OutDir + 'fert_scale.dat.' + CTM_NamExt( FertType ) + $
                          '.'               + CTM_ResExt( FertType )

   Open_File, OutFileName, Ilun_Fert, /Get_LUN, /Write
           

   ; Soil precipitation
   OutFileName = OutDir + 'climatprep' + CTM_ResExt( FertType ) + $
                          '.dat.'      + CTM_NamExt( FertType )

   Open_File, OutFileName, Ilun_Precip, /Get_LUN, /Write

   ;===================================================================
   ; Merge soil fertilizer data and soil precipitation data so that
   ; they both use the same grid box indices (N = 1, N_Land)
   ;===================================================================

   ; NLAND is the number of land boxes with nonzero data
   N_Land = 0L

   ; Loop over grid boxes
   ; NOTE: (I,J) are in IDL notation (starting from zero)
   for J = 0L, FertGrid.JMX - 1L do begin
   for I = 0L, FertGrid.IMX - 1L do begin
      
      ; IND1 is a byte flag for nonzero fertilizer data
      Ind1 = ( Fert[I,J] gt 0.0 )

      ; IND2 is a byte array of flags for nonzero
      ; soil precipitation data (12 months)
      Ind2 = ( Precip[I,J,*] gt 0.0 )      

      ; If either soil fertilizer or soil precip (any month) 
      ; is nonzero, write everything out to disk
      if ( ( Total( Ind1 ) gt 0 ) OR ( Total( Ind2 ) gt 0 ) ) then begin

         ; Increment number of land boxes
         N_Land = N_Land + 1

         ; Write soil fertilizer data to disk
         PrintF, Ilun_Fert,   Format='(2i6,e10.3)',  I+1, J+1, Fert[I,J]
 
         ; Write soil precipitation to disk
         Printf, Ilun_Precip, Format='(2i3,12f6.2)', I+1, J+1, Precip[I,J,*]
      endif
   endfor
   endfor

   ; Display N_LAND
   S = 'Number of land boxes: ' + StrTrim( String( N_Land ), 2 )
   Message, S, /Info

   ;===================================================================
   ; Close files and quit
   ;===================================================================
   Close,    Ilun_Fert
   Free_LUN, Ilun_Fert

   Close,    Ilun_Precip
   Free_LUN, Ilun_Precip

   ; Quit
   return
end
