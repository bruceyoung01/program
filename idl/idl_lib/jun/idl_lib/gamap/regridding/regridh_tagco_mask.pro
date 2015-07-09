; $Id: regridh_tagco_mask.pro,v 1.2 2008/04/02 15:19:04 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        REGRIDH_TAGCO_MASK
;
; PURPOSE:
;        Regrids country mask (used to separate Tagged CO emissions)
;        from the GEOS-4 1 x 1.25 grid to another CTM grid.
;
; CATEGORY:
;        Regridding
;
; CALLING SEQUENCE:
;        REGRIDH_TAGCO_MASK [, Keywords ]
;
; INPUTS:
;
; KEYWORD PARAMETERS:
;        INFILENAME -> Name of the input file to be regridded.  This
;             file is stored as binary F77 unformatted, with short
;             integers.  The default filename is:
;          '~/bmy/archive/data/tagged_CO_200106/1x125_geos/tagco_mask.f77_unf'
;
;        OUTFILENAME -> Name of the file which will contain the
;             regridded data.  Default is "tagco_mask.geos.{RESOLUTION}".
;
;        OUTMODELNAME -> Name of the CTM grid onto which the data will 
;             be regridded.  Default is "GEOS_4".  NOTE: Since the 
;             country mask is 2-D data, the vertical dimension of the
;             CTM grid will be ignored.
;
;        OUTRESOLUTION -> Resolution of the CTM grid onto which the
;             data will be regridded.  Default is 4.
;
; OUTPUTS:
;        None
;
; SUBROUTINES:
;        External Subroutines Required:
;        ========================================================
;        CTM_TYPE          (function)   CTM_GRID       (function)
;        CTM_MAKE_DATAINFO (function)   INTERPOLATE_2D (function)
;        CTM_WRITEBPCH                  OPEN_FILE
;
; REQUIREMENTS:
;        Requires routines from both the GAMAP and TOOLS packages.
;
; NOTES:
;        None
;
; EXAMPLE:
;        REGRIDH_TAGCO_MASK, INFILENAME='tagco_mask.f77_unf',$
;                            OUTMODELNAME='GEOS_4",          $
;                            OUTRESOLUTION=2,                $
;                            OUTFILENAME='tagco_mask.geos.2x25' 
;
;             ; Regrids country mask for Tagged CO
;
; MODIFICATION HISTORY:
;        bmy, 22 Jun 2004: VERSION 1.00
;        bmy, 02 Apr 2008: GAMAP VERSION 2.12
;                          - Read input data as big-endian
;
;-
; Copyright (C) 2004-2008, Bob Yantosca, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author.
; Bugs and comments should be directed to bmy@io.harvard.edu
; with subject "IDL routine regridh_tagco_mask"
;-----------------------------------------------------------------------


pro RegridH_TagCO_Mask, InFileName=InFileName,       $
                        OutModelName=OutModelName,   $
                        OutResolution=OutResolution, $
                        OutFileName=OutFileName,     $
                        _EXTRA=e
 
   ;====================================================================
   ; Initialization
   ;====================================================================
 
   ; External functions
   FORWARD_FUNCTION CTM_Make_DataInfo, CTM_Grid,     $
                    CTM_ResExt,        CTM_Type,     $
                    InterPolate_2D,    Little_Endian
 
   ; Default input file
   if ( N_Elements( InFileName ) eq 0 )                         $
      then InFileName = '~bmy/archive/data/tagged_CO_200106/' + $
                        '1x125_geos/tagco_mask.f77_unf'
 
   ; Keywords
   if ( N_Elements( OutModelName  ) eq 0 ) then OutModelName  = 'GEOS_4'
   if ( N_Elements( OutResolution ) eq 0 ) then OutResolution = 4
 
   ; Input grid info
   InType  = CTM_Type( 'GEOS_4', Res=[1.25, 1.0] )
   InGrid  = CTM_Grid( InType, /No_Vertical )
 
   ; Output grid info
   OutType = CTM_Type( OutModelName, Res=OutResolution )
   OutGrid = CTM_Grid( OutType, /No_Vertical )
 
   ;====================================================================
   ; Read input data
   ;====================================================================
 
   ; Create input data array
   InData = IntArr( InGrid.IMX, InGrid.JMX )
 
   ; Open input file
   Open_File, InFileName, Ilun, /Get_Lun, /F77, Swap_Endian=Little_Endian()
 
   ; Read data as F77 binary unformatted
   ReadU, Ilun, InData
 
   ; Close file
   Close,    Ilun
   Free_LUN, Ilun
 
   ; NOTE: The data begins at 0 degrees longitude, so we have to
   ;       shift it by 180 degrees (or 1/2 of the boxes)
   InData = Shift( InData, InGrid.IMX/2, 0 )
 
   ;====================================================================
   ; Regrid data and create a BPCH file
   ;====================================================================
 
   ; Interpolate from one grid to the next
   OutData = InterPolate_2D( InData, $
                             InGrid.XMid,  InGrid.YMid, $
                             OutGrid.XMid, OutGrid.YMid )
 
   ; Make sure to round up at the borders
   OutData = Fix( Temporary( OutData ) + 0.5 )
 
   ; Make a DATAINFO structure 
   Success = CTM_Make_DataInfo( Float( OutData ),          $
                                ThisDataInfo,              $
                                ThisFileInfo,              $
                                ModelInfo=OutType,         $
                                GridInfo=OutGrid,          $
                                DiagN='LANDMAP',           $
                                Tracer=3,                  $
                                Tau0=0D,                   $
                                Tau1=0D,                   $
                                Unit='unitless',           $
                                Dim=[ OutGrid.IMX,         $
                                      OutGrid.JMX, 0, 0 ], $
                                First=[1L, 1L, 1L],        $
                                /No_Global )
 
   ; Error check
   if ( not Success ) then Message, 'Could not make DATAINFO structure!'
 
   ; Write to bpch file
   if ( N_Elements( OutFileName ) eq 0 ) $
      then OutFileName = 'tagco_mask.geos.' + CTM_ResExt( OutType )
 
   ; Create bpch file
   CTM_WriteBpch, ThisDataInfo, ThisFileInfo, FileName=OutFileName
 
end
