; $Id: ctm_writenc.pro,v 1.1.1.1 2007/07/17 20:41:26 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        CTM_WRITENC
;
; PURPOSE:
;        Save GAMAP datainfo records to disk (in netCDF format)
;
; CATEGORY:
;        GAMAP Utilities, Scientific Data Formats
;
; CALLING SEQUENCE:
;        CTM_WRITENC, DATAINFO, FILENAME=FILENAME
;
; INPUTS:
;        DATAINFO -> a datainfo record or an array of datainfo records
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
; OUTPUTS:
;        A binary punch file with the selected data records will be
;        created.
;
; SUBROUTINES:
;        External Subroutines Required:
;        ====================================
;        CTM_GET_DATA
;        OPEN_FILE
;        DATATYPE
;
; REQUIREMENTS:
;        Must have a version of IDL w/ the netCDF library installed.
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
;        mgs, 20 May 1999: GAMAP VERSION 1.47
;                          - adapted from "ctm_writebpch.pro"
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
;
;-
; Copyright (C) 1999-2007, Martin Schultz,
; Bob Yantosca and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of 
; this software. If this software shall be used commercially or 
; sold as part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.harvard.edu with subject "IDL routine ctm_writenc"
;-----------------------------------------------------------------------

function CWN_Slice, Array, Dim, First

   I0 = First - 1L
   I1 = First + Dim - 2L

   return, Array[ I0:I1 ]
end

;-----------------------------------------------------------------------------

