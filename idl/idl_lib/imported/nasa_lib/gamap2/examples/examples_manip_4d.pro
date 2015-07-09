; $Id: examples_manip_4d.pro,v 1.2 2007/11/20 21:36:54 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        EXAMPLES_MANIP_4D
;
; PURPOSE:
;        Shows how to manipulate TS data saved as 4D array with
;        GC_COMBINE_ND49 or GC_COMBINE_ND48.
;        The routine loops over all available 4D data blocks and print 
;        information for each of them.
;
; CATEGORY:
;        GAMAP Data Manipulation, GAMAP Examples, Time Series
;
; CALLING SEQUENCE
;
;        EXAMPLES_MANIP_4D, File [ , Keywords ]
;
; INPUTS:
;
;        FILE -> The name of the file created by GC_COMBINE_ND48/9.
;
;
; OUTPUT KEYWORD PARAMETERS: 
;  #### ONLY THE LAST DATA SET IF MORE THAN ONE IS AVAILABLE ####
;
;        DATA -> Output keyword. Set to a variable name that will
;             contain the data set on exist.
;
;        LON -> Output keyword. Set to a variable name that will
;             contain the vector of LONGITUDES on exit.
;
;        LAT -> Output keyword. Set to a variable name that will
;             contain the vector of LATITUDES on exit.
;
;        TIME -> Output keyword. Set to a variable name that will
;              contain the vector of TIME STEP on exit. Format is
;              YYYYMMDD if daily max is asked for (see DMAX keyword),
;              TAU value else.
;
;        LOCALTIME -> to get the output TIME in LOCALTIME. If there
;             is more than one longitude in the data block, TIME
;             becomes an array : one vector for each longitude.
;
; KEYWORD PARAMETERS:
;        MAVG -> The window size (boxcar) of the moving average, if
;             you want to apply one.
;
;        DMAX -> Return daily maximum of the TS.
;
;        VERBOSE -> to print some basic information about the data
;                   set.
;
;        _EXTRA=e -> Picks up extra keywords for routines
;
;
; OUTPUTS:
;        With optional keyword.
;
; SUBROUTINES:
;
; REQUIREMENTS:
;        References many routines from GAMAP package. Requires GAMAP
;        v2.10 for handling 4D dataset.
;
; NOTES:
;
; EXAMPLES:
;
;      file = dialog_pickfile()
;
;      EXAMPLES_MANIP_4D, file, /v, data=ts, lat=lat, lon=lon, time=time
;
;      PLOT, time-time[0], ts[0,0,0,*], title='Time series at lon='+ $
;            strtrim(lon[0],2)+' / lat='+strtrim(lat[0],2)
;
;
;
; MODIFICATION HISTORY:
;        phs, 6 Jun 2007: GAMAP VERSION 2.10
;                          - Initial version
;
;-
; Copyright (C) 2007, Philippe Le Sager, Harvard University.
; This software is provided as is without any warranty whatsoever.
; It may be freely used, copied or distributed for non-commercial
; purposes. This copyright notice must be kept with any copy of this
; software. If this software shall be used commercially or sold as
; part of a larger package, please contact the author. Bugs and
; comments should be directed to plesager@seas.harvard.edu
; with subject "IDL routine ctm_manip_4D".
;-----------------------------------------------------------------------


