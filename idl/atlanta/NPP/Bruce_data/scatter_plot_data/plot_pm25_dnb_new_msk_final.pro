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
 readcol, dirpicked + 'Site_cloudmask.txt', $ 
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

 readcol, dirpicked + 'Site_pickmanual.txt', $ 
          YYM, MonM, DDM, HHM, MMMM, SSM,  $
          msk1, msk2, msk3, msk4, msk5, msk6, $
          F = '(I, I, I, I, I, I,  F, F, F, F, F, F )'     
         nvar =6 
         nl = n_elements(YYM)
         msk  = fltarr(nl, nvar)
          for j = 0, nvar-1 do begin
              tmp = string('msk'+strtrim(j+1, 2))
              tst = execute( 'msk[*, j] = ' + tmp+ '[*]' )
          endfor 

 readcol, dirpicked + 'Site_pickmanual2.txt', $ 
          YYM2, MonM2, DDM2, HHM2, MMMM2, SSM2,  $
          msk21, msk22, msk23, msk24, msk25, msk26, $
          F = '(I, I, I, I, I, I,  F, F, F, F, F, F )'     
         nvar =6 
         nl = n_elements(YYM2)
         msk2 = fltarr(nl, nvar)
          for j = 0, nvar-1 do begin
              tmp = string('msk2'+strtrim(j+1, 2))
              tst = execute( 'msk2[*, j] = ' + tmp+ '[*]' )
          endfor 
 
 readcol, dirpicked + 'Site_pickmanual3.txt', $ 
          YYM3, MonM3, DDM3, HHM3, MMMM3, SSM3,  $
          msk31, msk32, msk33, msk34, msk35, msk36, $
          F = '(I, I, I, I, I, I,  F, F, F, F, F, F )'     
         nvar =6 
         nl = n_elements(YYM3)
         msk3 = fltarr(nl, nvar)
          for j = 0, nvar-1 do begin
              tmp = string('msk3'+strtrim(j+1, 2))
              tst = execute( 'msk3[*, j] = ' + tmp+ '[*]' )
          endfor 

 readcol, dirpicked + 'Site_pickmanual4.txt', $ 
          YYM4, MonM4, DDM4, HHM4, MMMM4, SSM4,  $
          msk41, msk42, msk43, msk44, msk45, msk46, $
          F = '(I, I, I, I, I, I,  F, F, F, F, F, F )'     
         nvar =6 
         nl = n_elements(YYM4)
         msk4 = fltarr(nl, nvar)
          for j = 0, nvar-1 do begin
              tmp = string('msk4'+strtrim(j+1, 2))
              tst = execute( 'msk4[*, j] = ' + tmp+ '[*]' )
          endfor 

 readcol, dirpicked + 'Site_pickmanual5.txt', $ 
          YYM5, MonM5, DDM5, HHM5, MMMM5, SSM5,  $
          msk51, msk52, msk53, msk54, msk55, msk56, $
          F = '(I, I, I, I, I, I,  F, F, F, F, F, F )'     
         nvar =6 
         nl = n_elements(YYM5)
         msk5 = fltarr(nl, nvar)
          for j = 0, nvar-1 do begin
              tmp = string('msk5'+strtrim(j+1, 2))
              tst = execute( 'msk5[*, j] = ' + tmp+ '[*]' )
          endfor 

 readcol, dirpicked + 'Site_pickmanual6.txt', $ 
          YYM6, MonM6, DDM6, HHM6, MMMM6, SSM6,  $
          msk61, msk62, msk63, msk64, msk65, msk66, $
          F = '(I, I, I, I, I, I,  F, F, F, F, F, F )'     
         nvar =6 
         nl = n_elements(YYM6)
         msk6 = fltarr(nl, nvar)
          for j = 0, nvar-1 do begin
              tmp = string('msk6'+strtrim(j+1, 2))
              tst = execute( 'msk6[*, j] = ' + tmp+ '[*]' )
          endfor 

 readcol, dirpicked + 'Site_pickmanual7.txt', $ 
          YYM7, MonM7, DDM7, HHM7, MMMM7, SSM7,  $
          msk71, msk72, msk73, msk74, msk75, msk76, $
          F = '(I, I, I, I, I, I,  F, F, F, F, F, F )'     
         nvar =6 
         nl = n_elements(YYM7)
         msk7 = fltarr(nl, nvar)
          for j = 0, nvar-1 do begin
              tmp = string('msk7'+strtrim(j+1, 2))
              tst = execute( 'msk7[*, j] = ' + tmp+ '[*]' )
          endfor 

 readcol, dirpicked + 'Site_pickmanual8.txt', $ 
          YYM8, MonM8, DDM8, HHM8, MMMM8, SSM8,  $
          msk81, msk82, msk83, msk84, msk85, msk86, $
          F = '(I, I, I, I, I, I,  F, F, F, F, F, F )'     
         nvar =6 
         nl = n_elements(YYM8)
         msk8 = fltarr(nl, nvar)
          for j = 0, nvar-1 do begin
              tmp = string('msk8'+strtrim(j+1, 2))
              tst = execute( 'msk8[*, j] = ' + tmp+ '[*]' )
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

 OPENW, 20, filename_ind
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
  resultmsk = where( yym eq fix(yyp(i)) and monm eq fix(MonP(i)) and $
                  ddm eq fix(ddp(i)) and hhm eq fix(hhp(i)), countmsk) 

  ; also find the group # for this day
  ORbit, yyp(i), MonP(i), Ddp(i), orbitnum
