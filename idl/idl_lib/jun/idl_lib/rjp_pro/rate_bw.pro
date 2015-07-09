 function epa_default, obs

   tag = tag_names(obs[0])
   ntg = n_tags(obs[0])

   ; Light extinction from IMPROVE obs
   ammso4_bext = make_zero(obs.ammso4_bext, val='NaN')
   ammno3_bext = make_zero(obs.ammno3_bext, val='NaN')
   ec_bext     = make_zero(obs.ec_bext,     val='NaN')
   omc_bext    = make_zero(obs.omc_bext,    val='NaN')
   soil_bext   = make_zero(obs.soil_bext,   val='NaN')
   cm_bext     = make_zero(obs.cm_bext,     val='NaN')

   ext = ammso4_bext+ammno3_bext+ec_bext+omc_bext+soil_bext+cm_bext+10.
;   ext = ammso4_bext+ammno3_bext+ec_bext+omc_bext+10.

   vis = 10. * Alog( ext / 10. )

   avg = fltarr(N_elements(obs.siteid))
   std = avg

   For D = 0, N_elements(obs.siteid)-1 do begin
      data = chk_undefined(reform(vis[*,D]))

     if data[0]          ne -1   and $
        n_elements(data) gt 80.  and $
        obs[D].lat       gt 20.  then begin
        avg[D] = Mean(Data)
        std[D] = STDDEV(Data)
     end else begin
        avg[D] = -999.
        std[D] = -999.
     end

     ; calculate default natural values using EPA method 
     frh = mean(make_zero(obs[D].frhgrid,val='NaN'),/NaN) ; annual frh
     if obs[D].lon le -95. then begin ; west
        bext = 3.*frh*0.21 + 4.*0.47 + 10.*0.02 + 0.5 + 1.8 + 10.
        sd   = 2.
     end else begin  ; east
        bext = 3.*frh*0.33 + 4.*1.4  + 10.*0.02 + 0.5 + 1.8 + 10.
        sd   = 3.
     end

     epa_avg = 10.*alog(bext/10.)  ; EPA default mean natural visibilty
     epa_p8  = epa_avg - (1.42 * sd)
     epa_p92 = epa_avg + (1.42 * sd)
      
     ; mean and stddev and EPA default values
     a_str = create_struct('ID', D, 'MEAN',avg[D], 'STD',std[D],  $ 
                           'EPA_AVG', epa_avg, 'EPA_p8', epa_p8,$
                           'EPA_p92', epa_p92) 

     info = obs[D]
     for n = 0, ntg-1 do begin
         d1    = info.(N)
         a_str = create_struct(a_str, tag[N], d1)
     end

     if D eq 0 then fld = a_str else fld = [fld, a_str]

  End

   newobs = fld
   undefine, fld

   return, newobs

 end

;========================================================================
;============================================================================

@ctl
@define_plot_size

 if n_elements(pbkg) eq 0 then begin
    aobs = epa_default( obs )
    pcur = get_pval(obs=newobs, sim=newsim, /baseline)
    pbkg = get_pval(obs=newobs, sim=newbkg)
    pnat = get_pval(obs=newobs, sim=newnat)
    pbkg1 = get_pval(obs=newobs, sim=newbkg1)
    pnat1 = get_pval(obs=newobs, sim=newnat1)
 endif



 if (!D.name eq 'PS') then $
   open_device, file='fig11_trend_bw.ps', /ps, /color, /landscape

 !p.multi = [0,2,2,0,1]

 pos = cposition(2, 2, xoffset=[0.12,0.05], yoffset=[0.1,0.24], $
       xgap=0.05, ygap=0.1, order=1)
 ffc = 0.4
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                     for west
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 mid = where(newobs.lon lt -95. and newobs.lat gt 40. and newobs.std gt 3. and newobs.mean gt 8.)
 mid = where(newobs.lon lt -95. and newobs.lat gt 40.)
 mid = where(newobs.lon lt -95.)

; based on p90 statistic on 1x1 results
; for west
 baseline   = mean(pcur[mid].a80, /nan)
 background = mean(pbkg1[mid].a80, /nan)
 natural    = mean(pnat1[mid].a80, /nan)
 EPAdefault = mean(aobs[mid].epa_p92, /nan)

 print, baseline, EPAdefault, natural, background, '  west'

 N = 61
 Year = Lindgen(N)+2004L

 rjpb = ( baseline - background ) / (N - 1)
 rjpn = ( baseline - natural ) / (N - 1)
 epan = ( baseline - EPAdefault ) / (N - 1)

 dv_rjpn = baseline - rjpn*Lindgen(N)
 dv_rjpb = baseline - rjpb*Lindgen(N)
 dv_epan = baseline - epan*Lindgen(N)

 bext_rjpn = 10.*exp(dv_rjpn*0.1)
 bext_rjpb = 10.*exp(dv_rjpb*0.1)
 bext_epan = 10.*exp(dv_epan*0.1)

 rbext_rjpn = (bext_rjpn[0] - bext_rjpn)
 rbext_rjpb = (bext_rjpb[0] - bext_rjpb)
 rbext_epan = (bext_epan[0] - bext_epan)

 rate0_rjpn = rbext_rjpn / rbext_rjpb[N-1] * 100.
 rate0_rjpb = rbext_rjpb / rbext_rjpb[N-1] * 100.
 rate0_epan = rbext_epan / rbext_rjpb[N-1] * 100.

