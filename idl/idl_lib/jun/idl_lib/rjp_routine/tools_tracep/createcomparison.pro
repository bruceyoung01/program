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

readinplane,  qtype,  qdate,  qdd, qmn, qhh, qmm, $
   qlat, qlon, qpres,  qdata,  qnames, $
   'final-v4-mrg60d_all.trp', $
   'DC8'
readinplane,  ptype,  pdate,  pdd, pmn, phh, pmm, $
   plat, plon, ppres,  pdata,  pnames, $
   'final-v2.2-mrg60p_all.trp', $
  'P3B'
;readinphobea, wtype, wdate,  wdd,  wmn,  whh, wmm, $
;   wlat, wlon,  wpres, wdata, wnames

type = [qtype, ptype];,  wtype]
date = [qdate, pdate];, wdate]
dd = [qdd, pdd];, wdd]
mn = [qmn, pmn];, wmn]
hh = [qhh, phh];, whh]
mm = [qmm, pmm];, wmm]
lat = [qlat, plat];, wlat]
lon = [qlon, plon];, wlon]
pres = [qpres, ppres];, wpres]

k = sort(date)

type = type(k)
date = date(k)
dd = dd(k)
mn = mn(k)
hh = hh(k)
mm = mm(k)
lat = lat(k)
lon = lon(k)
pres = pres(k)


; Now lets find those things that we want in common
names_dc8 = ['ALTP', $
             'TEMPERATURE', $
             'H2O_MixingRatio', $
             'DLH_H2O_Mix_rat_sg', $
             'JDAY', $
             'UTC', $
             'Ozone', $
             'Carbon Monoxide mixing ratio', $
             'NO', $
             'NO2', $
             'NOy_10s_avg (Mixing Ratio)', $
             'OH', $
             'HO2', $
             'HO2+RO2', $
             'CH2O_fa', $
             'HYDROGEN PEROXIDE', $
             'METHYLHYDROPEROXIDE', $
             'Ethane_uci', $
             'Propane_uci', $
             'Propene_uci', $
             'trans-2-Butene_uci', $
             'i-Butane_uci', $
             'n-Butane_uci', $
             'n-Pentane_uci', $
             'i-Pentane_uci', $
             'n-Hexane_uci', $
             'Ethene_uci', $
             'Ethyne_uci', $
             'Benzene_uci', $
             'acetaldehyde_ap', $
             'acetone_ap', $
             'methyl ethyl ketone_ap', $
             'Acetaldehyde_sh', $
             'Propanaldehyde', $
             'Methyl Ethyl Ketone_sh', $
             'Acetone_sh',  $
             'PAN',  $
             'PPN', $
             'MPAN', $
             'HNO3', $
             'Nitrate', $
             'J[O3->O2+O(1D)]', $
             'J[NO2->NO+O(3P)]', $
             'J[H2O2->2OH]', $
             'J[CH2O->H+HCO]', $
             'J[CH2O->H2+CO]', $
             'J[CH3OOH->CH3O+OH]', $
             'J[CH3COCH3]',$
             'SZA', $
             'Surface_dry_.1-.75', $
             'Surface_.75-2', $
             'Surface_2-5', $
             'Surface_5-20', $
             'Surface_20-50', $
             'Surface_50-1550', $
             '2-BuONO2_uci', $
             '2-PeONO2_uci', $
             '3-PeONO2_uci', $
             'n-PrONO2_uci', $
             'i-PrONO2_uci', $
             'O3COLUMN', $
             'C2Cl4_uci', $
             'HCN', $
             'Chloride']
   
