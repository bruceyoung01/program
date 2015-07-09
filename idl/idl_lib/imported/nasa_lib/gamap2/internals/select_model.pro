; $Id: select_model.pro,v 1.2 2007/08/03 18:59:49 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        SELECT_MODEL
;
; PURPOSE:
;        Primitive function to select a model.
;        Calls CTM_TYPE and returns the MODELINFO structure.
;
; CATEGORY:
;        GAMAP Internals
;
; CALLING SEQUENCE:
;        MODELINFO = SELECT_MODEL( [ Keywords ] )
;
; INPUTS:
;        None
;
; KEYWORD PARAMETERS:
;        DEFAULT -> String containing the default model name, 
;             resolution, and number of levels.
;             
; OUTPUTS:
;        Returns the MODELINFO structure (from CTM_TYPE)
;        as the value of the function.
;
; SUBROUTINES:
;        External subroutines required:
;        ------------------------------
;        CTM_TYPE (function)
;
; REQUIREMENTS:
;        References routines from GAMAP and TOOLS packages.
;
; NOTES:
;        Add new model selections as is necessary.  Also be sure to
;        update routines "ctm_type", "ctm_grid", and "getsigma".
;
; EXAMPLE:
;        MODELINFO = SELECT_MODEL( DEFAULT='GISS_II_PRIME 4x5 (23L)' )
;            
;             ; Will return the modelinfo structure for the 23-layer
;             ; GISS-II-PRIME model.  We need to specify the number
;             ; of layers here since there is also a 9-layer version
;             ; of the GISS-II-PRIME model.
;
; MODIFICATION HISTORY:
;        mgs, 13 Aug 1998: VERSION 1.00
;        mgs, 21 Dec 1998: - added GEOS_STRAT 2x2.5
;        mgs, 25 Mar 1999: - changed FSU to 4x5 and added 'generic'
;        bmy, 27 Jul 1999: GAMAP VERSION 1.42
;                          - now add the number of layers to the menu choices
;                          - added GISS-II-PRIME 23-layer model as a choice
;                          - more sophisticated testing for default model 
;                          - a few cosmetic changes
;        bmy, 03 Jan 2000: GAMAP VERSION 1.44
;                          - added GEOS-2 as a model selection
;                          - added standard comment header
;        bmy, 16 May 2000: GAMAP VERSION 1.45
;                          - now use GEOS-2 47-layer grid 
;        bmy, 28 Jul 2000: GAMAP VERSION 1.46
;                          - added GEOS-3 48-layer grids for 1 x 1, 
;                            2 x 2.5, and 4 x 5 horizontal resolution
;        bmy, 26 Jul 2001: GAMAP VERSION 1.48
;                          - added GEOS-3 30-layer grids for 2 x 2.5
;                            and 4 x 5 horizontal resolution
;        bmy, 24 Aug 2001: - deleted GEOS-3 30-layer grids, since
;                            we won't be using these soon
;        bmy, 06 Nov 2001: GAMAP VERSION 1.49
;                          - added GEOS-4/fvDAS grids at 1 x 1.25,
;                            2 x 2.5, and 4 x 5 resolution
;  clh & bmy, 18 Oct 2002: GAMAP VERSION 1.52
;                          - added MOPITT 7L grid 
;        bmy, 11 Dec 2002  - deleted GEOS-2 47L grid, nobody uses this
;        bmy, 18 May 2007: TAMAP VERSION 2.06
;                          - added GEOS-4 30L grid
;                          - added GEOS-5 47L and 72L grids
;                          - added quit option
;
;-
; Copyright (C) 1998-2007,
; Martin Schultz and Bob Yantosca, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes.  This copyright notice must be kept with any copy of 
; this software.  If this software shall be used commercially or 
; sold as part of a larger package, please contact the author.  
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; with subject "IDL routine select_model"
;-----------------------------------------------------------------------

 
function Select_Model, default=default
 
   ; External functions
   FORWARD_FUNCTION CTM_Type

   ; Keyword Settings
   if ( N_Elements( Default ) eq 0 ) then Default = ''

   ; User menu (add new models as is necessary...)   Index
   Selection = [ 'GEOS1         4x5    (20L)', $      ; 0
                 'GEOS1         2x2.5  (20L)', $      ; 1
                 'GEOS_STRAT    4x5    (26L)', $      ; 2
                 'GEOS_STRAT    2x2.5  (26L)', $      ; 3
                 'GEOS3         4x5    (48L)', $      ; 4
                 'GEOS3         2x2.5  (48L)', $      ; 5
                 'GEOS3         1x1    (48L)', $      ; 6
                 'GEOS4_30L     4x5    (30L)', $      ; 7
                 'GEOS4_30L     2x2.5  (30L)', $      ; 8
                 'GEOS4_30L     1x1.25 (30L)', $      ; 9
                 'GEOS4         4x5    (55L)', $      ; 10
                 'GEOS4         2x2.5  (55L)', $      ; 11
                 'GEOS4         1x1.25 (55L)', $      ; 12
                 'GEOS5_47L     4x5    (47L)', $      ; 13
                 'GEOS5_47L     2x2.5  (47L)', $      ; 14
                 'GEOS5         4x5    (72L)', $      ; 15
                 'GEOS5         2x2.5  (72L)', $      ; 16
                 'GISS_II       4x5    ( 9L)', $      ; 17
                 'GISS_II_PRIME 4x5    ( 9L)', $      ; 18
                 'GISS_II_PRIME 4x5    (23L)', $      ; 19
                 'FSU           4x5    (14L)', $      ; 20
                 'MOPITT        2x2.5  ( 7L)', $      ; 21
                 'generic grid',               $      ; 22
                 'QUIT'                      ]        ; 23

   ; Remove white space from SELECTION and DEFAULT, 
   ; and store in temporary variables
   TmpSelection = StrUpCase( StrCompress( Selection, /Remove_All ) )
   TmpDefault   = StrUpCase( StrCompress( Default,   /Remove_All ) )
 
   ; Locate which element of SELECTION corresponds to DEFAULT
   ; If the EQ test doesn't work, then go to a STRPOS test!
   Ind = Where( TmpSelection eq TmpDefault )
   if ( Ind[0] lt 0 ) $
      then Ind = Where( StrPos( TmpSelection, TmpDefault ) ge 0 )

   Message, 'Please select one of the following model types:', /Info
   for i=0,n_elements(selection)-1 do begin
      extra = '   '
      if (i eq ind[0]) then extra = '(*)'

      ; Add extra space for numbers less than 10 (bmy, 1/3/00)
      if ( i+1 lt 10 ) then extra2 = '  : ' else extra2 = ' : '
      print, '   ', extra,' ', strtrim(i+1,2), extra2, selection[i]
   endfor
   
   ch = ''
   choice = -1
   while (choice lt 0 OR choice ge n_elements(selection)) do begin
      read,ch,prompt='---> '
      if (ch eq '' AND ind[0] ge 0) then choice = ind[0] $
      else choice = fix(ch)-1
   endwhile
   
   ; return information
   ; (no else branch because this MUST NOT happen !)
   case (choice) of
      0  : return,ctm_type( 'GEOS1',         res=4             )
      1  : return,ctm_type( 'GEOS1',         res=2             )
      2  : return,ctm_type( 'GEOS_STRAT',    res=4             )
      3  : return,ctm_type( 'GEOS_STRAT',    res=2             )
      4  : return,ctm_type( 'GEOS3',         res=4             )
      5  : return,ctm_type( 'GEOS3',         res=2             )
      6  : return,ctm_type( 'GEOS3',         res=1             )
      7  : return,ctm_type( 'GEOS4_30L',     res=4             )
      8  : return,ctm_type( 'GEOS4_30L',     res=2             )
      9  : return,ctm_type( 'GEOS4_30L',     res=[1.25, 1]     )
      10 : return,ctm_type( 'GEOS4',         res=4             )
      11 : return,ctm_type( 'GEOS4',         res=2             )
      12 : return,ctm_type( 'GEOS4',         res=[1.25, 1]     )
      13 : return,ctm_type( 'GEOS5_47L',     res=4             )
      14 : return,ctm_type( 'GEOS5_47L',     res=2             )
      15 : return,ctm_type( 'GEOS5',         res=4             )
      16 : return,ctm_type( 'GEOS5',         res=2             )
      17 : return,ctm_type( 'GISS_II',       res=4             )
      18 : return,ctm_type( 'GISS_II_PRIME', res=4, NLayers=9  )
      19 : return,ctm_type( 'GISS_II_PRIME', res=4, NLayers=23 )
      20 : return,ctm_type( 'FSU',           res=4             )
      21 : return,ctm_type( 'MOPITT',        res=2             )
      22 : begin
             res = fltarr(2)
             read,res,prompt='Resolution vector of generic grid ' 
             return,ctm_type('generic',res=res)
          end
      23 : return, -1L
   endcase
 
end
 
