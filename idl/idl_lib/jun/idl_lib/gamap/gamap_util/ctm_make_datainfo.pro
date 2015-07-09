; $Id: ctm_make_datainfo.pro,v 1.3 2008/07/01 14:52:03 bmy Exp $
;------------------------------------------------------------------------
;+
; NAME:
;        CTM_MAKE_DATAINFO (function)
;
; PURPOSE:
;        Create a datainfo and fileinfo structure from an
;        "external" data set so that it can be used seamlessly
;        within the GAMAP package. The dataset can have up to
;        four dimensions (however, only the first 3 are currently
;        supported). The new datainfo and fileinfo structures 
;        will be added to the global structure arrays.
;
; CATEGORY:
;        GAMAP Utilities, GAMAP Data Manipulation, Structures
;
; CALLING SEQUENCE:
;        RESULT = CTM_MAKE_DATAINFO( DATA, DATAINFO, FILEINFO  [,Keywords] )
;
; INPUTS:
;        DATA  -> A 1-D, 2-D, or 3-D data array.
;
; KEYWORD PARAMETERS:
;        DIAGN -> A diagnostics name (category) or number that describes
;               the data type. If not given, the user will be prompted.
;               If DIAGN is a number that is not recognized as valid
;               diagnostics by CTM_DIAGINFO, the number will be stored
;               as string value. If DIAGN is a string, it does not have 
;               to be a valid diagnostics category.
;
;        DIM -> A 4 element vector with the DATA dimensions as
;               LON, LAT, LEVEL, TIME. If not given, the dimensions
;               of DATA will be entered sequentially. Use this keyword
;               to properly identify e.g. a zonal mean data set as
;               DIM = [ 0, 46, 20, 0 ] (for the GEOS-1).
;               The order and magnitude of the dimensions in DIM must
;               agree with the dimensions of the DATA array
;               (e.g. if DATA(72,46) then DIM=[46,72,0,0] is not allowed).
;
;        FILENAME-> Name of the file which is specified by the
;               FILEINFO structure.  If FILENAME is not specified, 
;               then the default FILENAME = "derived data".
;
;        FILETYPE -> A numeric code to identify the file type.  If not
;               specified then the default FILETYPE = -1.
;
;        FIRSTBOX -> A 3 element vector containing IFIRST, JFIRST, and
;               LFIRST, which are the starting indices for the LON,
;               LAT, and LEVEL dimensions.  
;
;        FORMAT -> A format string (for ASCII data) or descriptive
;               string (for binary or self-describing data) that is
;               saved to the DATAINFO structure.  Default is ''.
;
;        GRIDINFO -> A gridinfo structure describing the grid set-up
;               of the data set (see CTM_GRID). If not given, 
;               CTM_MAKE_DATAINFO attempts to use the MODELINFO 
;               structure to construct GRIDINFO.
;
;        ILUN -> The file unit number that will be used to identify 
;               FILEINFO and DATAINFO.  If not passed, then ILUN will
;               be negative to denote derived data, and will increment
;               negatively for each data block, starting at -1. 
;
;        MODELINFO -> A modelinfo structure containing information
;               about the model that generated the data (see CTM_TYPE).
;               If not given, the user is prompted for a selection.
;
;        /NO_GLOBAL -> If passed, will prevent the DATAINFO and FILEINFO
;               structures from being appended to the global GAMAP
;               common blocks.  Useful for saving memory.
;
;        /NO_VERTICAL (passed via _EXTRA) -> set this keyword if you only want
;               to create a 2D gridfinfo structure.
;
;        TAU0, TAU1 -> Beginning and end of time interval that is spanned
;               by DATA (as TAU value). Default is -1 for both.
;
;        TOPTITLE -> A user defined string that may describe the data set
;               in more detail.
;
;        TRACER -> A tracer number or name that identifies the chemical 
;               species or physical quantity contained in DATA. If 
;               TRACER is an invalid name, it will be set to -1, and the
;               string value of TRACER will be used as TRCNAME (see below). 
;               If not given, the user will be prompted.
;
;        TRCNAME -> A tracer name. Default is to use the name associated
;               with that tracer number in CTM_TRACERINFO.
;
;        SCALE -> A value that is entered in the SCALE field in DATAINFO.
;               Default is 1.0.
;
;        UNIT -> A unit string. Default is empty.
;
; OUTPUTS:
;        DATAINFO, FILEINFO -> The datainfo and fileinfo structures
;               generated from the "external" data array. These are 
;               automatically appended to the global DATAINFO and FILEINFO 
;               structures, unless the /NO_GLOBAL keyword is set.
;
; SUBROUTINES:
;        External Subroutines Required:
;        =========================================
;        CREATE3DHSTRU, CREATE3DFSTRU, TAU2YYMMDD
;
; REQUIREMENTS:
;        None
;
; NOTES:
;        In the current version, no error checking is made whether the
;        DATA dimensions agree with the grid information. This is the
;        users responsibility. 
;
; EXAMPLES:
;        (1)
;        DATA   = DIST(72,46)
;        RESULT = CTM_MAKE_DATAINFO( DATA, DATAINFO, FILEINFO )
;
;             ; Create a 2D array and make a DATAINFO structure.
;             ; The user will be prompted for model type, 
;             ; diagnostics and tracer.
;   
;        (2)
;        RESULT = CTM_MAKE_DATAINFO( DATA, DATAINFO, FILEINFO,        $
;            MODEL=CTM_TYPE( 'GEOS1' ), DIAGN='IJ-AVG-$',             $ 
;            TRACER=2, TAU0=NYMD2TAU(940901L), TAU1=NYMD2TAU(940930), $
;            UNIT='PPBV', DIM=[0,46,20,0],                            $
;            TOPTITLE='Zonal mean difference in Ox CLDS/no CLDS')
;
;             ; Add a zonal mean difference data set (already in DATA) 
;
;        (3)
;        HELP, DATAINFO, /STRU
;           ** Structure H3DSTRU, 13 tags, length=72:
;              ILUN            LONG               -15
;              FILEPOS         LONG                 0
;              CATEGORY        STRING    'ZONE-AVG'
;              TRACER          INT              2
;              TRACERNAME      STRING    'Ox'
;              TAU0            DOUBLE           84720.000
;              TAU1            DOUBLE           85416.000
;              SCALE           FLOAT           1.00000
;              UNIT            STRING    'ppbv'
;              FORMAT          STRING    ''
;              STATUS          INT              1
;              DIM             INT       Array[4]
;              OFFSET          INT       Array[3]
;              DATA            POINTER   <PtrHeapVar41>
;
;             ; Display DATAINFO structure
;
; MODIFICATION HISTORY:
;        mgs, 09 Oct 1998: VERSION 1.00
;        mgs, 19 Nov 1998: - bug fix. ILUN now always negative!
;                          - unit now "required" parameter, i.e.
;                            interactively asked for
;        bmy, 11 Feb 1999: VERSION 1.01
;                          - added OFFSET keyword so that I0, J0, and
;                            L0 offsets can be stored in DATAINFO
;                          - DATAINFO.TAU0 and DATAINFO.TAU1 are now
;                            stored as double precision
;                          - updated comments
;        mgs, 16 Mar 1999: - cosmetic changes
;                          - OFFSET changed into FIRSTBOX
;        mgs, 30 Mar 1999: - added _EXTRA keyword for ctm_grid
;                            (use for /NO_VERTICAL)
;        bmy, 29 Jun 2001: GAMAP VERSION 1.48
;                          - bug fix: now pass CTM_TRACERINFO the
;                            tracer number plus diagnostic offset
;        bmy, 06 Mar 2002: GAMAP VERSION 1.50
;                          - now take TRACER mod 100L before 
;                            adding the diagnostic offset to it
;                            in call to CTM_TRACERINFO
;        bmy, 26 Nov 2003: GAMAP VERSION 2.01
;                          - added /NO_GLOBAL keyword
;                          - rewrote for clarity; updated comments
;                          - Now get diagnostic spacing from CTM_DIAGINFO
;                          - added ILUN, FILENAME, FILETYPE keywords
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
;        phs, 30 May 2008: GAMAP VERSION 2.12
;                          - Minor fix to restrict FIRSTBOX to 3 elements
;
;-
; Copyright (C) 1999-2008, Martin Schultz,
; Bob Yantosca and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of 
; this software. If this software shall be used commercially or 
; sold as part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.harvard.edu with subject "IDL routine ctm_make_datainfo"
;----------------------------------------------------------------------


