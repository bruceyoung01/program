; $Id: tsdiag.pro,v 1.1.1.1 2007/07/17 20:41:28 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        TSDIAG
;
; PURPOSE:
;        Reads and plots CTM time series (station) data. The
;        data are returned in a structure together with longitude,
;        latitude, altitude, and time information. TSDIAG tries to
;        construct a time vector from the TAU information stored
;        in the file. This may not always work (e.. it is assumed 
;        that time steps are 1 hour).
;           While reading, TSDIAG displays a '.' for each new station
;        encountered, and a '+' if a station is continued. If you want 
;        more detailed output, set the /VERBOSE flag.
;
;        %%% NOTE: May need updating %%%
;
; CATEGORY:
;        GAMAP Utilities, GAMAP Data Manipulation, GAMAP Plotting
;
; CALLING SEQUENCE:
;        TSDIAG [,RESULT] [,keywords]
;
; INPUTS:
;        None
;
; KEYWORD PARAMETERS:
;        FILENAME    -> Path of the input file containing CTM 
;                       Data data.
;
;        SCALE -> A global scale factor that will be applied to all
;                 data. Default is 1. Note that concentration data is
;                 stored as v/v, hence for ppt you should set 
;                 SCALE=1.E-12.
;
;        /VERBOSE -> display detailed information on what is being read.
;                 
;        /PLOT -> set this flag to produce quick-and-dirty plots of the 
;                 time-series data.
;
; OUTPUTS:
;        RESULT -> A structure containing LON, LAT, ALT and Data data
;               together with TRACER and a "global" TIME array.
;
; SUBROUTINES:
;        OPEN_DEVICE               CLOSE_DEVICE
;        CTM_TRACERINFO            FILE_EXIST (function)
;        STRSCINOT (function)
;
; REQUIREMENTS:
;
; NOTES:
;        Lines with the Data data (Header = 'TB' or 'DV') will be
;        read from disk.  Statistics are ignored for now.
;
; EXAMPLE:
;        ; read time series data from file and return result structure
;        ; in variable TSDATA
;        tsdiag, TSDATA, FILENAME='ctm.ts' 
;
; MODIFICATION HISTORY:
;        bmy, 06 May 1998: VERSION 1.00
;        bmy, 07 May 1998: VERSION 1.01
;                          - added PPBC and INTERVAL keywords
;                          - now calls FILE_EXIST to make sure
;                            the input file exists 
;        bmy, 27 May 1998  - now uses CTM_DIAGINFO to return
;                            the proper tracer offset
;        bmy, 28 May 1998  - now uses SCALE, UNIT, and MOLC information
;                            as returned by CTM_TRACERINFO.
;                          - now uses EXP_STR to compute a 
;                            power-of-ten string for the plot title
;        bmy, 29 May 1998  - now calls CLEANPLOT to initialize
;                            all system variables
;        bmy, 02 Jun 1998  - now uses STRSCI and STRCHEM string
;                            formatting functions
;        mgs, 11 Jun 1998: - couple of bug fixes
;        mgs, 15 Jun 1998: - default tick interval now 48 h
;        mgs, 22 Jun 1998: - added Data and CSTEPS keywords
;        mgs, 20 Nov 1998: - now uses convert_unit 
;        hsu, 22 Mar 1999: - increased MAXSTEPS and changed input format
;        mgs, 04 May 1999: - added MS as a tracer offset (100*MS)
;        mgs, 05 May 1999: - ... and a little bug fix
;        mgs, 19 May 1999: - updated comments
;                          - default SCALE factor now 1 instead of 1.E-12
;                          - CLEANPLOT no longer called
;        mgs, 24 May 1999: - added VERBOSE keyword
;                          - fixed at least two bugs
;                          - improved output. Now need to say /VERBOSE in
;                            order to get details.
;        mgs, 25 May 1999: - new format had MS and N swapped.
;        bmy, 27 Jul 1999: GAMAP VERSION 1.42
;                          - updated comments
;        bmy, 30 Jan 2002: GAMAP VERSION 1.50
;                          - Now use STRBREAK to split each line into 
;                            elements of data
;                          - Also no longer restrict data to be > 0
;  bmy & phs, 13 Jul 2007: GAMAP VERSION 2.10
;
;-
; Copyright (C) 1998-2007,
; Bob Yantosca and Philippe Le Sager, Harvard University
; This software is provided as is without any warranty whatsoever. 
; It may be freely used, copied or distributed for non-commercial 
; purposes. This copyright notice must be kept with any copy of 
; this software. If this software shall be used commercially or 
; sold as part of a larger package, please contact the author.
; Bugs and comments should be directed to bmy@io.as.harvard.edu
; or phs@io.harvard.edu with subject "IDL routine tsdiag"
;-----------------------------------------------------------------------