; rate1_rjp = rbext_rjp / rbext_epa[N-1] * 100.
; rate1_epa = rbext_epa / rbext_epa[N-1] * 100.


 lthick=10
 charsize=1.4
 xtag = Lindgen(6)*12L + 2004L
 xtag = strtrim(xtag,2)
 Xlabel = xtag

 yrange = [3,16]
 plot, Year, dv_epan, color=1, xrange=[2004,2064], xstyle=9, $
    ystyle=9, position = pos[*,0], thick=lthick, $
    Ytitle='Visibility [deciviews]', yrange=yrange, charsize=1.4, $
    line=1, xticklen=0.05

 oplot, Year, dv_rjpn, color=4, line=2, thick=lthick
 oplot, Year, dv_rjpb, color=2, line=0, thick=lthick

 ddd = where(year eq 2018L)
 print, Year[0], Year[ddd[0]], '   West      DV,          %'
 print, dv_epan[0], dv_epan[ddd[0]], dv_epan[0] - dv_epan[ddd[0]], rate0_epan[ddd[0]], '   EPA'
 print, dv_rjpn[0], dv_rjpn[ddd[0]], dv_rjpn[0] - dv_rjpn[ddd[0]], rate0_rjpn[ddd[0]], '   RJPNAT'
 print, dv_rjpb[0], dv_rjpb[ddd[0]], dv_rjpb[0] - dv_rjpb[ddd[0]], rate0_rjpb[ddd[0]], '   RJPBAK'
 print, max(rbext_rjpb)

 plots, [2018, 2018], yrange, color=1, line=0, thick=lthick*ffc


 XYOUTS, 0.1, 0.578, '2004', /normal, color=1, alignment=0.5, charsize=1.5

; Axis, 1996, 0, YAxis=0, Yrange=[10, 50], /Save, Ystyle=1, color=4, $
;    Ytitle='bext'

; oplot, Year, bext_rjp, color=4, line=0, thick=lthick
; oplot, Year, bext_epa, color=4, line=2 , thick=lthick


; Axis, 1996, 0, YAxis=0, Yrange=[0, 140], /Save, Ystyle=1, color=1

 plot, Year, rate0_epan, color=1, line=1, thick=lthick, $
    Yrange=[0, 100], position = pos[*,1], $
    xrange=[2004,2064], Xstyle=9, ystyle=9, $
    Xtitle='Year', Ytitle='Required % decrease in U.S. !C anthropogenic emissions', $
    charsize=1.4, xticklen=0.05

 oplot, Year, rate0_rjpn, color=4, line=2, thick=lthick
 oplot, Year, rate0_rjpb, color=2, line=0, thick=lthick
 plots, [2018, 2018], [0., 100], color=1, line=0, thick=lthick*ffc

 XYOUTS, 0.1, 0.198, '2004', /normal, color=1, alignment=0.5, charsize=1.5
; oplot, Year, rate1_rjp, color=3, line=0, thick=lthick
; oplot, Year, rate1_epa, color=3, line=2 , thick=lthick

 aa = where(rate0_epan ge 100.)
 bb = where(rate0_rjpn ge 100.)
; print, year(aa), year(bb)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                   for east
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 mid = where(newobs.lon gt -95. and newobs.lat gt 35. and newobs.std gt 5. and newobs.mean gt 18.)
 mid = where(newobs.lon gt -95. and newobs.lat gt 40.)
 mid = where(newobs.lon gt -95.)