function CTM_Make_DataInfo, Data, DataInfo, FileInfo,                $
                            ModelInfo=ModelInfo, GridInfo=GridInfo,  $
                            DiagN=DiagN,         Tracer=Tracer,      $
                            TrcName=TrcName,     Tau0=Tau0,          $
                            Tau1=Tau1,           Scale=Scale,        $
                            Unit=Unit,           Dim=Dim,            $
                            TopTitle=TopTitle,   FirstBox=FirstBox,  $
                            No_Global=No_Global, FileName=FileName,  $
                            FileType=FileType,   Ilun=Ilun,          $
                            Format=Format,       _EXTRA=e
 
   ;====================================================================
   ; Initialization
   ;====================================================================

   ; GAMAP common blocks
   @gamap_cmn
 
   ; External functions
   FORWARD_FUNCTION Create3dHStru, Create3dFStru, Tau2YYMMDD
 
   ; Result is 1 if sucessful, 0 if unsuccessful.
   ; Set to unsuccessful for safety's sake.
   result = 0
 
   ; Check validity of DATA argument
   if ( N_Elements( Data ) eq 0 ) then begin
      Message, 'No data passed!', /Continue
      return, Result
   endif
 
   ; Create default DATAINFO and FILEINFO return structures
   DataInfo = Create3dHStru()
   FileInfo = Create3dFStru()
 
   ;-------------------------------------------------------------------------
   ; Prior to 11/26/03:
   ;FileInfo.Ilun = ( Min( F.Ilun )  - 1 ) < ( -1 )
   ;DataInfo.Ilun = FileInfo.Ilun
   ; 
   ; filename is always "derived data"
   ;FileInfo.FileName = 'derived data'
   ;FileInfo.FileType = -1
   ;-------------------------------------------------------------------------
   
   ;====================================================================
   ; Save values into fields of FILEINFO and DATAINFO structures
   ; Query user for fields that are not passed as keywords
   ;==================================================================== 

   ;----------------
   ; ILUN
   ;----------------
   if ( N_Elements( Ilun ) eq 0 ) then begin

      ; Get the default value of ILUN from either the GAMAP global
      ; PGLOBALFILEINFO structure (if it exits) or from the FILEINFO
      ; structure we just made
      if ( Ptr_Valid( pGlobalFileInfo ) ) $
         then f = *pGlobalFileInfo        $
         else f = fileinfo

      ; If ILUN is specified, then use that value instead of the default
      Ilun = ( Min( F.Ilun ) - 1 ) < (-1)
   endif

   ; Store in FILEINFO and DATAINFO
   FileInfo.Ilun = Ilun
   DataInfo.Ilun = Ilun

   ;----------------
   ; FILENAME
   ;----------------
   
   ; Default value
   if ( N_Elements( FileName ) eq 0 ) then FileName = 'derived data'
   
   ; Store in FILEINFO
   FileInfo.FileName = FileName

   ;----------------
   ; FILETYPE
   ;----------------

   ; Default value
   if ( N_Elements( FileType ) eq 0 ) then FileType = -1
   
   ; Store in FILEINFO
   FileInfo.FileType = FileType

   ;----------------
   ; FORMAT
   ;----------------

   ; Default value
   if ( N_Elements( Format ) eq 0 ) then Format = ''

   ; Store in FILEINFO
   DataInfo.Format = Format

   ;----------------
   ; MODELINFO
   ;----------------

   ; If MODELINFO is not valid, then prompt user
   if ( not chkstru(modelinfo,['NAME','RESOLUTION']) ) $
      then ModelInfo = Select_Model()

   ; Store MODELINFO in FILEINFO structure
   FileInfo.ModelInfo = ModelInfo

   ;### Debug
   if (DEBUG) then print,'# Modelname and resolution : ', $
      modelinfo.name,modelinfo.resolution,format='(2A,2F6.2)'
 
   ;----------------
   ; GRIDINFO
   ;----------------

   ; If GRIDINFO is not defined, call CTM_GRID
   if ( not ChkStru( GridInfo, ['XEDGE','YEDGE'] ) ) $
      then GridInfo = Ctm_Grid( ModelInfo, _EXTRA=e )

   ; Save as a pointer in FILEINFO
   FileInfo.GridInfo = Ptr_New( GridInfo )
   
   ;----------------
   ; TOPTITLE
   ;----------------

   ; If TOPTITLE is passed, then store it in FILEINFO
   if ( N_Elements( TopTitle ) gt 0 ) $
      then FileInfo.TopTitle = TopTitle[0]
 
   ;----------------
   ; DIAGN
   ;----------------

   ; If DIAGN is not passed, then prompt user
   if ( N_Elements( DiagN ) eq 0 ) then begin
      Diagn = ''
      read,diagn,prompt='Diagnostics (name or number) : '
      if ( min(isdigit(diagn) eq 1) ) then diagn = fix(diagn)
   endif

   ; Return an array of structures for each of the 
   ; category names in the DIAGN variable.
   ctm_diaginfo, diagn, stru

   ; if not a valid diagnostics, use it anyway: pretend it's a string 
   if ( stru.Category eq '' ) then stru.category = strtrim(diagn,2)
   datainfo.category = stru.category

   ; Get the spacing between diagnostic offsets
   ; this value is the same for all categories
   Spacing = Stru[0].Spacing
   
   if (DEBUG) then print,'# Category : ',datainfo.category
 
   ;----------------
   ; TRACER
   ;----------------

   if ( N_Elements( Tracer ) eq 0 ) then begin

      ; If TRACER is not passed, then prompt user
      tracer = ''
      read,tracer,prompt='Tracer (number or name) : '
      if ( min(isdigit(tracer) eq 1) ) then tracer = fix(tracer)

   endif else begin

      ; if tracer is a string and trcname is not provided,
      ; save tracer as trcname
      if (size(tracer,/TYPE) eq 7 AND n_elements(trcname) eq 0) then $
         trcname = tracer

   endelse

   ; Apply the offset to CTM_TRACERINFO so that we pull out
   ; the proper tracer number for this category (bmy, 6/29/01)
   Offset = Stru.offset

   ; Take ( TRACER mod SPACING ) before we add the offset (bmy, 11/19/03)
   ctm_tracerinfo, ( ( Tracer mod Spacing ) + Offset ), stru, index=tracerindex
   datainfo.tracer = tracerindex
 
   ;----------------
   ; TRCNAME
   ;----------------

   if (n_elements(trcname) eq 0) then trcname = stru.name
   datainfo.tracername = trcname ; will be '' if unknown tracer
   if (DEBUG) then print,'# Tracer : ',datainfo.tracername, $
      datainfo.tracer,format='(2A,3X,I4)'
   
   ;----------------
   ; TAU0 and TAU1
   ;----------------

   if (n_elements(tau0) eq 0) then tau0 = -1D
   datainfo.tau0 = tau0
 
   if (n_elements(tau1) eq 0) then tau1 = -1D
   datainfo.tau1 = tau1
   if (DEBUG) then print,'# Time range : ',   $
                          tau0,(tau2yymmdd(tau0,/NFORMAT,/SHORT))[0], $
                          tau1,(tau2yymmdd(tau1,/NFORMAT,/SHORT))[0], $
                          format='(A,3X,2(F10.2," (=",I8,")  "))'
 
   ;----------------
   ; SCALE
   ;----------------

   if (n_elements(scale) eq 0) then scale = 1.0
   datainfo.scale = scale
 
   ;----------------
   ; UNIT
   ;----------------

   if (n_elements(unit) eq 0) then begin
      unit = ''
      read,unit,prompt='Unit : '
      unit = strtrim(unit,2)
      if (unit eq '') then unit = 'UNDEFINED'
   endif
   datainfo.unit = unit

   ;----------------
   ; STATUS
   ;----------------

   datainfo.status = 1          ; since we pass data it is always "read"
 
   ;----------------
   ; DIM
   ;----------------

   if (n_elements(dim) ne 4) then begin
      dim = size(data,/dimensions)
      while (n_elements(dim) lt 4) do dim = [ dim, 0 ]
   endif
   datainfo.dim = ( dim > 1 )
     
   ;----------------
   ; FIRSTBOX
   ;----------------

   if ( N_Elements( FIRSTBOX ) ne 3 ) then $
     FIRSTBOX = intarr(3)+1      ; all entries to 1

