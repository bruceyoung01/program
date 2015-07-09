
PRO yang_epa, filename, dir, position, pequation, siteid

; correlate Yang's data with EPA data in Sep.
 readcol, 'npp_overpass_yang.txt', yyy, mmy, ddy, hhy, pmy, $
   F = 'I, I, I, I, F', skipline = 1 , DELIMITER = ' '

; read EPA daat
readcol, dir + filename + '_1.txt', $
        yyp, mmp, ddp, hrp, lat, lon, vza, SatAZM, $
        moonphase, LZA, LAZM, PMA, PMB, F= 'A4, A2, A2, A2,  F, F, F, F, F, F, F, F, F', $
         skipline = 1 , DELIMITER = ','

; read meteorology field
 readcol, '/home/jwang/PRO/NPP/METR/Atlanta_RH_project.txt', ssiteid, wban, yymmdd, temp, $
           dewp, slp, stp, vis, $
           wdsp, mxspd, gust, matT, minT, prcp, SNDP, frshitt, rh, viskm, $
           format = 'A6, A5, A8, F, F, F, F, F, F, F, F, F, F, F, F, F, F, F', skipline = 1, $
           DELIMITER = ' '
  yymmddflt = double (yymmdd)
  yyy = fix((yymmddflt/10000))
  mmm = fix( (yymmddflt - yyy * 10000D)/100)
  ddd  =fix( yymmddflt - yyy*10000D - mmm*100)


; multipanel, position = newposition, /advance
; newpequation = [ newposition(0)+0.1* (newposition(2)-newposition(0)), newposition(1)+0.9*(newposition(3)-newposition(1)) ]
 pequation = [ position(0)+0.1* (position(2)-position(0)), position(1)+0.9*(position(3)-position(1)) ]

result = where ( pmy gt 0 and pma gt 0 and pmb gt 0) 
best_fit, pmy(result), 0.5* (pma(result)+pmb(result)) , ifplot=1, xrange = [0, 30], $
          yrange = [0, 30], $
          xtitle = ' EPA PM ' + siteid, $
          ytitle = ' Yang data ', position = position, $
          pequation = pequation

 multipanel, position = newposition, /advance
 newpequation = [ newposition(0)+0.1* (newposition(2)-newposition(0)), newposition(1)+0.9*(newposition(3)-newposition(1)) ]

result = where ( pmy gt 0 and pma gt 0 and pmb gt 0 and rh gt 0) 
ratio  = pmy/(0.5* (pma+pmb))
best_fit, ratio(result), rh(result), ifplot=1, xrange = [0, 100], $
          yrange = [0, 30], $
          xtitle = ' EPA PM ' + siteid, $
          ytitle = ' Yang data ', position = newposition, $
          pequation = newpequation



END


; start the fitting
; Main Code Starts Here
 ; set plot ps
 ps_color, filename = 'EPA_YANG.ps'

 ; set plot for 5 panels
 multipanel, row=3, col=2
 multipanel, position = position

;                   A           B           C            D           E
;              N. Atlanta    SW            SE           CTR         CTR      
 FileNames = ['131350002', '130770002', '131510002', '131210055', '130890002', 'CTR']
 siteid =    ['A', 'B', 'C', 'D', 'E', 'CTR' ]

 
 dir = '../scatter_plot_data/data_w_background/'

 for i = 0, 5 do begin
 pequation = [ position(0)+0.1* (position(2)-position(0)), position(1)+0.9*(position(3)-position(1)) ]
 yang_epa, filenames(i), dir, position, pequation, siteid(i)
 multipanel, position = position, /advance
 endfor
 
device, /close
END

