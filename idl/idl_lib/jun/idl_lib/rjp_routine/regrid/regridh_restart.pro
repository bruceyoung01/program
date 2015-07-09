; $Id: regridh_restart.pro,v 1.5 2006/04/25 16:26:46 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        REGRIDH_RESTART
;
; PURPOSE:
;        Horizontally regrids data in [v/v] mixing ratio from one
;        model grid to another.  Data is converted to [kg] for 
;        regridding, and then converted back to [v/v].       
;
; CATEGORY:
;        Regridding
;
; CALLING SEQUENCE:
;        REGRIDH_RESTART [, Keywords ]
;
; INPUTS:
;        None
;
; KEYWORD PARAMETERS:
;        INFILENAME -> Name of the file containing data to be regridded.
;             If INFILENAME is not specified, then REGRIDH_RESTART
;             will prompt the user to select a file via a dialog box.
;
;        OUTFILENAME -> Name of the file which will contain the regridded 
;             data.  If OUTFILENAME is not specified, then REGRIDH_RESTART
;             will prompt the user to select a file via a dialog box.
;
;        OUTMODELNAME -> Name of the model grid onto which the data
;             will be regridded.  If OUTMODELNAME is not specified, 
;             then REGRIDH_RESTART will use the same model name as the
;             input grid.
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
;        /GCAP -> Set this switch to regrid a 4x5 GEOS-3 or GEOS-4 
;            restart file to a "fake" GEOS grid containing 45 latitudes
;            but the same # of levels.  You can then regrid the file
;            vertically using regridv_restart.pro.
;
; OUTPUTS:
;        None
;
; SUBROUTINES:
;        External Subroutines Required:
;        =================================================
;        CTM_GRID       (function)   CTM_TYPE    (function)
;        CTM_BOXSIZE    (function)   CTM_REGRIDH (function)
;        CTM_NAMEXT     (function)   CTM_RESEXT  (function)
;        CTM_WRITEBPCH               GETMODELANDGRIDINFO 
;        INTERPOLATE_2D (function)   UNDEFINE 
;
; REQUIREMENTS:
;        References routines from the GAMAP and TOOLS packages.
;
; NOTES:
;        None
;
; EXAMPLE:
;        REGRIDH_RESTART, INFILENAME='geos3.2x25.bpch', $
;                         OUTFILENAME='geos3.4x5.bpch', $
;                         OUTRESOLUTION=4
;           
;             ; Regrids GEOS-3 data from 2 x 2.5 to 4 x 5 resolution.
;
; MODIFICATION HISTORY:
;        bmy, 22 Jan 2003: VERSION 1.01
;        bmy, 15 Apr 2003: VERSION 1.02
;                          - now reads bpch file w/o using CTM_GET_DATA;
;                            this keeps us from running out of memory
;        bmy, 22 Dec 2003: VERSION 1.03
;                          - rewritten for GAMAP v2-01
;                          - rewritten so that we can now regrid files
;                            containing less than GRIDINFO.LMX levels
;                          - reorganized a few things for clarity
;        bmy, 13 Apr 2004: VERSION 1.04
;                          - now use surface pressure files on both
;                            the input and output grids
;                          - now use separate arrays for airmass
;                            on the two grids
;                          - now adjusts polar latitudes so as to avoid
;                            artificial buildup of concentration when
;                            regridding from coarse --> fine grids
;        bmy, 31 Jan 2005: VERSION 1.05
;                          - Minor bug fix: INAREA and OUTAREA should
;                            have units of [m2] for the airmass computation
;                          - Now use /QUIET and /NOPRINT keywords in
;                            call to CTM_GET_DATABLOCK
;        bmy, 26 May 2005: VERSION 1.06
;                          - added /GCAP keyword for special handling
;                            when creating restart files on 4x5 GCAP grid
;                          - now references INTERPOLATE_2D function
;
;-
; Copyright (C) 2003-2005, Bob Yantosca, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author.
; Bugs and comments should be directed to bmy@io.harvard.edu
; with subject "IDL routine regridh_restart"
;-----------------------------------------------------------------------

