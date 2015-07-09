 function composite, data, first=first

 ; input data is a 2-d array
 ; we composite 2d data with 2nd rank as composited dimension 
 ; unless first is on

 ; sort out missing data
 p   = where(data lt 0.)
 if p[0] ne -1 then data[p] = 'NaN'

 ndim=size(data)

 if ndim[0] eq 1 then return, {mean:data, std:Replicate(0.,n_elements(data))}

 if keyword_set(first) then begin

    avg = fltarr(ndim[1]) 
    std = avg

    for d = 0, ndim[1]-1 do begin
       result = stat(reform(data[d,*]))
       avg[d] = result.mean
       std[d] = result.std
    end

 end else begin

    avg = fltarr(ndim[2])  
    std  = avg
    for d = 0, ndim[2]-1 do begin
       avg[d] = mean(data[*,d],/NaN)
       std[d] = stddev(data[*,d],/NaN) 
    end

 end

 return, {mean:avg,std:std}

 end
