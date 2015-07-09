; $Id$
;-----------------------------------------------------------------------
;+
; NAME:
;        REGRIDH_RESTART_2
;
; PURPOSE:
;        Regrids a 4 x 5 restart file to 2 x 2.5 resolution
;
; CATEGORY:
;        Regridding
;
; CALLING SEQUENCE:
;        REGRIDH_RESTART_2 [, Keywords ]
;
; INPUTS:
;        None
;
; KEYWORD PARAMETERS:
;        INDIR -> Name of the directory where the input files
;             are stored.  Default is './'.  
;
;        OUTMODELNAME -> A string containing the name of the model 
;             grid onto which the data will be regridded.
;
;        OUTRESOLUTION -> Specifies the resolution of the model grid
;             onto which the data will be regridded.  RESOLUTION
;             can be either a 2 element vector with [ DI, DJ ] or
;             a scalar (DJxDI: 8=8x10, 4=4x5, 2=2x2.5, 1=1x1, 
;             0.5=0.5x0.5).  Default for all models is 4x5.
;
;        OUTDIR -> Name of the directory where the output file will
;             be written.  Default is './'.  
;
; OUTPUTS:
;        None
;
; SUBROUTINES:
;        External Subroutines Required:
;        =================================================
;        CTM_GRID      (function)   CTM_TYPE    (function)
;        CTM_BOXSIZE   (function)   CTM_REGRIDH (function)
;        CTM_NAMEXT    (function)   CTM_RESEXT  (function)
;        CTM_WRITEBPCH
;
; REQUIREMENTS:
;        References routines from the GAMAP and TOOLS packages.
;
; NOTES:
;        (1) The path names for the files containing 1 x 1 data are
;            hardwired -- change as necessary!
;
;        (2) Now assumes 12 biomass burning tracers -- change this
;            number as necessary.
;
;        (3) REGRID_BIOBURN now will produce output for a whole
;            year in one file.  This is most convenient.
;
;        (4) Sometimes you might have to close all files and call
;            "ctm_cleanup.pro" in between calls to this routine.
;
; EXAMPLE:
;        REGRID_BIOBURN, MODELNAME='GEOS_STRAT', RESOLUTION=4, $
;                        MONTH=2,                TRACER=2
;           
;             ; Regrids 1 x 1 biomass burning data from February
;             ; for CO (tracer #2) onto the 4 x 5 GEOS-STRAT grid
;
; MODIFICATION HISTORY:
;        bmy, 18 Sep 2001: VERSION 1.00
;                          - adapted from REGRID_BIOBURN
;
;-
; Copyright (C) 2000, 2001, Bob Yantosca, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author.
; Bugs and comments should be directed to bmy@io.harvard.edu
; with subject "IDL routine regrid_bioburn"
;-----------------------------------------------------------------------

function GetAirMass, GridInfo, Area, P

   AirMass = DblArr( GridInfo.IMX, GridInfo.JMX, GridInfo.LMX )

   for L = 0, GridInfo.LMX - 1L do begin
      
      ; Sigma thickness
      DSig = GridInfo.SigEdge[L] - GridInfo.SigEdge[L+1]

      ; Air mass
      AirMass[*,*,L] = P[*,*] * Area[*,*] * DSig * ( 100d0 / 9.8d0 ) 
   endfor

   ; Return
   return, AirMass
end

;-----------------------------------------------------------------------------

pro RegridH_Restart_rjp, OutDir=OutDir,         OutModelName=OutModelName,   $
                       InDir=InDir,           OutResolution=OutResolution, $
                       WeightFile=WeightFile, OutFileName=OutFileName,     $
                       Copy=Copy,             _EXTRA=e
 
   ;====================================================================
   ; External Functions / Keyword Settings
   ;====================================================================
   FORWARD_FUNCTION CTM_Type,    CTM_Grid,   CTM_BoxSize, $
                    CTM_RegridH, CTM_NamExt, CTM_ResExt

   Copy = Keyword_Set( Copy )
   if ( N_Elements( InDir         ) eq 0 ) then InDir         = './'
   if ( N_Elements( InModelName   ) eq 0 ) then InModelName  = 'GEOS3_30L'
   if ( N_Elements( InResolution  ) eq 0 ) then InResolution = 4
   if ( N_Elements( OutModelName  ) eq 0 ) then OutModelName  = InModelName
   if ( N_Elements( OutResolution ) eq 0 ) then OutResolution = 2
   if ( N_Elements( OutDir        ) eq 0 ) then OutDir        = './'

   ; Hardwire filenames for now
   PSFile4x5  = '~bmy/archive/regrid/ps-ptop.geos3.4x5'
   PSFile2x25 = '~bmy/archive/regrid/ps-ptop.geos3.2x25'
   InFile     = '/scratch/rjp/run_std_v5.02/run.v5-02.geos3/gctm.trc.20000801_4x5'
   OutFile    = '/scratch/rjp/run_std_v5.02/run.v5-02.geos3/gctm.trc.20000801'

   ;====================================================================
   ; Define variables
   ;====================================================================

   ; MODELINFO, GRIDINFO structures, and surface areas for old grid
   InType  = CTM_Type( InModelName, Resolution=InResolution )
   InGrid  = CTM_Grid( InType )
   GEOS    = ( InType.Family eq 'GEOS' OR InType.Family eq 'GENERIC' )
   GISS    = ( InType.Family eq 'GISS' )
   FSU     = ( InType.Family eq 'FSU'  )
   InArea = CTM_BoxSize( InGrid, GEOS=GEOS, GISS=GISS, FSU=FSU, /cm2 )

   ; MODELINFO, GRIDINFO structures, and surface areas for new grid
   OutType = CTM_Type( OutModelName, Resolution=OutResolution )
   OutGrid = CTM_Grid( OutType )
   GEOS    = ( OutType.Family eq 'GEOS' OR OutType.Family eq 'GENERIC' )
   GISS    = ( OutType.Family eq 'GISS' )
   FSU     = ( OutType.Family eq 'FSU'  )
   OutArea = CTM_BoxSize( OutGrid, GEOS=GEOS, GISS=GISS, FSU=FSU, /cm2 )

   ;====================================================================
   ; Read data from each input file and regrid it!
   ;====================================================================

   ; Set first time flag
   First = 1L

   ; Read 4x5 surface pressure
   CTM_Get_Data, PS4x5Info,  File=PSFile4x5

   ; Read 2 x 2.5 surface pressure
   CTM_Get_Data, PS2x25Info, File=PSFile2x25

   ; Loop over each file
   for D = 0L, N_Elements( InFile ) - 1L do begin

      ; Read all data files
      CTM_Get_Data, DataInfo, File=InFile
     
      ; Loop over tracers
      for N = 0L, N_Elements( DataInfo ) - 1L do begin

         Print, N, Datainfo[N].tracername
         ; Input data (make sure it's in v/v
         InData  = *( DataInfo[N].Data ) 
         InData  = InData * 1d-9
         
         ; TAU0 of this data block
         InTau0  = DataInfo[N].Tau0
         InJD    = ( InTau0 / 24d0 ) + JulDay( 1, 1, 1985 )
         CalDat, InJD, Month, D, Y

         ; Get 4x5 pressures and air masses
         PS4x5   = *( PS4x5Info[Month-1].Data  )
         AirMass = GetAirMass( InGrid, InArea, PS4x5 )

         ; Convert from v/v to kg
         InData  = InData * AirMass

         ; reuse saved mapping weights?
         US = 1L - First

         ; Define output data array
         OutData = CTM_RegridH( InData, InGrid, OutGrid, $
                                Double=Double, Use_Saved=US )

         ; Get 4x5 pressures and air masses
         PS2x25  = *( PS2x25Info[Month-1].Data  )
         AirMass = GetAirMass( OutGrid, OutArea, PS2x25 )

         ; Convert molec/yr to molec/cm2/s
         OutData = ( OutData / Airmass )

         ; Make a DATAINFO structure for this NEWDATA
         Success = CTM_Make_DataInfo( Float( OutData ),               $
                                      ThisDataInfo,                   $
                                      ModelInfo=OutType,              $
                                      GridInfo=OutGrid,               $
                                      DiagN='IJ-AVG-$',               $ 
                                      Tracer=DataInfo[N].Tracer,      $
                                      TrcName=DataInfo[N].TracerName, $
                                      Tau0=DataInfo[N].Tau0,          $
                                      Tau1=DataInfo[N].Tau1,          $
                                      Unit='v/v',                     $
                                      Dim=[OutGrid.IMX,               $
                                           OutGrid.JMX,               $
                                           OutGrid.LMX, 0],           $
                                      First=[1L, 1L, 1L] )
 
         ; NEWDATAINFO is an array of DATAINFO Structures
         ; Append THISDATAINFO onto the NEWDATAINFO array
         if ( First )                                            $             
            then NewDataInfo = [ ThisDataInfo ]                  $
            else NewDataInfo = [ NewDataInfo, ThisDataInfo ]

         ; Reset the first time flag
         First = 0L
      
         ; Undefine variables for safety's sake
         UnDefine, InData
         UnDefine, OutData
         UnDefine, ThisDataInfo
         UnDefine, PS2x25
         UnDefine, PS4x5
         UnDefine, AirMass

Next_N:
      endfor  ; N
   endfor  ; D

   ;====================================================================
   ; Write all data blocks to a binary punch file
   ;====================================================================
   CTM_WriteBpch, NewDataInfo, FileName=OutFile
      
   ; Quit
   return
end