function RHR_GetAirMass, GridInfo, VEdge, Area, P

   ;====================================================================
   ; Internal function RHR_GETAIRMASS returns a 3-D array of air mass
   ; given the vertical edges, surface area, and surface pressure. 
   ; (bmy, 12/19/03)
   ;====================================================================

   ; Number of vertical levels (1 less than edges)
   LMX     = N_Elements( VEdge ) - 1L

   ; Define airmass array
   AirMass = DblArr( GridInfo.IMX, GridInfo.JMX, LMX )

   ; Constant 100/g 
   g100    = 100d0 / 9.8d0 

   ; Loop over levels
   for L = 0L, LMX-1L do begin
      AirMass[*,*,L] = P[*,*] * Area[*,*] * ( VEdge[L] - VEdge[L+1] ) * g100
   endfor

   ; Return
   return, AirMass
end

;-----------------------------------------------------------------------------

pro RHR_Fix_Poles, InGrid, InData, OutGrid, OutData

   ;====================================================================
   ; Routine RHR_FIX_POLES adjusts OUTDATA so as to prevent a buildup
   ; of mixing ratio concentration at the poles -- this is an artifact
   ; of the coarse grid to fine grid regridding (bmy, 4/13/04)
   ;====================================================================

   ; Echo Info
   S = 'Fixing polar data for coarse to fine regridding!'
   Message, S, /Info

   ; Convenience variable
   Nx = Float( InGrid.IMX )

   ; Get size of output array
   SData = Size( OutData, /Dim )
   NData = N_Elements( SData )

   ; Test for dimension of data array
   case ( NData ) of

      ; Just take the value at the pole from 
      ; the data array on the input grid
      2: begin

         ; Polar averages of INDATA at NP and SP 
         AvgNP = Total( InData[*,InGrid.JMX-1L] ) / Nx
         AvgSP = Total( InData[*,0            ] ) / Nx

         ; Copy to first 2 polar latitudes -- NP and SP
         OutData[*,OutGrid.JMX-1L] = AvgNP
         OutData[*,OutGrid.JMX-2L] = AvgNP
         OutData[*,0             ] = AvgSP
         OutData[*,1             ] = AvgSP
      end

      3: begin

         ; Loop over levels
         for L=0L, SData[2]-1L do begin

            ; Polar averages of INDATA at NP and SP
            AvgNP = Total( InData[*,InGrid.JMX-1L,L] ) / Nx
            AvgSP = Total( InData[*,0,            L] ) / Nx
         
            ; Copy to first-2 polar latitudes -- NP and SP
            OutData[*,OutGrid.JMX-1L,L] = AvgNP
            OutData[*,OutGrid.JMX-2L,L] = AvgNP
            OutData[*,0,             L] = AvgSP
            OutData[*,1,             L] = AvgSP
         endfor
      end
   endcase
         
end

;-----------------------------------------------------------------------------

