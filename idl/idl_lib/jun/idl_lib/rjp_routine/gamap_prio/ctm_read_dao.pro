; $Id: ctm_read_dao.pro,v 1.50 2002/05/24 14:03:52 bmy v150 $
;-----------------------------------------------------------------------
;+
; NAME:
;        CTM_READ_DAO
;
; PURPOSE:
;        Reads DAO I-6,(instantaneous 6h), A-6 (average 6h),
;        or A-3 (average 3-h) met field files, and constructs
;        a DATAINFO structure for each met field.
;
; CATEGORY:
;        GAMAP 
;
; CALLING SEQUENCE:
;        Result = CTM_READ_DAO( Ilun, FileInfo, DataInfo [, Keywords ] )
;
; INPUTS:
;        ILUN --> The name of the input file (or a file mask).
;             FILENAME is passed to OPEN_FILE.  If FILENAME is a null 
;             string or a file mask, then OPEN_FILE will open a
;             pickfile dialog box.
;
;        FILEINFO --> a (single) fileinfo structure containing information
;             about the (open) file (see CREATE3DFSTRU). FILEINFO also
;             contains information about the model which generated
;             the output (see CTM_TYPE)
;
;        DATAINFO --> a named variable that will contain an array of
;             structures describing the file content (see
;             CREATE3DHSTRU)
;
; KEYWORD PARAMETERS:
;        PRINT  -> if activated, print all headers found in the file
;
; OUTPUTS:
;        The function returns 1 if successful, and 0 otherwise. 
;
;        FILEINFO --> toptitle and modelinfo tags will be set
;
;        DATAINFO --> contains an array of named structures 
;             (see CREATE3DHSTRU) with all relevant information
;             from the punch file header and what is needed to find
;             and load the data.
;
; SUBROUTINES:
;        External Subroutines Required:
;        ================================================
;        CHKSTRU  (function)     CTM_GRID      (function)
;        CTM_TYPE (function)     CREATE3DHSTRU (function)
;        
;
; REQUIREMENTS:
;        References routines from both GAMAP and TOOLS packages.
;
; NOTES:
;        (1) You must also add additional met field names to routine
;        "ctm_read_dao" as is necessary.  The DAO met field files do 
;        not carry tracer numbers, so the name of each met field must
;        be checked in "ctm_read_dao" before a corresponding DATAINFO
;        structure can be assigned.;
;
;        (2) In routine "ctm_open_file", you must add addtional met
;        field names to the FIELDNAMES array in internal function
;        "test_for_dao".  The first met field name in a file is tested 
;        against FIELDNAMES.  If there is a match, then the file is 
;        declared to be a DAO met field file, and it is assigned a
;        file type of 4.
;
;=============================================================================
;   Description of data fields:
;
;   I-6 Fields: Instantaneous 6-h "snapshots"
;   -------------------------------------------------------------------------
;   (1 ) ALBD     : DAO 2-D surface albedo field                [unitless]
;   (2 ) ALBVISDF : DAO diffuse visible albedo                  [unitless]
;   (3 ) ALBVISDF : DAO diffuse IR albedo                       [unitless]
;   (4 ) ALBEDO   : DAO direct albedo (GEOS-3)                  [unitless]
;   (5 ) LWI      : DAO 2-D land/water indices field            [unitless]
;   (6 ) PHIS     : DAO 2-D surface geopotential heights        [m2/s2]
;   (7 ) PS       : DAO 2-D surface pressure field              [hPa]
;   (8 ) SLP      : DAO 2-D V-wind field                        [hPa]
;   (9 ) SURFTYPE : Alternate name for LWI (for GEOS-3) 
;   (10) SPHU     : DAO 3-D specific humidity field             [g H20/kg air]
;   (11) TMPU     : DAO 3-D temperature field                   [K]
;   (12) TROPP    : DAO tropopause pressure field               [hPa]
;   (13) UWND     : DAO 3-D U-wind field                        [m/s]
;   (14) VWND     : DAO 3-D V-wind field                        [m/s]
;   (15) TKE      : DAO 3-D turbulent kinetic energy field      [m2/s2]
;   (16) RH       : DAO 3-D relative humidity field             [%]
;   (17) DELP     : fvDAS 3-D pressure thickness field          [hPa]
;
;   A-6 Fields: 6-hour averages
;   --------------------------------------------------------------------------
;   (1 ) CLDMAS   : DAO cloud mass flux field                   [unitless]
;   (2 ) CLDTOT   : DAO total cloud fraction (GEOS-2, GEOS-3)   [unitless]
;   (3 ) CLMOLW   : DAO max overlap cloud fraction (GEOS-1)     [unitless]
;   (4 ) CLROLW   : DAO random overlap cloud frac (GEOS-1)      [unitless]
;   (5 ) DTRAIN   : DAO cloud detrainment field                 [unitless]
;   (6 ) MOISTQ   : DAO field for tendency in SPHU              [kg H2O/
;                                                                kg air/s]
;   (7 ) TAUCLD   : DAO in-cloud optical depth (GEOS-3)         [unitless]
;   (8 ) OPTDEPTH : DAO grid box optical depth (GEOS-3)         [unitless]
;   (9 ) KH       : DAO eddy diffusion coefficient field        [m2/s]
; 
;   A-3 fields: 3-hour averages
;   --------------------------------------------------------------------------
;   (1 ) CLDFRC   : DAO 2-D cloud fraction                      [unitless]
;   (2 ) HFLUX    : DAO 2-D sensible heat flux field            [W/m2]
;   (3 ) PBL      : DAO 2-D planetary boundary layer depth      [hPa]
;   (4 ) PREACC   : DAO 2-D accum. precip. field @ ground       [mm/day]
;   (5 ) PRECON   : DAO 2-D conv.  precip. field @ ground       [mm/day]
;   (6 ) RADSWG   : DAO 2-D solar insolation field @ ground     [W/m2]
;   (7 ) RADSWT   : DAO 2-D solar insolation @ atm. top         [W/m2]
;   (8 ) TS       : DAO 2-D surface air temperature             [K]
;   (9 ) TGROUND  : DAO 2-D ground temperature (SST over seas)  [K]
;   (10) T2M      : DAO 2-D temperature at 2 m altitude         [K]
;   (11) U10M     : DAO 2-D U-wind speed at 10 m altitude       [m/s]
;   (12) USTAR    : DAO 2-D friction velocity                   [m/s]
;   (13) V10M     : DAO 2-D V-wind speed at 10 m altitude       [m/s]
;   (14) Z0       : DAO 2-D surface roughness height            [m]
;   (15) TPW      : DAO 2-D total precipitable water            [g/cm2]
;   (16) CLDTMP   : DAO 2-D cloud top temperature               [K]
;   (17) GWET     : DAO 2-D soil wetness                        [unitless]
;   (18) GWETTOP  : fvDAS 2-D topsoil wetness                   [unitless]
;
;  ADDITIONAL NOTES:
;  (1) The I-6 fields are either INSTANTANEOUS 2-D or INSTANTANEOUS 3-D 
;      fields.  They are saved on times 00, 06, 12, and 18h GMT.  In other 
;      words, PS at 06 is the instantaneous value of PS at 6h, etc, etc.
;
;  (2) All of the A-6 fields are AVERAGE 3-D fields.  They are centered 
;      on times 00, 06, 12, and 18h GMT.  In other words, MOISTQ at 06h 
;      contains the average value of MOISTQ from 03h to 09h, etc, etc. 
;
;  (3) All of the A-3 fields are AVERAGE 2-D surface fields.  They are ended 
;      on times 00, 03, 06, 09, 12, 15, 18, and 21h GMT.  In other words, 
;      HFLUX at 3h contains the average HFLUX values from 00-03h GMT.
;
;  (4) GEOS-STRAT has no A-3 fields.  Several of the surface fields
;      that are A-3 in GEOS-1 are A-6 in GEOS-STRAT.
;=============================================================================
;
; EXAMPLES:
;        FileInfo = CREATE3DFSTRU()   ; not required !
;        FName    = '/r/amalthea/N/scratch/bmy/960101.a3.4x5'
;        OPEN_FILE, FName, Ilun, /F77_Unformatted   
;        if ( Ilun gt 0 ) $
;            then Result = CTM_READ_DAO( Ilun, FileInfo, DataInfo )
;        print,result
;
; MODIFICATION HISTORY:
;        bmy, 16 May 2000: GAMAP VERSION 1.45
;                          - adapted from original program "read_dao"
;        bmy, 12 Jun 2000: - declare XYMD and XHMS as integers for
;                            GEOS-2 and GEOS-3 data
;        bmy, 28 Jul 2000: GAMAP VERSION 1.46
;                          - added GEOS-3 names to list of recognized fields
;                          - deleted a couple of field names we don't use 
;        bmy, 25 Sep 2000: - added new field: SLP (sea level pressure)
;        bmy, 08 Dec 2000: GAMAP VERSION 1.47
;                          - added new fields: TKE, RH, KH
;        bmy, 07 Mar 2001: - added new fields: CLDTMP, TPW
;        bmy, 25 Apr 2001: - added new fields: TAULOW, TAUMID, TAUHI
;        bmy, 26 Jul 2001: GAMAP VERSION 1.48
;                          - added new field: T2M
;        bmy, 15 Aug 2001: - added new field: OPTDEPTH
;        bmy, 06 Nov 2001: GAMAP VERSION 1.49
;                          - added new field: DELP
;                          - changed units from "mb" to "hPa"
;        bmy, 29 Jan 2002: GAMAP VERSION 1.50
;                          - added new field: GWET
;                          - removed obsolete code from 11/6/01
;        bmy, 01 May 2002: - added GWETTOP as synonym for GWET
;                          - now assign correct units for fvDAS/GEOS-4
;                            CLDMAS and DTRAIN fields: kg/m2/s
;                          - now assign correct units for fvDAS/GEOS-4
;                            PBL field: m (instead of hPa)
;
;-
; Copyright (C) 2000, 2001, 2002, Bob Yantosca, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author to arrange payment.
; Bugs and comments should be directed to bmy@io.harvard.edu
; or bmy@io.harvard.edu with subject "IDL routine ctm_read_dao"
;-----------------------------------------------------------------------


