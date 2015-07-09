; $Id: rewrite_agprod.pro,v 1.1 2008/04/03 20:12:16 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;	 REWRITE_AGPROD
;
;
; PURPOSE:
;        To rewrite a APROD / GPROD restart file with a different
;        timestamp TAU0. The correspondence b/w file name and timestamp
;        is enforced, as required by GEOS-Chem.
;
; CATEGORY:
;	 Date & Time
;
;
; CALLING SEQUENCE:
;	 REWRITE_AGPROD, INFILE='old_file_name', TAU0=tau | YMD=yyyymmdd
;
; INPUTS:
;	 None
;
; KEYWORD PARAMETERS:
;
;        INFILENAME -> initial restart_aprod_gprod file. If not
;             passed, a dialog window will pop up.
;
;        TAU0 (double) -> the new time stamp you want, in Tau units
;
;        YMD (long) -> the new time stamp you want, in YYMMDD or YYYYMMDD
;
;        HH -> hour for this date (e.g. 6 for 6 a.m.)  Default is 0.
;
;        Either TAU0 or YMD should be passed. If both are passed,
;        TAU0 is used.
;
; OUTPUTS:
; 	 None.
;
; SIDE EFFECTS:
;	 A file named restart_aprod_gprod.YYYYMMDDHH where YYYYMMDDHH
;        corresponds with TAU0 in the data blocks is created.
;
; RESTRICTIONS:
;	 The input file must be a restart_aprod_gprod file.
;
; NOTES:
;        This is not a regridding routine. To regrid a
;        restart_aprod_gprod file, use :
;
;           REGRIDV_RESTART, ..., DIAGN=0
;
;        or/and
;
;           REGRIDH_RESTART, ..., DIAGN=0
;
; EXAMPLE:
;        REWRITE_AGPROD, YMD=20010701
;
; MODIFICATION HISTORY:
;	 phs,    Jul 2007: version 0.1
;        phs, 04 Apr 2007: GAMAP VERSION 2.12
;                          - commemts
;                          - clean non_global pointers
;                          - added YMD and HH keywords
;
;-
; Copyright (C) 2007-8, Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of 
; this software. If this software shall be used commercially or 
; sold as part of a larger package, please contact the author.
; Bugs and comments should be directed to plesager@seas.harvard.edu
; with subject "IDL routine add_date"
;-----------------------------------------------------------------------

pro rewrite_agprod, InFileName=InFileName, tau0=tau0, YMD=NYMD, HH=hh, _EXTRA=e
   
   ;================================================================
   ; check keywords
   ;================================================================
   if n_elements(InFileName) eq 0 then inFileName = dialog_pickfile()
   
   if n_elements( tau0 ) eq 0 then begin
      if n_elements( nymd ) eq 0 then $
         message, 'New date (YMD or TAU) is missing!! Returning...' $
      else tau0 = n_elements(hh) eq 0 ? $
                  nymd2tau( NYMD ) : nymd2tau( NYMD, long(HH)*10000L)
   endif

   ;================================================================
   ; output filename dafined by 
   ;================================================================
   date = tau2yymmdd( tau0 )
   outfilename = 'restart_gprod_aprod.'              + $
                 string(date.year,  format='(i4)'  ) + $
                 string(date.month, format='(i2.2)') + $
                 string(date.day,   format='(i2.2)') + $
                 string(date.hour,  format='(i2.2)')
   
   
   ;================================================================
   ; Process the data
   ;================================================================

   ; Read data into DATAINFO array of structures
   CTM_Get_Data, DataInfo, FileName=InFileName, _EXTRA=e

   NBlocks = N_Elements( DataInfo )


   ; Loop over all data blocks
   for D=0L, NBlocks-1L do begin

      ; Dereference the pointer to the data
      Data  = *DataInfo[D].Data

      ; model & grid
      GetModelAndGridInfo, DataInfo[D], ModelInfo, GridInfo
      if D eq 0l then print, ModelInfo.name

      ; Make DATAINFO structure 
      Success = CTM_Make_DataInfo( Data,                                $
                                   NewDataInfo,                         $
                                   NewFileInfo,                         $
                                   ModelInfo  = modelinfo,              $
                                   GridInfo   = GridInfo,               $
                                   DiagN      = DataInfo[D].Category,   $ 
                                   Tracer     = DataInfo[D].tracer,     $ 
                                   Tracername = DataInfo[D].tracername, $ 
                                   Tau0       = Tau0,                   $
                                   Tau1       = Tau0,                   $
                                   Unit       = DataInfo[D].Unit,       $
                                   Dim        = DataInfo[D].Dim,        $
                                   First      = DataInfo[D].First,      $
                                   /No_Global )
 
      ; Save into ArrDATAINFO array of structures
      if D eq 0L then ArrDataInfo = NewDataInfo  else $
         ArrDataInfo = [ ArrDataInfo, NewDataInfo ]

      ; clean one non-global pointer
      if D ne NBlocks-1l then ptr_free, NewFileinfo.gridinfo

   endfor

   ;====================================================================
   ; Save data to disk
   ;====================================================================

   ; Write as binary punch output
   CTM_WriteBpch, ArrDataInfo, NewFIleInfo, FileName=OutFileName

   ; clean non-global pointers
   for D=0, NBlocks-1l do ptr_free, ArrDataInfo[d].data
   ptr_free, Newfileinfo.gridinfo

END
