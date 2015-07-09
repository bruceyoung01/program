; $Id: ctm_cleanup.pro,v 1.1.1.1 2007/07/17 20:41:28 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        CTM_CLEANUP
;
; PURPOSE: 
;        Free memory blocked by excessive use of the GAMAP package.
;        With the /DATA_ONLY option, only the data blocks themselves
;        are freed, all header information remains accessible. 
;        This speeds up any further analysis.  Also calls HEAP_GC
;        to do garbage collection on unused heap variables.
;
; CATEGORY:
;        GAMAP Utilities
;
; CALLING SEQUENCE:
;        CTM_CLEANUP [, /DATA_ONLY, /NO_GC, /NO_FILE_CLOSE ]
;
; INPUTS:
;        none
;
; KEYWORD PARAMETERS:
;        /DATA_ONLY -> Only free heap variables that point to the
;             actual data records. Leave all 'info' intact. Default 
;             is to remove everything includign the global DATAINFO 
;             and FILEINFO structure arrays.  NOTE: Setting this switch
;             will not perform garbage collection via routine HEAP_GC.
;           
;        /NO_GC -> Set this switch to suppress garbage collection of
;             heap variables with HEAP_GC.
;
;        /NO_FILE_CLOSE -> Set this switch to suppress closing of
;             all open files.
;
; OUTPUTS:
;        None
;
; SUBROUTINES:
;        None
;
; REQUIREMENTS:
;        None
;
; NOTES:
;        None
;
; EXAMPLE:
;        CTM_CLEANUP
;
; MODIFICATION HISTORY:
;        mgs, 05 Oct 1998: VERSION 1.00
;        mgs, 08 Oct 1998: - fixed DATA_ONLY part so that status is
;                            reset to zero and derived data records 
;                            are removed
;        bmy, 21 Nov 2000: - Updated comments 
;        bmy, 04 Oct 2004: GAMAP VERSION 2.03
;                          - added /NO_GC keyword
;                          - now call HEAP_GC to do garbage collection
;                            of heap variables & pointers
;        bmy, 23 Mar 2007: GAMAP VERSION 2.06
;                          - Now add /NO_FILE_CLOSE keyword so as not
;                            to close open files
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
;                          - close only files opened with GAMAP
;
;-
; Copyright (C) 1998-2007, Martin Schultz,
; Bob Yantosca and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of 
; this software. If this software shall be used commercially or 
; sold as part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.harvard.edu with subject "IDL routine "
;-----------------------------------------------------------------------


pro ctm_cleanup, data_only=data_only, No_GC=No_GC, $
                 No_File_Close=No_File_Close
 
 
; include global common block
@gamap_cmn
 

   ; Don't close open files if /NO_FILE_CLOSE is set.
   File_Close = 1L - Keyword_Set( No_File_Close )

   ; close only file open with GAMAP (phs)
   if ( File_Close ) then begin
      if (ptr_valid(pGlobalFileInfo)) then begin
         f = *pGlobalFileInfo
         ind = where(f.ilun gt 0, count)
         if (count gt 0) then begin
            for klm=0, count-1 do free_lun, f[ind[klm]].ilun
         endif
      endif
   endif

 
   ; set DEBUG level to 'undefined'
   if (n_elements(DEBUG) gt 0) then DEBUG = -1   

   ; can exit now, if no global datainfo available
   if (not ptr_valid(pGlobalDataInfo)) then return

 
   ;====================================================================
   ; loop through DATAINFO records and free
   ; all valid data pointers 
   ;====================================================================
 
   d = *pGlobalDataInfo
   for i=0,n_elements(d)-1 do $
       if (ptr_valid(d[i].data)) then ptr_free,d[i].data

   ;====================================================================
   ; if only the data shall be removed, set all status variables
   ; to 0 (not read) and remove all derived data from the global
   ; lists (ilun lt 0)
   ;====================================================================
   if (keyword_set(DATA_ONLY)) then begin
      d.status = 0
      ind = where(d.ilun gt 0)
      if (ind[0] ge 0) then $
          *pGlobalDataInfo = d[ind]

      if (ptr_valid(pGlobalFileInfo)) then begin
         f = *pGlobalFileInfo
         ind = where(f.ilun gt 0)
         if (ind[0] ge 0) then $
             *pGlobalFileInfo = f[ind]
      endif

      return
   endif

   ;====================================================================
   ; otherwise: free all fileinfo.gridinfo pointers
   ; ===================================================================
   if ( Ptr_Valid( pGlobalFileInfo ) ) then begin
      F = *pGlobalFileInfo
      for i=0,n_elements(f)-1 do begin
         if ( ptr_valid( f[i].gridinfo ) ) then Ptr_Free, F[i].GridInfo
       endfor
   endif
 
   ; finally free the global fileinfo and datainfo pointers
   ; themselves
   if ( ptr_valid( pGlobalDataInfo ) ) then Ptr_Free, pGlobalDataInfo
   if ( ptr_valid( pGlobalFileInfo ) ) then Ptr_Free, pGlobalFileInfo
 
   ;====================================================================
   ; Do garbage collection to really clean up memory! (bmy, 10/4/04)
   ;====================================================================
   if ( ( not Keyword_Set( Data_Only ) ) AND $
        ( not Keyword_Set( No_GC     ) ) )   $
      then Heap_GC

   return
end
   
 
