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

  Offset = 1L

  read_vars, file, NV, names

  readdata, file, data, names_void, delim=',', /autoskip, $
      /noheader, cols=NV-Offset, $
      /quiet

  qdata = transpose(data)

  out = create_struct('siteid', names[0])

  For D = Offset, N_elements(names)-1 do $
      out = create_struct(out, Names[D], Float(qdata[*,D-Offset]))


 return, out

 end

;-----------------------------------------------------------------

 function recon_struct, data, lon

   info = castnet_siteinfo()
   n    = where(data.siteid eq info.site_id)

   date = tau2yymmdd(data.tau[0])
   YEAR = date.year
   tau0 = nymd2tau(Long(date.year)*10000L+101L)
   NDAY = fltarr(N_elements(data.tau))

   for d = 0, N_elements(data.tau)-1 do begin
     dtau    = data.tau[d]-tau0
     NDAY[d] = dtau/24. + 1.
   end

   if n[0] ne -1 then begin
      out = create_struct('SITEID', info.site_id[n[0]],           $ 
                          'NAME',   info.station[n[0]],           $
                          'STATE',  info.state[n[0]],             $
                          'LON',    float(info.LONGITUDE[n[0]]),  $
                          'LAT',    float(info.LATITUDE[n[0]]),   $
                          'ELEV',   float(info.ELEVATION[n[0]])   )
      lon = float(info.LONGITUDE[n[0]])
   end else return, -1.
      
   TAG = TAG_NAMES(DATA)
   For D = 0, N_Tags(data)-1 do begin

     FLD = DATA.(D)
     if n_elements(FLD) gt 1 then begin
        NEW = Replicate(-999., 365L)
        For N = 0, N_ELEMENTS(FLD)-1 do NEW[NDAY[N]-1] = FLD[N]
        out = create_struct(out, TAG[D], NEW)
     end

     jump:
   end
   
   return, out
 end

;============================================================================

 function castnet_o3_daily

  files = collect('/users/ctm/rjp/Data/CASTNET/O3_hourly/2001/*_daily.txt')

  For D = 0, N_elements(files)-1 do begin

    data = get_data(file=files[D])

    out = recon_struct( data, lon )
    print, files[d]
    if lon lt -130. then goto, jump

    if D eq 0 then result = out else result = [result, out]

    jump:
    undefine, out
    undefine, data
  End

 return, result

 End
