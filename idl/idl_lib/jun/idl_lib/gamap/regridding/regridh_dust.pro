; $Id: regridh_dust.pro,v 1.1.1.1 2007/07/17 20:41:33 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        REGRIDH_DUST
;
; PURPOSE:
;        Horizontally regrids mineral dust concentrations [kg/m3]
;        from one CTM grid to another.
;
; CATEGORY:
;        Regridding
;
; CALLING SEQUENCE:
;        REGRIDH_DUST [, Keywords ]
;
; INPUTS:
;        None
;
; KEYWORD PARAMETERS:
;        MONTH -> Month of year for which to process data.  Default is
;             1 (January).  Since the dust files are very large, it may
;             take several iterations to regrid an entire year of
;             data.  You can break the job down 1 month at a time.
;
;        INFILENAME -> Name of the file containing the dust data 
;             which is to be regridded.  If INFILENAME is not specified,
;             then REGRIDH_DUST will prompt the user to specify a file
;             name via a dialog box.
;
;        OUTMODELNAME -> A string containing the name of the model 
;             grid onto which the data will be regridded.  If not
;             specified, then OUTMODELNAME will be set to the same
;             value as the grid stored in INFILENAME.
;
;        OUTRESOLUTION -> Specifies the resolution of the model grid
;             onto which the data will be regridded.  OUTRESOLUTION
;             can be either a 2 element vector with [ DI, DJ ] or
;             a scalar (DJxDI: 8=8x10, 4=4x5, 2=2x2.5, 1=1x1, 
;             0.5=0.5x0.5).  Default for all models is 4x5.
;
;        OUTFILENAME -> Name of the directory where the output file will
;             be written.  If not specified, then a dialog box
;             will ask the user to supply a file name.
;
;        DIAGN -> Diagnostic category of data block that you want
;             to regrid.  Default is "MDUST-$".
;
; OUTPUTS:
;        None
;
; SUBROUTINES:
;        External Subroutines Required:
;        ======================================================
;        CTM_GRID     (function)   CTM_TYPE          (function)
;        CTM_REGRID   (function)   CTM_NAMEXT        (function)  
;        CTM_RESEXT   (function)   CTM_MAKE_DATAINFO (function)
;        CTM_WRITEBPCH             GETMODELANDGRIDINFO
;        UNDEFINE
;
; REQUIREMENTS:
;        None
;
; NOTES:
;        None
;
; EXAMPLE:
;        REGRIDH_DUST, INFILENAME='dust.geos3.2x25', $
;                      OUTRESOLUTION=4,              $
;                      OUTFILENAME='dust.geos3.4x5'
;           
;             ; Regrids dust data from 2 x 2.5 native resolution
;             ; to 4 x 5 resolution for the GEOS-3 grid
;
; MODIFICATION HISTORY:
;        bmy, 09 Jun 2000: VERSION 1.00
;        rvm, 18 Jun 2000: VERSION 1.01
;        bmy, 07 Jul 2000: VERSION 1.10
;                          - added OUTDIR keyword
;                          - save regridded data one month at a time
;                            since regridding takes so long 
;        bmy, 19 Dec 2003: VERSION 1.11
;                          - Rewritten for GAMAP v2-01
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
; or phs@io.as.harvard.edu with subject "IDL routine regridh_dust"
;-----------------------------------------------------------------------