pro CTM_WriteNc, DataInfo, $
                 FileName=FileName, Scale=Scale, NewUnit=NewUnit
 
   ; Pass external functions
   FORWARD_FUNCTION DataType
   
   ; include global structures for fileinfo
   @gamap_cmn
 
   ; return if nothing to write
   if (n_elements(datainfo) eq 0) then return
   if (not chkstru(datainfo[0],['ILUN','CATEGORY','TRACER','DIM'])) then begin
      message,'Need a valid datainfo structure!',/Continue
      return
   endif

   if ( N_Elements( FileName ) eq 0  ) then FileName = 'gamap.nc'
   
   if (n_elements(scale) ne 1) then scale = 1.0 
   
   ;====================================================================
   ; Make sure all data is loaded
   ;
   ; NOTE: if CTM_GET_DATA cannot find any valid data blocks, 
   ;       check your "tracerinfo.dat" and "diaginfo.dat" files to
   ;       and make sure that the category and tracer numbers are 
   ;       listed properly. (bmy, 1/19/2000)
   ;====================================================================
   tmpdatainfo = datainfo
   ctm_get_data,datainfo,use_datainfo=tmpdatainfo
 
   ; get global fileinfo structure (if fileinfo is not passed!)
   fileinfo = *pGlobalFileInfo
 
   ; Create an array of structures to track used tracer names
   Used = Replicate( { ncstru, Name: '', VarID: 0L }, 4096 )

   ; Counters
   N_Recs  = 0L
   N_Names = 0L
   
   ;=================================================================
   ; Get dimensions
   ;=================================================================

   ; data storage times
   Tau0     = DataInfo[*].Tau0
   UniqTau0 = Tau0[ Uniq( Tau0, Sort( Tau0 ) ) ]
   N_Times  = N_Elements( UniqTau0 )

   ; Get global longitude dimension
   Ind = Where( DataInfo[*].Dim[0] eq DataInfo[0].Dim[0] )
   if ( Ind[0] lt 0 ) then print, 'Longitude dims differ!'
   N_Lons = DataInfo[0].Dim[0]

   ; Get Global latitude dimension
   Ind = Where( DataInfo[*].Dim[1] eq DataInfo[0].Dim[1] )
   if ( Ind[0] lt 0 ) then print, 'Latitude dims differ!'
   N_Lats = DataInfo[0].Dim[1]

   ; Get global altitude dimension
   Ind = Where( DataInfo[*].Dim[2] eq DataInfo[0].Dim[2] )
   if ( Ind[0] lt 0 ) then print, 'Altitude dims differ!'
   N_Levs = DataInfo[0].Dim[2]

   ;=================================================================
   ; Open netCDF file and create dimension arrays
   ;=================================================================

   ; Open file for output
   FileId = NCDF_Create( FileName, /Clobber )
 
   ; Do not use fill values
   NCDF_Control, FileID, /NoFill

   ; Time Dimension
   tID    = NCDF_DimDef( FileID, 'T', N_Times )
   TimeID = NCDF_VarDef( FileID, 'TIME',      [tID], /Double )

   ; Longitude Dimension
   if ( N_Lons gt 1 ) then begin
      xID   = NCDF_DimDef( FileID, 'X', N_Lons  )
      LonID = NCDF_VarDef( FileID, 'LONGITUDE', [xID], /Float  )
   endif

   ; Latitude Dimension
   if ( N_Lats gt 1 ) then begin
      yID   = NCDF_DimDef( FileID, 'Y', N_Lats  )
      LatID = NCDF_VarDef( FileID, 'LATITUDE',  [yID], /Float  )
   endif

   ; Sigma level Dimension
   if ( N_Levs gt 1 ) then begin
      zID   = NCDF_DimDef( FileID, 'Z', N_Levs  )
      SigID = NCDF_VarDef( FileID, 'SIGMA', [zID], /Float )
   endif
         
   ; Define Global Attributes
   NCDF_Attput, FileID, /Global, 'Title', 'NetCDF file created by GAMAP'
         
   ; Put netCDF file into data mode
   NCDF_Control, FileID, /EnDef
         
   ;=================================================================
   ; Store values in dimension arrays
   ; NOTE: Assume all data blocks come from the same model for now
   ;=================================================================   
   Ind = where( FileInfo.ilun eq Datainfo[0].ilun )
   if ( Ind[0] ge 0 ) then begin
      ModelInfo = Fileinfo[ Ind[0] ].modelinfo
      GridInfo  = CTM_Type( ModelInfo )
   endif

   Dim   = DataInfo[0].Dim
   First = DataInfo[0].First

   ; Time
   NCDF_VarPut, FileID, TimeID, UniqTau0, Count=[N_Times]
 
   ; Longitude
   if ( N_Lons gt 1 ) then begin
      Lons = CWN_Slice( GridInfo.XMid, Dim[0], First[0] )
      NCDF_VarPut, FileID, LonID, Lons, Count=[ N_Lons ]
   endif

   ; Latitude
   if ( N_Lats gt 1 ) then begin
      Lats = CWN_Slice( GridInfo.YMid, Dim[1], First[1] )
      NCDF_VarPut, FileID, LatID, Lats, Count=[ N_Lats ]         
   endif

   ; Altitude
   if ( N_Levs gt 1 ) then begin
      Levs = CWN_Slice( GridInfo.ZMid, Dim[2], First[2] )
      NCDF_VarPut, FileID, SigID, Sigma, Count=[ N_Levs ]         
   endif

   ;=================================================================
   ; Loop over each data block
   ;=================================================================      
   for N = 0L, N_Elements( DataInfo ) - 1L do begin

      ;=================================================================
      ; find associated FILEINFO that goes with this DATAINFO
      ;=================================================================
      find = where( fileinfo.ilun eq Datainfo[N].ilun )
      
      if ( find[0] lt 0 ) then begin
         message,'Cannot find FILEINFO for DATAINFO['+ $
            strtrim(i,2)+']! Skipping record ...',/Continue
         goto, Skip_It 
         
      endif else begin

         ; extract model information
         modelinfo   = fileinfo[find[0]].modelinfo
         mname       = StrTrim( ModelInfo.Name, 2 )
         mres        = float( modelinfo.resolution)
         mhalfpolar  = long( modelinfo.halfpolar )
         mcenter180  = long( modelinfo.center180 )
         GridInfo    = CTM_Grid( ModelInfo )
 
      endelse

      ;=================================================================      
      ; check if data has been loaded
      ;=================================================================
      if ( not Ptr_Valid( DataInfo[N].Data) ) then begin
         message,'Record '+strtrim(N,2)+  $
            ' contains no valid data! Skipping...', /Continue
         goto, Skip_It
      endif

      ;=================================================================      
      ; Extract attributes
      ;=================================================================      
      Category   = StrTrim( DataInfo[N].Category, 2 ) 
      TracerName = StrTrim( DataInfo[N].TracerName, 2 )
      Tracer     = Long( Datainfo[N].tracer ) mod 100L
      Tau0       = Datainfo[N].Tau0
      Tau1       = Datainfo[N].tau1
      Dimensions = Long( Datainfo[N].dim[0:2] )
      First      = Long( Datainfo[N].first )   
      Dim        = [ Dimensions, First ]
      TmpData    = Float( *( DataInfo[N].Data ) )

      if ( N_Elements( NewUnit ) eq 1 )            $
         then Unit = StrTrim( NewUnit,2 )          $
         else Unit = StrTrim( Datainfo[N].Unit, 2 )

      ; NCNAME is the name under which we will store the file
      NcName     = Category + '-' + TracerName

      ; T is the time index
      T          = Where( UniqTau0 eq DataInfo[N].Tau0 )
      T          = T[0]

      ;=================================================================
      ; If this is the first time index, then we must define 
      ; this variable in the netCDF file
      ;=================================================================
      if ( T eq 0L ) then begin

         ; Switch into definition mode
         NCDF_Control, FileID, /ReDef

         ; Set the shape for this variable (quickie if statement here)
         if ( N_Lons eq 1 ) then begin
            Shape = [ yID, zID, tID ]
            
         endif else if ( N_Lats eq 1 ) then begin
            Shape = [ xID, zID, tID ]

         endif else if ( N_Levs eq 1 ) then begin
            Shape = [ xID, yID, tID ]

         endif else begin
            Shape = [ xID, yID, zID, tID ]
         
         endelse

         ; Define this variable
         VarID = NCDF_VarDef( FileID, NcName, Shape, /Float )

         ; Switch into data mode
         NCDF_Control, FileID, /EnDef

         ; Update counters
         Used[N_Names].Name  = NcName
         Used[N_Names].VarID = VarID

         ; Update number of tracer names defined
         N_Names = N_Names + 1L
      endif

      ;=================================================================
      ; Write data to the netCDF file under the proper name
      ;=================================================================
      Ind = Where( Used[*].Name eq NcName )
      if ( Ind[0] ge 0 ) then begin

         ; Select the proper variable ID
         VarId = Used[Ind].VarID

         print, VarId, NcName, ":", Min( TmpData, Max=M ), M

         ; COUNT is the number of elements to write to disk
         Count = DataInfo[N].Dim
         Count = Count( Where( Count ge 0 ) )
         
         if ( Count[0] eq 1 ) then begin
            TmpData = Reform( TmpData )
            Count   = Count[1:*]
         endif
         
         if ( Count[1] eq 1 ) then begin
            TmpData = Reform( TmpData )
            Count   = Count[0, 2]
         endif

         if ( Count[2] eq 1 ) then begin
            TmpData = Reform( TmpData )
            Count   = Count[0:1]
         endif

         help, TmpData
         print, Count

         ; Write to the data array
         NCDF_VarPut, FileID, VarID, TmpData, Count=Count
      endif

      ; Increment number of records written to file
      N_Recs = N_Recs + 1

Skip_It:
   endfor

   ; Error check
   if ( N_Recs eq 0L ) then begin
      S = 'WARNING! No records have been written! Please delete the file!' 
      message, S, /Info
   endif
  
   ; Close file
Quit:
   NCDF_Close, FileID

   return
end
 
 
 
 
 
