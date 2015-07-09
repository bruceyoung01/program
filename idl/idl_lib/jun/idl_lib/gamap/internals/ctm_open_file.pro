; $Id: ctm_open_file.pro,v 1.3 2008/07/01 14:52:07 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        CTM_OPEN_FILE
;
; PURPOSE:
;        Open a CTM output (punch) file and reads the complete
;        header information from that file. The file may be either
;        ASCII or binary type, and is only opened if not already 
;        parsed. It is re-opened if it was parsed but closed in the 
;        meantime. CTM_OPEN_FILE can also be used to read GEOS-CTM
;        restart files. However, since it is not possible to
;        point randomly at these data, the complete set of tracers
;        in a restart file will be read at once.
;        
;        While in general files are opened automatically when 
;        CTM_GET_DATA is used, there are several circumstances where
;        direct use of CTM_OPEN_FILE advantageous:
;        * if a read error occurs, use CTM_OPEN_FILE with the /PRINT
;          keyword to diagnose the error
;        * to compare two model runs, it is simpler to first open
;          the two files, then call CTM_GET_DATA without the filename
;          keyword. All operations will then be done on both files
;          in parallel.
;
; CATEGORY:
;        GAMAP Internals
;
; CALLING SEQUENCE:
;        CTM_OPEN_FILE, FILENAME, THISFILEINFO, THISDATAINFO
;
; INPUTS:
;        FILENAME -> The name of the file to be opened or a
;            file mask. If the file was not found or the file 
;            mask contains wild cards, a pickfile dialog is
;            opened for interactive selection. The default
;            search mask can be set in gamap.defaults (see
;            GAMAP_INIT).
;
; KEYWORD PARAMETERS:
;        CANCELLED -> Returns 1 if the CANCEL button was pressed
;            during DIALOG PICKFILE filename selection.
; 
;        _EXTRA keywords are passed to the various routines which
;            read the file headers.  
;
; OUTPUTS:
;        THISFILEINFO -> A named variable that will contain a 
;            fileinfo structure (see CREATE3DFSTRU).
;
;        THISDATAINFO -> A named variable that will contain an
;            array of datainfo structures (see CREATE3DHSTRU)
;            associated with this file.
;
;        THISFILEINFO and THISDATAINFO are also appended to the 
;        global pointer variables pGlobalFileInfo and pGlobalDataInfo
;        (see gamap_cmn.pro and GAMAP_INIT).
;
; SUBROUTINES:
;        Internal Subroutines:
;        ============================================================
;        Get_Free_Lun  (function)   Test_For_NCDF          (function)
;        Test_For_HDF  (function)   Test_For_HDFEOS        (function)
;        Test_For_GMAO (function)   Test_For_Binary        (function)
;        File_Parse    (function)   File_Opened_Previously (function)
;        Handle_Prev_Opened_File
;
;        External Subroutines Required:
;        ==============================================================
;        GAMAP_CMN          (incl file)  OPEN_FILE
;        CTM_READ3DB_HEADER (function )  CTM_READ3DB_HEADER (function)
;        CTM_READ_GMAO      (function )  CTM_READ_NCDF      (function) 
;        CTM_READ_GMI       (function )  LITTLE_ENDIAN      (function)
;        STRRIGHT           (function )
;
; REQUIREMENTS:
;        References routines from both GAMAP and TOOLS packages.
;
; NOTES:
;        (1) In internal function "test_for_dao", add additional met 
;        field names as is necessary to the FIELDNAMES array.  The
;        first met field name in a file is tested against FIELDNAMES.
;        If there is a match, then the file is declared to be a DAO 
;        met field file, and it is assigned a file type of 4.
;
;        (2) You must also add additional met field names to routine
;        "ctm_read_dao" as is necessary.  The DAO met field files do 
;        not carry tracer numbers, so the name of each met field must
;        be checked in "ctm_read_dao" before a corresponding DATAINFO
;        structure can be assigned.
;
;        (3) If a binary file is the wrong endian, we will get a
;        "Corrupted F77 file error" when we try to read data from it.
;        We now test for this error in routines TEST_FOR_BINARY and
;        TEST_FOR_DAO.  If this error condition occurs, the file is
;        re-opened with the /SWAP_ENDIAN command.
;
; EXAMPLE:
;        CTM_OPEN_FILE
;        ; queries the user for a filename and stores the analyzed
;        ; header information in the global common block
;        ; If an ASCII punch file is read, the user is prompted for
;        ; a model name
;
;        CTM_OPEN_FILE,'',fileinfo,datainfo
;        ; opens a CTM punch file after selection from a pickfile
;        ; dialog
;
;        CTM_OPEN_FILE,'~/amalthea/CTM4/run/ctm.pch',fileinfo,datainfo
;        ; opens the specified punch file
;
; MODIFICATION HISTORY:
;        mgs, 14 Aug 1998: VERSION 1.00
;        mgs, 17 Sep 1998: - file units now starting from 20, so
;                            they do not interfere with GET_LUN
;        mgs, 21 Sep 1998: - changed gamap.cmn to gamap_cmn.pro
;        mgs, 05 Oct 1998: - added function file_parse
;                          - can now handle GEOS restart files as well.
;        mgs, 10 Nov 1998: - no message after Cancel on Pickfile dialog
;        bmy, 20 Jan 1999: - explicitly set binary type to 2 for 
;                            GEOS-CTM restart files
;                          - accept bey's personal GEOS CTM timeseries label
;        mgs, 19 May 1999: - added SWAP_ENDIAN keyword to open_file if
;                            binary files are read on PC
;        mgs, 24 May 1999: - added support for 'CTM bin 02' files
;                            (involved changing filetype numbers)
;        bmy, 12 Apr 2000: GAMAP VERSION 1.45
;                          - added test for DAO binary met field files
;        bmy, 12 Jun 2000: - added CLDFRC to list of recognized DAO fields
;        bmy, 28 Jul 2000: GAMAP VERSION 1.46
;                          - added GEOS-3 names to list of recognized fields
;                          - deleted a couple of field names woe don't use
;        bmy, 25 Sep 2000: - added new field: SLP (sea level pressure)
;        bmy, 05 Dec 2000: GAMAP VERSION 1.47
;                          - added new fields: TKE, RH, KH
;        bmy, 07 Mar 2001: - added new fields: CLDTMP, TPW
;        bmy, 25 Apr 2001: - added new fields: TAULOW, TAUMID, TAUHI
;        bmy, 26 Jul 2001: GAMAP VERSION 1.48
;                          - added new field: T2M
;        bmy, 15 Aug 2001: - added new field: OPTDEPTH
;        bmy, 27 Sep 2001: GAMAP VERSION 1.49
;                          - reference LITTLE_ENDIAN in internal
;                            subroutine "handle_prev_opened_file"
;                          - swap endian if LITTLE_ENDIAN() returns true
;                            in internal subroutine "handle_prev_opened_file"
;        bmy, 29 Jan 2002: GAMAP VERSION 1.50
;                          - added new field: GWET
;        bmy, 03 Mar 2003: GAMAP VERSION 1.52:
;                          - added new fvDAS fields: CMFDTR, CMFETR,
;                            ZMDU, ZMED, ZMEU, ZMMD, ZMMU, HKETA, HKBETA
;        bmy, 18 Jun 2003: GAMAP VERSION 1.53
;                          - added new fields: EVAP, LAI, PARDF, PARDR
;        bmy, 30 Jul 2003: - added new field: TSKIN
;  lyj & tdf, 22 Oct 2003: - added SWAP_BINARY keyword to TEST_FOR_BINARY
;                          - Call TEST_FOR_BINARY with /SWAP_BINARY
;                            as a last-ditch effort if the file type
;                            cannot be classified.  This will open the
;                            file and swap the endian.
;        bmy, 12 Dec 2003: GAMAP VERSION 2.01
;                          - Now also test for netCDF file format
;                          - Added internal routines TEST_FOR_NETCDF,
;                            TEST_FOR_HDF (stub), TEST_FOR_HDFEOS
;                          - FILETYPE for ASCII   files range from 0-99
;                          - FILETYPE for BINARY  files range from 100-199
;                          - FILETYPE for netCDF  files range from 200-299
;                          - FILETYPE for HDF-EOS files range from 300-399
;                          - Routine TEST_FOR_GMAO now looks for met
;                            field tracer names from "tracerinfo.dat",
;                            instead of using a hardwired string array
;                          - rewritten for clarity; updated comments
;                          - Now looks for the GEOS-4 met field ident string
;        bmy, 11 Feb 2004: GAMAP VERSION 2.01a
;                          - Now prevents infinite loops when testing
;                            for file type
;        bmy, 24 Aug 2004: GAMAP VERSION 2.03
;                          - now recognizes GEOS-CHEM station timeseries
;                            file in bpch file format by the FTI string
;        bmy, 21 Mar 2005: - Added COARDS-compliant netCDF as FILETYPE=203
;        bmy, 24 May 2005: GAMAP VERSION 2.04
;                          - Now test properly for GCAP met fields
;        bmy, 06 Feb 2006: - Activate file type tests for HDF-EOS4 
;                            swath and point file types
;                          - Add new function TEST_FOR_HDF5 to test if
;                            the file is in HDF5 format
;                          - Use the absolute path name internally when
;                            testing for HDF5 or HDF-EOS files
;        bmy, 31 May 2006: GAMAP VERSION 2.05
;                          - Now expand the filename when calling NCDF_OPEN
;                          - Skip test for HDF5 for IDL versions
;                            earlier than 6.0
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
;                          - Now modified for GEOS-5
;                          - Added FILETYPE=106 for files that
;                            contain 4-D data blocks
;                          - Use FILETYPE=202 for netCDF files
;                            created by BPCH2GMI
;        phs, 30 Jun 2008: GAMAP VERSION 2.12
;                          - warning if too many files are opened
;                          - completly rewrite handling of endian swapping
;               
;-
; Copyright (C) 1998-2007, Martin Schultz, 
; Bob Yantosca, and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of 
; this software. If this software shall be used commercially or 
; sold as part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; with subject "IDL routine ctm_open_file"
;-----------------------------------------------------------------------


