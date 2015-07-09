; $Id: regridv_restart.pro,v 1.1.1.1 2007/07/17 20:41:34 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        REGRIDV_RESTART
;
; PURPOSE:
;        Vertically regrids data in [v/v] mixing ratio from one
;        model grid to another.  Data is converted to [kg] for 
;        regridding, and then converted back to [v/v].       
;
; CATEGORY:
;        Regridding
;
; CALLING SEQUENCE:
;        REGRIDV_RESTART [, Keywords ]
;
; INPUTS:
;        None
;
; KEYWORD PARAMETERS:
;        INFILENAME -> Name of the input file containing data to
;             be regridded.  If not specified, then REGRIDV_RESTART
;             will prompt the user to select a file name with a
;             dialog box.
;
;        OUTFILENAME -> Name of the directory where the output file
;             will be written.  If OUTFILENAME is not specified, then 
;             REGRIDV_RESTART will prmopt the user to specify a file
;             name via a dialog box.
;
;        OUTMODELNAME -> Name of the model grid onto which the data
;             will be regridded.  If OUTMODELNAME is not specified, 
;             REGRIDV_AEROSOL will use the same model name as the
;             input grid.
;
;        DIAGN -> Diagnostic category of data block that you want
;             to regrid.  Default is "IJ-AVG-$".
;
;        /TROP_ONLY -> If set, will only regrid data within the
;             tropopause (i.e. up to the level specified by
;             MODELINFO.NTROP).  
;
;        /GCAP -> Set this flag to denote that we are regridding from
;             a 4x5 restart file on a GEOS-3 or GEOS-4 grid which has
;             previously been regridded to 45 latitudes.
;
; OUTPUTS:
;        None
;
; SUBROUTINES:
;        Internal Subroutines:
;        =======================================================
;        RVR_GetAirMass (function)      RVR_GetPEdge (function)
;
;        External Subroutines Required:
;        ===========================================================
;        CTM_GRID          (function)   CTM_TYPE          (function)
;        CTM_BOXSIZE       (function)   CTM_REGRID        (function)
;        CTM_NAMEXT        (function)   CTM_RESEXT        (function)
;        CTM_GET_DATABLOCK (function)   CTM_MAKE_DATAINFO (function)
;        REGRID_COLUMN     (function)   GETMODELANDGRIDINFO        
;        CTM_WRITEBPCH                  UNDEFINE   
;
; REQUIREMENTS:
;        None
;
; NOTES:
;        None.
;
; EXAMPLE:
;        REGRIDV_RESTART, INFILENAME='data.geos3.4x5', $
;                         OUTMODELNAME='geos_strat',   $
;                         OUTFILENAME='data.geoss.4x5'
;
;             ; Regrids 4 x 5 GEOS-3 data to the GEOS-STRAT grid.
;              
; MODIFICATION HISTORY:
;        bmy, 21 Jan 2003: VERSION 1.00
;                          - adapted from "regridv_3d_oh.pro
;        bmy, 25 Jun 2003: VERSION 1.01
;                          - added routine RVR_GetPEdge
;                          - now uses ETA coords for GEOS-4 hybrid grid
;        bmy, 31 Oct 2003: VERSION 1.02
;                          - now call PTR_FREE to free pointer memory
;                          - now recognizes GEOS3_30L model name
;                          - now recognizes GEOS4_30L model name
;        bmy, 19 Dec 2003: VERSION 1.03
;                          - now supports hybrid grids
;                          - added /TROP_ONLY switch to regrid only
;                            as high as the tropopause
;                          - now looks for sfc pressure in ~/IDL/regrid/PSURF
;                          - removed routine RVR_GetPEdge
;                          - modified routine RVR_GetAirMass
;        bmy, 17 Feb 2004: VERSION 1.04
;                          - bug fix: replaced D with N as loop index
;        bmy, 01 Feb 2005  - Now suppress excessive printing to screen
;                            with keywords /QUIET and /NOPRINT in
;                            call to CTM_GET_DATABLOCK
;        bmy, 26 May 2005: VERSION 1.05
;                          - added /GCAP keyword for special handling
;                            when creating restart files on 4x5 GCAP grid
;  bmy & phs, 20 Jun 2007: GAMAP VERSION 2.10
;                          - Use FILE_WHICH to locate surf prs files
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
; or phs@io.as.harvard.edu with subject "IDL routine regridv_restart"
;-----------------------------------------------------------------------

