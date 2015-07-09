; $Id: regridv_aerosol.pro,v 1.1.1.1 2007/07/17 20:41:32 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        REGRIDV_AEROSOL
;
; PURPOSE:
;        Vertically regrids aerosol concentrations from one
;        CTM grid to another.  Total mass is conserved.
;
; CATEGORY:
;        Regridding
;
; CALLING SEQUENCE:
;        REGRIDV_AEROSOL [, Keywords ]
;
; INPUTS:
;        None
;
; KEYWORD PARAMETERS:
;        MONTH -> Month of year for which to process data.  Default is
;             the entire year.  Since the aerosol files are very large,
;             it take several iterations to regrid an entire year of
;             data.  You can break the job down 1 month at a time.
;
;        INFILENAME -> Name of the file containing data to be regridded.
;             If omitted, then REGRIDV_AEROSOL will prompt the user to
;             select a filename with a dialog box.
;
;        OUTFILENAME -> Name of output file containing the regridded
;             data.  If OUTFILENAME is not specified, then REGRIDV_AEROSOL
;             will ask the user to specify a file via a dialog box.
;
;        OUTMODELNAME -> Name of the model grid onto which the data
;             will be regridded.  If OUTMODELNAME is not specified, 
;             REGRIDV_AEROSOL will use the same model name as the
;             input grid.
;
;        DIAGN -> Diagnostic category of the data blocks that you 
;            wish to regrid.  Default is "ARSL-L=$".
;
;        /TROP_ONLY -> If set, will only regrid data within the
;             tropopause (i.e. up to the level specified by
;             MODELINFO.NTROP).  
;
; OUTPUTS:
;        None
;
; SUBROUTINES:
;        External Subroutines Required:
;        =======================================================
;        CTM_GRID          (function)   CTM_TYPE          (function)
;        CTM_BOXSIZE       (function)   CTM_REGRID        (function)
;        CTM_NAMEXT        (function)   CTM_RESEXT        (function)
;        CTM_GET_DATABLOCK (function)   CTM_MAKE_DATAINFO (function)
;        REGRID_COLUMN     (function)   CTM_WRITEBPCH              
;        CTM_GET_DATA                   GETMODELANDGRIDINFO        
;        UNDEFINE   
;
; REQUIREMENTS:
;        None
;
; NOTES:
;        None
;
; EXAMPLE:
;        REGRIDV_AEROSOL, INFILENAME='aerosol.geos3.4x5',  $
;                         OUTFILENAME='aerosol.geos4.4x5', $
;                         OUTRESOLUTION=4,                   $
;
;             ; Regrids dust data from the GEOS-3 4 x 5
;             ; grid to the GEOS-4 4 x 5 grid.
;
; MODIFICATION HISTORY:
;        bmy, 26 Jan 2001: VERSION 1.00
;                          - based on "regrid_dust_weights.pro" 
;        bmy, 13 Feb 2001: VERSION 1.01
;                          - de-hardwired calls to CTM_BOXSIZE
;        bmy, 22 Feb 2001: VERSION 1.02
;                          - now use improved version of SUMV.PRO
;                            which can handle GEOS-1 --> GEOS-STRAT
;                            vertical regridding
;        bmy, 28 Feb 2002: VERSION 1.03
;                          - Now use REGRID_COLUMN as a robust way
;                            to do the vertical regridding
;        bmy, 22 Dec 2003: VERSION 1.04
;                          - rewritten for GAMAP v2-01
;                          - now looks for sfc pressure in ~/IDL/regrid/PSURF
;                          - now supports hybrid grids
;                          - now call PTR_FREE to clear the heap memory
;  bmy & phs, 20 Jun 2007: GAMAP VERSION 2.10
;                          - Use FILE_WHICH to locate surf prs files
;
;-
; Copyright (C) 2001-2007, 
; Bob Yantosca, and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of this 
; software. If this software shall be used commercially or sold as 
; part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.as.harvard.edu with subject "IDL routine regridv_aerosol"
;-----------------------------------------------------------------------

