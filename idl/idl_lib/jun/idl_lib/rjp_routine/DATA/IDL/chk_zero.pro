 function chk_zero, data, Undef=Undef

  if n_elements(Undef) eq 0 then Undef = -999.

  NewData = Data
  p = where( data eq 0. )
  if p[0] ne -1 then NewData[p] = Undef

  return, NewData

 end
