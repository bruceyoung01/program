pro readin, type, flightno, alldata, names,astalk,  addendums

for i=flightno, flightno do begin
  
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
   readdata, file,DATA,names_void, delim=',',/autoskip, /noheader, cols=NV, $
      /quiet
   if (addendums(0) ne '') then begin
   for j=0, n_elements(addendums)-1 do begin
      if i le 9 then begin
         file = astalk+addendums(j)+'-mrg60'+strmid(type, 0, 1)+'0'+$
            string(i, format='(i1)')+'.trp'
      endif else begin
          file = astalk+addendums(j)+'-mrg60'+strmid(type, 0, 1)+$
             string(i, format='(i2)')+'.trp'
      endelse
      
      read_varstr, file, NV, names2
      readdata, file,DATA2,names_void, delim=',',/autoskip, $
         /noheader, cols=NV, $
         /quiet
      
;     OK loop through the new names looking for overlap
      for ip=0, n_elements(names2)-1 do begin
         ni = where(names2(ip) eq names)
;     If we have over lap then copy in the new fields
         if (ni(0) ne -1) then begin
            data(ni, *) = data2(ip, *)
         endif else begin
            names = [names, names2(ip)]
            data = [data, data2(ip, *)]
         endelse
      endfor
      
   endfor
   endif
   
   alldata = rotate(data, 1)
endfor
end

pro readindc8,  qtype,  qdate,  qdd, qmn, qhh, qmm, $
                qlat, qlon, qpres,  qdata,  qnames
type = 'dc8'

ds = 4
de = 20
for flightno=ds, de do begin
   print,  flightno
   readin, type, flightno, alldata, names, $
      '/scratch/mje/1hour/addenda/', ['prelim_add', 'prelim_add_2']

   if (flightno eq ds) then begin
      data = alldata
      fno = fltarr(n_elements(alldata(*, 0)))+flightno
   endif else begin
      data = [data, alldata]
      fnot = fltarr(n_elements(alldata(*, 0)))+flightno
      fno = [fno, fnot]
   endelse
   
endfor
n_lon = where(names eq 'LONGITUDE')
n_lat = where(names eq 'LATITUDE')
n_pres = where(names eq 'PRESSURE')
n_time = where(names eq 'UTC')
n_day = where(names eq 'JDAY')
kday = data(*, n_day)+data(*, n_time(0))/(24*60.*60.)
   k = sort(kday)
   data = data(k, *)
qtype = strarr(n_elements(data(*, 0)))
qdate = fltarr(n_elements(data(*, 0)))
qdd = intarr(n_elements(data(*, 0)))
qmm = intarr(n_elements(data(*, 0)))
qhh = intarr(n_elements(data(*, 0)))
qmn = intarr(n_elements(data(*, 0)))
qlat = fltarr(n_elements(data(*, 0)))
qlon = fltarr(n_elements(data(*, 0)))
qpres = fltarr(n_elements(data(*, 0)))
for i=0, n_elements(data(*, 0))-1 do begin
;   print,  i, data(i, n_lon(0)),  data(i, n_lat(0)),$
;      data(i, n_pres(0))
   jday = data(i, n_day)+data(i, n_time(0))/(24*60.*60.)
   
   time = (jday mod 1)*24.
   jday = jday-(jday mod 1)
   dminute = (time mod 1)
   hour = time-dminute
   minute = dminute*60
