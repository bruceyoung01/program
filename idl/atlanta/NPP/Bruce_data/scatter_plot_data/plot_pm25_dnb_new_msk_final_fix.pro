 ; based upon VIIRS data file names to find its orbit #
 ; August 1 will be orbit # 0; VIIRS has repeat cycle of 16 days. 
 PRO ORbit, YY, mm, day, orbitnum
    ; given a certain day, we can find the group #
    ; first we compute Julian day, and # of days from Aug1.
     JD = JulDAY (MM, day, YY)
     JD0 = JulDAY (8,   1, 2012)
     orbitnum = (JD-JD0) mod 16
 END

 ; plot pm2.5 vs. radiances
 PRO plot_dnb_radiance, dir, filename, filename_ind, position, pequation, siteid, sitenum

 ; read PM data
 readcol, dir + filename + '_1.txt', yypm, mmpm, ddpm, hrpm, lat, lon, vvza, SatAZM, $
         moonphase, LZA, LAZM, PMA, PMB, PMC, PMD, $
         F= 'I, I, I, I,  F, F, F, F, F, F, F, F, F, F, F', $
         skipline = 1 , DELIMITER = ','

 ; read cloud mask data
 dirpicked = '../../DNB/picked/'
 readcol, dirpicked + 'Site_cloudmask_fix.txt', $ 
          YYC, MonC, DDC, HHC, MMC, SSC,  $
          cld1, cld2, cld3, cld4, cld5, cld6, $
          F = '(I, I, I, I, I, I,  F, F, F, F, F, F )'     
         nvar =6 
         nl = n_elements(YYc)
         Cld  = fltarr(nl, nvar)
          for j = 0, nvar-1 do begin
              tmp = string('cld'+strtrim(j+1, 2))
              tst = execute( 'cld[*, j] = ' + tmp+ '[*]' )
          endfor 

 read_dnb_picked_201208_10, dirpicked, siteid, YYP, MonP, DDP, HHP, MMP, SSP, $
      rad, vza, Mphase, MFraction

 ; read daily RH file from weather stations
  readcol, '../../METR/Atlanta_RH_project.txt', ssiteid, wban, yymmdd, temp, $
           dewp, slp, stp, vis, $
           wdsp, mxspd, gust, matT, minT, prcp, SNDP, frshitt, rh, viskm, $
           format = 'A6, A5, A8, F, F, F, F, F, F, F, F, F, F, F, F, F, F, F', skipline = 1, $
           DELIMITER = ' '
  yymmddflt = double (yymmdd)
  yyrh = fix((yymmddflt/10000))
  mmrh = fix( (yymmddflt - yyrh * 10000D)/100)
  ddrh  =fix( yymmddflt - yyrh*10000D - mmrh*100)

 ; read hourly RH file from weather stations
  readcol, '../../METR/npp_overpass_mete.txt', YYY, MMM, DDD, HH, Vis, HourlyRH, Wind, WindDir, $
           precip, pressure, $ 
           format = 'I5,  I5,  I5, I5, F8.2, F8.2, F8.2, F8.2, F8.2, F8.2)', skipline = 1, $
           DELIMITER = ' '

 ; read PBH, pressure, water vapor amount, and RH from WRFChem simulation
;  readcol, './wrfchem_site/' + siteid + '_2012.txt', wyy, wmm, wdd, whr, wrh, wu, wv, wpbl, wps, $
;         F= 'A4, A3, A3, A3, F, F, F, F, F', $
;         skipline = 1 , DELIMITER = ','
;  readcol, '/home/jwang/PRO/NPP/METR/WRF/' + siteid + '_2012.txt', wyy, wmm, wdd, whr, wrh, wu, wv, wpbl, wps, $
;         F= 'A4, A3, A3, A3, F, F, F, F, F', $
 ;        skipline = 1 , DELIMITER = ','


 ; covert WRHChem RH to time of our interest
;  result = where (whr eq 7, count) 
;  print, 'RH correlation: ', correlate(RH(0:count-1), wrh(result))
;  WRFRH = wrh(result)

 ; use hourly HR
 RH = RH
 b0 = -0.24812
 b1 = 1.01865
 b2 = 0.01074
 F = b0 + b1 * 100/(100.-RH) + b2 * (100/(100.-RH))^2

; Viskm = vis

 ; computer mean of radiances
 NL = n_elements (YYP)
 DNB = fltarr(NL)    ; new rad from my own computation
 PM = fltarr(NL)
 dmfra = fltarr(NL)
 dmpha = fltarr(NL)
 dvza = fltarr(NL)-999
 dnb = fltarr(NL)
 dcld = fltarr(NL)
 drh = fltarr(NL)
 dmm = fltarr(NL)
 FF = fltarr(NL) - 999
 DNBL = fltarr(NL)
 DOrb = fltarr(NL) - 999 
 indp = intarr(NL)
 xx   = fltarr(NL)
 yy   = fltarr(NL)
 yypp = strarr(NL)
 monpp= strarr(NL)
 ddpp = strarr(NL)

 ; look through PM Days
 np = 0
 for i = 0, NL - 1 do begin
