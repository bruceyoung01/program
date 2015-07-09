  ; Math hourly data to npp
  
  ; read hourly data
  readcol, 'ATL_METAR/FORMATTED.txt', F = '(I4, I2, I2, F6.2, F8.2, F8.2, F8.2, F8.2, F8.2, F8.2, F8.2)', $
  YY, MM, DD, HH, Vis, RH, wind, windDIR, precip, pressure, $
  skipline=1, DELIMITER = ' '
 
  ; read NPP time
  readcol, '../Bruce_data/scatter_plot_data/data_w_background/130770002_1.txt', $
        yyp, mmp, ddp, hrp, lat, lon, vza, SatAZM, $
        moonphase, LZA, LAZM, PMA, PMB, F= 'A4, A2, A2, A2,  F, F, F, F, F, F, F, F, F', $
         skipline = 1 , DELIMITER = ','  

  ; loop through reach line to find all other mete fields durin gNPP overpass hours
   openw, 1, 'npp_overpass_mete.txt'
   printf, 1, 'YY  MM  DD  HH  VIs(mile)  RH (%)  Wind(MPH), WindDirectin(from Truth North), precip (inch/hr) pressure (inches in hudrens)'   

   for i = 0, n_elements(yyp)-1 do begin
     result = where (yy eq float( yyp(i)) and $
                     mm eq float(mmp(i)) and $
                     dd eq float(ddp(i)) and $
                     abs(hh - float(hrp(i))+4) le 1.0, count)

     tmpRH = -99.
     tmpVis = -99.
     tmpwind = -99.
     tmpwindDIR = -99.
     tmpprecip = -99.
     tmppressure = -99.

     if (count gt 0 ) then begin
     tmp = RH(result)
     tmpRH = mean(tmp(where (tmp gt 0)))     

     tmp = Vis(result)
     tmpVis = mean(tmp(where (tmp gt 0)))     

     tmp = Wind(result)
     result1 = where(tmp gt 0, count1)
     if count1 gt 0 then  tmpWind = mean(tmp(result1))     

     tmp = WindDIR(result)
     tmpWindDIR = mean(tmp(where (tmp ge 0)))     
    
     tmp = Precip(result)
     tmpprecip = mean(tmp(where (tmp ge 0)))    

     tmp = Pressure(result)
     tmppressure = mean(tmp(where (tmp gt 0)))    
     endif 
 
     printf, 1, yyp(i), mmp(i), ddp(i), hrp(i), tmpVis, tmpRH, $
                tmpwind, tmpwindDIR, tmpprecip, tmppressure, $
                Format = '(I5, 1x, I5, 1X, I5, 1X, I5, 1X, 6(F8.2, 1x))' 
    endfor                  
   close, 1

   END 
 