function Get_Free_Lun, pFileInfo

   ;====================================================================
   ; Internal function GET_FREE_LUN searches a FILEINFO structure 
   ; for the next free logical unit number.  If not found, it returns
   ; a default value of 20 for the first logical unit number.
   ;====================================================================

   ; If the PFILEINFO structure is defined, 
   ; then return the highest ILUN value plus 1
   if ( Ptr_Valid( pFileInfo ) ) then begin
      lun = Max( (*(pFileInfo)).Ilun ) + 1 

      ; check if too many files are opened (phs)
      if lun ge 100 then message, 'L.U.N. can also be managed by GET_LUN', /infor

      return, lun
   endif  
  
   ; Otherwise return 20 as first possible index
   return, 20
end

;------------------------------------------------------------------------------

function Test_For_NCDF, FileName

   ;====================================================================
   ; Internal function TEST_FOR_NCDF tests if FILENAME is a netCDF file. 
   ; The testing algorithm is as follows:  (bmy, 11/12/03, 3/21/05)
   ;
   ; (1) Tests if FILENAME has a ".nc" or ".ncdf" extension (upcase too!)
   ; (2) Opens FILENAME as a netCDF file and reads global attr. "Title"
   ; (3) If "Title" contains "CONSTITUENT", it's a GMI file (# 201)
   ; (4) If "Title" contains "BPCH2NC", it's a BPCH2NC file (# 202)
   ; (5) If "time" variable contains "since" in "units" attribute, 
   ;      then it's a COARDS-compliant netCDF file (#203)
   ; (6) Returns FILETYPE (201, 202, 203) to the main program.
   ; (7) Use FILETYPE=202 for files created by BPCH2GMI (bmy, 8/21/07)
   ;====================================================================
   
   ; Default file type; ASCII punch file
   FileType = 0

   ; Convert FILENAME to uppercase for testing
   TmpFileName = StrUpCase( StrTrim( FileName, 2 ) )
   
   ; Look for a .nc or .ncdf extension (uppercase too!)
   if ( StrRight( TmpFileName, 3 ) eq '.NC'     OR $
        StrRight( TmpFileName, 5 ) eq '.NCDF' ) then begin

      ;------------------------------------------------------
      ; Open netCDF file and look for TITLE global attribute
      ;------------------------------------------------------
      
      ; Test if netCDF routines exist
      if ( not NCDF_Exists() ) $
         then Message, 'NetCDF not supported w/ this version of IDL!'

      ; Open netCDF file
      fId = NCDF_Open( Expand_Path( FileName ) ) 

      ; Get info about the file
      Result = NCDF_Inquire( fId )
      
      ;------------------------------------------------------
      ; First look for the global attribute "Conventions"
      ; which will determine if this is a COARDS file
      ;------------------------------------------------------
      
      ; Loop thru # of global attributes
      for N = 0L, Result.NGAtts-1L do begin

         ; Get name of the Nth global attribute
         AttName = StrTrim( NCDF_AttName( fId, /Global, N ), 2 )
     
         ; Read CONVENTIONS attribute into TITLE string
         if ( StrPos( StrLowCase( AttName ), 'convention' ) ge 0 ) then begin
            NCDF_AttGet, fId, /Global, AttName, Title
            goto, Exit_Loop
         endif
      endfor
  
      ;------------------------------------------------------
      ; Look at "time" variable to see if it has a units
      ; string which contains "hours since YYYY-MM-MM" etc.
      ;------------------------------------------------------

      ; Loop thru variables
      for vId = 0L, Result.NVars-1L do begin

         ; Get variable name
         VarInfo = NCDF_VarInq( fId, vId )

         ; Do we have a variable named "time"?
         if ( StrPos( StrUpCase( VarInfo.Name ), 'TIME' ) eq 0 ) then begin

            ; If so, then loop over all of its attributes
            for N = 0L, VarInfo.NAtts-1L do begin

               ; Each attribute of "time"
               AttName = NCDF_AttName( fId, vId, N )
            
               ; Does the variable "time" have an attribute named "units"?
               ; If so, store its contents in the TITLE string and exit
               if ( StrPos( StrUpCase( AttName ), 'UNITS' ) ge 0 ) then begin
                  NCDF_AttGet, fId, vId, AttName, Title
                  goto, Exit_Loop
               endif

            endfor
         endif
      endfor

      ;------------------------------------------------------
      ; If there is no variable named TIME, then look at the
      ; TITLE to determine if this is a BPCH2NC or GMI file
      ;------------------------------------------------------
      
      ; Loop over all global attributes
      for N = 0L, Result.NGAtts-1L do begin
         
         ; Get the name of each global attribute
         AttName = NCDF_AttName( fId, /Global, N )
         AttName = StrTrim( AttName, 2 )

         ; Look for "TITLE" -- all combinations of upcase & lowcase
         if ( StrPos( StrUpCase( AttName ), 'TITLE' ) ge 0 ) then begin
            NCDF_AttGet, fId, /Global, AttName, Title
            goto, Exit_Loop
         endif
      endfor

      ;------------------------------------------------------
      ; We didn't find TITLE, so we can't get the filetype
      ;------------------------------------------------------

      ; Close netCDF file
      NCDF_Close, fId

      ; Return with failure status
      return, -1

      ;------------------------------------------------------
      ; We have found TITLE, so we can determine the filetype
      ;------------------------------------------------------
