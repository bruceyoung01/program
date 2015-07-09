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
      print,  'greater'
      jday = jday+1
      time = time-24*60*60.
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

type = 'DC8'
if (n_elements(qtype) eq 0) then begin
   readinplane,  qtype,  qdate,  qdd, qmn, qhh, qmm, $
      qlat, qlon, qpres,  qdata,  qnames,  $
      '/data/tracep/merge_final_v2/DC8_LARC/1_MINUTE/final-v2-mrg60d_all.trp', $
      'DC8'
endif
n_co =  where(qnames eq 'Carbon Monoxide mixing ratio')
n_lat =  where(qnames eq 'LATITUDE')
n_lon =  where(qnames eq 'LONGITUDE')
n_alt =  where(qnames eq 'ALTP')

co = qdata(*, n_co)
lat = qdata(*, n_lat)
lon = qdata(*, n_lon)
alt = qdata(*, n_alt)

defineGrid = CTM_Type( 'GEOS3_30L', Res=2 )
grid   = CTM_Grid( DefineGrid)
goto,  skip
gridco = fltarr(grid.imx, grid.jmx, 22, 6)
for i=0, grid.imx-1 do begin
   print,  i
   for j=(grid.jmx-1)/2., grid.jmx-1 do begin
      for k=0, 21 do begin
         kl = where(lat ge grid.yedge(j) and lat le grid.yedge(j+1) and $
                   lon ge grid.xedge(i) and lon le grid.xedge(i+1) and $
                   alt ge grid.zedge(k) and alt le grid.zedge(k+1) and $
                   co ge 0.)

         if (kl(0) ne -1) then begin
            gridco(i, j, k, 0) = mean(co(kl))
            gridco(i, j, k, 1) = median(co(kl))
            if (n_elements(kl) ge 3) then begin
               gridco(i, j, k, 2) = stddev(co(kl))
            endif else begin
               gridco(i, j, k, 2) = -1
            endelse
            gridco(i, j, k, 3) = max(co(kl))
            gridco(i, j, k, 4) = min(co(kl))
            gridco(i, j, k, 5) = n_elements(kl)
         endif
      endfor
   endfor
endfor
skip:
openw, 1, 'Mean_co'
printf, 1, 'i', 'j', 'l', 'lon', 'lat', 'alt', 'mean', 'median', 'stddev', 'max', 'min', '#',format='(3(a3,x),9(a6,x))'
for i=0, grid.imx-1 do begin
   for j=0, grid.jmx-1 do begin
      for k=0, 21 do begin
         if (gridco(i, j, k) ne 0) then begin
            printf,1,  i, j, k, grid.xmid(i),  grid.ymid(j), grid.zmid(k), gridco(i, j, k, *), format='(3(i3,x),9(f6.2,x))'
         endif
      endfor
   endfor
endfor
print,  total(co(*, *, *, 5)
close,  1
end
