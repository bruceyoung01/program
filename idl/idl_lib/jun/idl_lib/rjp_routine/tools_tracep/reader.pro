n_no = where(qnames eq 'NO')
n_no2 = where(qnames eq 'NO2')
n_alt = where(qnames eq 'ALTP')

k = where(qdata(*, n_no) ge 0. and $
          qdata(*, n_no2) ge 0. and $
          qdata(*, n_alt) le 3.0)


!p.multi = [0, 2, 2, 0, 0]
test = ''
for i=0, n_elements(qnames)-1 do begin
plot,  qdata(k, n_no(0))+qdata(k, n_no2(0)), qdata(k, i), /xlog, $
   psym=1,  min=0,  title=qnames(i),  xstyle=1,  /ynozero, $
   xrange=[0.1, 1e4]

read, test
endfor

end
