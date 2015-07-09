; $Id: scalefoss2bpch.pro,v 1.2 2008/04/02 15:19:02 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        SCALEFOSS2BPCH
;
; PURPOSE:
;        Converts fossil fuel scale factor files from the obsolete
;        binary format to binary punch format (so that they can be
;        read by GAMAP).
;
; CATEGORY:
;        File & I/O, BPCH Format
;
; CALLING SEQUENCE:
;        SCALEFOSS2BPCH, [ Keywords ]
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
;         SCALEFOSS2BPCH, INFILENAME='scalefoss.liq.2x25.1998', $
;                         OUTFILENAME='scalefoss.liq.2x25.1998.bpch'
;
;             ; Converts scalefoss files to BPCH format. 
;
; MODIFICATION HISTORY:
;        bmy, 15 Jan 2003: VERSION 1.00
;        bmy, 23 Dec 2003: VERSION 1.01
;                          - rewritten for GAMAP v2-01
;        bmy, 27 Jun 2006: VERSION 1.02
;                          - Use more robust algorithm for getting
;                            the year out of the file name
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
;        bmy, 02 Apr 2008: GAMAP VERSION 2.12
;                          - Now read input file as big-endian
;
;-
; Copyright (C) 2003-2008, 
; Bob Yantosca and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of 
; this software. If this software shall be used commercially or 
; sold as part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.as.harvard.edu with subject "IDL routine scalefoss2bpch"
;-----------------------------------------------------------------------


pro ScaleFoss2Bpch, InFileName=InFileName, OutFileName=OutFileName,  $
                    DiagN=DiagN,           _EXTRA=e
   
   ;====================================================================
   ; Initialization
   ;====================================================================
   
   ; External Functions
   FORWARD_FUNCTION CTM_Type,         CTM_Grid, CTM_Make_DataInfo, $
                    Extract_FileName, NYMD2Tau
  
   ; Keywords
   if ( N_Elements( DiagN ) ne 1 ) then DiagN = 'SCALFOSS'

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
   Print,'Dimensions of array : ', XDim, YDim
 
   ; Read data
   Data = FltArr( XDim, YDim )
   ReadU, Ilun, Data
   print, 'Min and max of data: ', Min( Data, Max=M ), M
 
   ; Close file
   Close,    Ilun
   Free_LUN, ilun
 
   ;====================================================================
   ; Compute some necessary variables
   ;====================================================================
   
   ; Input MODELINFO structure
   case ( XDim ) of 
      720: InType = CTM_Type( 'GENERIC', Res=[0.5,0.5], HalfP=0, Center180=0 )
      360: InType = CTM_Type( 'GEOS3',   Res=1         )
      288: InType = CTM_Type( 'GEOS4',   Res=[1.25, 1] )
      144: InType = CTM_Type( 'GEOS3',   Res=2         )
       72: InType = CTM_Type( 'GEOS3',   Res=4         )
     else: Message, 'Invalid horizontal resolution!'
   endcase
 
   ; Input GRIDINFO structure
   InGrid = CTM_Grid( InType )
 
   ; Get the year (after the 3rd "." character
   Ind    = StrWhere( InFileName, '.' )
   Year   = StrMid( InFileName, Ind[2]+1, 4 )
 
   ; TAU0 for this year
   Tau0   = Nymd2Tau( Year*10000L + 0101L )
 
   ; Tracer type
   if ( StrPos( InFileName, 'tot' ) ge 0 ) then Tracer = 1
   if ( StrPos( InFileName, 'liq' ) ge 0 ) then Tracer = 2
   if ( StrPos( InFileName, 'SOx' ) ge 0 ) then Tracer = 3
 
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
                                Tau1=Tau0,              $
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