; print, 'orbitnum = ', orbitnum

; PRINT, yyp(i), monp(i), ddp(i)
; print, countPM, '+', countCld, '+', countRH, '+', countmsk
  if (countPM  gt 0 and $
      countRH  gt 0 and $
      countCld gt 0 and $
      countmsk gt 0) then begin

   ; find f factor and PM factor
   nlpm    = resultPM(0)
   tmppm   = [PMA(nlpm), PMB(nlpm), PMC(nlpm), PMD(nlpm)]
   PM(np)  = MEAN(tmppm(WHERE(tmppm ge 0.0)))
   nlrh    = resultRH(0)
   FF(np)  = F(nlrh)   
   DRH(np) = RH(nlrh)

   ; find DNB values
    tmp = reverse(sort(rad(i, *)))
   ;DNB(np) = max(rad(i, *)) 
   ;DNB(np) = mean(rad(i, tmp(0)) + rad(i, tmp(1))) 
   tmp = rad(i, *)

   ; RESELECT SECOND MAXIMUM IF msk(resultmsk(0), sitenum) < 0
   IF (cld(resultCld(0), sitenum) eq 1 and $
       msk(resultmsk(0), sitenum) lt 0) then begin
    print, 'resultmsk = ', resultmsk
    print, '-----------------------------------------------'
    print, ' date = ', yyp(i), monp(i), ddp(i)
    print, '1st max = ', max(tmp)
    indtmpmax = where(tmp eq max(tmp), maxcount)
    tmp(indtmpmax) = 0.0
    print, '2nd max = ', max(tmp)
   ENDIF

   ; RESELECT SECOND MAXIMUM IF msk2(resultmsk(0), sitenum) < 0
   IF ( cld(resultCld(0), sitenum) eq 1 and $
       msk2(resultmsk(0), sitenum) lt 0) then begin
    indtmpmax = where(tmp eq max(tmp), maxcount)
    tmp(indtmpmax) = 0.0
    print, '3rd max = ', max(tmp)
   ENDIF

   ; RESELECT SECOND MAXIMUM IF msk3(resultmsk(0), sitenum) < 0
   IF ( cld(resultCld(0), sitenum) eq 1 and $
       msk3(resultmsk(0), sitenum) lt 0) then begin
    indtmpmax = where(tmp eq max(tmp), maxcount)
    tmp(indtmpmax) = 0.0
    print, '4th max = ', max(tmp)
   ENDIF

   ; RESELECT SECOND MAXIMUM IF msk4(resultmsk(0), sitenum) < 0
   IF ( cld(resultCld(0), sitenum) eq 1 and $
       msk4(resultmsk(0), sitenum) lt 0) then begin
    indtmpmax = where(tmp eq max(tmp), maxcount)
    tmp(indtmpmax) = 0.0
    print, '5th max = ', max(tmp)
   ENDIF

   ; RESELECT SECOND MAXIMUM IF msk5(resultmsk(0), sitenum) < 0
   IF ( cld(resultCld(0), sitenum) eq 1 and $
       msk5(resultmsk(0), sitenum) lt 0) then begin
    indtmpmax = where(tmp eq max(tmp), maxcount)
    tmp(indtmpmax) = 0.0
    print, '6th max = ', max(tmp)
   ENDIF

   ; RESELECT SECOND MAXIMUM IF msk6(resultmsk(0), sitenum) < 0
   IF ( cld(resultCld(0), sitenum) eq 1 and $
       msk6(resultmsk(0), sitenum) lt 0) then begin
    indtmpmax = where(tmp eq max(tmp), maxcount)
    tmp(indtmpmax) = 0.0
    print, '7th max = ', max(tmp)
   ENDIF

   ; RESELECT SECOND MAXIMUM IF msk7(resultmsk(0), sitenum) < 0
   IF ( cld(resultCld(0), sitenum) eq 1 and $
       msk7(resultmsk(0), sitenum) lt 0) then begin
    indtmpmax = where(tmp eq max(tmp), maxcount)
    tmp(indtmpmax) = 0.0
    print, '8th max = ', max(tmp)
   ENDIF

   ; RESELECT SECOND MAXIMUM IF msk8(resultmsk(0), sitenum) < 0
   IF ( cld(resultCld(0), sitenum) eq 1 and $
       msk8(resultmsk(0), sitenum) lt 0) then begin
    indtmpmax = where(tmp eq max(tmp), maxcount)
    tmp(indtmpmax) = 0.0
    print, '9th max = ', max(tmp)
   ENDIF

