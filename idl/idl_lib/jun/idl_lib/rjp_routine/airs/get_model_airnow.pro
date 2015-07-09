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

  OFF = 3L

  readdata, file, data, names_void, delim=',', /autoskip, $
      /noheader, cols=NV-OFF, $
      /quiet

  qdata = transpose(data)

  out = create_struct('siteid', names[0],        $
                      'Lon',    float(Names[1]), $
                      'Lat',    float(Names[2])  )
;                      'Elev',   float(Names[3])  )

  For D = OFF, N_elements(names)-1 do $
      out = create_struct(out, Names[D], Float(qdata[*,D-OFF]))

 return, out

 end

;-----------------------------------------------------------------

function get_model_airnow, files=files

  if n_elements(res)   eq 0 then res = 2
  if n_elements(files) eq 0 then begin
     dir = '/users/ctm/rjp/Data/AIRNOW/Model/daily_*.txt'
  endif

  spawn, 'ls '+dir, files
  tau0 = float(nymd2tau(20040101L))

  For D = 0, N_elements(files)-1 do begin
    data = get_data(file=files[D])
    print, files[d]
    tau  = data.tau

    jday = (tau - tau0[0])/24L + 1L
    data = create_struct(data, 'jday', jday)

    if D eq 0 then result = data else result = [result, data]
    undefine, data
  End

 return, result

 End
