; $Id: regridh_biofuel.pro,v 1.1.1.1 2007/07/17 20:41:33 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        REGRIDH_BIOFUEL
;
; PURPOSE:
;        Regrids 1 x 1 biofuel burning emissions for NOx or CO
;        onto a CTM grid of equal or coarser resolution.
;
; CATEGORY:
;        Regridding
;
; CALLING SEQUENCE:
;        REGRIDH_BIOFUEL [, Keywords ]
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
;             be written.  Default is './'.  
; 
;        /COPY -> If set, then will just copy 1 x 1 "raw" biofuel
;             data from native ASCII format to binary punch format.
;
; OUTPUTS:
;        Writes binary punch files: 
;             biofuel.generic.1x1        (if /COPY is set)  OR
;             biofuel.geos.{RESOLUTION}  (if OUTRESOLUTION=2 or =4)
;
; SUBROUTINES:
;        External Subroutines Required:
;        ===============================================
;        CTM_GRID    (function)   CTM_TYPE    (function)
;        CTM_REGRIDH (function)   CTM_NAMEXT  (function)   
;        CTM_RESEXT  (function)   CTM_WRITEBPCH
;
;        Internal Subroutines
;        ===============================================
;        RBF_READDATA (function) 
;
; REQUIREMENTS:
;        References routines from the GAMAP and TOOLS packages.
;
; NOTES:
;        The path names for the files containing 1 x 1 data are
;        hardwired -- change as necessary!
;
; EXAMPLE:
;        (1)
;        REGRIDH_BIOFUEL, MODELNAME='GEOS_STRAT', RESOLUTION=[5,4]
;           
;             ; Regrids 1 x 1 biofuel data to the 4 x 5 GEOS-STRAT grid
;
; MODIFICATION HISTORY:
;        bmy, 09 Jun 2000: VERSION 1.00
;        bmy, 12 Jul 2000: VERSION 1.01 
;                          - added NOx keyword
;                          - now read original data with 
;                            internal function RBF_READDATA
;        bmy, 24 Jul 2000: - added OUTDIR keyword
;        bmy, 26 Jan 2001: VERSION 1.02
;                          - added extra species names
;        bmy, 29 Oct 2001: VERSION 1.03
;                          - added /COPY keyword to just copy data
;                            from ASCII format to binary punch format
;                          - now loop over multiple tracer names
;                          - removed TRCNAME keyword
;        bmy, 28 Jan 2002: VERSION 1.04
;                          - bug fix: now convert C2H6, C3H8 and 
;                            ACET from kg/yr to kg C/yr
;        bmy, 14 Nov 2002: VERSION 1.05
;                          - renamed to REGRIDH_BIOFUEL
;        bmy, 23 Dec 2003: VERSION 1.06
;                          - updated for GAMAP v2-01
;
;-
; Copyright (C) 2000-2003, Bob Yantosca, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author.
; Bugs and comments should be directed to bmy@io.harvard.edu
; with subject "IDL routine regridh_biofuel"
;-----------------------------------------------------------------------


function RBF_ReadData, FileList, InGrid 

   ;====================================================================
   ; Internal function RBF_READDATA reads the original biofuel data
   ; from the ASCII format file and returns it to the main program.
   ;====================================================================

   ; Echo info to screen
   S = 'Processing ' + StrTrim( FileList, 2 ) + '...'
   Message, S, /Info
  
   ; INDATA = array to hold 1 x 1 biomass burning data
   InData = DblArr( InGrid.IMX, InGrid.JMX )

   ; TMPVAL is used to read in the data
   TmpVal  = 0D

   ; Open ASCII file containing biomass burning data
   Open_File, FileList, Ilun_IN, /Get_LUN
 
   ; Read data from each monthly file
   ; Data has units of [kg CO/box/yr]
   for J = 0L, InGrid.JMX - 1L do begin
   for I = 0L, InGrid.IMX - 1L do begin
      ReadF, Ilun_In, TmpVal
      InData[I, J] = TmpVal
   endfor
   endfor
 
   ; Close ASCII file
   Close,    Ilun_IN
   Free_LUN, Ilun_IN

   ; Return data to main program
   return, InData
end

;------------------------------------------------------------------------------

