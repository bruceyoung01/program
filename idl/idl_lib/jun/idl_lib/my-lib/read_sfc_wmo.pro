;
; Procedure to read MODIS surface temperature
;

;
; input: dir, staid, year, all in string type
;
;
; output: all the varialbes in the datasets 
;

  PRO read_sfc_wmo, dir = dir, staid = staid, year = year, $
                ln = ln, $
                stn =stn,  wban = wban,  yr = yr, $
                mon = mon,   day= day,  sfct= sfct, $
                tempcount = tempcount,   dewp= dewp, $
                dtcount= dtcount,   slp= slp,  slpcount= slpcount, $
                stp= stp,  stpcount= stpcount,  vis= vis,  viscount= viscount, $
                wdsp= wdsp,  wdspcount= wdspcount,  mxspd = mxspd,  gust = gust, $
                maxt = maxt,  maxtflg = maxtflg,  mint = mint,  mintflg = mintflg, $
                prcp = prcp,   fprcp = prcpflg,  sndp = sndp, fog = fog, $
                rain = rain, snow = snow, hail = hail, thunder = thunder, $
                Tornado = tornado, RH = RH       
          
  file = dir + staid + '-99999-' + year + '.op'
  nouse = ' '
  mintflg1 = ' '
  prcpflg1 = ' ' 
  maxtflg1 = ' '
  i = 0
  maxL = 400
  const = 2.5*10.^6/461.5   ; latent heat vs. gas constant 
  stn = fltarr(maxL)
  wban = fltarr(maxL)
  yr = fltarr(maxL)
  mon = fltarr(MaxL)
  day = fltarr(MaxL)
  temp = fltarr(MaxL)
  tempcount = fltarr(MaxL)
  dewp = fltarr(MaxL)
  dtcount = fltarr(MaxL)
  slp= fltarr(MaxL)
  slpcount= fltarr(MaxL)
  stp= fltarr(MaxL)
  stpcount= fltarr(MaxL)
  vis= fltarr(MaxL)
  viscount = fltarr(MaxL)
  wdsp= fltarr(MaxL)
  wdspcount= fltarr(MaxL)
  mxspd= fltarr(MaxL)
  gust= fltarr(MaxL)
  maxt= fltarr(MaxL)
  maxtflg = strarr(MaxL)  
  mint= fltarr(MaxL)
  mintflg = strarr(MaxL)
  prcp= fltarr(MaxL)
  prcpflg = strarr(MaxL)
  sndp= fltarr(MaxL)
  fog = fltarr(MaxL)
  rain = fltarr(MaxL)
  snow = fltarr(MaxL)
  hail = fltarr(MaxL)
  thunder = fltarr(MaxL)
  Tornado = fltarr(MaxL)       

  openr, 1, file
  readf, 1, nouse
  while not eof(1) do begin
     readf, 1, stn1, wban1, yr1, mon1, day1, temp1, tempcount1, $
               dewp1, dewpcount1, slp1, slpcount1, $
               stp1, stpcount1, vis1, viscount1, $
               wdsp1, wdspcount1, mxspd1, gust1, $ 
               maxt1, maxtflg1, mint1, mintflg1, $
               prcp1, prcpflg1, sndp1, fog1, rain1,  $ 
               snow1, hail1, thunder1, tornado1, $      ; 27 var
               FORMAT = '(I6, 1X, I5, 2X, I4, I2, I2, ' +  $ ; 5 var, 22char
                          '4(2X, f6.1, 1X, I2),' +  $      ; 10 var  44 char
                          '1X, f6.1, 1X, I2,' +  $      ; vis     10 char ;76 
                          '2X, f5.1, 1X, I2,' +  $       ; WDSP  2 var 10 char 86
                          ' 2X, f5.1, 2x, f5.1, ' +  $         ; GUST  2 var  14 char 100 char
                          '2X, f6.1, A1, 1X, f6.1, A1, 1X,' +  $ ; MAX & MIN 4 var 18 char 
                          'f5.2, A1, 1X, f5.1, 2X, I1, I1, I1, I1, I1, I1)'   ; PRCP   4 var, 20 char
    stn(i) = stn1 
    wban(i) = wban1
    yr(i) = yr1 
    mon(i) = mon1
    day(i)= day1
    temp(i)= temp1
    tempcount(i) = tempcount1
    dewp(i)= dewp1
    dtcount(i)= dewpcount1
    slp(i)= slp1
    slpcount(i)= slpcount1
    stp(i)= stp1
    stpcount(i)= stpcount1
    vis(i)= vis1
    viscount(i)= viscount1
    wdsp(i)= wdsp1
    wdspcount(i)= wdspcount1
    mxspd(i) = mxspd1
    gust(i) = gust1
    maxt(i) = maxt1
    maxtflg(i) = maxtflg1
    mint(i) = mint1
    mintflg(i) = mintflg1
    prcp(i) = prcp1
    prcpflg(i) = prcpflg1
    sndp(i) = sndp1
    fog(i) = fog1
    rain(i)  = rain1
    snow(i)  = snow1
    hail(i)  = hail1
    Thunder(i) = thunder1
    Tornado(i) = tornado1 
  
    i  = i + 1 
;    print, 'line number  = :', i 
  endwhile        
  close, 1

    stn = reform( stn(0:i-1) )
    wban =reform( wban(0:i-1))
    yr = reform(yr(0:i-1) )
    mon = reform(mon(0:i-1))
    day= reform(day(0:i-1))
  
    sfct= reform(temp(0:i-1))
    result = where(sfct ne 9999.9)  
    sfct(result) = (sfct(result) - 32.)*5./9     
    tempcount = reform(tempcount(0:i-1))
  
    dewp= reform(dewp(0:i-1))
    result = where(dewp ne 9999.9)  
    dewp(result)= (dewp(result) - 32.)*5./9
    dtcount= reform(dtcount(0:i-1))
    
    slp= reform(slp(0:i-1))
    slpcount= reform(slpcount(0:i-1))
    stp= reform(stp(0:i-1))
    stpcount= reform(stpcount(0:i-1))
    vis= reform(vis(0:i-1))
    viscount= reform(viscount(0:i-1))
    wdsp= reform(wdsp(0:i-1))
    wdspcount= reform(wdspcount(0:i-1))
    mxspd = reform(mxspd(0:i-1))
    gust = reform(gust(0:i-1))
    maxt = reform(maxt(0:i-1))
    maxtflg = reform(maxtflg(0:i-1))
    mint = reform(mint(0:i-1))
    mintflg = reform(mintflg(0:i-1))
    prcp = reform(prcp(0:i-1))
    fprcp = reform(prcpflg(0:i-1))
    sndp = reform(sndp(0:i-1))
    fog = reform(fog(0:i-1))
    rain  = reform(rain(0:i-1))
    snow  = reform(snow(0:i-1))
    hail  = reform(hail(0:i-1))
    Thunder = reform(thunder(0:i-1))
    Tornado = reform(tornado(0:i-1))
   
    RH = fltarr(i) + 9999.9 
    result = where(sfct ne 9999.9 and dewp ne 9999.9) 
    RH(result) = exp(const * (1./(sfct(result)+273.15) - 1./(dewp(result)+273.15)))
    ln = i-1
  
  END 
     
                              
  



