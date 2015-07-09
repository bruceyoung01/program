type = 'p3b'

close,  /all




openw, 2, 'dates'
for i=4, 24 do begin

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

;   if (i eq 4) then begin
;      alldata = rotate(data, 1)
;   endif else begin
;      alldata = [alldata, rotate(data, 1)]
;   endelse

   date = data(0, *)+data(1, *)/(24.*60.*60.)
   k = n_elements(date)-1
   printf,2,  i, round(date(0)), date(0),  date(k)
   plot,  date

endfor

close,  2
end



