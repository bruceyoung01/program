; $Id: regrid_toms_sbuv.pro,v 1.1.1.1 2007/07/17 20:41:31 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        REGRID_TOMS_SBUV
;
; PURPOSE:
;        Regrids 5 x 10 O3 column data from both 
;        TOMS and SBUV instruments onto a CTM grid.
;
; CATEGORY:
;        Regridding
;
; CALLING SEQUENCE:
;        REGRID_TOMS_SBUV [ , Keywords ]
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
;        OUTDIR -> Name of the directory where the output file will
;             be written.  Default is './'.  ;
; OUTPUTS:
;        Writes regridded O3 columns to file.
;
; SUBROUTINES:
;        
;
; REQUIREMENTS:
;        References routines from both GAMAP and TOOLS packages.
;
; NOTES:
;        (1) Input filename is hardwired -- change as necessary
;
; EXAMPLE:
;        REGRID_TOMS_SBUV, OUTMODELNAME='GEOS1', $
;                          OUTRESOLUTION=4,      $
;                          OUTDIR='/scratch/'
; 
;             ; Regrids O3 column data to GEOS-1 4 x 5 grid,
;             ; writes output file to /scratch directory
;
; MODIFICATION HISTORY:
;        bmy, 16 Mar 2001: VERSION 1.00
;        bmy, 29 Mar 2001: VERSION 1.01
;                          - renamed to REGRID_TOMS_SBUV
;                          - renamed keyword MODELNAME to OUTMODELNAME
;                          - renamed keyword RESOLUTION to OUTRESOLUTION
;                          - now use routine INTERPOLATE_2D
;
;-
; Copyright (C) 2001, Bob Yantosca, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author.
; Bugs and comments should be directed to bmy@io.harvard.edu
; with subject "IDL routine regrid_toms_sbuv"
;-----------------------------------------------------------------------


pro Regrid_TOMS_SBUV, OutModelName=OutModelName, $
                      OutResolution=Resolution,  $
                      OutDir=OutDir
 
   ; External functions
   FORWARD_FUNCTION CTM_Type, CTM_Grid, CTM_Make_DataInfo
   
   ; Keywords
   if ( N_Elements( ModelName  ) ne 1 ) then ModelName  = 'GEOS1'
   if ( N_Elements( Resolution ) ne 1 ) then Resolution = 4
   if ( N_Elements( OutDir     ) ne 1 ) then OutDir     = './'
 
   ; Trim excess spaces from OUTDIR
   OutDir = StrTrim( OutDir, 2 )
 
   ; Make sure the last character of OUTDIR is a slash
   if ( StrMid( OutDir, StrLen( OutDir ) - 1, 1 ) ne '/' ) $
      then OutDir = OutDir + '/'
 
   ;====================================================================
   ; Define variables
   ;====================================================================
   FileName = '/users/ctm/bnd/amalthea/TOMSO3/toms_sbuv_v3_78-00_5x10.txt'
   Line    = ''
   OldXMid = FltArr(36)
   OldYMid = FltArr(36)
   Lat     = IntArr(2 )
   TmpData = FltArr(36)
   Data    = Fltarr(36, 36)
 
   ; Array of month names
   Months  = [ 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', $
               'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec' ]
 
   ; First-time flag
   Flag = 1L
 
   ; MODELINFO and GRIDINFO structures
   NewType = CTM_Type( ModelName, Resolution=Resolution )
   NewGrid = CTM_Grid( NewType,   /No_Vertical          )
 
   ;====================================================================
   ; Process data
   ;====================================================================
   Open_File, FileName, Ilun, /Get_Lun
 
   while ( not EOF( Ilun ) ) do begin
 
      ;=================================================================
      ; Header Line -- extract month & year
      ;=================================================================
      ReadF, Ilun, Line
      Month = StrMid( Line, 0, 3 )
      Year  = StrMid( Line, 4, 4 )
 
      ;=================================================================
      ; Read longitude bin centers
      ;=================================================================
      ReadF, Ilun, OldXMid
 
      ; Shift them so that the starting box is edged on -180
      OldXMid = Shift( Temporary( OldXMid ), 18 )
 
      ; Put OLDXMID in the range of -180,180
      Ind = Where( OldXMid gt 180 )
      if ( Ind[0] ge 0 ) then OldXMid[Ind] = OldXMid[Ind] - 360
 
      ;=================================================================      
      ; Read Latitude centers and data
      ; Shift data so that the starting box is edged on -180
      ;=================================================================
      J = 0
