 function chk_sort, data

  dim = size(data)
  array = data

  if dim[0] eq 2 then begin
    ix = dim[1]
    iy = dim[2]
  end else if dim[0] eq 1 then begin
    ix = dim[1]
    iy = 1L
  end

  for d = 0, iy-1 do begin
     stor = reform(data[*,d])
     i = sort(stor)
     array[*,d] = stor[i]
  end

  fld = fltarr(ix)
  if dim[0] eq 2 then begin
     for d = 0, ix-1 do $
        fld[d] = mean(array[d,*],/NaN)
  end else if dim[0] eq 1 then begin
     fld = array
  end

  return, fld
 end
