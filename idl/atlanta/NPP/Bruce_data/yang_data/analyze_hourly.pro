
; read npp time 
readcol, '../scatter_plot_data/data_w_background/130770002_1.txt', $
        yyp, mmp, ddp, hrp, lat, lon, vza, SatAZM, $
        moonphase, LZA, LAZM, PMA, PMB, F= 'A4, A2, A2, A2,  F, F, F, F, F, F, F, F, F', $
         skipline = 1 , DELIMITER = ','

; read Yang's data in 2009
readcol, 'Hourly_average.txt', mm, dd, yy, hh, N, pm, std, maxpm, minpm, $
        skipline=1, DELIMITER = ' ', F = 'I, I, I, I, I, F, F, F, F'

  ; loop through reach line to find all other mete fields durin gNPP overpass hours
   openw, 1, 'Yang_1.txt'
   printf, 1, 'Year, month, day, hour, latitude, longitude, SatelliteZenithAngle,SatelliteAzimuthAngle, Moonphase, LunarZenithAngle, LunarAzimuthAngle,PM2.5A, PM2.5B'

   for i = 0, n_elements(yyp)-1 do begin
     result = where (yy eq float( yyp(i)) and $
                     mm eq float(mmp(i)) and $
                     dd eq float(ddp(i)) and $
                     hh eq float(hrp(i)+5 ) , count)
     tmppm = -99
     if (count gt 0 ) then begin
        tmppm = pm(result)
     endif

     printf, 1, yyp(i), ',', mmp(i), ',', ddp(i), ',', hrp(i), ',', $
             lat(i), ',', lon(i), ',',  vza(i), ',', SatAZM(i), ',', $
         moonphase(i), ',', LZA(i), ',', LAZM(i), ',', tmpPM, ',', tmpPM, $ 
		FORMAT= '( 4(A, A, 1X),   9(F8.2, A,  1X))'    
   endfor
   close, 1

end
  