Exit_Loop:
 
      ; Convert TITLE to uppercase
      Title = StrUpCase( StrTrim( Title, 2 ) )

      ; netCDF file from GMI 
      if ( StrPos( Title, 'CONSTITUENT' ) ge 0 ) then FileType = 201

      ; netCDF file created by BPCH2NC or BPCH2GMI
      if ( StrPos( Title, 'BPCH2NC'     ) ge 0 ) then FileType = 202
      if ( StrPos( Title, 'BPCH2GMI'    ) ge 0 ) then FileType = 202

      ; COARDS-compliant netCDF file 
      if ( StrPos( Title, 'COARDS'      ) ge 0 ) then FileType = 203
      if ( StrPos( Title, 'SINCE'       ) ge 0 ) then FileType = 203

      ; Close netCDF file
      NCDF_Close, fId

      ; Return to calling program
      return, FileType

   endif
end

;------------------------------------------------------------------------------

function Test_For_HDF, FileName

   ;====================================================================
   ; Internal function TEST_FOR_HDF tests if FILENAME is a HDF file. 
   ; Right now, this is a stub program--fill in later (bmy, 11/12/03)
   ;====================================================================
   
   ; Default file type; ASCII punch file
   FileType = 0

   ; Convert FILENAME to uppercase for testing
   TmpFileName = StrUpCase( StrTrim( FileName, 2 ) )
   
   ; Look for a hdf extension (cast to uppercase)
   if ( StrRight( TmpFileName, 4 ) eq '.HDF' ) then begin

      ; Return to calling program
      return, FileType
   endif
end

;------------------------------------------------------------------------------

function Test_For_HDF5, FileName

   ;====================================================================
   ; Internal function TEST_FOR_HDF5 tests if FILENAME is a HDF5 file. 
   ; (bmy, 2/8/06, 3/9/06)
   ;
   ; NOTES: 
   ; (1) Skip this for versions of IDL prior to 6.0 (bmy, 3/9/06)
   ; (2) Now also test that the file exists (bmy, 5/31/06)
   ;====================================================================

   ; IDL versions prior to 6.0 (?) do not have HDF5 library support
   if ( Float( !VERSION.RELEASE ) lt 6.0 ) then return, 0

   ; Get the absolute path name because HDF5 routines require it 
   FullFileName = Expand_Path( FileName )

   ; Exit if we can't find the file (bmy, 5/31/06)
   if ( not File_Exist( FullFileName ) ) then return, 0

   ; Test for HDF5 file (assign filetype 401 if successful)
   if ( H5F_IS_HDF5( FullFileName ) gt 0 ) then return,  401

   ; Otherwise, return FILETYPE=0 (ASCII pch file)
   return, 0
end

;------------------------------------------------------------------------------

function Test_For_HDFEOS, FileName

   ;====================================================================
   ; Internal function TEST_FOR_HDFEOS tests if FILENAME is a HDF-EOS4
   ; file.  The testing algorithm is as follows:  (bmy, 2/8/06)
   ;
   ; (1) First call IDL routine EOS_GD_INQGRID to test if the file
   ;      is an HDF-EOS GRID file.  This routine returns the number of
   ;      HDF-EOS grids in the file, so anything greater than 0 is
   ;      success.  Assign FILETYPE=301 if this is a HDF-EOS grid file. 
   ; (2) Then call IDL routine EOS_GD_INQSWATH to test if the file
   ;      is an HDF-EOS SWATH file.  This routine returns the number of
   ;      HDF-EOS swaths in the file, so anything greater than 0 is
   ;      success.  Assign FILETYPE=302 if this is a HDF-EOS swath file.
   ; (3) Then call IDL routine EOS_GD_INQPOINT to test if the file
   ;      is an HDF-EOS SWATH file.  This routine returns the number of
   ;      HDF-EOS swaths in the file, so anything greater than 0 is
   ;      success.  Assign FILETYPE=302 if this is a HDF-EOS swath file.
   ;====================================================================
   
   ; Get the absolute path name because HDF-EOS routines require it 
   FullFileName = Expand_Path( FileName )

   ; Test for HDF-EOS GRID, SWATH, and POINT files, in that order
   if ( EOS_GD_InqGrid(  FullFileName, List ) gt 0 ) then return, 301
   if ( EOS_SW_InqSwath( FullFileName, List ) gt 0 ) then return, 302
   if ( EOS_PT_InqPoint( FullFileName, List ) gt 0 ) then return, 303

   ; Otherwise, return FILETYPE=0 (ASCII pch file)
   return, 0
end

;------------------------------------------------------------------------------

