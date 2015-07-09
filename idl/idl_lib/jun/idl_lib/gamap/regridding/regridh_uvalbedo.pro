; $Id: regridh_uvalbedo.pro,v 1.1.1.1 2007/07/17 20:41:35 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        REGRIDH_UVALBEDO
;
; PURPOSE:
;        Horiziontally regrids UV albedo data from its native
;        resolution (1 x 1 or 1 x 1.25) to a CTM grid.
;
; CATEGORY:
;        Regridding
;
; CALLING SEQUENCE:
;        REGRIDH_UVALBEDO [, Keywords ]
;
; INPUTS:
;        None
;
; KEYWORD PARAMETERS:
;        OUTMODELNAME -> A string containing the name of the model 
;             grid onto which the data will be regridded.
;
;        OUTRESOLUTION -> Specifies the resolution of the model grid
;             onto which the data will be regridded.  RESOLUTION
;             can be either a 2 element vector with [ DI, DJ ] or
;             a scalar (DJxDI: 8=8x10, 4=4x5, 2=2x2.5, 1=1x1, 
;             0.5=0.5x0.5).  Default for all models is 4x5.
;
;        OUTFILENAME -> Name of the binary punch file containing
;             regridded UV Albedo data.  The default value for
;             OUTFILENAME is uvalbedo.geos.{RESOLUTION} 
;
;        FILL -> Value to fill "missing data" with.  Default is
;             0.85 (typcial albedo over ice).
;
; OUTPUTS:
;        None
;
; SUBROUTINES:
;        Internal Subroutines Required:
;        =====================================================
;        READ_UVALBEDO (function)
;
;        External Subroutines Required:
;        =====================================================
;        MFINDFILE   (function)   CTM_TYPE          (function)
;        CTM_NAMEXT  (function)   CTM_RESEXT        (function)
;        CTM_REGRIDH (function)   CTM_MAKE_DATAINFO (function)
;        CTM_WRITEBPCH            OPEN_FILE
;        UNDEFINE
;
; REQUIREMENTS:
;        None
;
; NOTES:
;        (1) Input file names are hardwired -- change as necessary 
;
; EXAMPLE:
;        REGRIDH_UVALBEDO, OUTFILENAME='uvalbedo.geos3.2x25', $
;                          OUTMODELNAME='GEOS3',              $
;                          OUTRESOLUTION=2     
;
;             ; Regrids UV Albedos from the native grid to the
;             ; 2 x 2.5 GEOS-3 horizontal grid.  (This is
;             ; actually the same horizontal grid as for 2 x 2.5
;             ; GEOS-1, GEOS-STRAT, and GEOS-4.)
;
; MODIFICATION HISTORY:
;        bmy, 06 Jul 2000: VERSION 1.00
;        bmy, 24 Jul 2000: VERSION 1.01
;                          - added OUTDIR keyword
;        bmy, 16 Nov 2001: VERSION 1.02
;                          - adapted for Koelemeijer et al 2001 data
;        bmy, 15 Jan 2003: VERISON 1.03
;                          - renamed to "regridh_uvalbedo.pro"
;                          - "read_uvalbedo.pro" is now an internal function
;                          - now uses CTM_REGRIDH to do the regridding
;        bmy, 23 Dec 2003: VERSION 1.04
;                          - updated for GAMAP v2-01
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
; or phs@io.as.harvard.edu with subject "IDL routine regridh_uvalbedo"
;-----------------------------------------------------------------------

function Read_UVAlbedo, InFileName, Fill, InType, InGrid

   ;====================================================================
   ; Internal function READ_UVALBEDO reads UV Albedo data from disk
   ; and returns the modelinfo and gridinfo structures which define
   ; the UV albedo native grid.  Also, missing data will be filled
   ; with a fill value specified by the user.
   ;====================================================================

   ; Echo information
   S = 'Reading ' + StrTrim( InFileName )
   Message, S, /Info

   ;--------------------------------------------------------------------
   ; For Hermann/Celarier 1997 (380 nm), native grid is 1 x 1.25
   ; This is what we should use for GEOS-CHEM!
   FormatStr   = '( 11(25i3/), 13i3 )'
   HeaderLines = 4
   InType      = CTM_Type( 'generic',   Resolution=[1.25, 1.0], $
                            HalfPolar=0, Center180=0 )
   Divisor     = 1000e0
   ;-------------------------------------------------------------------- 
   ; For Koelemeijer et al 2001 (440 nm), native grid is 1 x 1 
   ; This was needed by rvm for GOME retrievals!!!
   ;FormatStr    = '( 14(25i3/), 10i3 )'
   ;HeaderLines  = 3
   ;InType       = CTM_Type( 'generic',   Resolution=[1.0, 1.0], $
   ;                         HalfPolar=0, Center180=0 )
   ;Divisor       = 1000e0
   ;--------------------------------------------------------------------
   InGrid       = CTM_Grid( InType, /No_Vertical )  

   ; Define arrays for inpuyt grid
   TmpData      = FltArr( InGrid.IMX ) 
   InData       = FltArr( InGrid.IMX, InGrid.JMX )

   ; Open the input file
   Open_File, InFileName, Ilun, /Get_LUN
 
   ; Skip file header
   Line = ''
   for N = 1, HeaderLines do begin
      ReadF, Ilun, Line
   endfor
 
   ; Read in albedoes for each latitude
   J = 0
   while ( not EOF( Ilun ) ) do begin
      ReadF, Ilun, Format=FormatStr, TmpData
 
      ; Divide UV albedo data by the divisor in
      ; order to convert to unitless fraction
      InData[*, J] = TmpData / Divisor
 
      ; Increment counter of latitudes
      J = J + 1
   endwhile
 
   ; Close file
   Close,    Ilun
   Free_LUN, Ilun
 
   ; Fill missing data points (99.9) with data specified by the user.
   if ( N_Elements( Fill ) gt 0 ) then begin
      Ind = Where( InData gt 0.98 )
      if ( Ind[0] ge 0 ) then InData[Ind] = Fill
   endif
 
   ; Return to main program
   return, InData

