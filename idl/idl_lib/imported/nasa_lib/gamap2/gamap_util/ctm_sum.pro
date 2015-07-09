; $Id: ctm_sum.pro,v 1.1.1.1 2007/07/17 20:41:24 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        CTM_SUM
;
; PURPOSE:
;        Calculate the sum of several CTM output data blocks
;        and store them in a new datainfo structure as "derived 
;        data".  The user can select data blocks by diagnostics,
;        tracer, tau0, or logical unit of the source file.  With 
;        the AVERAGE keyword averages will be computed instead of
;        totals.
;
; CATEGORY:
;        GAMAP Utilities, GAMAP Data Manipulation
;
; CALLING SEQUENCE:
;        CTM_SUM [, DIAGN ] [, Keywords ]
;
; INPUTS:
;        DIAGN -> The diagnostic category name.  Default is 'IJ-AVG-$'
;
; KEYWORD PARAMETERS:
;        TRACER -> Tracer number(s) to look for.
;
;        TAU0 -> beginning of time step to look for. You can
;            specify a date using function nymd2tau(YYMMDD,HHMMSS)
;
;        ILUN -> If you want to restrict summation to datablocks from
;            one particular file, set the ILUN keyword to the 
;            respective logical unit number.  ILUN and FILENAME are
;            mutually exclusive.  If you select FILENAME then ILUN 
;            will be ignored.
;
;        FILENAME -> Instead of ILUN you may pass the name of a
;            CTM data file containing data blocks to be summed.
;            FILENAME and ILUN are mutually exclusive.  If you 
;            select FILENAME then ILUN will be ignored.
;
;        NEWTRACER -> Tracer number for the new tracer. Default is 
;            to use the same number as the tracer in the first 
;            selected data block.
;
;        NEWTAU0 -> A new pair of values for the time stamp. Default 
;            is to use the minimum tau0 and maximum tau1 from the 
;            selected data blocks. If only one value is passed (tau0),
;            then tau1 will be set to tau0+1.
;
;        /AVERAGE -> set this keyword to compute a (simple) average
;            instead of the total.
;
; OUTPUTS:
;        This routne produces no output but stores a new datainfo 
;        and fileinfo structure into the global arrays.
;
; SUBROUTINES:
;        uses gamap_cmn, ctm_get_data, ctm_grid, and ctm_make_datainfo
;
; REQUIREMENTS:
;        None
;
; NOTES:
;        All data blocks must originate from compatible models.
;        No test can be made whether an identical addition had been
;        performed earlier. Hence, it is a good idea to test the
;        existence of the "target" record before in order to avoid 
;        duplicates.
;
; EXAMPLE:
;        (1) 
;        CTM_GET_DATA, DATAINFO, 'IJ-AVG-$', $
;          TRACER=1, TAU0=NYMD2TAU( 940301L )
;
;        IF (N_ELEMENTS(DATAINFO) EQ 0) THEN $
;           CTM_SUM, 'IJ-AVG-$', TRACER=[1,2,3,4,5],  $
;              TAU0=NYMD2TAU(940301L), NEWTRACER=1
;
;           ; Add individual CH3I tracers for 03/01/1994 and 
;           ; store them  as total CH3I concentration. 
;           ; But first: test!
;
;        (2)
;        CTM_SUM,'IJ-AVG-$',$
;           TRACER=2, FILENAME='ctm.bpch.ox', /AVERAGE 
;        
;           ; Compute annual averages from monthly means for Ox
;
; MODIFICATION HISTORY:
;        mgs, 18 May 1999: VERSION 1.00
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
;                          - Added FILENAME keyword as an 
;                            alternative to ILUN
;                          - Updated comments, cosmetic changes
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
; or phs@io.harvard.edu with subject "IDL routine ctm_sum"
;-----------------------------------------------------------------------


