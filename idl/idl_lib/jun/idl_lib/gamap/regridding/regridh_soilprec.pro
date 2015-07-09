; $Id: regridh_soilprec.pro,v 1.2 2008/04/24 13:59:06 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        REGRIDH_SOILPREC
;
; PURPOSE:
;        Regrids soil precipitation from 0.5 x 0.5 resolution 
;        onto a CTM grid of equal or coarser resolution.
;        
; CATEGORY:
;        Regridding
;
; CALLING SEQUENCE:
;        REGRIDH_SOILPREC [, Keywords ]
;
; INPUTS:
;        None
;
; KEYWORD PARAMETERS:
;        INFILENAME -> Name of the file containing data to be regridded.
;             Default: "~bmy/archive/data/soil_NOx_200203/05x05_gen/lcprc.asc"
;
;        OUTFILENAME -> Name of the file which will contain the regridded 
;             data.  Default is "soil_precip.geos.{RESOLUTION}".
;
;        OUTMODELNAME -> Name of the model grid onto which the data
;             will be regridded.  Default is "GEOS3".
;
;        OUTRESOLUTION -> Specifies the resolution of the model grid
;             onto which the data will be regridded.  OUTRESOLUTION
;             can be either a 2 element vector with [ DI, DJ ] or
;             a scalar (DJxDI: 8=8x10, 4=4x5, 2=2x2.5, 1=1x1, 
;             0.5=0.5x0.5).  Default for all models is 4x5.
;
;        DIAGN -> Diagnostic category of the data blocks that you 
;            wish to regrid.  Default is "SOILPREC".
;
; OUTPUTS:
;        None
;  
; SUBROUTINES:
;        External Subroutines Required:
;        ==============================================
;        CTM_TYPE    (function)   CTM_GRID   (function)
;        CTM_NAMEXT  (function)   CTM_RESEXT (function)
;        CTM_REGRIDH (function)   CTM_BOXSIZE
;        CTM_WRITEBPCH            UNDEFINE
; 
; REQUIREMENTS:
;        None
;
; NOTES:
;        None
;
; EXAMPLE: 
;        REGRIDH_SOILPREC, OUTMODELNAME='GEOS3', $
;                          OUTRESOLUTION=2,      $
;                          OUTFILENAME='soil_precip.geos.2x25'
;
;             ; Regrids 0.5 x 0.5 soil precipitation data onto
;             ; the GEOS-1 2 x 2.5 grid.  Output will be sent
;             ; to the "~bmy/regrid" directory.  
;
; MODIFICATION HISTORY:
;        bmy, 01 Aug 2000: VERSION 1.00
;        bmy, 08 Jan 2003: VERSION 1.01
;                          - renamed to "regridh_soilprec.pro"
;                          - removed OUTDIR, added OUTFILENAME
;                          - updated comments
;        bmy, 23 Dec 2003: VERSION 1.02
;                          - updated for GAMAP v2-01
;  bmy & phs, 20 Jun 2007: GAMAP VERSION 2.10
;        bmy, 24 Apr 2008: GAMAP VERSION 2.12
;                          - bug fix: N_ELEMENTS was misspelled
;
;-
; Copyright (C) 2000-2008, 
; Bob Yantosca, and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of this 
; software. If this software shall be used commercially or sold as 
; part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.as.harvard.edu with subject "IDL routine regridh_soilprec"
;-----------------------------------------------------------------------


