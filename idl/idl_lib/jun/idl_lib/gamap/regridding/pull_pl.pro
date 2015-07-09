; $Id: pull_pl.pro,v 1.1.1.1 2007/07/17 20:41:31 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        PULL_PL
;
; PURPOSE:
;        Copies datablocks from NRT bpch files for category PORL-L=$
;        to a separate file for archival purposes.
;
; CATEGORY:
;        Regridding
;
; CALLING SEQUENCE:
;        PULL_PL, DATE
;
; INPUTS:
;        DATE -> YYYYMMDD of the date for which to extract data.
;
; KEYWORD PARAMETERS:
;        None
;
; OUTPUTS:
;        None
;
; SUBROUTINES:
;        External Subroutines Required:
;        =============================================
;        CTM_GET_DATA    CTM_MAKE_DATAINFO  (function)
;        CTM_WRITEBPCH   GETMODELANDGRIDINFO
;
; REQUIREMENTS:
;        None
;
; NOTES:
;        None
;
; EXAMPLE:
;        PULL_PL, 20051201
;             - Extracts PORL-L=$ data for 2005/12/01.
;
; MODIFICATION HISTORY:
;  rch & bmy, 06 Dec 2005: VERSION 1.00
;  bmy & phs, 20 Jun 2007: GAMAP VERSION 2.10
;
;-
; Copyright (C) 2005-2007, 
; Bob Yantosca, and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of this 
; software. If this software shall be used commercially or sold as 
; part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.as.harvard.edu with subject "IDL routine pull_pl"
;-----------------------------------------------------------------------


pro Pull_PL, Date
 
   ;====================================================================
   ; Initialization
   ;====================================================================
 
   ; External functions
   FORWARD_FUNCTION CTM_Make_DataInfo

   ; Arguments
   if ( N_Elements( Date ) ne 1 ) then Message, 'Date not passed!'
 
   ; 8 and 10 character date strings
   DateStr8  = String( Date, '(i8.8)' )
   DateStr10 = DateStr8 + '00'
 
   ; Input file
   InFile    = '/as2/priv/NRT/bpch/ctm.bpch.' + DateStr10
       
   ; Tracer list
   Tracer    = [ 1, 2, 3, 4 ]
 
   ; First-time flag
   FirstTime = 1L
   
   ;====================================================================
   ; Extract PORL-L=$ data blocks and save to a new file
   ;====================================================================
   
   ; Get all data blocks
   CTM_Get_Data, DataInfo, 'PORL-L=$', Tracer=Tracer, File=InFile, /Quiet
 
   ; Loop over all data blocks
   for D = 0L, N_Elements( DataInfo )-1L do begin
 
      ; Get MODELINFO and GRIDINFO for each data block
      GetModelAndGridInfo, DataInfo[D], InType, InGrid
 
      ; Get the data 
      InData  = *( DataInfo[D].Data )
 
      ; Make a new DATAINFO structure
      Success = CTM_Make_DataInfo( Float( InData ),                  $
                                   ThisDataInfo,                     $
                                   ThisFileInfo,                     $
                                   ModelInfo = InType,               $
                                   GridInfo  = InGrid,               $
                                   DiagN     = DataInfo[D].Category, $
                                   Tracer    = DataInfo[D].Tracer,   $
                                   Tau0      = DataInfo[D].Tau0,     $
                                   Tau1      = DataInfo[D].Tau1,     $
                                   Unit      = DataInfo[D].Unit,     $
                                   Dim       = DataInfo[D].Dim,      $
                                   First     = DataInfo[D].First,    $
                                   /No_Global)
         
      ; Error check
      if ( not Success ) then Message, 'Could not make DATAINFO!'
 
      ; Append THISDATAINFO onto the NEWDATAINFO array of structures
      if ( FirstTime )                                           $
         then NewDataInfo = [ ThisDataInfo ]                     $
         else NewDataInfo = [ NewDataInfo, ThisDataInfo ]
                
      ; Reset the first time flag
      FirstTime = 0L
 
      ; Undefine stuff
      UnDefine, ThisDataInfo
      UnDefine, InType
      UnDefine, InGrid
 
   endfor
 
   ;====================================================================
   ; Write output file
   ;====================================================================
    
   ; Output file
   OutFileName = '/as2/priv/NRT/co_ox_pl/co_ox_pl.' + DateStr8
          
   ; Write bpch file
   CTM_WriteBpch, NewDataInfo, ThisFileInfo, FileName=OutFilename
 
end
