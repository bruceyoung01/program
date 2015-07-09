; $Id: regrid_biofuel.pro,v 1.1.1.1 2007/07/17 20:41:32 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        REGRID_BIOFUEL
;
; PURPOSE:
;        Regrids 1 x 1 biomass burning emissions for NOx or CO
;        onto a CTM grid of equal or coarser resolution.
;
; CATEGORY:
;        Regridding
;
; CALLING SEQUENCE:
;        REGRID_BIOFUEL [, Keywords ]
;
; INPUTS:
;        None
;
; KEYWORD PARAMETERS:
;        MODELNAME -> A string containing the name of the model 
;             grid onto which the data will be regridded.
;
;        RESOLUTION -> Specifies the resolution of the model grid
;             onto which the data will be regridded.  RESOLUTION
;             can be either a 2 element vector with [ DI, DJ ] or
;             a scalar (DJxDI: 8=8x10, 4=4x5, 2=2x2.5, 1=1x1, 
;             0.5=0.5x0.5).  Default for all models is 4x5.
;
;        /NOX -> If set, will regrid NOx biofuel data.  Default is
;             to regrid CO biofuel data.
;
;        OUTDIR -> Name of the directory where the output file will
;             be written.  Default is './'.  
;
; OUTPUTS:
;        Writes binary punch files: 
;             biofuel.NOx.{MODELNAME}.{RESOLUTION}  (when NOX=1)
;             biofuel.CO.{MODELNAME}.{RESOLUTION}   (when NOX=0)
;
; SUBROUTINES:
;        External Subroutines Required:
;        ================================================
;        CTM_GRID     (function)   CTM_TYPE   (function)
;        CTM_BOXSIZE  (function)   CTM_REGRID (function)
;        CTM_NAMEXT   (function)   CTM_RESEXT (function)
;        CTM_WRITEBPCH
;
;        Internal Subroutines
;        ================================================
;        RBF_READDATA (function) 
;
; REQUIREMENTS:
;        None
;
; NOTES:
;        The path names for the files containing 1 x 1 data are
;        hardwired -- change as necessary!
;
; EXAMPLE:
;        (1)
;        REGRID_BIOFUEL, MODELNAME='GEOS_STRAT', RESOLUTION=[5,4]
;           
;             ; Regrids 1 x 1 CO biofuel data to the 4 x 5 GEOS-STRAT grid
;
;        (2)
;        REGRID_BIOFUEL, MODELNAME='GEOS_1', RESOLUTION=2, /NOX
;           
;             ; Regrids 1 x 1 NOx biofuel data to the 2 x 2.5 GEOS-1 grid
;
; MODIFICATION HISTORY:
;        bmy, 09 Jun 2000: VERSION 1.00
;        bmy, 12 Jul 2000: VERSION 1.01 
;                          - added NOx keyword
;                          - now read original data with 
;                            internal function RBF_READDATA
;        bmy, 24 Jul 2000: - added OUTDIR keyword
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
; or phs@io.as.harvard.edu with subject "IDL routine regrid_biofuel"
;-----------------------------------------------------------------------


function RBF_ReadData, FileList, OldGrid 

   ;====================================================================
   ; Internal function RBF_READDATA reads the original biofuel data
   ; from the ASCII format file and returns it to the main program.
   ;====================================================================

   ; OLDDATA = array to hold 1 x 1 biomass burning data
   OldData = DblArr( OldGrid.IMX, OldGrid.JMX )

   ; TMPVAL is used to read in the data
   TmpVal  = 0D

   ; Open ASCII file containing biomass burning data
   Open_File, FileList, Ilun_IN, /Get_LUN
 
   ; Read data from each monthly file
   ; Data has units of [kg CO/box/yr]
   for J = 0L, OldGrid.JMX - 1L do begin
   for I = 0L, OldGrid.IMX - 1L do begin
      ReadF, Ilun_In, TmpVal
      OldData[I, J] = TmpVal
   endfor
   endfor
 
   ; Close ASCII file
   Close,    Ilun_IN
   Free_LUN, Ilun_IN

   ; Return data to main program
   return, OldData
end

;------------------------------------------------------------------------------