; based on p90 statistic on 1x1 results
; for west
 baseline   = mean(pcur[mid].a80, /nan)
 background = mean(pbkg1[mid].a80, /nan)
 natural    = mean(pnat1[mid].a80, /nan)
 EPAdefault = mean(aobs[mid].epa_p92, /nan)

 print, '==================================================='
 print, baseline, EPAdefault, natural, background, '  east'

 N = 61
 Year = Lindgen(N)+2004L

 rjpb = ( baseline - background ) / (N - 1)
 rjpn = ( baseline - natural ) / (N - 1)
 epan = ( baseline - EPAdefault ) / (N - 1)

 dv_rjpn = baseline - rjpn*Lindgen(N)
 dv_rjpb = baseline - rjpb*Lindgen(N)
 dv_epan = baseline - epan*Lindgen(N)

 bext_rjpn = 10.*exp(dv_rjpn*0.1)
 bext_rjpb = 10.*exp(dv_rjpb*0.1)
 bext_epan = 10.*exp(dv_epan*0.1)

 rbext_rjpn = (bext_rjpn[0] - bext_rjpn)
 rbext_rjpb = (bext_rjpb[0] - bext_rjpb)
 rbext_epan = (bext_epan[0] - bext_epan)

 rate0_rjpn = rbext_rjpn / rbext_rjpb[N-1] * 100.
 rate0_rjpb = rbext_rjpb / rbext_rjpb[N-1] * 100.
 rate0_epan = rbext_epan / rbext_rjpb[N-1] * 100.

; rate1_rjp = rbext_rjp / rbext_epa[N-1] * 100.
; rate1_epa = rbext_epa / rbext_epa[N-1] * 100.

 print, Year[0], Year[ddd[0]], '   East     DV,          %'
 print, dv_epan[0], dv_epan[ddd[0]], dv_epan[0] - dv_epan[ddd[0]], rate0_epan[ddd[0]], '   EPA'
 print, dv_rjpn[0], dv_rjpn[ddd[0]], dv_rjpn[0] - dv_rjpn[ddd[0]], rate0_rjpn[ddd[0]], '   RJPNAT'
 print, dv_rjpb[0], dv_rjpb[ddd[0]], dv_rjpb[0] - dv_rjpb[ddd[0]], rate0_rjpb[ddd[0]], '   RJPBAK'
 print, max(rbext_rjpb)

 yrange = [3, 30]

 plot, Year, dv_epan, color=1, xrange=[2004,2064], xstyle=9, $
    ystyle=9, position = pos[*,2], thick=lthick, $
    yrange=yrange, charsize=1.4, line=1, xticklen=0.05
 oplot, Year, dv_rjpn, color=4, line=2, thick=lthick
 oplot, Year, dv_rjpb, color=2, line=0, thick=lthick
 plots, [2018, 2018], yrange, color=1, line=0, thick=lthick*ffc

 x0 = 0.32
 xd = [x0, x0+0.05]
 y0 = 0.13 & dy = 0.03
 y1 = y0-dy
 y2 = y1-dy
 y3 = y2-dy
 plots, xd, [y1,y1], color=2, line=0, thick=lthick, /normal
 plots, xd, [y2,y2], color=4, line=2, thick=lthick, /normal
 plots, xd, [y3,y3], color=1, line=1, thick=lthick, /normal

 XYOUTS, xd[0]+0.01, y0, 'Specification of 2064 endpoint:', color=1, charsize=charsize, /normal
 XYOUTS, xd[1]+0.01, y1-0.005, 'background (this work)', color=1, charsize=charsize, /normal
 XYOUTS, xd[1]+0.01, y2-0.005, 'natural (this work)', color=1, charsize=charsize, /normal
 XYOUTS, xd[1]+0.01, y3-0.005, 'natural (EPA default value)', color=1, charsize=charsize, /normal

 xx0 = xd[0]-0.01
 xx1 = xx0+0.39
 yy0 = y3-0.02
 yy1 = y0+0.025
 plots, [xx0,xx1,xx1,xx0,xx0], [yy0,yy0,yy1,yy1,yy0], color=1, /normal, thick=5


 plot, Year, rate0_epan, color=1, line=1, thick=lthick, $
    Yrange=[0, 100], position = pos[*,3], $
    xrange=[2004,2064], Xstyle=9, ystyle=9, $
    Xtitle='Year', charsize=1.4, xticklen=0.05

 oplot, Year, rate0_rjpn, color=4, line=2, thick=lthick
 oplot, Year, rate0_rjpb, color=2, line=0, thick=lthick
 plots, [2018, 2018], [0., 100], color=1, line=0, thick=lthick*ffc

; xyouts, 0.32, 0.9, 'Northwest !C(<95W, >40N)', color=1, alignment=0.5, charsize=1.5, charthick=5,/normal
; xyouts, 0.75, 0.9, 'Northeast !C(>95W, >40N)', color=1, alignment=0.5, charsize=1.5, charthick=5,/normal
 xyouts, 0.32, 0.9, 'WEST', color=1, alignment=0.5, charsize=1.5, charthick=5,/normal
 xyouts, 0.75, 0.9, 'EAST', color=1, alignment=0.5, charsize=1.5, charthick=5,/normal

 aa = where(rate0_epan ge 100.)
 bb = where(rate0_rjpn ge 100.)
; print, year(aa), year(bb)

; XYOUTS, 0.55, 0.067, '2004', /normal, color=1, alignment=0.5, charsize=1.5
 if (!D.name eq 'PS') then $
   close_device

 
 End