pro RegridH_BioFuel, OutModelName=OutModelName, OutResolution=OutResolution, $
                     OutDir=OutDir,             Copy=Copy
 
   ;====================================================================
   ; External Functions / Keyword Settings
   ;====================================================================
   FORWARD_FUNCTION CTM_Grid, CTM_Type, CTM_RegridH, CTM_NamExt, CTM_ResExt

   if ( N_Elements( OutModelName  ) ne 1 ) then OutModelName  = 'GEOS1'
   if ( N_Elements( OutResolution ) eq 0 ) then OutResolution = 4
   if ( N_Elements( OutDir        ) ne 1 ) then OutDir = './'
   Copy = Keyword_Set( Copy )

   ; Trim excess spaces from OUTDIR
   OutDir = StrTrim( OutDir, 2 )

   ; Make sure the last character of OUTDIR is a slash
   if ( StrMid( OutDir, StrLen( OutDir ) - 1, 1 ) ne '/' ) $
      then OutDir = OutDir + '/'

   ;====================================================================
   ; Define MODELINFO and GRIDINFO structures for the 1 x 1 grid
   ; Define MODELINFO and GRIDINFO structures for the CTM grid
   ;====================================================================
   InType  = CTM_Type( 'generic', res=[1, 1], HalfPolar=0, Center180=0 )
   InGrid  = CTM_Grid( InType, /No_Vertical )
   
   OutType = CTM_Type( OutModelName, Resolution=OutResolution )
   OutGrid = CTM_Grid( OutType, /No_Vertical )

   ;====================================================================
   ; Define the path name for each of the ASCII files that 
   ; contain 1 x 1 biomass burning data -- change if necessary!
   ;====================================================================

   ; Tracername array -- hardwire as necessary (bmy, 10/29/01)
   TrcName = [ 'NOx',  'CO',   'ALK4', 'ACET', 'MEK', $
               'ALD2', 'PRPE', 'C3H8', 'CH2O', 'C2H6' ]
   
   ; Set first time flag
   First = 1L

   ; Loop over tracers
   for N=0, N_Elements( TrcName ) - 1L do begin

      ; Species name
      Spec = StrUpCase( StrTrim( TrcName[N], 2 ) )

      ; Pick the tracer number from the given species
      case ( Spec ) of

         ; NOx -- use lowercase X
         'NOX'  : begin
            Spec   = 'NOx'
            Tracer = 1L
            Conv   = 1D
            Unit   = 'kg/yr'
         end

         'CO'   : begin
            Tracer = 4L
            Conv   = 1D
            Unit   = 'kg/yr'
         end

         'ALK4' : begin
            Tracer = 5L
            Conv   = 1D
            Unit   = 'kg C/yr'
         end

         ; Need to convert [kg ACET/yr] to [kg C/yr]
         'ACET' : begin
            Tracer = 9L
            Conv   = ( 12D / 58D ) * 3D
            Unit   = 'kg C/yr'
         end
            
         'MEK'  : begin
            Tracer = 10L
            Conv   = 1D
            Unit   = 'kg C/yr'
         end

         'ALD2' : begin
            Tracer = 11L
            Conv   = 1D
            Unit   = 'kg C/yr'
         end

         'C3H6' : begin
            Tracer = 18L 
            Conv   = 1D
            Unit   = 'kg C/yr'
         end

         ; Need to convert [kg C3H8/yr] to [kg C/yr]
         'C3H8' : begin
            Tracer = 19L
            Conv   = ( 12D / 44D ) * 3D
            Unit   = 'kg C/yr'
         end

         'CH2O' : begin
            Tracer = 20L
            Conv   = 1D
            Unit   = 'kg/yr'
         end
            
         ; Need to convert [kg C2H6/yr] to [kg C/yr]
         'C2H6' : begin
            Tracer = 21L
            Conv   = ( 12D /30D ) * 2D
            Unit   = 'kg C/yr'
         end

         ; PRPE is a synonym for C3H6
         'PRPE' : begin
            Tracer = 18L        
            Spec   = 'C3H6'
            Unit   = 'kg C/yr'
            Conv   = 1D
         end

         ; Everything else is invalid
         else   : begin
            Message, 'Invalid species name!', /Continue
            return
         end
      
      endcase

      ; Path name
      FileList = '/users/ctm/bmy/archive/data/biofuel_200202/raw/kg_yr/' + $
         Spec + 'emiss.biofuels'

      ; Read original data from ASCII file
      InData = RBF_ReadData( FileList, InGrid )
      
      ; Multiply by conversion factor defined above
      InData = InData * Conv

      if ( Copy ) then begin

         ; If just copying the data then skip ahead
         InData = OutData
         InType = OutType
         InGrid = OutGrid

      endif else begin
   
         ; Otherwise regrid the data in units of [kg CO/box/yr]
         OutData = CTM_RegridH( InData,  InGrid, OutGrid,  $
                                /Double, Use_Saved=1L-First )
      endelse

      ; Make a DATAINFO structure for this NEWDATA array
      Success = CTM_Make_DataInfo( Float( OutData ),        $
                                   ThisDataInfo,            $
                                   ThisFileInfo,            $
                                   ModelInfo=OutType,       $
                                   GridInfo=OutGrid,        $
                                   DiagN='BIOFSRCE',        $
                                   Tracer=Tracer,           $
                                   Tau0=0D,                 $
                                   Tau1=8760D,              $
                                   Unit=Unit,               $
                                   Dim=[OutGrid.IMX,        $
                                        OutGrid.JMX, 0, 0], $
                                   First=[1L, 1L, 1L] )
      
      ; Append into array of DATAINFO structures
      if ( First )                                          $
         then NewDataInfo = ThisDataInfo                    $
         else NewDataInfo = [ NewDataInfo, ThisDataInfo ]
      
      ; Reset first time flag
      First = 0L

      ; Undefine stuff for safety's sake
      UnDefine, InData
      UnDefine, OutData
      UnDefine, ThisDataInfo
      UnDefine, Conv
      UnDefine, Unit
      UnDefine, FileList

   endfor

   ;====================================================================
   ; Write all data blocks to a binary punch file
   ;====================================================================
   if ( Copy )                                          $
      then OutFileName = OutDir + 'biofuel.generic.1x1' $
      else OutFileName = OutDir + 'biofuel.geos.' + CTM_ResExt( OutType )

   CTM_WriteBpch, NewDataInfo, ThisFileInfo, FileName=OutFileName
    
   ; Quit
   return
end