pro tsdiag, Result,  FileName=FileName, Scale=Scale, Plot=DoPlot,  $
      Verbose=Verbose
   


   Result = -1L   ; default


   Verbose = keyword_set(Verbose)

   if (n_elements(Scale) eq 0) then Scale = 1.    ; v/v as default

   ; Default Filename
   DefaultFile = '~/terra/CTM4/*.ts.*'
   if ( n_elements(FileName) eq 0 ) then $
       FileName = DefaultFile

   open_file,FileName,Ilun,default=DefaultFile,FileName=TrueFile, $
         title='Choose a time-series file'

   ; Check to see if the input file exists before proceeding
   if ( ilun le 0 ) then begin
      message,'Could not open input file '+FileName+'!',/Cont
      return
   end

   ; return true filename as FileName
   FileName = TrueFile

   if (Verbose) then $
      print,'Reading time series (station) data from ',TrueFile,' ...'
 
   ; Inititalize array variables
   ;MaxStations  = 800L
   MaxStations  = 2400L
   MaxSteps   =  8785L     ; number of hours in one leap year + 1
   Data       = fltarr( MaxSteps, MaxStations ) 
   Header     = strarr( MaxStations )
   Lat        = intarr( MaxStations )
   Lon        = intarr( MaxStations )
   Alt        = intarr( MaxStations )
   Tracer     = intarr( MaxStations )
;  MS         = intarr( MaxStations )
   CSteps     = lonarr( MaxStations )

   ; Initialize scalar variables
   Tau0 = 0L
   Tau1 = 0L


   ; Call CTM_DIAGINFO to get information about 
   ; this diagnostic (ND48 = Data)
   CTM_DiagInfo, 48, Offset=Offset


   ;====================================================
   ;  READ Data DATA 
   ; * Loop through file
   ; * Whenever a time series label is detected (TS, DV in
   ; old format, 'TIME-SERIES', 'DEPVEL' in new format)
   ; parse header line and read in data block
   ; * add as new station if location and tracer number
   ; were not encountered before, append if data block
   ; is continuation.
   ;====================================================


   First = 1
   NStations = 0
   NRecords = 0L

   while ( not EOF( Ilun ) ) do begin
      Line = ''
      readf, Ilun, Line

      ; ---------------------------------------------------------------- 
      ; ####  NEW FORMAT ##### mgs, 25 Nov 1998
      ; TIME-SERIES indicates time series concentration data
      ; DEPVEL denoted deposition velocities etc.
      ; ---------------------------------------------------------------- 
      on_ioerror,try_new_format

      thislabel = ''
      I = 0  &  J = 0  &  L = 0  &  N = 0  &  MS = 0
      AScale = 0.0
      ATau0 = 0L
      ATau1 = 0L
      reads,Line,thislabel,NLines,I,J,L,N,MS,AScale,ATau0,ATau1,  $
                 format='(1X,A12,6I5,E10.3,2I8)'

      if (Verbose) then $
         print,'detected line in obsolete mgs format : ',Line

      goto,read_data


      ; ---------------------------------------------------------------- 
      ; ####  NEW FORMAT #####
      ; ---------------------------------------------------------------- 
