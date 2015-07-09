
 function find_country_id, name

  file = '/users/ctm/rjp/Data/MAP/country_code.txt'
  id   = lonarr(185)
  code = strarr(185)
  i    = 1L
  a    = ' '

  Openr, il, file, /get
  ict  = 0L
  while (not eof(il)) do begin
     readf, il, i, a, format='(i4, 1x, a20)'
     id[ict]   = i
     code[ict] = a    
     ict = ict + 1L
  end

  return, id

 end
