; find 4 corners 

PRO compute_4_corner, rlat, rlon, nx, ny, rlatll, rlatlr, rlatul, rlatur, $
                     rlonll, rlonlr, rlonul, rlonur

     rlat1l  = fltarr(nx, ny)
     rlatlr  = fltarr(nx, ny)
     rlatul  = fltarr(nx, ny)
     rlatur  = fltarr(nx, ny)
     rlonll  = fltarr(nx, ny)
     rlonlr  = fltarr(nx, ny)
     rlonul  = fltarr(nx, ny)
     rlonur  = fltarr(nx, ny)

    for i = 1, nx-2 do begin
      for j = 1, ny-2 do begin

       rlatll(i, j) = 0.25 * total(rlat(i-1:i, j-1:j))
       rlatlr(i, j) = 0.25 * total(rlat(i:i+1, j-1:j))
       rlatul(i, j) = 0.25 * total(rlat(i-1:i, j:j+1))
       rlatur(i, j) = 0.25 * total(rlat(i:i+1, j:j+1))

       rlonll(i, j) = 0.25 * total(rlon(i-1:i, j-1:j))
       rlonlr(i, j) = 0.25 * total(rlon(i:i+1, j-1:j))
       rlonul(i, j) = 0.25 * total(rlon(i-1:i, j:j+1))
       rlonur(i, j) = 0.25 * total(rlon(i:i+1, j:j+1))

      endfor
   endfor
END

; find the box that bracket the 4 corners 

PRO putin_4_corner, rlat, rlon, nx, ny, rlatll, rlatlr, rlatul, rlatur, $
                    rlonll, rlonlr, rlonul, rlonur, clat, clon, $
                    inx, iny
    
    result = where( rlatll le clat   and rlonll le clon and $
                    rlatlr le clat   and rlonlr ge clon and $
                    rlatul ge clat   and rlonul le clon and $
                    rlatur ge clat   and rlonur le clon, count) 

    if ( count le 0 ) then print, 'out of NAAR Domain'
    iny = result(0)/nx
    inx = result(0)*1.0 - iny * nx

end 


