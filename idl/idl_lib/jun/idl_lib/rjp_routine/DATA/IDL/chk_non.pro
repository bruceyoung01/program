 function chk_non, data

  p = where( finite(data) eq 0 )
  if p[0] ne -1 then data[p] = -999.

  return, data

 end
