; $Id: regridh_scalefoss.pro,v 1.1.1.1 2003/10/22 18:41:20 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        REGRIDH_SCALEFOSS_SOX
;
; PURPOSE:
;        Regrids 0.5 x 0.5 fossil fuel scale factors onto a 
;        CTM grid of equal or coarser resolution.
;
; CATEGORY:
;        Regridding
;
; CALLING SEQUENCE:
;        REGRID_SCALEFOSS [, Keywords ]
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
;             0.5=0.5x0.5).  Default for all models is 4x5.;
;
;        YEAR -> 4-digit year number (e.g. 1994) correspoinding
;             to the data to be regridded.  Default is 1994.
;
;        OUTDIR -> Name of the directory where the output file will
;             be written.  Default is './'. 
;
; OUTPUTS:
;        Writes output to binary files (*NOT* binary punch files):
;             scalefoss.liq.{RESOLUTION}.{YEAR}
;             scalefoss.tot.{RESOLUTION}.{YEAR}
;
; SUBROUTINES:
;        External Subroutines Required:
;        ================================================
;        CTM_GRID    (function)    CTM_TYPE   (function)
;        CTM_REGRID  (function)    CTM_NAMEXT (function)   
;        CTM_RESEXT  (function)
;
;        Internal Subroutines:
;        ================================================
;        RS_READ_DATA (function)   RS_WRITE_DATA
;
; REQUIREMENTS:
;        References routines from the GAMAP and TOOLS packages.
;
; NOTES:
;        None
;
; EXAMPLE:
;        REGRID_SCALEFOSS, YEAR=1994,              $
;                          MODELNAME='GEOS_STRAT', $
;                          RESOLUTION=[5,4]
;           
;             ; Regrids fossil fuel scale factor files for 1994 from
;             ; 0.5 x 0.5 resolution onto the 4 x 5 GEOS-STRAT grid
;
; MODIFICATION HISTORY:
;        bmy, 09 Jun 2000: VERSION 1.00
;
;-
; Copyright (C) 2000, Bob Yantosca, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author.
; Bugs and comments should be directed to bmy@io.harvard.edu
; with subject "IDL routine regrid_scalefoss"
;-----------------------------------------------------------------------


pro RegridH_ScaleFoss_Sox, InFileName=InFileName,  OutFileName=OutFileName,  $
                           OutModelName=ModelName, OutResolution=Resolution, $
                           _EXTRA=e
 
   ;====================================================================
   ; External Functions / Keyword Settings
   ;====================================================================
   FORWARD_FUNCTION CTM_Type, CTM_Grid, CTM_Regrid, CTM_NamExt, CTM_ResExt
   
   if ( N_Elements( OutModelName  ) eq 0 ) then OutModelName  = 'GEOS3'
   if ( N_Elements( OutResolution ) eq 0 ) then OutResolution = 4
   
   ; Get data
   CTM_Get_Data, DataInfo, 'SCALFOSS', Tracer=3, File=InFileName

   ; Get input grid parameters
   GetModelAndGridInfo, DataInfo[0], InType, InGrid

   ; Get output grid parameters
   OutType = CTM_Type( ModelName, Resolution=Resolution )
   OutGrid = CTM_Grid( OutType, /No_Vertical )
 
   ; Input data
   InData  = *( DataInfo[0].Data )
   
   ; Regrid data
   OutData = InterPolate_2D( InData,                     $
                             InGrid.Xmid,  InGrid.YMid,  $
                             OutGrid.XMid, OutGrid.YMid )

   ; Make DATAINFO structure 
   Success = CTM_Make_DataInfo( Float( OutData ),           $
                                ThisDataInfo,               $
                                ThisFileInfo,               $
                                ModelInfo=OutType,          $
                                GridInfo=OutGrid,           $
                                DiagN=DataInfo[0].Category, $
                                Tracer=DataInfo[0].Tracer,  $
                                Tau0=DataInfo[0].Tau0,      $
                                Tau1=DataInfo[0].Tau1,      $
                                Unit=DataInfo[0].Unit,      $
                                Dim=[OutGrid.IMX,           $
                                     OutGrid.JMX, 0, 0],    $
                                First=[1L, 1L, 1L],         $
                                /No_Global )
     
   ; Error check
   if ( not Success ) then Message, 'Could not make DATAINFO!'
 
   ; Write as binary punch file
   CTM_WriteBpch, ThisDataInfo, ThisFileInfo, FileName=OutFileName

   return
end
