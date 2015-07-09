 function castnet_siteinfo, map=map

 If !D.name eq 'WIN' then $
 file = '.\CASTNET\sites.csv' else $
 file = '/users/ctm/rjp/Data/CASTNET/sites.csv'

 openr, il, file, /get

 DAT = ''
 
 readf, il, DAT
 TAG = csvconvert(DAT)

 icount = -1L
 while (not eof(il)) do begin
  readf, il, DAT
  STR = csvconvert(DAT)
  If N_elements(STR) ne N_elements(TAG) then STR = [STR,' ']     
  icount = icount + 1L
  if icount eq 0 then VAR = STR else VAR = [VAR,STR]
 end
  free_lun, il

  VAR = reform(VAR,N_elements(TAG),icount+1)

 for i = 0, N_elements(TAG)-1 do begin
   if i eq 0 then result = create_struct(TAG[i],reform(VAR[i,*])) $
   else result = create_struct(result,TAG[i],reform(VAR[i,*]))
 endfor

  If keyword_set(map) then begin
    map_set, 0, 0, color=1, limit = [20., -130., 55., -60.]
    map_continents, /coasts, color=1, /countries, /usa
    for i = 0, N_elements(result.site_id)-1 do $ 
     xyouts, result.longitude(i), result.latitude(i), '*', color=1, $
     charsize=1.0, charthick=4.0, alignment=0.5
  Endif

 return, result

 end 
 
