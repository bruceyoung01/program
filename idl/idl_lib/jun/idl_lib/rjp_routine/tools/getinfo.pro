pro GetInfo, ThisDataInfo, ModelInfo, GridInfo

   ;====================================================================
   ; Internal subroutine GetInfo returns the MODELINFO and 
   ; GRIDINFO structures for a given data block (bmy, 11/21/01)
   ;====================================================================

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
