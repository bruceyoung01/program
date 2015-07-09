; $Id: ctm_writebpch.pro,v 1.3 2004/06/03 17:58:09 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        CTM_WRITEBPCH
;
; PURPOSE:
;        Save GAMAP datainfo records to disk 
;        (in binary punch file format).
;
; CATEGORY:
;        CTM tools
;
; CALLING SEQUENCE:
;        CTM_WRITEBPCH, DATAINFO, [, Keywords ]
;
; INPUTS:
;        DATAINFO -> a datainfo record or an array of datainfo records
; 
;        FILEINFO -> a fileinfo record or an array of fileinfo records
;
; KEYWORD PARAMETERS:
;        FILENAME -> Filename of output file. Should end in '.bpch'.
;
;        SCALE -> An optional scaling factor. This factor will be applied 
;             to _all_ data record upon saving. The globally stored records
;             are not affected.
;
;        NEWUNIT -> With this keyword you can change the unit _name_ for
;             the saved data. This will _not_ perform a unit conversion!
;             For a true unit conversion you must also use the SCALE
;             keyword. NEWUNIT will be applied to _all_ records!
;
;        /APPEND -> If set, then will append to an existing binary
;             punch file rather than writing to a new file.
;
; OUTPUTS:
;        A binary punch file with the selected data records will be
;        created.
;
; SUBROUTINES:
;
; REQUIREMENTS:
;        Uses ctm_get_data, open_file, datatype, CHKSTRU
;
; NOTES:
;        This routine forces reading of all selected data records via
;        ctm_get_data. This may take a while for huge ASCII punch files.
;
; EXAMPLE:
;        gamap [,options]  ; call gamap to read records from a file
;        @gamap_cmn        ; get global datainfo structure
;        d = *pglobalDataInfo 
;        ind = where(d.tracer eq 2)  ; select all Ox records
;        ctm_writebpch,d[ind],filename='oxconc.bpch'
;        
; MODIFICATION HISTORY:
;        mgs, 20 May 1999: VERSION 1.00
;                          - stores binary files version 1
;        mgs, 24 May 1999: VERSION 2.00
;                          - stores binary files version 2
;        bmy, 26 Jul 1999: VERSION 2.01
;                          - now call function DATATYPE
;                          - make sure only floating point data gets
;                            written to binary punch file v. 2.0
;        bmy, 19 Jan 2000: - updated commetns
;        bmy, 07 Jun 2000: GAMAP VERSION 1.45
;                          - Save TRACER mod 100L to the punch file 
;                          - updated comments
;        bmy, 02 Mar 2001: GAMAP VERSION 1.47
;                          - added FILEINFO as an argument; will use
;                            PGLOBALFILEINFO structure if not passed
;                          - removed obsolete comments
;        bmy, 13 Mar 2001: - now supports Windows, MacOS, and Unix/Linux
;        bmy, 07 Jun 2001: - removed obsolete code from 7/26/99
;  mje & bmy, 17 Dec 2001: GAMAP VERSION 1.49
;                          - added /APPEND keyword in order to
;                            append to an existing binary punch file
;                          - updated comments
;        bmy, 15 Oct 2002: GAMAP VERSION 1.52
;                          - added LEVELSAVE keyword to define certain
;                            levels which to save to disk
;                          - Updated comments, cosmetic changes
;        bmy, 19 Nov 2003: GAMAP VERSION 2.01
;                          - now get diagnostic spacing from CTM_DIAGINFO
;                            and write TRACER mod SPACING to the BPCH file.
;        bmy, 27 May 2004: GAMAP VERSION 2.02
;                          - Bug fix: Don't call CTM_GET_DATA to initialize
;                            data pointers if this has been done already
;                          - removed LEVELSAVE keyword
;
;-
; Copyright (C) 1999, 2000, 2001, 2002, 2003, 2004
; Martin Schultz and Bob Yantosca, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author to arrange payment.
; Bugs and comments should be directed to mgs@io.harvard.edu
; or bmy@io.harvard.edu with subject "IDL routine ctm_writebpch"
;-----------------------------------------------------------------------


