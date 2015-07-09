pro readinplane,  qtype,  qdate,  qdd, qmn, qhh, qmm, $
                qlat, qlon, qpres,  qdata,  qnames,  file, $
                  type

; OK Readin in the file
read_varstr, file, NV, names
readdata, file,data,names_void, delim=',',/autoskip, $
      /noheader, cols=NV, $
      /quiet
      
; Set up pointers to columns with data in 
n_lon = where(names eq 'LONGITUDE')
n_lat = where(names eq 'LATITUDE')
n_pres = where(names eq 'PRESSURE')
n_time = where(names eq 'UTC')
n_day = where(names eq 'JDAY')
n_flight = where(names eq 'FLIGHT')

;check data is sorted correctly. 
kday = data(n_day, *)+data(n_time(0), *)/(24*60.*60.)
k = sort(kday)
data = data(*, k)

;set up array to hold the new arrays
n = n_elements(data(0, *))
qtype = strarr(n)
qdate = fltarr(n)
qdd = intarr(n)
qmm = intarr(n)
qhh = intarr(n)
qmn = intarr(n)
qlat = fltarr(n)
qlon = fltarr(n)
qpres = fltarr(n)

; get flight number
fno = data(n_flight, *)
months = [0, 31, 28, 31, 30, 31, 30]


for iq=1, n_elements(months)-1 do begin
   months(iq) = months(iq-1)+months(iq)
endfor

; now loop over all the data points
for i=0, n-1 do begin

   jday = data(n_day, i)

   time = data(n_time, i)
   
   if (time(0) ge 24*60*60.) then begin
      print,  time
      jday = jday+1
      time = time-24*60*60.
      print,  time
   endif

   hours = time/(60*60.)
   hour = floor(hours)

   time = time-hour*60*60
   minutes = time/60.
   minute = floor(minutes)
   
   time = time-minute*60.
   seconds = time/60.
   second = round(time) 
 


   for ip=0, n_elements(months)-1 do begin
      if (jday(0) ge months(ip)) then im = ip
   endfor
   
   id = jday(0)-months(im)
   if (id eq 0) then begin
      im = im-1
      id = months(im+1)-months(im)
   endif
   
   im = im+1                    ;Jan=1 rather than 0
   print,  im, id
   if (id ge 32) then stop
   if (fno(i) le 9) then begin
      qtype(i) = type+'0'+string(fno(i), format='(i1)')
   endif else begin
      qtype(i) = type+string(fno(i), format='(i2)')
   endelse
 
   qdd(i) = id
   qmn(i) = im
   qhh(i) = hour
   qmm(i) = minute
   qdate(i) = data(n_day, i)+data(n_time(0), i)/(24*60.*60.)
   qlat(i) = data(n_lat(0), i)
   qlon(i) = data(n_lon(0), i)
   qpres(i) = data(n_pres(0), i)
 
endfor
qdata = transpose(data)
qnames = names
end



pro readinphobea,  wtype, wdate,  wdd,  wmn,  whh, wmm, $
   wlat, wlon,  wpres, wdata, wnames
   line = ''
   openr, 1, 'PHOBEA/PHOBEA2_Flight.dat'
   readf, 1, line
   array = fltarr(10)
   counter = 0
   while not eof(1) do begin
      readf, 1, array,  format='(i4,x,i3,x,i2,x,i2,x,i4,x,i2,x,i2,x,f7.2,x,f7.2,x,f7.2)'
      
   
      if (counter eq 0) then begin
         wtype = 'PHOBEA'
         wdate = array(1)+(array(5)+array(6)/60.)/24.
         wdd = array(2)
         wmn = array(3)
         whh = array(5)
         wmm = array(6)
         wlat = array(7)
         wlon = array(8)
         wpres = array(9)
         wdata = [0]
         wnames = 'Dum'
      endif else begin
         wtype = [wtype, 'PHOBEA']
         wdate = [wdate, array(1)+(array(5)+array(6)/60.)/24.]
         wdd =   [wdd, array(2)]
         wmn = [wmn, array(3)]
         whh = [whh, array(5)]
         wmm = [wmm, array(6)]
         wlat = [wlat, array(7)]
         wlon = [wlon, array(8)]
         wpres = [wpres, array(9)]
         wdata = [wdata, [0]]
      endelse
      counter = counter+1
   
   endwhile

   

   close,  1
end


if (n_elements(qtype) eq 0) then begin
   kd = 0
   kp =0
   readinplane,  qtype,  qdate,  qdd, qmn, qhh, qmm, $
      qlat, qlon, qpres,  qdata,  qnames, $
      'final-v4-mrg60d_all.trp', $
      'DC8'
   readinplane,  ptype,  pdate,  pdd, pmn, phh, pmm, $
      plat, plon, ppres,  pdata,  pnames, $
      'final-v2.2-mrg60p_all.trp', $
      'P3B'

n_flight = where(pnames eq 'FLIGHT')
n_time = where(pnames eq 'UTC')
n_day = where(pnames eq 'JDAY')
n_lat = where(pnames eq 'LATITUDE')
n_lon = where(pnames eq 'LONGITUDE')
n_alt = where(pnames eq 'PressureAlt')
np_co = where(pnames eq 'Carbon Monoxide mixing ratio')
np_no = where(pnames eq 'NO_10s_avg  (Mixing Ratio)')
np_no2 = where(pnames eq 'NO2 (Mixing Ratio)')
nd_co = where(qnames eq 'Carbon Monoxide mixing ratio')
nd_no = where(qnames eq 'NO')
nd_no2 = where(qnames eq 'NO2')
   for i=0, n_elements(qdata(*, 0))-1 do begin
      k = where(pdate(i) eq qdate)
      
      if (n_elements(k) gt 1) then stop
      if (k(0) ne -1) then begin
         kp = [kp, i]
         kd = [kd, k]
      endif
   endfor
