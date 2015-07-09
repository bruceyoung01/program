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


 function take_avg, data

 ; sort out missing data
 p   = where(data lt 0.)
 if p[0] ne -1 then data[p] = 'NaN'

 return, mean(data,/NaN)

 end

;=======================================================

 function read_site, sites

  YEARS = Findgen(17)+1988L
  CYEARS= string(Years,form='(I4)')
  DIR = '/users/ctm/rjp/Data/IMPROVE/Raw_data/DAILY_'

  values = fltarr(N_elements(years))

  For D = 0, N_elements(CYEARS)-1 do begin
    FILE = DIR + CYEARS[D] + '/' + SITES[D] + '_' + CYEARS[D] + '.txt'
    print, file

    data = get_data(file=file)
    ND   = where(data.date gt 600. and data.date lt 900.)
    MF   = data.MF[ND]
    values[D] =  take_avg(MF)
  End

  return, values

 end
;=======================================================
@define_plot_size

  SITEID = ['GLAC1','LAVO1','RMHQ1','YELL1']
 
  DATA  = FLTARR(17, N_ELEMENTS(SITEID))
  FOR D = 0, N_ELEMENTS(SITEID)-1L DO BEGIN
     SITES = Replicate(SITEID[D], 17)
     IF D EQ 2 THEN SITES = [Replicate('RMHQ1', 3), Replicate('ROMO1', 14)]
     IF D EQ 3 THEN SITES = [Replicate('YELL1', 8), Replicate('YELL2', 9)]
     DATA[*,D] = read_site(sites)
  END

 mean = total(data,2)/4.
 xyear = findgen(17)+1988L
 plot,  xyear, mean, color=1, xstyle=1, thick=dthick, yrange=[3.,7.]

 openw, il, 'pm25_4sites.txt', /get
 printf, il, xyear, format='(17I7)'
 printf, il, mean, format='(17F7.3)'
 free_lun, il
 end
