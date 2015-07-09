 function define_country, code

  if n_elements(code) eq 0 then code = 176L

  ctncode = lonarr(360,180)
  Openr,il,'/users/ctm/rjp/Data/MAP/newcountry.codes.1x1.Jun15',/Get
  Readf,il,ctncode
  Free_lun,il

  map = fltarr(360,180) ; generic 1x1 emission grid.

  for j = 0, 179 do begin
  for i = 0, 359 do begin

      for d = 0, n_elements(code)-1 do begin
          chk = where((ctncode[i,j]/100) eq code[d])
          if ( chk[0] ne -1 ) then map[i,j] = 1.
      end

  endfor
  endfor

  tvmap, map, /conti, /sample, /cbar, divis=4

  return, map

 end
