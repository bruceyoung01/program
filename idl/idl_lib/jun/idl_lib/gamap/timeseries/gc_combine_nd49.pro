; $Id: gc_combine_nd49.pro,v 1.3 2008/07/17 14:10:17 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        GC_COMBINE_ND49
;
; PURPOSE:
;        Combine timeseries data from the Geos-CHEM ND49
;        diagnostics that are spread over a series of daily binary
;        punch files. Note that met fields are in that same format.
;
;        (1) We combine all the data blocks for one tracer (there is
;        one per time step) into one single 4-D data block (with time
;        in 4th dimension). This takes advantage of support for 4D
;        dataset in GAMAP v2-10.
;
;        (2) The combined series can be saved into a binary punch
;        file. You end up with one file per tracer that covers many
;        days of output, instead of one file per day for all tracers.
;
;        (3) A subarea (even a single location) can be extracted. But
;        for multiple but not contiguous locations, call the routine
;        as many time as needed.
;
;        (4) Shorter timeseries can be selected/saved, by specifying
;        Tau range, or day (as YYYYMMDD long integer) range if daily
;        max or average is selected.
;
;        (5) Two basic signal processing before saving the data can be
;        performed: moving average and/or daily maximum.
;
;        ## LIMITATION ## : full days considered, i.e., GEOS-Chem runs
;        should start and end at midnight (YYYYMMDD 000000)
;
; CATEGORY:
;        GAMAP Utilities, GAMAP Data Manipulation, Time Series
;
; CALLING SEQUENCE:
;        GC_COMBINE_ND49 [, TRACER ][, CATEGORY ][, Keywords ]
;
; INPUTS:
;        TRACER -> The tracer number. Default is 1.
;
;        CATEGORY -> The category name (default is "IJ-AVG-$")
;             for which to read data.
;
; KEYWORD PARAMETERS:
;
;        ;============ For I/O files/directory =====================
;
;        FILELIST -> list of files to process. Usually used as output
;             keyword to get the list of files selected with INDIR and
;             MASK or through a dialog window.
;             Can be used as input. Then INDIR and MASK are ignored.
;
;        INDIR -> Directory where to look for 'ts*.bpch' files. Must
;             end with separator. If provided, ALL files satisfying
;             the MASK keyword in the directory will be selected. If
;             not provided, a dialog window that allows multiple
;             files selection (keep SHIFT key down) will
;             pop-up. See EXAMPLES below for tips.
;
;             If set to an undefined variable name, it will hold the
;             directory of the selected files (output keyword).
;
;             NOTE: If more than one file is processed, it is assumed
;             that, once sorted in alphabetical order, they are in
;             chronological order (this is the case with GEOS-Chem
;             default naming of ND49 output files: they contain
;             YYYYMMDD).
;
;        MASK -> Pattern Mask to find files in INDIR. Default is
;             "ts*.bpch".
;
;        OUTDIR -> Output directory where file with new timeseries
;             data set will be. Default is INDIR.
;
;        OUTFILENAME -> Name of the file that will contain the
;             timeseries. Default is 'combts_%TRACERNAME%.bpch', for
;             COMB ined  T ime  S eries.
;
;            The routine prevents from overwriting any input file.
;
;        ;============ To extract subset of data ===================
;
;        LON -> A one or two-elements vector specifying the longitude
;            of one location or one area. If LON is outside the ND49
;            area, the program print a warning, and uses border
;            value.
;
;        LAT -> same as LON, but for Latitudes
;
;        LEV -> same as LON, but for Levels. Refers to the model grid.
;
;
;        ; - - you can also select indices into the requested 3D cube:
;
;        LLEV -> A one or two-element vector specifying the min and
;             max of available levels to be included in the file.
;             Default is ALL available levels.
;             Default FORTRAN indexing is used: LLEV #1 is the first
;             level ***requested*** in ND49. See LEV above otherwise.
;
;        ILON, JLAT -> same as LLEV but for Longitude and Latitude
;             indices. Starting at 1 at the first ***requested***
;             grid box in ND49.
;
;
;        TIME -> vector for selecting time span. The data covering
;              [min(TIME),max(TIME)] are selected. If only one
;              element, then the closest-in-time data are selected.
;              TIME must be given as Tau (double) or YYYYMMDD (long)
;              if /DMAX or /DAVG.
;              If both DMAX (or DAVG) and LOCALTIME are set, TIME is
;              ignored. 
;
;          ** TIP ** if you select a short time span, it may be
;                    useful to limit the number of files to process
;                    by redefining MASK or using FILELIST. That will
;                    speed up the process.
;
;
;        ;================= Signal Processing ======================
;
;        MAVG -> to apply a running average filter to the series. MAVG
;              value will define the boxcar size and must be GE
;              3. Even numbers are increased by +1. The IDL SMOOTH
;              routine is called and accept _extra keywords (NaN,
;              Edge_truncate, missing).
;
;        DMAX -> to select the daily maxima of the time series. If
;              both MAVG and Dmax are set, the moving average is
;              performed first and you get the daily max of the moving
;              average.
;
;        DAVG -> to select the daily average of the time series. If
;              both MAVG and DAVG are set, the moving average is
;              performed first and you get the daily average of the
;              moving average.
;
;        LOCALTIME -> to get DAVG or DMAX computed over local days
;              instead of UT days. See details below.
;
;
;        ;================= Output keywords ========================
;
;        DATA -> set to a variable name that will hold the selected
;             timeseries data on exit. This is a 4D array
;             (nLon, nLat, nLevel, ntime) even if only one location is
;             selected.
;
;        OUTLON -> set to a variable name that will hold the vector
;             of longitudes of the data set on exit.
;
;        OUTLAT -> set to a variable name that will hold the vector
;             of latitudes of the data set on exit.
;
;        OUTLEV -> set to a variable name that will hold the vector
;             of Levels of the data set on exit.
;
;        OUTALT -> set to a variable name that will hold the vector
;             of altitudes for the data set on exit.
;
;        OUTTIME -> set to a variable name that will hold the time
;             vector corresponding to the data set on exit. Format
;             is Tau, or YYYYMMDD if /DMAX.
;
;        LOCALTIME -> if set, OUTTIME becomes a Nb_OutLon X Nb_TimeStep
;             array, with each vector OUTTIME[i,*] holding the time
;             vector in local time instead of UT. That vector will
;             apply to all j and k for DATA[i,j,k,*].
;
;
;           Specific case of...  both DMAX (or DAVG) and LOCALTIME
;             being set. The daily max (average) is obtained after
;             shifting the timeseries, so they start at 00 LT
;             everywhere (or the first available time step just before
;             00 LT). The first max (average) value is for the first
;             complete local day of the series. The OUTTIME array is
;             then a [numbers of complete days, 2] array that gives
;             the local YYYYMMDD for both positive and negative
;             longitudes.
;
;             See also note about TAU0/TAU1 below.
;
;             Note that the time step of the series must be small
;             enough for the DMAX/DAVG w/r/t Local Time to be
;             reliable.
;
;
;        ;================= Others ========================
;
;        NOSAVE -> set to not save output into a BPCH file. Useful if
;             you just want to check results with output keywords.
;
;        VERBOSE -> Set to print informational message about the time
;             series. Particularly useful to double check the
;             area/location selected with subset keywords.
;
;        _EXTRA=e -> Picks up extra keywords for SMOOTH and
;                 DIALOG_PICKFILE.
;
;
; OUTPUTS:
;        See output keywords above.
;
; SUBROUTINES:
;
; REQUIREMENTS:
;        References many routines from GAMAP package. Requires GAMAP
;        v2.10 for saving 4D dataset into binary punch file.
;
; NOTES:
;        ######## ND49 only. For ND48, see GC_COMBINE_ND48  #########
;
;        Written with batch processing in mind. It is recommended to
;        save all ND49 outputs into one dedicated directory, and to
;        use keywords (INDIR, OUTDIR, OUTFILE..) and save the new
;        combined timeseries in a new directory.
;
;        About TAU0 and TAU1 : in the DataInfo structure, they are set
;        to the beginning and end of the timeseries. For daily data,
;        we compute them by setting HH:MM:SS to 00:00:00. If LocalTime
;        is set, UT is still used for TAU0 and TAU1, so we can use
;        only one value. If both LocalTime and DMAX are set, tau0 and
;        tau1 give the first and last (local) days for longitudes less
;        than 0 (west). For East longitudes, you need to add one day
;        to these to get the correct date.
; 
;
; EXAMPLES:
;        ;; In the following examples, it is assumed that tracer 1
;        ;; has been saved with ND49
;
;
;        ;; (1) Read multiple timeseries files selected w/ a pop-up
;        window (use SHIFT key for muliple selections). Saved series
;        at ALL available locations into default directory and filename:
;
;            GC_COMBINE_ND49
;
;        exactly the same as:
;
;            GC_COMBINE_ND49, 1, 'IJ-AVG-$'
;
;
;        ;; (2) Like example (1), but saves only the daily max of the
;        ;; 9-hours average timeseries:
;
;            GC_COMBINE_ND49, 1, 'IJ-AVG-$', /dmax, mavg=8
;
;
;        ;; (3) Like example (1), but do not save the timeseries. Get
;        ;; the timeseries in the variable TS in output:
;
;            GC_COMBINE_ND49, 1, 'IJ-AVG-$', /nosave, data=TS
;
;
;        ;; (4) read **ALL** MASK-files from directory '~/path/'
;        ;; without a pop-up window (no interactivity, good for batch
;        ;; processing):
;
;            GC_COMBINE_ND49, 1, 'IJ-AVG-$', indir='~/path/', outfile='series1.dat'
;
;
;        ;; (5) Like example (4), but with selection of ONE station:
;
;            GC_COMBINE_ND49, 1, 'IJ-AVG-$', indir='~/path/', outfile='station1.bpch',$
;                             lon=-65., lat=45., lev=1
;
;
;        ;; (6) Like example (5), but with shorter time series (from
;        ;; 2001/7/20 20:00 to 2001/7/23 2:00):
;
;            GC_COMBINE_ND49, 1, 'IJ-AVG-$', indir='~/path/', outfile='station1.bpch',$
;                             lon=-65., lat=45., lev=1, $
;                             Time=[nymd2tau(20010720l,200000l),nymd2tau(20010723l,20000l)]
;
;
;        ;; (7) Like example (6), but select Daily Max and for few
;        ;;  days only (from 23rd to 28th of July 2001):
;
;            GC_COMBINE_ND49, 1, 'IJ-AVG-$', indir='~/path/', outfile='station1.bpch',$
;                             lon=-65., lat=45., lev=1, /DMax,
;                             Time=[20010723L,20010728L]
;
;
;        ;; (8) read **ALL** MASK-files from a directory selected with
;        ;; a pop-up window:
;
;            GC_COMBINE_ND49, 1, 'IJ-AVG-$', indir=dialog_pickfile(/dir)
;
;
;
; MODIFICATION HISTORY:
;        phs,  6 Jun 2007: GAMAP VERSION 2.05
;                          - Initial version
;        phs, 25 Jul 2007: GAMAP VERSION 2.10
;                          - added Moving Average and Daily Max as
;                            signal processing available before 
;                            saving/passing data.
;                          - added Lon and Lat keywords to select one
;                            location or a smaller area.
;                          - added output keywords.
;        phs,  4 Oct 2007: - Bug fix for OUTTIME keyword
;        phs, 12 Oct 2007: - Added OUTLEV output keyword, and LEV
;                            input keyword.
;                          - INDIR can be used as output keyword.
;        phs, 15 Oct 2007: - added LOCALTIME keyword
;        phs, 18 Oct 2007: - do not save if output file is one of the
;                            input file.
;        phs, 26 Oct 2007: - bug fix for LON and LAT
;                          - added TIME keyword to limit
;                            timeseries in time.
;        phs, 28 Oct 2007: - DMAX accounts for LOCALTIME if set.
;                          - Bug fix for OutTime when /DMax.
;        phs, 04 Apr 2008: GAMAP VERSION 2.12
;                          - added DAVG keyword
;                          - now cleanup the /no_global pointers
;                          - added the FILELIST keyword
;        phs, 17 Jul 2008: - Added comments
;
;-
; Copyright (C) 2007-2008, Philippe Le Sager, Harvard University.
; This software is provided as is without any warranty whatsoever.
; It may be freely used, copied or distributed for non-commercial
; purposes. This copyright notice must be kept with any copy of this
; software. If this software shall be used commercially or sold as
; part of a larger package, please contact the author. Bugs and
; comments should be directed to plesager@seas.harvard.edu
; with subject "IDL routine gc_combine_nd49".
;-----------------------------------------------------------------------