try_new_format:
      Line = strtrim(Line,2)
      ; test if this is a valid header line
      if ( strmid( Line, 0, 2 ) ne 'TB'   AND $ 
           strmid( Line, 0, 2 ) ne 'DV' ) then goto,Next_Iteration

      ; define additional dummy variables
      sdum = ''
      fdum1 = 0.0  &  fdum2 = 0.0  &  fdum3 = 0.0
      on_ioerror,try_old_format
      reads, Line, sdum,  $
         I, J, L, MS, N, NLines, ATau0, ATau1, AScale, $
         format='( a2, 6I5, 2I10, e14 )'

      if (Verbose) then $
         print,'detected line in new CTM format : ',Line

      goto,read_data

      ; ---------------------------------------------------------------- 
      ; ####  VERY OLD FORMAT #####
      ; still used in GISS CTM II. !! WARNING: This format does not
      ; allow model runs with 2x2.5 resolution !!
      ; (and it is extremely ugly!)
      ; ---------------------------------------------------------------- 
try_old_format:
      Line = strtrim(Line,2)
      ; test if this is a valid header line
      if ( strmid( Line, 0, 2 ) ne 'TB'   AND $ 
           strmid( Line, 0, 2 ) ne 'DV' ) then goto,Next_Iteration

      ; define additional dummy variables
      sdum = ''
      fdum1 = 0.0  &  fdum2 = 0.0  &  fdum3 = 0.0
      on_ioerror,Next_Iteration
      reads, Line, sdum,  $
         I, J, L, MS, NLines, N, fdum1, fdum2, fdum3, ATau0, ATau1, AScale, $
         format='( a2, 4I2, I3, I5, 3F6.3, 2I10, e10.3 )'

      if (Verbose) then $
         print,'detected line in old CTM format : ',Line

      ; ---------------------------------------------------------------- 
      ; Analyse input from header and loop through data lines
      ; ---------------------------------------------------------------- 
read_data:

      on_ioerror,NULL
      NRecords = NRecords + 1L
      if (First) then begin
         Tau0 = ATau0
         First = 0
      endif
      Tau1 = ATau1   ; will always be at least previous value

      ; check whether that same station has already been read
      test = where(Lon eq I AND Lat eq J AND Alt eq L AND $
                   Tracer eq N+100*(MS > 0))
      if (test[0] ge 0) then begin
         test = test[0]
         step = CSteps[test]
         Station = test

         if (Verbose) then $
            print,'Continue station ',strtrim(Station,2)  $
         else begin  
            print,'+',format='(A1,$)'
            if ((NRecords mod 50) eq 0) then $
               print,'/'
         endelse

      endif else begin
         step = 0L
         Station = NStations
         NStations = NStations + 1
         if (NStations ge MaxStations) then begin
            message,'Maximum number of stations exceeded!',/Cont
            return
         endif
         Header[Station] = strtrim(thislabel,2)
         Lon[Station] = I
         Lat[Station] = J
         Alt[Station] = L
         Tracer[Station] = N + 100*(MS > 0)

         if (Verbose) then $
            print,'New Station (lon,lat,alt,tracer):',I,J,L,N  $
         else begin  
            print,'.',format='(A1,$)'
            if ((NRecords mod 50) eq 0) then $
               print,'/'
         endelse

      endelse

      for i=1,NLines do begin 
         if (eof(ilun)) then goto,Next_Iteration   ; will end loop
         readf,Ilun,Line
