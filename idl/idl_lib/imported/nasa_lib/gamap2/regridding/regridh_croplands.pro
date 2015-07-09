; $Id: regridh_croplands.pro,v 1.1.1.1 2007/07/17 20:41:31 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        REGRIDH_CROPLANDS
;
; PURPOSE:
;        Regrids crop land fraction data from 0.5 x 0.5 degree 
;        resolution to a coarser CTM grid.
;
; CATEGORY:
;        Regridding
;
; CALLING SEQUENCE:
;        REGRIDH_CROPLANDS [, Keywords ]
;
; INPUTS:
;        None
;
; KEYWORD PARAMETERS:
;        INFILENAME -> Name of a netCDF file containing input 
;             data to be be regridded.  Default is 
;             '~rmy/Croplands/crop92_v1.1_0.5.nc'.
;
;        OUTFILENAME -> Name of the binary punch file to contain
;             output data.  Default is "croplands.bpch"
;
;        OUTMODELNAME -> A string containing the name of the model
;             grid on which the input data resides.  Default is GENERIC.
;
;        OUTRESOLUTION -> Specifies the resolution of the model grid
;             on which the input data resides.  RESOLUTION can be 
;             either a 2 element vector with [ DI, DJ ] or
;             a scalar (DJxDI: 8=8x10, 4=4x5, 2=2x2.5, 1=1x1, 
;             0.5=0.5x0.5).  Default is 1.
;
; OUTPUTS:
;        None -- writes output to file
;
; SUBROUTINES:
;        Internal Subroutines
;        ===================================================
;        RC_ReadData (function)
; 
;        External Subroutines Required:
;        ===================================================
;        NCDF_READ             CTM_MAKE_DATAINFO (function) 
;        CTM_TYPE (function)   CTM_GRID          (function)  
;        CTM_WRITEBPCH         UNDEFINE
;
; REQUIREMENTS:
;        References routines from both GAMAP and TOOLS packages.
;
; NOTES:
;        Some hardwiring for now...this is OK.
;
; EXAMPLE:
;        REGRID_CROPLANDS, INFILENAME='croplands.nc',       $
;                          OUTMODELNAME='generic',          $
;                          OUTRESOLUTION=1,                 $
;                          OUTFILENAME='newcroplands.bpch'
;
;
;             ; Regrids 0.5 x 0.5 croplands data from "croplands.nc"
;             ; file to 1 x 1 resolution.  Output is to the binary
;             ; punch file "newcroplands.bpch".
;
; MODIFICATION HISTORY:
;        bmy, 19 Jul 2001: VERSION 1.00
;        bmy, 09 Jan 2003: VERSION 1.02
;                          - Now use CTM_REGRIDH to regrid data
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
; or phs@io.as.harvard.edu with subject "IDL routine regrid_croplands"
;-----------------------------------------------------------------------


function RC_ReadData, FileName
   
   ;====================================================================
   ; Function RC_ReadData reads croplands data from a NetCDF file,
   ; using NCDF_READ by Martin Schultz. (bmy, 7/19/01)
   ;====================================================================
 
   ; Echo to screen
   S = 'Reading data from ' + StrTrim( FileName, 2 )
   Message, S, /Info
 
   ; Read from NCDF file
   NCDF_Read, Result, File=FileName, /All, Attributes=Attributes
 
   ; Extract the data
   ; Reverse latitudes so that we go from S --> N 
   Lon   = Result.Longitude
   Lat   = Reverse( Result.Latitude )
   FArea = Reverse( Result.FArea, 2 )
 
   ; Extract the units and missing value
   Unit    = Attributes.FArea.Units
   Missing = Attributes.FArea.Missing_Value
 
   ; Strip missing values
   Ind = Where( FArea eq Missing )
   if ( Ind[0] ge 0 ) then FArea[Ind] = 0.0
 
   ; Create return structure
   NewResult = { Longitude : Lon,     $
                 Latitude  : Lat,     $
                 Data      : FArea,   $
                 Unit      : Unit,    $
                 Missing   : Missing }
   
   ; Undefine variables
   UnDefine, Result
   UnDefine, Lon
   UnDefine, Lat
   UnDefine, FArea
   UnDefine, Unit
   UnDefine, Missing
 
   ; Return to calling program
   return, NewResult 