pro RegridH_Restart, InFileName=InFileName,       OutModelName=OutModelName, $
                     OutResolution=OutResolution, OutFileName=OutFileName,   $
                     DiagN=DiagN,                 GCAP=GCAP,                 $
                     _EXTRA=e
 
   ;====================================================================
   ; Initialization
   ;====================================================================

   ; External functions
   FORWARD_FUNCTION CTM_Type,       CTM_Grid,        CTM_BoxSize, $
                    CTM_RegridH,    CTM_NamExt,      CTM_ResExt,  $
                    InterPolate_2D, CTM_Make_DataInfo 

   ; Keywords
   if ( N_Elements( DiagN         ) ne 1 ) then DiagN         = 'IJ-AVG-$'
   if ( N_Elements( OutResolution ) eq 0 ) then OutResolution = 4

   ; For GCAP grid
   GCAP = Keyword_Set( GCAP )

   ; Time values for each month
   Tau        = [ 0D,    744D,  1416D, 2160D, 2880D, 3624D, $
                  4344D, 5088D, 5832D, 6552D, 7296D, 8016D, 8760D ]
      
   ; Set first time flag
   FirstTime  = 1L

   ;================================================================
   ; Process the data
   ;================================================================

   ; Read data into DATAINFO array of structures
   CTM_Get_Data, DataInfo, DiagN, FileName=InFileName, _EXTRA=e
   
   ; Loop over all data blocks
   for D = 0L, N_Elements( DataInfo ) - 1L do begin

      ; Echo info to screen
      S = 'Now processing ' + StrTrim( DataInfo[D].TracerName, 2 )
      Message, S, /Info

      ;-------------------
      ; INPUT GRID
      ;-------------------

      ; Get MODELINFO and GRIDINFO structures 
      GetModelAndGridInfo, DataInfo[D], InType, InGrid
     
      ; Compute surface area on INPUT GRID
      GEOS   = ( InType.Family eq 'GEOS' OR InType.Family eq 'GENERIC' )
      GISS   = ( InType.Family eq 'GISS' )
      FSU    = ( InType.Family eq 'FSU'  )
      InArea = CTM_BoxSize( InGrid, GEOS=GEOS, GISS=GISS, FSU=FSU, /M2 )

      ; Vertical edge coordinates
      if ( InType.Hybrid )                                        $
         then InVertEdge = InGrid.EtaEdge[ 0:DataInfo[D].Dim[2] ] $
         else InVertEdge = InGrid.SigEdge[ 0:DataInfo[D].Dim[2] ] 

      ; Pointer to the data
      Pointer = DataInfo[D].Data

      ; Error check Pointer
      if ( not Ptr_Valid( Pointer ) ) then Message, 'Invalid Pointer!'

      ; Dereference the pointer to the data
      InData  = *( Pointer )

      ; Free the associated pointer heap memory
      Ptr_Free, Pointer

      ; Save original unit string
      InUnit  = DataInfo[D].Unit

      ; Convert from [ppbv] or [pptv] to [v/v] if necessary
      if ( StrPos( StrUpCase( InUnit ), 'PPB' ) ge 0 ) then begin
         InData = InData * 1d-9
         InUnit = 'v/v'
      endif else if ( StrPos( StrUpCase( InUnit ), 'PPT' ) ge 0 ) then begin
         InData = InData * 1d-12
         InUnit = 'v/v'            
      endif

      ;-------------------
      ; OUTPUT GRID
      ;-------------------      

      ; If OUTMODELNAME is not passed, then use the same grid as for INTYPE
      if ( N_Elements( OutModelName ) ne 1 ) then OutModelName = InType.Name

      ; Special handling for GCAP regridding
      if ( GCAP ) then begin

         ; For GCAP: Make a "fake" GEOS-grid w/ 45 latitudes but
         ; with the same # of vertical levels. (bmy, 5/26/05)
         OutType           = InType
         OutType.HalfPolar = 0
         OutGrid           = CTM_Grid( OutType )

      endif else begin

         ; Otherwise get MODELINFO and GRIDINFO structures from user input
         OutType = CTM_Type( OutModelName, Res=OutResolution, _EXTRA=e )
         OutGrid = CTM_Grid( OutType )

      endelse

      ; Compute surface area on OUTPUT GRID
      GEOS    = ( OutType.Family eq 'GEOS' OR OutType.Family eq 'GENERIC' )
      GISS    = ( OutType.Family eq 'GISS' )
      FSU     = ( OutType.Family eq 'FSU'  )
      OutArea = CTM_BoxSize( OutGrid, GEOS=GEOS, GISS=GISS, FSU=FSU, /M2 )

      ; Vertical edge coordinates on OUTPUT GRID
      if ( OutType.Hybrid )                                         $
         then OutVertEdge = OutGrid.EtaEdge[ 0:DataInfo[D].Dim[2] ] $
         else OutVertEdge = OutGrid.SigEdge[ 0:DataInfo[D].Dim[2] ] 

      ; Save OUTTYPE for future use
      OutTypeSav = OutType

      ;-------------------
      ; SURFACE PRESSURE
      ;-------------------      

      ; Get current month index
      Result   = Tau2YYMMDD( DataInfo[D].Tau0 )
      MonInd   = Result.Month - 1L
      UnDefine, Result

      ; File name for surface pressure on INPUT GRID
      InPSFile = '~/IDL/regrid/PSURF/ps-ptop.' + CTM_NamExt( InType ) + $
                   '.'                         + CTM_ResExt( InType ) 
      
      ; Read surface pressure on INPUT GRID
      Success = CTM_Get_DataBlock( InPSurf, 'PS-PTOP',  $
                                   FileName=InPSFile,   $
                                   Tracer=1L,           $
                                   Tau0=Tau[MonInd],    $
                                   /Quiet, /NoPrint )

      ; Error check
      if ( not Success ) then Message, 'Could not read INPSURF!'

      ; File name for surface pressure on INPUT GRID
      OutPSFile = '~/IDL/regrid/PSURF/ps-ptop.' + CTM_NamExt( OutType ) + $
                   '.'                          + CTM_ResExt( OutType ) 
      
      ; Read surface pressure on INPUT GRID
      Success = CTM_Get_DataBlock( OutPSurf, 'PS-PTOP',  $
                                   FileName=OutPSFile,   $
                                   Tracer=1L,            $
                                   Tau0=Tau[MonInd],     $
                                   /Quiet, /NoPrint )

      ; Error check
      if ( not Success ) then Message, 'Could not read OUTPSURF!'
      
      ; Special handling for GCAP: we need to interpolate
      ; the output pressure data to 45 latitudes (bmy, 5/26/05)
      if ( GCAP ) then begin
         OutPSurf = InterPolate_2d( Temporary( OutPSurf ),      $
                                    InGrid.XMid,  InGrid.YMid,  $
                                    OutGrid.XMid, OutGrid.YMid )
      endif
      
      ;-------------------
      ; REGRID DATA
      ;------------------- 

      ; Convert data on INPUT GRID from [v/v] to [kg]
      InAirMass = RHR_GetAirMass( InGrid, InVertEdge, InArea, InPSurf )
      InData    = Temporary( InData ) * InAirMass

      ; Reuse saved mapping weights?
      US      = 1L - FirstTime

      ; Regrid data from INPUT GRID to OUTPUT GRID
      OutData = CTM_RegridH( InData, InGrid, OutGrid, $
                             /Double, Use_Saved=US )

      ; Convert data on OUTPUT GRID from [kg] to [v/v]
      OutAirMass = RHR_GetAirMass( OutGrid, OutVertEdge, OutArea, OutPSurf )
      OutData    = ( Temporary( OutData ) / OutAirMass )

      ;### Kludge -- prevent buildup of stuff at the poles caused by 
      ;### the fine --> coarse regridding algorithm (bmy, 4/9/04)
      if ( InGrid.IMX lt OutGrid.IMX ) then begin
         InData = Temporary( InData ) / InAirMass
         RHR_Fix_Poles, InGrid, InData, OutGrid, OutData
      endif
      
      ;-------------------
      ; SAVE DATA BLOCKS
      ;------------------- 

      ; Get size of output data
      S = Size( OutData, /Dim )
      
      ; Make DIM array for CTM_MAKE_DATAINFO
      case( N_Elements( S ) ) of
         2    : Dim = [ S[0], S[1], 0,    0 ]
         3    : Dim = [ S[0], S[1], S[2], 0 ]
         else : Message, 'Invalid dimensions for OUTDATA!'
      endcase

      ; Make DATAINFO structure 
      Success = CTM_Make_DataInfo( Float( OutData ),           $
                                   ThisDataInfo,               $
                                   ThisFileInfo,               $
                                   ModelInfo=OutType,          $
                                   GridInfo=OutGrid,           $
                                   DiagN=DataInfo[D].Category, $ 
                                   Tracer=DataInfo[D].Tracer,  $
                                   Tau0=DataInfo[D].Tau0,      $
                                   Tau1=DataInfo[D].Tau1,      $
                                   Unit=InUnit,                $
                                   Dim=Dim,                    $
                                   First=DataInfo[D].First,    $
                                   /No_Global )
 
      ; Save into NEWDATAINFO array of structures
      if ( FirstTime )                                         $      
         then NewDataInfo = ThisDataInfo                       $
         else NewDataInfo = [ NewDataInfo, ThisDataInfo ]

      ; Reset the first time flag
      FirstTime = 0L
      
      ; Undefine variables for safety's sake
      UnDefine, InType
      UnDefine, InGrid
      UnDefine, InData
      UnDefine, OutType
      UnDefine, OutGrid
      UnDefine, OutData
      UnDefine, ThisDataInfo
      UnDefine, InPSurf
      UnDefine, OutPSurf
      UnDefine, InAirMass
      UnDefine, OutAirMass
   endfor

   ;====================================================================
   ; Save data to disk
   ;====================================================================

   ; Write as binary punch output
   CTM_WriteBpch, NewDataInfo, ThisFileInfo, FileName=OutFileName

end