;-----------------------------------------------------------------------------
; Prior to 1/30/02:
; Now use STRBREAK to split the line.  Also no longer restrict data to
; be greater than zero (bmy, 1/30/02)
;         DumArr = fltarr(12) - 9.99E31
;         on_ioerror,ignore_it    ; takes care of incomplete lines
;         reads, Line, DumArr, format='(12f6.2)'
;ignore_it:
;         on_ioerror,NULL
;        ind = where(dumarr gt -9.99E31,COUNT) 
;-----------------------------------------------------------------------------
         DumArr = StrBreak( Line, ' ' )           
         Count = N_Elements( DumArr )
         for J = 0, COUNT-1 do begin
             Data(Step, Station) = DumArr(J) * AScale
             Step = Step+1
             ;print, '### step: ', step
         endfor
         CSteps[Station] = step
         ;print, '### Station, CSTEPS: ', Station, CSTEPS[Station]
         ;pause
      endfor

Next_Iteration:
      on_ioerror,NULL
   endwhile

Abort_Reading: 
   ; Close file
   free_lun,ilun


   ; Test if any data was read successfully
   if (NStations eq 0) then begin
      message,'No data was read!',/Continue
      return
   endif


   print
   print,'Stations:',Nstations,' maximum number of STEPS: ', $
             max(csteps[0:NStations-1])
   print,'Tau0, Tau1, delta-Tau :',Tau0,Tau1,Tau1-Tau0,  $
           ' = ',(Tau2YYMMDD(Tau0,/SHORT))[0],'-',  $
          (Tau2YYMMDD(Tau1,/SHORT))[0], $
          format='(A,3I10,A3,I6,A1,I6)'

   ; Strip arrays
   MaxSteps = max(CSteps)
   Data = Data[*,0:NStations-1]
   Lon = Lon[0:NStations-1]
   Lat = Lat[0:NStations-1]
   Alt = Alt[0:NStations-1]
   Tracer = Tracer[0:NStations-1]
   CSteps = CSteps[0:NStations-1]

   Data = Data[0:MaxSteps-1,*]

   ; Rescale Data
   if (Scale ne 1.0) then $ 
      print,'Scaling data with factor ',Scale
   Data = Scale * Data


   ; Create Time vector
   Time = findgen(MaxSteps)/MaxSteps*(Tau1-Tau0)/24.

   ; =====================================================
   ; Prepare result structure
   ; =====================================================

   result = { Lon:Lon, Lat:Lat, Alt:Alt, Tracer:Tracer,  $
              TAU0:tau0, TAU1:tau1,  $
              Time:Time, DATA:Data  }


   if (keyword_set(DoPlot)) then begin
      ; quick and dirty quality control plots
      ; get unique station identifiers
      ulon = lon(uniq(lon,sort(lon)))
      ulat = lat(uniq(lat,sort(lat)))
      utra = tracer(uniq(tracer,sort(tracer)))

      ; plots per page - compute rows and cols
      nplots = n_elements(ulon)*n_elements(ulat)
      nx = (sqrt(nplots-1)+1) < 5
      ny = (sqrt(nplots-1)+1) < 4
      !p.multi=[0,nx,ny]
      !x.margin=[2,1]
      !y.margin=[2,1]
      for n=0,n_elements(utra)-1 do begin
       for i=0,n_elements(ulon)-1 do begin
        for j=0,n_elements(ulat)-1 do begin
         ind = where(Lon eq ulon[i] AND Lat eq ulat[j] AND Tracer eq utra[n])
         if (ind[0] lt 0) then goto,skip_this
         ; sort altitudes
         salt = sort(Alt[ind])
         nalt = n_elements(salt)
         ; get max data
         maxdat = max(data[*,ind])
         pw = 10.^(-fix(alog10(maxdat)-0.9999 ) )
         maxdat = fix(maxdat*pw)/pw
         ; draw coordinate frame
         plot,time,data[*,0],color=1,yrange=[0.,(nalt+1)*maxdat*0.5], $
            title=strtrim(ulon[i],2)+','+strtrim(ulat[j],2)+':'+ $
                  strtrim(utra[n],2)

         for l=0,nalt-1 do begin
            oplot,time,Data[*,ind[salt[l]]]+0.5*(l+1)*maxdat,  $
                 color=1,line=(l mod 2)*2
         endfor
skip_this:
        endfor
       endfor
      endfor

   endif 

   return
 
end