pro RegridV_Aerosol, InFileName=InFileName,       OutFileName=OutFileName,   $
                     OutResolution=OutResolution, OutModelName=OutModelName, $
                     Trop_Only=Trop_Only,         Month=Month,               $
                     DiagN=DiagN,                 _EXTRA=e

   ;====================================================================
   ; Initialization
   ;====================================================================

   ; External functions
   FORWARD_FUNCTION CTM_Type,    CTM_Grid,   CTM_Get_DataBlock, $
                    CTM_BoxSize, CTM_NamExt, CTM_Make_DataInfo, $
                    CTM_ResExt,  Regrid_Column

   ; Keywords
   Trop_Only = Keyword_Set( Trop_Only )
   if ( N_Elements( DiagN        ) ne 1 ) then DiagN         = 'ARSL-L=$'
   if ( N_Elements( Month        ) ne 1 ) then Month         = Indgen(12)+1
   if ( N_Elements( OutModelName ) ne 1 ) then OutModelName  = 'GEOS3'

   ; TAU = time values (hours) for indexing each month -- for 1990
   Tau   = [  96408D,  97152D,  97848D,  98592D,  99312D, 100056D, $ 
             100776D, 101520D, 102264D, 102984D, 103728D, 104448D, 105192D ] 

   ; TAU's for the boxheights and surface pressures (GEOS-1)
   TauPS = [    0D,  744D, 1416D, 2160D, 2880D, 3624D, $
             4344D, 5088D, 5832D, 6552D, 7296D, 8016D ]
   
   ; First-time flag
   FirstTime = 1L

   ;====================================================================
   ; Process data
   ;====================================================================

   ; Get TAU0 to process
   ThisTau = Tau[ Month-1L ]

   ; Read data into the DATAINFO structure of arrays for this month
   CTM_Get_Data, DataInfo, DiagN, FileName=InFileName, Tau0=ThisTau, _EXTRA=e

   ; Loop over data blocks
   for D = 0L, N_Elements( DataInfo )-1L do begin

      ; Echo info
      print, DataInfo[D].TracerName, Format='(''Now Processing: '',a)' 

      ;-------------------
      ; INPUT GRID
      ;-------------------

      ; Get MODELINFO and GRIDINFO structures
      GetModelAndGridInfo, DataInfo[D], InType, InGrid

      ; Box volumes [m3]
      GEOS  = ( InType.Family eq 'GEOS' OR InType.Family eq 'GENERIC' )
      GISS  = ( InType.Family eq 'GISS' )
      FSU   = ( InType.Family eq 'FSU'  )
      InVol = CTM_BoxSize( InGrid, GEOS=GEOS, GISS=GISS, FSU=FSU, /Vol, /m3 )
      InVol = InVol[ *, *, 0L:DataInfo[D].Dim[2]-1L ]

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

      ;-------------------
      ; OUTPUT GRID
      ;-------------------

      ; Get MODELINFO and GRIDINFO structures
      OutType = CTM_Type( OutModelName, Res=InType.Resolution )
      OutGrid = CTM_Grid( OutType )

      ; Maximum level to save on OUTPUT grid
      if ( Trop_Only )            $   
         then LMX = OutType.NTROP $
         else LMX = OutGrid.LMX

      ; Box volumes [m3]
      GEOS   = ( OutType.Family eq 'GEOS' OR OutType.Family eq 'GENERIC' )
      GISS   = ( OutType.Family eq 'GISS' )
      FSU    = ( OutType.Family eq 'FSU'  )
      OutVol = CTM_BoxSize( OutGrid, GEOS=GEOS, GISS=GISS, FSU=FSU, /Vol, /m3 )
      OutVol = OutVol[ *, *, 0L:LMX-1L ]
      
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
                                   Tau0=TauPS[MonInd] )
   
      ; Error check
      if ( not Success ) then Message, 'Could not read PSURF data!'
            
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
   
      endif else begin
         No_Check = 0
         
      endelse

      ; Turn off check if we are only regridding the troposphere
      if ( Trop_Only ) then No_Check = 0

      ;-------------------
      ; REGRID DATA
      ;-------------------

      ; Loop over surface grid boxes
      for J = 0L, OutGrid.JMX-1L do begin
      for I = 0L, OutGrid.IMX-1L do begin

         ; Compute pressure edges for this column
         InPEdge  = ( InVertEdge  * PSurf[I,J] ) + InType.PTOP
         OutPEdge = ( OutVertEdge * PSurf[I,J] ) + OutType.PTOP
           
         ; Column of INPUT DATA; convert from [kg/m3] to [kg]
         InCol    = Reform( InData[I,J,*] * InVol[I,J,*] )
         
         ; Regrid vertically -- preserve column mass
         OutCol   = Regrid_Column( InCol, InPEdge, OutPEdge, $
                                   No_Check=No_Check, _EXTRA=e )
         
         ; Convert OUTPUT DATA from [kg] to [kg/m3]
         OutData[I,J,*] = Reform( OutCol / OutVol[I,J,*] )
           
         ; Undefine stuff
         UnDefine, InCol
         UnDefine, InPEdge
         UnDefine, OutCol
         UnDefine, OutPEdge
               
      endfor
      endfor

      ;-------------------
      ; SAVE DATA BLOCKS
      ;-------------------      

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
                                   Unit=DataInfo[D].Unit,      $
                                   Dim=[OutGrid.IMX,           $
                                        OutGrid.JMX,           $
                                        LMX,                   $
                                        DataInfo[D].Dim[3] ],  $
                                   First=DataInfo[D].First,    $
                                   /No_Global )

      if ( not Success ) then Message, 'Could not make THISDATAINFO structure!'

      ; Save to NEWDATAINFO array of structures
      if ( FirstTime )                                      $
         then NewDataInfo = ThisDataInfo                    $
         else NewDataInfo = [ NewDataInfo, ThisDataInfo ]

      ; Reset first-time flag
      FirstTime = 0L

      ; Undefine stuff
      UnDefine, InType
      UnDefine, InGrid
      UnDefine, InData
      UnDefine, OutType
      UnDefine, OutGrid
      UnDefine, OutData
      UnDefine, ThisDataInfo
      UnDefine, PSurf
   endfor
 
   ;====================================================================
   ; Save data to disk
   ;====================================================================

   ; Default OUTFILENAME
   if ( N_Elements( OutFileName ) ne 1 ) then begin
      OutFileName = 'aerosol.' + CTM_NamExt( OutTypeSav ) + $
                    '.'        + CTM_ResExt( OutTypeSav ) + $
                    '.'        + String( Month, Format='(i2.2)' )
   endif

   ; Write to binary punch format
   CTM_WriteBpch, NewDataInfo, ThisFileInfo, FileName=OutFileName

end
