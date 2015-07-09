; $Id: ctm_diff.pro,v 1.3 2004/01/29 20:16:16 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        CTM_DIFF
;
; PURPOSE:
;        Computes absolute or relative differences between two CTM
;        data blocks, and creates a new entry in the global DATAINFO
;        structure.
;
; CATEGORY:
;        CTM tools
;
; CALLING SEQUENCE:
;        CTM_DIFF, DIAGN, [, Keywords ]
;
; INPUTS:
;        DIAGN -> A diagnostic number or category name (see
;             (CTM_DIAGINFO). A value of 0 (or an empty string)
;             prompts processing of all available diagnostics.
;             DIAGN can also be an array of diagnostic numbers or
;             category names.
;
; KEYWORD PARAMETERS:
;        FILE -> File name or list of file names containing the data 
;             blocks to be differenced.  
;
;        ILUN -> Logical unit number, or list of logical unit numbers
;             of the files that contain the data blocks to be differenced.   
;
;        TAU0 -> A time value or list of values to restrict the search.
;             Default handling as with ILUN or TRACER. TAU0 superseeds
;             /FIRST, /LAST or TAURANGE.
;
;        TRACER -> Tracer ID number, or list of tracer ID numbers.  
;             CTM_DIFF will difference the data blocks for diagnostic 
;             DIAGN and tracer TRACER.
;
;        /PERCENT -> If set, will compute the percent difference
;             between two data blocks as 100 * ( DATA2 - DATA1 ) / DATA1.  
;             Default is to compute the absolute difference DATA2 - DATA1.  
;
;        NEWTRACER -> Returns to the calling program the tracer values
;             for the data blocks, as read in from disk.
;
;        NEWTAU -> Returns to the calling program the TAU0 values for
;             the data blocks, as read in from disk.
;
; OUTPUTS:
;        CTM_DIFF will append an entry to the global DATAINFO array of
;        structures pertaining to the difference between the data blocks.
;
; SUBROUTINES:
;        External Subroutines Requrired:
;        =========================================================
;        CTM_GET_DATA             CTM_MAKE_DATAINFO (function)
;        CTM_GRID     (function)  GAMAP_CMN         (include file)
;        INV_INDEX    (function)  YESNO             (function)
;        CTM_DIAGINFO 
;
; REQUIREMENTS:
;        References routines from GAMAP and TOOLS packages.
;
;        Also, currently will only look at data blocks with the same
;        tracer, since differencing two different tracers is not
;        always that productive. 
;
; NOTES:
;        (1) If DATA1 corresponds to the "old" data, and DATA2
;            corresponds to the "new" data, then CTM_DIFF will 
;            compute the following:
;         
;            Abs. Diff = ( new - old )
;            % Diff    = ( new - old ) / old
;
;        (2) The DATAINFO entries created by CTM_DIFF can be read into
;            GAMAP with the /NOFILE option.  The ILUN values of these 
;            data blocks will be negative, indicating derived data.
;
;        (3) The call to CTM_REGRID probably does not work yet.
;             Will get around to fixing that later...
;
; EXAMPLE:
;        (1) Call CTM_DIFF to compute an absolute difference between
;            two data blocks from two different punch files, at the
;            same TAU0 value, for OH (DIAGN='CHEM-L=$', TRACER=1).
;            
;            File = [ 'ctm.bpch.v4-30', 'ctm.bpch.v4-31' ] 
;            CTM_DIFF, 'CHEM-L=$', File=File, Tracer=1
;
;
;        (2) Call CTM_DIFF to compute a relative difference between
;            two data blocks from the same punch file, at two
;            different TAU0 values, for tracer 61 (Radon).
;
;            Ilun = 20
;            Tau0 = [ 74472L, 74640L ]
;
;            CTM_DIFF, 'IJ-AVG-$', Ilun=Ilun, Tau0=Tau0, $
;                  Tracer=61, /Percent
; 
; MODIFICATION HISTORY:
;        bmy, 23 Apr 1999: VERSION 1.00
;        mgs, 18 May 1999: - some bug fixes in error checks.
;                          - regridding still not tested !!
;        mgs, 10 Jun 1999: - bug fix for percent diference (indexing)
;        bmy, 15 Sep 1999: GAMAP VERSION 1.43
;                          - now use the GRIDINFO structure from the
;                            global FILEINFO structure, if it exists.
;                          - bug fix in call to CTM_GET_DATABLOCK
;                          - updated comments
;        bmy, 14 Jan 2000: GAMAP VERSION 1.44
;                          - now allow comparision of two different
;                            tracer numbers (e.g. for comparing two
;                            simulations w/ different tracer indices)
;                          - added error checking for size of the
;                            FILE, ILUN, TAU0, TRACER keywords
;                          - deleted obsolete code
;        bmy, 26 Jan 2000: GAMAP VERSION 1.45
;                          - now allow TAU0, FILE, ILUN, TRACER to have 
;                            0 elements w/o generating an error message
;        bmy, 15 Nov 2001: GAMAP VERSION 1.49
;                          - Now make sure that NEWTRACER is not a 
;                            multiple of 100, so that the tracer #
;                            will be saved correctly to the global 
;                            DATAINFO structure 
;        bmy, 22 Apr 2002: GAMAP VERSION 1.50
;                          - updated comments
;        bmy, 19 Nov 2003: GAMAP VERSION 2.01
;                          - Now get spacing between diagnostic
;                            offsets from CTM_DIAGINFO
;        bmy, 29 Jan 2004: - Added LEV keyword so that you can
;                            select just a single level
;                          - If we are just comparing a single level,
;                            then do not test altitude dimensions
;                            of the two data blocks.
;
;-
; Copyright (C) 1999-2004, Bob Yantosca, Harvard University
; This software is provided as is without any warranty
; whatsoever. It may be freely used, copied or distributed
; for non-commercial purposes. This copyright notice must be
; kept with any copy of this software. If this software shall
; be used commercially or sold as part of a larger package,
; please contact the author to arrange payment.
; Bugs and comments should be directed to bmy@io.harvard.edu
; with subject "IDL routine ctm_diff"
;-----------------------------------------------------------------------

pro CTM_Diff, DiagN, $
              File=File,        Tau0=Tau0,           $
              Ilun=Ilun,        Tracer=Tracer,       $
              Percent=Percent,  NewTracer=NewTracer, $
              NewTau=NewTau,    Lev=Lev,             $
              _EXTRA=e
 
   ; Pass external functions
   FORWARD_FUNCTION ChkStru, CTM_Grid, Inv_Index, YesNo
 
   ; GAMAP common blocks 
   @gamap_cmn
 
   ;====================================================================
   ; Keyword settings and error checking
   ;====================================================================
   Percent         = Keyword_Set( Percent )
   Save            = Keyword_Set( Save    )
   NeedsRegridding = 0
   NeedsPadding    = 0

   if ( N_Elements( Diagn ) eq 0 ) then begin
      Message, 'DIAGN must be passed to CTM_DIFF!', /Continue
      return
   endif

   ; Save elements of FILE to individual variables
   case ( N_Elements( File ) ) of
      0: ;Null Command
      
      1: begin
         File_1 = File[0]
         File_2 = File[0]
      end

      2: begin
         File_1 = File[0]
         File_2 = File[1]
      end

      else: begin
         Message, 'FILE must not have more than 2 elements!', /Continue
         return
      end       
   endcase
      
   ; Save elements of TAU0 to individual variables
   case ( N_Elements( Tau0 ) ) of
      0: ; Null command

      1: begin
         Tau0_1 = Tau0[0]
         Tau0_2 = Tau0[0] 
      end

      2: begin
         Tau0_1 = Tau0[0]
         Tau0_2 = Tau0[1]   
      end

      else: begin
         Message, 'TAU0 must not have more than 2 elements!', /Continue
         return
      end 
   endcase

   ; Save elements of ILUN to individual variables
   case ( N_Elements( Ilun ) ) of
      0: ; Null command

      1: begin
         Ilun_1 = Ilun[0]
         Ilun_2 = Ilun[0]   
      end

      2: begin
         Ilun_1 = Ilun[0]
         Ilun_2 = Ilun[1] 
      end

      else: begin
         Message, 'ILUN must not have more than 2 elements!', /Continue
         return
      end 
   endcase

   ; Save elements of TRACER to individual variables
   case ( N_Elements( Tracer ) ) of
      0: begin  ; Default to Ox
         Tracer_1 = 2 
         Tracer_2 = 2
      end 

      1: begin
         Tracer_1 = Tracer[0]
         Tracer_2 = Tracer[0] 
      end

      2: begin
         Tracer_1 = Tracer[0]
         Tracer_2 = Tracer[1] 
      end

      else: begin
         Message, 'TRACER must not have more than 2 elements!', /Continue
         return
      end 
   endcase

   ;====================================================================
   ; Find the first data block from the first file
   ;====================================================================
   CTM_Get_Data, DataInfo1, DiagN, $
      Tracer=Tracer_1, Tau0=Tau0_1, Ilun=Ilun_1, FileName=File_1 

   if ( N_Elements( DataInfo1 ) eq 0 ) then begin
      Message, 'No matching records found!', /Continue
      return
   endif
   if ( N_Elements( DataInfo1 ) gt 1 ) then begin
      Message, 'Only one record allowed for DataInfo1!', /INFO
      Message, 'Will use first record match.',/INFO,/NONAME
      ; do not return but quietly use frst record
   endif
 
   if ( Debug ) then begin
      print,'Datainfo 1 : ',n_elements(DataInfo1),' elements.'
      help,  datainfo1, /stru
      print, datainfo1.tracer
      print, datainfo1.category
      print, datainfo1.tau0
   endif
 
   ;====================================================================
   ; Find the second data block from the second file
   ;====================================================================
   CTM_Get_Data, DataInfo2, DiagN, $
      Tracer=Tracer_2, Tau0=Tau0_2, Ilun=Ilun_2, FileName=File_2
 
   if ( N_Elements( DataInfo2 ) eq 0 ) then begin
      Message, 'No matching records found!', /Continue
      return
   endif
   if ( N_Elements( DataInfo2 ) gt 1 ) then begin
      Message, 'Only one record allowed for DataInfo2!', /INFO
      Message, 'Will use first record match.',/INFO,/NONAME
   endif
 
   if ( Debug ) then begin
      print,'Datainfo 2 : ',n_elements(DataInfo2),' elements.'
      help,  datainfo2, /stru
      print, datainfo2.tracer
      print, datainfo2.category
      print, datainfo2.tau0
   endif

   ;====================================================================
   ; Get MODEL1, the MODELINFO structure for the first data block 
   ;====================================================================
   FileInfo = *pGlobalFileInfo

   DataInfo1 = DataInfo1[0]
   DataInfo2 = DataInfo2[0] 

   Ind = Where( FileInfo.Ilun eq DataInfo1.Ilun )
   
   if ( Ind[0] ge 0 ) then begin
      Model1 = FileInfo[ Ind[0] ].ModelInfo
   endif else begin
      S = 'Could not find a matching FILEINFO structure for DATAINFO!'
      Message, S, /Continue
      return
   endelse

   if ( ChkStru( Model1, ['NAME', 'RESOLUTION'] ) ) then begin   
      ; Nothing
   endif else begin
      Message, 'Data block 1 has an invalid MODELINFO structure!', /Continue
      return
   endelse

   ;====================================================================
   ; If there is a valid pointer to the GRIDINFO structure, use it!
   ; Otherwise construct a new GRIDINFO structure from MODEL1
   ; and attach it to the global FILEINFO structure.
   ;====================================================================
   if ( Ptr_Valid( FileInfo[ Ind[0] ].GridInfo ) ) then begin
      Grid1 = *( FileInfo[ Ind[0] ].GridInfo )
   endif else begin
      Ptr_Free, FileInfo[ Ind[0] ].GridInfo
      Grid1 = CTM_Grid( Model1 )
      FileInfo[ Ind[0] ].GridInfo = Ptr_New( Grid1 )
   endelse

   ;====================================================================
   ; Get MODEL2, the MODELINFO structure for the second data block 
   ;====================================================================
   Ind = Where( FileInfo.Ilun eq DataInfo2.Ilun )
 
   if ( Ind[0] ge 0 ) then begin
      Model2 = FileInfo[ Ind[0] ].ModelInfo
   endif else begin
      S = 'Could not find a matching FILEINFO structure for DATAINFO!'
      Message, S, /Continue
      return
   endelse

   if ( ChkStru( Model2, ['NAME', 'RESOLUTION'] ) ) then begin   
      ; Nothing
   endif else begin
      Message, 'Data block 2 has an invalid MODELINFO structure!', /Continue
      return
   endelse   
   
   ;====================================================================
   ; If there is a valid pointer to the GRIDINFO structure, use it!
   ; Otherwise construct a new GRIDINFO structure from MODEL2
   ; and attach it to the global FILEINFO structure.
   ;====================================================================
   if ( Ptr_Valid( FileInfo[ Ind[0] ].GridInfo ) ) then begin
      Grid2 = *( FileInfo[ Ind[0] ].GridInfo )
   endif else begin
      Ptr_Free, FileInfo[ Ind[0] ].GridInfo
      Grid2 = CTM_Grid( Model2 )
      FileInfo[ Ind[0] ].GridInfo = Ptr_New( Grid2 )
   endelse

   ;====================================================================
   ; Check the resolution of both models.  
   ; If they differ, then regridding is necessary.
   ;====================================================================
   if ( Total( Model1.Resolution ) ne Total( Model2.Resolution ) ) then begin
      S = 'Data blocks come from grids with different resolutions!'
      Message, S,  /Continue
      NeedsRegridding = 1
   endif

   ;====================================================================
   ; Check the starting longitudes & latitudes.  
   ; If they differ, then regridding is necessary.
   ;====================================================================
   if ( Grid1.XEDGE[0] ne Grid2.XEDGE[0]   OR $
        Grid1.YEDGE[0] ne Grid2.YEDGE[0] ) then begin
      S = 'Data blocks do not have the same starting lon or lat values!'
      Message, S, /Continue
      NeedsRegriding = 1
   endif

   ;====================================================================
   ; Check the dimensions of both data blocks.
   ; If they differ, then regridding is necessary.
   ;====================================================================
   ;----------------------------------------------------------------------
   ; Prior to 1/29/04:
   ;if ( Total( DataInfo1.Dim ) ne Total( DataInfo2.Dim ) ) then begin
   ;----------------------------------------------------------------------
   
   ; Check lon dimensions
   if ( DataInfo1.Dim[0] ne DataInfo2.Dim[0] ) then begin
      S = 'Data blocks have different LONGITUDE dimensions!' 
      Message, S, /Continue
      NeedsRegridding = 1
   endif

   ; Check lat dimensions
   if ( DataInfo1.Dim[1] ne DataInfo2.Dim[1] ) then begin
      S = 'Data blocks have different LATITUDE dimensions!' 
      Message, S, /Continue
      NeedsRegridding = 1
   endif      

   ; Check alt dimensions -- unless we only are plotting 1 level
   if ( N_Elements( Lev ) eq 0 ) then begin
      if ( DataInfo1.Dim[2] ne DataInfo2.Dim[2] ) then begin
         S = 'Data blocks have different ALTITUDE dimensions!' 
         Message, S, /Continue
         NeedsRegridding = 1
      endif
   endif

   ;====================================================================
   ; Check the I-J-L indices of the first grid box for both data 
   ; blocks.  If they differ, then regridding is necessary.
   ;====================================================================
   if ( Total( DataInfo1.First ) ne Total( DataInfo2.First ) ) then begin
      S = 'Data blocks start at different locations' 
      Message, S, /Continue
      NeedsRegridding = 1
      NeedsPadding    = 1
   endif

   ;====================================================================
   ; If regridding is needed, regrid DATA2 to match DATA1.
   ; Also pad DATA2 so that it begins at the same grid box
   ; as DATA1 does.
   ;====================================================================
   Data1 = *( DataInfo1.Data )

   ; Cut down the size of DATA1 if LEV is passed (bmy, 1/29/04)
   if ( N_Elements( Lev ) gt 0 ) $
      then Data1 = Data1[*,*,( (Lev-1) > 0 )]

;**** Work on this a little later on... (bmy, 4/27/99)
;   if ( NeedsPadding ) then begin
;      TmpData2 = FltArr( DataInfo[0].Dim
;   endif else begin
      TmpData2 = *( DataInfo2[0].Data )

      ; Cut down the size of DATA2 if LEV is passed (bmy, 1/29/04)
      if ( N_Elements( Lev ) gt 0 )                  $
         then TmpData2 = TmpData2[*,*,( (Lev-1) > 0 ) ] $
         else TmpData2 = TmpData2

;   endelse

   if ( NeedsRegridding ) then begin
      if ( YesNo( 'Dimensions do not agree!  Regrid DATA2?' ) ) then begin
         Data2 = CTM_Regrid( TmpData2, Grid2, Grid1 )
      endif else return

   endif else begin
      Data2 = TmpData2 

   endelse

   ;====================================================================
   ; Further error checking
   ;====================================================================

   ; Now make sure that NEWTRACER is not a multiple of SPACING, so that
   ; the tracer # will be saved correctly to the global DATAINFO structure. 
   ; (bmy, 11/15/01, 11/19/03) 
   if ( N_Elements( NewTracer ) eq 0 ) then begin
      CTM_DiagInfo, DiagN, Spacing=Spacing
      NewTracer = DataInfo1.tracer mod Spacing[0]
   endif
 
   if ( N_Elements( NewTau ) eq 0 ) then   $
      NewTau = [ min( DataInfo1.Tau0 ), max( DataInfo1.Tau1 ) ]
   
   if ( N_Elements( NewTau ) eq 1 ) then   $
      NewTau = [ NewTau, NewTau+1 ]
 
   ;====================================================================
   ; If /PERCENT is set, then compute the percent difference 
   ; between the two data blocks = 100 * ( DATA2 - DATA1 ) / DATA1.  
   ; Be careful not to divide by zero.
   ;
   ; If /PERCENT is not set, then just compute the absolute
   ; difference DATA2 - DATA1.
   ;
   ; If we assume DATA2 is the "new" data and DATA1 is the "old" data
   ; then the absolute difference will be computed as ( new - old ) 
   ; and the percent difference will be computed as ( new - old ) / old.  
   ; This is consistent with established usage. (bmy, 4/22/02)
   ;====================================================================
   Diff = Data2 - Data1
 
   if ( Percent ) then begin
      Ind  = Where( Data1 ne 0. )
      if ( Ind[0] ge 0 ) then begin
 
         ; Only divide by non-zero points
         Diff[Ind] = ( Diff[Ind] / Data1[Ind] ) * 100.0
         
         ; Set DIFF = a large number where DATA1 = 0, 
         ; but set DIFF = 0 where DATA1 = 0 AND DATA2 = 0
         Ind2 = Inv_Index( Ind, n_elements( Data1 ) )
         if ( Ind2[0] ge 0 ) then begin
            Ind3 = Where( Data2[Ind2] eq 0 )
            if ( Ind3[0] ge 0 ) then begin
               Diff[Ind2] = -9.99e30
               Diff[Ind2[Ind3]] = 0.00e0
            endif else begin
               Diff[Ind2] = -9.99e30
            endelse
         endif

      endif else begin
         S =  'WARNING: Cannot produce a % difference since ' + $
              'DATA1 is zero everywhere!'
         Message, S, /Continue
         return
      endelse         
   endif
   
   ;====================================================================
   ; If /PERCENT is set then this is a percent difference
   ;====================================================================
   if ( Percent ) then Unit = '%' else Unit = DataInfo1[0].Unit 

   ;====================================================================
   ; Now that all of the error checking has been done, save the 
   ; difference of the two data blocks as a new DATAINFO entry.
   ; This entry will have a negative mod
   ;
   ; If /SAVE is set, then don't add the new FILEINFO and DATAINFO 
   ; entries to the global structures, but save them so that they
   ; can be written to a binary punch file.
   ;====================================================================
   Result = CTM_Make_Datainfo( Diff, NewD, NewF,              $
                               Model=Model1,                  $
                               Grid=Grid1,                    $
                               Diagn=DataInfo1[0].Category,   $
                               Tracer=NewTracer,              $
                               Tau0=NewTau[0],                $
                               Tau1=NewTau[1],                $
                               Unit=Unit,                     $
                               Dim=DataInfo1.Dim,          $
                               First=DataInfo1.First )
 
   if ( Result ) then $
      Message,'Successfully added selected datablocks.',/INFO  $
   else begin
      Message,'Something went wrong! STOP.',/Cont
      stop
   endelse

   return
end
 