; print, 'processing day = ', fix(yyp(i)), fix(MonP(i)), fix(ddp(i)), $
;                             fix(hhp(i)), fix(mmp(i)), fix(ssp(i))
  resultPM = where( yypm eq fix(yyp(i)) and mmpm eq fix(MonP(i)) and $
                  ddpm eq fix(ddp(i)), countPM)
  resultRH = where( yyrh eq fix(yyp(i)) and mmrh eq fix(MonP(i)) and $
                  ddrh eq fix(ddp(i)), countRH)
  resultCld = where( yyc eq fix(yyp(i)) and monc eq fix(MonP(i)) and $
                  ddc eq fix(ddp(i)) and hhc eq fix(hhp(i)), countCld) 

  ; also find the group # for this day
  ORbit, yyp(i), MonP(i), Ddp(i), orbitnum
; print, 'orbitnum = ', orbitnum

; PRINT, yyp(i), monp(i), ddp(i)
; print, countPM, '+', countCld, '+', countRH, '+', countmsk
; if (countPM  gt 0 and $
;     countRH  gt 0 and $
;     countCld gt 0 and $
;     countmsk gt 0) then begin

  if (countPM  gt 0 and $
      countRH  gt 0 and $
      countCld gt 0 and $
      cld(resultCld(0), sitenum) eq 1) then begin
; find f factor and PM factor
      nlpm    = resultPM(0)
      tmppm   = [PMA(nlpm), PMB(nlpm), PMC(nlpm), PMD(nlpm)]
      PM(np)  = MEAN(tmppm(WHERE(tmppm ge 0.0)))
      nlrh    = resultRH(0)
      FF(np)  = F(nlrh)   
      DRH(np) = RH(nlrh)

; find DNB values
;     tmp     = reverse(sort(rad(i, *)))
;     DNB(np) = max(rad(i, *)) 
;     DNB(np) = mean(rad(i, tmp(0)) + rad(i, tmp(1))) 
      tmp     = rad(i, *)

; FIX DIFFERENT PIXELS FOR DIFFERENT SITES
;     PRINT, ' date = ', yyp(i), monp(i), ddp(i)
      IF (sitenum EQ 0) THEN BEGIN
         fixp    = 4
         DNB(np) = tmp(0, fixp)
      ENDIF ELSE IF (sitenum EQ 1) THEN BEGIN
         fixp    = [1, 2, 5]
         DNB(np) = MEAN(tmp(0, fixp))
      ENDIF ELSE IF (sitenum EQ 2) THEN BEGIN
         fixp    = [0, 1]
         DNB(np) = MEAN(tmp(0, fixp))
      ENDIF ELSE IF (sitenum EQ 3) THEN BEGIN
         fixp    = [1, 4]
         DNB(np) = MEAN(tmp(0, fixp))
      ENDIF ELSE IF (sitenum EQ 4) THEN BEGIN
         fixp    = [8, 11, 13]
         DNB(np) = MEAN(tmp(0, fixp))
      ENDIF ELSE IF (sitenum EQ 5) THEN BEGIN
         fixp    = [2, 6, 7, 12]
         DNB(np) = MEAN(tmp(0, fixp))
      ENDIF
;--------------------------------------------------------------
;  FIX ONE PIXEL TO CORRELATE PM AND VIIRS
;--------------------------------------------------------------
;     fixp    = 4
;     DNB(np) = tmp(0, fixp)

;     inx     = reverse(sort(tmp))
;     DNB(np) = mean(tmp(inx[2:4]))
;     DNB(np) = mean([tmp(1), tmp(2), tmp(4)])
;     DNB(np) = mean(tmp(where(tmp gt 0 ))) 
;     DNB(np) = max(tmp)
;     DNB(np) = median(tmp)

      DVZA(np) = mean(cos(vza(i,*)*!pi/180.)) 
      DMFra(np)= Mfraction(i) 
      DMPha(np)=  MPhase(i)
      DCld(np) = Cld(resultCld(0), sitenum )
      Dmm(np)  = MonP(i)
      DOrb(np) = orbitnum 
      DNBL(np) = i
      indp(np) = where(tmp eq max(tmp) and                  $
                       cld(resultCld(0), sitenum)  eq 1, maxcount)
      xx(np)   = PM(np)*FF(np)
      yy(np)   = alog(DNB(np))
      yypp(np) = yyp(i)
      monpp(np)= monp(i)
      ddpp(np) = ddp(i)
