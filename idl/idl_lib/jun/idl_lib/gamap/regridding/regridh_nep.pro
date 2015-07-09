; $Id: regridh_nep.pro,v 1.1.1.1 2007/07/17 20:41:33 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        REGRIDH_NEP
;
; PURPOSE:
;        Horizontally regrids NEP data from its resolution to a CTM grid.
;
; CATEGORY:
;        Regridding
;
; CALLING SEQUENCE:
;        REGRIDH_NEP [, Keywords ]
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
; or phs@io.as.harvard.edu with subject "IDL routine regridh_nep"
;-----------------------------------------------------------------------


pro RegridH_NEP, InFileName=InFileName,       OutModelName=OutModelName, $
                 OutResolution=OutResolution, DiagN=DiagN
   
   ;====================================================================
   ; Initialization
   ;====================================================================
 
   ; External functions
   FORWARD_FUNCTION CTM_Type,    CTM_Grid, CTM_ResExt, $
                    CTM_RegridH, CTM_Make_DataInfo

   ; Default input file name
   DefFile = '~bmy/S/CO2/nep_gpp.nc'

   ; Keywords
   if ( N_Elements( DiagN         ) eq 0 ) then DiagN         = 'GLOB-NPP'
   if ( N_Elements( InFileName    ) eq 0 ) then InFileName    = DefFile
   if ( N_Elements( OutModelName  ) eq 0 ) then OutModelName  = 'GEOS3'
   if ( N_Elements( OutResolution ) eq 0 ) then OutResolution = 4
 
   ; Input grid
   InType  = CTM_Type( 'generic', Res=[5.625, 5.53], Halfpolar=0, Center180=1 )
   InGrid  = CTM_Grid( InType )
 
   ; Output grid
   OutType = CTM_Type( OutModelName, Res=OutResolution )
   OutGrid = CTM_Grid( OutType )
 
   ; Reuse saved mapping weights
   US = 0L
 
   ;====================================================================
   ; Read data from netCDF file
   ;====================================================================
 
   ; Echo filename
   S = 'Reading ' + StrTrim( InFileName, 2 )
   Message, S, /Info
 
   ; Read from NCDF file
   NCDF_Read, Result, File=InFileName, /All, Attributes=Attributes
 
   ; Extract the data
   Lon        = Result.LON
   Lat        = Result.LAT
   Time       = Result.TIME
   Nep        = Result.NEP_GPP
 
   ; Extract the units
   Lon_Units  = Attributes.LON.Units
   Lat_Units  = Attributes.LAT.Units
   Time_Units = Attributes.TIME.Units
   Nep_Units  = Attributes.NEP_GPP.Units
 
   ; Undefine structures
   UnDefine, Result
   UnDefine, Attributes
 
   ; Shift arrays in longitude by 180 degrees
   Nx         = N_Elements( Lon )
   Lon        = Shift( Lon, Nx/2 )
   Nep        = Shift( Nep, Nx/2, 0, 0 )
   
   ; Put lon in the range [-180..180]
   Ind = Where( Lon ge 180 )
   if ( Ind[0] ge 0 ) then Lon[Ind] = Lon[Ind] - 360.0
 
   ; Print info
   Print, 'Longitude units are : ', Lon_Units
   Print, 'Latitude units are  : ', Lat_Units
   Print, 'Latitude units are  : ', Time_Units
   Print, 'NEP units are       : ', Nep_Units
   Print
   Print, 'Longitudes: '
   Print, Lon, Format='(7f11.5)'
   Print
   Print, 'Latitudes: '
   Print, Lat, Format='(7f11.5)'
   ;Print
   ;Print, 'Time: '
   ;Print, Time, Format='(7f10.4)'
 
   ;====================================================================
   ; Process data
   ;====================================================================  
 
   ; Convert unit sfrom (kg C/m2/s) to molecules CO2/cm2/s
   ; Conversion factor  = 1e3 *(1/1e4) * (1/12) * Avogadro number
   ;         convert to   g C   cm^2     mole C   molecule CO2
   ; Overall factor = (6.022e23/12)*(1/10)
   Conv1  = 6.022d23 / 12.0d0
   Conv2  = (1d0 / 10d0)
   Convf  = Conv1 * Conv2
   NEP    = NEP   * Convf
 
   ; Loop over days per year
   for JDay = 1L, 365L do begin
      
      ; Find Day index
      Ind = Where( Time ge JDay and Time le JDay+1 )
      if ( Ind[0] lt 0 ) then Message, 'Could not find right time!'
 
      ; Today's output file name
      OutFileName = 'nep.geos.' + CTM_ResExt( OutType ) + $
                    '.'         + String( JDay, Format='(i3.3)' )
 
      ; Echo info
      S = 'Creating ' + StrTrim( OutFileName, 2 )
      Message, S, /Info

      ; Set Flags
      FirstTimeToday = 1L
 
      ;--------------------------
      ; Loop over times per day
      ;--------------------------
      for T = 0L, N_Elements( Ind ) - 1L do begin

         ; Get NEP data for this day
         InData = Reform( NEP[ *, *, Ind[T] ] )
     
         ; Compute TAU0 and TAU1 (assume generic year 1985)
         Tau0 = ( ( JDay-1L )* 24d0 ) + ( Double( T ) * 3d0 )
         Tau1 = Tau0 + 3d0
 
         ; Regrid data to GEOS-CHEM grid 
         OutData = CTM_RegridH( InData, InGrid, OutGrid, $
                                /Per_Unit_Area, /Double, Use_Saved=US )
 
         ; Make a DATAINFO structure for this NEWDATA
         Success = CTM_Make_DataInfo( Float( OutData ),         $
                                      ThisDataInfo,             $
                                      ThisFileInfo,             $
                                      ModelInfo=OutType,        $
                                      GridInfo=OutGrid,         $
                                      DiagN=DiagN,              $
                                      Tracer=2,                 $
                                      Tau0=Tau0,                $
                                      Tau1=Tau1,                $
                                      Unit='molec CO2/cm2/s',   $
                                      Dim=[OutGrid.IMX,         $
                                           OutGrid.JMX, 0, 0],  $
                                      First=[1L, 1L, 1L],       $
                                      /No_Global )
 
         ; Reuse the same mapping weights from now on
         US = 1L
 
         ; Append to NEWDATAINFO structure
         if ( FirstTimeToday )                                  $
            then NewDataInfo = ThisDataInfo                     $
            else NewDataInfo = [ NewDataInfo, ThisDataInfo ] 

         ; Reset first-time flag
         FirstTimeToday = 0L
 
         ; Undefine stuff
         UnDefine, InData
         UnDefine, OutData
         UnDefine, ThisDataInfo
 
      endfor
      
      ;---------------------------
      ; Write to daily bpch file
      ;---------------------------
      CTM_WriteBpch, NewDataInfo, ThisFileInfo, FileName=OutFileName
 
      ; Undefine more stuff
      UnDefine, Ind
      UnDefine, NewDataInfo
      UnDefine, FirstTimeToday
      UnDefine, OutFileName
 
   endfor
 
end