pro CTM_WriteBpch, DataInfo, FileInfo,                $
                   FileName=FileName, Scale=Scale,    $
                   NewUnit=NewUnit,   Append=Append
   
   ;====================================================================
   ; Initialization
   ;====================================================================

   ; Pass external functions
   FORWARD_FUNCTION ChkStru, DataType, Little_Endian
   
   ; Include global structures for fileinfo
   @gamap_cmn
 
   ; Error check keywords
   if ( N_Elements( DataInfo  ) eq 0 ) then return
   if ( N_Elements( Scale     ) ne 1 ) then Scale = 1.0 

   ; Make sure DATAINFO is a valid structure
   if (not ChkStru(DataInfo[0],['ILUN','CATEGORY','TRACER','DIM'])) then begin
      Message, 'Need a valid datainfo structure!', /Continue
      return
   endif

   ; Get the diagnostic spacing (same for all categories)
   CTM_DiagInfo, DataInfo[0].Category, Spacing=Spacing
   Spacing = Spacing[0]

   ;==================================================================== 
   ; Make sure all data is loaded
   ;
   ; NOTE: if CTM_GET_DATA cannot find any valid data blocks, 
   ;       check your "tracerinfo.dat" and "diaginfo.dat" files to
   ;       and make sure that the category and tracer numbers are 
   ;       listed properly. (bmy, 1/19/2000)
   ;====================================================================
   
   ; Check if the pointer to the 1st data block has been initialized
   ; This should be OK since all of the data blocks in the DATAINFO 
   ; structure will come either from GAMAP or from CTM_MAKE_DATAINFO.
   ; (bmy, 5/27/04)
   Is_Valid = Ptr_Valid( DataInfo[0].Data )

   ; Call CTM_GET_DATA to intialize the pointer to each data block
   ; in DATAINFO if this has not been done before (bmy, 5/27/04)
   if ( not Is_Valid ) then begin
      TmpDataInfo = DataInfo
      CTM_Get_Data, DataInfo, Use_DataInfo=TmpDataInfo
   endif

   ; Get global fileinfo structure (if fileinfo is not passed!)
   if ( N_Elements( FileInfo ) eq 0 ) then FileInfo = *pGlobalFileInfo
 
   ; Open output file
   if ( N_Elements( FileName ) eq 0 ) then FileName = ''

   ; Now supports Windows, MacOs, and Unix/Linux (bmy, 3/13/01)
   if ( FileName eq '' ) then begin
      case ( StrUpCase( StrTrim( !VERSION.OS_FAMILY, 2 ) ) ) of
         'UNIX'    : FileName = DefaultPath + '/*.bpch'
         'WINDOWS' : FileName = DefaultPath + '\*.bpch'
         'MACOS'   : FileName = DefaultPath + ':*.bpch'
         else      : Message, '*** Operating system not supported! ***'
      endcase
   endif
   
   ;==================================================================== 
   ; Open file for output and write top header
   ;==================================================================== 

   ; Added /APPEND keyword in call to OPEN_FILE, which will append
   ; to an existing file rather than create a new file (mje, 12/17/01)
   Open_File, filename, Olun, /Write,                       $
      Title='Save as binary punch file',  /F77_Unformatted, $
      Swap_Endian=Little_Endian(),        Append=Append
 
   ; Return if we could not open the file
   if ( Olun le 0 ) then return   
 
   ; If APPEND=0, then write the top-of-file header
   if ( not( Keyword_set( Append ) ) ) then begin
      FTI      = Str2Byte( 'CTM bin 02', 40 )
      toptitle = Str2Byte( 'CTM output saved by GAMAP '+ StrDate(), 80 )
      WriteU, Olun, FTI
      WriteU, Olun, TopTitle
   endif

   ;====================================================================
   ; For each DATAINFO record, write header, dimensional info and data 
   ;====================================================================

   ; Number of records processed
   NRecs = 0L

   ; Loop over all elements of DATAINFO array of structures
   for I = 0L, N_Elements( DataInfo ) - 1L do begin
 
      ; find associated fileinfo
      find = where(fileinfo.ilun eq datainfo[i].ilun)

      ; Extract MODELINFO from FILEINFO structure (if possible)
      if ( find[0] lt 0 ) then begin

         ; ERROR: not found
         message,'Cannot find FILEINFO for DATAINFO['+ $
            strtrim(i,2)+']! Skipping record ...',/Continue
         goto, Skip_It 

      endif else begin

         ; extract fields from MODELINFO
         Modelinfo   = FileInfo[find[0]].ModelInfo
         Mname       = Str2Byte( ModelInfo.Name, 20 )
         Mres        = Float( ModelInfo.Resolution )
         MHalfPolar  = Long( ModelInfo.HalfPolar )
         MCenter180  = Long( ModelInfo.Center180 )

      endelse
 
      ; Check if data has been loaded
      if ( not Ptr_Valid( DataInfo[I].Data) ) then begin
         S = 'Record '+strtrim(i,2)+  ' contains no valid data! Skipping...'
         Message, S, /Continue
         goto, Skip_It
      endif

      ; If NEWUNIT is passed, convert that to a 40-element byte array
      ; Otherwise, use the unit string from the DATAINFO structure
      if ( N_Elements( NewUnit ) eq 1 )               $
         then Unit = Str2Byte( NewUnit,          40 ) $
         else Unit = Str2Byte( DataInfo[I].Unit, 40 )
 
      ; Get other quantities from DATAINFO
      Category   = Str2Byte( DataInfo[I].Category, 40 )
      Tracer     = Long( DataInfo[I].tracer ) mod Spacing
      Tau0       = Datainfo[I].Tau0
      Tau1       = Datainfo[I].Tau1
      Reserved   = BytArr( 40 )
      Dimensions = Long( DataInfo[I].Dim[0:2] )
      First      = Long( DataInfo[I].First )  ; FORTRAN indices (start from 1) 
      Dim        = [ Dimensions, First ]
      Skip       = 4L *  ( Dim[0] * Dim[1] * Dim[2]  ) + 8L
 
      ; Write header for each DATAINFO record
      WriteU, Olun, Mname, Mres, MHalfPolar, MCenter180
      WriteU, Olun, Category, Tracer, Unit, Tau0, Tau1, Reserved, Dim, Skip

      ;=================================================================
      ; Extract data array from DATAINFO and cast it to floating point
      ; data (IDL type 4) if necessary).  GAMAP will have problems 
      ; reading a binary punch file unless the data array is FLOAT.
      ;=================================================================
      TmpData  = *(datainfo[i].data)

      case ( DataType( TmpData ) ) of
         2: begin  ; Fix
            Message, 'Converting data from type FIX to type FLOAT!', /Info
            TmpData = Float( TmpData )
         end

         3: begin  ; Longword
            Message, 'Converting data from type LONG to type FLOAT!', /Info
            TmpData = Float( TmpData )
         end

         4:        ; Floating point

         5: begin  ; Double precision
            Message, 'Converting data from type DOUBLE to type FLOAT!', /Info
            TmpData = Float( TmpData )
         end

         else: begin
            Message, 'Invalid data type!  Cannot write to punch file!', $    
               /Continue
            return
         end
      endcase

      ; Write floating point data to punch file
      WriteU, Olun, TmpData * Scale

      ; Increment number of records written to file
      NRecs = NRecs + 1L

Skip_It:
   endfor
 
   ;====================================================================
   ; Cleanup and quit
   ;====================================================================

   ; Close file and free unit number
   Close,    Olun
   Free_LUN, Olun

   ; Error message if nothing was written to disk
   if ( NRecs eq 0L ) then begin
      Message,                                                            $
         'WARNING! No records have been written! Please delete the file!',$
          /INFO
   endif
 
   return
end
 
 
 
 
 