function RVR_GetAirMass, VertEdge, Area, PSurf

   ;====================================================================
   ; Internal function RVR_GETAIRMASS returns a column vector of air 
   ; mass given the vertical coordinates, the surface area,
   ; and surface pressure. (bmy, 12/19/03)
   ;====================================================================

   ; Number of vertical levels (1 less than edges)
   LMX     = N_Elements( VertEdge ) - 1L

   ; Define column AIRMASS array
   AirMass = DblArr( LMX )

   ; Constant 100/g 
   g100    = 100d0 / 9.8d0 

   ; Loop over levels
   for L = 0L, LMX-1L do begin
      AirMass[L] = PSurf * Area * ( VertEdge[L] - VertEdge[L+1] ) * g100
   endfor

   ; Return
   return, AirMass
end

;------------------------------------------------------------------------------

pro RegridV_Restart, InFileName=FileName,     OutModelName=OutModelName, $
                     OutFileName=OutFileName, DiagN=DiagN,               $
                     Trop_Only=Trop_Only,     GCAP=GCAP, _EXTRA=e

   ;====================================================================
   ; Initialization
   ;====================================================================

   ; External functions
   FORWARD_FUNCTION CTM_Type,   CTM_Grid, CTM_NamExt,    $
                    CTM_ResExt, Nymd2Tau, Regrid_Column 
    
   ; Keywords
   Trop_Only = Keyword_Set( Trop_Only )
   if ( N_Elements( DiagN         ) ne 1 ) then DiagN         = 'IJ-AVG-$'
   if ( N_Elements( OutModelName  ) ne 1 ) then OutModelName  = 'GEOS3'
   if ( N_Elements( OutResolution ) eq 0 ) then OutResolution = 4
    
   ; For GCAP regridding
   GCAP = Keyword_Set( GCAP )

   ; Time values for each month
   Tau       = [ 0D,    744D,  1416D, 2160D, 2880D, 3624D, $
                 4344D, 5088D, 5832D, 6552D, 7296D, 8016D, 8760D ]
      
   ; Set first time flag
   FirstTime = 1L

   ;================================================================
   ; Process data
   ;================================================================

   ; Read data into the DATAINFO structure of arrays
   CTM_Get_Data, DataInfo, DiagN, FileName=FileName, _EXTRA=e
   
   ; Loop over all data blocks
   for D = 0L, N_Elements( DataInfo ) - 1L do begin

      ; Make sure this data block is 3-D
      if ( DataInfo[D].Dim[2] le 1 ) then Message, 'DATA is not 3-D!'

      ; Echo info to screen
      S = 'Now processing ' + StrTrim( DataInfo[D].TracerName, 2 )
      Message, S, /Info
      
      ;-------------------
      ; INPUT GRID
      ;-------------------

      ; Get MODELINFO and GRIDINFO structures
      GetModelAndGridInfo, DataInfo[D], InType, InGrid
     
      ; Special treatment for GCAP -- start with a "fake"
      ; GEOS restart file w/ 45 latitudes (bmy, 5/26/05)
      if ( GCAP ) then begin
         InType.HalfPolar = 0
         InGrid           = CTM_Grid( InType )
      endif

      ; Grid box surface areas [cm2]
      GEOS   = ( InType.Family eq 'GEOS' OR InType.Family eq 'GENERIC' )
      GISS   = ( InType.Family eq 'GISS' )
      FSU    = ( InType.Family eq 'FSU'  )
      InArea = CTM_BoxSize( InGrid, GEOS=GEOS, GISS=GISS, FSU=FSU, /Cm2 )

      ; Vertical edge coordinates
      if ( InType.Hybrid )                                        $
         then InVertEdge = InGrid.EtaEdge[ 0:DataInfo[D].Dim[2] ] $
         else InVertEdge = InGrid.SigEdge[ 0:DataInfo[D].Dim[2] ] 

      ; Pointer to the INPUT DATA
      Pointer = DataInfo[D].Data 

      ; Error check
      if ( not Ptr_Valid( Pointer ) ) then Message, 'Invalid Pointer!'

      ; Get INPUT data
      InData  = *( Pointer )

      ; Free the heap memory
      Ptr_Free, Pointer

      ; Get units of the INPUT DATA
      InUnit  = StrUpCase( StrTrim( DataInfo[D].Unit, 2 ) )

      ; Convert from [ppbv] or [pptv] to [v/v] if necessary
      if ( StrPos( InUnit, 'PPB' ) ge 0 ) then begin
         InData           = InData * 1d-9
         DataInfo[D].Unit = 'v/v'
      endif else if ( StrPos( InUnit, 'PPT' ) ge 0 ) then begin
         InData           = InData * 1d-12
         DataInfo[D].Unit = 'v/v'            
      endif

      ;-------------------
      ; OUTPUT GRID
      ;-------------------
      
      ; Special handling for GCAP grid
      if ( GCAP ) then begin

         ; Get MODELINFO & GRIDINFO structures for 4x5 GCAP output grid
         OutType = CTM_Type( 'GCAP', Res=4 )
         OutGrid = CTM_Grid( OutType )

      endif else begin
         
         ; Otherwise get MODELINFO and GRIDINFO structures from user input
         OutType = CTM_Type( OutModelName, Res=InType.Resolution )
         OutGrid = CTM_Grid( OutType )

      endelse

      ; Compute surface area on OUTPUT GRID
      GEOS    = ( OutType.Family eq 'GEOS' OR OutType.Family eq 'GENERIC' )
      GISS    = ( OutType.Family eq 'GISS' )
      FSU     = ( OutType.Family eq 'FSU'  )
      OutArea = CTM_BoxSize( OutGrid, GEOS=GEOS, GISS=GISS, FSU=FSU, /Cm2 )

      ; Maximum level to save on OUTPUT grid
      if ( Trop_Only )            $   
         then LMX = OutType.NTROP $
         else LMX = OutGrid.LMX

      ; Vertical edge coordinates on OUTPUT GRID
      if ( OutType.Hybrid )                          $
         then OutVertEdge = OutGrid.EtaEdge[ 0:LMX ] $
         else OutVertEdge = OutGrid.SigEdge[ 0:LMX ] 

      ; OUTPUT DATA array
      OutData = DblArr( OutGrid.IMX, OutGrid.JMX, LMX )
             
      ; Save OUTYPE for future use
      OutTypeSav = OutType

      ;-------------------
      ; SURFACE PRESSURE
      ;-------------------

      ; Surface pressure filename
      PsFileName = 'ps-ptop.' + CTM_NamExt( InType ) + $
                   '.'        + CTM_ResExt( InType )

      ; Look for PSFILENAME in the current directory, and 
      ; failing that, in the directories specified in !PATH
      PsFileName = File_Which( PsFileName, /Include_Current_Dir )
      PsFileName = Expand_Path( PsFileName )

      ; Get current month index
      Result  = Tau2YYMMDD( DataInfo[D].Tau0 )
      MonInd  = Result.Month - 1L
    
      ; Read this month's surface pressure data
      Success = CTM_Get_DataBlock( PSurf, 'PS-PTOP',    $
                                   FileName=PSFileName, $
                                   Tracer=1L,           $
                                   Tau0=Tau[MonInd],    $
                                   /Quiet, /NoPrint )

      ; Error check
      if ( not Success ) then Message, 'Could not read PSURF data!'

      ; Special handling for GCAP: we need to interpolate the output 
      ; pressure data (on GEOS grid) to 45 latitudes (bmy, 5/26/05)
      if ( GCAP ) then begin

         ; Make "original" GEOS grid w/ 46 lats
         TmpType           = InType
         TmpType.HalfPolar = 1
         TmpGrid           = CTM_Grid( TmpType )

         ; Interpolate to 45 lats
         PSurf = InterPolate_2d( Temporary( PSurf ),          $
                                 TmpGrid.XMid, TmpGrid.YMid,  $
                                 OutGrid.XMid, OutGrid.YMid )
      endif

      ;-------------------
      ; USE COLUMN SUMS?
      ;-------------------

      ; Decide whether to suppress column sum or not -- if we are going
      ; from a high grid to a low grid, then column sum doesn't make sense
      if ( ( InType.Name  eq 'GEOS3'       OR  $
             InType.Name  eq 'GEOS3_30L' ) AND $
             OutType.Name eq 'GEOS1'     ) then begin
         No_Check = 1                     

      endif else if ( ( InType.Name  eq 'GEOS3'        OR  $
                        InType.Name  eq 'GEOS3_30L'  ) AND $
                        OutType.Name eq 'GEOS_STRAT' ) then begin
         No_Check = 1                     

      endif else if( ( InType.Name  eq 'GEOS4'         OR  $
                       InType.Name  eq 'GEOS4_30L'   ) AND $
                       OutType.Name eq 'GEOS_STRAT'  ) then begin 
         No_Check = 1  

      endif else if ( ( InType.Name  eq 'GEOS4'        OR  $
                        InType.Name  eq 'GEOS4_30L'  ) AND $
                        OutType.Name eq 'GEOS1'      ) then begin 
         No_Check = 1                                            

      endif else if ( InType.Name  eq 'GEOS_STRAT' AND $
                      OutType.Name eq 'GEOS1'    ) then begin
         No_Check = 1                                            
   
      endif else if ( OutType.Name eq 'GCAP' ) then begin
         No_Check = 1

      endif else begin
         No_Check = 0
                  
      endelse

      ; Turn off check if we are only regridding the troposphere
      if ( Trop_Only ) then No_Check = 0

      ;-------------------
      ; REGRID DATA
      ;-------------------

      ; Loop over surface grid boxes
      for J = 0L, InGrid.JMX - 1L do begin
      for I = 0L, InGrid.IMX - 1L do begin

         ; Pressure edges on INPUT and OUTPUT grids
         InPEdge  = ( InVertEdge  * PSurf[I,J] ) + InType.PTOP 
         OutPEdge = ( OutVertEdge * PSurf[I,J] ) + OutType.PTOP

         ; Airmass on input grid
         AirMass  = RVR_GetAirMass( InVertEdge, InArea[I,J], Psurf[I,J] )

         ; Convert data from [v/v] to mass 
         InCol    = Reform( InData[I,J,*] * Airmass[*] )
 
         ; Regrid vertically -- preserve column mass
         OutCol   = Regrid_Column( InCol, InPEdge, OutPEdge, $
                                   No_Check=No_Check, _EXTRA=e )
         
         ; Airmass on output grid
         AirMass  = RVR_GetAirMass( OutVertEdge, OutArea[I,J], Psurf[I,J] )

         ; Convert new OH data from [molec] to [molec/cm3]
         OutData[I,J,*] = Reform( OutCol / AirMass[*] )
           
         ; Undefine variables for safety's sake
         UnDefine, InCol
         UnDefine, OutCol
         UnDefine, InPEdge
         UnDefine, OutPEdge
         UnDefine, AirMass

      endfor
      endfor

      ;-------------------
      ; SAVE DATA BLOCKS
      ;-------------------

      ; Make a DATAINFO structure for each month of OH data
      Success = CTM_Make_DataInfo( Float( OutData ),           $
                                   ThisDataInfo,               $
                                   ThisFileInfo,               $
                                   ModelInfo=OutType,          $
                                   GridInfo=OutGrid,           $
                                   DiagN=DataInfo[D].Category, $
                                   Tracer=DataInfo[D].Tracer,  $
                                   Tau0=DataInfo[D].Tau0,      $
                                   Tau1=DataInfo[D].Tau1,      $
                                   Unit=DataInfo[D].Unit,      $
                                   Dim=[ OutGrid.IMX,          $
                                         OutGrid.JMX,          $
                                         LMX,                  $
                                         DataInfo[D].Dim[3] ], $ 
                                   First=DataInfo[D].First,    $
                                   /No_Global ) 
 
      ; Save to NEWDATAINFO array of structures
      if ( FirstTime )                                         $
         then NewDataInfo = ThisDataInfo                       $
         else NewDataInfo = [ NewDataInfo, ThisDataInfo ]
      
      ; Reset first time flag
      FirstTime = 0L

      ; Undefine data
      UnDefine, InType
      UnDefine, OutType
      UnDefine, InGrid
      UnDefine, OutGrid
      UnDefine, InArea
      UnDefine, OutArea
      UnDefine, InData
      UnDefine, OutData
      UnDefine, PSurf
      UnDefine, TmpGrid
   endfor

   ;=================================================================   
   ; Write data to disk
   ;=================================================================

   ; Default OUTFILENAME
   if ( N_Elements( OutFileName ) ne 1 ) then begin
      OutFileName = 'gctm.trc.' + CTM_NamExt( OutTypeSav ) + $
                    '.'         + CTM_ResExt( OutTypeSav )
   endif

   ; Write to binary punch format
   CTM_WriteBpch, NewDataInfo, ThisFileInfo, FileName=OutFileName

end                               
 
    
 
