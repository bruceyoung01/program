;                   A           B           C            D           E
;              N. Atlanta    SW            SE           CTR         CTR      
 FileNames = ['131350002', '130770002', '131510002', '131210055', '130890002']
 siteid =    ['A', 'B', 'C', 'D', 'E', 'CTR' ]
 dir = './data_w_background/'


    PM = fltarr(182) 
    Count = fltarr(182)
 
 for i = 0, 4 do begin
;  for i = 4, 4 do begin
    readcol, dir + filenames(i) + '_1.txt', yy, mm, dd, hr, lat, lon, vza, SatAZM, $
         moonphase, LZA, LAZM, PMA, PMB, PMC, PMD, F= 'A4, A2, A2, A2,  F, F, F, F, F, F, F, F, F, F, F', $
         skipline = 1, DELIMITER = ','
    
    result = where (PMA gt 0, count1)
    if count1 gt 0 then begin
      PM(result) = PMA(result) + PM(result)
      Count(result) = Count(result)+1
    endif

    result = where (PMB gt 0, count2)
    if count2 gt 0 then begin
      PM(result) = PMB(result) + PM(result)
      Count(result) = Count(result)+1
    endif
    
    result = where (PMC gt 0, count3)
    if count3 gt 0 then begin
      PM(result) = PMC(result) + PM(result)
      Count(result) = Count(result)+1
    endif

    result = where (PMD gt 0, count4)
    if count4 gt 0 then begin
      PM(result) = PMD(result) + PM(result)
      Count(result) = Count(result)+1
    endif

   endfor

; write output
  openw, 1, 'CTR_1.txt'
  printf, 1, 'Year, month, day, hour, latitude, longitude, SatelliteZenithAngle,SatelliteAzimuthAngle, Moonphase, LunarZenithAngle, LunarAzimuthAngle,PM2.5A, PM2.5B PM2.5C PM25D'

  for i = 0, n_elements(PM)-1 do begin
  if ( Count(i) gt 0) then PM(i) = PM(i)*1.0/Count(i)
  if (Count(i) le 0 ) then PM(i) = -999. 
  printf, 1, yy(i), ',', mm(i), ',', dd(i), ',', hr(i), ',', $
             lat(i), ',', lon(i), ',',  vza(i), ',', SatAZM(i), ',', $
         moonphase(i), ',', LZA(i), ',', LAZM(i), ',', PM(i), ',', PM(i), ',',  PM(i), ',',  PM(i), $
         FORMAT= '( 4(A, A, 1X),   11(F8.2,A, 1X))'
  endfor
  close, 1 

 end  

