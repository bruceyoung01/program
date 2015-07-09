; $Id: regridh_aerosol.pro,v 1.1.1.1 2007/07/17 20:41:32 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        REGRIDH_AEROSOL
;
; PURPOSE:
;        Horiziontally regrids aerosol concentrations from
;        one CTM grid to another.  Total mass is conserved.
;
; CATEGORY:
;        Regridding
;
; CALLING SEQUENCE:
;        REGRIDH_AEROSOL [, Keywords ]
;
; INPUTS:
;        None
;
; KEYWORD PARAMETERS:
;        MONTH -> Month of year for which to process data.
;             Default is 1 (January).
;
;        INFILENAME -> Name of the file containing data to be regridded.
;             If omitted, then REGRIDH_AEROSOL will prompt the user to
;             select a filename with a dialog box.
;
;        OUTMODELNAME -> Name of the model grid onto which the data
;             will be regridded.  If OUTMODELNAME is not specified, 
;             REGRIDH_AEROSOL will use the same model name as the
;             input grid.
;
;        OUTRESOLUTION -> Specifies the resolution of the model grid
;             onto which the data will be regridded.  OUTRESOLUTION
;             can be either a 2 element vector with [ DI, DJ ] or
;             a scalar (DJxDI: 8=8x10, 4=4x5, 2=2x2.5, 1=1x1, 
;             0.5=0.5x0.5).  Default for all models is 4x5.
;
;        OUTFILENAME -> Name of the file which will contain the
;            regridded data.  
;
;        DIAGN -> Diagnostic category of the data blocks that you 
;            wish to regrid.  Default is "ARSL-L=$".
;
; OUTPUTS:
;        None
;
; SUBROUTINES:
;        External Subroutines Required:
;        =================================================
;        CTM_GRID    (function)   CTM_TYPE          (function)
;        CTM_REGRIDH (function)   CTM_NAMEXT        (function)   
;        CTM_RESEXT  (function)   CTM_MAKE_DATAINFO (function)
;        CTM_GET_DATA             CTM_WRITEBPCH            
;        GETMODELANDGRIDINFO      UNDEFINE
;
; REQUIREMENTS:
;        References routines from the GAMAP and TOOLS packages.
;
; NOTES:
;        (1) It is best to regrid the aeorsol dust files 1 month
;            at a time, since it can take quite a while to regrid
;            all of the tracers and levels.  One can then use GAMAP
;            to concatenate the monthly files.
;
;        (2) Aerosol concentrations are used in the photolysis code
;            since they also cause the incoming solar radiation
;            to be scattered out of a column.
;
;        (3) Assumes that the input file is already in binary punch
;            format.  To regrid data directly from Paul Ginoux's
;            GOCART model simulations, use "regridh_dust.raw.pro".
;
; EXAMPLE:
;        REGRIDH_AEROSOL, INFILENAME='aerosol.geos3.2x25', $
;                         OUTFILENAME='aerosol.geos3.4x5', $
;                         OUTRESOLUTION=4, MONTH=1
;           
;             ; Regrids January aerosol data from 2 x 2.5 GEOS-3
;             ; resolution to 4 x 5 resolution.
;
; MODIFICATION HISTORY:
;        bmy, 15 Jan 2003: VERSION 1.01
;        bmy, 22 Dec 2003: VERSION 1.02
;                          - rewritten for GAMAP v2-01
;                          - call PTR_FREE to free the pointer heap memory 
;                
;-
; Copyright (C) 2003, Bob Yantosca, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author.
; Bugs and comments should be directed to bmy@io.harvard.edu
; with subject "IDL routine regridh_aerosol"
;-----------------------------------------------------------------------

