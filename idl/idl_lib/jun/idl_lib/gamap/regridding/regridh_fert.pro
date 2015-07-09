; $Id: regridh_fert.pro,v 1.1.1.1 2007/07/17 20:41:33 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        REGRIDH_FERT
;
; PURPOSE:
;        Regrids fertilizer NOx from a 1 x 1 grid onto a
;        CTM grid of equal or coarser horizontal resolution.
;        
; CATEGORY:
;        Regridding
;
; CALLING SEQUENCE:
;        REGRIDH_FERT [, Keywords ]
;
; INPUTS:
;        None
;
; KEYWORD PARAMETERS:
;        OUTMODELNAME -> A string containing the name of the model 
;             grid onto which the data will be regridded.
;
;        OUTRESOLUTION -> Specifies the resolution of the model grid
;             onto which the data will be regridded.  RESOLUTION
;             can be either a 2 element vector with [ DI, DJ ] or
;             a scalar (DJxDI: 8=8x10, 4=4x5, 2=2x2.5, 1=1x1, 
;             0.5=0.5x0.5).  Default for all models is 4x5.
;
;        OUTFILENAME -> Name of the binary punch file that will hold
;             regridded data.  If not specified, the default OUTFILENAME
;             will be nox_fert.geos.{OUTRESOLUTION}
;
; OUTPUTS:
;        None
;  
; SUBROUTINES:
;        External Subroutines Required:
;        ==============================================
;        CTM_TYPE    (function)   CTM_GRID   (function)
;        CTM_NAMEXT  (function)   CTM_RESEXT (function)
;        CTM_REGRIDH (function)   CTM_WRITEBPCH
;        
;
; REQUIREMENTS:
;        None
;
; NOTES:
;        (1) Filenames are hardwired -- change as necessary
;        (2) Regridding can take a while, especially at 1x1 resolution.
;
; EXAMPLE: 
;        REGRIDH_FERT, OUTMODELNAME='GEOS1', $
;                      OUTRESOLUTION=2,      $
;                      OUTFILENAME='nox_fert.geos.2x25'
; 
;             ; Regrids 1 x 1 NOx fertilizer data onto the GEOS-1
;             ; 2 x 2.5 resolution grid.  
;
; MODIFICATION HISTORY:
;        bmy, 01 Aug 2000: VERSION 1.00
;        bmy, 13 Jan 2003: VERSION 1.01
;                          - renamed to "regridh_fert.pro"
;                          - now uses CTM_REGRIDH
;                          - removed OUTDIR, added OUTFILENAME
;                          - updated comments
;        bmy, 23 Dec 2003: VERSION 1.02
;                          - updated for GAMAP v2-01
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
; or phs@io.as.harvard.edu with subject "IDL routine regridh_fert"
;-----------------------------------------------------------------------


pro RegridH_Fert, OutModelName=OutModelName, OutResolution=OutResolution, $
                  OutFileName=OutFileName,   _EXTRA=e

   ;===================================================================
   ; Initialization
   ;===================================================================

   ; External functions
   FORWARD_FUNCTION CTM_Type, CTM_Grid, CTM_NamExt, CTM_ResExt, CTM_RegridH

   ; Keywords
   if ( N_Elements( OutModelName  ) eq 0 ) then OutModelName  = 'GEOS1'
   if ( N_Elements( OutResolution ) eq 0 ) then OutResolution = 4

   ; MODELINFO, GRIDINFO structures & surface areas -- old grid
   InType = CTM_Type( 'generic', Resolution=1, HalfPolar=0, Center180=0 )
   InGrid = CTM_Grid( InType, /No_Vertical)
   
   ; MODELINFO & GRIDINFO structures & surface areas -- new grid
   OutType = CTM_Type( OutModelName, Resolution=OutResolution )
   OutGrid = CTM_Grid( OutType, /No_Vertical )

   ; Default INFILENAME -- change as necessary
   InFileName = '~bmy/archive/data/soil_NOx_200203/1x1_gen/newfert.1x1'
   
   ; Default OUTFILENAME -- change as necessary
   if ( N_Elements( OutFileName ) ne 1 ) then begin
      OutFileName = 'nox_fert.geos.' + CTM_ResExt( OutType )
   endif

   ;===================================================================
   ; Read 1 x 1 fertilizer data from input file "newfert.1x1"
   ;
   ; "newfert.1x1" is in units of g N / hectare / month
   ; where 1 hectare (ha) = 10,000 m^2 = a (100 m) x (100 m) square
   ;
   ; We must convert to ng N / m^2 / s for 'fert_scale.dat'
   ; The conversion factor (HCONV) is derived as follows:
   ;
   ;     g     | 10^9 ng |   ha    |  month  |  day          10^5
   ; ----------+---------+---------+---------+--------- = ------------
   ;  ha month |    g    | 10^4 m2 | 30 days | 86400 s     30 * 86400
   ;===================================================================
   InFrt = DblArr( InGrid.IMX, InGrid.JMX )

   Open_File, InFileName, Ilun, /Get_LUN

   ReadF, Ilun, InFrt, Format='(8e10.3)'
   
   Close,    Ilun
   Free_Lun, Ilun

   ; Convert from [g N/hectare/month] to [ng N/m2/s] as described above
   InFrt = InFrt * ( 1d5 / ( 30d0 * 86400d0 ) )

   ;====================================================================
   ; Process data
   ;====================================================================
   
   ; Regrid from the 1 x 1 grid onto the CTM grid
   OutFrt = CTM_RegridH( InFrt, InGrid, OutGrid, /Per_Unit_Area, /Double )

   ; Make a datainfo structure
   Success = CTM_Make_DataInfo( Float( OutFrt ),              $
                                ThisDataInfo,                 $
                                ThisFileInfo,                 $
                                ModelInfo=OutType,            $
                                GridInfo=OutGrid,             $
                                DiagN='NOX-FERT',             $
                                Tracer=1L,                    $
                                Tau0=0D,                      $
                                Tau1=8760D,                   $
                                Unit='ng N/m2/s',             $
                                Dim=[ OutGrid.IMX,            $
                                      OutGrid.JMX, 0, 0 ],    $
                                First=[1L, 1L, 1L] )
 
   ; Write data to binary punch file
   CTM_WriteBpch, ThisDataInfo, ThisFileInfo, FileName=OutFileName

end
