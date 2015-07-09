; $Id: create_tagox_restart.pro,v 1.1.1.1 2007/07/17 20:41:38 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        CREATE_TAGOX_RESTART
;
; PURPOSE:
;        Creates an initial tagged-Ox restart file w/ 13 tracers
;        (i.e. corresponding to Arlene Fiore's original runs)
;
; CATEGORY:
;        File & I/O
;
; CALLING SEQUENCE:
;        CREATE_TAGOX_RESTART
;
; INPUTS:
;        None
;        
; KEYWORD PARAMETERS:
;        FILENAME -> Name of full-chemistry restart file containing Ox 
;             data (stored under tracer #2) to be used in creating a 
;             Tagged Ox restart file.
;
;        OUTFILENAME -> Name of the Tagged Ox restart file that will
;             be created.  Default is "restart.Ox".
;
;        /ZERO_STRAT -> Set this
;         
; OUTPUTS:
;        None
;
; SUBROUTINES:
;        External subroutines required:
;        ==============================
;        CTM_GRID          (function)  
;        CTM_MAKE_DATAINFO (function)
;        CTM_WRITEBPCH
;
; REQUIREMENTS:
;        None
;
; NOTES:
;        Assumes Ox tracers have an offset of 40.
;
; EXAMPLE:
;        CREATE_TAGOX_RESTART, FILENAME='gctm.trc.20010701', $
;                              OUTFILENAME="gctm.trc.20010701.Ox'
;             
;             ; Reads Ox from a full chemistry restart file and
;             ; creates a tagged-Ox restart file for initial spinup.
;
; MODIFICATION HISTORY:
;        bmy, 18 Aug 2003: VERSION 1.01
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
;
;-
; Copyright (C) 2003-2007, 
; Bob Yantosca and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of 
; this software. If this software shall be used commercially or 
; sold as part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.as.harvard.edu with subject  "IDL routine create_tagox_restart"
;-----------------------------------------------------------------------


pro Create_TagOx_Restart, InFileName=InFileName,   $  
                          OutFileName=OutFileName, $
                          Zero_Strat=Zero_Strat,   $
                          _EXTRA=e

   ;====================================================================
   ; Initialization
   ;====================================================================

   ; External functions
   FORWARD_FUNCTION CTM_Grid, CTM_Make_DataInfo, CTM_Get_DataBlock

   ; Keywords
   if ( N_Elements( OutFileName ) ne 1 ) then OutFileName = 'restart.Ox'
   Zero_Strat = Keyword_Set( Zero_Strat )

   ; First-time flag
   FirstTime = 1L
 
   ;====================================================================
   ; Read data from FILENAME
   ;====================================================================

   ; Read all datablocks corresponding to Ox
   CTM_Get_Data, DataInfo, 'IJ-AVG-$', Tracer=2, FileName=InFileName, _EXTRA=e

   ; Loop over data blocks
   for D = 0L, N_Elements( DataInfo ) - 1L do begin

      ; Extract fields from DATAINFO structure
      Unit   = StrTrim( DataInfo[D].Unit, 2 )
      Tracer = DataInfo[D].Tracer mod 100L
      Data   = *( DataInfo[D].Data )

      ; Get size of data
      SData  = Size( Data, /Dim )

      ; Get MODELINFO and GRIDINFO structures
      GetModelAndGridInfo, DataInfo[D], InType, InGrid 

      ;;### KLUDGE: Reset Name for 30-layer GEOS-3 model
      ;if ( InType.Name eq 'GEOS3' and SData[2] eq 30 ) then begin
      ;   InType      = CTM_Type( 'GEOS3_30L', Res=InType.Resolution )
      ;   InGrid      = CTM_Grid( InType )
      ;   InType.Name = 'GEOS3_30L'
      ;endif

      ;print, '### Name: ', InType.NAME
      ;print, '### Grid: ', InGrid.LMX
      ;goto, next
      
      ; Adjust for ppbv --> v/v
      if ( StrPos( StrUpCase( Unit ), 'PPB' ) ge 0 ) then begin 
         Data = Data * 1e-9
         Unit = 'v/v'
      endif

      ; Adjust for pptv --> v/v
      if ( StrPos( StrUpCase( Unit ), 'PPT' ) ge 0 ) then begin 
         Data = Data * 1e-12
         Unit = 'v/v'
      endif
      
      ;=================================================================
      ; Zero data that is above the tropopause (if necessary)
      ;=================================================================
      if ( Zero_Strat and D eq 0 ) then begin

         ; Annual mean tropopause file
         TFile = '/data/ctm/GEOS_4x5/ann_mean_trop_200202/ann_mean_trop.' + $
                 CTM_NamExt( InType ) + '.' + CTM_ResExt( InType )

         ; Read tropopause file
         Success = CTM_Get_DataBlock( LTrop,     'TR-PAUSE', $
                                      File=TFile, Tracer=1,  $
                                      /Quiet,     /NoPrint )

         ; Convert from FORTRAN to IDL notation
         LTrop = Long( LTrop ) - 1L

         ; Zero places higher than the tropopause
         for J = 0L, InGrid.JMX-1L do begin
         for I = 0L, InGrid.IMX-1L do begin
            Data[ I, J, LTrop[I,J]:* ] = 0e0
         endfor
         endfor
      endif

      ;=================================================================
      ; Create a tagged-Ox restart file which corresponds to tracers
      ; defined by Arlene Fiore.  Tracers 1 and 12 are initialized w/
      ; data read in from the fullchem file; others are zeroed.
      ;
      ; (1 ) TOTAL O3
      ; (2 ) Upper Trop (above 350 mb)
      ; (3 ) Middle Trop (above PBL and below 350 mb)
      ; (4 ) Southern hemisphere BL (Level 1 - PBL)
      ; (5 ) Pacific BL (Level 1 - PBL)
      ; (6 ) N America BL (Level 1 - PBL)
      ; (7 ) Atlantic BL (Level 1 - PBL)
      ; (8 ) Europe BL (Level 1 - PBL)
      ; (9 ) N Africa BL (Level 1 - PBL)
      ; (10) Asia BL (Level 1 - PBL)
      ; (11) Flux in from stratosphere (specified in upbdflx_O3.f)
      ; (12) initial O3 read in from restart file 
      ; (13) USA production
      ;=================================================================
      for T = 1L, 13L do begin
             
         ; Define data for outpu
         case ( T ) of
            1    : OutData = Data
            12   : OutData = Data
            else : OutData = FltArr( InGrid.IMX, InGrid.JMX, InGrid.LMX )
         endcase

         ; Add traceroffset of 40
         NewTracer = T + 40L

         ; Make a DATAINFO structure for the 
         Success = CTM_Make_DataInfo( Float( OutData ),           $
                                      ThisDataInfo,               $
                                      ThisFileInfo,               $
                                      ModelInfo=InType,           $
                                      GridInfo=InGrid,            $
                                      DiagN=DataInfo[D].Category, $
                                      Tracer=NewTracer,           $
                                      Unit=Unit,                  $
                                      Tau0=DataInfo[D].Tau0,      $
                                      Tau1=DataInfo[D].Tau1,      $
                                      Dim=DataInfo[D].Dim,        $
                                      First=DataInfo[D].First,    $
                                      /No_Global ) 
         
         if ( not Success ) then print, 'Could not make DATAINFO structure!'

         ; Append THISDATAINFO into NEWDATAINFO array of structures
         if ( FirstTime )                                         $
            then NewDataInfo = [ ThisDataInfo ]                   $
            else NewDataInfo = [ NewDataInfo, ThisDataInfo ]
      
         ; Reset first time flag
         FirstTime = 0L

         ; Undefine for safety's sake
         UnDefine, OutData
         UnDefine, ThisDataInfo
      endfor

next:
      ; Undefine for safety's sake
      UnDefine, InType
      UnDefine, InGrid
      UnDefine, Data
      UnDefine, Unit
      UnDefine, Tracer
   endfor
   
   ;====================================================================
   ; Write to binary punch file and quit
   ;====================================================================
   CTM_WriteBpch, NewDataInfo, ThisFileInfo, FileName=OutFileName
      
   return
end
