 PRO format_hourly_data, iptfile

 ; first use Result = ASCII_TEMPLATE("ATL_12_2012.txt")
 ; to get template, and then one can save the template
 ; into xdr and start to use it.

 dir  = 'ATL_METAR/'
 restore, dir + 'hourlydata_template.xdr'
 data = read_ASCII(dir + iptfile, TEMPLATE=result, data_start=8)
 
 ; let's get output in a nice format
 ; openw, 1, dir + "FORMATTED.txt"
  yymmddflt = double (data.field02)
  yy = fix((yymmddflt/10000))
  mm = fix( (yymmddflt - yy * 10000D)/100)
  dd  =fix( yymmddflt - yy*10000D - mm*100)
  
  hhmm = double(data.field03)
  hh = fix(hhmm/100.) + (hhmm - 100*fix(hhmm/100.))/60.
  Vis = data.field07
  Visflg = data.field08
  RH = data.field23
  RHflg = data.field24
  wind = data.field25
  winddir = data.field27
  precip = data.field41
  pressure = data.field31
;  pretendy = data.field29 ; inches in hundreds in Hg.
  
  ; sea level pressure is at field 37 
  ; station pressure is at field 31 
  

  for i = 0, n_elements(hh)-1 do begin
  if (RH(i) lt 0) then RH(i) = -99
  if (Vis(i) lt 0) then Vis(i) = -99
  if (Wind(i) lt 0) then Wind(i) = -99
  if (Winddir(i) lt 0) then Winddir(i) = -99
  if (Precip(i) lt 0) then Precip(i) = 0
  if (pressure(i) lt 0) then Pressure(i) = 0 
  
  printf, 1, yy(i), mm(i), dd(i), hh(i), Vis(i), $
             RH(i), wind(i),winddir(i), precip(i), pressure(i), $ 
             format='(I4, 1X, I2, 1x, I2, 1X, F6.2, 1X, F8.2, 1x, F8.2, 1X, F8.2, 1x, F8.2, 1x, F8.2, 1x, F8.2)'
  endfor
 end   

 ;
 ; main program starts here
 ; 
 dir  = 'ATL_METAR/'
 openw, 1, dir + "FORMATTED.txt"
 iptfiles = [ 'ATL_08_2012.txt',  'ATL_09_2012.txt',  $
              'ATL_10_2012.txt',  'ATL_11_2012.txt', $
              'ATL_12_2012.txt', 'ATL_01_2013.txt']
 printf, 1, 'YY  MM  DD  HH  VIs(mile)  RH (%)  Wind(MPH), WindDirectin(from Truth North), precip (inch/hr) pressure (inches in hudrens' 
 for i = 0, n_elements(iptfiles)-1 do begin 
; for i = 0,  do begin 
 format_hourly_data, iptfiles(i)
 endfor
 close, 1
  
 end  
  
