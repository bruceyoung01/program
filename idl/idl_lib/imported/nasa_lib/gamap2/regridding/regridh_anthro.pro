; $Id: regridh_anthro.pro,v 1.1.1.1 2007/07/17 20:41:32 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        REGRIDH_ANTHRO
;
; PURPOSE:
;        Regrids 1 x 1 GEIA anthropogenic emissions "merge file" 
;        onto a CTM grid of equal or coarser resolution.
;
; CATEGORY:
;        Regridding
;
; CALLING SEQUENCE:
;        REGRIDH_ANTHRO [, Keywords ]
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
;        OUTFILENAME -> Name of the directory where the output file will
;             be written.  Default is 'merge_nobiofuels.geos.{resolution}'.  
;
;        /COPY -> If set, will just copy the 1 x 1 data from the ASCII
;             file to a binary punch file format, w/o regridding.
;
; OUTPUTS:
;        Writes to binary "merge" file:
;             merge.{MODELNAME}.{RESOLUTION}.bpch
;
; SUBROUTINES:
;        External Subroutines Required:
;        =================================================
;        CTM_GRID    (function)   CTM_TYPE   (function)
;        CTM_BOXSIZE (function)   CTM_REGRID (function)
;        CTM_RESEXT  (function)   CTM_MAKE_DATAINFO (function)

;
; REQUIREMENTS:
;        References routines from the GAMAP and TOOLS packages.
;
; NOTES:
;        (1) The path names for the files containing 1 x 1 data are
;            hardwired -- change this number as is necessary.
;
;        (2) Also assumes 10 fossil fuel emission species -- 
;            change this number as is necessary.
;
;        (3) Now use CTM_REGRIDH, which is much quicker since it
;            saves the mapping weights
;
; EXAMPLE:
;        REGRIDH_ANTHRO, OUTMODELNAME='GEOS_STRAT', $
;                        OUTRESOLUTION=4 
;           
;             ; Regrids 1 x 1 GEIA fossil fuel emissions onto the
;             ; 4 x 5 GEOS-STRAT grid.  The default output filename
;             ; will be "merge_nobiofuels.geos.4x5".  
;
; MODIFICATION HISTORY:
;        bmy, 01 Aug 2000: VERSION 1.00
;        bmy, 14 Mar 2001: VERSION 1.01
;                          - now write output to binary punch file format
;        bmy, 30 Oct 2001: VERSION 1.02
;                          - added /COPY keyword
;                          - now can also copy data from 1 x 1 ASCII
;                            file to binary punch file w/o regridding
;        bmy, 09 Jan 2003: VERSION 1.03
;                          - renamed to "regridh_anthro.pro"
;                          - now uses CTM_REGRIDH, which is faster
;                            when regridding multiple arrays
;
;-
; Copyright (C) 2000-2003, Bob Yantosca, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author.
; Bugs and comments should be directed to bmy@io.harvard.edu
; with subject "IDL routine regrid_anthro"
;-----------------------------------------------------------------------


