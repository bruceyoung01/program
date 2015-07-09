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

  readdata, file, data, names_void, delim=',', /autoskip, $
      /noheader, cols=NV-2L, $
      /quiet

  qdata = transpose(data)

  out = create_struct('siteid', names[0], 'year', Names[1])

  For D = 2, N_elements(names)-1 do $
      out = create_struct(out, Names[D], Float(qdata[*,D-2L]))


 return, out

 end

;-----------------------------------------------------------------

 function recon_struct, data, date, nofile

   nofile = -1.
   info = search_siteinfo()
   n = where(data.siteid eq info.siteid)

   YYMMDD0 = Long(data.year)*10000L+101L
   NDAY = fltarr(N_elements(date))
   for d = 0, N_elements(date)-1 do begin
     YYMMDD  = Long(data.year)*10000L+Long(date[d])
     dtau    = nymd2tau(YYMMDD)-nymd2tau(YYMMDD0)
     NDAY[d] = dtau/24. + 1.
   end

   if n[0] ne -1 then begin
      out = create_struct('SITEID', info.siteid[n[0]], $
                          'NAME',   info.name[n[0]],   $
                          'STATE',  info.state[n[0]],  $
                          'LON',    info.lon[n[0]],    $
                          'LAT',    info.lat[n[0]],    $
                          'ELEV',   info.elev[n[0]],   $
                          'YEAR',   data.year      ,   $
                          'DATE',   date           ,   $
                          'JDAY',   NDAY               )
   end else begin
      nofile = 1.
      return, -1.
   end
      
   TAG = TAG_NAMES(DATA)
   For D = 0, N_Tags(data)-1 do begin

     if TAG[D] eq 'DATE' then goto, jump

     FLD = DATA.(D)
     if n_elements(FLD) gt 1 then begin
        NEW = Replicate(-999.,N_ELEMENTS(date))

        For N = 0, N_ELEMENTS(FLD)-1 do begin
            P = where(data.date[N] eq date)
            if P[0] ne -1 then begin
               NEW[P[0]] = FLD[N]
            end else begin
               print, 'result is wrong'
               stop
            end
        End           

        out = create_struct(out, TAG[D], NEW)
     end

     jump:
   end
   
   return, out
 end

;=======================================================

 function get_search_daily, year

  if n_elements(year) eq 0 then year = 2001L
  cyear = strtrim(year,2)

  files = collect('/users/ctm/rjp/Data/SEARCH/DAILY_'+cyear+'/*.txt')

  For D = 0, N_elements(files)-1 do begin

    data = get_data(file=files[D])
    if D eq 0 then Date = data.date

    out = recon_struct( data, date, nofile )
    print, files[d]

    if nofile eq 1. then goto, jump
    if out.lon lt -130. then goto, jump
    if out.lat le 24. then goto, jump
    if D eq 0 then result = out else result = [result, out]

    jump:
    undefine, out
    undefine, data
  End

 return, result

 End
