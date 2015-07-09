 function sort_positive, data

  p = where( data gt 0. )
  if p[0] ne -1 then return, data[p] else message, 'no positive data'

  return, -1

 end
