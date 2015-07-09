; $Id: ctm_print_datainfo.pro,v 1.1.1.1 2007/07/17 20:41:47 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        CTM_PRINT_DATAINFO
;
; PURPOSE:
;        Create and print a formatted list of DATAINFO records.
;        This procedure can be used for direct printing, but it
;        can also return a string array of the formatted output 
;        e.g. for use in a widget list.
;
; CATEGORY:
;        GAMAP Internals, GAMAP Data Manipulation
;
; CALLING SEQUENCE:
;        CTM_PRINT_DATAINFO,DATAINFO [,keywords]
;
; INPUTS:
;        DATAINFO -> One or more DATAINFO records, e.g. the result 
;             from CTM_GET_DATA.
;
; KEYWORD PARAMETERS:
;        FIELDS -> (*** not yet implemented ***) A list of fields
;             (structure tag names) to be printed. Default is
;             CATEGORY, ILUN, TRACERNAME, TRACERNUMBER, 
;             UNIT, TAU0, STATUS, DIMENSIONS
;             FIELDS can also include tags from the (global) FILEINFO
;             structure (e.g. FILENAME).
;
;        OUTPUT -> A named variable that will contain a string array
;             with the formatted output including the title line but 
;             without the seperating lines. The title is not included
;             if keyword /NOTITLE is set.
;
;        /NOPRINT -> Don't print, only return formatted strings
;
;        /NOTITLE -> Do not generate title line (will neither be printed
;             nor included in OUTPUT.
;
; OUTPUTS:
;        None
;
; SUBROUTINES:
;        External subroutines required:  
;        ------------------------------
;        GAMAP_CMN  (include file)
;        TAU2YYMMDD (function)
;
; REQUIREMENTS:
;        References routines from both GAMAP and TOOLS packages.
;
; NOTES:
;        For GISS, FSU family of models, TAU0 = 0 occurs on date 1/1/1980.
;        For GEOS      family of models, TAU0 = 0 occurs on date 1/1/1985.
;        Therefore, the model family must be obtained from the global
;        FILEINFO structure in order to display the YYMMDD
;        corresponding to TAU0.
; 
; EXAMPLE:
;        CTM_GET_DATA,DataInfo,File='',tracer=2
;        CTM_PRINT_DATAINFO,DataInfo
;        ; *or*
;        CTM_PRINT_DATAINFO,DataInfo,Output=r,/NOPRINT
;
; MODIFICATION HISTORY:
;        mgs, 10 Nov 1998: VERSION 1.00
;        bmy, 11 Feb 1999: VERSION 1.01
;                          - adjust format for double-precision TAU0
;        mgs, 16 Mar 1999: - added tracer number and removed STATUS
;                          - made cosmetic changes
;        mgs, 23 Mar 1999: - print dimension as NA if not yet available
;        bmy, 27 Apr 1999: - widen tracer number field to 6 chars
;        mgs, 22 Jun 1999: - widen unit field to 12 chars and add DATE field
;        bmy, 27 Jul 1999: VERSION 1.42
;                          - GISS/FSU YYMMDD values are now correct
;                          - cosmetic changes
;        bmy, 10 Aug 1999: - change I6 format for date to I6.6
;                            so that leading zeroes are printed
;        bmy, 03 Jan 2000: VERSION 1.44
;                          - change I6.6 format to I8.8 and print the 
;                            date in YYYYMMDD format for Y2K compliance
;                          - declare TAU2YYMMDD as external with the
;                            FORWARD_FUNCTION command
;        bmy, 14 Feb 2001: GAMAP VERSION 1.47
;                          - decrease tracer name from 10 to 7 chars
;                          - Now use 10-digit date string YYYYMMDDHH
;        bmy, 02 Jul 2001: GAMAP VERSION 1.48
;                          - now assume that GENERIC grids use GEOS
;                            time epoch for NYMD2TAU 
;        bmy, 21 Oct 2002: GAMAP VERSION 1.52
;                          - now assume MOPITT grid uses GEOS epoch
;                          - deleted obsolete code
;        bmy, 03 May 2005: GAMAP VERSION 2.04
;                          - wrap tracer number into 5 digits
;                          - GCAP uses the same TAU values as GEOS models
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
;
;-
; Copyright (C) 1998-2007, Martin Schultz,
; Bob Yantosca, and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of 
; this software. If this software shall be used commercially or 
; sold as part of a larger package, please contact the author.
; Bugs and comments should be directed to mgs@io.harvard.edu
; or bmy@io.harvard.edu, with subject "IDL routine ctm_print_datainfo"
;-----------------------------------------------------------------------


pro ctm_print_datainfo,DataInfo,fields=fields,  $
             output=output,noprint=noprint,notitle=notitle

   ; *** (fields keyword not yet implemented) ***
 
   ; Include global structures
   @gamap_cmn

   ; External functions
   FORWARD_FUNCTION Tau2YYMMDD

   ; Dereference the global FILEINFO structure
   FileInfo = *pGlobalFileInfo

   seperator = string(replicate('-',78),format='(78A1)') 
 
   if (n_elements(DataInfo) eq 0) then begin
      message,'No data records in DATAINFO!',/Continue
      return
   endif
 
   
   ; ================================================================ 
   ; print title line and loop through datainfo records
   ; We compose a string array so that it can be returned e.g. for
   ; a widget list item
   ; ================================================================ 
 
   if (not keyword_set(noprint)) then print,seperator

   s = 'CATEGORY ILUN TRCNAME   TRC         UNIT' + $
       '      TAU0(DATE)       DIMENSIONS' 

   for i=0,n_elements(DataInfo)-1 do begin
      dims = ''
      for j=0,2 do begin
         if (DataInfo[i].dim[j] gt 0) then $
            dims = dims + string(DataInfo[i].dim[j],format='(i3)') $
         else $
            dims = dims + ' NA'
      endfor
      
      ; Find the element of FILEINFO that corresponds to DATAINFO[I]
      Ind = Where( FileInfo.ILUN eq DataInfo[I].ILUN )
      if ( Ind[0] ge 0 ) then begin
         
         ; Get the model family name from FILEINFO
         Family = StrUpCase( StrTrim( FileInfo[Ind].ModelInfo.FAMILY, 2 ) )

         ; Get the model name from FILEINFO
         Name   = StrUpCase( StrTrim( FileInfo[Ind].ModelInfo.Name, 2 ) )
           
         ; Convert TAU0 to YYMMDD.  YYMMDD will now be correct 
         ; for GEOS, GISS or FSU family of models (bmy, 8/2/99)
         ; Now use 10-digit date string YYYYMMDDHH (bmy, 2/14/01)
         ; Also assume MOPITT grid uses GEOS epoch (bmy, 10/21/02)
         ; GCAP uses the same TAU values as GEOS-CHEM (bmy, 5/26/05)
         GEOS = ( Family eq 'GEOS'    OR Family eq 'GENERIC' OR $
                  Family eq 'MOPITT'  OR Name   eq 'GCAP' )
         GISS = 1 - GEOS
         NYMD = Tau2YYMMDD( DataInfo[i].Tau0, GEOS=GEOS, GISS=GISS, /NFormat )
         NYMD = ( NYMD[0] * 100 ) + ( NYMD[1] / 10000 )

      endif else begin

         ; No corresponding FILEINFO record found!  Display warning 
         ; message and set NYMD to 0 for display purposes (bmy, 8/2/99)
         Message, 'Could not find corresponding record of FILEINFO!', /Continue
         NYMD = 000000

      endelse

      s = [ s , string(DataInfo[i].category,           $
                       DataInfo[i].ilun,               $
                       DataInfo[i].tracername,         $
                       DataInfo[i].tracer mod 100000L, $  
                       DataInfo[i].unit,               $
                       DataInfo[i].tau0,               $
                       NYMD,                           $
                       dims,                           $
             format='(A8,1X,I4,1X,A7,I6,1X,A12,1X,F9.2,"(",I10.10,") ",A)') ]

   endfor
    

   if (keyword_set(NOTITLE)) then s = s[1:*] 
   output = s

   if (not keyword_set(NOPRINT) ) then begin
      ; loop necessary because of extra blanks otherwise
      for i=0,n_elements(s)-1 do print,' ', s[i]
      print,seperator
   endif
 
   return
end
 
 
 
