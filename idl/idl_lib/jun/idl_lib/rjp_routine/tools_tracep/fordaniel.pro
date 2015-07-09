type = 'dc8'

close,  /all





for i=4, 20 do begin

   ; read in the measurements
   if i le 9 then begin
      file = '/data/tracep/merge_sept_2001/'+type+$
         '/1min/prelim-mrg60'+strmid(type,0,1)+'0'+$
         string(i, format='(i1)')+'.trp'
   endif else begin
      file = '/data/tracep/merge_sept_2001/'+type+$
         '/1min/prelim-mrg60'+strmid(type,0,1)+$
         string(i, format='(i2)')+'.trp'
   endelse
   
   read_varstr, file, NV, names
   readdata, file,DATA,names_void, delim=',',/autoskip, cols=NV,  /noheader

   if (i eq 4) then begin
      alldata = rotate(data, 1)
   endif else begin
      alldata = [alldata, rotate(data, 1)]
   endelse
   
endfor

n_no =  where(names eq 'NO')

end



