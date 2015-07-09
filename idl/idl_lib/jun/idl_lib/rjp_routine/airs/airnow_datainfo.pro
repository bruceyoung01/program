 function rd_site, file

 JdayB = fix(nymd2tau(20040101L)-nymd2tau(20040101L))/24L
 JdayE = fix(nymd2tau(20041231L)-nymd2tau(20040101L))/24L
 Jday0 = Indgen(JdayE-JdayB+1L) + JdayB[0] + 1L

 spec = ['MIN_TEMP','SULFATE','NITRATE','AMMONIUM','ORGANICCARBONMASS','ELEMENTALCARBON']
 name = ['MIN_TEMP','SO4','NIT','NH4','OMC','EC']
 openr, il, file, /get

 hd  = ''
 siteid = ''
 sitename = ''
 
 readf, il, siteid
 readf, il, sitename
 readf, il, gmtdif
 readf, il, hd
 readf, il, lon, lat
 readf, il, a

 results = {siteid:siteid, sitename:sitename, gmtdif:gmtdif, $
            lon:lon, lat:lat, elev:0.}

 Tag = ''
 for D = 6, 80 do begin
   readf, il, hd   
   hd = exchar(hd,'(',' ')
   hd = exchar(hd,')',' ')
   Tag = [Tag, STRCOMPRESS(HD, /REMOVE_ALL)]
 end

 Tag  = Tag[1:*]

 jday = -999L
 gmt  = -999L
 data = -999.

 dat = fltarr(N_elements(Tag))
 while (not eof(il)) do begin 
    readf, il, a, b, c, dat
    jday = [jday, b]
    gmt  = [gmt, c]
    data = [data, dat]
 end

 free_lun, il

 jday = jday[1:*]
 gmt  = gmt[1:*]
 data = reform(data[1:*], N_elements(Tag), N_elements(jday))

 results = create_struct(results, 'jday', jday0)
 sample  = Replicate(-999., 366L)

 For D = 0, N_elements(Tag)-1 do begin
   P = where(strupcase(Tag[D]) eq spec)
   if P[0] ne -1 then begin
      sample[jday-1] = reform(Data[D,*])
      results = create_struct(results, Name[P[0]], sample[JdayB[0]:JdayE[0]])
   endif
 End

 return, results

 End

;======================================================================

 function airnow_datainfo, Year

  if N_elements(Year) eq 0 then Year = 2004L
  Cyear = strtrim(Year,2)

  Dir = './Output/'+Cyear+'/'
  spawn, 'ls '+Dir+'*.dat', files

  For D = 0, N_elements(files)-1 do begin

   file = files[D]
   print, 'processing file ', file
   str = rd_site( file )
 
   if D eq 0 then obs = str else obs = [obs, str]
  End
  
  return, obs

 End
