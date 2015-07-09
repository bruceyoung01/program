; $Id: future2bpch.pro,v 1.2 2008/04/02 15:19:01 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        FUTURE2BPCH
;
; PURPOSE:
;        Converts future emission growth factor files from the obsolete
;        binary format to binary punch format (so that they can be
;        read by GAMAP).
;
; CATEGORY:
;        File & I/O, BPCH Format
;
; CALLING SEQUENCE:
;        FUTURE2BPCH, [ Keywords ]
;
; INPUTS:
;        None
;
; KEYWORD PARAMETERS:
;        INFILENAME -> Name of the input file containing fossil 
;             fuel scale factors.  If omitted, SCALEFOSS2BPCH
;             will prompt the user for a filename via a dialog box.
;
;        OUTFILENAME -> Name of the binary punch file containing 
;             fossil fuel scale factors.  Default is to add a
;             ".bpch" extension to INFILENAME.
;
; OUTPUTS:
;         None
;
; SUBROUTINES:
;         External Subroutines Required
;         ==================================================
;         CTM_TYPE (function)   CTM_GRID          (function) 
;         NYMD2TAU (function)   CTM_MAKE_DATAINFO (function) 
;         CTM_WRITEBPCH         EXTRACT_FILENAME  (function)
;
; REQUIREMENTS:
;         None
;
; NOTES:
;         None
;
; EXAMPLE:
;         FUTURE2BPCH, INFILENAME='scalefoss.liq.2x25.1998', $
;                      OUTFILENAME='scalefoss.liq.2x25.1998.bpch'
;
;             ; Converts scalefoss files to BPCH format. 
;
; MODIFICATION HISTORY:
;        bmy, 25 Jan 2006: VERSION 1.00
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
;        bmy, 02 Apr 2008: GAMAP VERSION 2.12
;                          - Now read bpch as big-endian
;
;-
; Copyright (C) 2006-2008, 
; Bob Yantosca and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of 
; this software. If this software shall be used commercially or 
; sold as part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.as.harvard.edu with subject "IDL routine future2bpch"
;-----------------------------------------------------------------------


pro Future2Bpch, InFileName=InFileName, OutFileName=OutFileName,  $
                 DiagN=DiagN,           _EXTRA=e
   
   ;====================================================================
   ; Initialization
   ;====================================================================
   
   ; External Functions
   FORWARD_FUNCTION CTM_Type,         CTM_Grid, CTM_Make_DataInfo, $
                    Extract_FileName, NYMD2Tau
  
   ; Keywords
   if ( N_Elements( DiagN ) ne 1 ) then DiagN = 'FUTURE-E'

   ;====================================================================
   ; Process data
   ;====================================================================
 
   ; Open SCALEFOSS binary file (read as big-endian)
   Open_File, InFileName, Ilun,                                  $
              /Get_Lun,              /F77,                       $
              FileName=FullPathName, Swap_Endian=Little_Endian()
  
   ; Read dimensions
   XDim = 0L
   YDim = 0L
   ReadU, Ilun, XDim, YDim
   ;Print,'Dimensions of array : ', XDim, YDim
 
   ; Read data
   Data = FltArr( XDim, YDim )
   ReadU, Ilun, Data
   ;print, 'Min and max of data: ', Min( Data, Max=M ), M
 
   ; Close file
   Close,    Ilun
   Free_LUN, ilun
 
   ;====================================================================
   ; Compute some necessary variables
   ;====================================================================
   
   ; GEOS-3 1x1
   if ( XDim eq 360 AND YDim eq 181 ) $
      then InType = CTM_Type( 'GEOS3', Res=1 )

   ; GENERIC 1x1
   if ( XDim eq 360 AND YDim eq 180 ) $
      then InType = CTM_Type( 'GENERIC', Res=1 )
   
   ; GEOS-4 1 x 1.25
   if ( XDim eq 288 AND YDim eq 181 ) $
      then InType = CTM_Type( 'GEOS4', Res=[1.25, 1] )

   ; GEOS 2 x 2.5
   if ( XDim eq 144 AND YDim eq 91 ) $
      then InType = CTM_Type( 'GEOS4', Res=2 )

   ; GEOS 4 x 5
   if ( XDim eq 72  AND YDim eq 46 ) $
      then InType = CTM_Type( 'GEOS4', Res=4 )
   
   ; GENERIC 4x5
   if ( XDim eq 72  AND YDim eq 45 ) $
      then InType = CTM_Type( 'GCAP', Res=4 )

   ; Input GRIDINFO structure
   InGrid = CTM_Grid( InType )
 
   ; Get the year as the last 4 digits of INFILENAME
   Year = StrMid( InFileName, StrLen( InFileName ) - 4L, 4 )
 
   ; TAU0 for this year and next year
   Tau0 = Nymd2Tau( ( Year     )*10000L + 0101L )
   Tau1 = Nymd2Tau( ( Year + 1 )*10000L + 0101L )

   ; Initialize 
   Tracer = -1

   ; Get tracer based on file name
   if ( StrPos( InFileName, 'NOx'  ) ge 0 ) then Tracer = 1
   if ( StrPos( InFileName, 'CO'   ) ge 0 ) then Tracer = 4
   if ( StrPos( InFileName, 'ALK4' ) ge 0 ) then Tracer = 5
   if ( StrPos( InFileName, 'ACET' ) ge 0 ) then Tracer = 9
   if ( StrPos( InFileName, 'TONE' ) ge 0 ) then Tracer = 9
   if ( StrPos( InFileName, 'PRPE' ) ge 0 ) then Tracer = 18
   if ( StrPos( InFileName, 'C3H8' ) ge 0 ) then Tracer = 19
   if ( StrPos( InFileName, 'C2H6' ) ge 0 ) then Tracer = 21
   if ( StrPos( InFileName, 'SO2'  ) ge 0 ) then Tracer = 26
   if ( StrPos( InFileName, 'NH3'  ) ge 0 ) then Tracer = 30
   if ( StrPos( InFileName, 'BC'   ) ge 0 ) then Tracer = 34
   if ( StrPos( InFileName, 'OC'   ) ge 0 ) then Tracer = 35
   if ( StrPos( InFileName, 'VOC'  ) ge 0 ) then Tracer = 90
 
   ; Error check tracer
   if ( Tracer eq -1 ) then Message, 'Invalid tracer number!'

   ;====================================================================
   ; Save data blocks
   ;====================================================================
 
   ; Make DATAINFO structure
   Success = CTM_Make_DataInfo( Float( Data ),          $
                                ThisDataInfo,           $
                                ThisFileInfo,           $
                                ModelInfo=InType,       $
                                GridInfo=InGrid,        $
                                DiagN=DiagN,            $
                                Tracer=Tracer,          $
                                Tau0=Tau0,              $
                                Tau1=Tau1,              $
                                Unit='unitless',        $
                                Dim=[InGrid.IMX,        $
                                     InGrid.JMX, 0, 0], $
                                First=[1L, 1L, 1L],     $
                                /No_Global )
     
   ; Error check
   if ( not Success ) then Message, 'Could not make DATAINFO!'
 
   ;====================================================================
   ; Save data to disk
   ;====================================================================

   ; Default OUTFILENAME 
   if ( N_Elements( OutFileName ) ne 1 ) then begin
      OutFileName = Extract_FileName( FullPathName ) + '.bpch'
   endif

   ; Write as binary punch file
   CTM_WriteBpch, ThisDataInfo, ThisFileInfo, FileName=OutFileName

end
