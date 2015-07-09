function rdcmdl, file=file, imon=imon, time=time, lat=lat, lon=lon, imax = imax

if n_elements(file) eq 0 then return, 0
nfile = n_elements(file)

 station = ['ALT', 'ASC', 'BAL', 'BME', 'BMW', $
            'BRW', 'BSC', 'CBA', 'CGO', 'CHR', $
            'CMO', 'EIC', 'GMI', 'GOZ', 'HUN', $
            'ICE', 'ITN', 'IZO', 'KEY', 'KUM', $
            'LEF', 'MBC', 'MHD', 'MID', 'MLO', $
            'NWR', 'PSA', 'QPC', 'RPB', 'SEY', $
            'SHM', 'SMO', 'SPO', 'STM', 'SYO', $
            'TAP', 'TDF', 'UTA', 'UUM', 'ZEP' ]

 ylat = [82.27,  -7.55,  55.30,  32.22,  32.16, $
         71.19,  44.10,  55.12, -40.41,   1.42, $
         45.29, -29.09,  13.26,  36.03,  46.57, $
         63.15,  35.21,  28.18,  25.40,  19.31, $
         45.56,  76.15,  53.20,  28.13,  19.32, $
         40.03, -64.55,  36.16,  13.10, -04.40, $
         52.43, -14.15, -89.59,  66.00, -69.00, $
         36.44, -54.52,  39.54,  44.27,  78.54 ]

 xlon = [ -62.31,-14.25,   16.40, -64.39, -65.53, $
         -156.36, 28.41, -162.43, 144.41,-157.10, $
         -123.58,-109.26, 144.47,  14.11,  16.39, $
          -20.09, -77.23, -16.29, -80.12,-154.49, $
          -90.16,-119.21,  -9.54,-177.22,-155.35, $
         -105.35, -64.00, 100.55, -59.26,  55.10, $
          174.06,-170.34, -24.48,  02.00,  39.35, $
          126.08, -68.29,-113.43, 111.06,  11.53 ]

 std = ''
 dat1 = fltarr(1000,nfile) & dat2 = dat1
 lat = fltarr(nfile) & lon = lat
 imax = 0

for n = 0 , nfile-1 do begin
 openr,ilun,file(n), /get_lun
 i = 0

 while (not eof(ilun)) do begin
  readf, ilun, std, year, mon, dat, format='(a3,1x,f4,f3,f9)'

 case n_elements(imon) of
  0 : begin
   dat1(i,n) = year
   dat2(i,n) = dat
   i = i + 1
   end
  else : begin
  if mon eq imon then begin
   dat1(i,n) = year
   dat2(i,n) = dat
   i = i+1
  endif
  end

 endcase

 end

  if i ge imax then imax = i

 for j = 0, 39 do begin
  if std eq station(j) then begin
    lat(n) = ylat(j)
    lon(n) = xlon(j)
  endif 
 end

 free_lun, ilun
end

 co = fltarr(imax,nfile) & time = co
 time = dat1(0:imax-1,*) & co = dat2(0:imax-1,*)

return, co
end
 