pro CTM_Sum, DiagN,                                                $
             Tracer=Tracer,       Tau0=Tau0,     Ilun=Ilun,        $
             NewTracer=NewTracer, NewTau=NewTau, Average=Average,  $
             FileName=FileName

   ;====================================================================
   ; Initialization
   ;====================================================================
  
   ; External functions
   FORWARD_FUNCTION CTM_Grid, CTM_Make_DataInfo

   ; Get GAMAP common block
   @gamap_cmn
 
   ; Get data block, using either FILENAME or ILUN
   if ( N_Elements( FileName ) gt 0 ) then begin
      CTM_Get_Data, DataInfo, DiagN, $
         Tracer=Tracer, Tau0=Tau0, FileName=FileName, /Quiet
   endif else begin
      CTM_Get_Data, DataInfo, DiagN, $
         Tracer=Tracer, Tau0=Tau0, Ilun=Ilun, /Quiet
    endelse

   ; Error check
   if ( N_Elements( datainfo ) eq 0) then begin
       Message, 'No matching records found!', /Continue
       return
   endif
 
   ;### Debug output
   ;help,datainfo,/stru
   ;print,datainfo.tracer
   ;print,datainfo.category
   ;print,datainfo.tau0
 
   ;====================================================================
   ; Compute the sum (or average) of the data
   ;====================================================================

   ; Sum the data 
   Sum = *( DataInfo[0].Data )
   for I = 1L, N_Elements( DataInfo ) - 1L do begin
      Sum = Sum + *( DataInfo[I].Data )
   endfor
 
   ; If /AVERAGE is set, return the average of the data
   if ( Keyword_Set( Average ) ) $
      then Sum = Sum / Float( N_Elements( DataInfo ) )
 
   ; If NEWTRACER is not passed, use tracer # from DATAINFO
   if ( N_Elements( NewTracer ) eq 0 ) $
      then NewTracer = DataInfo[0].Tracer
 
   ; If NEWTAU is not passed, use TAU from DATAINFO
   if ( N_Elements( NewTau ) eq 0 ) $
      then NewTau = [ Min( DataInfo.Tau0 ), Max( DataInfo.Tau1 ) ]
 
   if ( N_Elements( NewTau ) eq 1 ) $
      then NewTau = [ NewTau, NewTau+1 ]
 
   ;====================================================================
   ; Create a DATAINFO structure for the sum (average) of the data
   ;====================================================================

   ; Get the MODELINFO structure from the global FILEINFO structure
   Fileinfo  = *pGlobalFileInfo
   Ind       = Where( FileInfo.Ilun eq Datainfo[0].Ilun )
   ModelInfo = Fileinfo[ Ind[0] ].ModelInfo

   ; Look for the GRIDINFO struture from the global GAMAP FILEINFO structure
   ; If it is not present, then create it with the CTM_GRID routine
   if ( Ptr_Valid( Fileinfo[ Ind[0] ].GridInfo ) )         $
      then GridInfo = *( FileInfo[ Ind[0] ].GridInfo )     $
      else GridInfo = CTM_Grid( ModelInfo )
 
   ; Make a DATAINFO structure
   Result = CTM_Make_DataInfo( Float( Sum ),               $
                               ;-------------------------------------
                               ; Prior to 5/18/07:
                               ;NewD,                       $
                               ;NewF,                       $
                               ;-------------------------------------
                               ModelInfo=ModelInfo,        $
                               GridInfo=GridInfo,          $
                               DiagN=DataInfo[0].Category, $
                               Tracer=NewTracer,           $
                               Tau0=NewTau[0],             $
                               Tau1=NewTau[1],             $
                               Unit=DataInfo[0].Unit,      $
                               Dim=DataInfo[0].Dim,        $
                               First=DataInfo[0].First )
   
   ; Error check 
   if ( Result )                                                      $
      then Message, 'Successfully added selected datablocks.', /Info  $
      else Message, 'Something went wrong! STOP.'
 
   return
end
 
