; $Id: make_restart.pro,v 1.3 2007/07/27 18:56:41 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        MAKE_RESTART
;
; PURPOSE:
;        Creates a restart file for GEOS-Chem.  
;
; CATEGORY:
;        File & I/O, BPCH Format
;
; CALLING SEQUENCE:
;        MAKE_RESTART [, Keywords ]
;
; INPUTS:
;        None
;
; KEYWORD PARAMETERS:
;        OUTMODELNAME -> Name of the model grid onto which the data
;             will be regridded.  Default is "GEOS4_30L".
;
;        OUTRESOLUTION -> Specifies the resolution of the model grid
;             onto which the data will be regridded.  OUTRESOLUTION
;             can be either a 2 element vector with [ DI, DJ ] or
;             a scalar (DJxDI: 8=8x10, 4=4x5, 2=2x2.5, 1=1x1, 
;             0.5=0.5x0.5).  Default for all models is 4x5.
;
;        OUTFILENAME -> Name of the restart file that will be created.
;             Default is "restart.bpch".
;
;        TAU0 -> TAU value (hours from 0 GMT on 01 Jan 1985) that 
;             that will be used to timestamp the restart file.
;             The default TAU0 value 140256.00 (corresponds to 
;             0 GMT on 01 Jan 2001).
; 
;        TRACERLIST -> A scalar value (or vector) of tracer numbers
;             to write to the restart file.  Default is 1.
;      
;        DATAVALUE -> Specifies the data value that will be assigned
;             to all grid boxes in the restart file.  Default is 0e0.
;
;        DIAGN -> Specifies the diagnostic category name that will
;             be used to index data fields in the restart file.
;             Default is "IJ-AVG-$".
;
;        UNIT -> Use this keyword to overwrite the default unit
;             string (as specified in the "tracerinfo.dat" file)
;             for each data block in the restart file.
;
;        /NO_VERTICAL -> Set this switch to create a restart file
;             with 2-D data blocks (e.g. lon x lat) instead of 3-D
;             data blocks (e.g. lon x lat x alt).
;        
; OUTPUTS:
;         None
;
; SUBROUTINES:
;         External Subroutines Required:
;         ===================================================
;         CTM_GET_DATABLOCK (function)   CTM_GRID (function)   
;         CTM_MAKE_DATAINFO (function)   CTM_TYPE (function) 
;         CTM_WRITEBPCH                  NYMD2TAU
;
; REQUIREMENTS:
;         None
;
; NOTES:
;         (1) You must make sure that your "diaginfo.dat" and 
;             "tracerinfo.dat" file lists the diagnostic categories
;             and tracers that you wish to save to the restart file.
;
; EXAMPLE:
;         MAKE_RESTART, OUTMODELNAME='GEOS4_30L',              $
;                       OUTRESOLUTION=2,                       $
;                       OUTFILENAME='restart.2x25.2005010100', $
;                       TAU0=NYMD2TAU( 20050101L ),            $
;                       DATAVALUE=100e0,                       $
;                       TRACERLIST=[1,2,3,4,5,6],              $
;                       UNIT='ppbv',                           $
;                       DIAGN='IJ-AVG-$'
;
;             ; Create a GEOS-4 30-level 2x25 restart file for 
;             ; CO2 tracers 1-6, setting all tracers equal to 
;             ; 100 ppbv.
;                           
;
; MODIFICATION HISTORY:
;        bmy, 19 Jul 2007: VERSION 1.00
;
;-
; Copyright (C) 2007, 
; Bob Yantosca and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever.
; It may be freely used, copied or distributed for non-commercial
; purposes.  This copyright notice must be kept with any copy of
; this software. If this software shall be used commercially or
; sold as part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.as.harvard.edu with subject "IDL routine make_restart"
;-----------------------------------------------------------------------


