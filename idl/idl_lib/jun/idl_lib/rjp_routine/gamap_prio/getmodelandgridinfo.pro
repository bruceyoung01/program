; $Id: getmodelandgridinfo.pro,v 1.1.1.1 2003/10/22 18:06:01 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        GETMODELANDGRIDINFO
;
; PURPOSE:
;        Given a DATAINFO structure, returns the corresponding
;        MODELINFO and GRIDINFO structures. 
;
; CATEGORY:
;        CTM tools
;
; CALLING SEQUENCE:
;        CTM_GETMODELANDGRIDINFO, THISDATAINFO, MODELINFO, GRIDINFO
;
; INPUTS:
;        THISDATAINFO -> A single of DATAINFO structure which 
;             contains the following fields:
;
;             ** Structure H3DSTRU, 13 tags, length=72:
;                ILUN            LONG      
;                FILEPOS         LONG      
;                CATEGORY        STRING    
;                TRACER          INT       
;                TRACERNAME      STRING    
;                TAU0            DOUBLE    
;                TAU1            DOUBLE    
;                SCALE           FLOAT     
;                UNIT            STRING    
;                FORMAT          STRING    
;                STATUS          INT       
;                DIM             INT       
;                OFFSET          INT       
;                DATA            POINTER   
;
; KEYWORD PARAMETERS:
;        None
;
; OUTPUTS:
;        MODELINFO -> Returns to the calling program the model 
;             information structure (see "ctm_type.pro") which
;             corresponds to THISDATAINFO.
;                      
;        GRIDINFO -> Returns to the calling program the grid 
;             information structure (see "ctm_grid.pro") which
;             corresponds to THISDATAINFO.
;
; SUBROUTINES:
;        External Subroutines Required:
;        ==============================
;        GAMAP_CMN (include file)  
;        CTM_GRID  (function)
;
; REQUIREMENTS:
;        References routines from both the GAMAP package.
;
; NOTES:
;        None
;
; EXAMPLE:
;
;        ; Read data from "myfile.bpch"
;        ; DATAINFO is an array of structures
;        CTM_GET_DATA, DATAINFO, FILE='myfile.bpch'
;
;        ; Loop over all data blocks in the file
;        FOR D = 0L, N_ELEMENTS( DATAINFO )-1L DO BEGIN
;
;            ; Pick the DATAINFO structure for the Dth data block 
;            THISDATAINFO = DATAINFO[D].DATA
;
;            ; Get MODELINFO and GRIDINFO structures for the Dth data block
;            GETMODELANDGRIDINFO, THISDATAINFO, MODELINFO, GRIDINFO
;
;             ...
;        ENDFOR
;
; MODIFICATION HISTORY:
;        bmy, 24 Apr 2002: GAMAP VERSION 1.50
;
;-
; Copyright (C) 2002, Bob Yantosca, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author.
; Bugs and comments should be directed to bmy@io.harvard.edu
; with subject "IDL routine ctm_getmodelandgridinfo"
;-----------------------------------------------------------------------


pro GetModelAndGridInfo, ThisDataInfo, ModelInfo, GridInfo

   ; External functions
   FORWARD_FUNCTION CTM_Grid

   ; Include GAMAP common block
   @gamap_cmn

   ; Get the global FILEINFO structure
   FileInfo  = *( PGlobalFileInfo )
   
   ; Find out the FILEINFO entry that matches THISDATAINFO
   Ind       = Where( FileInfo.Ilun eq ThisDataInfo.Ilun )

   ; Error check
   if ( Ind[0] lt 0 ) then begin
      Message, 'FILEINFO and DATAINFO are not consistent!'
   endif
   
   ; Get MODELINFO & GRIDINFO structures
   ; If MODELINFO.NLAYERS = 0, CTM_TYPE will automatically return
   ; a GRIDINFO structure w/ no vertical layer info (bmy, 7/3/01)
   ModelInfo = FileInfo[Ind].ModelInfo
   GridInfo  = CTM_Grid( ModelInfo ) 

   ; Return to calling program
   return

end
