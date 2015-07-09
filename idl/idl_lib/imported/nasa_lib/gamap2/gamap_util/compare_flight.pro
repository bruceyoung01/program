; $Id: compare_flight.pro,v 1.1.1.1 2007/07/17 20:41:28 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        COMPARE_FLIGHT
;
; PURPOSE:
;        Compare observations from aircraft campaigns to 
;        high time-resolution CTM output (bpch files).
;        This routine reads aircraft data in binary (bdt) format
;        and produces an unlabeld plot and returns all the data
;        you might ask for. If an aircraft mission extends beyond
;        midnight GMT, the program will ask for a second model file
;        which should be from the following day.
;
; CATEGORY:
;        GAMAP Utilities, GAMAP Plotting
;
; CALLING SEQUENCE:
;        COMPARE_FLIGHT, keywords
;
; INPUTS:
;        None
;
; KEYWORD PARAMETERS:
;      DATAFILE -> Name of the aircraft data file or file mask
;
;      MODELFILE -> Name of the (first) model output file or file mask
;
;      TRACER -> tracer number in model output (default=71)
;
;      PSURF -> surface pressure for model grid (default=1013, because most
;          aircraft data was sampled over oceans)
;
;      FLIGHTDATA -> returns the observational data array as read
;          with gte_readbin. Can also be used to pass flight data if you
;          set the USE_DATA flag.
;
;      FLIGHTVARS -> returns the variable names of the observational data.
;          Must accompany FLIGHTDATA if you use USE_DATA.
;
;      SPECIES -> the name of the observed species to plot (default CH3I).
;
;      MODELDATA -> returns a time series of model data along the flight 
;          track and a couple of min/max values:
;             MODELDATA[*,0] = model value in corresponding grid box
;                      [*,1] = min of neighbouring grid boxes at same level
;                      [*,2] = max ...
;                      [*,3] = min of neighbouring grid boxes at level below
;                      [*,4] = max ...
;                      [*,5] = min of neighbouring grid boxes at level above
;                      [*,6] = max ...
;          Note that the min/max arrays may contain values from the same
;          grid boxes at the edges (i.e. there is no level below the first
;          one, hence 3,4 will be identical to 1,2).
;
;      TIME -> returns the time vector of the observations and modeldata
;
;      /USE_DATA -> set this flag if you provide the aircraft data in the
;          FLIGHTDATA array and the variable names in FLIGHTVARS. The data
;          must contain variables named 'LON', 'LAT', 'ALTP' and SPECIES
;          (for SPECIES see above). You must also provide a TIME vector
;          which specifies UTC seconds.
;
; OUTPUTS:
;      The extracted data is returned in MODELDATA, several other keywords
;      return things read or computed in the process.
;
; SUBROUTINES:
;      EXTRACT__FLIGHT : actual workhorse that does the extraction
;
; REQUIREMENTS:
;      chkstru, ctm_get_data (GAMAP), gte_readbin (GTE)
;
; NOTES:
;      Some hardwiring of default directories.
;
; EXAMPLE:
;      simply  COMPARE_FLIGHT,tracer=1  if all you want is a plot
; 
;      CONVERT_FLIGHT,tracer=1,modeldata=md,time=time
;      plot,time,md[*,0],color=1
;
; MODIFICATION HISTORY:
;      mgs, 21 Apr 1999: VERSION 1.00
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
; or phs@io.harvard.edu with subject "IDL routine compare_flight"
;-----------------------------------------------------------------------


