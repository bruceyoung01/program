; $Id: ctm_read_planeflight.pro,v 1.1.1.1 2003/10/22 18:06:04 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        CTM_READ_PLANEFLIGHT
;
; PURPOSE:
;        Reads GEOS-CHEM plane flight diagnostic (ND40) data.  
;
; CATEGORY:
;        CTM Tools
;
; CALLING SEQUENCE:
;        RESULT = CTM_READ_PLANEFLIGHT( FILENAME )
;
; INPUTS:
;        FILENAME -> Name of the file containing data from the GEOS-CHEM
;             plane following diagnostic ND40.  Default is "plane.log".
;
; KEYWORD PARAMETERS:
;        None
;
; OUTPUTS:
;        RESULT -> Array of structures containing data from read from
;             the input file.  There will be one element per plane
;             flight track point.
;
; SUBROUTINES:
;        Internal Subroutines:
;        ===================================
;        Valid_TagName           (function) 
;        CreateStructureTemplate (function)
;
;        External Subroutines Required:
;        ===================================
;        OPEN_FILE   
;        STRBREAK (function)
;        STRREPL  (function)
;
; REQUIREMENTS:
;
; NOTES:
;
; EXAMPLE:
;
; MODIFICATION HISTORY:
;        bmy, 08 Aug 2003: VERSION 1.00
;
;-
; Copyright (C) 2003, Bob Yantosca, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author.
; Bugs and comments should be directed to bmy@io.harvard.edu
; with subject "IDL routine ctm_read_planeflight"
;-----------------------------------------------------------------------


function Valid_TagName, Tag
 
   ;====================================================================
   ; Internal function Valid_TagName replaces invalid characters in
   ; a structure tag with valid characters. (bmy, 8/7/03)
   ;====================================================================
   T = StrRepl( Tag, '-', '_' )
   T = StrRepl( T,   '+', 'P' )
   T = StrRepl( T,   '$', 'D' )
   T = StrRepl( T,   '*', 'S' )
   T = StrRepl( T,   '&', '_' )
   T = StrRepl( T,   ' ', '_' )
   T = StrRepl( T,   '@', '_' )
   T = StrRepl( T,   ':', '_' )       
   T = StrRepl( T,   '=', '_' )      
   T = StrRepl( T,   '#', '_' )      
   return, T
end
 
;------------------------------------------------------------------------------
 
function GetStructureTemplate, Name
 
   ;====================================================================
   ; Internal function GetStructureTemplate defines a template structure
   ; the PLANEINFO array of structurcharacters in
   ; a structure tag with valid characters. (bmy, 8/7/03)
   ;====================================================================
 
   ; Loop over all names
   for N = 0L, N_Elements( Name )-1L do begin
 
      ; Strip out invalid characters 
      ThisTag = Valid_TagName( Name[N] )
 
      ; Assign default tag values
      case ( ThisTag ) of
         'POINT'    : ThisValue = 0L
         'TYPE'     : ThisValue = ''
         'YYYYMMDD' : ThisValue = 0L
         'HHMM'     : ThisValue = 0L
         else       : ThisValue = 0e0
      endcase
      
      ; Create default structure
      if ( N eq 0L ) $                                                 $
         then Template = Create_Struct(           ThisTag, ThisValue ) $
         else Template = Create_Struct( Template, ThisTag, ThisValue )
   endfor
 
   ; Return to main program
   return, Template
end
 
;------------------------------------------------------------------------------
 
function CTM_Read_PlaneFlight, FileName
 
   ;====================================================================
   ; Initialization
   ;====================================================================

   ; External function
   FORWARD_FUNCTION StrBreak, StrRepl

   ; Keywords
   if ( N_Elements( FileName ) ne 1 ) then FileName = 'plane.log'
 
   ;====================================================================
   ; Read header and create template structure
   ;====================================================================
 
   ; Open file
   Open_File, FileName, Ilun, /Get_LUN
 
   ; Read header line
   Line = ''
   ReadF, Ilun, Line
 
   ; Read names from the header file
   Name   = StrBreak( Line, ' ' )
   N_Name = N_Elements( Name )
 
   ; Create default structure template
   Template = GetStructureTemplate( Name )
 
   ;====================================================================
   ; Read data into structures
   ;====================================================================
 
   ; First time flag
   FirstTime = 1L
   
   ; Loop thru file
   while ( not EOF( Ilun ) ) do begin
 
      ; Parse one line at a time
      Readf, Ilun, line
      List   = StrBreak( Line, ' ' )
      N_List = N_Elements( List )
 
      ; If this is a valid data line
      if ( N_List eq N_Name ) then begin
 
         ; Place fields from line into structure
         for L = 0L, N_List-1L do begin
            Template.(L) = List[L]
         endfor
 
         ; Assign into array of structures
         if ( FirstTime )                            $
            then PlaneInfo = [            Template ] $
            else PlaneInfo = [ PlaneInfo, Template ]
         
         ; Reset first-time flag
         FirstTime = 0L
      endif
 
   endwhile
 
   ;====================================================================
   ; Cleanup and quit
   ;====================================================================   
   Close,    Ilun
   Free_LUN, Ilun
 
   ; Return to calling program
   return, PlaneInfo
end