;print, 'line = ', np+1, ' date = ', yyp(i), monp(i), ddp(i), ' pm = ', PM(np), ' DNB = ', DNB(np), $
;       ' FF = ', FF(np), ' vza = ', mean(vza(np, *)), ' DVZA = ', DVZA(np), $
;       'xx = ', xx(np), 'yy = ', yy(np)
;     PRINT, yyp(i), monp(i), ddp(i), DNB(np)
      np = np + 1
   endif
 endfor      

 CLOSE, 20
 ; start the ploting
; for j = 0, 15 do begin
;print, 'yypp = ', yypp(34), $
;       'monpp= ', monpp(34),$
;       'ddpp = ', ddpp(34), $
;       'pm =   ', PM(35),   $
;       'FF =   ', FF(35),   $
;       'vza = ', mean(vza(35, *)), $
;       'DVZA = ', DVZA(32), $
;       'DNB = ', DNB(32)
 XX = PM * FF
 YY = alog(DNB)
 result = where ( XX gt 0  and  $ 
              DVZA ge 0 and  Dmm le 10 and Dmm ge 8 and DRH gt 0 and Dcld eq 1 and Dorb ge 0, count)
 for ic = 0, count-1 do begin
    npp = result(ic)
;print, 'line = ', npp+1, ' date = ', yypp(npp), monpp(npp), ddpp(npp), ' pm = ', PM(npp), ' DNB = ', DNB(npp), $
;       ' FF = ', FF(npp), ' vza = ', mean(vza(npp, *)), ' DVZA = ', DVZA(npp), $
;       ' xx = ', xx(npp), ' yy = ', yy(npp)
 endfor

if (count gt 1 ) then begin
 print, 'N = ', N_ELEMENTS(yy(result))
 print, 'R = ', correlate(yy(result),  xx(result)/DVZA(result))
 print, 'yy = ', yy(result(7)), 'xx = ', xx(result(7)), 'DVZA = ', DVZA(result(7)), 'txx = ', xx(result(7))/DVZA(result(7))
 best_fit_n, yy(result),  xx(result)/DVZA(result) , ifplot=1, xrange = [0, 150], $
          yrange = [-2.0, 3.5], title = 'Line #', $
          xtitle = 'PM2.5/(cos(VZA)), Siteid:' + siteid, $
          ytitle = ' log(rad) ', position = position, $
          pequation = pequation, colors = 1, number = DNBL(result)

 multipanel, position = newposition, /advance
 newpequation = [ newposition(0)+0.1* (newposition(2)-newposition(0)), newposition(1)+0.9*(newposition(3)-newposition(1)) ]
 best_fit_n, yy(result),  xx(result)/DVZA(result) , ifplot=1, xrange = [0, 150], $
          yrange = [-2.0, 3.5], title = 'Group #', $
          xtitle = 'PM2.5/(cos(VZA)), Siteid:' + siteid, $
          ytitle = ' log(rad) ', position = newposition, $
          pequation = newpequation, colors = 1, number = Dorb(result) 
 multipanel, position = position, /advance
 pequation = [ position(0)+0.1* (position(2)-position(0)), position(1)+0.9*(position(3)-position(1)) ]

endif
;endfor
end  


;==================================================================================================
; Main Code Starts Here
 ; set plot ps
;ps_color, filename = 'PM_DNB_Picked_fix_msk_B_201208_10_v01.ps'
 MYCT, 0, /NO_STD 
 ; set plot for 5 panels
;multipanel, row=1, col=2 
;multipanel, position = position

;                   A           B           C            D           E
;              N. Atlanta    SW            SE           CTR         CTR      
 FileNames = ['131350002', '130770002', '131510002', '131210055', '130890002', 'CTR', 'Yang'] 
 siteid    = ['A', 'B', 'C', 'D', 'E', 'CTR', 'YANG' ]
 nsite     = N_ELEMENTS(siteid)

 dir = './data_w_background/'
; dir = './data_ctr/'
 
 for i = 0, 5 do begin
    print, 'Site = ', siteid(i)
; set plot for 5 panels
    multipanel, row=3, col=2 
    multipanel, position = position
; set plot ps
    ps_color, filename = 'PM_DNB_Picked_fix_msk_' + siteid(i) + '_201208_10_v02.ps'
    pequation = [ position(0)+0.05* (position(2)-position(0)), position(1)+0.9*(position(3)-position(1)) ] 
    plot_dnb_radiance, dir, filenames(i), filename_ind, position, pequation, siteid(i), i  
    multipanel, /OFF
 endfor

 device, /close
 end