;   if ( N_Elements( FIRSTBOX ) ne 3 ) then begin
;      FIRSTBOX = intarr(3)      ; three zero entries
;      sd = Size( Data, /N_Dim)  ; set valid entries to 1
;;--prior to 5/29/08 - phs
;;      FIRSTBOX[0:sd < 3] = 1
;      FIRSTBOX[0:(sd-1) < 2] = 1
;   endif

   DataInfo.First = FIRSTBOX

   ;====================================================================
   ; Make sure data dimensions agree with dim dimensions somehow !!
   ; be strict in the sense that the order of dimensions must be 
   ; the same
   ;====================================================================
   datadim = size(data,/dimensions)
   if (DEBUG) then print,'# DATA Dimensions : ',datadim,format='(A,4X,9I5)'
   if (DEBUG) then print,'# DIM Field : ',dim,format='(A,10X,4I5)'
   if (DEBUG) then print,'# FIRSTBOX Field : ', FIRSTBOX, Format='(A,10X,3I5)'
 
   if (n_elements(datadim) gt 4) then begin
      message,'Data has too many dimensions!',/Cont
      return,result
   endif
   j = 0
   for i=0,n_elements(datadim)-1 do begin
      while (j lt 4 AND datadim[i] ne dim[j]) do begin
         j = j+1
         if (j eq 4) then begin
            message,'Dimensions of DATA and DIM do not match!',/Cont
            return,result
         endif
      endwhile
   endfor
   
   ; Add data 
   DataInfo.Data = Ptr_New( Data )
   
   Result = 1
 
   ;====================================================================
   ; If everything went OK, we can now append the new structures
   ; to the global ones.  Don't do this if /NO_GLOBAL is set.
   ;====================================================================
   if ( not Keyword_Set( No_Global ) ) then begin

      ; Either append to or create the *pGlobalFileInfo structure
      if ( Ptr_Valid( pGlobalFileInfo ) )                       $
         then *pGlobalFileInfo = [ *pGlobalFileInfo, fileinfo ] $
         else  pGlobalFileInfo = ptr_new(fileinfo)
 
      ; Either append to or create the *pGlobalDataInfo structure
      if ( Ptr_Valid( pGlobalDataInfo ) )                       $
         then *pGlobalDataInfo = [ *pGlobalDataInfo, datainfo ] $
         else  pGlobalDataInfo = ptr_new(datainfo)

   endif
 
   ; Return success/failure flag to calling program
   return, Result
end
 