;-----------------------------------------------------------------------
function cct_section, Dim, L1, L2, LLEV=LLEV

   ; Input Keyword = LLEV is level (scalar) or level range (2-element
   ; vector) wanted. These are FORTRAN-like indices since they start
   ; at 1.
   ;
   ; Input = DIM is the size of the dimension from which we select a section.
   ;
   ; In output, function returns the size of the section only.
   ;
   ; Additional output : L1 and L2 are set to IDL-indices that start
   ; and end the section in the original vector.

   L1  = 0L
   L2  = dim-1L
   if ( N_Elements( LLev ) eq 1 ) then L1 = ( L2 = LLev - 1L )
   if ( N_Elements( LLev ) eq 2 ) then L1 = min( LLev - 1L, max = L2 )

   ;LLev = [L1,L2]+1l  ; in case LLev was undefined

   ;; output dimension
   return, L2 - L1 + 1L

end


;-----------------------------------------------------------------------
PRO cct_get_ind, gridinfo, Lat, Lon, first, dim, ILON, JLAT

   ;; a wrapper for CTM_INDEX

   ;; INPUT: gridInfo (structure), Lat & Lon (scalars), first & dim
   ;;        (2- and 4-elements vectors from datainfo structure)
   ;;
   ;; OUPUT: closest I,J (IDLwise) corresponding to LON,LAT

   CTM_INDEX, gridinfo, ILon, JLat, center=[Lat, Lon], /non_inter
   ILon = ILon - First[0] ; automatically IDL indexing
   JLat = JLat - First[1]

   IF Ilon lt 0L OR Ilon ge Dim[0] then $
      Message, '### WARNING #### ' + strtrim(Lon, 2) + $
         ' is out of available domain! Border value is used instead.', /Cont

   IF Jlat lt 0L or Jlat ge Dim[1] then $
      Message, '### WARNING #### ' + strtrim(Lat, 2)+  $
         ' is out of available domain! Border value is used instead.', /Cont

   ilon = 0 > ilon < (dim[0]-1)
   jlat = 0 > jlat < (dim[1]-1)
