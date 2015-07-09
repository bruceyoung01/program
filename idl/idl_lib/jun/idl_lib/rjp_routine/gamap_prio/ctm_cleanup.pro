; $Id: ctm_cleanup.pro,v 1.1.1.1 2003/10/22 18:06:04 bmy Exp $
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
;        GAMAP tool
;
; CALLING SEQUENCE:
;        CTM_CLEANUP [, /DATA_ONLY, /NO_GC ]
;
; INPUTS:
;        none
;
; KEYWORD PARAMETERS:
;        /DATA_ONLY -> Only free heap variables that point to the
;           actual data records. Leave all 'info' intact. Default 
;           is to remove everything includign the global DATAINFO 
;           and FILEINFO structure arrays.  NOTE: Setting this switch
;           will not perform garbage collection via routine HEAP_GC.
;           
;        /NO_GC -> Set this switch to suppress garbage collection of
;           heap variables with HEAP_GC.
;
; OUTPUTS:
;        None
;
; SUBROUTINES:
;        None
;
; REQUIREMENTS:
;        Requires routines from the GAMAP package.
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
;
;-
; Copyright (C) 1998-2004, 
; Martin Schultz and Bob Yantosca, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author to arrange payment.
; Bugs and comments should be directed to mgs@io.harvard.edu
; or bmy@io.harvard.edu with subject "IDL routine ctm_cleanup"
;-----------------------------------------------------------------------


pro ctm_cleanup, data_only=data_only, No_GC=No_GC
 
 
; include global common block
@gamap_cmn
 
 
   ; close all open files
   close,/all
 
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
   if (ptr_valid(pGlobalFileInfo)) then begin
      f = *pGlobalFileInfo
      for i=0,n_elements(f)-1 do $
          if (ptr_valid(f[i].gridinfo)) then ptr_free,f[i].gridinfo
   endif
 
   ; finally free the global fileinfo and datainfo pointers
   ; themselves
   if (ptr_valid(pGlobalDataInfo)) then $
       ptr_free,pGlobalDataInfo
   if (ptr_valid(pGlobalFileInfo)) then $
       ptr_free,pGlobalFileInfo
 
   ;====================================================================
   ; Do garbage collection to really clean up memory! (bmy, 10/4/04)
   ;====================================================================
   if ( ( not Keyword_Set( Data_Only ) ) AND $
        ( not Keyword_Set( No_GC     ) ) )   $
      then Heap_GC

   return
end
   
 
