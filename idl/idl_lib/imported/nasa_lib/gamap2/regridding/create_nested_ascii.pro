; $Id: create_nested_ascii.pro,v 1.1.1.1 2007/07/17 20:41:31 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        CREATE_NESTED_ASCII
;
; PURPOSE:
;        Reads data from an ASCII file and trims it to nested-grid
;        resolution.  Also renumbers I and J from "global" to "window" 
;        coordinates.  Vertical and temporal resolution are not affected.
;
; CATEGORY:
;        Regridding
;
; CALLING SEQUENCE:
;        CREATE_NESTED_ASCII [, Keywords ]
;
; INPUTS:
;        None
;
; KEYWORD PARAMETERS:
;        INMODELNAME -> A string containing the name of the model 
;             grid on which the input data resides.  Default is 'GEOS3'.
;
;        INRESOLUTION -> Specifies the resolution of the model grid
;             on which the input data resides.  INRESOLUTION
;             can be either a 2 element vector with [ DI, DJ ] or
;             a scalar (DJxDI: 8=8x10, 4=4x5, 2=2x2.5, 1=1x1, 
;             0.5=0.5x0.5).  Default is 1.
;
;        INFILENAME -> Name of the input file containing data to be 
;             trimmed down to "nested" model grid resolution.  If 
;             omitted, a dialog box will prompt the user to supply
;             a filename.
;
;        OUTFILENAME -> Name of the file that will contain trimmed
;             data on the "nested" model grid.  OUTFILENAME will be
;             in binary punch resolution.  If omitted, a dialog box 
;             will prompt the user to supply a filename.
;
;        XRANGE -> A 2-element vector containing the minimum and
;             maximum box center longitudes which define the nested
;             model grid. Default is [-180,180].
;
;        YRANGE -> A 2-element vector containing the minimum and
;             maximum box center latitudes which define the nested
;             model grid. Default is [-180,180].
;
;        HEADER -> Number of header lines to skip over.
;
;        FORMAT -> String describing the input file format.  
;             Default is '(2i3,a)', i.e., two 3-digit integers
;             and then an unspecified length character line.
;
; OUTPUTS:
;        None
;
; SUBROUTINES:
;        External Subroutines Required:
;        ================================================
;        CTM_TYPE (function)   CTM_GRID (function)
;        OPEN_FILE
;
; REQUIREMENTS:
;        None
;
; NOTES:
;        (1) Assumes I and J (the lon & lat grid box indices) 
;            are the first two items on each line.
;
;        (2) Assumes that the nested-grid does not wrap around
;            the date line.  
;
; EXAMPLE:
;        CREATE_NESTED_ASCII, INFILENAME='fert_scale.dat.1x1', $
;                             OUTFILENAME='fert_scale.dat,     $
;                             XRANGE=[ -140, -40 ],            $
;                             YRANGE=[   10,  60 ],            $
;                             FORMAT='(2i6,a)
;
;             ; Trims data from "fert_scale.dat.1x1" to a GEOS-3
;             ; 1x1 (default values) nested grid from 14OW to 4OW 
;             ; and 10N to 60N (in this example, this covers the US 
;             ; and parts of Canada and Mexico).
;
; MODIFICATION HISTORY:
;        bmy, 10 Apr 2003: VERSION 1.00
;  bmy & phs, 20 Jun 2007: GAMAP VERSION 2.10
;
;-
; Copyright (C) 2003-2007, 
; Bob Yantosca, and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of this 
; software. If this software shall be used commercially or sold as 
; part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.as.harvard.edu with subject "IDL routine create_nested_ascii"
;-----------------------------------------------------------------------


pro Create_Nested_Ascii, InFileName=InFileName,   OutFileName=OutFileName,   $
                         InModelName=InModelName, InResolution=InResolution, $
                         XRange=XRange,           YRange=YRange,             $
                         Header=Header,           Format=Format,             $
                         _EXTRA=e
 
   ;====================================================================
   ; Initialization
   ;====================================================================
 
   ; External functions
   FORWARD_FUNCTION CTM_Type, CTM_Grid
 
   ; Keyword Settings
   if ( N_Elements( Format       ) eq 0 ) then Format       = '(2i3,a)'
   if ( N_Elements( Header       ) eq 0 ) then Header       = -1L
   if ( N_Elements( InModelName  ) eq 0 ) then InModelName  = 'GEOS3'
   if ( N_Elements( InResolution ) eq 0 ) then InResolution = 1
   if ( N_Elements( XRange       ) eq 0 ) then XRange       = [-180,180]
   if ( N_Elements( YRange       ) eq 0 ) then YRange       = [ -90, 90]
 
   ; Assume GEOS-3 1x1 grid for now -- change if necesary
   InType = CTM_Type( InModelName, Res=InResolution )
   InGrid = CTM_Grid( InType )

   ; Get the index arrays in the X and Y dimensions
   IndX = Where( InGrid.XMid ge XRange[0] AND InGrid.XMid le XRange[1] )
   IndY = Where( InGrid.YMid ge YRange[0] AND InGrid.YMid le YRange[1] )

   ; Get min & max lon & lat (add 1 for FORTRAN notation)
   ; NOTE: Assumes we don't wrap around date line -- fix later if necessary
   IMin = Min( IndX+1, Max=IMax )
   JMin = Min( IndY+1, Max=JMax )

   ; Offsets
   IOff = IMin - 1L
   JOff = JMin - 1L

   ; Define variables
   Line = ''
   I    = 0L
   J    = 0L
   
   ;====================================================================
   ; Read data and trim it to the size of the nested grid
   ;====================================================================

   ; Hardwire input & output files for now
   Ilun_IN  = 50
   Ilun_OUT = 51

   ; Open input and output files
   Open_File, InFileName,  Ilun_IN          ;, /Get_LUN
   Open_File, OutFileName, Ilun_OUT, /Write ;, /Get_LUN
   
   ; Write header lines to output file (if any)
   for N = 0L, Header - 1L do begin
      ReadF,  Ilun_IN, Line
      PrintF, Ilun_OUT, Line
   endfor

   ; Loop thru input file
   while ( not EOF( Ilun_IN ) ) do begin
 
      ; Read a line from the input file 
      ReadF, Ilun_IN, I, J, Line, Format=Format

      ; If I,J are w/in the nested grid, write line to the output file
      if ( ( I ge IMin AND I le IMax )   AND $
           ( J ge JMIn AND J le JMax ) ) then begin
         PrintF, Ilun_OUT, I-IOff, J-JOff, Line, Format=Format
      endif

   endwhile

   ;====================================================================
   ; Close files and quit
   ;====================================================================
   Close,    Ilun_IN
   ;Free_LUN, Ilun_IN

   Close,    Ilun_OUT
   ;Free_LUN, Ilun_OUT

   ; Quit
   return
end
          
