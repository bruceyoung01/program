; $Id: trop_cut.pro,v 1.1.1.1 2007/07/17 20:41:33 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        TROP_CUT
;
; PURPOSE:
;        Reads a CTM data block and then only saves data from the
;        surface up to the maximum tropopause level. (e.g. the 
;        field MODELINFO.NTROP, returned from function CTM_TYPE).
;
; CATEGORY:
;        Regridding
;
; CALLING SEQUENCE:
;        TROP_CUT [, Keywords ]
;
; INPUTS:
;        None
;
; KEYWORD PARAMETERS:
;        INFILENAME -> Name of the file containing data to be regridded.
;             If INFILENAME is not specified, then REGRIDH_RESTART
;             will prompt the user to select a file via a dialog box.
;
;        OUTFILENAME -> Name of the file which will contain the regridded 
;             data.  Default is INFILENAME + '.trop'.
;
; OUTPUTS:
;        None
;
; SUBROUTINES:
;        External Subroutines Required:
;        ==================================================
;        CTM_GET_DATA          CTM_MAKE_DATAINFO (function)
;        GETMODELANDGRIDINFO   UNDEFINE
;        
; REQUIREMENTS:
;        References routines from both GAMAP and TOOLS packages
;
; NOTES:
;        None
;
; EXAMPLE:
;        TROP_CUT, INFILENAME='data.geos3.4x5',      $
;                  OUTFILENAME='trop_data.geos3.4x5'
;
;             ; Reads data from "data.geos3.4x5".  Saves data
;             ; from the surface up to level MODELINFO.NTROP
;             ; and writes to file trop_data.geos3.4x5".
;              
; MODIFICATION HISTORY:
;        bmy, 31 Oct 2002: VERSION 1.00
;        bmy, 25 Sep 2003: VERSION 1.01
;                          - Call PTR_FREE to free the pointer heap memory
;  bmy & phs, 20 Jun 2007: GAMAP VERSION 2.10
;                          - Use FILE_WHICH to locate surf prs files
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
; or phs@io.as.harvard.edu with subject "IDL routine trop_cut"
;-----------------------------------------------------------------------


pro Trop_Cut, InFileName=InFileName, OutFileName=OutFileName, _EXTRA=e 
    
   ;====================================================================
   ; Initialization
   ;====================================================================
      
   ; Set first time flag
   FirstTime = 1L

   ;================================================================
   ; Read data and cut to size
   ;================================================================

   ; Read data
   CTM_Get_Data, DataInfo, FileName=InFileName, _EXTRA=e
   
   ; Loop over all data blocks
   for D = 0L, N_Elements( DataInfo )-1L do begin
      
      ; Get MODELINFO and GRIDINFO structures
      GetModelAndGridInfo, DataInfo[D], ModelInfo, GridInfo

      ; Pointer to the data
      Pointer = DataInfo[D].Data

      ; Error check pointer
      if ( not Ptr_Valid( Pointer ) ) then Message, 'Invalid Pointer!'

      ; Dereference the pointer to get the data
      InData  = *( Pointer )

      ;---------------------------------------------
      ; Prior to 7/13/07:
      ;; Free the associated pointer heap memory
      ;Ptr_Free, Pointer
      ;---------------------------------------------

      ; Get unit of the data
      InUnit  = StrUpCase( StrTrim( DataInfo[D].Unit, 2 ) )

      ; Convert from [ppbv] or [pptv] to [v/v] if necessary
      if ( StrPos( InUnit, 'PPB' ) ge 0 ) then begin
         InData           = InData * 1d-9
         DataInfo[D].Unit = 'v/v'
      endif else if ( StrPos( InUnit, 'PPT' ) ge 0 ) then begin
         InData           = InData * 1d-12
         DataInfo[D].Unit = 'v/v'            
      endif

      ; Only save from the surface up to the max tropopause level
      InData             = InData[*,*,0L:ModelInfo.NTROP-1L]
      DataInfo[D].Dim[2] = ModelInfo.NTROP

      ; Make a DATAINFO structure for each month of OH data
      Success = CTM_Make_DataInfo( Float( InData ),            $
                                   ThisDataInfo,               $
                                   ThisFileInfo,               $
                                   ModelInfo=ModelInfo,        $
                                   GridInfo=GridInfo,          $
                                   DiagN=DataInfo[D].Category, $
                                   Tracer=DataInfo[D].Tracer,  $
                                   Tau0=DataInfo[D].Tau0,      $
                                   Tau1=DataInfo[D].Tau1,      $
                                   Unit=DataInfo[D].Unit,      $
                                   Dim=DataInfo[D].Dim,        $
                                   First=DataInfo[D].First,    $
                                   /No_Global ) 
 
      ; Store all data blocks in the NEWDATAINFO array of structures
      if ( FirstTime )                                         $
         then NewDataInfo = ThisDataInfo                       $
         else NewDataInfo = [ NewDataInfo, ThisDataInfo ]
      
      ; Reset first time flag
      FirstTime = 0L

      ; Undefine stuff
      UnDefine, InData
   endfor

   ;=================================================================   
   ; Write all data blocks to disk
   ;=================================================================
   
   ; Default OUTFILENAME
   if ( N_Elements( OutFileName ) ne 1 ) then begin
      OutFileName = InFileName + '.trop'
   endif

   ; Save as binary punch format
   CTM_WriteBpch, NewDataInfo, ThisFileInfo, FileName=OutFileName
 
end                               
 
    
 