pro RegridH_Anthro, OutModelName=OutModelName,   $
                    OutResolution=OutResolution, $
                    OutFileName=OutFileName,     $
                    Copy=Copy,                   $
                    _EXTRA=e
 
   ;====================================================================
   ; Initialization
   ;====================================================================

   ; External Functions
   FORWARD_FUNCTION CTM_Type, CTM_Grid, CTM_RegridH, CTM_ResExt, $
                    CTM_Make_DataInfo

   ; Keywords
   Copy = Keyword_Set( Copy )
   if ( N_Elements( OutModelName  ) eq 0 ) then OutModelName  = 'GEOS1'
   if ( N_Elements( OutResolution ) eq 0 ) then OutResolution = 4

   ; Input file name -- change if necessary
   InFileName = $
      '~bmy/archive/data/fossil_200104/1x1_gen/merge_nobiofuels.1x1_STD_SASS'

   ; Input grid
   InType = CTM_Type( 'generic', res=[1, 1], HalfPolar=0, Center180=0 )
   InGrid = CTM_Grid( InType, /No_Vertical )

   ; Output grid
   OutType = CTM_Type( OutModelName, Resolution=OutResolution )
   OutGrid = CTM_Grid( OutType, /No_Vertical )

   ; Default OUTFILENAME
   if ( N_Elements( OutFileName ) ne 1 ) $
      then OutFileName = 'merge_nobiofuels.geos.' + CTM_ResExt( OutType ) 
      
   ;====================================================================
   ; Read data from the 1 x 1 emissions file
   ;====================================================================
   Message, 'Reading 1 x 1 emissions data...', /Info

   ; Number of seasons for NOx, SOx
   N_Seasons = 4L

   ; Number of levels for NOx, SOx
   N_Levels  = 2L

   ; Declare arrays
   InNOx    = FltArr( InGrid.IMX, InGrid.JMX, N_Seasons, N_Levels )
   InCO     = FltArr( InGrid.IMX, InGrid.JMX                      )
   InETHE   = FltArr( InGrid.IMX, InGrid.JMX                      )
   InPRPE   = FltArr( InGrid.IMX, InGrid.JMX                      )
   InC2H6   = FltArr( InGrid.IMX, InGrid.JMX                      )
   InC3H8   = FltArr( InGrid.IMX, InGrid.JMX                      )
   InALK4   = FltArr( InGrid.IMX, InGrid.JMX                      )
   InACET   = FltArr( InGrid.IMX, InGrid.JMX                      )
   InMEK    = FltArr( InGrid.IMX, InGrid.JMX                      )
   InSOx    = FltArr( InGrid.IMX, InGrid.JMX, N_Seasons, N_Levels )

   ; Open file
   Open_File, InFileName, Ilun, /Get_LUN
   
   ; Read data
   ReadF, Ilun, Format='(7e10.3)',                 $
      InNOx,  InCO,   InETHE, InPRPE, InC2H6, $
      InC3H8, InALK4, InACET, InMEK,  InSOx

   ; Close file
   Close,    Ilun
   Free_LUN, Ilun

   ;====================================================================
   ; If we are just copying the 1 x 1 data to binary punch file format,
   ; then copy old arrays into new arrays and skip ahead
   ;====================================================================
   if ( Keyword_Set( Copy ) ) then begin
      OutType = InType
      OutGrid = InGrid
      OutArea = InArea
      OutNOx  = InNOx
      OutSOx  = InSOx
      OutCO   = InCO
      OutETHE = InETHE 
      OutPRPE = InPRPE 
      OutC2H6 = InC2H6 
      OutC3H8 = InC3H8 
      OutALK4 = InALK4 
      OutACET = InACET 
      OutMEK  = InMEK  
      goto, Skip1x1
   endif

   ;====================================================================
   ; Regrid data from 1 x 1 to CTM resolution
   ;====================================================================
   OutNOx = FltArr( OutGrid.IMX, OutGrid.JMX, N_Seasons, N_Levels )
   OutSOx = FltArr( OutGrid.IMX, OutGrid.JMX, N_Seasons, N_Levels )
   
   ; Loop over seasons & levels for NOx & SOx
   for L = 0L, N_Levels  - 1L do begin
   for N = 0L, N_Seasons - 1L do begin
      OutNOx[*,*,N,L] = CTM_RegridH( InNOx[*,*,N,L], InGrid, OutGrid, $
                                     /Per_Unit_Area, /Double, Use_Saved=0 )

      OutSOx[*,*,N,L] = CTM_RegridH( InSOx[*,*,N,L], InGrid, OutGrid, $
                                     /Per_Unit_Area, /Double, /Use_Saved )
   endfor
   endfor

   ; Other species are aseasonal and have only one level
   OutCO   = CTM_RegridH( InCO,           InGrid, OutGrid,    $
                          /Per_Unit_Area, /Double, /Use_Saved )
 
   OutETHE = CTM_RegridH( InETHE,         InGrid, OutGrid,     $
                          /Per_Unit_Area, /Double, /Use_Saved )

   OutPRPE = CTM_RegridH( InPRPE,         InGrid, OutGrid,     $
                          /Per_Unit_Area, /Double, /Use_Saved )

   OutC2H6 = CTM_RegridH( InC2H6,         InGrid, OutGrid,     $
                          /Per_Unit_Area, /Double, /Use_Saved )

   OutC3H8 = CTM_RegridH( InC3H8,         InGrid, OutGrid,     $
                          /Per_Unit_Area, /Double, /Use_Saved )

   OutALK4 = CTM_RegridH( InALK4,         InGrid, OutGrid,     $
                          /Per_Unit_Area, /Double, /Use_Saved )

   OutACET = CTM_RegridH( InACET,         InGrid, OutGrid,     $
                          /Per_Unit_Area, /Double, /Use_Saved )

   OutMEK  = CTM_RegridH( InMEK,          InGrid, OutGrid,     $
                          /Per_Unit_Area, /Double, /Use_Saved )

   ;====================================================================
   ; Make DATAINFO structures for seasonal NOx values
   ;====================================================================
