 pro read_vars, file, NV, varstr


  OpenR, unit, file, /get_lun

  charline = '' & comment = ''

  readf, unit, NH
  readf, unit, NV   &  NV=fix(Nv)         ;# of variables

  varstr = StrArr(NV)

  for i = 0, NV-1 do begin
    readf, unit, charline
    headstr = StrTrim ( StrSplit ( StrTrim(charline,2), ',', /extract ), 2 )
    varstr(i) = headstr(0)
  endfor

  free_lun,  unit

 end

;-----------------------------------------------------------------

 function get_data, file=file

  if n_elements(file) eq 0 then return, 0

  read_vars, file, NV, names

  OFF = 4L

  readdata, file, data, names_void, delim=',', /autoskip, $
      /noheader, cols=NV-OFF, $
      /quiet

  qdata = transpose(data)

  out = create_struct('siteid', names[0],        $
                      'Lon',    float(Names[1]), $
                      'Lat',    float(Names[2]), $
                      'Elev',   float(Names[3])  )

  For D = OFF, N_elements(names)-1 do $
      out = create_struct(out, Names[D], Float(qdata[*,D-OFF]))


 return, out

 end

;-----------------------------------------------------------------

 function rd_site, file

 ; read raw data
 info  = get_data( file=file )

 Tau0  = nymd2tau(20040101L)
 JdayB = fix(nymd2tau(20040101L)-nymd2tau(20040101L))/24L
 JdayE = fix(nymd2tau(20041231L)-nymd2tau(20040101L))/24L
 Jday0 = Indgen(JdayE-JdayB+1L) + JdayB[0] + 1L

 ; species name that we want to retrieve from raw data
 spec = ['Ambient_Min_Temperature',       $
         'Pm2_5_Local_Conditions',        $
         'Ammonium_Ion_Pm2_5_Lc',         $
         'Organic_Carbon_Stn_Pm2_5_Lc',   $
         'Elemental_Carbon Stn_Pm2_5_Lc', $
         'Sulfate_Pm2_5_Lc',              $
         'Total_Nitrate_Pm2_5_Lc' ]

 name = ['MIN_TEMP','PM25','NH4','OMC','EC','SO4','NIT']

 ; basic site information
 results = {siteid:info.siteid, lon:info.lon, lat:info.lat, $
            elev:info.elev, jday:jday0}

 ; searching for the data we want and archive it as daily
 Tag    = Tag_names(info)
 sample = Replicate(-999., 366L)
 date   = Long(info.date)
 Jday   = (nymd2tau(date) - tau0[0])/24L

 For D = 0, N_elements(spec)-1 do begin
   P = where( Tag eq strupcase(spec[D]) )
   ; conversion from OC to OMC by multiplying 1.4
   if (Name[D] eq 'OMC') then fac = 1.4 else fac = 1.
   if P[0] ne -1 then begin
      field = reform(info.(P[0])) * fac
      ck    = where(field eq 0.)
      if ck[0] ne -1L then field[ck] = -999.
      sample[jday] = field
   end
   results = create_struct(results, Name[D], sample)
 End

 return, results

 End

;======================================================================

 function aqs_datainfo, Year

  if N_elements(Year) eq 0 then Year = 2004L
  Cyear = strtrim(Year,2)

  Dir = '/users/ctm/rjp/Data/AIRS/OUT/
  spawn, 'ls '+Dir+'*.txt', files

  For D = 0, N_elements(files)-1 do begin

   file = files[D]
   print, 'processing file ', file
   str = rd_site( file )
 
   if D eq 0 then obs = str else obs = [obs, str]
  End
  
  return, obs

 End