pro Make_Restart, OutModelName=OutModelName,    $
                  OutResolution=OutResolution,  $
                  OutFileName=OutFileName,      $
                  Tau0=Tau0,                    $
                  TracerList=TracerList,        $
                  DataValue=DataValue,          $
                  DiagN=DiagN,                  $
                  Unit=Unit,                    $
                  No_Vertical=No_Vertical
 
   ;====================================================================
   ; Initialization
   ;====================================================================

   ; External functions
   FORWARD_FUNCTION CTM_Type, CTM_Grid, CTM_Get_DataBlock, Nymd2Tau
 
   ; keywords
   No_Vertical = Keyword_Set( No_Vertical )
   if ( N_Elements( OutModelName  ) eq 0 ) then OutModelName  = 'GEOS4_30L'
   if ( N_Elements( OutResolution ) eq 0 ) then OutResolution = 4
   if ( N_Elements( OutFileName   ) eq 0 ) then OutFileName   = 'restart.bpch'
   if ( N_Elements( Tau0          ) eq 0 ) then Tau0 = Nymd2Tau( 20010101L )
   if ( N_Elements( DataValue     ) eq 0 ) then DataValue     = 0e0
   if ( N_Elements( TracerList    ) eq 0 ) then TracerList    = [ 1L ]
   if ( N_Elements( DiagN         ) eq 0 ) then DiagN         = 'IJ-AVG-$'
   if ( N_Elements( Unit          ) eq 0 ) then Unit          = 'v/v'
 
   ; Set 1st time flag
   FirstTime  = 1L
 
   ; Set ending TAU value
   Tau1       = Tau0

   ; MODELINFO and GRIDINFO structures (change as necessary)
   ModelInfo  = CTM_Type( OutModelName, Resolution=OutResolution )
   GridInfo   = CTM_Grid( ModelInfo, No_Vertical=No_Vertical )

   ;====================================================================
   ; Create restart file
   ;==================================================================== 

   ; Define data array
   if ( No_Vertical ) then begin
      NewData = FltArr( GridInfo.IMX, GridInfo.JMX ) 
      Dim     = [ GridInfo.IMX, GridInfo.JMX, 0L, 0L ]
   endif else begin
      NewData = FltArr( GridInfo.IMX, GridInfo.JMX, GridInfo.LMX ) 
      Dim     = [ GridInfo.IMX, GridInfo.JMX, GridInfo.LMX, 0L ]
   endelse
 
   ; Set data everywhere the data value (in ppb)
   NewData[*] = DataValue
 
   ; Loop over tracers
   for N = 0L, N_Elements( TracerList ) - 1L do begin
 
      ; Call CTM_MAKE_DATAINFO to make a DATAINFO structure
      ; for this tracer.  Return this structure in THISDATAINFO
      Success = CTM_Make_DataInfo( Float( NewData ),         $
                                   ThisDataInfo,             $
                                   ThisFileInfo,             $
                                   ModelInfo=ModelInfo,      $
                                   GridInfo=GridInfo,        $
                                   DiagN=DiagN,              $
                                   Tracer=TracerList[N],     $
                                   Tau0=Tau0,                $
                                   Tau1=Tau1,                $
                                   Unit=Unit,                $
                                   Dim=Dim,                  $
                                   First=[1L, 1L, 1L] )
 
      ; Stop upon error
      if ( not Success ) then begin
         S = 'Could not make data block for tracer ' + String( N )
         Message, S
      endif
 
      ; NEWDATAINFO is an array of DATAINFO Structures
      ; Append THISDATAINFO onto the NEWDATAINFO array
      if ( FirstTime )                                       $             
         then NewDataInfo = [ ThisDataInfo              ]    $
         else NewDataInfo = [ NewDataInfo, ThisDataInfo ]
 
      ; Reset the first time flag
      FirstTime = 0L
 
      ; Undefine THISDATAINFO for safety's sake
      UnDefine, ThisDataInfo
 
   endfor                       
 
   ; Write binary punch file
   CTM_WriteBpch, NewDataInfo, FileName=OutFileName
 
end