pro RegridH_SoilPrec, InFileName=InFileName,     OutFileName=OutFileName,    $
                      OutModelName=OutModelName, OutResolution=OutResolution,$
                      DiagN=DiagN,               _EXTRA=e

   ;===================================================================
   ; Initialization
   ;===================================================================

   ; External functions
   FORWARD_FUNCTION CTM_Type,   CTM_Grid,                     $
                    CTM_NamExt, CTM_ResExt, CTM_Make_DataInfo

   ; Keywords
   if ( N_Elements( DiagN         ) ne 1 ) then DiagN         = 'SOILPREC' 
   if ( N_Elements( OutModelName  ) eq 0 ) then OutModelName  = 'GEOS3'
   if ( N_Elements( OutResolution ) eq 0 ) then OutResolution = 4

   ; Default INFILENAME
   if ( N_Elements( InFileName ) ne 1 ) then begin
      InFileName = '~bmy/archive/data/soil_NOx_200203/05x05_gen/lcprc.asc'
   endif

   ; MODELINFO and GRIDINFO structures for the soil precip data
   InType  = CTM_Type( 'generic', Resolution=0.5, HalfPolar=0, Center180=0 )
   InGrid  = CTM_Grid( InType, /No_Vertical )

   ; MODELINFO and GRIDINFO structures for the output CTM grid
   OutType = CTM_Type( OutModelName, Resolution=OutResolution )
   OutGrid = CTM_Grid( OutType, /No_Vertical )

   ; Surface areas of old & new grid in [mm2]
   InArea  = CTM_BoxSize( InGrid,  /GEOS, /Cm2 ) * 100d0
   OutArea = CTM_BoxSize( OutGrid, /GEOS, /Cm2 ) * 100d0

   ; Soil precip arrays
   InPrc   = DblArr( InGrid.IMX,  InGrid.JMX,  12 )
   OutPrc  = DblArr( OutGrid.IMX, OutGrid.JMX, 12 )

   ; Temporary data
   TmpArr  = IntArr( 12 ) 

   ; TAU = time values (hours) for indexing each month
   Tau     = [ 0D,    744D,  1416D, 2160D, 2880D, 3624D, $
               4344D, 5088D, 5832D, 6552D, 7296D, 8016D, 8760D ]

   ; DAY = Days per month 
   Day     = [ 31D,   28D,   31D,   30D,   31D,   30D, $
               31D,   31D,   30D,   31D,   30D,   31D ]

   ;===================================================================
   ; Read 0.5 x 0.5 soil precip data (12 months) from input file
   ;===================================================================
   S = 'Reading 0.5 x 0.5 data from ' + StrTrim( InFileName, 2 ) 
   Message, S, /Info

   Open_File, InFileName, Ilun, /Get_LUN

   while ( not EOF( Ilun ) ) do begin
      
      ; (I,J) are grid box indices in FORTRAN notation!
      ; Subtract 1 to get IDL notation (starting from 0)      
      ReadF, Ilun, Format='(2i4,12i6)', I, J, TmpArr

      ; Soil precip data has units of [mm H2O/month/box]
      ; Convert from [mm H20/month/box] to [mm H2O/day/box]
      InPrc[I-1,J-1,*] = Double( TmpArr ) / Day

      ; Convert from [mm H2O/day/box] to [mm^3/day/box]
      ; We need to regrid a volume of water...
      InPrc[I-1,J-1,*] = InPrc[I-1,J-1,*] * InArea[I-1,J-1]
   endwhile

   ; We have to reverse the rows of OLDPRC, since the soil precip
   ; data starts at the North pole and then goes southward
   InPrc = Reverse( InPrc, 2 )

   ;====================================================================
   ; Regrid the soil precip data for each month onto the CTM grid
   ;====================================================================

   ; Set First time flag
   FirstTime = 1L

   ; Loop over each month
   for T = 0L, 11L do begin
 
      Print
      S = 'Regridding data for month: ' + String( T+1, Format='(i2)' )
      Message, S, /Continue

      ; Reuse saved mapping weights?
      US = 1L - FirstTime

      ; Regrid precip in units of [mm3/day/box]
      OutPrc[*,*,T] = CTM_RegridH( InPrc[*,*,T], InGrid, OutGrid, $
                                   Use_Saved=US, /Double )


      Print, 'Sum Old: ', Total( InPrc[*,*,T] )
      Print, 'Sum New: ', Total( OutPrc[*,*,T] )

      ; Convert regridded precip from [mm3/day/box] back to [mm/day/box]
      OutPrc[*,*,T] = OutPrc[*,*,T] / OutArea[*,*]

      ; Make a DATAINFO structure for each month of regridded data
      Success = CTM_Make_DataInfo( Float( OutPrc[*,*,T] ),    $
                                   ThisDataInfo,              $
                                   ModelInfo=OutType,         $
                                   GridInfo=OutGrid,          $
                                   DiagN=DiagN,               $
                                   Tracer=1L,                 $
                                   Tau0=Tau[T],               $
                                   Tau1=Tau[T+1],             $
                                   Unit='mm/day',             $
                                   Dim=[ OutGrid.IMX,         $
                                         OutGrid.JMX, 0, 0 ], $
                                   First=[1L, 1L, 1L],        $
                                   /No_Global )
      
      ; Error check 
      if ( not Success ) then begin
         Message, 'Error creating DATAINFO structure!', /Continue
         return
      endif

      ; Append structures into an array of structures
      if ( FirstTime )                                        $
         then NewDataInfo = ThisDataInfo                      $
         else NewDataInfo = [ NewDataInfo, ThisDataInfo ]
      
      ; Reset first time flag
      FirstTime = 0L

      ; UnDefine stuff
      UnDefine, ThisDataInfo
   endfor

   ; Close file
   Close,    Ilun
   Free_LUN, Ilun

   ;====================================================================
   ; Save data to disk
   ;====================================================================

   ; Default OUTFILENAME
   if ( N_Elements( OutFileName ) ne 1 ) then begin
      OutFileName = 'soil_precip.geos.' + CTM_ResExt( OutType )
   endif

   ; Write as binary punch format
   CTM_WriteBpch, NewDataInfo, FileName=OutFileName

end