endif

set_plot,  'ps'
device,  /landscape
device,  /color
loadct, 39
device,  /helvetica
!p.multi = [0, 2, 0, 0, 0]
n = where(((pdata(kp, n_lat(0))-qdata(kd, n_lat(0)))^2+$
          (pdata(kp, n_lon(0))-qdata(kd, n_lon(0)))^2) le 0.05 and $
          abs(pdata(kp, n_alt(0))-qdata(kd, n_alt(0)) le 0.100) and $
          pdata(kp, np_no(0)) ge 0. and $
          qdata(kd, nd_no(0)) ge 0.)

plot,  $
   qdata(kd(n), nd_no(0)),  pdata(kp(n), np_no(0)), psym=1, $
   xtitle='DC8 NO (pptv)',  ytitle='P3B NO (pptv)'

print,  mean(qdata(kd(n), nd_no(0))/pdata(kp(n), np_no(0)))
print,  correlate(qdata(kd(n), nd_no(0)), pdata(kp(n), np_no(0)))
plots,  qdata(kd(n), nd_no(0)),  pdata(kp(n), np_no(0)), psym=1, $
   color=pdata(kp(n), n_flight(0))*10
  x = qdata(kd(n), nd_no(0))
   y = pdata(kp(n), np_no(0))
   Org_Corr, X, Y, Grad, Cept, R,  Grad_Err, Cept_Err,  yfit

   oplot,  x, yfit,  thick=4,  linestyle=1

flight = [8, 16, 23]
for i=0, n_elements(flight)-1 do begin
   n = where(((pdata(kp, n_lat(0))-qdata(kd, n_lat(0)))^2+$
              (pdata(kp, n_lon(0))-qdata(kd, n_lon(0)))^2) le 0.05 and $
             abs(pdata(kp, n_alt(0))-qdata(kd, n_alt(0)) le 0.100) and $
             pdata(kp, np_no(0)) ge 0. and $
             qdata(kd, nd_no(0)) ge 0. and $
             pdata(kp, n_flight(0)) eq flight(i))
   plots,  qdata(kd(n), nd_no(0)),  pdata(kp(n), np_no(0)), psym=1, $
   color=pdata(kp(n), n_flight(0))*10
   x = qdata(kd(n), nd_no(0))
   y = pdata(kp(n), np_no(0))
   Org_Corr, X, Y, Grad, Cept, R,  Grad_Err, Cept_Err,  yfit

   oplot,  x, yfit,  linestyle=1
   print,  flight(i),mean(pdata(kp(n), n_lat(0))), mean(pdata(kp(n), n_lon(0))), grad,  cept,  $
      mean(qdata(kd(n), nd_no(0))/  pdata(kp(n), np_no(0))), $
      stddev(qdata(kd(n), nd_no(0))/  pdata(kp(n), np_no(0)))

endfor

oplot,  [0, 40], [0, 40],  thick=4

n = where(((pdata(kp, n_lat(0))-qdata(kd, n_lat(0)))^2+$
          (pdata(kp, n_lon(0))-qdata(kd, n_lon(0)))^2) le 0.05 and $
          abs(pdata(kp, n_alt(0))-qdata(kd, n_alt(0)) le 0.100) and $
          pdata(kp, np_no2(0)) ge 0. and $
          qdata(kd, nd_no2(0)) ge 0.)

plot,  $
   qdata(kd(n), nd_no2(0)),  pdata(kp(n), np_no2(0)), psym=1, $
   xtitle='DC8 NO!d2!n (pptv)',  ytitle='P3B NO!d2!n (pptv)'

print,  mean(qdata(kd(n), nd_no(0))/pdata(kp(n), np_no(0)))
print,  correlate(qdata(kd(n), nd_no(0)), pdata(kp(n), np_no(0)))
plots,  qdata(kd(n), nd_no2(0)),  pdata(kp(n), np_no2(0)), psym=1, $
   color=pdata(kp(n), n_flight(0))*10
x = qdata(kd(n), nd_no2(0))
y = pdata(kp(n), np_no2(0))
Org_Corr, X, Y, Grad, Cept, R,  Grad_Err, Cept_Err,  yfit

oplot,  x, yfit,  thick=4,  linestyle=1

flight = [8, 16]
for i=0, n_elements(flight)-1 do begin
   n = where(((pdata(kp, n_lat(0))-qdata(kd, n_lat(0)))^2+$
              (pdata(kp, n_lon(0))-qdata(kd, n_lon(0)))^2) le 0.05 and $
             abs(pdata(kp, n_alt(0))-qdata(kd, n_alt(0)) le 0.100) and $
             pdata(kp, np_no2(0)) ge 0. and $
             qdata(kd, nd_no2(0)) ge 0. and $
             pdata(kp, n_flight(0)) eq flight(i))
   plots,  qdata(kd(n), nd_no2(0)),  pdata(kp(n), np_no2(0)), psym=1, $
   color=pdata(kp(n), n_flight(0))*10
   x = qdata(kd(n), nd_no2(0))
   y = pdata(kp(n), np_no2(0))
   Org_Corr, X, Y, Grad, Cept, R,  Grad_Err, Cept_Err,  yfit

   oplot,  x, yfit,  linestyle=1
endfor
oplot,  [0, 100], [0, 100],  thick=4
device,  /close
end