END



;-----------------------------------------------------------------------
pro gc_combine_nd49, Tracer,                   Category,        $
                     OutFileName=OutFileName,  OutDir=OutDir,   $
                     mask=mask,                InDir=InDir,     $
                     FileList=FileList,                         $
                     LLev=LLev,                ILon=ILON,       $
                     Jlat=Jlat,                lev=lev,         $
                     Lon=Lon,                  lat=lat,         $
                     mavg=mavg,                dmax=dmax,       $
                     davg=davg,                Time=Time,       $
                     data=tsdata,                               $
                     NOSAVE=nosave,            verbose=verbose, $
                     outlat=outlat,            outlon=outlon,   $
                     outtime=outtime,          outalt=outalt,   $
                     outlev=outlev,            _EXTRA=e,        $
                     localtime=localtime

   ;===================================================================
   ; Initialization
   ;===================================================================

   ; Default arguments
   if ( N_Elements( Category  ) eq 0 ) then Category = 'IJ-AVG-$'
   if ( N_Elements( Tracer    ) eq 0 ) then Tracer   = 1

   ;; Safety: prevent user from creating huge file w/ all diagnostics
   if ( StrCompress( category[0], /r) eq '0' ) or   $
      ( String     ( category[0] )    eq ''  ) then Category = 'IJ-AVG-$'

   ; Default ND49 mask to find timeseries files
   if ( N_Elements( Mask      ) eq 0 ) then Mask = 'ts*.bpch'

   ; Default Output Filename
   if ( N_Elements( OutFilename ) eq 0 ) $
      then OutFileName  = 'combts_%TRACERNAME%.bpch'

   ; keywords set?
   dmax   = keyword_set( dmax    )
   davg   = keyword_set( davg    )
   verb   = keyword_set( verbose )
   LTime  = keyword_set(localtime)
   N_Time = n_elements(Time)
   daily  = dmax or davg

   ;===================================================================
   ; Input files
   ;===================================================================

   ; Get file list and number of files
   IF N_Elements( FileList ) eq 0 then $
      FileList = is_dir( InDir ) ? MfindFile( InDir + mask ) :            $
                 dialog_pickfile(filter=mask, /read, /multiple_files,     $
                                 title='Choose Time Series files (ND49)', $
                                 get_path=indir, _extra=e)

   nfiles = n_elements( FileList )

   IF ( FileList[0] eq '' ) THEN BEGIN
      print,  'No File found. Returning...'
      return
   ENDIF ELSE print, 'Found ' + strtrim(nfiles,2) + ' files.'


   ;; assume filenames follow time
   FileList = FileList[sort(FileList)]



   ;===================================================================
   ; Read data into one array
   ;===================================================================

   ; ------------- For each day (i.e, each ND49 files)
   First = 1B
   FOR DD = 0L, Nfiles-1L DO BEGIN

      Infile = FileList[DD]
      if verb then Print, 'Processing ' + infile + '...'

      ;; get tracer/category records for all time steps of that day
      CTM_GET_DATA, Datainfo, FILE=infile, quiet=1, category, tracer=tracer


      ;; --------- From 1st file only ----------------
      IF First THEN BEGIN


         ;; Check availability of tracer/category records, and get nb
         ;; of daily timesteps
         nblocks = n_elements( datainfo )

         if ( nblocks eq 0 ) then begin
            Message, 'No matching data found!', /Continue
            return
         endif


         ;; Get MODELINFO and GRIDINFO structures, dimension and offset
         GetModelAndGridInfo, DataInfo[0], ModelInfo, GridInfo
         dim    = dataInfo[0].dim
         offset = dataInfo[0].first



         ;; Define output array from datainfo size, first data block
         ;; dimensions, and Locations keywords (LLEV,...).

         ;; Overwrite LLev if LEV is passed
         Case n_elements(lev) of
                2: llev = lev - offset[2] + 1l
                1: llev = replicate(lev - offset[2] + 1l, 2)
                else:
         Endcase

         ;; Check LLEV if defined
         if n_elements(LLEV) gt 0 then begin
         dummy = where(llev le 0 or llev gt dim[2], count)
         if count gt 0 then begin
            Message, 'No matching LEVEL', /Continue
            return
         endif
         endif

         ;; Case of smaller area (overwrite ILON & JLAT if LAT or/and
         ;; LON is passed)
         nlat = n_elements(lat)
         nlon = N_Elements(lon)

         IF nlon gt 0 or nlat gt 0 THEN BEGIN

            case nlon of
               1: lon = [lon, lon]
               0: lon = [gridinfo.xmid[offset[0] - 1L],         $
                         gridinfo.xmid[offset[0] - 2L + dim[0]] ]
               else:
            endcase

            case nlat of
               1: lat = [lat, lat]
               0: lat = [gridinfo.ymid[offset[1] - 1L],         $
                         gridinfo.ymid[offset[1] - 2L + dim[1]] ]
               else:
            endcase

            cct_get_ind, gridinfo, Lat[0], Lon[0], offset, dim, I1, J1
            cct_get_ind, gridinfo, Lat[1], Lon[1], offset, dim, I2, J2

            ILON = [I1, I2]+1L ; these are fortran indices
            JLAT = [J1, J2]+1L

         ENDIF

         ;; final output dimensions
         dim[0] = cct_section( Dim[0], I1, I2, LLEV=ILON)
         dim[1] = cct_section( Dim[1], J1, J2, LLEV=JLAT)
         dim[2] = cct_section( Dim[2], L1, L2, LLEV=LLEV)
         dim[3] = nblocks * nfiles
         TSData = fltarr(dim[0], dim[1], dim[2], dim[3])

         ;; more tags
         tau0       = dataInfo[0].tau0
         startindex = DataInfo[0].first + [I1, J1, L1]
         unit       = DataInfo[0].unit
         tracername = DataInfo[0].tracername
         if (tracername eq '') then tracername = strtrim(tracer,2)

         First  = 0B
      ENDIF
      ;; --------- End 1st file ----------------


      ;; Store data for each time step
      For T = 0L, NBlocks-1L  do $
         TSData[0, 0, 0, DD * NBlocks + T ] =  $
         ( *(datainfo[T].data) )[I1:I2,J1:J2,L1:L2]

      ;; and Tau1
      If DD eq NFiles-1L then tau1 = $
         daily ? dataInfo[0L].tau0 : dataInfo[nblocks-1L].tau0

      ;; Free memory, pointers, lun, and close file
      ctm_cleanup

   ENDFOR



   ;===================================================================
   ; Additional output
   ;===================================================================

   OutLon  = gridinfo.xmid[ offset[0]-1+I1 : offset[0]-1+I2 ]
   OutLat  = gridinfo.ymid[ offset[1]-1+J1 : offset[1]-1+J2 ]
   OutAlt  = gridinfo.zmid[ offset[2]-1+L1 : offset[2]-1+L2 ]
   OutLev  = [ L1, L2 ] + offset[2] - 1l
   Tstep   = 24/nblocks

   ;; Here, OutTime is available time steps
   Outtime = lindgen(dim[3]) * tstep + tau0

   time0 = tau2yymmdd(tau0, /nf) ; => [ YYYYMMDD, HHMMSS ]
   ind_end = 1

   if daily then begin
      outtime = lindgen(nfiles)+time0[0] ; day-vector - Previous
      outtime = (tau2yymmdd(nymd2tau(OutTime), /nf))[0:nfiles-1] ;now correct if more than one month
      ind_end = 0
   endif



   ;===================================================================
   ; Signal processing if requested
   ;===================================================================

   ;; -- Basic Moving Average (if MAvg is even, MAvg+1 is used)
   if keyword_set(MAVG) then $
      tsdata = SMOOTH( temporary(tsdata), [1,1,1,mavg], _extra=e )


   ;; -- Daily max or average
   if daily then begin

      ;; accounting for local time
      if LTime then begin

        ; for each longitude
      	for i=0L,dim[0]-1 do begin
      	  tshift = fix( outlon[i]/(15.*tstep) ) - (outLon[i] gt 0)*24/tstep
          tsdata[i,*,*,*] = shift( tsdata[i,*,*,*],0,0,0, tshift )
        endfor

        ; get rid of the flaw (incomplete) day
        end_ind = dim[3]-nblocks-1 ; same as = (nfiles-1)*nblocks - 1l
        tsdata  = tsdata[*,*,*,0:end_ind]
        outTime = outTime[0:nfiles-2]

        ; warning
        if N_Time ne 0 then begin
           print, 'Time Selection is not supported when /Dmax ' + $
                  '(or /DAvg) and /LocalTime'
           N_Time = 0
        endif
      endif


      dim[3] = nfiles - 1L*LTime

      if dmax then $
         tsdata = MAX( REFORM( temporary(tsdata), dim[0], dim[1], $
                               dim[2], nblocks, dim[3] ), dimension=4 ) $
      else $
         tsdata = MEAN( REFORM( temporary(tsdata), dim[0], dim[1], $
                                dim[2], nblocks, dim[3] ), 4 ) 
         
   endif


   ;===================================================================
   ; Overwrite OUTTIME and DATA if TIME is passed
   ;===================================================================
   case N_Time of

      ;; output only or no kwrd
      0:

      ;; one element. Rewrite OUTTIME with closer element
      1: begin
         mi      = min( abs(outtime-TIME[0]), lmin )
         OutTime = OutTime[lmin]
         tsdata  = tsdata[*,*,*,lmin]
      endcase

      ;; 2+ elements. Replace OUTTIME with vector of available
      ;; timesteps between min and max of TIME, plus overlap such that
      ;; min and max are included in the vector.
      else: begin
         mi = min(Time, max=ma)

         ind = value_locate(OutTime, [mi, ma]) > 0

         tsdata  = tsdata[*,*,*,ind[0]:ind[1]]
         OutTime = OutTime[ind[0]:ind[1]]
      endcase

   endcase


   ;;--- overwrite dim[3], tau0 and tau1 accordingly
   dim[3] = n_elements(OutTime)
   tau0   = daily ? nymd2tau(OutTime[0], 0l)        : OutTime[0]
   tau1   = daily ? nymd2tau(OutTime[dim[3]-1], 0l) : OutTime[dim[3]-1]



   ;;--- specific output time vectors with localtime
   if LTime and not(daily) then $
   	  outtime = rebin(outlon / 15., dim[0], dim[3]) + $
   	            rebin(reform(outtime,1,dim[3]),dim[0],dim[3])

   ;; LocalTimeDay = ouTIme[*,0] is for location w/ negative longitude
   ;; LocalTimeDay = ouTIme[*,1] is for location w/ positive longitude
   if LTime and Daily then outTime=[[OutTime], $ 
                                   [(tau2yymmdd(nymd2tau(OutTime)+24, /nf))[0:dim[3]-1]] ]


   ;===================================================================
   ;; Information
   ;===================================================================
   if keyword_set(verbose) then begin
      print, '******************************************'
      print, 'Selected Time series:'
      print, ' start at ', (tau2yymmdd(tau0, /nf))[0:ind_end]
      print, ' & end at ', (tau2yymmdd(tau1, /nf))[0:ind_end]