pro RegridH_Dust, Month=Month,               InFileName=InFileName,       $
                  OutModelName=OutModelName, OutResolution=OutResolution, $
                  OutFileName=OutFileName,   DiagN=DiagN,                 $
                  _EXTRA=e
 
   ;====================================================================
   ; Initialization
   ;====================================================================

   ; External functions
   FORWARD_FUNCTION CTM_Type,   CTM_Grid,   CTM_RegridH, $
                    CTM_NamExt, CTM_ResExt, CTM_Make_DataInfo

   ; Keywords
   if ( N_Elements( Month         ) eq 0 ) then Month         = Indgen(12)+1
   if ( N_Elements( DiagN         ) eq 0 ) then DiagN         = 'MDUST-$'
   if ( N_Elements( OutResolution ) eq 0 ) then OutResolution = 4

   ; TAU = time values (hours) for indexing each month
   Tau = [ 0D,    744D,  1416D, 2160D, 2880D, 3624D, $
           4344D, 5088D, 5832D, 6552D, 7296D, 8016D, 8760D ]
 
   ; First time flag
   FirstTime = 1L

   ;====================================================================
   ; Process data
   ;====================================================================

   ; TAU0 value for this month
   ThisTau = Tau[ Month - 1L ]

   ; Read dust data from binary punch file
   CTM_Get_Data, DataInfo, DiagN, FileName=InFileName, Tau0=ThisTau

   ; Loop over selected data blocks
   for D = 0L, N_Elements( DataInfo )-1L do begin

      ; Echo info
      Print, 'Now Processing: ' + DataInfo[D].TracerName
      
      ;-----------------
      ; INPUT GRID
      ;-----------------

      ; Get MODELINFO and GRIDINFO structures
      GetModelAndGridInfo, DataInfo[D], InType, InGrid

      ; Compute grid box volumes [m3] on INPUT GRID
      GEOS  = ( InType.Family eq 'GEOS' OR InType.Family eq 'GENERIC' )
      GISS  = ( InType.Family eq 'GISS' )
      FSU   = ( InType.Family eq 'FSU'  )
      InVol = CTM_BoxSize( InGrid, GEOS=GEOS, GISS=GISS, FSU=FSU, /Vol, /M3 )

      ; Pointer to the INPUT data
      Pointer = DataInfo[D].Data

      ; Error check Pointer
      if ( not Ptr_Valid( Pointer ) ) then Message, 'Invalid Pointer!'

      ; Dereference the pointer to the data
      InData  = *( Pointer )

      ; Free the associated pointer heap memory
      Ptr_Free, Pointer
      
      ;-----------------
      ; OUTPUT GRID
      ;-----------------      

      ; If OUTMODELNAME is not passed, use same modelname as INPUT GRID
      if ( N_Elements( OutModelName ) ne 1 ) then OutModelName = InType.Name

      ; Get MODELINFO and GRIDINFO structures
      OutType = CTM_Type( OutModelName, Res=OutResolution )
      OutGrid = CTM_Grid( OutType )

      ; Save OUTTYPE for future use
      OutTypeSav = OutType

      ;-----------------
      ; REGRID DATA
      ;-----------------

      ; Reuse saved mapping weights?
      US =  1L - FirstTime

      ; Regrid data from INPUT GRID to OUTPUT GRID
      OutData = CTM_RegridH( InData,         InGrid,  OutGrid, $
                             /Per_Unit_Area, /Double, Use_Saved=US )

      ;------------------
      ; SAVE DATA BLOCKS
      ;------------------
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
                                   Dim=[ OutGrid.IMX,          $
                                         OutGrid.JMX,          $
                                         DataInfo[D].Dim[2],   $
                                         DataInfo[D].Dim[3] ], $
                                   First=[1L, 1L, 1L],         $
                                   /No_Global )
 
      ; Error check
      if ( not Success ) then Message, 'Could not make data block!'

      ; Save into NEWDATAINFO array of structures
      if ( FirstTime )                                         $
         then NewDataInfo = ThisDataInfo                       $
         else NewDataInfo = [ NewDataInfo, ThisDataInfo ]

      ; Reset first-time flag
      FirstTime = 0L
   endfor
 
   ;====================================================================
   ; Save data to disk
   ;====================================================================

   ; Default OUTFILENAME
   if ( N_Elements( OutFileName ) ne 1 ) then begin
      OutFileName = 'dust.' + CTM_NamExt( OutTypeSav ) + $
                    '.'     + CTM_ResExt( OutTypeSav )
   endif

   ; Write to binary punch format
   CTM_WriteBpch, NewDataInfo, ThisFileInfo, FileName=OutFileName
   
end
