; $Id: gc_combine_nd48.pro,v 1.1 2007/11/20 20:15:45 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        GC_COMBINE_ND48
;
; PURPOSE:
;        Combine timeseries data from the Geos-CHEM ND48
;        diagnostics contained in one or more binary punch files.
;
;        The goal is to combine, for one station, all the data blocks
;        (there is one per time step) into one single 4-D data block
;        (we want the time to be the 4th dimension). This is basically
;        to take advantage of support for 4D dataset in GAMAP v2-10.
;
;        GEOS-Chem ND48 (as in v7-04-12) outputs one file for all
;        stations and all time steps. GC_COMBINE_ND48 will write one
;        file but each timeseries will be in one data block instead of
;        as many as the number of timesteps. This will make reading
;        the timeseries with CTM_GET_DATA a lot faster.
;
;        Two basic signal processing before saving the data can be
;        applied: moving average and/or daily maximum.
;
;        LIMITATION: daily maximum will not make sense if series do
;        not cover full days.
;
; CATEGORY:
;        GAMAP Utilities, GAMAP Data Manipulation, Time Series
;
; CALLING SEQUENCE:
;        GC_COMBINE_ND48 [, Keywords ]
;
; OPTIONAL INPUTS:
;
;        By defaults all stations are processed. And one output file
;        is created that contains all the stations timeseries.
;
; KEYWORD PARAMETERS:
;
;        ;============ For I/O files/directory =====================
;
;        INFILE -> one or more station file(s) from ND48
;              diagnostic. If more than one file is processed, it is
;              assumed that, once sorted in alphabetical order, they
;              are in chronological order (this is automatically the
;              case, if you insert YYYYMMDD into ND48 filenames in
;              input.geos).
;
;        INDIR -> Directory where to look for "stations" files. Can be
;             either input or output keyword:
;
;             Input: when defined, ALL files satisfying the MASK
;                    keyword in the directory will be selected.
;
;             Ouput: set to a variable name that will contains the DIR
;                    of the selected files.
;
;             It is ignored (both input and output roles) if INFILE is
;             provided.
;
;             If neither INFILE nor INDIR is set, then a dialog window
;             that allows multiple files selection (keep CTRL or SHIFT
;             key down) will pop-up.
;
;
;        MASK -> Pattern Mask to find files in INDIR. Default is
;             "stations*".
;
;        OUTFILENAME -> Name of the file that will contain the
;             new timeseries. Default is 'combined'+INFILE[0], in the
;             same directory as stations file. If the full path is not
;             included, the file is created in the working directory.
;
;            The routine prevents from overwriting any input file.
;
;        ;================= Data Selection ======================
;
;        STATIONNB -> Station(s) number. Can be one or more elements
;              (up to the number of stations in ND48). Use to select a
;              subset of the stations instead of all of them.
;
;        TIME -> vector for selecting time span. The data covering
;              [min(TIME),max(TIME)] are selected. If only one
;              element, then the closest-in-time data is selected.
;
;              If min and/or max of TIME is outside the range of
;              available time steps, the first or last available time
;              step is used.
;
;              Note 1: this is also an output keyword. Then, if passed
;              by reference, TIME becomes the time vector in
;              output. See example (6).
;
;              Note 2: if using DMAX or DAVG, then TIME should be long 
;              integer (YYYYMMDD), if not it should be Tau format.
;
;        ;================= Signal Processing ======================
;
;        MAVG -> to apply a running average filter to the series. MAVG
;              value will define the boxcar size and must be GE
;              3. Even numbers are increased by +1. The IDL SMOOTH
;              routine is called and accept _extra keywords (NAN,
;              EDGE_TRUNCATE, and MISSING).
;
;        DMAX -> to select the daily maxima of the time series. If
;              both MAVG and Dmax are set, the moving average is
;              performed first and you get the daily max of the moving
;              average. (Local time is not accounted for: days start
;              and end at 0 UT everywhere).
;
;        DAVG -> to select the daily average of the time series. If
;              both MAVG and DAVG are set, the moving average is
;              performed first and you get the daily average of the
;              moving average. (Local time is not accounted for: days
;              start and end at 0 UT everywhere).
;
;
;        ;================= Output keywords ========================
;
;        All the following keywords will apply to only ONE
;        station. The last one is used if none or more than one is
;        requested.
;
;        DATA -> set to a variable name that will hold the selected
;             timeseries data on exit. This is a 4D array
;             (1,1,lev,time) even though only one station is
;             selected.
;
;        LON -> set to a variable name that will hold the
;             longitude of the data set on exit.
;
;        LAT -> set to a variable name that will hold the
;             latitude of the data set on exit.
;
;        LEV -> set to a variable name that will hold the vector
;             of levels for the data set on exit.
;
;        TIME -> set to a variable name that will hold the time
;             vector for the station on exit. Given as Tau values,
;             unless DMAX or DAVG is set, then as YYYYMMDD.
;
;        LOCALTIME -> if set, the TIME vector is in local time
;             instead of UT. Has no effect if /DMAX or /DAVG.
;
;
;        ;================= Others ========================
;
;        NOSAVE -> set to not save output into a BPCH file. Useful if
;             you just want to check results with output keywords.
;
;        VERBOSE -> Set to print informational message about the time
;             series. particularly useful to double check
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
;        v2.10 for handling 4D dataset.
;
; NOTES:
;       If memory issues show up, try to save one timeseries (i.e.,
;       one station at a time).
;
; EXAMPLES:
;
;        ;; (1) Read multiple timeseries files selected w/ a pop-up
;        window (use SHIFT key for muliple selections). Save with the
;        default filename in the default directory:
;
;        GC_COMBINE_ND48
;
;
;        ;; (2) Like example (1), but saves only the daily max of the
;        ;;     9-hours average timeseries:
;
;        GC_COMBINE_ND48, /dmax, mavg=8
;
;
;
;        ;; (3) read ALL stations files from directory '~/path/'
;        ;; without a pop-up window (no interactivity, good for batch
;        ;; processing). Default MASk and outfile name are used.
;
;        GC_COMBINE_ND48, indir='~/path/'
;
;
;        ;; (4) Like example (3) but select only the first available
;        ;; station, and save the result in a specified file:
;
;        GC_COMBINE_ND48, Station=1, indir='~/path/', outfile='~/path/series1.bpch'
;
;
;        ;; (5) read files from directory '~/path/', and select 3rd station.
;        ;; Do not save combined timeseries. Get outputs in variables
;        ;; data, lon, lat and time.
;
;        GC_COMBINE_ND48, indir='~/path/', station=3, data=data, lon=lon, lat=lat, time=time
;
;        Help, reform(data)
;        PLOT, time, data[0,0,0,*], title='Lon= strtrim(lon,2)+'- Lat='+strtrim(lat,2)
;
;
;        ;; (6) Like (5), but limit the time to 23rd-28th of July
;        ;;     2001. Not the use of two commands to get the output
;        ;;     time vector.
;
;        time = [nymd2tau(20010723L,20010728l)]
;        GC_COMBINE_ND48, indir='~/path/', station=3, data=data, lon=lon, lat=lat, time=time 
;        HELP, time
;
;
; MODIFICATION HISTORY:
;        phs, 31 Jul 2007: GAMAP VERSION 2.10
;                          - Initial version
;        phs, 11 Oct 2007: - few bugs fix
;                          - added output keywords
;        phs, 15 Oct 2007: - added LOCALTIME keyword
;        phs, 18 Oct 2007: - do not save if output file is one of the
;                            input file.
;        phs, 26 Oct 2007: - TIME can be use to select the time span
;                            of the series.
;                            Added DAVG keyword.
;        phs, 30 Oct 2007: - couple of minor fixes.
;
;-
; Copyright (C) 2007, Philippe Le Sager, Harvard University.
; This software is provided as is without any warranty whatsoever.
; It may be freely used, copied or distributed for non-commercial
; purposes. This copyright notice must be kept with any copy of this
; software. If this software shall be used commercially or sold as
; part of a larger package, please contact the author. Bugs and
; comments should be directed to plesager@seas.harvard.edu
; with subject "IDL routine gc_combine_nd48".
;-----------------------------------------------------------------------