function Test_For_GMAO, Ilun, Debug=Debug

   ;====================================================================
   ; Internal function TEST_FOR_GMAO tests if a file is a GMAO met
   ; field file.  The testing algorithm is as follows: (bmy, 5/23/05)
   ;
   ; (1) Opens the file as binary and reads in the first 8 bytes 
   ; (2) If file type is binary, replace logical unit number    
   ; (3) Tests first 8 characters for known GMAO met field names
   ; (4) Returns 104 if FILENAME is a GMAO or GCAP met field file; 
   ;      -1 otherwise.
   ;
   ; NOTES: 
   ; (1) Now re-opens the binary file and swaps the endian if 
   ;      necessary.  This should now eliminate problems when reading 
   ;      binary files created on machines w/ a different endian than 
   ;      the machine on which you are running GAMAP. (bmy, 10/23/03)
   ; (2) Now looks for the GEOS-4 ident string (bmy, 12/12/03)
   ; (3) Now prevent infinite loop when testing to swap endian.  This
   ;      happened when trying to read in ASCII pch files (bmy, 2/11/04)
   ; (4) Now return FILETYPE=104 for GCAP met field files, which
   ;      have an IDENT string (bmy, 5/23/05)
   ;====================================================================

   ; Counter to prevent infinite loop
   Count    = 0L

   ; Default : ASCII punch file
   Filetype = 0                 

   ; Test if file is opened (actually, get file name, it is already opened! -phs)
   Result = FStat( Ilun )

   ; open file once more in binary mode 
   ; swap endians if we are working on a PC (x86 system)
   ; (we know that binary model files are always produced on a 
   ; big endian system)
   
; -- prior 6/30/08 (phs)
;   ; use next unit number *** DANGEROUS ?? ***
;    TestLun = Ilun + 1             
;
;   ;### Debug print
;   if ( Debug ) then print, '##TESTLUN:',testlun
;
;   ; Open the file assuming big endian w/ a new lun b/w 100-128
;   Open_File, Result.Name, TestLun, $
;      /No_PickFile, /F77_Unformatted, Swap_Endian=Little_Endian()
;
;   ; if unable to open file, simply return
;   if ( testlun le 0 ) then return, -1

   ; read version information from binary file
   ; If the file is of the wrong endian, reopen it properly
   TestChar = BytArr( 8 )
   on_ioerror, handle_the_ioerror

Try_The_Read_Again:
; -- prior 6/30/08 (phs)
;   readu, testlun, testchar
   readu, ilun, testchar

   ; The 1st 8 characters of the binary file
   TmpStr = StrUpCase( StrTrim( String( TestChar ), 2 ) )

   ; First look for the GEOS-4 ident string
   if ( StrMid( TmpStr, 0, 2 ) eq 'G4'   OR $
        StrMid( TmpStr, 0, 2 ) eq 'G5'   OR $
        StrMid( TmpStr, 0, 2 ) eq 'GP' ) then begin

      ;-----------------------------------------------------------------
      ; If we have found the GEOS-4 or GCAP ident string, we know that
      ; this is a met field file so set FILETYPE=104 (bmy, 12/12/03)
      ;-----------------------------------------------------------------
      FileType = 104

   endif else begin

      ;-----------------------------------------------------------------
      ; GEOS-3 etc do not have ident strings, so we must match
      ; the first met field name w/ tracers listed in "tracerinfo.dat"
      ;-----------------------------------------------------------------

      ; First look for the 2-D field names listed in the setup files
      CTM_TracerInfo, /All, Name=Name, Index=Index   
      CTM_DiagInfo,  'GMAO-2D', Offset=Offset, Spacing=Spacing
      Ind = Where( Index ge Offset AND Index le Offset+Spacing )
      FieldNames = Name[Ind]

      ; Now look for the 3-D field names listed in the setup files
      CTM_DiagInfo,  'GMAO-3D$', Offset=Offset, Spacing=Spacing
      Ind = Where( Index ge Offset AND Index le Offset+Spacing )
      FieldNames = [ FieldNames, Name[Ind] ]
      FieldNames = StrUpCase( StrTrim( FieldNames, 2 ) )

      ; Search for a match...if found, then this is a
      ; GEOS-CHEM met field file, so set FILETYPE = 104
      Ind = Where( FieldNames eq TmpStr )
      if ( Ind[0] ge 0 ) then FileType = 104

   endelse

   ;### Debug
   if ( Debug ) then print,'## TEST_FOR_GMAO: filetype=',filetype, $
      '  test string=',string(testchar)

;;-- prior to 6/30/08 (phs)
;
;   if ( FileType gt 0 ) then begin
;      ; close unit ilun and replace with testlun
;      ; *** NOTE: This will produce 1 unused unit number each time
;      ; *** a binary file is opened! If necessary, we have to replace
;      ; *** this by closing testlun and re-opening the file 
;      ; *** as /F77_UNFORMATTED with unit number ilun!
;      ;Free_Lun, Ilun
;      ;Ilun = TestLun
;
;   endif else begin
;      ; close test unit
;      Free_lun, TestLun
;   endelse
;
;

   ; Return to calling program
   return, FileType
    
Handle_The_IoError:

;--- prior to 6/30/08
;   ;---------------------------------------------------
;   ; Prevent infinite loop (bmy, 2/11/04)   
;   ;---------------------------------------------------
;   if ( Count gt 1L ) then begin
;      Free_LUN, Testlun
;      return, FileType
;   endif
;
;   ;---------------------------------------------------
;   ; Test if we have to swap the endian (bmy, 10/23/03)
;   ;---------------------------------------------------
;   if ( StrPos( !ERROR_STATE.MSG, 'Corrupted f77 unformatted file' ) ge 0 ) $
;      then begin
;
;      ; Close the current file unit (but do not free it!)
;      Close, TestLun
;
;      ; Reopen the file w/ the same unit and swap the endian
;      Open_File, Result.Name, TestLun, /No_Pickfile, /F77, /Swap_Endian
;
;      ; Increment counter (bmy, 2/11/04)
;      Count = Count + 1L
;
;      ; Try to read characters from the file again
;      goto, Try_The_Read_Again
;   endif
;   
;   ;---------------------------------------------------
;   ; Be crude: simply assume file is not binary and 
;   ; close test unit. Errors should be caught 
;   ; elsewhere.  Reset error state. 
;   ;---------------------------------------------------
;
;   ;### for debug purposes:
;   ;###print,!error_state.code,':',!error_state.msg
;   Message,/Reset
;   free_lun,testlun
;   return,0
;
;   ; *** more sophisticated, if crude approach causes trouble: ***
;   ; catch "corrupted binary file" error (assume it's ASCII)
;   if (!ERR eq -237) then begin   
;      free_lun,testlun
;      return,0
;   endif
            
   Message, /Reset
   return, 0
   
end

;------------------------------------------------------------------------------

function Test_For_Binary, Ilun, Debug=Debug, Swap_Binary=Swap_Binary

   ;====================================================================
   ; Internal function TEST_FOR_BINARY tests if a file is a binary 
   ; punch file (v1 or v2) or a GEOS-CTM restart file.  The testing
   ; algorithm is as follows:  (bmy, phs, 11/18/03, 6/21/07)
   ;
   ; (1) Opens the file as binary and reads in the first 40 bytes 
   ; (2) If file type is binary, replace logical unit number    
   ; (3) Test first 10 characters for 'CTM binary' or 'CTM bin 02'.
   ; (4) Returns 101 if FILENAME is a BINARY PUNCH FILE version 1
   ; (5) Returns 102 if FILENAME is a BINARY PUNCH FILE version 2
   ; (6) Returns 105 if FILENAME is a GEOS-CHEM station timeseries file
   ; (7) Returns 0 otherwise (FILENAME is ASCII punch file)
   ;
   ; NOTES:
   ; (1) Add the swap binary keyword for files written on big-endian
   ;      machines such as SGI (lyj, tdf, 10/23/03)
   ; (2) Now re-opens the binary file and swaps the endian if 
   ;      necessary.  This should now eliminate problems when reading 
   ;      binary files created on machines w/ a different endian than the
   ;      machine on which you are running GAMAP. (bmy, 10/23/03)
   ; (3) Now eliminate the old GEOS-CTM restart file format, this 
   ;      has been supplanted w/ BINARY PUNCH FILE v2 (bmy, 11/18/03)
   ; (4) Now prevent infinite loop when testing to swap endian.  This
   ;      happened when trying to read in ASCII pch files (bmy, 2/11/04)
   ; (5) Added test for GEOS-CHEM station timeseries file (which is
   ;      in bpch file format). (bmy, 7/20/04)
   ; (6) Return FILETYPE=106 for 4-D data block (phs, 6/21/07)
   ;====================================================================

   ; Counter to prevent infinite loop
   Count    = 0L

   ; Default : ASCII punch file
   Filetype = 0                 

   ; Keywords
   Debug       = Keyword_Set( Debug       )
   Swap_Binary = Keyword_Set( Swap_Binary )

   ; test if file is opened (it is opened! this is just to get the
   ; file name so we can re-open it w/ another lun -phs)
   Result = FStat( Ilun )

; -- prior 6/30/08 (phs). Now commented, since open_file will define testlun   
;   ; use next unit number *** DANGEROUS ?? ***
;    TestLun = Ilun + 1             
;   if ( Debug )  then print,'##TESTLUN:',testlun
;
;   ; jaegle 2003-02-14 replace little endian with swap _binary
;   ; to allow reading of files being created on the Compaq Alpha
;   Open_File, Result.Name, TestLun,$
;      /No_PickFile, /F77_Unformatted, Swap_Endian=Swap_Binary
;
;   ; If unable to open file, simply return
;   if ( TestLun le 0 ) then return, -1
;

   ; read version information from binary file
   ; If the file is of the wrong endian, reopen it properly
   TestChar = BytArr(40)
   on_ioerror,handle_ioerror

Try_Read_Again:  

;--- prior to 6/30/08
;   readu,testlun,testchar
   readu,ilun,testchar

   ;---------------------------------------
   ; test for binary CTM output file types
   ;---------------------------------------

   ; Binary punch file for GEOS-CHEM station timeseries
   if ( StrPos( String( TestChar ), 'GEOS-CHEM station ts' ) ge 0 ) then begin
      Filetype = 105

   ; CTM binary punch file v2 
   endif else if ( StrPos( String( TestChar ),'CTM bin 02' ) ge 0 ) then begin
      FileType = 102

   ; CTM binary punch file v2 with 4-D data blocks
   endif else if ( StrPos( String( TestChar ),'CTM bin 4D' ) ge 0 ) then begin
      FileType = 106

   ; CTM binary punch file v1 (NOW OBSOLETE!)
   endif else if ( StrPos( String( TestChar ),'CTM binary' ) ge 0 ) then begin
      FileType = 101

   endif

   ;### Debug
   if ( Debug ) then print,'## TEST_FOR_BINARY: filetype=',filetype, $
      '  test string=',string(testchar)

;--- prior to 6/30/08
;   if ( FileType gt 0 ) then begin
;      ; close unit ilun and replace with testlun
;      ; *** NOTE: This will produce 1 unused unit number each time
;      ; *** a binary file is opened! If necessary, we have to replace
;      ; *** this by closing testlun and re-openeing the file 
;      ; *** as /F77_UNFORMATTED with unit number ilun!
;      Free_LUN, Ilun
;      Ilun = TestLun
;   endif else begin
;      ; close test unit
;      Free_LUN, TestLun
;   endelse
;
   ; Return FILETYPE to main program
   return, FileType

Handle_IoError:

;--- prior to 6/30/08
;   ;---------------------------------------------------
;   ; Prevent infinite loop (bmy, 2/11/04)   
;   ;---------------------------------------------------
;   if ( Count gt 1L ) then begin
;      Free_LUN, Testlun
;      return, FileType
;   endif
;
;   ;---------------------------------------------------
;   ; Test if we have to swap the endian (bmy, 10/23/03)
;   ;---------------------------------------------------
;   if ( StrPos( !ERROR_STATE.MSG, 'Corrupted f77 unformatted file' ) ge 0 ) $
;      then begin
;   
;      ; Close the current file unit (but don't free it!)
;      Close, Testlun
;   
;      ; Reopen the file w/ the same unit and swap the endian
;      Open_File, Result.Name, testlun, /No_Pickfile, /F77, /Swap_Endian
;   
;      ; Increment counter (bmy, 2/11/04)
;      Count = Count + 1L
;
;      ; Try to read characters from the file again
;      goto, Try_Read_Again
;   endif
;   
;   ;---------------------------------------------------
;   ; be crude: simply assume file is not binary and 
;   ; close test unit.  Errors should be caught 
;   ; elsewhere.  Reset error state.
;   ;---------------------------------------------------
;   ;### for debug purposes
;   ;###print,!error_state.code,':',!error_state.msg
;   Message, /Reset
;   free_lun, testlun
;   return, 0
;
;   ; *** more sophisticated, if crude approach causes trouble: ***
;   ; catch "corrupted binary file" error (assume it's ASCII)
;   if (!ERR eq -237) then begin   
;      free_lun,testlun
;      return,0
;   endif

   ;---------------------------------------------------
   ; be crude: simply assume file is not binary and 
   ; close test unit.  Errors should be caught 
   ; elsewhere.  Reset error state.
   ;---------------------------------------------------
   ;### for debug purposes
   ;###print,!error_state.code,':',!error_state.msg
   Message, /Reset
   return, 0

end


;------------------------------------------------------------------------------

function File_Parse, Ilun, Ftype, ThisFileInfo, ThisDataInfo, _EXTRA=e

   ;====================================================================
   ; Internal function FILE_PARSE calls the proper reader for the
   ; given file, based on the value of FTYPE. (bmy, 11/25/03, 6/21/07)
   ;
   ; FTYPE  File Format                        Reader
   ; -------------------------------------------------------------------
   ;   0    ASCII punch file (used by GISS)     CTM_READ3DP_HEADER
   ;  101   BINARY punch file v1 (OBSOLETE)     CTM_READ3DB_HEADER
   ;  102   BINARY punch file v2 (GEOS-Chem)    CTM_READ3DB_HEADER
   ;  104   GMAO or GCAP binary met field file  CTM_READ_GMAO
   ;  105   GEOS-CHEM station timeseries file   CTM_READ3DB_HEADER
   ;  106   BINARY punch file v2 w/ 4-D data    CTM_READ3DB_HEADER
   ;  201   netCDF file from GMI                CTM_READ_GMI
   ;  202   netCDF file written by BPCH2NC      CTM_READ_NCDF
   ;  203   netCDF file, COARDS-compliant       CTM_READ_COARDS
   ;  301   HDF-EOS4 file w/ gridded data       CTM_READ_EOSGR
   ;  302   HDF-EOS4 file w/ satellite swath    not yet implemented
   ;  303   HDF-EOS4 file w/ point data         not yet implemented
   ;  401   HDF5 file                           not yet implemented
   ;====================================================================

   ; Case statement
   case ( FType ) of

      ;------------------------
      ; ASCII pch file (GISS)
      ;------------------------
      0   : Result = CTM_Read3dP_Header( Ilun,               $
                                         ThisFileInfo,       $
                                         ThisDataInfo,       $
                                         _EXTRA=e )

      ;-------------------------
      ; Bpch file v1 (OBSOLETE)
      ;-------------------------
      101 : Result = CTM_Read3dB_Header( Ilun,               $
                                         ThisFileInfo,       $
                                         ThisDataInfo,       $ 
                                         _EXTRA=e) 

      ;--------------------------
      ; Bpch file v2 (GEOS-CHEM)
      ;--------------------------
      102 : Result = CTM_Read3dB_Header( Ilun,               $
                                         ThisFileInfo,       $
                                         ThisDataInfo,       $
                                         _EXTRA=e )

      ;--------------------------
      ; GMAO/GCAP met field file
      ;--------------------------
      104 : Result = CTM_Read_GMAO( Ilun,                    $
                                    ThisFileInfo,            $
                                    ThisDataInfo,            $
                                    _EXTRA=e )

      ;--------------------------
      ; ND48 timeseries bpch
      ; (in Bpch v2 format)
      ;--------------------------
      105 : Result = CTM_Read3dB_Header( Ilun,               $
                                         ThisFileInfo,       $
                                         ThisDataInfo,       $
                                         _EXTRA=e)
      ;--------------------------
      ; Bpch file w/ 4-D data
      ;--------------------------
      106 : Result = CTM_Read3dB_Header( Ilun,               $
                                         ThisFileInfo,       $
                                         ThisDataInfo,       $
                                         _EXTRA=e)

      ;--------------------------
      ; netCDF file from GMI
      ;--------------------------      
      201 : Result = CTM_Read_GMI( Ilun,                     $
                                   ThisFileInfo.FileName,    $
                                   ThisFileInfo,             $
                                   ThisDataInfo,             $
                                   _EXTRA=e )

      ;--------------------------
      ; netCDF file from BPCH2NC
      ;--------------------------      
      202 : Result = CTM_Read_NCDF( Ilun,                    $
                                    ThisFileInfo.FileName,   $
                                    ThisFileInfo,            $
                                    ThisDataInfo,            $
                                    _EXTRA=e )

      ;--------------------------
      ; COARDS netCDF file
      ;--------------------------      
      203 : Result = CTM_Read_COARDS( Ilun,                  $
                                      ThisFileInfo.FileName, $
                                      ThisFileInfo,          $
                                      ThisDataInfo,          $
                                      _EXTRA=e )

      ;--------------------------
      ; HDF-EOS4 GRID file
      ;--------------------------      
      301 : Result = CTM_Read_EOSGR( Ilun,                   $
                                     ThisFileInfo.FileName,  $
                                     ThisFileInfo,           $
                                     ThisDataInfo,           $
                                     _EXTRA=e )

      ;--------------------------
      ; HDF-EOS4 SWATH file
      ; ** NOT YET SUPPORTED **
      ;--------------------------   
      302 : Message, 'HDF-EOS4 swath type is not implemented into GAMAP yet!'
         
      ;--------------------------
      ; HDF-EOS4 POINT file
      ; ** NOT YET SUPPORTED **
      ;--------------------------   
      303 : Message, 'HDF-EOS4 point type is not implemented into GAMAP yet!'

      ;--------------------------
      ; HDF5 file
      ; ** NOT YET SUPPORTED **
      ;--------------------------   
      401 : Message, 'HDF5 data type is not implemented into GAMAP yet!'

      ; Error msg
      else : Message, 'UNKNOWN GAMAP FILETYPE!  Contact bmy@io.harvard.edu'
   endcase

   ; Return success/failure flag to main program
   return, Result
end

;------------------------------------------------------------------------------

function File_Opened_Previously, FileName, pFileInfo, Lun=Lun

   ;====================================================================
   ; Internal function FILE_OPENED_PREVIOUSLY tests if a filename
   ; entry exists in the FILEINFO structure.
   ;====================================================================

   ; Default lun as next available unit number
   Lun = Get_Free_Lun( pFileInfo )

   ; if FileName contains wildcards, quit immediately
   if ( StrPos( FileName, '*' ) ge 0   OR   $
        StrPos( FileName, '?' ) ge 0 ) then $
      return, -1
 
   ; expand filename ( '~' -> '/users/ctm/', etc.)
   TestName = Expand_Path( FileName )
 
   ; Test if PFILEINFO structure is valid
   if ( Ptr_Valid( pFileInfo ) ) then begin
 
      ; Try to locate FILENAME in the PFILEINFO structure
      Ind = Where( (*(pFileInfo)).FileName eq TestName )

      ; If found, then pull out the corresponding ILUN
      if ( Ind[0] ge 0 ) $
         then Lun = (*(pFileInfo))[Ind[0]].Ilun 

      ; Return index where FILENAME eq TESTNAME to calling program
      return, ind[0]

   endif else begin

      ; Could not find FILENAME in the PFILEINFO structure 
      return, -1

   endelse
 end

;------------------------------------------------------------------------------

pro Handle_Prev_Opened_File, ThisFileInfo,  ThisDataInfo, pGlobalDataInfo, $
                             Result=Result, Debug=debug
 
   ;====================================================================
   ; Internal routine HANDLE_PREV_OPENED_FILE makes sure all 
   ; information from a previously opened file is available.
   ;====================================================================

   ; initialize result with safe value
   Result = 0
  
   ; get file status
   Test = Fstat( ThisFileInfo.Ilun )
 
   ;===================================================================
   ; re-open file if accidentally closed
   ; (Note: detached composites contain negative ilun)
   ;
   ; Do NOT reopen self-describing files (e.g. netCDF) (bmy, 11/12/03)
   ;===================================================================
   if ( ThisFileInfo.Ilun gt 0 AND not Test.Open ) then begin

      ; Binary files have FILETYPE values from 100-199
      Is_Binary   = ( ThisFileInfo.FileType ge 100 AND $
                      ThisFileInfo.FileType lt 200 )

      ; Self-Describing files (netCDF, HDF-EOS, HDF, ...)
      ; have FILETYPE values 200 and higher
      Is_SelfDesc = ( Thisfileinfo.FileType ge 200 )

      ; Debug info
      if ( Debug ) then print,'## CTM_OPEN_FILE: RE-OPEN FILE...'
      
      ; Open the file and assume big endian
      ; will be re-swapped when testing for file type
      ;### NOTE: Don't do this for netCDF files (bmy, 11/10/03)
      if ( not Is_SelfDesc ) then begin
         Open_File, ThisFileInfo.FileName, ThisFileInfo.Ilun, $
            F77_Unformatted=Is_Binary, Default=DefaultPath, $
            /No_PickFile, Swap_Endian=Little_Endian()
      endif

      ; error test
      if ( ThisFileInfo.Ilun lt 0 ) then $
         Message,'*** Serious error: Cannot re-open file '+ $
         ThisFileInfo.FileName
   endif
 
   ;====================================================================
   ; OK: file is open and we do have a suitable fileinfo record
   ; (or we found the respective composite information)
   ;====================================================================
 
   ; Now extract all datainfo structures that correspond to the
   ; current file
   if ( not Ptr_Valid( pGlobalDataInfo ) ) then begin
      Message,'*** Fatal error: Global DataInfo pointer nil !'
   endif

   ; Find elements of PGLOBALDATAINFO that come from the current file
   ; We do this by matching DATAINFO.ILUN w/ FILEINFO.ILUN fields
   Ind = Where( (*pGlobalDataInfo).Ilun eq ThisFileInfo.Ilun )

   if ( Ind[0] ge 0 ) then begin

      ; indicates successful operation
      ThisDataInfo = (*pGlobalDataInfo)[ind]
      result = 1                

   endif else begin

      ; If nothing was found, try reading the header information again
      Result = File_Parse( ThisFileInfo.Ilun,     $
                           ThisFileInfo.FileType, $
                           ThisFileInfo,          $
                           ThisDataInfo,          $
                           _EXTRA=e)

      ;### Debug
      if ( Debug ) then begin
         print,'## CTM_OPEN_FILE: RESULT from read_header ',result
      endif

      ; If successful in reading header info, then
      ; append current datainfo to global datainfo
      if ( Result ) then begin
         CurDataInfo        = *(pGlobalDataInfo)
         *(pGlobalDataInfo) = [ CurDataInfo, ThisDataInfo ]
      endif
 
   endelse
 
   ; Return to calling program
   return
end
 
;------------------------------------------------------------------------------
 
pro CTM_Open_File, FileName, ThisFileInfo, ThisDataInfo,  $
                   Cancelled=Cancelled, _EXTRA=e
 
   ;====================================================================
   ; Initialization
   ;==================================================================== 

   ; External functions
   FORWARD_FUNCTION CTM_Read3dP_Header, CTM_Read3dB_Header, $
                    CTM_Read_GMAO,      CTM_Read_NCDF,      $
                    CTM_Read_GMI,       Test_For_Binary,    $
                    Test_For_GMAO,      Test_For_NCDF,      $
                    StrRight,           Little_Endian
 
   ; Include global GAMAP Common blocks
   @gamap_cmn.pro
 
   ; set datainfo to -1 for safe exit
   ThisDataInfo = -1L
    
   ; default is operation not cancelled
   Cancelled = 0

   ; Initialize filetype
   FileType = -1

   ; if filename is empty, set default mask  
   if ( N_Elements( FileName ) eq 0  ) then FileName = ''
   if ( FileName               eq '' ) then FileName = DefaultPath 

   ;====================================================================
   ; Test if the global FILEINFO structure contains an entry for the
   ; current file.  If so, then also make sure that the file is
   ; open and extract the corresponding DATAINFO structures.
   ; Also get Ilun number for all cases.
   ;====================================================================
   Ind = File_Opened_Previously( FileName, pGlobalFileInfo, Lun=Ilun )

   ; If file was opened previously...
   if ( Ind ge 0 ) then begin

      ;### Debug
      if ( Debug ) then begin
         print,'## CTM_OPEN_FILE: FOUND FILENAME IN FILEINFO...'
      endif

      ; Extract current fileinfo from global structure array
      ThisFileInfo = (*pGlobalFileInfo)[Ind[0]]
 
      ; Get datablock info from previously opened file
      Handle_Prev_Opened_File, ThisFileInfo,    ThisDataInfo,  $
                               pGlobalDataInfo, Debug=Debug
      
      ; Return to calling program
      return
   endif
 
   ;====================================================================
   ; Otherwise, create a new FILEINFO entry and read the header info
   ;====================================================================
   ThisFileInfo = Create3dFStru() 

    ; open the file
   if ( Debug ) $
      then print,'## CTM_OPEN_FILE: OPENING (NEW) FILE ...', Ilun

   ; Initialize FILEMASK w/ filename
   FileMask = FileName

   ;====================================================================
   ; First test if FILENAME is a self-describing file
   ; such as netCDF, HDF, or HDF-EOS (bmy, 11/12/03)
   ;====================================================================
   
   ; First Test for netCDF file
   FileType = Test_For_NCDF( FileName )

   ; Then test for HDF-EOS4 format
   if ( FileType eq 0 ) then FileType = Test_For_HDFEOS( FileName )

   ; Then test for HDF4 file (to be implemented later)
   ;if ( FileType eq 0 ) then FileType = Test_For_HDF( FileName )

   ; Test for HDF5 file 
   if ( FileType eq 0 ) then FileType = Test_For_HDF5( FileName )

   ;====================================================================
   ; If FILENAME is not a self-describing file, then test for
   ; BINARY (BPCH or DAO met field) format or ASCII pch format
   ;
   ; NOTE: The routines TEST_FOR_BINARY and TEST_FOR GMAO may change
   ;       the logical unit number by adding 1 to it. (bmy, 11/12/03)
   ;====================================================================
   if ( FileType le 0 ) then begin


      ;-------------------------------------------
      ; Open the file assuming big endian
      ;-------------------------------------------
      Open_File, FileMask, Ilun, /f77, $
                 Default=DefaultPath, Filename=FileName, $
                 /Swap_if_little_endian

      ; ### Debug
      if ( Debug ) then print,'## CTM_OPEN_FILE: TRUE FILENAME:',filename

      ; Error check ILUN
      if ( Ilun le 0 ) then begin
         if ( !Error_State.Code ne 0 ) $
            then message,'Cannot open file '+filename,/Cont  $
            else cancelled = 1     ; Cancel button was pressed
         return
      endif

      ; Test for BPCH file
      FileType = Test_For_Binary( Ilun, Debug=Debug )

      ; Reposition and Test for GMAO met field file
      if ( FileType eq 0 ) then begin
         point_lun, ilun,  0
         FileType = Test_For_GMAO( Ilun, Debug=Debug )
      endif


      ;-------------------------------------------
      ; Open the file assuming little endian
      ;-------------------------------------------
      IF FileTYpe eq 0 then begin

         close,  ilun

         Open_File, FileMask, Ilun, /f77, $
                    Default=DefaultPath, Filename=FileName, $
                    /swap_if_big_endian

         ; Error check ILUN
         if ( Ilun le 0 ) then begin
            if ( !Error_State.Code ne 0 ) $
            then message, 'Cannot open file '+filename, /Cont  $
            else cancelled = 1     ; Cancel button was pressed
            return
         endif
      
         ; Test for byte-swapped GMAO met field file
         FileType = Test_For_Binary( ilun, Debug=Debug )
         
         ; Reposition and Test for byte-swapped BPCH file
         if ( FileType eq 0 ) then begin
            point_lun, ilun,  0
            FileType = Test_For_GMAO( Ilun, Debug=Debug )
         endif

         ; ### Debug
         if ( Debug ) then print, '## FILETYPE, ILUN: ', FileType, Ilun

      endif

      ;---------------------------------
      ; FILETYPE=0  is ASCII punch file
      ; FILETYPE=-1 is an I/O error
      ;---------------------------------
      if ( Filetype lt 0 ) then begin
         Message, 'Error while detecting file type.',/Cont
         return
      endif

   endif

   ;====================================================================
   ; Test if FILENAME is already open.  If so, then get all of the
   ; datablocks corresponding to the THISFILEINFO and THISDATAINFO
   ; structures and return.
   ;====================================================================

   ; Save FILETYPE and FILENAME in the THISFILEINFO structure
   ThisFileInfo.FileType = FileType
   ThisFileInfo.FileName = FileName 

   ; Test again if the file is already open
   Ind = File_Opened_Previously( FileName, pGlobalFileInfo )

   if ( Ind ge 0 ) then begin
 
      ; If this is not a self-describing file format, then close 
      ; The newly opened file (will be re-opened with previous LUN)
      if ( FileType lt 200 ) then Free_Lun, Ilun
 
      ; ### Debug
      if ( Debug ) then $
      print,'## CTM_OPEN_FILE: FOUND FILENAME IN FILEINFO (after pickfile) ...'

      ; Extract current FILEINFO structure from GAMAP global common block
      ThisFileInfo = (*pGlobalFileInfo)[Ind[0]]
 
      ; Get all DATAINFO structures from the current file
      Handle_Prev_Opened_File, ThisFileInfo, ThisDataInfo,  $
         pGlobalDataInfo, Result=Result, Debug=Debug
 
      ; if (re)loading the datainfo caused trouble, mark 
      ; filestatus in fileinfo
      if ( not Result ) then ThisFileInfo.Status = 0

      ; Return to calling program
      return
   endif
 
   ;====================================================================
   ; If FILENAME has not yet been opened, then call FILE_PARSE, which 
   ; calls the proper reader for the given file type.  Then append the
   ; THISDATAINFO and THISFILEINFO structures (which describe each data
   ; block contained in FILENAME) into the GAMAP global structures 
   ; PGLOBALDATAINFO and PGLOBALFILEINFO.  
   ;
   ; Once the information from each data block has been added to 
   ; PGLOBALDATAINFO and PGLOBALFILEINFO, then the data blocks may
   ; be accessed via GAMAP, CTM_GET_DATABLOCK, etc.
   ;====================================================================

   ; For safety's sake, replace tag names of FILEINFO structure
   ThisFileInfo.FileName = FileName
   ThisFileInfo.FileType = FileType 
   ThisFileInfo.Ilun     = Ilun

   ; For each data block in the FILENAME, return the 
   ; corresponding THISFILEINFO and THISDATAINFO structures
   Result = File_Parse( ThisFileInfo.Ilun,     $
                        ThisFileInfo.FileType, $
                        ThisFileInfo,          $
                        ThisDataInfo,          $
                        _EXTRA=e )
 
   if ( Debug ) then print,'## CTM_OPEN_FILE: RESULT : ', Result

   ; For safety's sake, replace RESULT tag of THISFILEINFO
   ThisFileInfo.Status = Result

   ; Add THISFILEINFO and THISDATAINFO into GAMAP global structures
   if ( Result ) then begin

      ;-------------------------------------
      ; pGlobalFileInfo array of structures
      ;-------------------------------------
      if ( not Ptr_Valid( pGlobalFileInfo ) ) then begin

         ; If PGLOBALFILEINFO doesn't exist, 
         ; define it from the THISFILEINFO structue
         pGlobalFileInfo = Ptr_New( ThisFileInfo ) 

      endif else begin
         
         ; If PGLOBALFILEINFO exists, just 
         ; append THISFILEINFO structure into it
         CurFileInfo        = *(pGlobalFileInfo)
         *(pGlobalFileInfo) = [ CurFileInfo, ThisFileInfo ]

      endelse
 
      ;-------------------------------------
      ; pGlobalDataInfo array of structures
      ;-------------------------------------
      if ( not Ptr_Valid( pGlobalDataInfo ) ) then begin

         ; If PGLOBALDATAINFO doesn't exist, 
         ; define it from the THISDATAINFO structue
         pGlobalDataInfo = Ptr_New( ThisDataInfo ) 

      endif else begin 

         ; If PGLOBALDATAINFO exists, just 
         ; append THISDATAINFO structure into it
         CurDataInfo        = *(pGlobalDataInfo)
         *(pGlobalDataInfo) = [ CurDataInfo, ThisDataInfo ]

      endelse
 
   endif

   ; Return to calling program
   return
end
 