pro examples_manip_4d, FileName,           $
       MAVG=MAVG,    DMAX=DMAX,            $ ; manipulation keywords
       Data=OUTDATA, verbose=verbose,      $ ; output keywords
       Lon= Lon,     Lat= Lat,             $ ; output keywords
       Time= Time,   localtime=localtime,  $ ; output keywords
       _EXTRA=e


   ;; Include GAMAP common block
   @gamap_cmn

   verbose = keyword_set(verbose)

   ;====================================================================
   ; READ TIME SERIES
   ;====================================================================

   ;; ----- FileName
   IF N_Params() EQ 0 Then  $
      fileName = dialog_pickfile(title='Select a 4D TIME SERIES file')

   if fileName eq '' then return


   ;; ----- Read data and dimensions
   CTM_Get_Data, DataInfo, File=FileName, _EXTRA=e


   ;; Check that filetype is 106 (4D data blocks)
   FileInfo = *( PGlobalFileInfo )  ; global FILEINFO structure array
   Ind      = Where( FileInfo.Ilun eq datainfo[0].ilun )

   if fileinfo[ind].filetype ne 106 then begin
      print, 'This is not a SINGLE-TRACER Time Series File! Returning...'
      return
   endif

   nblocks = n_elements(DataInfo)


   ;; --- Basic Information
   print, 'Found '+ strtrim(nBlocks,2) + ' 4D datablocks'

   ;; --- Get MODELINFO and GRIDINFO structures
   GetModelAndGridInfo, DataInfo[0], ModelInfo, GridInfo


   ;;================= Big Loop over each Data Block ===================

   For I=0,nblocks-1 do begin


      ;; extract data & dimensions (nlon,nlat,nlev,nts)
      data = *dataInfo[i].data
      dim  = datainfo[i].dim


      ;; ---- Spatial coordinates : 
      ;; Get longitudes, latitudes and levels vectors
      x0 = DataInfo[i].First[0] - 1
      y0 = DataInfo[i].First[1] - 1
      z0 = DataInfo[i].First[2] - 1

      Lon = gridinfo.xmid[ x0 : x0+dim[0]-1 ]
      Lat = gridinfo.ymid[ y0 : y0+dim[1]-1 ]
      Lev = z0 + indgen(dim[2])

      ;; ----- Time coordinates
      ;; Get number of days and number of timesteps per day
      ;; Here it is assumed that only entire days of outputs have been
      ;; requested, no fractional day
      ndays = ( FIX( datainfo[i].tau1 - dataInfo[i].tau0 ) / 24 ) + 1
      nstep = dim[3]/ndays
      time  = lindgen(dim[3]) + dataInfo[i].tau0

      if keyword_set(localtime) then $
         outtime = reform( rebin(lon / 15., dim[0], dim[3])         + $
                           rebin(reform(time,1,dim[3]),dim[0],dim[3]) )



      time0 = tau2yymmdd(dataInfo[i].tau0, /nf) ; 1st YYYYMMDD and 1st HHMMSS

      ;; --- print information
      if verbose then begin
         print, 'Time series #'+strtrim(i+1,2)+':'
         print, ' start at ', time0
         print, ' & end at ', tau2yymmdd(dataInfo.tau1, /nf)
         print, 'Total nb of days is ' + strtrim(ndays, 2)
         print, 'Time step is ' + strtrim(24/nstep, 2) + ' hour(s)'
         print, 'Area covered:'
         print, '  longitudes=['+strtrim(lon[0], 2)+', '+ $
            strtrim(lon[dim[0]-1], 2)+']'
         print, '   latitudes=['+strtrim(lat[0], 2)+', '+ $
            strtrim(lat[dim[1]-1], 2)+']'
         print, '   levels=['+strtrim(lev[0]+1, 2)+', '+ $
            strtrim(lev[dim[2]-1]+1, 2)+']'
         print,''
      endif

      ;;====================================================================
      ;; MANIPULATION
      ;;====================================================================
      
      ;; Basic Moving Average (if MAvg is even, MAvg+1 is used)
      if keyword_set(MAVG) then data = smooth(data, [1,1,1,mavg], _extra=e)



      ;; Daily max
      if keyword_set(dmax) then begin
         data = max( reform( temporary(data),dim[0],dim[1],dim[2],nstep,ndays ), $
                     dimension=4)
         time = lindgen(ndays)+time0[0]
      endif


   endfor

   ;;====================================================================
   ;; CLEANUP and quit
   ;;====================================================================

   ;; Undefine variables
   if arg_present(outdata) then outdata = data
   UnDefine, Data
   
end
