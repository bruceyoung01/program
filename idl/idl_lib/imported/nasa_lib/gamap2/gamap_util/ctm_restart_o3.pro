; $Id: ctm_restart_o3.pro,v 1.1.1.1 2007/07/17 20:41:28 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        CTM_RESTART_O3
;
; PURPOSE:
;        Merges single-tracer Ox data into a full-chemistry
;        CTM restart file.
;
; CATEGORY:
;        GAMAP Utilities
;
; CALLING SEQUENCE:
;        CTM_RESTART_O3 [, BATCHFILE [, Keywords ] ]
;
; INPUTS:
;        BATCHFILE (optional) -> Name of the input file containing
;             the names of the full chemistry restart file, the
;             single tracer O3 file, the annual mean tropopause file,
;             and the output file.  If BATCHFILE is omitted, then the
;             user will be prompted to make a selection via a dialog box.
;
; KEYWORD PARAMETERS:
;        /STRAT_ONLY -> Set this keyword to only merge the stratospheric
;             Ox into the full chemistry restart file.  Stratospheric 
;             levels are determined by reading in the annual mean 
;             tropopause file (as specified in BATCHFILE).  Default is
;             to merge all levels into the full chemistry restart file.
;
; OUTPUTS:
;        Will write merged data to an output file whose name is
;        specified in BATCHFILE.
;
; SUBROUTINES:
;        External subroutines required:
;        ------------------------------------------------------
;        CTM_GRID     (function)  CTM_GET_DATABLOCK (function)
;        CTM_GET_DATA             OPEN_FILE
;        STR2BYTE     (function)
;
; REQUIREMENTS:
;        None
;
; NOTES:
;        CTM_RESTART_O3 is currently only applicable to the GEOS-CTM,
;        since this is the only model that can run single tracer Ox.
;
;        A Sample BATCHFILE is given below.  There must be 3 header 
;        lines before the first file name:
;
;CTM_RESTART_O3.DAT -- defines filenames to read in for merging single 
;                      tracer Ox data into a full chem restart file
;=============================================================================
;Full Chem File : /r/amalthea/N/scratch/bmy/run_3.2/gctm.trc.941001
;Ox Run File    : /r/amalthea/N/scratch/bmy/run_o3_3.2/gctm.trc.941001
;T-Pause File   : /r/amalthea/Li/data/ctm/GEOS_4x5/ann_mean_trop.geos1.4x5
;Output File    : /scratch/bmy/gctm.trc.941001.new
;=============================================================================
;
; EXAMPLE:
;        CTM_RESTART_O3, 'filenames.dat', /STRAT_ONLY
;             
;             ; Will merge stratospheric single tracer Ox into the 
;             ; full chemistry restart file.  Input and output file
;             ; names are given in "filenames.dat".
;
; MODIFICATION HISTORY:
;        bmy, 17 Feb 2000: VERSION 1.45
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
;
;-
; Copyright (C) 1999-2007, Martin Schultz,
; Bob Yantosca and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of 
; this software. If this software shall be used commercially or 
; sold as part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.harvard.edu with subject "IDL routine ctm_restart_o3"
;-----------------------------------------------------------------------


