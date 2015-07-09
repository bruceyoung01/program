; $Id: merge_oh.pro,v 1.1.1.1 2007/07/17 20:41:34 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        MERGE_OH
;
; PURPOSE:
;        Creates a "Merged OH" file, with OH from the GEOS-CHEM 
;        model in the troposphere and zonal mean OH from a 2-D 
;        model in the stratosphere.
;
; CATEGORY:
;        Regridding
;
; CALLING SEQUENCE:
;        MERGE_OH, MODELNAME
;
; INPUTS:
;        None
;       
; KEYWORD PARAMETERS:
;        MODELNAME -> Name of the model (e.g. GEOS1, GEOS-STRAT) 
;             for which we are going to merge tropospheric OH with 
;             stratospheric OH.
;
;        RESOLUTION -> Horizontal latitude resolution of the grid.
;             RESOLUTION=2 specifies 2 x 2.5 grid and
;             RESOLUTION=4 specifies 4 x 5   grid.
;
; OUTPUTS:
;        None
;
; SUBROUTINES:
;        External Subroutines Required:
;        ====================================================
;        CTM_TYPE (function)   CTM_GET_DATABLOCK (function)   
;        CTM_GRID (function)   CTM_MAKE_DATAINFO 
;
; REQUIREMENTS:
;        None
;
; NOTES:
;        (1) The output file name has the form:
;             OH_3Dglobal.{MODELNAME}.{RESOLUTION}
;
;        (2) Filenames are currently hardwired for 4x5,
;              
; EXAMPLE:
;        MERGE_OH, MODELNAME='GEOS3', RESOLUTION=4
; 
;             ; Will merge stratospheric and tropospheric OH
;             ; at the GEOS-1 4 x 5 resolution into a single 
;             ; binary punch file.
;
; MODIFICATION HISTORY:
;        bey, 21 Jul 2000: VERSION 1.00
;        bmy, 11 Aug 2000: VERSION 1.01
;                          - added standard header, updated comments
;                          - renamed to "merge_oh.pro"
;        bmy, 04 Feb 2002: VERSION 1.02
;                          - rewrote for expediency
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
; or phs@io.as.harvard.edu with subject "IDL routine merge_oh"
;-----------------------------------------------------------------------