end
 
;------------------------------------------------------------------------------
 
pro RegridH_Croplands, InFileName=InFileName,       $
                       OutFileName=OutFileName,     $
                       OutModelName=OutModelName,   $
                       OutResolution=OutResolution, $
                       _EXTRA=e

   ;====================================================================
   ; Initialization
   ;==================================================================== 
 
   ; External functions
   FORWARD_FUNCTION RC_ReadData, CTM_Type, CTM_Grid, CTM_Make_DataInfo
 
   ; Keywords
   if ( N_Elements( OutModelName  ) ne 1 ) then OutModelName   = 'generic'
   if ( N_Elements( OutResolution ) ne 1 ) then OutResolution  = 1
   if ( N_Elements( OutFileName   ) ne 1 ) then OutFileName = 'croplands.bpch'

   ; Default INFILENAME
   if ( N_Elements( InFileName    ) ne 1 ) $
      then InFileName = '~rmy/Croplands/crop92_v1.1_0.5.nc'

   ; Input grid
   InType = CTM_Type( 'generic', res=[0.5, 0.5], HalfPolar=0, Center180=0 )
   InGrid = CTM_Grid( InType, /No_Vertical )
 
   ; Output grid parameters
   ; Make sure GENERIC grid is edged on 180 and has no halfpolar boxes
   if ( StrUpCase( StrTrim( OutModelName, 2 ) eq 'GENERIC' ) ) then begin
      OutType = CTM_Type( OutModelName, Res=OutResolution, $
                          HalfPolar=0,  Center180=0 )
   endif else begin
      OutType = CTM_Type( OutModelName, Res=OutResolution )
   endelse
 
   OutGrid = CTM_Grid( OutType, /No_Vertical )
 
   ;====================================================================
   ; Read and regrid data!
   ;====================================================================
 
   ; Read the data 
   Result  = RC_ReadData( InFileName )
   InData  = Result.Data
 
   ; Regrid data
   OutData = CTM_RegridH( InData, InGrid, OutGrid, /Double )
    
   ;====================================================================
   ; Write output to binary punch file format
   ;====================================================================
 
   ; Make a DATAINFO structure for this NEWDATA
   Success = CTM_Make_DataInfo( Float( OutData ),         $
                                ThisDataInfo,             $
                                ModelInfo=OutType,        $
                                GridInfo=OutGrid,         $
                                DiagN='CROPLAND',         $
                                Tracer=1,                 $
                                Tau0=0D,                  $
                                Tau1=8760D,               $
                                Unit='unitless',          $
                                Dim=[OutGrid.IMX,         $
                                     OutGrid.JMX, 0, 0],  $
                                First=[1L, 1L, 1L] )
   
   ; Error check
   if ( not Success ) then begin
      Message, 'Could not make a DATAINFO structure!', /Continue
      return
   endif
 
   ; Write binary punch file
   CTM_WriteBpch, ThisDataInfo, FileName=OutFileName
 
   ;### Debug
   ;Multipanel, Rows=2, Cols=1
   ;
   ;TvMap, OldData, InGrid.XMid, InGrid.YMid, /Countries, /Coasts, $
   ;   /Grid, /CBar, /Sample, Div=4, Min_Valid=1e-10, /Isotropic, $
   ;   /USA, Title='Olddata - 0.5 x 0.5'
   ;
   ;TvMap, NewData, NewGrid.XMid, NewGrid.YMid, /Countries, /Coasts, $
   ;   /Grid, /CBar, /Sample, Div=4, Min_Valid=1e-10, /Isotropic, $
   ;   /USA, Title='Newdata - 1 x 1'
 
   ;====================================================================
   ; Cleanup and Quit
   ;====================================================================
   UnDefine, ThisDataInfo
   UnDefine, InData
   UnDefine, OutData

end
