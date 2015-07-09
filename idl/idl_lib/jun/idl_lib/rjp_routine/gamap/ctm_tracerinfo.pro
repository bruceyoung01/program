; $Id: ctm_tracerinfo.pro,v 1.3 2004/06/03 17:58:08 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        CTM_TRACERINFO
;
; PURPOSE:
;        Return information about one or all tracers for a given
;        GEOS-CHEM, GISS, or other CTM diagnostic.
;
; CATEGORY:
;        GAMAP
;
; CALLING SEQUENCE:
;        CTM_TRACERINFO, TRACERN, TRACERSTRU [, Keywords ]
;
; INPUTS:
;        TRACERN -> tracer number or name for which to extract the 
;            information. If TRACERN is numeric, it is interpreted as 
;            an index to the FULLCHEM or SMALLCHEM tracernumber
;            in the global model. If it is a string, it will be compared 
;            to NAME then FULLNAME. TRACERN may contain more than one 
;            element. To retrieve information about all tracers, use the
;            /ALL_TRACERS keyword.
;
; KEYWORD PARAMETERS:
;        /ALL_TRACERS -> retrieve information about all tracers
;
;        FILENAME --> name of the tracerinfo file (default tracerinfo.dat)
;            The file will be searched in the current directory first, then
;            in the directory where ctm_tracerinfo.pro is located. If not found
;            in either location, a standard data block is retrieved from this 
;            file.
;
;        /FORCE_READING -> overwrite the contents of the common block
;
;        FULLNAME -> returns the (long) name of the requested tracer(s)
;
;        INDEX -> returns the CTM index of the requested tracer(s)
;
;        MOLC -> returns the carbon number of the requested tracer(s)
;             (For hydrocarbons, this is the # moles C/mole tracer)
;
;        MOLWT -> returns the molecular weight (kg/mole) of the 
;             requested tracer(s)
;
;        NAME -> returns the (short) name of the requested tracer(s)
;
;        SCALE -> standard scale factor for tracer
;
;        UNIT -> returns the standard unit of the requested tracer(s)
;             (i.e. unit as supplied by CTM with standard scale factor 
;             applied (e.g. ppbv instead of V/V))
;
; OUTPUTS:
;        TRACERSTRU -> returns a structure or structure array with the 
;            following tags:
;               NAME     : short name for tracer as used in the model
;               FULLNAME : long name for tracer (may be used in titles)
;               MWT      : molec. weight as kg N or kg C 
;               INDEX    : tracer number
;               MOLC     : carbon number for NMHC
;               SCALE    : standard scale factor
;               UNIT     : standard unit for tracer with scale factor applied
;
; SUBROUTINES:
;
; REQUIREMENTS:
;        External Subroutines Required:
;        ================================================
;        FILE_EXIST (function)   ROUTINE_NAME (function)
;        OPEN_FILE 
;
; NOTES:
;        At first call, the tracer information structure array is
;        either read from file or retrieved from the
;        DATA block at the end of this program. Thereafter, the information
;        is stored in a common block where it is accessible in subsequent 
;        calls.
;        The newer tags MOLC, SCALE and UNIT are optional and defaulted
;        to 1.0, 1.0, and 'UNDEFINED', resp.
;
; EXAMPLE:
;        CTM_TRACERINFO, 2, RES
;        PRINT, RES.NAME, RES.MWT, RES.INDEX
;        ; prints        Ox    0.0480000     2
;
;        CTM_TRACERINFO,'OX',RES
;        PRINT, RES.NAME, RES.MWT, RES.INDEX
;        ; prints identical results
;
;        CTM_TRACERINFO,[1,3,5],NAME=NAME,MOLWT=MWT,MOLC=MOLC,/FORCE_READING
;        PRINT, NAME, MWT, MOLC
;        ; reads tracerinfo.dat file and prints 
;        ; NOx PAN ALK4
;        ; 0.0140000     0.121000    0.0120000
;        ; 1.00000      1.00000      4.00000
;
; MODIFICATION HISTORY:
;        mgs, 22 Apr 1998: VERSION 1.00
;        mgs, 24 Apr 1998: - added NAME keyword
;        bmy, 07 May 1998: - added MOLC structure field to store 
;                            carbon number for NMHC
;        mgs, 07 May 1998: VERSION 2.00
;                          - substantially revised
;        mgs, 08 May 1998: - added SCALE and UNIT tags, made them optional
;        mgs, 28 May 1998: - bug fix with on_ioerror
;        mgs, 09 Oct 1998: - bug fix for tracern=0, changed CALLING SEQ. entry
;        mgs, 12 Nov 1998: - unit string now defaulted to 'UNDEFINED' 
;        bmy, 03 Jan 2001: GAMAP VERSION 1.47
;                          - skip tracer lines beginning with '#' character
;        bmy, 17 Nov 2003: GAMAP VERSION 2.01
;                          - Removed FULLI, SMALLI, they're obsolete
;                          - now use INDEX for tracer number
;                          - Now use new file format for "tracerinfo.dat"
;                            which allows for 8-digit offset numbers
;                          - No longer read defaults from internal datablock
;                          - Updated comments 
;        bmy, 06 Apr 2004: GAMAP VERSION 2.02
;                          - added /VERBOSE keyword
;
;-
; Copyright (C) 1998, 2001, 2003, 2004,
; Martin Schultz and Bob Yantosca, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author to arrange payment.
; Bugs and comments should be directed to mgs@io.harvard.edu
; or bmy@io.harvard.edu with subject "IDL routine ctm_tracerinfo"
;-----------------------------------------------------------------------

  
pro CTM_TracerInfo, TracerN, TracerStru,                            $
                    All_tracers=All_Tracers,     Index=Index,       $
                    Name=Name,                   FullName=FullName, $
                    Molwt=Mwt,                   MolC=MolC,         $
                    Scale=Scale,                 Unit=Unit,         $
                    Force_Reading=Force_Reading, Filename=Filename, $
                    Verbose=Verbose
 
   ;====================================================================
   ; Initialization
   ;====================================================================

   ; common block stores pointer to information for future calls
   common TracerCom, pTracerInfo
 
   ; sample structure for void return
   Sample = { TStru,          $
              Name     : '',  $
              FullName : '',  $
              Mwt      : 0.0, $
              Index    : 0L,  $
              MolC     : 1.0, $
              Scale    : 1.0, $
              Unit     : 'UNDEFINED' }
 
   ; Initialize pointer at first call
   if ( N_Elements( pTracerInfo ) eq 0 ) then pTracerInfo = Ptr_New()

   ; Add VERBOSE keyword (bmy, 4/6/04)
   Verbose = Keyword_Set( Verbose )

   ;====================================================================
   ; If TRACERINFO contains no elements (or /FORCE_READING is set),
   ; then read the "tracerinfo.dat" file -- first look in current 
   ; directory, then in the directory of this procedure.
   ;====================================================================
   if ( Keyword_Set( Force_Reading )   OR $
        not Ptr_Valid( pTracerInfo ) ) then begin

      ; Assume default filename
      if ( N_Elements( FileName ) eq 0 ) then FileName = 'tracerinfo.dat'

      ; If not found, look for it in the directory of this procedure
      if ( not file_exist( filename, full=full ) ) then begin
         dum = routine_name( filename=profilename )
         if (file_exist(profilename,path=!PATH,full=full)) then begin
            filename = extract_path(full)+filename
            if (not file_exist(filename,full=full)) then filename = ''
         endif 
      endif
 
      ;=================================================================
      ; Read data from FILENAME
      ;=================================================================
      if ( FileName eq '' ) then begin

         ; Exit 
         Message, 'FILENAME not passed!', /Continue
         return

      endif else begin

         ; Echo info
         S = 'Reading ' + StrTrim( Full, 2 ) + ' ...'
         Message, S, /Info
         
         ; Open file for reading
         Open_File, Full, Ilun, /Get_LUN

         ; Initialize
         Line      = ''
         FirstTime = 1L

         ; Loop thru input file
         while ( not EOF( Ilun ) ) do begin
            
            ; Read a line from the file
            ReadF, Ilun, Line

            ; Comment lines begin with '#' in the first column
            if ( StrMid( Line, 0, 1 ) ne '#' ) then begin

               ; This is not a comment line -- store into SDATA array 
               if ( FirstTime ) then begin
                  SData     = Line
                  FirstTime = 0L
               endif else begin
                  SData     = [ SData, Line ]
               endelse

            endif

         endwhile   

         ; Close input file
         Close,    Ilun
         Free_LUN, Ilun

      endelse
 
      ;=================================================================     
      ; Extract data from string array SDATA   
      ;=================================================================
      if ( SData[0] eq '') then begin
         Message, 'Could not retrieve tracer information !'
      endif
 
      ; Create array of structures to store tracer info
      TracerStru = Replicate( Sample, N_Elements( SData ) )
 
      ; Loop over all lines of the file
      for I = 0L, N_Elements( SData )-1L do begin

         ; Initialize
         Name     = ''
         FullName = ''
         Mwt      = 0.0
         Index    = 0L
         MolC     = 1.0
         Scale    = 1.0
         Unit     = ''

         ; Print if /VERBOSE is set
         if ( Verbose ) then Print, SData[I]

         ; Extract fields from each line -- new format!
         ReadS, SData[I],                                  $
            Name, FullName, MWt, MolC, Index, Scale, Unit, $
            Format='(a8,1x,a30,e10.0,i3,i9,e10.3,1x,a)'

         ; Store information in the structure fields
         TracerStru[I].Name     = StrTrim( Name,     2 )          
         TracerStru[I].FullName = StrTrim( FullName, 2 )          
         TracerStru[I].Unit     = StrTrim( Unit,     2 )
         TracerStru[I].Mwt      = Float( Mwt )
         TracerStru[I].Index    = Index
         TracerStru[I].MolC     = MolC
         TracerStru[I].Scale    = Scale
      endfor
      
      ; Echo information
      S = 'Retrieved information about ' + $
           StrTrim( String( N_Elements( TracerStru ), Format='(i10)' ), 2 ) + $
           ' tracers'
      Message, S, /Info

      ; Delete all entries with tracernumber le 0
      Ind = Where( TracerStru.Index gt 0 )
      if ( Ind[0] ge 0 ) then begin
         TracerStru = TracerStru[Ind]
      endif else begin
         Message, 'No valid records found!', /Continue
         return
      endelse

      ; store as pointer (delete old one)
      if ( Ptr_Valid( pTracerInfo) ) then Ptr_Free, pTracerInfo
      pTracerInfo = Ptr_New( TracerStru, /No_Copy )
      
   endif
   
   ;====================================================================
   ; Now return information that the user has selected
   ;====================================================================

   ; If /ALL_TRACERS is set, return info about all tracers
   if ( Keyword_Set( All_Tracers ) ) then begin
      TracerStru = *pTracerInfo 
      Index      = TracerStru[*].Index
      Name       = TracerStru[*].Name
      FullName   = TracerStru[*].FullName
      Mwt        = TracerStru[*].Mwt
      MolC       = TracerStru[*].Molc
      Scale      = TracerStru[*].Scale
      Unit       = TracerStru[*].Unit
      return
   endif

   ; initialize return values for no valid tracer
   TracerStru = sample 
   Index      = -1
   Name       = ''
   FullName   = ''
   Mwt        = 1.000
   Molc       = 1.
   Scale      = 1.
   Unit       = ''
   Ind        = -1
 
   ; nothing requested -- just return
   if ( N_Elements( TracerN ) eq 0) then return 

   ; check if tracern is numeric (i.e. index) or string (i.e. name)
   S = Size( TracerN, /TYPE )

   ; ERROR -- bad argument type, so return
   if ( S eq 6 OR S gt 7 ) then return 
   
   ; loop through all tracern arguments and try to find them
   for i = 0L, N_Elements( TracerN )-1L do begin
      
      if ( S eq 7 ) then begin    

         ; tracer identified by name or FullName
         tind = where(strupcase((*ptracerinfo).name) eq $
                      strupcase(tracern[i])) 

         if (tind(0) lt 0) then begin
            tind = where(strupcase((*ptracerinfo).FullName) eq $
                         strupcase(tracern[i])) 
         endif
            
      endif else begin          
         
         ; tracer identified by CTM index            
         tind = where((*ptracerinfo).Index eq Long(tracern[i])) 

      endelse
      
      ind = [ ind, tind ]
   endfor
   
   ; Remove dummy
   ind = temporary(ind[1:*])    
   
   ; Create array of structures to contain each tracer info
   TracerStru = Replicate( sample, N_Elements(ind) )

   ; Found desired tracers ? 
   Tind = where( ind ge 0 )

   ; Return information for each requested tracer
   if ( Tind[0] ge 0 ) then begin
      TracerStru[tind] = (*ptracerinfo)[ind[tind]]
      Index    = TracerStru[*].Index
      Name     = TracerStru[*].Name
      FullName = TracerStru[*].FullName
      Mwt      = TracerStru[*].Mwt
      Molc     = TracerStru[*].Molc
      Scale    = TracerStru[*].Scale
      Unit     = TracerStru[*].Unit
   endif

   ; Return keywords as scalars if only one tracer was requested
   if ( N_Elements( Ind ) eq 1 ) then begin
      ;  TracerStru = TracerStru[0]
      Index    = Index[0]
      Name     = Name[0]
      FullName = FullName[0]
      Mwt      = Mwt[0]
      Molc     = Molc[0]
      Scale    = Scale[0]
      Unit     = Unit[0]
   endif
   
   return
end