pro extract__flight,datafile=datafile,modelfile=modelfile, $
       tracer=tracer,psurf=psurf, $
       flightdata=flightdata,flightvars=flightvars,use_data=use_data,  $
       modeldata=modeldata,  $
       time=time,daytwo=daytwo
 
 
  ; extract data along flight tracks from high-resolution model results
  ; this is the actual work horse routine
 
  if (n_elements(datafile) eq 0) then $
     datafile='/data/pem-t/dc8/binary/ucgc*.bdt'
 
  if (n_elements(modelfile) eq 0) then $
     modelfile='~/amalthea/CTM4/runch3i_Mar99/ts*.bpch'
 
  if (n_elements(tracer) eq 0) then tracer = 71    ; ocean CH3I
  if (n_elements(psurf) eq 0) then psurf = 1013.   ; ocean
 
 
  ; read experiment data and extract LAT, LON, ALT
  ; unless use_data is given
  if (not keyword_set(use_data)) then begin
     gte_readbin,datafile,flightdata,vardesc,time=time
     if (n_elements(flightdata) lt 2 OR not chkstru(vardesc,'NAME') ) $
        then return
     flightvars = vardesc.name
  endif
 
  if (n_elements(flightdata) lt 2 OR n_elements(flightvars) lt 1) then return
 
  if (keyword_set(daytwo)) then time = time - 86400.
 
  spec = [ 'LON', 'LAT', 'ALTP' ]
  sel = make_selection(flightvars,spec)
  if (min(sel) lt 0) then stop,'Could not find lat, lon or altp!'
  lon = flightdata[*,sel[0]]
  lat = flightdata[*,sel[1]]
  lev = flightdata[*,sel[2]]
 
  ; convert altitude from feet to km if necessary
  if (max(lev) gt 100.) then lev = lev*0.3025e-3
 
 
  ; read model data and set up grid
  ctm_get_data,datainfo,'IJ-AVG-$',filename=modelfile,tracer=tracer, $
      use_fileinfo=fileinfo
 
  if (n_elements(datainfo) lt 2) then return
  fileinfo.modelinfo.psurf = psurf    ; overwrite standard surface pressure
 
  fileinfo.gridinfo = ptr_new( ctm_grid(fileinfo.modelinfo) )
 
  ; get edge coordinates for geographical region
  ; construct index array from dimensional info of first datainfo record
  mloni = lindgen(datainfo[0].dim[0]+1) + datainfo[0].first[0] - 1
  mlati = lindgen(datainfo[1].dim[1]+1) + datainfo[1].first[1] - 1
  mlevi = lindgen(datainfo[2].dim[2]+1) + datainfo[2].first[2] - 1
 
  mloni = mloni mod (*fileinfo.gridinfo).imx
  mlati = mlati mod (*fileinfo.gridinfo).jmx
  mlevi = mlevi mod (*fileinfo.gridinfo).lmx
  
  mlon = (*fileinfo.gridinfo).xedge[mloni]
  mlat = (*fileinfo.gridinfo).yedge[mlati]
  mlev = (*fileinfo.gridinfo).zedge[mlevi]
 
  nmlon = n_elements(mlon)
  nmlat = n_elements(mlat)
  nmlev = n_elements(mlev)
 
  ind = where(mlon lt -180.) 
  if (ind[0] ge 0) then mlon[ind] = mlon[ind] + 360.
  ; convert longitudes to Pacific style if model region spans dateline
  if ( datainfo[0].dim[0]+datainfo[0].first[0] gt (*fileinfo.gridinfo).imx ) $
     then convert_lon,mlon,/Pacific  
 
  print,nmlon,'LONS: ',mlon
  print,nmlat,'LATS: ',mlat
  print,nmlev,'LEVS: ',mlev
 
  ; get model time as UTC seconds
  mtimestru = tau2yymmdd(datainfo.tau0)
  mtime0 = mtimestru.hour*3600. + mtimestru.minute*60. + mtimestru.second
; that's how it should be:
; mtimestru = tau2yymmdd(datainfo.tau1)
; mtime1 = mtimestru.hour*3600. + mtimestru.minute*60. + mtimestru.second
  mtime1 = mtime0 + ( mtime0[1]-mtime0[0] )
 
 
  ; now loop through time array and extract matching model data
  modeldata = fltarr(n_elements(time),7)-9.99E30
 
; print,'TIME EXP=',min(time),max(time),'  MOD=',min(mtime0),max(mtime1)
 
  for i=0,n_elements(time)-1 do begin
     ti = where(mtime0 le time[i] AND mtime1 gt time[i])
     if (ti[0] ge 0) then begin
        if (n_elements(ti) gt 1) then message,'MORE THAN 1 TIME ??!!',/Continue
        loni = max( where(mlon le lon[i]) )
        lati = max( where(mlat le lat[i]) )
        levi = max( where(mlev le lev[i]) )
