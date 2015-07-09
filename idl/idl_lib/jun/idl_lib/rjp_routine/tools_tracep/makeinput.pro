type = 'dc8'

close,  /all



if (type eq 'dc8') then begin
   slist = ['NO', 'NO2', 'Ozone', 'PAN', $
            'Ethane', 'Propane', 'Carbon Monoxide mixing ratio', $
            'CH2O_fa', 'FORMALDEHYDE_hb', 'HYDROGEN PEROXIDE', $
            'METHYLHYDROPEROXIDE', 'HNO3', 'acetaldehyde_ap', $
           'acetone_ap', 'Acetone_sh', 'Acetaldehyde_sh' ]
   newlist = ['NO','NO2', 'O3', 'PAN', 'Ethane', 'Propane', 'CO', $
             'CH2O_fa', 'CH2O_hb', 'H2O2', 'MP', 'HNO3', 'ALD2_ap', $
             'ACET_ap', 'ACET_sh', 'ALD2_sh']
endif

if (type eq 'p3b') then begin
   slist = ['NO_10s_avg  (Mixing Ratio)', 'NO2 (Mixing Ratio)', 'NOy_10s_avg (Mixing Ratio)', 'Ozone', 'PAN mixing ratio', $
            'PPN mixing ratio', $
            'Ethane', 'Propane', 'Carbon Monoxide mixing ratio']
   newlist = ['NO','NO2', 'NOy', 'O3', 'PAN', 'PPN', 'Ethane', 'Propane', 'CO']
endif


   
geosnames = ['NOx', 'Ox', 'PAN', 'CO', 'ALK4', 'ISOP', $
             'HNO3', 'H2O2', 'ACET', $
             'MEK', 'ALD2', 'RCHO', 'MVK', 'MACR', 'PMN', $
             'PPN', 'R4N2', 'PRPE', $
             'C3H8', 'CH2O', 'C2H6', 'N2O5', 'HNO4', 'MP']

geosnames = 'geos_'+geosnames
months = [0, 31, 28, 31, 30, 31, 30]
ModelInfo = ctm_type('GEOS-3', resolution=4)
GridInfo = ctm_grid( ModelInfo ) 
map_set, 0, -180,  /continents
for i=1, n_elements(months)-1 do begin
   months(i) = months(i-1)+months(i)
endfor



; Loop round all the flights
if (type eq 'p3b') then begin
   starter = 4
   ender = 24
endif

if (type eq 'dc8') then begin
   starter = 4
   ender = 20
endif

for i=starter,ender do begin
  
   if (i le 9) then begin
      openw, 1, type+'_0'+string(i, format='(i1)')+'.dat'
   endif else begin
      openw, 1, type+'_'+string(i, format='(i2)')+'.dat'
   endelse
   printf, 1, 'lon lat alt', newlist, geosnames,  format='(50(a,x))'
   mean1 = fltarr(72, 46, 20, n_elements(slist))
   count = fltarr(72, 46, 20, n_elements(slist))


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
   readdata, file,DATA,names_void, delim=',',/autoskip, /noheader, cols=NV, $
      /quiet

  
; find day of flight   
   date = (data(0, *)+data(1, *)/(24*60*60.))   
   mini = min(date, mintime)
   idate = round(date(mintime))
   
   for ip=0, n_elements(months)-1 do begin
      if (idate ge months(ip)) then im = ip
   endfor
   
   id = idate-months(im)
   if (id eq 0) then begin
      im = im-1
      id = months(im+1)-months(im)
   endif

; correct for month 0 begin January  = month 1
   im = im+1
   if (id ge 10) then begin
      print,  '0'+string(im, format='(i1)')+string(id, format='(i2)'),  idate
      day = '0'+string(im, format='(i1)')+string(id, format='(i2)')
   endif else begin
      print,  '0'+string(im, format='(i1)')+'0'+$
         string(id, format='(i1)'),  idate
      day = '0'+string(im, format='(i1)')+'0'+$
         string(id, format='(i1)')
   endelse

   filename = '/scratch/mje/run_4.16/fields/gctm.trc.2001'+day
   CTM_GET_DATA, DataInfo,45,file=filename,  tracer=tracer

   geos = fltarr(72, 46, 48, 24)
   for ip=0, 23 do begin
      geos(*, *, *, ip) = *(datainfo(ip).data)
   endfor

  

   n_lat = where(names eq 'LATITUDE')
   n_lon = where(names eq 'LONGITUDE')
   if (type eq 'p3b') then begin
      n_alt = where(names eq 'PressureAlt')
   endif

   if (type eq 'dc8') then begin
      n_alt = where(names eq 'ALTP')
   endif
   for ip=0, n_elements(data(0, *))-1 do begin
     
      if (data(n_lon(0), ip) ge 180) then $
         data(n_lon(0), ip) = data(n_lon(0), ip) -360
      test = min(abs(data(n_lat(0), ip)-gridinfo.ymid), iy)
      test = min(abs(data(n_lon(0), ip)-gridinfo.xmid), ix)
      test = min(abs(data(n_alt(0), ip)-gridinfo.zmid), iz)
      plots,  gridinfo.xmid(ix),  gridinfo.ymid(iy),  psym=1
      for iq=0, n_elements(slist)-1 do begin
         k = where(slist(iq) eq names)
         if (data(k(0), ip) gt 0.) then begin
            mean1(ix, iy, iz, iq) = mean1(ix, iy, iz, iq)+data(k(0), ip)
            count(ix, iy, iz, iq) = count(ix, iy, iz, iq)+1
         endif
      endfor
   endfor
   
   for ix=0, 71 do begin
      for iy=0, 45 do begin
         for iz=0, 19 do begin
            for iq=0, n_elements(slist)-1 do begin
               if (count(ix, iy, iz, iq) gt 0) then begin 
                  mean1(ix, iy, iz, iq) = mean1 (ix, iy, iz, iq)/$
                     count(ix, iy, iz, iq)
               endif else begin
                  mean1(ix, iy, iz, iq) =  -999.990
               endelse
            endfor

            if (max(count(ix, iy, iz, *))  gt 0) then begin
               printf,1, $
                  gridinfo.xmid(ix), $
                  gridinfo.ymid(iy), $ 
                  gridinfo.zmid(iz), $
                  mean1(ix, iy, iz, *), $
                  geos(ix, iy, iz, *), format='(3(f8.2,x),40(e15.3,x))'
            endif

         endfor
      endfor
   endfor
   ctm_cleanup,  /data
   close,  1
endfor



close,  /all
end