names_p3b = ['PressureAlt', $
             'TEMPERATURE', $
             'H2O_MixingRatio', $
             'DLH_H2O_Mix_rat_sg', $
             'JDAY', $
             'UTC', $
             'Ozone', $
             'Carbon Monoxide mixing ratio', $
             'NO_10s_avg  (Mixing Ratio)', $
             'NO2 (Mixing Ratio)', $
             'NOy_10s_avg (Mixing Ratio)', $
             '[OH]', $
             'HO2', $
             'RO2+HO2', $
             'CH2O', $
             'H2O2', $
             'MP', $
             'Ethane_uci', $
             'Propane_uci', $
             'Propene_uci', $
             'trans-2-Butene_uci', $
             'i-Butane_uci', $
             'n-Butane_uci', $
             'n-Pentane_uci', $
             'i-Pentane_uci', $
             'n-Hexane_uci', $
             'Ethene_uci', $
             'Ethyne_uci', $
             'Benzene_uci', $
             'acetaldehyde_ap', $
             'acetone_ap', $
             'methyl ethyl ketone_ap', $
             'Acetaldehyde_sh', $
             'Methyl Ethyl Ketone_sh', $
             'Acetone_sh', $
             'Propanaldehyde', $
             'PAN mixing ratio', $
             'PPN mixing ratio', $
             'MPAN mixing ratio', $
             'HNO3', $
             'NO3', $
             'J[O3->O2+O(1D)]', $
             'J[NO2->NO+O(3P)]', $
             'J[H2O2->2OH]', $
             'J[CH2O->H+HCO]', $
             'J[CH2O->H2+CO]', $
             'J[CH3OOH->CH3O+OH]', $
             'J[CH3COCH3]',$
             'SZA', $
             'Surface_dry_.1-.75', $
             'Surface_.75-2', $
             'Surface_2-5', $
             'Surface_5-20', $      
             'Surface_20-50', $
             'Surface_50-1550', $
             '2-BuONO2_uci', $
             '2-PeONO2_uci', $
             '3-PeONO2_uci', $
             'n-PrONO2_uci', $
             'i-PrONO2_uci', $
             'O3COLUMN', $
             'C2Cl4_uci', $
             'HCN', $
             'Cl']
names_real = ['Altitude', $
              'Temp', $
              'H2O', $
              'H2O_2', $
              'JDAY', $
              'UTC', $
              'O3', $
              'CO', $
              'NO', $
              'NO2', $
              'NOy', $
              'OH', $
              'HO2', $
              'HO2+RO2', $ 
              'CH2O', $
              'H2O2', $
              'MP', $
              'Ethane', $
              'Propane', $
              'Propene', $
              't-2-Butene', $
              'i-Butane', $
              'n-Butane', $
              'n-Pentane', $
              'i-Pentane', $
              'n-Hexane', $
              'Ethene', $
              'Ethyne', $
              'Benzene', $
              'CH3CHO_ap', $
              '(CH3)2CO_ap', $
              '(CH3)(C2H5)CO_ap', $
              'CH3CHO_sh', $
              'Propanaldehyde', $
              '(CH3)(C2H5)CO_sh', $
              '(CH3)2CO_sh', $
              'PAN', $
              'PPN', $
              'MPAN', $
              'HNO3', $
              'Nitrate', $
              'J(O1D)', $
              'J(NO2)', $
              'J(H2O2)', $
              'J(CH2Oa)', $
              'J(CH2Ob)', $
              'J(CH3OOH)', $
              'J(CH3COCH3)',$
              'SZA', $
             'Surface_dry_.1-.75', $
             'Surface_.75-2', $
             'Surface_2-5', $
             'Surface_5-20', $
             'Surface_20-50', $
             'Surface_50-1550', $
             '2-BuONO2_uci', $
             '2-PeONO2_uci', $
             '3-PeONO2_uci', $
             'n-PrONO2_uci', $
             'i-PrONO2_uci', $
             'O3COLUMN', $
             'PCE', $
             'HCN', $
             'Cl']



if (n_elements(names_dc8) ne n_elements(names_p3b) or $
    n_elements(names_real) ne n_elements(names_p3b)) then stop

cdata = fltarr(n_elements(names_dc8), n_elements(type))

for i=0, n_elements(names_dc8)-1 do begin
   nq = where(names_dc8(i) eq qnames)
   np = where(names_p3b(i) eq pnames)
   nw = -1
   if (nq(0) ne -1) then begin
      qnew = qdata(*, nq)
   endif else begin
      qnew = qdata(*, 0)*0.-999.990
      print,  'Not found',  names_dc8(i),  'in DC8'
   endelse
   
   if (np(0) ne -1) then begin
      pnew = pdata(*, np)
   endif else begin
      pnew = pdata(*, 0)*0.-999.990
      print,  'Not found',  names_p3b(i),  'in P3B'
   endelse
   