; find the month and day

   months = [0, 31, 28, 31, 30, 31, 30]
   for iq=1, n_elements(months)-1 do begin
      months(iq) = months(iq-1)+months(iq)
   endfor

   for ip=0, n_elements(months)-1 do begin
      if (jday(0) ge months(ip)) then im = ip
   endfor
      
   id = jday(0)-months(im)
   if (id eq 0) then begin
      im = im-1
      id = months(im+1)-months(im)
   endif
   
   im = im+1                    ;Jan=1 rather than 0
   if (fno(i) le 9) then begin
      qtype(i) = 'DC80'+string(fno(i), format='(i1)')
   endif else begin
      qtype(i) = 'DC8'+string(fno(i), format='(i2)')
   endelse
   
   qdd(i) = id
   qmn(i) = im
   qhh(i) = hour
   qmm(i) = minute
   qdate(i) = data(i, n_day)+data(i, n_time(0))/(24*60.*60.)
   qlat(i) = data(i, n_lat(0))
   qlon(i) = data(i, n_lon(0))
   qpres(i) = data(i, n_pres(0))
endfor
qdata = data
qnames = names
end

pro readinp3b,  qtype,  qdate,  qdd, qmn, qhh, qmm, $
                qlat, qlon, qpres,  qdata,  qnames
type = 'p3b'

ds = 4
de = 24
for flightno=ds, de do begin
   print,  flightno
   readin, type, flightno, alldata, names, $
      '/scratch/mje/1hour/addenda/', ['prelim_add']

   if (flightno eq ds) then begin
      data = alldata
      fno = fltarr(n_elements(alldata(*, 0)))+flightno
   endif else begin
      data = [data, alldata]
      fnot = fltarr(n_elements(alldata(*, 0)))+flightno
      fno = [fno, fnot]
   endelse
endfor
n_lon = where(names eq 'LONGITUDE')
n_lat = where(names eq 'LATITUDE')
n_pres = where(names eq 'PRESSURE')
n_time = where(names eq 'UTC')
n_day = where(names eq 'JDAY')
kday = data(*, n_day)+data(*, n_time(0))/(24*60.*60.)
   k = sort(kday)
   data = data(k, *)
qtype = strarr(n_elements(data(*, 0)))
qdate = fltarr(n_elements(data(*, 0)))
qdd = intarr(n_elements(data(*, 0)))
qmm = intarr(n_elements(data(*, 0)))
qhh = intarr(n_elements(data(*, 0)))
qmn = intarr(n_elements(data(*, 0)))
qlat = fltarr(n_elements(data(*, 0)))
qlon = fltarr(n_elements(data(*, 0)))
qpres = fltarr(n_elements(data(*, 0)))
for i=0, n_elements(data(*, 0))-1 do begin
;   print,  i, data(i, n_lon(0)),  data(i, n_lat(0)),$
;      data(i, n_pres(0))
   jday = data(i, n_day)+data(i, n_time(0))/(24*60.*60.)
   
   time = (jday mod 1)*24.
   jday = jday-(jday mod 1)
   dminute = (time mod 1)
   hour = time-dminute
   minute = dminute*60
; find the month and day

   months = [0, 31, 28, 31, 30, 31, 30]
   for iq=1, n_elements(months)-1 do begin
      months(iq) = months(iq-1)+months(iq)
   endfor

   for ip=0, n_elements(months)-1 do begin
      if (jday(0) ge months(ip)) then im = ip
   endfor
      
   id = jday(0)-months(im)
   if (id eq 0) then begin
      im = im-1
      id = months(im+1)-months(im)
   endif
   
   im = im+1                    ;Jan=1 rather than 0

   if (fno(i) le 9) then begin
      qtype(i) = 'P3B0'+string(fno(i), format='(i1)')
   endif else begin
      qtype(i) = 'P3B'+string(fno(i), format='(i2)')
   endelse
   qdd(i) = id
   qmn(i) = im
   qhh(i) = hour
   qmm(i) = minute
   qdate(i) = data(i, n_day)+data(i, n_time(0))/(24*60.*60.)
   qlat(i) = data(i, n_lat(0))
   qlon(i) = data(i, n_lon(0))
   qpres(i) = data(i, n_pres(0))
   
endfor
qdata = data
qnames = names
end

readindc8,  qtype,  qdate,  qdd, qmn, qhh, qmm, $
   qlat, qlon, qpres,  qdata,  qnames



end
