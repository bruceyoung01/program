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

  Offset = 4L

  read_vars, file, NV, names

  readdata, file, data, names_void, delim=',', /autoskip, $
      /noheader, cols=NV-Offset, $
      /quiet

  qdata = transpose(data)

  out = create_struct('siteid', names[0], 'lon', float(names[1]), $
                      'lat', float(names[2]), 'elev', float(names[3]))

  For D = Offset, N_elements(names)-1 do $
      out = create_struct(out, Names[D], Float(qdata[*,D-Offset]))


 return, out

 end

;============================================================================

;   DIR   = './geos_test/'
   DIR    = './data_castnet/out_nofire/'
;   TAIL  = '_daily.txt'
   TAIL  = '_aft.txt'

   files = collect(DIR+'hourly_*.txt')
   off   = 4L
   nymd0 = 20040101L
   tau0  = nymd2tau(nymd0)

  For D = 0, N_elements(files)-1 do begin

    data = get_data(file=files[D])
    tag  = tag_names(data)
    str  = strtrim(n_tags(data)-off, 2)
    tdf  = round( data.lon / 15. ) ; time difference between gmt and lt
    avg  = fltarr(n_tags(data)-off)

    wfile = DIR + data.siteid + TAIL

    openw, jl, wfile, /get
    print, wfile

    printf, jl, strtrim(n_tags(data)+2L,2)
    printf, jl, strtrim(n_tags(data),2)
    printf, jl, data.siteid
    printf, jl, data.lon
    printf, jl, data.lat
    printf, jl, data.elev
    tag[off] = 'JDAY'
    for n = off, n_elements(tag)-1 do printf, jl, tag[n]

    lmt  = data.tau + tdf
    jday = tau2jday(lmt, base=nymd0)
    date = tau2yymmdd(lmt)
    jtime= jday*100L + date.hour
    jhr  = date.hour
    ii   = sort(jday)
    jj   = uniq(jday[ii])
    j0   = jday[ii[jj]]

    for N = 0, N_elements(j0)-1L do begin 
        p = where(jday eq j0[N])
        s = where(jhr[p] ge 13. and jhr[p] le 17.)

;        print, j0[N], n_elements(s)

        for Q = 0, n_tags(data)-off-1L do begin
            f = Data.(Q+off)[P]

            if s[0] ne -1 then avg[Q] = mean(f[s], /nan) else avg[Q] = -999.
;            avg[Q] = mean(f, /nan)
        end

        printf, jl, jday[P[0]], avg[1:*], format='('+str+'F11.3)' 
     end

    free_lun, jl
    undefine, data

  end

end