;   if (nw(0) ne -1) then begin
;      wnew = wdata(*, nw)
;   endif else begin
;      wnew = wdata(*, 0)*0.-999.990
;   endelse

   new = [qnew, pnew];, wnew]
   cdata(i, *) = new
   
endfor

ctime = [qdate, pdate];, wdate]
k = sort(ctime)
cdata = cdata(*, k)
openw, 1, 'Conc.dat'
printf, 1, 'Point', 'Type', 'YYYY-MM-DD', 'HH:MM', 'LAT', 'LON', 'PRESS', $
   names_real, format='(a5,x,a5,x,a10,x,a5,x,a7,x,a7,x,a7,x,100(a20,x))'
for i=0, n_elements(k)-1 do begin
   if (dd(i) le 9) then begin
      sdd = '0'+string(dd(i), format='(i1)')
   endif else begin
      sdd = string(dd(i), format='(i2)')
   endelse

   if (mm(i) le 9) then begin
      smm = '0'+string(mm(i), format='(i1)')
   endif else begin
      smm = string(mm(i), format='(i2)')
   endelse
   
   if (mn(i) le 9) then begin
      smn = '0'+string(mn(i), format='(i1)')
   endif else begin
      smn = string(mn(i), format='(i2)')
   endelse

   if (hh(i) le 9) then begin
      shh = '0'+string(hh(i), format='(i1)')
   endif else begin
      shh = string(hh(i), format='(i2)')
   endelse
   
   printf, 1, i+1, type(i), 2001, smn, sdd, shh, smm, $
      lat(i), lon(i), pres(i), cdata(*, i), $
      format='(i5,x,a5,x,i4,a2,a2,x,a2,a2,x,3(f7.2,x),100(e20.5,x))'
endfor
close, 1
;list of variables wanted output from model
mlist = ['O3', $
         'NO2', 'NO', 'NO3', 'N2O5', 'HNO4', $
         'HNO3', 'HNO2', $
         'PAN', 'PPN', 'PMN', 'R4N2', $
         'H2O2', 'MP', 'CH2O', $
         'HO2', 'OH', 'RO2', $
         'CO', 'C2H6', 'C3H8', 'PRPE', 'ALK4', $
         'ACET', 'ALD2', 'MEK', 'RCHO', $
         'REA_O1D', 'REA_295', $
         'DAO_TEMP', 'DAO_ABSH', 'DAO_TOMS', 'DAO_SURF', 'END']
         

openw, 1, 'Planeflight.dat'
printf, 1, 'Header for the flight'
printf, 1, 'Gives information'
printf, 1, 'Not too much'
printf, 1, '--------------------------------'
printf, 1, n_elements(mlist),' !Number of variables to be output', $
   format='(i3,a36)'
printf, 1,'--------------------------------'
for i=0, n_elements(mlist)-1 do begin
   printf, 1, mlist(i)
endfor
printf, 1, '-------------------------------------------------'
printf, 1,'Now give the times and locations of the flight'
printf, 1,'-------------------------------------------------'

 printf, 1, 'Point', 'Type', 'DD-MM-YYYY', 'HH:MM', 'LAT', 'LON', 'PRESS', $
      format='(a5,x,a5,x,a10,x,a5,x,a7,x,a7,x,a7)'
for i=0, n_elements(k)-1 do begin
   printf,1,  i+1, type(i), dd(i), mn(i), 2001, hh(i), mm(i), $
      lat(i), lon(i), pres(i), $
      format='(i5,x,a5,x,i2,"-",i2,"-",i4,x,i2,":",i2,x,f7.2,x,f7.2,x,f7.2)'
endfor
printf, 1, '99999', 'END', 0, 0, 0, 0, 0, 0., 0., 0., $
      format='(i5,x,a5,x,i2,"-",i2,"-",i4,x,i2,":",i2,x,f7.2,x,f7.2,x,f7.2)'
close,  1
end