PRO GC48_TIMESELECT, data, WantedTime=time, AvailableTime=atime


   ;===================================================================
   ; Overwrite TIME and DATA
   ;===================================================================
   case n_elements(TIME) of

      ;; output only kwrd
      0: time = atime

      ;; one element. Rewrite TIME with closer element
      1: begin
         mi = min( abs(atime-time[0]), lmin )
         time = atime[lmin]
         data = data[*,*,*,lmin]
      endcase

      ;; 2+ elements. Replace TIME with vector of available timesteps
      ;; between min and max of TIME, with overlap such that min and
      ;; max are included.
      else: begin
         mi = min(time, max=ma)

         ind = value_locate(atime, [mi, ma])
         ind = ind > 0

         data = data[*,*,*,ind[0]:ind[1]]
         time = atime[ind[0]:ind[1]]
      endcase

   endcase

END

;-----------------------------------------------------------------------

PRO GC_COMBINE_ND48, InFile =InFile,      InDir=InDir,             $
                     mask=mask,           OutFileName=OutFileName, $
                     StationNb=StationNb, dmax=dmax,  davg=davg,   $
                     mavg=mavg,           verbose=verbose,         $
                     Data=NEWDATA,        Time= Time,        $ ; output keywords
                     Lon = Lon,           Lat = Lat,         $ ; output keywords
                     Lev = lev,           NoSave=NOSave,     $
                     LOCALTIME=LOCALTIME, _EXTRA=e

   ;===================================================================
   ; Avoid memory leak
   ;===================================================================
   catch, bug
   if bug ne 0 then begin
      catch,  /cancel
      PRINT, 'Error message: ', !ERROR_STATE.MSG
      ctm_cleanup, /no_gc
      if size(data, /type) eq 10 then ptr_free, data
      return
   endif

   ;===================================================================
   ; Initialization
   ;===================================================================
   dmax   =      keyword_set( dmax      )    ; daily max
   davg   =      keyword_set( davg      )    ; daily avg
   save   = Not( keyword_set( nosave    ) )  ; save
   localt =      keyword_set( localTime )    ; Local Time
   nstat  =      n_elements(  stationNb )    ; station selected

   if arg_present(newdata) and nstat ne 1 then $
   	print, 'WARNING: output data will be for the LAST station only'


   ;===================================================================
   ; File(s) to process
   ;===================================================================

   ; Default mask to find timeseries files
   if N_Elements( Mask   ) eq 0 then Mask =  'stations.*'

   ; Get file list and number of files
   IF N_Elements( InFile ) eq 0 then $
      InFile = is_dir( InDir ) ? MfindFile( InDir + mask ) :  $
      dialog_pickfile(filter = mask, /read, /multiple_files, $
                      title = 'Choose STATIONS files (ND48)', $
                      get_path=indir, _extra=e)

   nfiles = n_elements( InFIle )

   IF ( InFile[0] eq '') THEN BEGIN
      print, 'No File found in DIRECTORY: '+InDir
      print, 'Returning...'
      return
   ENDIF

   ; assume filenames follow time
   InFile = InFile[sort(InFile)]




   ;===================================================================
   ; READ - Loop over files
   ;===================================================================

   First = 1B
   FOR DD = 0L, Nfiles-1L DO BEGIN

      Filename = InFile[DD]
      Print, 'Processing ' + filename + '...'


      ;; get all data for all time steps in the file
      CTM_GET_DATA, Datainfo, FILE=filename, quiet=1


      ;; Get the number of timesteps in the stations*.bpch file
      Tau         = DataInfo[*].Tau0
      Tau         = Tau[ Uniq( Tau , Sort( Tau ) ) ]
      n_time_step = n_elements(Tau)


      ;; final Tau0 and Tau1 if first/last file
      If DD eq 0L        then tau0 = Tau[0]
      If DD eq NFiles-1L then tau1 = dmax ? Tau[0]:Tau[n_time_step-1]


      ;; Get time step in hour
      deltaT = Tau[1] - Tau[0]


      ;; number of available stations
      n_stations  = n_elements(DataInfo)/ n_time_step


      ;; More initialization....
      If First then begin
         ns     = n_stations
         dt     = deltaT
         Sindex = indgen(ns)
         if nstat eq 0 then nstat = ns
         ;; use pointers because number of levels can be different at each stations
         data = ptrarr(nstat, /allocate)

      ;; ... or checking
      endif else begin
         if ( n_stations ne ns ) OR ( deltaT ne dt ) then begin
            mess = 'Problem: files do not have the same ND48 output!'
            message, mess
         endif
      endelse


      ;; Sort the records in DataInfo according to block position in
      ;; the file. This is a secure way to order things, since the
      ;; order of DataInfo depends on the type of tracer
      filepos      = DataInfo[*].filepos
      record_order = sort(filepos)


      ;;================ Loop over each time series
      FOR T = 0L, nstat  - 1L DO BEGIN

         Torig = nstat eq ns ? T : SIndex[stationNB[T]-1]

         ;; get relevant records indices, and get subset of datainfo
         Ind = record_order[ Torig + indgen( n_time_step )* n_stations ]
         ThisDataInfo  = DataInfo[Ind]


         ;; Loop over all data blocks
         for D = 0L , n_elements( ThisDataInfo ) - 1L  do begin
            If first and D eq 0L then $
               *Data[T] = reform(*( ThisDataInfo[D].Data )) ELSE $
               *Data[T] = [[*data[T]],[reform(*ThisDataInfo[D].Data)]]
         endfor

         undefine, thisdataInfo

      ENDFOR

      First = 0B

      ;; Free memory, pointers, lun, and close file, unless it's last
      ;; file
      If DD ne NFiles-1L then ctm_cleanup, /No_GC

   ENDFOR


   ;===================================================================
   ; Additional output
   ;===================================================================

   GetModelAndGridInfo, DataInfo[0], ModelInfo, GridInfo
   NDays     = fix( tau1 - tau0 )/24 + 1
   StartTime = tau2yymmdd(tau0, /nf)        ; [ YYYYMMDD , HHMMSS ]

   ;; Information
   if keyword_set(verbose) then begin
      print, '******************************************'
      print, 'Found '+strtrim(n_stations, 2) + ' time-series total,'
      print, 'selected ' + strtrim(nstat, 2) + ' stations'
      print, ''
      print, ' Start at ', StartTime
      print, ' End time ', tau2yymmdd(tau1, /nf)
      print, 'Time step = ' + strtrim(deltat, 2) + ' hour(s)'
      print, ''
      print, '******************************************'
   endif





   ;===================================================================
   ; For each required time series:
   ;         Get DataInfo structure & Do signal processing
   ;===================================================================

   FOR T = 0L, nstat  - 1L do begin

      NewData = *data[T]
      ptr_free, data[T]

      ;;--- size business (stations are at 1 lon, 1 lat but can be at
      ;;    more than one level) Here we assume that if data is 1D
      ;;    then it is 1 level and many time step, and not the
      ;;    opposite. Pretty safe for ND48!
      sz = size(NewData, /Dim)

      dim = n_elements(sz) eq 2 ? [1L, 1L, sz[0], sz[1]] :  $
         [1L, 1L, 1L, sz[0]]

      NewData = reform(temporary(newdata), 1l, 1l, dim[2], dim[3])


      ;;--- index of first time step datablock in original datainfo
      Torig    = nstat eq ns ? T : SIndex[stationNB[T]-1]
      Tinit    = record_order[Torig]
      Location = datainfo[Tinit].first

      lon = gridinfo.xmid[location[0]-1]
      lat = gridinfo.ymid[location[1]-1]
      lev = indgen(dim[2])+1


      ;;--- Moving Average (if MAvg is even, MAvg+1 is used)
      if keyword_set( MAVG ) then $
         NewData = SMOOTH( temporary(Newdata), [1,1,1,mavg], _extra=e)


      ;;--- Daily max/avg and Vector of available timesteps
      ind_end = 1
      if dmax then begin
         NewData = MAX( REFORM( temporary(NewData), dim[0], dim[1],  $
                                dim[2], dim[3]/ndays, ndays ),       $
                        dimension=4 )
         dim[3]  = ndays
         atime   = lindgen(ndays) + StartTime[0]
         atime   = (tau2yymmdd(nymd2tau(aTime), /nf))[0:dim[3]-1] ;now correct if more than one month

         ind_end = 0

      endif else if davg then begin
         NewData = MEAN( REFORM( temporary(NewData), dim[0], dim[1],  $
                                dim[2], dim[3]/ndays, ndays ),    4   )
         dim[3]  = ndays
         atime   = lindgen(ndays) + StartTime[0]
         atime   = (tau2yymmdd(nymd2tau(aTime), /nf))[0:dim[3]-1] ;now correct if more than one month

         ind_end = 0

      endif else $
         atime   = ( findgen(dim[3])*deltaT + tau0 ) + localt*lon/15.



      ;;--- Time selection, and update Tau0, tau1, and dim[3]
      gc48_timeselect, NewData, WantedTime=time, AvailableTime=atime

      dim[3] = n_elements(time)

      tau0   = (dmax or davg) ? nymd2tau(time[0], 0l) : $
                                time[0] - localt*lon/15.

      tau1   = (dmax or davg) ? nymd2tau(time[dim[3]-1], 0l) : $
                                time[dim[3]-1] - localt*lon/15.



      ;;--- Information
      if keyword_set(verbose) then begin
         print, 'Timeseries #'+strtrim(T+1,2)+':'
         print, '----------------'
         print, 'Diag=',    datainfo[Tinit].category
         print, 'Tracer #=',datainfo[Tinit].Tracer
         print, 'Name =',   datainfo[Tinit].Tracername
         print, 'Lat. Center = ', gridinfo.ymid[location[1]-1]
         print, 'Lon. Center = ', gridinfo.xmid[location[0]-1]
         print, 'Level range = ', location[2],location[2]+dim[2]-1
         print, ''
         print, ' start at ', (tau2yymmdd(tau0, /nf))[0:ind_end]
         print, ' & end at ', (tau2yymmdd(tau1, /nf))[0:ind_end]
         print, '----------------'
      endif



      ;; Make DATAINFO structure
      if save then begin
         Success = CTM_Make_DataInfo( NewData,                            $
                                      ThisDataInfo,                       $
                                      NewFileInfo,                        $
                                      FileType =106,                      $
                                      ModelInfo=ModelInfo,                $
                                      GridInfo=GridInfo,                  $
                                      DiagN=datainfo[Tinit].category,     $
                                      Tracer=datainfo[Tinit].Tracer,      $
                                      Trcname=datainfo[Tinit].Tracername, $
                                      Tau0=Tau0,                          $
                                      Tau1=Tau1,                          $ 
                                      Unit=datainfo[Tinit].Unit,          $
                                      Dim=Dim,                            $
                                      First=datainfo[Tinit].first,        $
                                      /No_Global )

         ;; Save into NewDataInfo array of structures
         If T eq 0                                              $
            then NewDataInfo = ThisDataInfo                     $
            else NewDataInfo = [ NewDataInfo, ThisDataInfo ]


         ;; security
         UNDEFINE, ThisDatacinfo

      endif

      ; UNDEFINE, NewData ;; can be done  only if (~arg_present(newdata)) and 
                                ; (T eq (nstat-1))

   ENDFOR



   ;;====================================================================
   ;; Save data to disk as binary punch file
   ;;====================================================================
   if save then begin
      if N_Elements( OutFileName ) eq 0 then $
         OutFileName = InDir + 'Combined'+ extract_filename(Infile[0])

      ; check that we are not overwriting one of the input files
      dumy = where(InFile eq OutFileName, c1)
      if c1 ne 0 then begin
         Message, 'Output File is one of the input files. ' + $
                  'Writing CANCELLED !!', /Continue
         return
      endif

      print, 'Writing '+ OutFileName +'....'

      CTM_WriteBpch, NewDataInfo, NewFIleInfo, FileName=OutFileName

   endif

   ;;====================================================================
   ;; Cleanup and quit
   ;;====================================================================
   ctm_cleanup,  /no_gc

END