;      print, 'Total nb of days is ' + strtrim(nfiles, 2) ;; not valid if Time
      print, 'Time step is ' + ( daily ?  $
         '1 day.' : ( strtrim( tstep, 2) + ' hour(s)' ) )
      print, 'Area covered:'
      print, '  longitudes=['+strtrim(outlon[0], 2)+', '+ $
         strtrim(outlon[dim[0]-1], 2)+']'
      print, '   latitudes=['+strtrim(outlat[0], 2)+', '+ $
         strtrim(outlat[dim[1]-1], 2)+']'
      print, '   altitudes=['+strtrim(outalt[0], 2)+', '+ $
         strtrim(outalt[dim[2]-1], 2)+']'
      print, '******************************************'
   endif


   ;===================================================================
   ; Save into BPCH file
   ;===================================================================
   If NOT(keyword_set(nosave)) then begin
   ;If ~keyword_set(nosave) then begin

      ;; Make DATAINFO structure
      Success = CTM_Make_DataInfo( TSData,                  $
                                   NewDataInfo,             $
                                   NewFileInfo,             $
                                   FileType   = 106,        $
                                   ModelInfo  = ModelInfo,  $
                                   GridInfo   = GridInfo,   $
                                   DiagN      = Category,   $
                                   Tracer     = Tracer,     $
                                   Trcname    = Tracername, $
                                   Tau0       = Tau0,       $
                                   Tau1       = Tau1,       $
                                   Unit       = Unit,       $
                                   Dim        = Dim,        $
                                   First      = StartIndex, $
                                   /No_Global )


      ;; Replace token in the output file name
;      IF n_elements(OutDir) EQ 0 THEN OutDir = File_DirName(FileList[0], /Mark)
      IF n_elements(OutDir) EQ 0 THEN OutDir = extract_path(FileList[0])

      OutFileName = OutDir + Replace_Token( OutFileName, 'TRACERNAME',  $
                                            StrCompress(tracername, /r) )


      ; check that we are not overwriting one of the input files
      dumy = where(FileList eq OutFileName, c1)
      if c1 ne 0 then begin
         Message, 'Output File is one of the input files. ' + $
                  'Writing CANCELLED !!', /Continue
         return
      endif

      print, 'Writing '+ OutFileName +'....'

      ;; Write binary punch file output
      CTM_WriteBpch, NewDataInfo, NewFIleInfo, FileName=OutFileName


      ; cleanup /no_global pointers before returning
      ptr_free, NewDataInfo.Data
      ptr_free, NewFIleInfo.GridInfo

   endif

END
