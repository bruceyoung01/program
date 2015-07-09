; $Id: ctm_get_datablock.pro,v 1.2 2004/01/29 19:33:36 bmy Exp $
;-------------------------------------------------------------
;+
; NAME:
;        CTM_GET_DATABLOCK
;
; PURPOSE:
;        Extracts a data block from a CTM punch file.
;        (Wrapper program for CTM_GET_DATA and CTM_EXTRACT.)
;
; CATEGORY:
;        CTM_TOOLS
;
; CALLING SEQUENCE:
;        success = CTM_GET_DATABLOCK(DATA [,DiagN] [,keywords])
;
; INPUTS:
;        DIAGN -> A diagnostic number or category name (see
;             (CTM_DIAGINFO). This must uniquely identify a
;             specific data type.  DIAGN is passed to CTM_GET_DATA
;
;
; KEYWORD PARAMETERS:
;     Keywords that are passed to CTM_GET_DATA:
;     =========================================
;        FILENAME   -> Name of the file to open.  FILENAME is passed
;                      to CTM_GET_DATA.  CTM_GET_DATA will return
;                      the full path name, which is then returned
;                      to the calling program.
;
;        USE_FILEINFO -> (optional) If provided, CTM_GET_DATA will 
;             restrict its search to only the files that are
;             contained in USE_FILEINFO which must be a FILEINFO 
;             structure array. Default is to use the global information 
;             (see gamap_cmn.pro).
;             If an undefined named variable is provided in USE_FILEINFO,
;             it will either contain the global FILEINFO structure array 
;             or the FILEINFO record of the specified file.
;             USE_FILEINFO and USE_DATAINFO must be consistent, and should
;             either both be used or omitted. However, it is
;             possible to provide the global FILEINFO structure 
;             (or nothing) with a local subset of DATAINFO.
;
;        USE_DATAINFO -> (optional) Restrict search to records contained
;             in USE_DATAINFO which must be a DATAINFO structure array. 
;             If an undefined named variable is provided in USE_DATAINFO,
;             it will either contain the global DATAINFO structure array 
;             or all DATAINFO records of the specified file.
;             See also USE_FILEINFO.
;
;     Keywords that are passed to CTM_EXTRACT:
;     ========================================
;        AVERAGE -> Bit flag to average over certain dimensions
;             (see CTM_EXTRACT)
;
;        TOTAL -> Bit flag to sum over certain dimensions 
;             (see CTM_EXTRACT)
;
;        /INDEX -> If set, will interpret LAT, LEV, and LON as index 
;             arrays.  If not set, will interpret LAT, LEV, and LON as 
;             ranges (i.e. two-element vectors containing min and max values).
;
;        LAT -> An index array of latitudes *OR* a two-element vector 
;             specifying the min and max latitudes to be included in
;             the extracted data block.  Default is [ -90, 90 ].
;
;        LEV -> An index array of sigma levels *OR* a two-element vector 
;             specifying the min and max sigma levels to be included in
;             the extracted data block.  Default is [ 1, GRIDINFO.LMX ].
;
;        LON -> An index array of longitudes *OR* a two-element vector 
;             specifying the min and max longitudes to be included in
;             the extracted data block.  Default is [ -180, 180 ].
;
;        ALTRANGE -> A vector specifying the min and max altitude
;             values to be included in the extracted data block.
;
;        PRANGE -> A vector specifying the min and max pressure levels 
;             to be included in the extracted data block.
;
;     Other keywords:
;     ===============
;        XMID, YMID, ZMID -> Arrays of values (e.g. latitude,
;             longitude, or altitude) for the 1st, 2nd, and 3rd
;             dimensions of the DATA array, respectively.  
;             NOTE: These are *NOT* index arrays.
;
;        THISDATAINFO -> Returns the DATAINFO structure for the
;             selected data block.
;
;        MODELINFO -> Returns to the calling program the model information 
;             structure created by CTM_TYPE.
;                      
;        GRIDINFO -> Returns to the calling program the grid information  
;             structure created by CTM_GRID.
;
;        WE -> Returns to the calling program the index array of longitudes
;             for the extracted data region, ordered from west to east.
;
;        SN -> Returns to the calling program the index array of latitudes
;             for the extracted data region, ordered from South to North 
; 
;        UP -> Returns to the calling program the index array of vertical
;             levels for the extracted data region, ordered from surface 
;             to top.
;
;        PSURF -> Surface pressure to be used for the conversion from
;             sigma layers to pressure and altitude.  For defaults 
;             see function CTM_TYPE.
;
;       _EXTRA=e -> Picks up any extra keywords for CTM_GET_DATA
;              and CTM_EXTRACT.
; 
; OUTPUTS:
;        DATA -> A 2D or 3D data array
;
; SUBROUTINES:
;        CTM_GET_DATA
;        CTM_GRID (function)
;        CTM_EXTRACT (function)
;
; REQUIREMENTS:
;        Uses GAMAP package subroutines.
;
; NOTES:
;        (1) CTM_GET_DATABLOCK returns the extracted data block as the 
;        function value.
;
;        (2) CTM_GET_DATABLOCK is meant to be called whenever you need
;        to extract data from a punch file.  If the punch file needs
;        to be opened, CTM_GET_DATABLOCK will do that automatically
;        (via CTM_GET_DATA).  
;
; EXAMPLE:
;   FileName  = '~/amalthea/CTM4/run/ctm.pch'
;   Lat       = [  -90,  90 ]
;   Lon       = [ -180, 180 ]
;   Lev       = 1
;   Success   = CTM_Get_DataBlock( Data, 'IJ-AVG-$',                 $
;                           XInd=XMid, YInd=YMid, ZInd=ZMid,         $
;                           Use_FileInfo=FileInfo,                   $
;                           Use_DataInfo=DataInfo,                   $
;                           ThisDataInfo=ThisDataInfo,               $
;                           Tracer=1,           FileName=FileName,   $
;                           GridInfo=GridInfo,  ModelInfo=ModelInfo, $
;                           Lev=Lev,            Lat=Lat,             $
;                           Lon=Lon,            WE=WE,               $
;                           SN=SN,              UP=UP )
;
;   if ( not Success ) then return, 0
;
;            ; gets a data block for the IJ-AVG-$ (ND45) diagnostic,
;            ; for the first tracer, at the first timestep, with the 
;            ; given latitude, longitude, and sigma level ranges.  
;            ; Returns FILEINFO, DATAINFO, THISDATAINFO, WE, SN, UP, 
;            ; XMID, YMID, and ZMID to the calling program.
;
; MODIFICATION HISTORY:
;        bmy, 16 Sep 1998: VERSION 1.00
;        bmy, 17 Sep 1998: - added FILENAME keyword, so that the file
;                            name can be passed back to the calling
;                            program. 
;        bmy, 18 Sep 1998: VERSION 1.01
;                          - now compatible with CTM_EXTRACT v. 1.01
;                          - INDEX, SN, WE, UP keywords added
;                          - LATRANGE, LONRANGE, LEVRANGE renamed
;                            to LAT, LON, LEV (since they may now 
;                            contain arrays and not just ranges).
;        mgs, 21 Sep 1998: VERSION 1.02
;                          - more error checking
;                          - added PSurf keywords
;                          - frees gridinfo pointer before re-assignment
;                          - removed MinData and MaxData
;        bmy, 22 Sep 1998: - Now pass AVERAGE and TOTAL keywords to
;                            CTM_EXTRACT
;        mgs, 22 Sep 1998: - added THISDATAINFO keyword
;        bmy, 24 Sep 1998: - added FORWARD_FUNCTION for CTM_GRID
;                            and CTM_EXTRACT
;        bmy, 08 Oct 1998: VERSION 1.03
;                          - FILEINFO and DATAINFO are now keywords
;                          - now returns X, Y, and Z as parameters
;        bmy, 03 Nov 1998: VERSION 1.04
;                          - compatible with new CTM_GET_DATA routine
;                          - now pass FILEINFO and DATAINFO structures 
;                            via USE_FILEINFO and USE_DATAINFO keywords
;        mgs, 10 Nov 1998: - once more adapted to changes in CTM_GET_DATA
;                          - now extracts locally used FILEINFO structure
;        bmy, 11 Feb 1999: VERSION 1.05
;                          - updated comments
;        bmy, 19 Feb 1999: - Renamed XIND, YIND, ZIND to XMID, YMID,
;                            and ZMID, since these are not index
;                            arrays, but the actual longitude,
;                            latitude, or altitude values for each
;                            dimension of the DATA array.
;                          - added DEBUG keyword
;                          - eliminate obsolete XARR, YARR, ZARR keywords
;                          - added NOPRINT keyword to suppress
;                            call to CTM_PRINT_DATAINFO
;        mgs, 02 Apr 1999: - replace gridinfo in fileinfo only if new
;                            surface pressure is requested. Necessary 
;                            for 2D fields (e.g. EPTOMS)
;                          - deactivated SMALLCHEM flag
;                          - added error checking for FILEINFO
;        bmy, 28 Apr 1999: - return THISFILEINFO as a keyword
;        mgs, 30 Jun 1999: - Specification of PSURF finally works.
;        bmy, 13 Dec 1999: - now use CHKSTRU instead of N_ELEMENTS  
;                            to diagnose undefined GRIDINFO structure
;        bmy, 04 Dec 2000: GAMAP VERSION 1.47
;                          - eliminated obsolete code from 12/31/99
;        bmy, 03 Jun 2001: GAMAP VERSION 1.48
;                          - bug fix: also create GRIDINFO structure
;                            for grids with no vertical layers
;
;-
; Copyright (C) 1998, 1999, 2000, 2001, 
; Bob Yantosca and Martin Schultz, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author to arrange payment.
; Bugs and comments should be directed to bmy@io.harvard.edu
; or mgs@io.harvard.edu with subject "IDL routine ctm_get_datablock"
;-------------------------------------------------------------


function CTM_Get_DataBlock, Data, DiagN,                   $
            XMid=XMid, YMid=YMid, ZMid=ZMid,               $
            Use_FileInfo=Use_FileInfo,                     $
            Use_DataInfo=Use_DataInfo,                     $
            ThisDataInfo=ThisDataInfo,                     $
            ThisFileInfo=ThisFileInfo,                     $
            AltRange=AltRange,    Average=Average,         $
            FileName=FileName,    GridInfo=GridInfo,       $
            Index=Index,          Lat=Lat,                 $ 
            Lev=Lev,              Lon=Lon,                 $
            ModelInfo=ModelInfo,  PRange=PRange,           $
            PSurf=PSurf,                                   $
            SN=SN,                Total=FTotal,            $
            UP=UP,                WE=WE,                   $
            Debug=Debug,          NoPrint=NoPrint,         $
            _EXTRA=e

   ;=====================================================================
   ; Pass external functions
   ;=====================================================================
   FORWARD_FUNCTION CTM_Extract, CTM_Grid

   ;=====================================================================
   ; If DATA contains something delete it
   ; Also set debugging flag
   ;=====================================================================
   if ( N_Elements( Data ) gt 0 ) then Undefine, Data

   Debug = Keyword_Set( Debug )

   ;=====================================================================
   ; Call CTM_GET_DATA to read the punch file and return a 
   ; latitude-longitude-altitude data cube
   ;=====================================================================
   CTM_Get_Data, ThisDataInfo,   DIAGN,                     $
      FileName=FileName,         Index=NewInd,              $
      Use_FileInfo=Use_FileInfo, Use_DataInfo=Use_DataInfo, $ 
      _EXTRA=e 

   ;=====================================================================
   ; Test if any data were retrieved
   ;=====================================================================
   if ( n_elements(ThisDataInfo) eq 0 ) then begin
      Message, 'Sorry...no data found!', /Continue
      return, 0
   endif

   ;=====================================================================
   ; Retrieve data from first record 
   ;
   ; *** This is a limitation in order to facilitate plotting! ***
   ;
   ; NOTE: For multilevel or multitracer diagnostics, this is always 
   ;       a 3D data cube even though the diagnostic in ASCII files 
   ;       was saved in individual levels.
   ;=====================================================================
   if ( N_Elements( NewInd ) gt 1 ) then $
      Message, 'More than 1 data block loaded. Will use first...',/Cont

   ThisDataInfo = ThisDataInfo[0]

   ; If /NOPRINT is not set, then suppress printing 
   ; DATAINFO information back to the user (bmy, 2/19/99)
   if ( not Keyword_Set( NoPrint ) ) then CTM_Print_DataInfo, ThisDataInfo
   
   BigData = *( ThisDataInfo.Data )

   ;====================================================================
   ; Retrieve fileinfo structure associated with ThisDataInfo
   ;====================================================================
   f_ind = where(Use_FileInfo.ilun eq ThisDataInfo.ilun)
   if (f_ind[0] lt 0) then begin
       message,'*** SERIOUS ERROR: Cannot find associated FILEINFO !'
       return, 0
   endif
   if (n_elements(f_ind) gt 1) then begin
       message,'*** SERIOUS ERROR: Cannot uniquely identify FILEINFO !', $
           /Continue
       for i=0,n_elements(f_ind)-1 do help,use_fileinfo[f_ind[i]],/Stru
       return, 0
   endif

   ThisFileInfo = Use_FileInfo[f_ind[0]]

   ;====================================================================
   ; Redefine Modelinfo if a new surface pressure value is given 
   ; Get the MODELINFO and GRIDINFO structures.  
   ; Update the GRIDINFO field in FILEINFO.
   ;====================================================================

   ModelInfo = ThisFileInfo.ModelInfo
   if ( Ptr_Valid( ThisFileInfo.GridInfo ) ) then $
      GridInfo = *(ThisFileInfo.GridInfo)

   if ( N_Elements( PSurf ) eq 1 ) then begin
; print,'#### psurf=',psurf,ThisFileInfo.ModelInfo.PSurf
; help,gridinfo
      if ( ThisFileInfo.ModelInfo.PSurf ne PSurf ) then begin
         ThisFileInfo.ModelInfo.PSurf = PSurf
         Undefine,GridInfo   ; force new computation of grid
      endif
   endif else $
      PSurf = ThisFileInfo.ModelInfo.PSurf

   ;----------------------------------------------------------------------
   ; Prior to 7/2/01:
   ; Bug fix for generic grids with no  vertical layers -- make sure to 
   ; call CTM_GRID with the /NO_VERTICAL keyword, or else CTM_EXTRACT
   ; will choke (bmy, 7/2/01)
   ;if ( not ChkStru( GridInfo, [ 'IMX', 'JMX', 'LMX' ] ) ) then begin
   ;   GridInfo = CTM_Grid( ModelInfo, PSURF=PSurf )
   ; 
   ;   if ( Ptr_Valid( ThisFileInfo.GridInfo ) ) $
   ;      then Ptr_Free, ThisFileInfo.GridInfo
   ; 
   ;   ThisFileInfo.GridInfo = Ptr_New( GridInfo )
   ;endif
   ;----------------------------------------------------------------------

   ; If GRIDINFO is undefined, define it here (bmy, 7/2/01)
   if ( not ChkStru( GridInfo, [ 'IMX', 'JMX' ] ) ) then begin

      ; Define GRIDINFO structure -- CTM_GRID will check to see if 
      ; this structure should be created w/o vertical levels (bmy, 7/3/01)
      GridInfo = CTM_Grid( ModelInfo, PSURF=PSurf )

      if ( Ptr_Valid( ThisFileInfo.GridInfo ) ) $
         then Ptr_Free, ThisFileInfo.GridInfo
    
      ThisFileInfo.GridInfo = Ptr_New( GridInfo )
   endif

   ;=====================================================================
   ; Call CTM_EXTRACT to extract a region from the data block
   ; according to the latitude, longitude, level, altitude, and 
   ; pressure ranges that were passed from the calling program.
   ;=====================================================================
   Data = CTM_Extract( BigData, X, Y, Z,                              $
                       ModelInfo=ModelInfo, GridInfo=GridInfo,        $
                       Average=Average,     AltRange=AltRange,        $
                       Index=Index,         Lat=Lat,                  $
                       Lon=Lon,             Lev=Lev,                  $
                       PRange=PRange,       SN=SN,                    $
                       Total=FTotal,        WE=WE,                    $
                       UP=UP,               First=ThisDataInfo.First, $
                       Debug=Debug )

   XMid = X
   YMid = Y
   ZMid = Z

   ;=====================================================================
   ; Return to calling program 
   ;=====================================================================
   return, 1
 
end
 