pro CTM_Restart_O3, BatchFile, Strat_Only=Strat_Only
 
   ;====================================================================
   ; External functions / Keyword Settings
   ;====================================================================
   FORWARD_FUNCTION CTM_Grid, CTM_Get_DataBlock, Str2Byte
 
   ;====================================================================
   ; Read the input & output file names from BATCHFILE
   ;====================================================================
   Open_File, BatchFile, Ilun_IN, /Get_LUN
 
   ; Skip 3 header lines
   Line = ''
   ReadF, Ilun_IN, Format='(a)', Line
   ReadF, Ilun_IN, Format='(a)', Line
   ReadF, Ilun_IN, Format='(a)', Line
 
   ; Read full chemistry restart file
   ReadF, Ilun_IN, Format='(17x,a)', Line
   InFile = StrTrim( Line, 2 )
 
   ; Read single tracer Ox restart file
   ReadF, Ilun_IN, Format='(17x,a)', Line
   OxFile = StrTrim( Line, 2 ) 
 
   ; Read annual mean tropopause file
   ReadF, Ilun_IN, Format='(17x,a)', Line
   TropFile = StrTrim( Line, 2 )
 
   ; Read output restart file
   ReadF, Ilun_IN, Format='(17x,a)', Line
   OutFile = StrTrim( Line, 2 )
 
   ; Close BATCHFILE
   Close,    Ilun_IN
   Free_LUN, Ilun_IN
 
   ;====================================================================
   ; Read annual mean tropopause data into the TROPOPAUSE array,
   ; and get the corresponding MODELINFO and GRIDINFO structures.  
   ;
   ; Recall, the levels where the tropopause occur are treated as
   ; stratospheric boxes.  So for grid box [I,J]: 
   ;    L = 1, TROPOPAUSE[I,J]-1  are tropospheric 
   ;    L = TROPOPAUSE[I,J], LMX  are stratospheric 
   ;====================================================================
   Success = CTM_Get_DataBlock( Tropopause, 'TR-PAUSE', $
                                FileName=TropFile,      $
                                ModelInfo=ModelInfo1,   $
                                GridInfo=GridInfo1,     $
                                Tracer=1,               $
                                Tau0=0 )
 
   if ( not Success ) then Message, 'Tropopause not found!'
   
   ; Convert from Fortran indexing to IDL indexing (starts from 0)
   Tropopause = Tropopause - 1
 
   ;====================================================================
   ; Read original restart file, and get the corresponding
   ; MODELINFO and GRIDINFO structures
   ;====================================================================
   CTM_Get_Data, DataInfo, 'IJ-AVG-$',                      $
      FileName=InFile,           Index=NewInd,              $
      Use_FileInfo=Use_FileInfo, Use_DataInfo=Use_DataInfo, $ 
      _EXTRA=e    
 
   ModelInfo2 = Use_FileInfo.ModelInfo
   GridInfo2  = CTM_Grid( ModelInfo2 )
 
   ;====================================================================
   ; Read restart file with single-tracer Ox data, and get 
   ; the corresponding MODELINFO and GRIDINFO structures
   ;====================================================================
   CTM_Get_Data, O3DataInfo, 'IJ-AVG-$',                    $
      FileName=OxFile,           Index=NewInd,              $
      Use_FileInfo=Use_FileInfo, Use_DataInfo=Use_DataInfo, $ 
      _EXTRA=e   
 
   ModelInfo3 = Use_FileInfo.ModelInfo
   GridInfo3  = CTM_Grid( ModelInfo2 )
   
   ;====================================================================
   ; Make sure that all 3 files we just opened are for the same grid
   ; and model, or else we can't do the merging properly
   ;====================================================================
   if ( ( ModelInfo1.Name ne ModelInfo2.Name )   OR $
        ( ModelInfo1.Name ne ModelInfo3.Name ) ) then begin
      Message, 'The input files are from different models!', /Continue
      return
   endif
 
   if ( ( GridInfo1.IMX ne GridInfo2.IMX )   OR $
        ( GridInfo1.IMX ne GridInfo3.IMX ) ) then begin
      Message, 'The input files have different longitude resolutions!', $
         /Continue
      return
   endif
 
   if ( ( GridInfo1.JMX ne GridInfo2.JMX )   OR $
        ( GridInfo1.JMX ne GridInfo3.JMX ) ) then begin
      Message, 'The input files have different latitude resolutions!', $
         /Continue
      return
   endif
 
   if ( ( GridInfo1.LMX ne GridInfo2.LMX )   OR $
        ( GridInfo1.LMX ne GridInfo3.LMX ) ) then begin
      Message, 'The input files have different altitude resolutions!', $
         /Continue
      return
   endif
 
   ;====================================================================
   ; Compute skip factor and dimensions of data block, now that 
   ; we are sure all 3 files come from the same model and grid
   ;====================================================================
   IMX  = Long( GridInfo1.IMX )
   JMX  = Long( GridInfo1.JMX )
   LMX  = Long( GridInfo1.LMX )
   Skip = ( 4L * ( IMX * JMX * LMX ) ) + 8L
   Dim  = [ IMX, JMX, LMX, 1L, 1L, 1L ]
 
   ;====================================================================
   ; Declare some variables from the O3 file
   ; and adjust units from ppb to v/v if necessary
   ;====================================================================
   O3Data   = *( O3DataInfo[0].Data )
   O3Unit   = StrUpCase( StrMid( StrTrim( O3DataInfo[0].Unit, 2 ), 0, 3 ) )
   O3Tracer = O3DataInfo[0].Tracer
 
   if ( O3Unit eq 'PPB' ) then begin 
      O3Data = O3Data * 1e-9
      O3Unit = 'v/v'
   endif
 
   ;====================================================================
   ; Open the output file and wrrite the FTI and TOPTITLE lines
   ;====================================================================
   FTI      = Str2Byte( 'CTM bin 02', 40 )
   TopTitle = Str2Byte( $
      'Restart file with steady-state O3 values (bmy, acf, 2/00)', 80 )
 
   Open_File, OutFile, Ilun_OUT, /Get_LUN, /Write, /F77
   
   WriteU, Ilun_OUT, FTI
   WriteU, Ilun_OUT, TopTitle
 
   ;====================================================================
   ; Loop over all of the data blocks in the original restart file,
   ; replacing Ox with the single-tracer Ox from the O3 file
   ;====================================================================
   for N = 0L, N_Elements( DataInfo ) - 1L  do begin
      
      ; Save the current data block structure in THISDATAINFO
      ThisDataInfo = DataInfo[N]
 
      ; Variables for the binary punch file
      ModelName  = Str2Byte( ModelInfo1.Name, 20 )
      ModelRes   = Float( ModelInfo1.Resolution )
      Category   = Str2Byte( ThisDataInfo.Category,  40 )
      HalfPolar  = Long( ModelInfo1.HalfPolar )
      Center180  = Long( ModelInfo1.Center180 )
      Reserved   = BytArr(40)
      Unit       = StrTrim( ThisDataInfo.Unit, 2 )
      Tau0       = ThisDataInfo.Tau0
      Tau1       = ThisDataInfo.Tau1
      Tracer     = Long( ThisDataInfo.Tracer ) mod 100L
      Data       = *( ThisDataInfo.Data )

      ; adjust for ppbv --> v/v
      if ( StrUpCase( StrMid( Unit, 0, 3 ) ) eq 'PPB' ) then begin 
         Data = Data * 1e-9
         Unit = 'v/v'
      endif
   
      ; Convert Unit to byte for punch file
      Unit = Str2Byte( Unit, 40 )

      ; For Ox, substitute the steady-state O3 data as read above.
      if ( Tracer eq O3Tracer ) then begin
 
         ; If /STRAT_ONLY is set, then only copy the 
         ; stratospheric O3 into the output file.  
         if ( Keyword_Set( Strat_Only ) ) then begin
 
            for J = 0L, JMX - 1L do begin
            for I = 0L, IMX - 1L do begin
               L = Tropopause[I, J]
               Data[I, J, L:*] = O3Data[I, J, L:*]
            endfor
            endfor
 
         ; Otherwise, copy all levels
         ; of the O3 data into the output file.
         endif else Data = O3Data
      endif
 
      ;### Debug output
      ;print, '### ', Tau0, Tracer, Min( Data, Max=M ), M
 
      ; Write each data block to disk
      WriteU, Ilun_OUT, modelname, modelres, halfpolar, center180
      WriteU, Ilun_OUT, category, tracer, unit, tau0, tau1, $
                        reserved, dim, skip
      WriteU, Ilun_OUT, Float( Data )
   endfor
 
   ;====================================================================
   ; Close output file and quit program
   ;====================================================================
Quit:
   Close,    Ilun_OUT
   Free_LUN, Ilun_OUT
 
end