end

;------------------------------------------------------------------------------

pro RegridH_UVAlbedo, OutModelName=OutModelName, OutResolution=OutResolution,$
                      OutFileName=OutFileName,   Fill=Fill,                  $
                      _EXTRA=e
   
   ;====================================================================
   ; Initialization
   ;====================================================================

   ; External functions
   FORWARD_FUNCTION MFindFile,  CTM_Type,    CTM_NamExt, $
                    CTM_ResExt, CTM_RegridH, CTM_Make_DataInfo

   ; Keywords
   if ( N_Elements( OutModelName  ) eq 0 ) then OutModelName  = 'GEOS3' 
   if ( N_Elements( OutResolution ) eq 0 ) then OutResolution = 2
   if ( N_Elements( Fill          ) eq 0 ) then Fill          = 0.85

   ; Output grid parameters
   OutType = CTM_Type( OutModelName, Resolution=OutResolution )
   OutGrid = CTM_Grid( OutType,      /No_Vertical )

   ; DEFAULT input file names (change as necessary)
   ;--------------------------------------------------------------------
   ; Herman and Celarier 1997 (380nm)
   InFileList = MFindFile( '~bmy/archive/data/uvalbedo_200111/raw/rs*.dat' )
   ;--------------------------------------------------------------------
   ; Koelemeijer et al 2001 (440nm)
   ;InFileList = MFindFile( '~bmy/archive/data/uvalbedo_gome/*.dat' )
   ;--------------------------------------------------------------------

   ; Error check INFILELIST
   if ( InfileList[0] eq '' ) then begin
      Message, 'Could not find any input files!', /Continue
      return
   endif

   ; Top title for UV albedo data
   TopTitle = 'UV Albedos -- created by rvm, bmy, 1/03'
 
   ; Values for indexing each month
   Tau = [    0D,  744D, 1416D, 2160D, 2880D, 3624D, $
           4344D, 5088D, 5832D, 6552D, 7296D, 8016D, 8760D ]
 
   ; Set first time flag
   FirstTime = 1L

   ;====================================================================
   ; Regrid UVALBEDO data
   ;====================================================================
   for T = 0L, N_Elements( InFileList ) - 1L do begin
 
      ; Read the UV Albedo data and return UVTYPE and UVGRID
      InData  = Read_UVAlbedo( InFileList[T], Fill, InType, InGrid )
    
      ; Reuse saved mapping weights?
      US = 1L - FirstTime

      ; Regrid UV albedo data
      OutData = CTM_RegridH( InData,         InGrid,  OutGrid, $
                             /Per_Unit_Area, /Double, Use_Saved=US )

      ; Fill missing data points
      if ( N_Elements( Fill ) gt 0 ) then begin
         Ind = Where( OutData le 0.001 )
         if ( Ind[0] ge 0 ) then OutData[Ind] = Fill
      endif

      ; Make a new DATAINFO structure
      Success = CTM_Make_DataInfo( Float( OutData ),            $
                                   ThisDataInfo,                $
                                   ThisFileInfo,                $
                                   ModelInfo=OutType,           $
                                   GridInfo=OutGrid,            $
                                   DiagN='UVALBEDO',            $
                                   Tracer=1L,                   $
                                   Tau0=Tau[T],                 $ 
                                   Tau1=Tau[T+1],               $ 
                                   Unit='unitless',             $ 
                                   Dim=[ OutGrid.IMX,           $
                                         OutGrid.JMX, 0L, 0L ], $
                                   First=[1L, 1L, 1L],          $
                                   TopTitle=TopTitle,           $
                                   /No_Global )

      ; Error check
      if ( not Success ) then Message, 'Could not make DATAINFO!'

      ; Append into NEWDATAINFO array of structures
      if ( FirstTime )                                          $
         then NewDataInfo = ThisDataInfo                        $
         else NewDataInfo = [ NewDataInfo, ThisDataInfo ]
      
      ; Reset FLAG to a nonzero value
      FirstTime = 0L

      ; Undefine stuff
      UnDefine, InData
      UnDefine, OutData
      UnDefine, ThisDataInfo
   endfor
   
   ;====================================================================
   ; Save data to disk
   ;====================================================================

   ; Default OUTFILENAME
   if ( N_Elements( OutFileName ) ne 1 ) then begin
      OutFileName = 'uvalbedo.' + CTM_NamExt( OutType ) + $
                    '.'         + CTM_ResExt( OutType )
   endif

   ; Save as binary punch format
   CTM_WriteBpch, NewDataInfo, ThisFileInfo, FileName=OutFileName

end
