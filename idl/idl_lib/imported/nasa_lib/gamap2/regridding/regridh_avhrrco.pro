; $Id: regridh_avhrrco.pro,v 1.1.1.1 2007/07/17 20:41:32 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        REGRIDH_AVHRRCO
;
; PURPOSE:
;        Regrids AVHRR biomass burning emissions at 
;        1 x 1 resolution to CTM resolution.
;
; CATEGORY:
;        Regridding
;
; CALLING SEQUENCE:
;        REGRIDH_AVHRRCO [, Keywords ]
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
;        /COPY -> Use this switch to write the original 1 x 1
;             biomass burning data to a binary punch file without
;             regridding.  
;
; OUTPUTS:
;        Writes binary punch files: 
;             bioburn.avhrr.mon.{RESOLUTION}
;
; SUBROUTINES:
;        External Subroutines Required:
;        =================================================
;        CTM_GRID      (function)   CTM_TYPE   (function)
;        CTM_BOXSIZE   (function)   CTM_RESEXT (function)   
;        CTM_NAMEXT    (function)   NYMD2TAU   (function)
;        CTM_REGRIDH   (function)   CTM_WRITEBPCH
;
; REQUIREMENTS:
;        References routines from the GAMAP and TOOLS packages.
;
; NOTES:
;        (1) The path names for the files containing 1 x 1 data are
;            hardwired -- change as necessary!
;
;        (2) Sometimes you might have to close all files and call
;            "ctm_cleanup.pro" in between calls to this routine.
;
;        (3) Can be extended to other tracers than CO...
;
; EXAMPLE:
;        REGRIDH_AVHRRCO, OUTMODELNAME='GEOS_STRAT', $
;                         OUTRESOLUTION=4
;           
;             ; Regrids 1 x 1 AVHRR CO biomass burning data
;             ; onto the 4 x 5 GEOS-STRAT grid
;
; MODIFICATION HISTORY:
;  clh & bmy, 09 Jun 2000: VERSION 1.00
;                          - adapted from "regrid_bioburn.pro"  
;        bmy, 14 Nov 2002: VERSION 1.01
;                          - now use CTM_REGRIDH for horiz regridding
;                          - renamed to "regridh_avhrrco.pro"
;        bmy, 23 Dec 2003: VERSION 1.02
;                          - updated for GAMAP v2-01
;
;-
; Copyright (C) 2000, 2001, 2002, 2003,
; Colette Heald and Bob Yantosca, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author.
; Bugs and comments should be directed to clh@io.harvard.edu
; or bmy@io.harvard.edu with subject "IDL routine regrid_avhrrco"
;-----------------------------------------------------------------------


function RBB_ReadData, FileName, GridInfo
   
   ;====================================================================
   ; Internal function RBB_READDATA reads the 1 x 1 biomass burning
   ; data from disk in ASCII format and returns it to the main program
   ;====================================================================

   ; Print filename for this month
   S = 'Reading ' + StrTrim( FileName, 2 )
   Message, S, /Info

   ; Array to hold 1 x 1 biomass burning data
   Data = DblArr( GridInfo.IMX, GridInfo.JMX )

   ; Open ASCII file containing biomass burning data for CO
   Open_File, FileName, Ilun, /Get_LUN
 
   ; read data from AVHRR file
   A = 0.0
   for I = 0, GridInfo.IMX - 1L do begin
   for J = 0, GridInfo.JMX - 1L do begin
      ReadF, Ilun, I, J, A
      Data[I-1, 180-J] = A
   endfor
   endfor
 
   ; Close ASCII file
   Close,    Ilun
   Free_LUN, Ilun

   ; Return DATA to calling program
   return, Data
end

;-----------------------------------------------------------------------------

