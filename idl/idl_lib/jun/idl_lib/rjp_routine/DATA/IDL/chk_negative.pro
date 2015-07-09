 function chk_negative, data, Undef=Undef

  if n_elements(Undef) eq 0 then Undef = 'NaN'

  NewData = Data
  p = where( data lt 0. )
  if p[0] ne -1 then Newdata[p] = Undef

  return, NewData

 end