pro Regrid_BioFuel, ModelName=ModelName, Resolution=Resolution, $
                    NOx=NOx,             OutDir=OutDir
 
   ;====================================================================
   ; External Functions / Keyword Settings
   ;====================================================================
   FORWARD_FUNCTION CTM_Grid,   CTM_Type,   CTM_BoxSize, $
                    CTM_Regrid, CTM_NamExt, CTM_ResExt

   if ( N_Elements( ModelName  ) eq 0 ) then ModelName  = 'GEOS1'
   if ( N_Elements( Resolution ) eq 0 ) then Resolution = 4

   ; Trim excess spaces from OUTDIR
   OutDir = StrTrim( OutDir, 2 )

   ; Make sure the last character of OUTDIR is a slash
   if ( StrMid( OutDir, StrLen( OutDir ) - 1, 1 ) ne '/' ) $
      then OutDir = OutDir + '/'

   ;====================================================================
   ; Define the path name for each of the ASCII files that 
   ; contain 1 x 1 biomass burning data -- change if necessary!
   ;
   ; Set filename for either NOx or CO biofuel data (bmy, 7/12/00)
   ;====================================================================
   if ( Keyword_Set( NOx ) ) then begin
      Spec   = 'NOx'
      Tracer = 1L
   endif else begin
      Spec   = 'CO'
      Tracer = 4L
   endelse
 
   FileList = '/users/amalthea/ctm/bnd/fires/RoseCO/' + Spec + 'emiss.biofuels'

   ; Echo info to screen
   S = 'Processing ' + StrTrim( FileList, 2 ) + '...'
   Message, S, /Info

   ;====================================================================
   ; Define MODELINFO and GRIDINFO structures for the 1 x 1 grid
   ; Define MODELINFO and GRIDINFO structures for the CTM grid
   ; Compute grid box surface areas for old & new grids
   ;====================================================================
   OldType = CTM_Type( 'generic', res=[1, 1], HalfPolar=0, Center180=0 )
   OldGrid = CTM_Grid( OldType, /No_Vertical )
   OldArea = CTM_BoxSize( OldGrid, /GEOS_Radius, /Cm2 )
   
   NewType = CTM_Type( ModelName, Resolution=Resolution )
   NewGrid = CTM_Grid( NewType, /No_Vertical )
   NewArea = CTM_BoxSize( NewGrid, /GEOS_Radius, /Cm2 )
  
   ;====================================================================
   ; Process the biofuel file -- compute yearly totals
   ;====================================================================
      
   ; Declare Summing variables
   Sum_Old = 0D
   Sum_New = 0D

   ; Read original data from ASCII file
   OldData = RBF_ReadData( FileList, OldGrid )
 
   ; Regrid the data in units of [kg CO/box/yr]
   NewData = CTM_Regrid( OldData, OldGrid, NewGrid, $
                         /No_Normalize, /Double, /Quiet )
 
   ; Compute sums of data for both old & new grids in Tg CO
   Sum_Old = Total( OldData ) / 1d9 
   Sum_New = Total( NewData ) / 1d9 
 
   ; Print old & new sums in Tg CO
   print
   print, Spec, Sum_Old, Format='( ''Sum Old Grid [Tg '', a,'']: '', f13.6 )' 
   print, Spec, Sum_New, Format='( ''Sum New Grid [Tg '', a,'']: '', f13.6 )' 
 
   ; Make a DATAINFO structure for this NEWDATA array
   Success = CTM_Make_DataInfo( Float( NewData ),        $
                                ThisDataInfo,            $
                                ThisFileInfo,            $
                                ModelInfo=NewType,       $
                                GridInfo=NewGrid,        $
                                DiagN='BIOFSRCE',        $
                                Tracer=Tracer,           $
                                Tau0=0D,                 $
                                Tau1=8760D,              $
                                Unit='kg/yr',            $
                                Dim=[NewGrid.IMX,        $
                                     NewGrid.JMX, 0, 0], $
                                First=[1L, 1L, 1L] )
 
   ;====================================================================
   ; Write all data blocks to a binary punch file
   ;====================================================================
   OutFileName = OutDir + 'biofuel.' + Spec                  + $
                          '.'        + CTM_NamExt( NewType ) + $
                          '.'        + CTM_ResExt( NewType )

   CTM_WriteBpch, ThisDataInfo, FileName=OutFileName
    
   ; Quit
   return
end