;  if (i lt 200) then print,lon[i],lat[i],lev[i],loni,lati,levi
        if ( loni ge 0 AND lati ge 0 AND levi ge 0  $
         AND loni lt nmlon AND lati lt nmlat AND levi lt nmlev ) then begin
           ; get value for closest grid box
           modeldata[i,0] = (*datainfo[ti].data)[loni,lati,levi]
           ; get min and max for neighbouring grid boxes
           ; at same level, level below and level above
           tmp = (*datainfo[ti].data)[(loni-1)>0 : (loni+1)<(nmlon-1),*,*]
           tmp = tmp[*,(lati-1)>0:(lati+1)<(nmlat-1),*]
 
           modeldata[i,1] = min( tmp[*,*,levi] )
           modeldata[i,2] = max( tmp[*,*,levi] )
           modeldata[i,3] = min( tmp[*,*,(levi-1)>0] )
           modeldata[i,4] = max( tmp[*,*,(levi-1)>0] )
           modeldata[i,5] = min( tmp[*,*,(levi+1)<(nmlev-1)] )
           modeldata[i,6] = max( tmp[*,*,(levi+1)<(nmlev-1)] )
        endif
     endif
  endfor
 
 
 
  if (keyword_set(daytwo) ) then time = time + 86400.
 
  return
end
 
 
 
 
 
 
pro compare_flight,datafile=datafile,modelfile=modelfile, $
       tracer=tracer,psurf=psurf, $
       flightdata=flightdata,flightvars=flightvars,species=species, $
       modeldata=modeldata,time=time,use_data=use_data
 
 
    if (n_elements(species) eq 0) then species = 'CH3I'
 
    ; get data for one flight and at least part of the model results
 
    extract__flight,datafile=datafile,modelfile=modelfile, $
       tracer=tracer,psurf=psurf, $
       flightdata=flightdata,flightvars=flightvars,  $
       modeldata=modeldata,time=time,use_data=use_data
 
    if (n_elements(modeldata) lt 2) then return   ; wasn't too successful
 
 
    ; if the time array extends beyond midnight, read another 
    ; model file
    if (max(time) gt 86400.) then begin
       undefine,modelfile
       extract__flight,datafile=datafile,modelfile=modelfile, $
          tracer=tracer,psurf=psurf, $
          flightdata=flightdata,flightvars=flightvars,/use_data,  $
          modeldata=md2,time=time,/daytwo
 
       if (n_elements(md2) lt 2) then return   ; wasn't too successful
 
       ; merge model data together [ shouldn't be any overlap and arrays
       ; should have same size ]
; print,min(modeldata),max(modeldata)
; print,min(md2),max(md2)
       ind = where(md2 ge 0.)
 
       if (ind[0] ge 0) then $
          modeldata[ind] = md2[ind]
    endif
 
 
; ### *****  GLITCH FIX for now: old binaries have wrong tracer and
; ### *****  get therefore scaled wrongly
modeldata = 1000.*modeldata
 
    si = where(strupcase(flightvars) eq strupcase(species) )
    if (si[0] lt 0) then begin
       message,'Cannot find species '+species+' in flightvars!',/Continue
       return
    endif
 
    ; produce a plot with measured data
    plot,time,flightdata[*,si[0]],color=1,min_val=0.
 
    ; overlay model curves: first from different levels
    oplot,time,modeldata[*,6],color=15,line=3
    oplot,time,modeldata[*,5],color=15,line=3
    oplot,time,modeldata[*,4],color=15,line=2
    oplot,time,modeldata[*,3],color=15,line=2
    oplot,time,modeldata[*,2],color=3,line=0
    oplot,time,modeldata[*,1],color=3,line=0
    oplot,time,modeldata[*,0],color=2,line=0
 
    legend,halign=0.95,valign=0.95,line=[0,0,0,2,3],lcolor=[1,2,3,15,15], $
       label=['observations','grid box','min/max same level', $
              'min/max level below', 'min/max level above' ]
 
    return
 
end
 
