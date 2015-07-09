; $Id: regridh_pops.pro,v 1.1.1.1 2007/07/17 20:41:32 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        REGRIDH_POPS
;
; PURPOSE:
;        Regrids 1 x 1 POPS (persistent organic pollutants) emissions 
;        onto a CTM grid of equal or coarser resolution.
;
; CATEGORY:
;        Regridding
;
; CALLING SEQUENCE:
;        REGRIDH_POPS [, Keywords ]
;
; INPUTS:
;        None
;
; KEYWORD PARAMETERS:
;        INFILENAME -> Name (or array of names) of the ASCII file(s) 
;             which contain(s) emissions for a POP species.  If
;             omitted, then the user will be prompted to select a 
;             file via a dialog box.
; 
;        OUTFILENAME -> Name of the bpch file which will contain
;             regridded data.  If omitted, then the user will be
;             prompted to select a file via a dialog box.
; 
;        OUTMODELNAME -> A string containing the name of the model 
;             grid onto which the data will be regridded.
;
;        OUTRESOLUTION -> Specifies the resolution of the model grid
;             onto which the data will be regridded.  RESOLUTION
;             can be either a 2 element vector with [ DI, DJ ] or
;             a scalar (DJxDI: 8=8x10, 4=4x5, 2=2x2.5, 1=1x1, 
;             0.5=0.5x0.5).  Default for all models is 4x5.
;
; OUTPUTS:
;        None
;
; SUBROUTINES:
;        External Subroutines Required:
;        =======================================================
;        CTM_GRID     (function)   CTM_TYPE          (function)
;        CTM_REGRIDH  (function)   CTM_MAKE_DATAINFO (function) 
;        CTM_WRITEBPCH             READDATA
;
; REQUIREMENTS:
;        None
;
; NOTES:
;        Assumes GAMAP diagnostic category name of "POP-ANTH".
;
; EXAMPLE:
;        REGRIDH_POPS, INFILENAME='EmisPCB28Mean',$
;                      OUTMODELNAME='GEOS3',      $
;                      OUTRESOLUTION=2,           $
;                      OUTFILENAME='PCB28.bpch'
;           
;             ; Regrids 1x1 POPS emissions [kg/yr] to 4x5 GEOS grid
;
; MODIFICATION HISTORY:
;        bmy, 23 May 2005: VERSION 1.00
;  bmy & phs, 20 Jun 2007: GAMAP VERSION 2.10
;
;-
; Copyright (C) 20005-2007, 
; Bob Yantosca, and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of this 
; software. If this software shall be used commercially or sold as 
; part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.as.harvard.edu with subject "IDL routine regridh_pops"
;-----------------------------------------------------------------------


pro RegridH_POPS, InFileName=InFileName,       $
                  OutFileName=OutFileName,     $
                  OutModelName=OutModelName,   $
                  OutResolution=OutResolution, $
                  Use_Saved_Weights=US,        $
                  _EXTRA=e

   ;====================================================================
   ; Initialization
   ;====================================================================

   ; External functions
   FORWARD_FUNCTION CTM_Grid,    CTM_Type,        $
                    CTM_RegridH, CTM_Make_DataInfo

   ; Keywords
   if ( N_Elements( US            ) ne 1 ) then US            = 0
   if ( N_Elements( OutModelName  ) ne 1 ) then OutModelName  = 'GEOS1'
   if ( N_Elements( OutResolution ) eq 0 ) then OutResolution = 4

   ; Define 1x1 generic grid
   InType  = CTM_Type( 'generic', res=[1, 1], HalfPolar=0, Center180=0 )
   InGrid  = CTM_Grid( InType, /No_Vertical )
   
   ; Define output grid
   OutType = CTM_Type( OutModelName, Resolution=OutResolution )
   OutGrid = CTM_Grid( OutType, /No_Vertical )

   ; Loop over files
   FirstTime = 1L

   ;====================================================================
   ; Read and process data
   ;====================================================================
   
   ; Loop over each file
   for N = 0L, N_Elements( InFileName )-1L do begin
      
      ; The current file name
      ThisFile = InFileName[N]

      ; Echo info
      Print, 'Processing: ', StrTrim( ThisFile, 2 )

      ; Test if this is a monthly file or a yearly file
      ; if there is an extension like '.01' then it's monthly
      if ( StrPos( ThisFile, '.' ) ge 0 ) then begin
         Month = Long( StrRight( ThisFile, 2 ) )
         Nymd0 = 19850000 + Month*100L + 1

         ; Special handling for December
         if ( Month+1 eq 13 )                          $
            then Nymd1 = 19860101                      $
            else Nymd1 = 19850000 + (Month+1)*100L + 1

         ; Start of diagnostic period
         Tau0 = Nymd2Tau( Nymd0 )
         Tau1 = Nymd2Tau( Nymd1 )

         ; Use saved weights for regridding
         US = 1L - FirstTime

      endif else begin

         ; File contains yearly data
         Tau0 = 0D
         Tau1 = 8760D

      endelse

      ; Read 1x1 data from ASCII files [kg/yr]
      ReadData, ThisFile, InData, Delim=' ', /NoHeader, Cols=360, /Double

      ; Make sure longitudes run from S -> N
      InData = Reverse( InData, 2 )

      ; Regrid the data [kg/yr]
      OutData = CTM_RegridH( InData,  InGrid, OutGrid, $
                             /Double, Use_Saved=US )

      ; Find tracer number
      if ( StrPos( ThisFile, 'PCB28' ) ge 0 ) then Tracer = 1

      ; Make a DATAINFO structure corresponding to OUTDATA
      Success = CTM_Make_DataInfo( Float( OutData ),        $
                                   ThisDataInfo,            $
                                   ThisFileInfo,            $
                                   ModelInfo=OutType,       $
                                   GridInfo=OutGrid,        $
                                   DiagN='POP-ANTH',        $
                                   Tracer=Tracer,           $
                                   Tau0=Tau0,               $
                                   Tau1=Tau1,               $
                                   Unit='kg',               $
                                   Dim=[OutGrid.IMX,        $
                                        OutGrid.JMX, 0, 0], $
                                   First=[1L, 1L, 1L] )

      if ( not Success ) then Message, 'Error!'

      ; Save into NEWDATAINFO array of structures
      if ( FirstTime ) then begin
         NewDataInfo = ThisDataInfo
         NewFileInfo = ThisFileInfo
      endif else begin
         NewDataInfo = [ NewDataInfo, ThisDataInfo ]
         NewFileInfo = [ NewFileInfo, ThisFileInfo ]
      endelse

      ; Reset 1st time flag
      FirstTime = 0L

      ; Undefine variables
      Undefine, InData
      Undefine, OutData
      UnDefine, ThisDataInfo
      UnDefine, ThisFileInfo
      UnDefine, ThisFile
      UnDefine, Tau0
      UnDefine, Tau1
      UnDefine, Tracer

Next:   
   endfor
      
   ;====================================================================
   ; Save file and quit
   ;====================================================================

   ; Write to bpch file
   CTM_WriteBpch, NewDataInfo, NewFileInfo, FileName=OutFileName
    
   ; Quit
   return
end
