; $Id: regridh_scalefoss.pro,v 1.3 2008/04/02 15:19:04 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        REGRIDH_SCALEFOSS
;
; PURPOSE:
;        Regrids 0.5 x 0.5 fossil fuel scale factors onto a 
;        CTM grid of equal or coarser resolution.
;
; CATEGORY:
;        Regridding
;
; CALLING SEQUENCE:
;        REGRID_SCALEFOSS [, Keywords ]
;
; INPUTS:
;        None
;
; KEYWORD PARAMETERS:
;        MODELNAME -> A string containing the name of the model 
;             grid onto which the data will be regridded.
;
;        RESOLUTION -> Specifies the resolution of the model grid
;             onto which the data will be regridded.  RESOLUTION
;             can be either a 2 element vector with [ DI, DJ ] or
;             a scalar (DJxDI: 8=8x10, 4=4x5, 2=2x2.5, 1=1x1, 
;             0.5=0.5x0.5).  Default for all models is 4x5.;
;
;        YEAR -> 4-digit year number (e.g. 1994) correspoinding
;             to the data to be regridded.  Default is 1994.
;
;        OUTDIR -> Name of the directory where the output file will
;             be written.  Default is './'. 
;
; OUTPUTS:
;        Writes output to binary files (*NOT* binary punch files):
;             scalefoss.liq.{RESOLUTION}.{YEAR}
;             scalefoss.tot.{RESOLUTION}.{YEAR}
;
; SUBROUTINES:
;        External Subroutines Required:
;        ================================================
;        CTM_GRID    (function)    CTM_TYPE   (function)
;        CTM_REGRID  (function)    CTM_NAMEXT (function)   
;        CTM_RESEXT  (function)
;
;        Internal Subroutines:
;        ================================================
;        RS_READ_DATA (function)   RS_WRITE_DATA
;
; REQUIREMENTS:
;        None
;
; NOTES:
;        None
;
; EXAMPLE:
;        REGRID_SCALEFOSS, YEAR=1994,              $
;                          MODELNAME='GEOS_STRAT', $
;                          RESOLUTION=[5,4]
;           
;             ; Regrids fossil fuel scale factor files for 1994 from
;             ; 0.5 x 0.5 resolution onto the 4 x 5 GEOS-STRAT grid
;
; MODIFICATION HISTORY:
;        bmy, 09 Jun 2000: VERSION 1.00
;  bmy & phs, 20 Jun 2007: GAMAP VERSION 2.10
;        phs, 08 Feb 2008: GAMAP VERSION 2.12
;                          - added swap_endian keyword to OPEN_FILE
;                            in RS_Read_Data and RS_WRITE_DATA
;                          - fixed keywords checking
;                          - replace ctm_regrid w/ ctm_regridh
;
;-
; Copyright (C) 2000-2008, 
; Bob Yantosca, and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of this 
; software. If this software shall be used commercially or sold as 
; part of a larger package, please contact the author.
; Bugs and comments should be directed to yantosca@seas.harvard.edu
; or plesager@seas.harvard.edu with subject "IDL routine regridh_scalefoss"
;-----------------------------------------------------------------------


function RS_Read_Data, FileName, GridInfo

   ;====================================================================
   ; Internal Function RS_READ_DATA reads either liquid fuel scale
   ; factors or total fuel scale factors from disk.
   ;====================================================================

   ; Define IMX, JMX as longwords
   IMX = 0L
   JMX = 0L

   ; Open file and read the dimensions of the data block
   Open_File, FileName, Ilun, /Get_Lun, /F77, Swap_Endian=Little_Endian() 
   ReadU, Ilun, IMX, JMX
   
   ; Make a floating point array of size (IMX,JMX) and read data
   Data = FltArr( IMX, JMX )
   ReadU, Ilun, Data

   ; Error check array dimensions against GRIDINFO
   SData = Size( Data, /Dim )
   if ( SData[0] ne GridInfo.IMX or SData[1] ne GridInfo.JMX ) then begin
      Message, 'Data is not 0.5 x 0.5 resolution!', /Continue
   endif

   ; Return DATA to main program
   return, Data
