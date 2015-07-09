
;============================================================================

@ctl
@define_plot_size

 if n_elements(pbkg) eq 0 then begin
    pcur = get_pval(obs=newobs, sim=newsim)
    pbkg = get_pval(obs=newobs, sim=newbkg)
    pnat = get_pval(obs=newobs, sim=newnat)
    pbkg1 = get_pval(obs=newobs, sim=newbkg1)
    pnat1 = get_pval(obs=newobs, sim=newnat1)
 endif


; mid = where(newobs.lon lt -95. and newobs.lat gt 40. and newobs.std gt 3. and newobs.mean gt 8.)
; mid = where(newobs.lon gt -95. and newobs.lat gt 35. and newobs.std gt 5. and newobs.mean gt 18.)
; mid = where(newobs.lon lt -95. and newobs.lat gt 40. )

   mid = [14, 16, 19, 27, 30, 32, 36, 38, 45, 52, 56, $
          58, 61, 71, 74, 75, 79, 80, $
          94,102,110,111,112,113,119,120,127,132]

; based on p90 statistic on 1x1 results
; for west
 baseline   = mean(pcur[mid].a80, /nan)
 background = mean(pbkg[mid].a80, /nan)
 natural    = mean(pnat[mid].a80, /nan)
 EPAdefault = mean(newobs[mid].epa_p90, /nan)

 print, baseline, background, natural, epadefault

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

 if (!D.name eq 'PS') then $
   open_device, file='trend_west_color.ps', /ps, /color, /landscape

 !p.multi = [0,1,2]

 lthick=10

 plot, Year, dv_epan, color=1, xrange=[2004,2064], xstyle=9, $
    ystyle=9, position = [0.15, 0.55, 0.95, 0.95], thick=lthick, $
    Ytitle='Visibility [deciview]', yrange=[3,20], charsize=charsize
 oplot, Year, dv_rjpn, color=4, line=0, thick=lthick
 oplot, Year, dv_rjpb, color=2, line=0, thick=lthick

; plots, [2018, 2018], [0., 15], color=2, line=0, thick=lthick*0.5

 xd = [2007,2012]
 plots, xd, [7.5,7.5], color=1, line=0, thick=lthick
 plots, xd, [6.,6.], color=4, line=0, thick=lthick
 plots, xd, [4.5,4.5], color=2, line=0, thick=lthick

 XYOUTS, xd[1]+1, 7.5,  'natural (EPA default value)', color=1, charsize=charsize
 XYOUTS, xd[1]+1, 6., 'natural (this work)', color=1, charsize=charsize
 XYOUTS, xd[1]+1, 4.5, 'natural + transboundary pollution (this work)', color=1, charsize=charsize

; Axis, 1996, 0, YAxis=0, Yrange=[10, 50], /Save, Ystyle=1, color=4, $
;    Ytitle='bext'

; oplot, Year, bext_rjp, color=4, line=0, thick=lthick
; oplot, Year, bext_epa, color=4, line=2 , thick=lthick


; Axis, 1996, 0, YAxis=0, Yrange=[0, 140], /Save, Ystyle=1, color=1

 plot, Year, rate0_epan, color=1, line=0, thick=lthick, $
    Yrange=[0, 100], position = [0.15, 0.1, 0.95, 0.5], $
    xrange=[2004,2064], Xstyle=9, ystyle=9, $
    Xtitle='Year', Ytitle='Required [%] decrease in U.S. !C!C anthropogenic emissions', $
    charsize=1.4

 oplot, Year, rate0_rjpn, color=4, line=0, thick=lthick
 oplot, Year, rate0_rjpb, color=2, line=0, thick=lthick

 XYOUTS, 0.12, 0.06, '2000-4', /normal, color=1, alignment=0.5, charsize=1.4
; oplot, Year, rate1_rjp, color=3, line=0, thick=lthick
; oplot, Year, rate1_epa, color=3, line=2 , thick=lthick

; plots, [2018, 2018], [0., 140], color=2, line=0, thick=lthick*0.5

; plots, [2010, 2016], [130.,130.], color=1, line=0, thick=lthick
; plots, [2010, 2016], [110.,110.], color=3, line=0, thick=lthick

; XYOUTS, 2017, 130., 'based on GEOS-CHEM endpoint', color=1
; XYOUTS, 2017, 110., 'based on EPA endpoint', color=1

 print, year[15], rate0_epan[15], rate0_rjpn[15], rate0_rjpb[15]

 if (!D.name eq 'PS') then $
   close_device

 
 End