function CTM_Read_DAO, Ilun, FileInfo, DataInfo, Print=PPrint

   ;==================================================================== 
   ; Pass external functions and variable settings
   ;==================================================================== 
   FORWARD_FUNCTION ChkStru, CTM_Type, CTM_Grid, Create3DHStru

   ; Note: assume that Met field files have less than 512 entries,
   ; this is a pretty safe assumption (bmy, 4/7/00)
   Struc  = Create3DHStru( 512 )
   PPrint = Keyword_Set( PPrint )

   ;==================================================================== 
   ; Place file pointer at top of the file before reading data
   ;==================================================================== 
   Point_Lun, Ilun, 0L
   
   ;==================================================================== 
   ; retrieve punch file name
   ;==================================================================== 
   if ( ChkStru( FileInfo, 'filename' ) )     $
      then ThisFileName = FileInfo.FileName   $
      else ThisFileName = '<UNKNOWN FILE>'
   
   ;==================================================================== 
   ; Make sure that the file type is correct.
   ;==================================================================== 
   if ( ChkStru( FileInfo, 'filetype' ) ) $
      then FileType = FileInfo.FileType   $
      else FileType = 99                  ; unknown -- will default to 2

   ;### Debug output
   if ( PPrint ) $
      then print,'Reading header from ',thisfilename,', filetype ',filetype

   if ( FileType ne 4 ) then begin
      Message,'WARNING!! Filetype is not a DAO met field file!', /Continue
      return, -1L
   endif

   ;==================================================================== 
   ; Compute model & grid type -- call SELECT_MODEL
   ; DAO met field files do not carry model information
   ; Store model & grid type in the FILEINFO structure
   ;==================================================================== 
   ModelInfo = Select_Model( Default='GEOS1 4x5 (20L)' )
   GridInfo  = CTM_Grid( ModelInfo )

   FileInfo.ModelInfo = ModelInfo 

   if ( ptr_valid( FileInfo.GridInfo ) ) then ptr_free, fileinfo.gridinfo
   FileInfo.GridInfo = Ptr_New( GridInfo )

   ;==================================================================== 
   ; Define necessary parameters
   ;==================================================================== 
   Name = BytArr( 8 )           ; FORTRAN CHARACTER*8 variable
   NI   = Long( GridInfo.IMX )  ; number of longitude boxes   (2x2.5 = 144)
   NJ   = Long( GridInfo.JMX )  ; number of latitude boxes    (2x2.5 =  91)
   N    = 0L                    ; data block counter 

   ; For GEOS-2 or GEOS-3, XYMD (YYYYMMDD) and XHMS (HHMMSS) are longwords
   ; Otherwise, they need to be declared floating-point (bmy, 6/12/00)
   S = StrUpCase( StrTrim( ModelInfo.NAME, 2 ) ) 

   if ( S eq 'GEOS1' or S eq 'GEOS_STRAT' ) then begin
      XYMD = 0.0                 
      XHMS = 0.0 
   endif else begin
      XYMD = 0L                 
      XHMS = 0L 
   endelse

   ;==================================================================== 
   ; Read through all of the fields in the file
   ;==================================================================== 
   while ( not EOF( Ilun ) ) do begin
      Readu, Ilun, Name
      StrName = StrUpCase( StrCompress( Name, /Remove_All ) )
 
      if ( PPrint ) then print,'read in label : ',strname
      
      ; STRNAME will be in uppercase, as read in from the file...
      case ( StrName ) of

         ;==============================================================
         ; DAO 2-D fields
         ; Use POINT_LUN to compute the file pointer position
         ; Set NL = 1, since these are only 2-D fields
         ;==============================================================
         'HFLUX' : begin
            Category = 'DAO-FLDS'
            Tracer   = 1L
            Unit     = 'W/m2'
            NL       = 1L
            Data     = FltArr( NI, NJ )

            Point_Lun, -Ilun, Newpos
            ReadU, Ilun, XYMD, XHMS, Data
         end

         'RADSWG' : begin
            Category = 'DAO-FLDS'
            Tracer   = 2L
            Unit     = 'W/m2'
            NL       = 1L
            Data     = FltArr( NI, NJ )

            Point_Lun, -Ilun, Newpos
            ReadU, Ilun, XYMD, XHMS, Data
         end
 
         'PREACC' : begin
            Category = 'DAO-FLDS'
            Tracer   = 3L
            Unit     = 'mm/day'
            NL       = 1L
            Data     = FltArr( NI, NJ )         

            Point_Lun, -Ilun, Newpos
            ReadU, Ilun, XYMD, XHMS, Data
         end
 
         'PRECON' : begin
            Category = 'DAO-FLDS'
            Tracer   = 4L
            Unit     = 'mm/day'
            NL       = 1L
            Data     = FltArr( NI, NJ )

            Point_Lun, -Ilun, Newpos
            ReadU, Ilun, XYMD, XHMS, Data
         end
 
         'TS' : begin
            Category = 'DAO-FLDS'
            Tracer   = 5L
            Unit     = 'K'
            NL       = 1L
            Data     = FltArr( NI, NJ )

            Point_Lun, -Ilun, Newpos
            ReadU, Ilun, XYMD, XHMS, Data
         end
 
         ; TGROUND is the GEOS-3 equivalent of TS (bmy, 7/28/00)
         'TGROUND' : begin
            Category = 'DAO-FLDS'
            Tracer   = 5L
            Unit     = 'K'
            NL       = 1L
            Data     = FltArr( NI, NJ )

            Point_Lun, -Ilun, Newpos
            ReadU, Ilun, XYMD, XHMS, Data
         end

         ; T2M is used in GEOS-3 as the equivalent of TS (bmy, 7/26/01)
         'T2M' : begin
            Category = 'DAO-FLDS'
            Tracer   = 5L
            Unit     = 'K'
            NL       = 1L
            Data     = FltArr( NI, NJ )

            Point_Lun, -Ilun, Newpos
            ReadU, Ilun, XYMD, XHMS, Data
         end

         'RADSWT' : begin
            Category = 'DAO-FLDS'
            Tracer   = 6L
            Unit     = 'W/m2'
            NL       = 1L
            Data     = FltArr( NI, NJ )

            Point_Lun, -Ilun, Newpos
            ReadU, Ilun, XYMD, XHMS, Data
         end
 
         'USTAR' : begin
            Category = 'DAO-FLDS'
            Tracer   = 7L
            Unit     = 'm/s'
            NL       = 1L
            Data     = FltArr( NI, NJ )

            Point_Lun, -Ilun, Newpos
            ReadU, Ilun, XYMD, XHMS, Data
         end
 
         'Z0' : begin
            Category = 'DAO-FLDS'
            Tracer   = 8L
            Unit     = 'm'
            NL       = 1L
            Data     = FltArr( NI, NJ )

            Point_Lun, -Ilun, Newpos
            ReadU, Ilun, XYMD, XHMS, Data
         end
 
         'PBL' : begin
            Category = 'DAO-FLDS'
            Tracer   = 9L
            ;-----------------------------
            ; Prior to 5/1/02:
            ;Unit     = 'hPa'
            ;-----------------------------
            NL       = 1L
            Data     = FltArr(NI,NJ)

            ; GEOS-4 is in [m], others are [hPa] (bmy, 5/1/02) 
            if ( ModelInfo.Name eq 'GEOS4' ) $
               then Unit = 'm'               $
               else Unit = 'hPa'

            Point_Lun, -Ilun, Newpos
            ReadU, Ilun, XYMD, XHMS, Data
         end
 
         'CLDFRC' : begin
            Category = 'DAO-FLDS'
            Tracer   = 10L
            Unit     = 'unitless'
            NL       = 1L
            Data     = FltArr( NI, NJ )

            Point_Lun, -Ilun, Newpos
            ReadU, Ilun, XYMD, XHMS, Data
         end

         'U10M' : begin
            Category = 'DAO-FLDS'
            Tracer   = 11L
            Unit     = 'm/s'
            NL       = 1L
            Data     = FltArr( NI, NJ )

            Point_Lun, -Ilun, Newpos
            ReadU, Ilun, XYMD, XHMS, Data
         end

         'V10M' : begin
            Category = 'DAO-FLDS'
            Tracer   = 12L
            Unit     = 'm/s' 
            NL       = 1L
            Data     = FltArr( NI, NJ )

            Point_Lun, -Ilun, Newpos
            ReadU, Ilun, XYMD, XHMS, Data
         end

         'ALBD' : begin
            Category = 'DAO-FLDS'
            Tracer   = 14L
            Unit     = 'unitless'
            NL       = 1L
            Data     = FltArr( NI, NJ )

            Point_Lun, -Ilun, Newpos
            ReadU, Ilun, XYMD, XHMS, Data
         end

         ; ALBVISDR the equivalent of ALBD for GEOS-2 data (bmy, 7/28/00)
         'ALBVISDF' : begin
            Category = 'DAO-FLDS'
            Tracer   = 14L
            Unit     = 'unitless'
            NL       = 1L
            Data     = FltArr( NI, NJ )

            Point_Lun, -Ilun, Newpos
            ReadU, Ilun, XYMD, XHMS, Data
         end

         ; ALBVISDR the equivalent of ALBD for GEOS-3 data (bmy, 7/28/00)
         'ALBEDO' : begin
            Category = 'DAO-FLDS'
            Tracer   = 14L
            Unit     = 'unitless'
            NL       = 1L
            Data     = FltArr( NI, NJ )

            Point_Lun, -Ilun, Newpos
            ReadU, Ilun, XYMD, XHMS, Data
         end

         'PHIS' : begin
            Category = 'DAO-FLDS'
            Tracer   = 15L
            Unit     = 'm2/s2'
            NL       = 1L
            Data     = FltArr( NI, NJ )

            Point_Lun, -Ilun, Newpos
            ReadU, Ilun, XYMD, XHMS, Data
         end

         'PS' : begin
            Category = 'DAO-FLDS'
            Tracer   = 17L
            Unit     = 'hPa'
            NL       = 1L
            Data     = FltArr( NI, NJ )

            Point_Lun, -Ilun, Newpos
            ReadU, Ilun, XYMD, XHMS, Data
         end

         'LWI' : begin
            Category = 'DAO-FLDS'
            Tracer   = 18L
            Unit     = 'unitless'
            NL       = 1L
            Data     = FltArr( NI, NJ )

            Point_Lun, -Ilun, Newpos
            ReadU, Ilun, XYMD, XHMS, Data
         end

         ; SURFTYPE is the equivalent of LWI for GEOS-3 data (bmy, 7/28/00)
         'SURFTYPE' : begin
            Category = 'DAO-FLDS'
            Tracer   = 18L
            Unit     = 'unitless'
            NL       = 1L
            Data     = FltArr( NI, NJ )

            Point_Lun, -Ilun, Newpos
            ReadU, Ilun, XYMD, XHMS, Data
         end

         'TROPP' : begin
            Category = 'DAO-FLDS'
            Tracer   = 19L
            Unit     = 'hPa' 
            NL       = 1L
            Data     = FltArr( NI, NJ )

            Point_Lun, -Ilun, Newpos
            ReadU, Ilun, XYMD, XHMS, Data
         end

         ; Added sea level pressure (bmy, 9/25/00)
         'SLP' : begin
            Category = 'DAO-FLDS'
            Tracer   = 21L
            Unit     = 'hPa'
            NL       = 1L
            Data     = FltArr( NI, NJ )

            Point_Lun, -Ilun, Newpos
            ReadU, Ilun, XYMD, XHMS, Data
         end

         ; Added cloud top temperature (bmy, 3/7/01)
         'CLDTMP' : begin
            Category = 'DAO-FLDS'
            Tracer   = 22L
            Unit     = 'K'
            NL       = 1L
            Data     = FltArr( NI, NJ )

            Point_Lun, -Ilun, Newpos
            ReadU, Ilun, XYMD, XHMS, Data
         end

         ; Added total precipitable water (bmy, 3/7/01)
         'TPW' : begin
            Category = 'DAO-FLDS'
            Tracer   = 23L
            Unit     = 'g/cm2'
            NL       = 1L
            Data     = FltArr( NI, NJ )

            Point_Lun, -Ilun, Newpos
            ReadU, Ilun, XYMD, XHMS, Data
         end

         ; Added TAULOW (bmy, 4/25/01)
         'TAULOW' : begin
            Category = 'DAO-FLDS'
            Tracer   = 24L
            Unit     = 'unitless'
            NL       = 1L
            Data     = FltArr( NI, NJ )

            Point_Lun, -Ilun, Newpos
            ReadU, Ilun, XYMD, XHMS, Data
         end

         ; Added TAULOW (bmy, 4/25/01)
         'TAUMID' : begin
            Category = 'DAO-FLDS'
            Tracer   = 25L
            Unit     = 'unitless'
            NL       = 1L
            Data     = FltArr( NI, NJ )

            Point_Lun, -Ilun, Newpos
            ReadU, Ilun, XYMD, XHMS, Data
         end

         ; Added TAUHI (bmy, 4/25/01)
         'TAUHI' : begin
            Category = 'DAO-FLDS'
            Tracer   = 26L
            Unit     = 'unitless'
            NL       = 1L
            Data     = FltArr( NI, NJ )

            Point_Lun, -Ilun, Newpos
            ReadU, Ilun, XYMD, XHMS, Data
         end

         ; Added GWET (bmy, 1/29/02)
         'GWET' : begin
            Category = 'DAO-FLDS'
            Tracer   = 27L
            Unit     = 'unitless'
            NL       = 1L
            Data     = FltArr( NI, NJ )

            Point_Lun, -Ilun, Newpos
            ReadU, Ilun, XYMD, XHMS, Data
         end

         ; Added GWETTOP -- for fvDAS (bmy, 5/1/02)
         'GWETTOP' : begin
            Category = 'DAO-FLDS'
            Tracer   = 27L
            Unit     = 'unitless'
            NL       = 1L
            Data     = FltArr( NI, NJ )

            Point_Lun, -Ilun, Newpos
            ReadU, Ilun, XYMD, XHMS, Data
         end

         ;==============================================================
         ; DAO 3-D fields 
         ; Use POINT_LUN to compute the file pointer position
         ; Set NL = GRIDINFO.LMX, since these are only 3-D fields
         ;==============================================================
         'UWND' : begin
            Category = 'DAO-3D-$'
            Tracer   = 1L
            Unit     = 'm/s'
            NL       = Long( GridInfo.LMX )
            Data     = FltArr( NI, NJ, NL )

            Point_Lun, -Ilun, Newpos
            ReadU, Ilun, XYMD, XHMS, Data
         end

         'VWND' : begin
            Category = 'DAO-3D-$'
            Tracer   = 2L
            Unit     = 'm/s'
            NL       = Long( GridInfo.LMX )
            Data     = FltArr(NI, NJ, NL)

            Point_Lun, -Ilun, Newpos
            ReadU, Ilun, XYMD, XHMS, Data
         end

         'TMPU' : begin
            Category = 'DAO-3D-$'
            Tracer   = 3L
            Unit     = 'K'
            NL       = Long( GridInfo.LMX )
            Data     = FltArr( NI, NJ, NL )

            Point_Lun, -Ilun, Newpos
            ReadU, Ilun, XYMD, XHMS, Data
         end

         'SPHU' : begin
            Category = 'DAO-3D-$'
            Tracer   = 4L
            Unit     = 'g/kg'
            NL       = Long( GridInfo.LMX  )
            Data     = FltArr( NI, NJ, NL )

            Point_Lun, -Ilun, Newpos
            ReadU, Ilun, XYMD, XHMS, Data
         end
         
         'KZZ' : begin
            Category = 'DAO-3D-$'
            Tracer   = 5L
            Unit     = ''
            NL       = Long( GridInfo.LMX  )
            Data     = FltArr( NI, NJ, NL )

            Point_Lun, -Ilun, Newpos
            ReadU, Ilun, XYMD, XHMS, Data
         end
         
         'MOISTQ' : begin
            Category = 'DAO-3D-$'
            Tracer   = 6L
            Unit     = 'g/kg/day'
            NL       = Long( GridInfo.LMX) 
            Data     = FltArr(NI,NJ,NL)

            Point_Lun, -Ilun, Newpos
            ReadU, Ilun, XYMD, XHMS, Data
         end
 
         'CLDMAS' : begin
            Category = 'DAO-3D-$'
            Tracer   = 7L
            ;---------------------------------
            ; Prior to 5/1/02:
            ;Unit     = 'kg/m2/600s'
            ;---------------------------------
            NL       = Long( GridInfo.LMX )
            Data     = FltArr( NI, NJ, NL )

            ; GEOS-4 is in kg/m2/s, others are kg/m2/600s (bmy, 5/1/02) 
            if ( ModelInfo.Name eq 'GEOS4' ) $
               then Unit = 'kg/m2/s'         $
               else Unit = 'kg/m2/600s'

            Point_Lun, -Ilun, Newpos
            ReadU, Ilun, XYMD, XHMS, Data
         end
 
         'DTRAIN' : begin
            Category = 'DAO-3D-$'
            Tracer   = 8L
            ;---------------------------------
            ; Prior to 5/1/02:
            ;Unit     = 'kg/m2/600s'
            ;---------------------------------
            NL       = Long( GridInfo.LMX )
            Data     = FltArr( NI, NJ, NL )

            ; GEOS-4 is in kg/m2/s, others are kg/m2/600s (bmy, 5/1/02) 
            if ( ModelInfo.Name eq 'GEOS4' ) $
               then Unit = 'kg/m2/s'         $
               else Unit = 'kg/m2/600s'

            Point_Lun, -Ilun, Newpos
            ReadU, Ilun, XYMD, XHMS, Data
         end
 
         'CLMOLW' : begin
            Category = 'DAO-3D-$'
            Tracer   = 9L
            Unit     = 'unitless'
            NL       = Long( GridInfo.LMX )
            Data     = FltArr( NI, NJ, NL )

            Point_Lun, -Ilun, Newpos
            ReadU, Ilun, XYMD, XHMS, Data
         end
 
         'CLROLW' : begin
            Category = 'DAO-3D-$'
            Tracer   = 10L
            Unit     = 'unitless'
            NL       = Long( GridInfo.LMX )
            Data     = FltArr( NI, NJ, NL )

            Point_Lun, -Ilun, Newpos
            ReadU, Ilun, XYMD, XHMS, Data
         end
 
         'RH' : begin
            Category = 'DAO-3D-$'
            Tracer   = 11L
            Unit     = '%'
            NL       = Long( GridInfo.LMX )
            Data     = FltArr( NI, NJ, NL )

            Point_Lun, -Ilun, Newpos
            ReadU, Ilun, XYMD, XHMS, Data
         end

         'TAUCLD' : begin
            Category = 'DAO-3D-$'
            Tracer   = 12L
            Unit     = 'unitless'
            NL       = Long( GridInfo.LMX )
            Data     = FltArr( NI, NJ, NL )

            Point_Lun, -Ilun, Newpos
            ReadU, Ilun, XYMD, XHMS, Data
         end

         ; Added OPTDEPTH field as tracer #13 (bmy, 8/15/01)
         'OPTDEPTH' : begin
            Category = 'DAO-3D-$'
            Tracer   = 13L
            Unit     = 'unitless'
            NL       = Long( GridInfo.LMX )
            Data     = FltArr( NI, NJ, NL )

            Point_Lun, -Ilun, Newpos
            ReadU, Ilun, XYMD, XHMS, Data
         end

         'CLDTOT' : begin
            Category = 'DAO-3D-$'
            Tracer   = 14L
            Unit     = 'unitless'
            NL       = Long( GridInfo.LMX )
            Data     = FltArr( NI, NJ, NL )

            Point_Lun, -Ilun, Newpos
            ReadU, Ilun, XYMD, XHMS, Data
         end

         'TKE' : begin
            Category = 'DAO-3D-$'
            Tracer   = 15L
            Unit     = 'unitless'
            NL       = Long( GridInfo.LMX )
            Data     = FltArr( NI, NJ, NL )

            Point_Lun, -Ilun, Newpos
            ReadU, Ilun, XYMD, XHMS, Data
         end

         'KH' : begin
            Category = 'DAO-3D-$'
            Tracer   = 16L
            Unit     = 'unitless'
            NL       = Long( GridInfo.LMX )
            Data     = FltArr( NI, NJ, NL )

            Point_Lun, -Ilun, Newpos
            ReadU, Ilun, XYMD, XHMS, Data
         end

         'DELP' : begin
            Category = 'DAO-3D-$'
            Tracer   = 17L
            Unit     = 'hPa'
            NL       = Long( GridInfo.LMX )
            Data     = FltArr( NI, NJ, NL )

            Point_Lun, -Ilun, Newpos
            ReadU, Ilun, XYMD, XHMS, Data
         end

         else : begin
            Message, 'Invalid selection!', /Continue
            stop
         end
      endcase
 
      ; Compute TAU from XYMD, XHMS
      Tau = NYMD2Tau( Long( XYMD ), Long( XHMS ), /GEOS )

      ; Store DATAINFO fields in the STRUC array of structures
      Struc[N].Ilun     = Ilun
      Struc[N].FilePos  = NewPos 
      Struc[N].Category = Category
      Struc[N].Tracer   = Tracer
      Struc[N].Tau0     = Tau
      Struc[N].Tau1     = Tau
      Struc[N].Unit     = Unit
      Struc[N].Format   = 'BINARY'
      Struc[N].Dim      = [ NI, NJ, NL, 1L ]
      Struc[N].First    = [ 1L, 1L, 1L ]

      ; Increment count
      N = N + 1L

   endwhile
   
   ;==================================================================== 
   ; Copy fields from STRUC to DATAINFO and return
   ;==================================================================== 
   DataInfo = Struc[0:N-1]
 
   return, 1L
end
 