pro Merge_OH, ModelName=ModelName, Resolution=Resolution

   ;====================================================================
   ; Initialization
   ;====================================================================

   ; External functions
   FORWARD_FUNCTION CTM_Type, CTM_Grid

   ; Keyword settings
   if ( N_Elements( ModelName  ) ne 1 ) then ModelName  = 'GEOS3'
   if ( N_Elements( Resolution ) ne 1 ) then Resolution = 4

   ;====================================================================
   ; Define variables (hardwire as necessary)
   ;====================================================================

   ; Input MODELINFO and GRIDINFO structures
   OutType = CTM_Type( ModelName, Resolution=Resolution )
   OutGrid = CTM_Grid( OutType )

   ; Select default data directory
   ;case ( Resolution ) of
   ;   2: DataDir = '/data/ctm/GEOS_2x2.5/'
   ;   4: DataDir = '/data/ctm/GEOS_4x5/'
   ;endcase

   ; Assume 4x5 for now
   DataDir = '/data/ctm/GEOS_4x5/'

   ; Select filenames based on resolution and modelname
   case( StrTrim( OutType.Name, 2 ) ) of 

      ; GEOS-1: 1994 file names and TAU values
      'GEOS1': begin
         File_T   = DataDir + 'ctm.bpch.1994'
         File_S   = DataDir + '/stratOH_200203/stratOH.geos1.4x5'
         File_AMT = DataDir + '/ann_mean_trop_200202/ann_mean_trop.geos1.4x5'
         File_Out = '/scratch/bmy/OH/OH_3Dglobal.geos1.4x5'  
      end

      ; GEOS-STRAT: 1997 file names and TAU values
      'GEOS_STRAT': begin
         File_T   = '/scratch/bmy/OH/rvm_OH.geoss.4x5'
         File_S   = DataDir + '/stratOH_200203/stratOH.geoss.4x5'
         File_AMT = DataDir + 'ann_mean_trop_200202/ann_mean_trop.geoss.4x5'
         File_Out = '/scratch/bmy/OH/OH_3Dglobal.geoss.4x5.new'         
      end

      ; GEOS-3: 2001 file names and TAU values
      'GEOS3': begin
         File_T   = '~bmy/S/OH/OH.geos3_20L.4x5'
         File_S   = DataDir + 'stratOH_200203/stratOH.geos3.4x5'
         File_AMT = DataDir + 'ann_mean_trop_200202/ann_mean_trop.geos3.4x5'
         File_Out = '~bmy/S/OH/OH_3Dglobal.geos3.4x5'         
      end

      ; GEOS-4: 2001 file names and TAU values
      'GEOS4': begin
         File_T   = '~bmy/S/geos4_oh.bpch'
         File_S   = DataDir + 'stratOH_200203/stratOH.geos4.4x5'
         File_AMT = DataDir + 'ann_mean_trop_200202/ann_mean_trop.geos4.4x5'
         File_Out = '~bmy/S/OH_3Dglobal.geos4.4x5'         
      end

   endcase

   ; Stratospheric TAU0 values (use "generic" year 1985)
   Tau_S = [   0D,  744D, 1416D, 2160D, 2880D, 3624D,        $
            4344D, 5088D, 5832D, 6552D, 7296D, 8016D, 8760D ]

   ;====================================================================
   ; Read annual mean tropopause 
   ;====================================================================
   Success = CTM_Get_DataBlock( LPause, 'TR-PAUSE', $
                                Tracer=1,           $
                                Tau0=0D,            $
                                FileName=File_AMT)
 
   ; Print max & min values of LPAUSE
   print, '### Min, max LPAUSE: ', Min( LPause, Max=M ), M

   ; First time flag
   First = 1L

   ;====================================================================
   ; Read data from the GEOS-CHEM and 2-D zonal mean OH files
   ;====================================================================
   CTM_Get_Data, DataInfo_T, 'CHEM-L=$', Tracer=1, File=File_T
   CTM_Get_Data, DataInfo_S, 'CHEM-L=$', Tracer=1, File=File_S

   ; Loop over months
   for T = 0, 11 do begin

      ; Create output data array
      OH = FltArr( OutGrid.IMX, OutGrid.JMX, OutGrid.LMX )

      ; Tropospheric OH -- from GEOS_CHEM
      OH_T = *( DataInfo_T[T].Data )

      ; error check OH_T
      Ind = Where( OH_T lt 0, C )
      if ( Ind[0] ge 0 ) then begin
         for N = 0L, C-1L do print, Ind[N], OH_T[Ind[N]], 'TROP'
         stop
      endif

      ; Stratospheric OH -- from Hans' model
      ; filter out negative numbers
      OH_S = *( DataInfo_S[T].Data )
      OH_S = Reform( OH_S )
      Ind  = Where( OH_S lt 0 )
      if ( Ind[0] ge 0 ) then OH_S[Ind] = 0.0

      ;=================================================================
      ; Merge stratospheric + tropospheric data 
      ;=================================================================
      for J = 0L, OutGrid.JMX - 1L do begin      
      for I = 0L, OutGrid.IMX - 1L do begin

         ; Get the tropopause level
         Ltrop = Lpause[I,J] - 1L

         ; Copy tropospheric values
         OH[I,J,0:Ltrop-1] = Reform( OH_T[I,J,0:Ltrop-1] )
       
         ; Copy stratospheric values
         OH[I,J,Ltrop:*] = Reform( OH_S[J,Ltrop:*] )
      endfor
      endfor
      
      ; Replace negatives with zeroes
      ; error check OH_T
      Ind = Where( OH lt 0, C )
      if ( Ind[0] gt 0 ) then begin
         for N = 0L, C-1L do begin
            print, $
           CONVERT_INDEX( Ind[N], [OutGrid.IMX, OutGrid.JMX, OutGrid.LMX] ), $
               OH[Ind[N]], Format='(3i5,1x,f15.6)'
         endfor
         stop
      endif

      ; Make a DATAINFO structure for this NEWDATA
      Success = CTM_Make_DataInfo( Float( OH ),           $
                                   ThisDataInfo,          $
                                   ThisFileInfo,          $
                                   ModelInfo=OutType,     $
                                   GridInfo=OutGrid,      $
                                   DiagN='CHEM-L=$',      $
                                   Tracer=1,              $
                                   Tau0=Tau_S[T],         $
                                   Tau1=Tau_S[T+1],       $
                                   Unit='molec/cm3',      $
                                   Dim=[OutGrid.IMX,      $
                                        OutGrid.JMX,      $
                                        OutGrid.LMX, 0],  $
                                   First=[1L, 1L, 1L],    $
                                   /No_Global )
 
      ; NEWDATAINFO is an array of DATAINFO Structures
      ; Append THISDATAINFO onto the NEWDATAINFO array
      if ( First )                                        $             
         then NewDataInfo = [ ThisDataInfo ]              $
         else NewDataInfo = [ NewDataInfo, ThisDataInfo ]

      ; Reset the first time flag
      First = 0L
      
      ; Undefine stuff for safety's sake
      UnDefine, OH
      UnDefine, OH_T
      UnDefine, OH_S
      UnDefine, ThisDataInfo

   endfor
   
   ;====================================================================
   ; Write to binary punch file 
   ;====================================================================
   CTM_WriteBpch, NewDataInfo, ThisFileInfo, FileName=File_Out

Quit:
   return
 
end