pro RegridH_Aerosol, InFileName=InFileName,       OutModelName=OutModelName, $
                     OutResolution=OutResolution, OutFileName=OutFileName,   $
                     Diagn=DiagN,                 Month=Month,               $
                     _EXTRA=e
 
   ;====================================================================
   ; Initialization
   ;====================================================================

   ; External Functions
   FORWARD_FUNCTION CTM_Type,   CTM_Grid,    CTM_NamExt, $
                    CTM_ResExt, CTM_RegridH, CTM_Make_DataInfo 

   ; Keywords
   if ( N_Elements( DiagN         ) ne 1 ) then DiagN         = 'ARSL-L=$'
   if ( N_Elements( Month         ) eq 0 ) then Month         = Indgen(12)+1L
   if ( N_Elements( OutResolution ) eq 0 ) then OutResolution = 1

   ; TAU values used to index input data (year 1996)
   Tau       = [  96408D,  97152D,  97848D,  98592D,  99312D, 100056D, $
                 100776D, 101520D, 102264D, 102984D, 103728D, 104448D ]

   ; First-time flag
   FirstTime = 1L

   ;====================================================================
   ; Process data
   ;====================================================================
  
   ; Get all months
   ThisTau = Tau[ Month-1L ]

   ; Read data blocks into DATAINFO array of structures
   CTM_Get_Data, DataInfo, 'ARSL-L=$', FileName=InFileName, Tau0=ThisTau

   ; Loop over data blocks
   for D = 0L, N_Elements( DataInfo ) - 1L do begin

      ; Echo tracer name to screen
      S = 'Now processing tracer ' + StrTrim( DataInfo[D].TracerName )
      Message, S, /Info

      ;-------------------
      ; INPUT GRID
      ;-------------------
     
      ; Get MODELINFO and GRIDINFO structures 
      GetModelAndGridInfo, DataInfo[D], InType, InGrid
     
      ; Pointer to the data
      Pointer = DataInfo[D].Data

      ; Error check pointer
      if ( not Ptr_Valid( Pointer ) ) then Message, 'Invalid Pointer!'

      ; Dereference the pointer to get the data
      InData  = *( Pointer )

      ; Free the associated pointer heap memory
      Ptr_Free, Pointer

      ;-------------------
      ; OUTPUT GRID
      ;-------------------

      ; If OUTMODELNAME is not passed, then use the same grid as for INTYPE
      if ( N_Elements( OutModelName ) ne 1 ) then OutModelName = InType.Name

      ; Get MODELINFO and GRIDINFO structures
      OutType = CTM_Type( OutModelName, Res=OutResolution, _EXTRA=e )
      OutGrid = CTM_Grid( OutType )

      ;-------------------
      ; REGRID DATA
      ;-------------------
     
      ; Use saved mapping weights?
      US = 1L - FirstTime

      ; Regrid the aerosol data
      OutData = CTM_RegridH( InData,         InGrid,  OutGrid, $
                             /Per_Unit_Area, /Double, Use_Saved=US )

      ;-------------------
      ; SAVE DATA BLOCKS
      ;-------------------

      ; Make DATAINFO structure 
      Success = CTM_Make_DataInfo( Float( OutData ),           $
                                   ThisDataInfo,               $
                                   ThisFileInfo,               $
                                   ModelInfo=OutType,          $
                                   GridInfo=OutGrid,           $
                                   DiagN=DataInfo[D].Category, $
                                   Tracer=DataInfo[D].Tracer,  $
                                   Tau0=DataInfo[D].Tau0,      $
                                   Tau1=DataInfo[D].Tau1,      $
                                   Unit=DataInfo[D].Unit,      $
                                   Dim=[OutGrid.IMX,           $
                                        OutGrid.JMX,           $    
                                        DataInfo[D].Dim[2],    $
                                        DataInfo[D].Dim[3] ],  $
                                   First=DataInfo[D].First,    $
                                   /No_Global )
      
      ; Error check
      if ( not Success ) then Message, 'Could not make DATAINFO!'

      ; Save into NEWDATAINFO array of structures
      if ( FirstTime )                                         $ 
         then NewDataInfo = ThisDataInfo                       $
         else NewDataInfo = [ NewDataInfo, ThisDataInfo ]

      ; Reset first-time flag
      FirstTime = 0L

      ; Undefine stuff
      UnDefine, InData
      UnDefine, InType
      UnDefine, InGrid
      UnDefine, OutData
      UnDefine, ThisDataInfo
   endfor

   ;====================================================================
   ; Save data to disk
   ;==================================================================== 

   ; Default OUTFILENAME
   if ( N_Elements( OutFileName ) ne 1 ) then begin
      OutFileName = 'aerosol.' + CTM_NamExt( OutTypeSav ) + $
                    '.'        + CTM_ResExt( OutTypeSav ) + $ 
                    '.'        + String( Month, Format='(i2.2)' )
   endif


   ; Save as binary punch format
   CTM_WriteBpch, NewDataInfo, ThisFileInfo, FileName=OutFileName

end
