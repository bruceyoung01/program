; $Id: read_sonde.pro,v 1.1.1.1 2007/07/17 20:41:36 bmy Exp $
;-----------------------------------------------------------------------
;+
; NAME:
;        READ_SONDE
;
; PURPOSE:
;        Read climatological ozone sonde data as compiled by 
;        Jennifer A. Logan at Harvard University.
;        If successful, the procedure returns a structure 
;        with all information from a sondeXXX.* file.
;        Ozone concentrations are automatically converted to ppbv.
;        The data can be downloaded via ftp from io.harvard.edu
;        path= pub/exchange/sonde. Please read the README files!
;
; CATEGORY:
;        Atmospheric Sciences, File & I/O
;
; CALLING SEQUENCE:
;        READ_SONDE,filename,data
;
; INPUTS:
;        filename -> Name of the file containing the sonde data.
;            This parameter can contain wildcards (*,?) in which case
;            a file selection dialog will be displayed. If filename
;            is a variable, it will be replaced by the actual filename
;            that was opened.
;
; KEYWORD PARAMETERS:
;        MBAR -> return ozone concentrations in mbar rather than ppbv
;
;        STATIONS -> Can be used either as input or output for a list
;            of station codes, locations and names as retrieved with
;            procedure read_sondestations. STATIONS must be specified
;            (or is returned) as an array of structures.
;
; OUTPUTS:
;        DATA -> A structure containing the following fields:
;                TITLE           STRING    'Ozone sonde data'
;                STATION         STRING    <station name>
;                STATIONCODE     INT       <WMO or JAL code>
;                TIMERANGE       STRING    <time range covered, e.g. 
;                                           '(01/86-12/93)'>
;                CORRECTION_FACTOR   FLOAT Array[2]   < sonde correction 
;                                                       factor range used
;                                                       for filtering of data
;                                                       (see README.data) >
;                PRESSURE        FLOAT  Array[22]     < pressure levels >
;                CONCENTRATION   FLOAT  Array[22, 12] < ozone concentrations >
;                UNIT            STRING               < 'ppbv' or 'mbar' >
;                SDEV            LONG   Array[22, 12] < std dev. in % of mean >
;                NUMBER          LONG   Array[22, 12] < number of sondings per 
;                                                       month and altitude >
;        If the station.codes file was read successfully, three more tags
;        are added to the structure:
;                LAT, LON, ALT   FLOAT  < geographical location of station >
;
; SUBROUTINES:
;        parse_line
;
; REQUIREMENTS:
;        This subroutine uses the following procedures and functions that
;        are not contained in the standard IDL distribution:
;        READ_SONDESTATIONS : tool for reading the station.codes file
;              (if you de-activate the line calling this procedure, READ_SONDE
;               will still work but not return the station coordinates)
;
;        EXTRACT_FILENAME  : a utility to seperate file path and file name 
;
;        FILE_EXIST : a function testing for existance of a file
;
;        OPEN_FILE  : more flexible than openr
;              (if you choose not to use OPEN_FILE, you can replace the
;               line that contains OPEN_FILE with:
;                   OPENR,filename,ilun,/get_lun 
;               You then don't need any of the following programs)
;
;        UNDEFINE   : David Fanning's routine for dynamic removal of variables
;
; NOTES:
;
; EXAMPLE:
;        ; read sonde data file
;        read_sonde,filename,data
;
;        ; test if successful
;        if (n_elements(data) eq 0) then stop
;
;        ; plot tropospheric profiles for all 12 month
;        plot,data.concentration[*,0],data.pressure,  $
;             xrange=[0.,100.],yrange=[1000,50],  $
;             color=1,title=data.station+' '+data.timerange, $
;             xtitle='Ozone ['+data.unit+']', ytitle='Pressure [mbar]'
;        for i=1,11 do oplot,data.concentration[*,i],data.pressure,  $
;             color=fix(i/6.)+1,line=(i mod 6)
;        ; add station location as label
;        label = '  LAT:'+string(data.lat,format='(f5.1)')+  $
;                '  LON:'+string(data.lon,format='(f6.1)')
;        xyouts,!x.window[0],!y.window[1]-0.1,label,color=1,/NORM
;
; MODIFICATION HISTORY:
;        mgs, 29 Oct 1998: VERSION 1.00
;        mgs, 02 Nov 1998: - added call to read_sondestations
;                            (i.e. can now return LAT, LON, ALT of station)
;                          - improved comments
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
; or phs@io.as.harvard.edu with subject "IDL routine read_sonde"
;-----------------------------------------------------------------------


pro parse_line,tok,alt,linedata,ppb=ppb,mbar=mbar
 
    ; analyze one data line (minimal error checking)
    ; (keyword ppb superseeds mbar)
 
    ; replace 'NA' by -999.
    ind = where(strupcase(tok) eq 'NA')
    if (ind[0] ge 0) then tok[ind] = '-999.'
   
    ; convert strings to numbers
    linedata = float(tok)
 
    ; extract pressure altitude
    alt = tok[0]
    linedata = linedata[1:*] 
     
    ; convert from micro-mbar to ppbv (or mbar)
    if (keyword_set(ppb)) then linedata = linedata*1000./alt  $
    else if (keyword_set(mbar) ) then linedata = linedata/1.e6
 
    return
end
 
 
 
pro read_sonde,filename,data,mbar=mbar,stations=stations
 
 
   ; read standard ozone sonde files from JAL
   ; return a structure containing all necessary information
   ; data is converted to ppbv as default
 
   ; undefine data if already there
   if (n_elements(data) gt 0) then undefine,data

   ; name of file with station codes
   scodefile = 'station.codes'

   ; get defaults 
   mbar = keyword_set(mbar)
   if (mbar) then unit = 'mbar' else unit = 'ppbv'
 
   if (n_elements(filename) eq 0) then $
       filemask = 'sonde*'  $
   else $
       filemask = filename
 
   ; open file  *** replace this line with OPENR,filename,ilun,/get_lun
   ;                if you don't want to use non-standard IDL routines ***
   open_file,filemask,ilun,filename=filename   ; <<<<<<<<<<<<<<<<<<<
 
   if (ilun le 0) then return
 
   on_ioerror,error_cond
 
   ; read title line
   title = ''
   readf,ilun,title
 
   ; extract stationcode, name, correction factors and time range
   tok = str_sep(strcompress(strtrim(title,2)),' ')
   stationcode = fix(tok[2])
   stationname = tok[3]
 
   ; NOTE: some of the old data don't have correction factors
   if (strmid(tok[4],0,4) ne 'LOCF') then begin
      locf = -999.
      hicf = -999.
      timerange = string(tok[4:*],format='(10A)')
   endif else begin
      tmp = str_sep(tok[4],'=')
      locf = float(tmp[1])
      tmp = str_sep(tok[5],'=')
      hicf = float(tmp[1])
      timerange = string(tok[6:*],format='(10A)')
   endelse
 
   ; skip one line  (contains labels)
   readf,ilun,title
   readf,ilun,title
 
   ; skip next lines until line starts with pressure value
   while (strlen(title) lt 5 OR strmid(title,0,5) eq '     ') do begin
      readf,ilun,title
   endwhile
 
   ; now title should contain first line of concentration data
   ; naalyze it and read rest of data
   ; use the fact that label for next category does not start before 
   ; column 10 to get end of data block
 
   while (strmid(title,0,5) ne '     ' AND strlen(title) gt 5) do begin
      tok = str_sep(strcompress(strtrim(title,2)),' ')
      if (n_elements(tok) ne 13) then goto,read_err
      parse_line,tok,linealt,lineconc,mbar=mbar,ppb=1-mbar
 
      if (n_elements(conc) eq 0) then conc = transpose(lineconc) $
      else conc = [ conc, transpose(lineconc) ]
      if (n_elements(alt) eq 0) then alt = linealt $
      else alt = [ alt, linealt ]
 
      ; read next line
      readf,ilun,title
   endwhile
 
 
   ; now read number of sondings
   ; we expect the same number of levels !
   ; first skip header block
   while (strlen(title) lt 5 OR strmid(title,0,5) eq '     ') do begin
      readf,ilun,title
   endwhile
 
   num = lonarr(n_elements(alt),12)
 
   for i=0,n_elements(alt)-1 do begin
      tok = str_sep(strcompress(strtrim(title,2)),' ')
      if (n_elements(tok) ne 13) then goto,read_err
      parse_line,tok,linealt,linenum
 
      if (linealt ne alt[i]) then begin
          message,'Mismatch in altitudes! File '+filename,/Cont
          message,'Current line: '+title,/Cont,/NoName
          free_lun,ilun
          return
      endif
 
      num[i,*] = long(linenum)
 
      ; read next line
      readf,ilun,title
   endfor
 
   
   ; now read standard deviations (percent)
   ; we expect the same number of levels !
   ; first skip header block
   while (strlen(title) lt 5 OR strmid(title,0,5) eq '     ') do begin
      readf,ilun,title
   endwhile
 
   sdev = lonarr(n_elements(alt),12)
 
   for i=0,n_elements(alt)-1 do begin
      tok = str_sep(strcompress(strtrim(title,2)),' ')
      if (n_elements(tok) ne 13) then goto,read_err
      parse_line,tok,linealt,linesdev
 
      if (linealt ne alt[i]) then begin
          message,'Mismatch in altitudes! File '+filename,/Cont
          message,'Current line: '+title,/Cont,/NoName
          free_lun,ilun
          return
      endif
 
      sdev[i,*] = linesdev
 
      ; read next line
      if (not eof(ilun)) then readf,ilun,title $
      else title = ''
   endfor
 
 
 
   ; got it all! Close file and create structure
 
   free_lun,ilun

   data = { title:'Ozone sonde data',  $
            station:stationname,       $
            stationcode:stationcode,   $
            timerange:timerange,       $
            correction_factor:[locf,hicf], $
            pressure:alt,              $
            concentration:conc,        $
            unit:unit,                 $ 
            sdev:sdev,                 $
            number:num  }


 
   ; try to get station codes with geographical locations
   ; *** Assumes station.codes as default filename. File must be
   ;     located in current directory or in directory of data file ***
   if (n_elements(stations) eq 0) then begin
      dummy = extract_filename(filename,filepath=searchpath)
      searchpath = '.:'+searchpath
      if (file_exist(scodefile,path=searchpath,full=stationfile)) then $
          read_sondestations,stations,stationfile 
   endif

   if (n_elements(stations) gt 0) then begin
      ; find current station by code
      test = where(stations.code eq stationcode)
      if (test[0] ge 0) then $   ; add geographical information to structure
          data = create_struct(data, 'LAT',stations[test[0]].lat,  $
                                     'LON',stations[test[0]].lon,  $
                                     'ALT',stations[test[0]].alt )

   endif
 
   return
            
 
read_err:
      message,'Error in file '+filename+'! Corrupted line:',/Cont
      message,'>'+title+'<',/Cont,/NoName
      free_lun,ilun
      return
 
error_cond:
   message,!Error_State.Msg,/Cont
   free_lun,ilun
   return
 
end
   
