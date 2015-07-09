; $Id: regridh_aircraft_data.pro,v 1.2 2008/04/28 14:07:24 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        REGRIDH_AIRCRAFT_DATA
;
; PURPOSE:
;        Driver program for routines REGRIDH_AIRCRAFT_NOX 
;        and REGRIDH_AIRCRAFT_FUEL.  
;
; CATEGORY:
;        Regridding
;
; CALLING SEQUENCE:
;        REGRIDH_AIRCRAFT_DATA [, Keywords ]
;
; INPUTS:
;        None
;
; KEYWORD PARAMETERS:
;        /NOX -> Set this switch to regrid aircraft NOx data.
;
;        /SOx -> Set this switch to regrid aircraft SOx data.
;
;        OUTMODELNAME -> A string containing the name of the model 
;             grid onto which the NOx emissions will be regridded.
;             Default is 'GEOS3'.
;
;        OUTRESOLUTION -> Specifies the resolution of the model grid
;             onto which the NOX emissions will be regridded.  
;             OUTRESOLUTION can be either a 2 element vector with 
;             [ DI, DJ ] or a scalar (DJxDI: 8=8x10, 4=4x5, 2=2x2.5, 
;             1=1x1, 0.5=0.5x0.5).  Default is 1.
;
; OUTPUTS:
;        None
;
; SUBROUTINES:
;        External Subroutines Required:
;        ================================
;        REGRIDH_AIRCRAFT_NOX  (function)
;        REGRIDH_AIRCRAFT_FUEL (function)
;
; REQUIREMENTS:
;        References routines from the GAMAP and TOOLS packages.
;
; NOTES:
;        Input & output directories are hardwired for now, 
;        you can change them as is necessary.
;
; EXAMPLE:
;        REGRIDH_AIRCRAFT_DATA, /NOX,                 $
;                               OUTMODELNAME='GEOS3', $
;                               OUTRESOLUTION=1
;           
;             ; Regrids aircraft NOx data from native
;             ; resolution to GEOS-3 1x1 grid.
;
; MODIFICATION HISTORY:
;        bmy, 23 Dec 2003: VERSION 1.01
;                          - Initial version
;        bmy, 28 Apr 2008: GAMAP VERSION 2.12
;                          - Corrected typo at line 142
;                                
;-
; Copyright (C) 2003-2008, Bob Yantosca, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of this 
; software. If this software shall be used commercially or sold as 
; part of a larger package, please contact the author. Bugs and 
; comments should be directed to yantosca@seas.harvard.edu or
; plesager@seas.harvard.edu with subject "IDL routine regridh_aircraft_data"
;-----------------------------------------------------------------------


pro RegridH_Aircraft_Data, NOx=NOx, SOx=SOx,          $
                           OutModelName=OutModelName, $
                           OutResolution=OutResolution

   ;====================================================================
   ; Initialization
   ;====================================================================

   ; Month array
   Months = [ 'jan', 'feb', 'mar', 'apr', 'may', 'jun',  $
              'jul', 'aug', 'sep', 'oct', 'nov', 'dec' ] 

   ;====================================================================
   ; NOx (create global size @ 1x1)
   ;====================================================================
   if ( Keyword_Set( NOx ) ) then begin

      ; Directories (change as necessary)
      InDir  = '~/S/AIRCRAFT_1x1/'
      OutDir = '/data/ctm/GEOS_1x1_NA/aircraft_NOx_200202/'

      ; Input & output file arrays
      File1 = InDir  + 'total_1992_' + Months + '.kg_day.3d'
      File2 = OutDir + 'air'         + Months + '.1x1.fullsize'

      ; Set flag
      US = 0L
      
      ; Loop over months
      for I = 0, 11 do begin

         ; Get input & output file names
         InFile   = File1[I]
         OutFile  = File2[I]

         ;print, InFile
         ;print, OutFile

         ; Regrid the data!
         RegridH_Aircraft_NOx, InFileName=InFile,           $
                               OutFileName=OutFile,         $
                               OutModelName=OutModelName,   $
                               OutResolution=OutResolution, $
                               Use_Saved=US

         ; Reset flag
         US = 1L
      endfor
   endif

   ;====================================================================
   ; Aircraft Fuel for SOx (create global size @ 1x1)
   ;====================================================================
   if ( Keyword_Set( SOx ) ) then begin

      ; Directories (change as necessary)
      InDir  = '~/S/sulfate_aircraft/'
      OutDir = '/data/ctm/GEOS_1x1_NA/sulfate_sim_200210/'

      ; File names (change as necessary)
      File1 = 'total_1992_'        + Months + '.kg_day.3d.v971020'
      File2 = 'aircraft.1x1.1992.' + Months + '.fullsize'

      ; Set flag
      US = 0L

      ; Loop over months
      for I = 0, 11 do begin

         ; Get input & output file names
         InFile   = InDir  + File1[I]
         OutFile  = OutDir + File2[I]
         
         ;print, InFile
         ;print, OutFile
         
         ; Regrid aircraft data (total fuel)
         ; (SOx is a fraction of this)
         RegridH_Aircraft_Fuel, InFile=InFile,               $  
                                OutFile=OutFile,             $
                                OutModelName=OutModelName,   $
                                OutResolution=OutResolution, $ 
                                Use_Saved=US
         
         ; Reset flag
         US = 1L
      endfor
   endif

end
