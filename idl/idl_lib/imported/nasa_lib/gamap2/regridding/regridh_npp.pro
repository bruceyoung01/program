; $Id: regridh_npp.pro,v 1.1.1.1 2007/07/17 20:41:33 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        REGRIDH_NPP
;
; PURPOSE:
;        Horizontally regrids NPP data from native
;        resolution to a CTM grid.
;
; CATEGORY:
;        Regridding
;
; CALLING SEQUENCE:
;        REGRIDH_NPP [, Keywords ]
;
; INPUTS:
;        None
;
; KEYWORD PARAMETERS:
;        INFILENAME -> Name of the file containing data to be regridded.
;             Default is: '~bmy/S/CO2/nep_gpp.nc'.
;
;        OUTMODELNAME -> Name of the model grid onto which the data
;             will be regridded.  Default is 'GEOS3'.
;
;        OUTRESOLUTION -> Specifies the resolution of the model grid
;             onto which the data will be regridded.  OUTRESOLUTION
;             can be either a 2 element vector with [ DI, DJ ] or
;             a scalar (DJxDI: 8=8x10, 4=4x5, 2=2x2.5, 1=1x1, 
;             0.5=0.5x0.5).  Default for all models is 4x5.
;
;        DIAGN -> Diagnostic category of the data blocks that you 
;            wish to regrid.  Default is "IJ-AVG-$".
;
; OUTPUTS:
;        None
;
; SUBROUTINES:
;        External Subroutines Required:
;        =======================================================
;        CTM_TYPE          (function)   CTM_GRID      (function)
;        CTM_RESEXT        (function)   CTM_REGRIDH   (function)
;        CTM_MAKE_DATAINFO (function)   CTM_WRITEBPCH
;        UNDEFINE
; 
; REQUIREMENTS:
;        None
;
; NOTES:
;        Output filenames are hardwired.
;
; EXAMPLE:
;        REGRIDH_NEP, INFILENAME='nep_gpp.nc', $
;                     OUTMODELNAME='GEOS3',    $
;                     OUTRESOLUTION=4
;
;             ; Regrids NEP data to the GEOS-3 4x5 grid.
;
; MODIFICATION HISTORY:
;        bmy, 15 Apr 2003: VERSION 1.00
;        bmy, 23 Dec 2003: VERSION 1.01
;                          - updated for GAMAP v2-01
;                          - added DIAGN keyword
;  bmy & phs, 20 Jun 2007: GAMAP VERSION 2.10
;
;-
; Copyright (C) 2000-2007, 
; Bob Yantosca, and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of this 
; software. If this software shall be used commercially or sold as 
; part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.as.harvard.edu with subject "IDL routine regridh_npp" 
;-----------------------------------------------------------------------


pro RegridH_NPP, InFileName=InFileName,     OutFileName=OutFileName,     $
                 OutModelName=OutModelName, OutResolution=OutResolution, $
                 DiagN=DiagN

   ;====================================================================
   ; Initialization
   ;====================================================================

   ; Keywords
   if ( N_Elements( DiagN         ) eq 0 ) then DiagN         = 
   if ( N_Elements( OutModelName  ) eq 0 ) then OutModelName  = 'GEOS3'
   if ( N_Elements( OutResolution ) eq 0 ) then OutResolution = 1

   ; Default INFILENAME
   if ( N_Elements( InFileName ) eq 0 ) then begin
      InFileName = '~/S/CO2/nep_gpp.nc'
   endif

   ;====================================================================
   ; Read input data
   ;====================================================================

   ; Read from NCDF file
   NCDF_Read, Result, File=InFileName, /All, Attributes=Attributes

   ; Extract the data
   Lon           = Result.LON
   Lat           = Result.LAT
   Time          = Result.TIME
   Nep           = Result.NEP_GPP

   ; Extract the units and missing value
   Lon_Units     = Attributes.LON.Units
   Lat_Units     = Attributes.LAT.Units
   Time_Units    = Attributes.TIME.Units
   Nep_Units     = Attributes.NEP_GPP.Units

   ; Undefine data
   UnDefine, Result
   UnDefine, Attributes

   Print, 'Longitude units are    : ', Lon_Units
   Print, 'Latitude units are     : ', Lat_Units
   Print, 'NEP units are        : ', nep_Units

   Print
   Print, 'Longitudes: '
   Print, Lon, Format='(9f8.2)'
   
   Print
   Print, 'Latitudes: '
   Print, Lat, Format='(9f8.2)'

   return

   ;Pass 1st NEP level to array
    nep1 = nep[*,*,1]

   ; Strip missing value
;   Ind = Where( FArea eq FArea_Missing )
;   if ( Ind[0] ge 0 ) then FArea[Ind] = 0.0

   ; Also reorder latitude so that we plot from S --> N
;   Lat   = Reverse( Lat )
;   FArea = Reverse( FArea, 2 )
   
;   ; Plot map
;   Open_Device, /PS, /Color, Bits=8, File='casa.ps'

;   TvMap, nep1, Lon, Lat, $
;      /Sample, /Grid, /Countries, /Coasts, /CBar, Div=4,   $
;       Title='CASA'

;   Close_Device


end
