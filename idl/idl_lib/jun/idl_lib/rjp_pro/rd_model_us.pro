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

  off = 4L

  read_vars, file, NV, names

  readdata, file, data, names_void, delim=',', /autoskip, $
      /noheader, cols=NV-off, $
      /quiet

  qdata = transpose(data)

  out = create_struct('siteid', names[0],        $
                      'Lon',    float(Names[1]), $
                      'Lat',    float(Names[2]), $
                      'Elev',   float(Names[3])  )


  For D = off, N_elements(names)-1 do $
      out = create_struct(out, Names[D], Float(qdata[*,D-off]))


 return, out

 end

;=======================================================

 function rd_model_us, nofire=nofire

  if keyword_set(nofire) then $
    dir = '/users/ctm/rjp/Research/icartt/model_data/sen/daily/*.txt' else $
    dir = '/users/ctm/rjp/Research/icartt/model_data/std/daily/*.txt'

  files = collect(dir)

  modelinfo = ctm_type('GEOS4_30L',res=2)
  gridinfo  = ctm_grid(modelinfo)

  ; 2D array of model lat lon
  lon = gridinfo.xmid#replicate(1.,91)
  lat = replicate(1.,144)#gridinfo.ymid

  For D = 0, N_elements(files)-1 do begin

    data = get_data(file=files[D])

    print, files[d]
    if data.lon lt -130. then goto, jump
    if data.lat le 24.   then goto, jump

    ID   = where(lon eq data.lon and lat eq data.lat)
    IF ID[0] eq -1 then message, 'no lat lon present'

    data = create_struct(data, 'ID', ID[0])

    if D eq 0 then result = data else result = [result, data]

    jump:
    undefine, data
  End

 return, result

 End
