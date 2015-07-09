type = 'dc8' ;'dc8'/'p3b'


if (type eq 'p3b') then begin
   starter = 4
   ender =  24
   maxalt = 8
endif

if (type eq 'dc8') then begin
   starter = 4
   ender = 20
   maxalt = 12
endif

for i=starter, ender do begin
   if (i le 9) then begin
      file = type+'_0'+string(i, format='(i1)')+'.dat'
   endif else begin
      file = type+'_'+string(i, format='(i2)')+'.dat'
   endelse
   print,  file
  
   openr, 1, file
   line = ''
   readf, 1, line
   names = strsplit(line, ' ', /extract)
   if (i eq 4) then begin
      data = fltarr(10000, n_elements(names))
      counter = 0
   endif
   while not eof(1) do begin
      readf, 1, line
      xline = float(strsplit(line, ' ', /extract))
      data(counter, *) = xline
      counter = counter+1
   endwhile
   close, 1
endfor
data = data(0:(counter-1), *)
!p.multi = [0, 0, 0, 0, 0]
mnames = ['CO', 'O3', 'Ethane', 'Propane', 'PAN']
gnames = ['geos_CO', 'geos_Ox', 'geos_C2H6', 'geos_C3H8', 'geos_PAN']
gcorr = [1e9, 1e9, 0.5e12, 0.333e12, 1e12]

for ip=0, n_elements(mnames)-1 do begin
;for ip=0, 0 do begin
   n_lon = where(names eq 'lon')
   n_alt = where(names eq 'alt')
   m_o3 = where(names eq mnames(ip))
   g_o3 = where(names eq gnames(ip))
   
   k = where(data(*, g_o3) ge 1e-5)
   data(k, g_o3(0)) = data(k, g_o3(0))/1e9
   lons = fltarr(72, 13)
   clons = fltarr(72, 13)
   for i=0, n_elements(data(*, 0))-1 do begin
      if (data(i, n_lon(0)) le 0.) then begin
         n_l = (data(i, n_lon(0))+360)/5.
      endif else begin
         n_l = (data(i, n_lon(0)))/5.
      endelse
      
      n_a = round(data(i, n_alt(0)))
      if(data(i, m_o3(0)) ge 0.) then begin
         lons(n_l, n_a) = lons(n_l, n_a)+$
            (data(i, m_o3(0))/(data(i, g_o3(0))*gcorr(ip)))
         clons(n_l, n_a) = clons(n_l, n_a)+1.
      endif
   endfor
   x = 0
   y = 0
   v = 0
   for i=0, 71 do begin
      for j=0, 12 do begin
         if (clons(i, j) ne 0) then begin
            lons(i, j) = lons(i, j)/clons(i, j)
            x = [x, i]
            y = [y, j]
            v = [v, lons(i, j)]
         endif
      endfor
   endfor
   x = x(1:*)
   y = y(1:*)
   v = v(1:*)
   contour, v,x*5,y, /irregular, nlevels=30, /fill, $
      levels=indgen(30)*0.06666,  title=mnames(ip)+' Measured/modeled'
   contour, v,x*5,y, /irregular, nlevels=10, /follow, $
      /overplot, levels=indgen(10)*0.2
   contour,  v, x*5, y,  /irregular,  nlevels=1,  levels=[1],  /follow,  /overplot,  c_thick=4

   plots,  x*5, y,  psym=1
endfor
device,  /close
end