Skip1x1:

   ; Set first-time flag
   FirstTime = 1L

   for N = 0L, 3L do begin
      
      ; Set TAU values for seasons: DJF/MAM/JJA/SON
      case ( N ) of 
         0: Tau = [ -744D, 1416D ]
         1: Tau = [ 1416D, 3624D ]
         2: Tau = [ 3624D, 5832D ]
         3: Tau = [ 5832D, 8016D ]
      endcase

      ; There are 2 levels of NOx for every season
      Data = Reform( OutNOx[*, *, N, *] )

      ; Make a DATAINFO structure for each season of NOx
      Success = CTM_Make_DataInfo( Float( Data ),            $
                                   ThisDataInfo,             $
                                   ThisFileInfo,             $
                                   ModelInfo=OutType,        $
                                   GridInfo=OutGrid,         $
                                   DiagN='ANTHSRCE',         $
                                   Tracer=1,                 $
                                   TrcName='NOx',            $
                                   Tau0=Tau[0],              $
                                   Tau1=Tau[1],              $
                                   Unit='molec/cm2/s',       $
                                   Dim=[OutGrid.IMX,         $
                                        OutGrid.JMX, 2, 0],  $
                                   First=[1L, 1L, 1L] )
 
      ; NEWDATAINFO is an array of DATAINFO Structures
      ; Append THISDATAINFO onto the NEWDATAINFO array
      if ( FirstTime )                                       $       
         then NewDataInfo = [ ThisDataInfo ]                 $
         else NewDataInfo = [ NewDataInfo, ThisDataInfo ]

      ; Reset the first time flag
      FirstTime = 0L

      ; Undefine variables for safety's sake
      UnDefine, ThisDataInfo
      UnDefine, Data
   endfor

   ;====================================================================
   ; Make DATAINFO structures for hydrocarbon species
   ;====================================================================
   for N = 0L, 7L do begin

      case ( N ) of
         0: begin
            Data    = OutCO
            Trc     = 4
            Unit    = 'molec/cm2/s'
         end

         1: begin
            Data    = OutALK4
            Trc     = 5
            Unit    = 'molec C/cm2/s'
         end
         
         2: begin
            Data    = OutACET
            Trc     = 9
            Unit    = 'molec C/cm2/s'
         end

         3: begin
            Data    = OutMEK
            Trc     = 10
            Unit    = 'molec C/cm2/s'
         end
            
         4: begin    
            Data    = OutPRPE
            Trc     = 18
            Unit    = 'molec C/cm2/s'
         end

         5: begin
            Data    = OutC3H8
            Trc     = 19
            Unit    = 'molec C/cm2/s'
         end

         6: begin
            Data    = OutC2H6
            Trc     = 21
            Unit    = 'molec C/cm2/s'
         end

         7: begin 
            Data    = OutETHE
            Trc     = 26
            Unit    = 'molec C/cm2/s'
         end
      endcase

      ; Make a DATAINFO structure for this NEWDATA
      Success = CTM_Make_DataInfo( Float( Data ),            $
                                   ThisDataInfo,             $
                                   ThisFileInfo,             $
                                   ModelInfo=OutType,        $
                                   GridInfo=OutGrid,         $
                                   DiagN='ANTHSRCE',         $
                                   Tracer=Trc,               $
                                   Tau0=0D,                  $
                                   Tau1=8760D,               $
                                   Unit=Unit,                $
                                   Dim=[OutGrid.IMX,         $
                                        OutGrid.JMX, 0, 0],  $
                                   First=[1L, 1L, 1L],       $
                                   /No_Global )
 
      ; NEWDATAINFO is an array of DATAINFO Structures
      ; Append THISDATAINFO onto the NEWDATAINFO array
      if ( FirstTime )                                       $             
         then NewDataInfo = [ ThisDataInfo ]                 $
         else NewDataInfo = [ NewDataInfo, ThisDataInfo ]

      ; Reset the first time flag
      FirstTime = 0L

      ; Undefine variables for safety's sake
      UnDefine, ThisDataInfo
      UnDefine, Data
      UnDefine, Trc
      UnDefine, TrcName
      UnDefine, Unit
   endfor

   ;====================================================================
   ; Handle seasonal SOx
   ;====================================================================
   for N = 0L, 3L do begin
      
      ; Set TAU values for seasons: DJF/MAM/JJA/SON
      case ( N ) of 
         0: Tau = [ -744D, 1416D ]
         1: Tau = [ 1416D, 3624D ]
         2: Tau = [ 3624D, 5832D ]
         3: Tau = [ 5832D, 8016D ]
      endcase

      ; There are 2 levels of NOx for every season
      Data = Reform( OutSOx[*, *, N, *] )

      ; Make a DATAINFO structure for each season of NOx
      Success = CTM_Make_DataInfo( Float( Data ),            $
                                   ThisDataInfo,             $
                                   ThisFileInfo,             $
                                   ModelInfo=OutType,        $
                                   GridInfo=OutGrid,         $
                                   DiagN='ANTHSRCE',         $
                                   Tracer=27,                $
                                   TrcName='SOx',            $
                                   Tau0=Tau[0],              $
                                   Tau1=Tau[1],              $
                                   Unit='molec/cm2/s',       $
                                   Dim=[OutGrid.IMX,         $
                                        OutGrid.JMX, 2, 0],  $
                                   First=[1L, 1L, 1L] )
 
      ; Append THISDATAINFO onto the NEWDATAINFO array
      NewDataInfo = [ NewDataInfo, ThisDataInfo ]

      ; Undefine variables for safety's sake
      UnDefine, ThisDataInfo
      UnDefine, Data
   endfor

   ;====================================================================
   ; Write to binary punch file 
   ;====================================================================
   CTM_WriteBpch, NewDataInfo, FileName=OutFileName

   ; Quit
   return
end
