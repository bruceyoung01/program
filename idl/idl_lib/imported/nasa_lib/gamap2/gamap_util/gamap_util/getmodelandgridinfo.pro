; $Id: getmodelandgridinfo.pro,v 1.2 2008/07/17 14:08:52 bmy Exp $
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
;        GAMAP Utilities, GAMAP Models & Grids, Structures
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
;        LON -> set to a variable that will hold the longitude
;             centers of the data set. Grid Offsets of data that
;             do not cover the globe are accounted for.
; 
;        LAT -> same as LON, but for Latitude centers.
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
;        None
;
; NOTES:
;        None
;
; EXAMPLE:
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
;        bmy, 28 Jun 2006: GAMAP VERSION 2.05
;                          - Bug fix for multi-level GENERIC grids
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
;        phs, 13 May 2008: GAMAP VERSION 2.12
;                          - Added LON and LAT keyword to return data
;                          (not global grid) longitude and latitude centers.
;-
; Copyright (C) 2002-2007, Martin Schultz,
; Bob Yantosca and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of 
; this software. If this software shall be used commercially or 
; sold as part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.harvard.edu with subject "IDL routine ctm_getmodelandgridinfo"
;-----------------------------------------------------------------------


pro GetModelAndGridInfo, ThisDataInfo, ModelInfo, GridInfo, Lon=lon, Lat=lat

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
   
   ; Get MODELINFO structure.  If MODELINFO.NLAYERS = 0, CTM_TYPE will 
   ; automatically return a MODELINFO structure w/ no vertical layer info 
   ; (bmy, 7/3/01)
   ModelInfo = FileInfo[Ind].ModelInfo

   ; Fix for multi-level GENERIC grids...use the size of the file
   ; to set the MODELINFO.NLAYERS flag for proper GAMAP processing.
   ; (bmy, 6/28/06)
   if ( ModelInfo.Name eq 'GENERIC' AND ThisDataInfo.Dim[2] gt 0 ) $
      then ModelInfo.NLayers = ThisDataInfo.Dim[2]

   ; Get GRIDINFO structure
   GridInfo  = CTM_Grid( ModelInfo ) 


   ; output keywords
   if arg_present(lon) then $
      lon = GridInfo.Xmid[ThisDataInfo.first[0]-1 : $
                          ThisDataInfo.first[0]-2 + ThisDataInfo.dim[0]]

   if arg_present(lat) then $
      lat = GridInfo.Ymid[ThisDataInfo.first[1]-1 : $
                          ThisDataInfo.first[1]-2 + ThisDataInfo.dim[1]]

   ; Return to calling program
   return

end