end 

;------------------------------------------------------------------------------

pro RS_Write_Data, Data, FileName=FileName
   
   ;====================================================================
   ; Internal Function RS_READ_DATA writes either liquid fuel scale
   ; factors or total fuel scale factors to disk.
   ;====================================================================

   ; Get the dimensions of the file
   SData = Size( Data, /Dim )
   IMX   = Long( SData[0] )
   JMX   = Long( SData[1] )

   ; Open the binary file for output
   Open_File, FileName, Ilun, $
              /Get_Lun, /Write, /F77_Unformatted, Swap_Endian=Little_Endian() 

   ; Write dimensions and the data to the binary file
   WriteU, Ilun, IMX, JMX
   WriteU, Ilun, Float( Data )
   
   ; Close file and return
   Close,    Ilun
   Free_LUN, Ilun

   return
end 

;------------------------------------------------------------------------------

pro RegridH_ScaleFoss, OutModelName=ModelName, OutResolution=Resolution, $
                       Year=Year,              OutDir=OutDir
 
   ;====================================================================
   ; External Functions / Keyword Settings
   ;====================================================================
   FORWARD_FUNCTION CTM_Type,   CTM_Grid,   CTM_Regrid,  $ 
                    CTM_NamExt, CTM_ResExt, Little_Endian
   
   if ( N_Elements( Year       ) eq 0 ) then Year       = 1994
   if ( N_Elements( ModelName  ) eq 0 ) then ModelName  = 'GEOS4'
   if ( N_Elements( Resolution ) eq 0 ) then Resolution = 4
   if ( N_Elements( OutDir     ) eq 0 ) then OutDir     = './'
   
   ; Trim excess spaces from OUTDIR
   OutDir = StrTrim( OutDir, 2 )

   ; Make sure the last character of OUTDIR is a slash
   if ( StrMid( OutDir, StrLen( OutDir ) - 1, 1 ) ne '/' ) $
      then OutDir = OutDir + '/' 

   ;====================================================================
   ; Define MODELINFO and GRIDINFO structures for old & new grids
   ;====================================================================
   InType = CTM_Type( 'generic', res=[0.5, 0.5], HalfPolar=0, Center180=0 )
   InGrid = CTM_Grid( InType, /No_Vertical )
   
   OutType = CTM_Type( ModelName, Resolution=Resolution )
   OutGrid = CTM_Grid( OutType, /No_Vertical )
 
   ;====================================================================
   ; Construct the proper filenames for liquid & total fuel files
   ; Read data from the proper file -- also check array dimensions 
   ;====================================================================
   YearStr = StrTrim( String( Year, Format='(i4)' ), 2 )

   root = '/home/bmy/archive/data/scalefoss_200607/05x05_gen/'

   LiqFile = root + 'scalefoss.liq.05x05.' + YearStr 
   TotFile = root + 'scalefoss.tot.05x05.' + YearStr

;   LiqFile = '~bmy/sup/scalefoss/scalefoss.liq.05x05.' + YearStr 
;   TotFile = '~bmy/sup/scalefoss/scalefoss.tot.05x05.' + YearStr

   InLiq   = RS_Read_Data( LiqFile, InGrid )
   InTot   = RS_Read_Data( TotFile, InGrid )
   
   ;====================================================================
   ; Call CTM_REGRID to regrid the liquid and total fuel 
   ; scale factors to the CTM grid resolution.
   ;====================================================================   
   OutLiq = CTM_Regridh( InLiq, InGrid, OutGrid, /Double )
   OutTot = CTM_Regridh( InTot, InGrid, OutGrid, /Double, /Use_Saved )

   ;====================================================================
   ; Write regridded liquid and total fossil fuel data to disk
   ;====================================================================
   LiqFile = OutDir + 'scalefoss.liq.' + CTM_ResExt( OutType ) + '.' + YearStr 
   TotFile = OutDir + 'scalefoss.tot.' + CTM_ResExt( OutType ) + '.' + YearStr

   RS_Write_Data, OutLiq, FileName=LiqFile
   RS_Write_Data, OutTot, FileName=TotFile

   return
end