GetData:
      ReadF, Ilun, Lat, TmpData, Format='(i3,1x,i3,36f6.1)'
      TmpData = Shift( Temporary( TmpData ), 18 )
 
      ; OLDYMID is the latitude bin center
      OldYMid[J] = 0.5 * ( Lat[1] + Lat[0] )
 
      ; Save into data array
      Data[*, J] = TmpData
 
      ; Increment latitude index
      J = J + 1
 
      ; Get next latitude (if necessary)
      if ( Lat[1] lt 90 ) then goto, GetData
 
      ;=================================================================      
      ; Compute TAU values for this month and next month
      ;================================================================= 
 
      ; Find the current month and next month
      Ind = Where( Months eq Month )
      if ( Ind[0] ge 0 ) then begin
         ThisMonth = Ind[0]    + 1 
         NextMonth = ThisMonth + 1
 
         ; For December, the next month is January
         ; and it is into the next year -- adjust stuff
         if ( NextMonth gt 12 ) then begin
            ThisYear  = Long( Year )
            NextYear  = ThisYear + 1
            NextMonth = NextMonth - 12            
         endif else begin
            ThisYear  = Long( Year )
            NextYear  = ThisYear
         endelse
      endif
 
      ; YYYYMMDD at start of this month
      NYMD0 = ( ThisYear * 10000 ) + ( Long( ThisMonth ) * 100 ) + 1L
 
      ; YYYYMMDD at start of the next month
      NYMD1 = ( NextYear * 10000 ) + ( Long( NextMonth ) * 100 ) + 1L  
 
      ; Don't regrid O3 cols prior to 1985
      ; The DAO met data does not exist before then!
      if ( NYMD0 lt 19850101 ) then begin
         Print, 'Skipping ' + String( NYMD0, Format='(i8.8)' ) + '...' 
         goto, Next
      endif
 
      ;=================================================================      
      ; Interpolate data from 5 x 10 to CTM resolution
      ;================================================================= 
      Print, 'Regridding ' + String( NYMD0, Format='(i8.8)' ) + '...' 
      
      NewData = Interpolate_2D( Data, OldXMid, OldYMid,     $
                                NewGrid.XMid, NewGrid.YMid )

      ;----------------------------------------------------------------
      ;### Debug -- plot maps side by side
      ;multipanel, 2
      ; 
      ;Max0    = Max( Data )
      ;Max1    = Max( Tmp2 )
      ;MaxData = Max( [ Max0, Max1 ] )
      ; 
      ;Title = Month + Year + 'orig'
      ;TvMap, Data, OldXMid, OldYMid, /Grid, /Countries, /Coasts, $
      ;   /CBar, Div=4, /Sample, Min_Valid=1.0, Title=Title,      $
      ;   MaxData=MaxData
      ; 
      ;Title = Month + Year + 'new'
      ;TvMap, Tmp2, NewGrid.XMid, NewGrid.YMid, /Grid, $
      ;   /Countries, /Coasts, /CBar, Div=4, /Sample, $
      ;   Min_Valid=1.0, Title=Title, MaxData=MaxData
      ;   
      ;read, Line
      ;----------------------------------------------------------------
 
      ;=================================================================      
      ; Create a DATAINFO entry for each month and year of O3 data
      ;=================================================================       
      Result = CTM_Make_DataInfo( NewData, ThisDataInfo,         $
                                  ModelInfo=NewType,             $
                                  GridInfo=NewGrid,              $
                                  DiagN='O3COLMAP',              $          
                                  Tracer=25L,                    $
                                  Tau0=NYMD2Tau( NYMD0, /GEOS ), $
                                  Tau1=NYMD2Tau( NYMD1, /GEOS ), $
                                  Unit='DU',                     $
                                  Dim=[NewGrid.IMX,              $
                                       NewGrid.JMX, 0, 0 ],      $
                                  First=[1L, 1L, 1L],            $
                                  /NO_GLOBAL )
 
 
      ; Append into array of DATAINFO structures
      if ( Flag )                                           $
         then NewDataInfo = [ ThisDataInfo ]                $
         else NewDataInfo = [ NewDataInfo, ThisDataInfo ]
 
      ; Reset First-time 
      Flag = 0L
      
      ;=================================================================
      ; Undefine variables for safety's sake
      ;=================================================================
      UnDefine, Tmp1
      UnDefine, Tmp2
      UnDefine, ThisDataInfo
 
Next:
   endwhile
 
   ;====================================================================
   ; Write to punch file
   ;====================================================================
   OutFileName = OutDir + 'O3_TOMS.geos.' + CTM_ResExt( NewType )
 
   CTM_WriteBpch, NewDataInfo, FileName=OutFileName
 
   ;====================================================================
   ; Close file and quit
   ;====================================================================
Quit:
   Close,   Ilun
   Free_LUN, Ilun
 
   return
end