;  inx = reverse(sort(tmp))
;  DNB(np) = mean(tmp(inx[2:4]))
;  DNB(np) = mean([tmp(1), tmp(2), tmp(4)])
;  DNB(np) = mean(tmp(where(tmp gt 0 ))) 
   DNB(np) = max(tmp)
;  DNB(np) = median(tmp)
 
   DVZA(np) = mean(cos(vza(i,*)*!pi/180.)) 
   DMFra(np) = Mfraction(i) 
   DMPha(np) =  MPhase(i)
   DCld(np) = Cld(resultCld(0), sitenum )
   Dmm(np) = MonP(i)
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
;PRINT, yyp(i), monp(i), ddp(i), indp(np)
 PRINTF, 20, yyp(i), monp(i), ddp(i), indp(np), FORMAT = '(3(A, X), 1X, I2)'
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
 best_fit_n, yy(result),  xx(result)/DVZA(result) , ifplot=1, xrange = [0, 150], $
          yrange = [-2.0, 3.5], title = 'Max index #', $
          xtitle = 'PM2.5/(cos(VZA)), Siteid:' + siteid, $
          ytitle = ' log(rad) ', position = position, $
          pequation = pequation, colors = 1, number = indp(result) 
 multipanel, position = position, /advance
 pequation = [ position(0)+0.1* (position(2)-position(0)), position(1)+0.1*(position(3)-position(1)) ]
endif
;endfor
end  


;==================================================================================================
; Main Code Starts Here
 ; set plot ps
 ps_color, filename = 'PM_DNB_Picked_msk_CTR_201208_10_v08.ps'
 MYCT, 0, /NO_STD 
 ; set plot for 5 panels
 multipanel, row=3, col=2 
 multipanel, position = position

;                   A           B           C            D           E
;              N. Atlanta    SW            SE           CTR         CTR      
 FileNames = ['131350002', '130770002', '131510002', '131210055', '130890002', 'CTR', 'Yang'] 
 siteid    = ['A', 'B', 'C', 'D', 'E', 'CTR', 'YANG' ]
 nsite     = N_ELEMENTS(siteid)

 dir = './data_w_background/'
; dir = './data_ctr/'
 
 for i = 5, 5 do begin
 print, 'Site = ', siteid(i)
 filename_ind = 'select_pixel_index'
 filename_ind = filename_ind + siteid(i) + '.txt'
 pequation = [ position(0)+0.05* (position(2)-position(0)), position(1)+0.9*(position(3)-position(1)) ] 
 plot_dnb_radiance, dir, filenames(i), filename_ind, position, pequation, siteid(i), i  
 multipanel, position = position, /advance
 endfor
 device, /close
 end