pro RegridH_AVHRRCO, OutModelName=OutModelName, OutResolution=OutResolution, $
                     Copy=Copy,                 _EXTRA=e
 
   ;====================================================================
   ; Initialize
   ;====================================================================
 
   ; Close all open files
   Close, /All

   ; External functions
   FORWARD_FUNCTION CTM_Type,   CTM_Grid,   CTM_RegridH, $
                    CTM_NamExt, CTM_ResExt, NYMD2Tau

   ; Keywords
   Copy = Keyword_Set( Copy )
   if ( N_Elements( OutModelName  ) eq 0 ) then OutModelName  = 'GEOS3'
   if ( N_Elements( OutResolution ) eq 0 ) then OutResolution = 2
   
   ;====================================================================
   ; Define variables
   ;====================================================================
   TracerList     = IndGen(1) + 1
   TracerStr      = StrTrim( String( TracerList, Format='(i14)' ), 2 )
   CTM_TracerList = [ 4 ]
   TracerName     = [ 'CO' ]
   Unit           = [ 'molec/cm2' ]
   XNumol         = 6.022d23 / MolWt                      
   
   ; Input file names (hardwired for now)
   InFileName = '/users/ctm/clh/AVHRR/' + 
                [ '200008.co', '200009.co', '200010.co', '200011.co',  $
                  '200012.co', '200101.co', '200102.co', '200103.co', $
                  '200104.co' ]

   ; MODELINFO, GRIDINFO structures, and surface areas for old grid
   InType    = CTM_Type( 'generic', res=[1, 1], HalfPolar=0, Center180=0 )
   InGrid    = CTM_Grid( InType, /No_Vertical )

   ; MODELINFO, GRIDINFO structures, and surface areas for new grid
   OutType   = CTM_Type( OutModelName, Resolution=OutResolution )
   OutGrid   = CTM_Grid( OutType, /No_Vertical )
 
   ; TAU = time values (hours) for indexing each month
   Nymd      = [ 20000801L, 20000901L, 20001001L, 20001101L, 20001201L, $
                 20010101L, 20010201L, 20010301L, 20010401L, 20010501L, $
                 20010601L, 20010701L ]  
  
   Tau       = Nymd2Tau( Nymd )
 
   ; If we are copying 1 x 1 data to a binary punch file, then
   ; make sure to use the proper MODELINFO and GRIDINFO structures
   if ( Copy ) then begin
      OutType = InType
      OutGrid = InGrid
   endif 

   ;====================================================================
   ; Regrid all biomass burning tracers for this month
   ; Now use pre-saved mapping weights
   ;====================================================================

   ; Set first time flag
   First = 1L

   ; T is the month index
   for T = 0, N_Elements( MonthName ) - 1L do begin

      ; TAU0 and TAU1 for punch file
      ThisTau0 = Tau[T]
      ThisTau1 = Tau[T+1]

      ; N is the tracer index
      for N = 0L, N_Elements( CTM_TracerList ) - 1L do begin

         ; Read biomass burning data on the 1 x 1 grid
         InData = RBB_ReadData( InFileName[T], InGrid )

         if ( Copy ) then begin

            ; Skip regridding if this is already 1 x 1 data
            NewData = OldData

         endif else begin

            ; Reuse saved Mapping weights?
            US = 1L - First
         
            ; Regrid data from 1 x 1 to CTM resolution!
            OutData = CTM_RegridH( InData,         InGrid,  OutGrid,      $
                                   /Per_Unit_Area, /Double, Use_Saved=US )
 
         endelse

         ; Make a DATAINFO structure for this NEWDATA
         Success = CTM_Make_DataInfo( Float( OutData ),         $
                                      ThisDataInfo,             $
                                      ThisFileInfo,             $
                                      ModelInfo=OutType,        $
                                      GridInfo=OutGrid,         $
                                      DiagN='BIOBSRCE',         $
                                      Tracer=CTM_TracerList[N], $
                                      Tau0=ThisTau0,            $
                                      Tau1=ThisTau1,            $
                                      Unit=Unit[N],             $
                                      Dim=[NewGrid.IMX,         $
                                           NewGrid.JMX, 0, 0],  $
                                      First=[1L, 1L, 1L] )
 
         ; NEWDATAINFO is an array of DATAINFO Structures
         ; Append THISDATAINFO onto the NEWDATAINFO array
         if ( First )                                           $             
            then NewDataInfo = [ ThisDataInfo ]                 $
            else NewDataInfo = [ NewDataInfo, ThisDataInfo ]

         ; Reset the first time flag
         First = 0L

         ; Undefine variables for safety's sake
         UnDefine, InData
         UnDefine, OutData
         UnDefine, ThisDataInfo

      endfor  ; N
   endfor     ; T
 
   ;====================================================================
   ; Write all data blocks to a binary punch file
   ;====================================================================
   OutFileName = 'bioburn.avhrr.mon.geos' + CTM_ResExt( NewType ) 

   CTM_WriteBpch, NewDataInfo, ThisFileInfo, FileName=OutFileName

   ; Quit
   return
end
