
;read/save all DC-8 flight data (for specified variables) into a *.dat file
;hyl, 09/16/2001

 pro example 

;=================== Read TRACE-P aircraft DC-8 data =====================
 INDEX= FltArr (10000)
 Jday = FltArr (10000)
Flight= IntArr (10000)
 UTC  = FltArr (10000)
 SECS = FltArr (10000)
 LAT  = FltArr (10000)
 LON  = FltArr (10000)
PRESSURE = FltArr (10000)
 ALTP = FltArr (10000)
 ALTR = FltArr (10000)
   O3 = FltArr (10000)
   CO = FltArr (10000)
   Pb = FltArr (10000)
   Be = FltArr (10000)

 fchar = ['04','05','06','07','08','09','10', $
          '11','12','13','14','15','16','17','18','19', '20']
 fdigitn = [4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20]

 startline = 0L

;open a file to save all samples for all flights
 OpenW, udata, 'example.data.dc8.1min.txt', /get_lun
 printf, udata,'JD', 'UTC', 'F#', 'LAT', 'LON', 'ALTP', 'O3', 'CO',format='(A3,A6,A3,5A9)'

;loop over flights

 for j= 0, N_Elements(fchar)-1 do begin  ;17 flights

  dirname = '/data/tracep/merge_sept_2001/dc8/1min/' 
  file = dirname + 'prelim-mrg60d'+fchar(j) + '.trp'

 ;get all NV variable strings
  read_varstr, file, NV, header 

 ;get NV columns of data
  readdata, file, data, header_void, delim=',',/autoskip, /noheader, cols=NV

 ;help, data
 ;print, 'data= ', data 
 ;print, 'header= ', header

 OpenW, uheader, 'example.headers.dc8.1min.txt',/get_lun
  printf,uheader, 'header=', header
  print, 'header=', header
  printf, uheader,''
  for i = 0, N_elements(header)-1 do begin
   printf,uheader, i+1, 'th header=', header(i)
   print, i+1, 'th header= ', header(i)
  endfor
 Free_Lun, uheader

getspec, data, header, Index_TMP,   'INDEX'
getspec, data, header, FLIGHT_TMP,  'FLIGHT'
getspec, data, header, UTC_TMP,     'UTC'
getspec, data, header, Jday_TMP,    'JDAY'
getspec, data, header, LAT_TMP,     'LATITUDE'
getspec, data, header, LON_TMP,     'LONGITUDE'
getspec, data, header, ALTP_TMP,    'ALTP'
getspec, data, header, PRESSURE_TMP,'PRESSURE'
getspec, data, header, O3_TMP,      'Ozone'
getspec, data, header, CO_TMP,      'Carbon Monoxide mixing ratio'
help, INDEX_TMP, FLIGHT_TMP, UTC_TMP, JDAY_TMP, LAT_TMP, LON_TMP, $
      ALTP_TMP, PRESSURE_TMP, O3_TMP, CO_TMP

;total lines of data: N_elements(Jday_TMP)
 datalines = N_elements(Jday_TMP)

;push samples in each flight to a single data array
 Index (startline:startline+datalines-1)   = Index_TMP(0:datalines-1)
 Flight (startline:startline+datalines-1)  = Flight_TMP(0:datalines-1)
 UTC (startline:startline+datalines-1)     = UTC_TMP(0:datalines-1)
 Jday (startline:startline+datalines-1)    = Jday_TMP(0:datalines-1)
 LAT  (startline:startline+datalines-1)    = LAT_TMP(0:datalines-1)
 LON  (startline:startline+datalines-1)    = LON_TMP(0:datalines-1)
 PRESSURE (startline:startline+datalines-1)= PRESSURE_TMP(0:datalines-1)
 ALTP(startline:startline+datalines-1)     = ALTP_TMP(0:datalines-1)
 O3   (startline:startline+datalines-1)    = O3_TMP(0:datalines-1)
 CO   (startline:startline+datalines-1)    = CO_TMP(0:datalines-1)

;find the start point where data for next flight will be pushed into
 startline = startline + datalines

;save samples in each flight to a file
 for i = 0, datalines-1 do begin
 printf, udata,Jday_TMP(i),UTC_TMP(i),Flight_TMP(i),LAT_TMP(i),LON_TMP(i), ALTP_TMP(i), $
               O3_TMP(i), CO_TMP(i), format='(I3,I6,I3,5F9.3)'
 endfor

endfor  ;17 flights

Free_lun, udata

 ;size of final data arrays
  ARRSIZE = startline
  print, 'size of final data arrays = ', ARRSIZE
  IF ( N_Elements( where (Jday ne 0) ) ne ARRSIZE ) then begin
      print, 'size of final data arrays (', N_Elements(Jday),') \= ARRSIZE !'
      STOP
  ENDIF

;=================== Read TRACE-P aircraft DC-8 data : END =====================

end
