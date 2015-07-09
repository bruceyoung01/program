
 function site_pval, obs, sim, bkg, nat, asi, f_na=f_na, f_asia=f_asia

   if n_elements(f_na)   eq 0 then f_na = 1.
   if n_elements(f_asia) eq 0 then f_asia = 1.

   tag = tag_names(sim[0])
   ntg = n_tags(sim[0])

   ; 10th and 90th quantile as averages of best and worst 20%
   s_p10 = fltarr(N_elements(sim.siteid))
   s_p90 = s_p10

   ; average over best and worst 20% values
   s_a20 = s_p10
   s_a80 = s_p10

   For D = 0, N_elements(sim.siteid)-1L do begin

     ; calculate annual frh following the RHR recommendation
       frh = mean(make_zero(obs[D].frhgrid,val='NaN'),/NaN) ; annual frh
;       frh = make_zero(sim[D].frho,val='NaN')

       so4 = nat[D].so4+(bkg[D].so4-asi[D].so4)*f_na+(asi[D].so4-nat[D].so4)*f_asia
       nit = bkg[D].nit
       omc = bkg[D].omc
       ec  = bkg[D].ec

       ; use EPA default soil and cm ext 
       ext = 3.*frh*(so4*1.375+nit*1.29) $
           + omc*4. + ec*10. + 10. + 0.5 + 1.8 ;+ soil_bext + cm_bext

       vis = 10. * Alog( ext / 10. )
       vis = chk_undefined(vis)

       if n_elements(vis) gt 80. and $  ; number of data availabel 2/3 of year
          obs[D].lat      gt 20.  then begin   
          out = quantile(vis, [0.1,0.2,0.8,0.9]) 
          s_p10[D] = out[0]
          s_p90[D] = out[3]

          dat = vis[sort(vis)]
          p1  = where(dat le out[1])  ; best 20%
          p2  = where(dat ge out[2])  ; worst 20%
          s_a20[D] = mean(dat[p1])
          s_a80[D] = mean(dat[p2])

;          print, dat, '****'
;          print, dat[p1], '*****'
;          print, dat[p2], '*****'
;          print, s_a80[D], s_p90[D]
;          if D eq 10 then stop

       end else begin
          s_p10[D] = 'NaN'
          s_p90[D] = 'NaN'
          s_a20[D] = 'NaN'
          s_a80[D] = 'NaN'
       end

     ; mean and stddev and EPA default values
     a_str = create_struct( 'p10', s_p10[D], 'p90', s_p90[D], $
                            'a20', s_a20[D], 'a80', s_a80[D]  ) 

     info = sim[D]
     for n = 0, ntg-1 do begin
         d1    = info.(N)
         a_str = create_struct(a_str, tag[N], d1)
     end

     if D eq 0 then fld = a_str else fld = [fld, a_str]

   end

   return, fld

 end


;============================================================================

@ctl
@define_plot_size

 ; according to A1B scenario
 ; SO2 in Aisa will increase by 1.4
 ; SO2 in Canada decrease by 0.23
 ; SO2 in Mexico increase by 1.6 which 
 ; makes SO2 in North America increase by 1.1

 if n_elements(pbkg) eq 0 then begin
    pcur  = get_pval(obs=newobs, sim=newsim)
    pbkg  = get_pval(obs=newobs, sim=newbkg)
    pnat  = get_pval(obs=newobs, sim=newnat)
    pbkg1 = get_pval(obs=newobs, sim=newbkg1)
    pnat1 = get_pval(obs=newobs, sim=newnat1)
 endif


 if (!D.name eq 'PS') then $
   open_device, file='trend_bw.ps', /ps, /color, /landscape

 !p.multi = [0,2,2,0,1]

 pos = cposition(2, 2, xoffset=[0.12,0.05], yoffset=[0.1,0.24], $
       xgap=0.05, ygap=0.1, order=1)
 ffc = 0.4
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                     for west
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 mid = where(newobs.lon lt -95. and newobs.lat gt 40. and newobs.std gt 3. and newobs.mean gt 8.)
 mid = where(newobs.lon lt -95.)
; mid = 31 ; CRLA
; mid = 116 ; THRO

       ;    A1B  B1   A2   B2
; f_na   = [1.06,0.52,2.27,0.46]
; f_asia = [1.37,0.48,2.05,0.68]

       ;    A1B  B1   B2
; f_na   = [1.06,0.52,0.46]
; f_asia = [1.37,0.48,0.68]

       ;    A1B  B1   B2   A2
 f_na   = [0.00,0.00,0.00,0.00]
; f_na   = [1.00,1.00,1.00,1.00]
 f_asia = [1.37,0.48,0.68,2.05]

 future = fltarr(N_elements(f_na))

 for m = 0, N_elements(f_na)-1 do begin
    out = site_pval( newobs[mid], newsim[mid], newbkg1[mid], newnat1[mid], $
                     newasi[mid], f_na=f_na[m], f_asia=f_asia[m] )
    if n_elements(out.a80) gt 1. then  future[m] = mean(out.a80,/nan) else $
    future[m] = out.a80
 end

; based on p90 statistic on 1x1 results
; for west
 baseline   = mean(pcur[mid].a80, /nan)
 background = mean(pbkg1[mid].a80, /nan)
 natural    = mean(pnat1[mid].a80, /nan)
 EPAdefault = mean(newobs[mid].epa_p90, /nan)

; future = [future, background]

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

 ; Future backgroud (low end)
 background = min(future)

 flow_dv_rjpb    = baseline - Lindgen(N) * ( baseline - background ) / (N - 1)
 flow_bext_rjpb  = 10.*exp(flow_dv_rjpb*0.1)
 flow_rbext_rjpb = (flow_bext_rjpb[0] - flow_bext_rjpb)

 flow_rate0_rjpn = rbext_rjpn      / flow_rbext_rjpb[N-1] * 100.
 flow_rate0_rjpb = flow_rbext_rjpb / flow_rbext_rjpb[N-1] * 100.
 flow_rate0_epan = rbext_epan      / flow_rbext_rjpb[N-1] * 100.

 ; Future backgroud (high end)
 background = max(future)

 fhi_dv_rjpb    = baseline - Lindgen(N) * ( baseline - background ) / (N - 1)
 fhi_bext_rjpb  = 10.*exp(fhi_dv_rjpb*0.1)
 fhi_rbext_rjpb = (fhi_bext_rjpb[0] - fhi_bext_rjpb)

 fhi_rate0_rjpn = rbext_rjpn     / fhi_rbext_rjpb[N-1] * 100.
 fhi_rate0_rjpb = fhi_rbext_rjpb / fhi_rbext_rjpb[N-1] * 100.
 fhi_rate0_epan = rbext_epan     / fhi_rbext_rjpb[N-1] * 100.


 ; plotting

 lthick=dthick
 charsize=1.4
 xtag = Lindgen(6)*12L + 2004L
 xtag = strtrim(xtag,2)
 Xlabel = xtag


 yrange = [3,15]
 plot, Year, dv_epan, color=1, xrange=[2004,2064], xstyle=9, $
    ystyle=9, position = pos[*,0], thick=lthick, $
    Ytitle='Visibility [deciviews]', yrange=yrange, charsize=1.4, $
    line=1, xticklen=0.05

  x   = year
  ylo = fhi_dv_rjpb
  yhi = flow_dv_rjpb
 for nn = 0, n_elements(year)-2 do begin
   xx = [x[nn],x[nn+1],x[nn+1],x[nn]]
   yy = [ylo[nn],ylo[nn+1],yhi[nn+1],yhi[nn]]
   polyfill, xx, yy, color=13
 end

 oplot, Year, dv_rjpn, color=1, line=2, thick=lthick
 oplot, Year, dv_rjpb, color=1, line=0, thick=lthick

 oplot, Year, fhi_dv_rjpb, color=1, line=0, thick=thin
 oplot, Year, flow_dv_rjpb, color=1, line=0, thick=thin


 ddd = where(year eq 2018L)
 print, Year[0], Year[ddd[0]], '   West      DV,          %'
 print, dv_epan[0], dv_epan[ddd[0]], dv_epan[0] - dv_epan[ddd[0]], rate0_epan[ddd[0]], ' epa'
 print, dv_rjpn[0], dv_rjpn[ddd[0]], dv_rjpn[0] - dv_rjpn[ddd[0]], rate0_rjpn[ddd[0]], ' natural'
 print, dv_rjpb[0], dv_rjpb[ddd[0]], dv_rjpb[0] - dv_rjpb[ddd[0]], rate0_rjpb[ddd[0]], ' backgroud'
 print, bext_rjpb[0]-bext_rjpb[N-1], ' US influence'
 print, fhi_dv_rjpb[0], fhi_dv_rjpb[ddd[0]], fhi_dv_rjpb[0]-fhi_dv_rjpb[ddd[0]], fhi_rate0_rjpb[ddd[0]], 'hi backgroud'
 print, flow_dv_rjpb[0], flow_dv_rjpb[ddd[0]], flow_dv_rjpb[0]-flow_dv_rjpb[ddd[0]], flow_rate0_rjpb[ddd[0]], 'hi backgroud'
 print, flow_rate0_epan[ddd[0]], fhi_rate0_epan[ddd[0]], ' low high epa'
 print, flow_rate0_rjpn[ddd[0]], fhi_rate0_rjpn[ddd[0]], ' low high natural'
 print, dv_rjpb[N-1], fhi_dv_rjpb[N-1], flow_dv_rjpb[N-1], ' backgroud deciview'

 plots, [2018, 2018], yrange, color=1, line=0, thick=lthick*ffc


 XYOUTS, 0.1, 0.578, '2004', /normal, color=1, alignment=0.5, charsize=1.5

 ;=======================
 ; emission reduction 
 ;=======================
 plot, Year, rate0_epan, color=1, line=1, thick=lthick, $
    Yrange=[0, 100], position = pos[*,1], $
    xrange=[2004,2064], Xstyle=9, ystyle=9, $
    Xtitle='Year', Ytitle='Required % decrease in U.S. !C anthropogenic emissions', $
    charsize=1.4, xticklen=0.05

  x   = year
  ylo = flow_rate0_rjpb
  yhi = fhi_rate0_rjpb
 for nn = 0, n_elements(year)-2 do begin
   xx = [x[nn],x[nn+1],x[nn+1],x[nn]]
   yy = [ylo[nn]<100,ylo[nn+1]<100,yhi[nn+1]<100,yhi[nn]<100]
   polyfill, xx, yy, color=13
 end

  x   = year
  ylo = flow_rate0_epan
  yhi = fhi_rate0_epan
 for nn = 0, n_elements(year)-2 do begin
   xx = [x[nn],x[nn+1],x[nn+1],x[nn]]
   yy = [ylo[nn]<100,ylo[nn+1]<100,yhi[nn+1]<100,yhi[nn]<100]
   polyfill, xx, yy, color=13, /line_fill, spacing=0.1
 end

  x   = year
  ylo = flow_rate0_rjpn
  yhi = fhi_rate0_rjpn
 for nn = 0, n_elements(year)-2 do begin
   xx = [x[nn],x[nn+1],x[nn+1],x[nn]]
   yy = [ylo[nn]<100,ylo[nn+1]<100,yhi[nn+1]<100,yhi[nn]<100]
   polyfill, xx, yy, color=13, /line_fill, orientation=90, spacing=0.1
 end

 oplot, Year, rate0_epan, color=1, line=1, thick=lthick
 oplot, Year, rate0_rjpn, color=1, line=2, thick=lthick
 oplot, Year, rate0_rjpb, color=1, line=0, thick=lthick

 oplot, Year, flow_rate0_epan, color=1, line=1, thick=thin
 oplot, Year, flow_rate0_rjpn, color=1, line=2, thick=thin
 oplot, Year, flow_rate0_rjpb, color=1, line=0, thick=thin

 oplot, Year, fhi_rate0_epan, color=1, line=1, thick=thin
 oplot, Year, fhi_rate0_rjpn, color=1, line=2, thick=thin
 oplot, Year, fhi_rate0_rjpb, color=1, line=0, thick=thin



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
 mid = where(newobs.lon gt -95.)
; mid = 77 ; OKEF, Georgia

 for m = 0, N_elements(f_na)-1 do begin
    out = site_pval( newobs[mid], newsim[mid], newbkg1[mid], newnat1[mid], $
                     newasi[mid], f_na=f_na[m], f_asia=f_asia[m] )
    if n_elements(out.a80) gt 1. then  future[m] = mean(out.a80,/nan) else $
    future[m] = out.a80
 end

; based on p90 statistic on 1x1 results
; for west
 baseline   = mean(pcur[mid].a80, /nan)
 background = mean(pbkg1[mid].a80, /nan)
 natural    = mean(pnat1[mid].a80, /nan)
 EPAdefault = mean(newobs[mid].epa_p90, /nan)

; future = [future, background]


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

 ; Future backgroud (low end)
 background = min(future)

 flow_dv_rjpb    = baseline - Lindgen(N) * ( baseline - background ) / (N - 1)
 flow_bext_rjpb  = 10.*exp(flow_dv_rjpb*0.1)
 flow_rbext_rjpb = (flow_bext_rjpb[0] - flow_bext_rjpb)

 flow_rate0_rjpn = rbext_rjpn      / flow_rbext_rjpb[N-1] * 100.
 flow_rate0_rjpb = flow_rbext_rjpb / flow_rbext_rjpb[N-1] * 100.
 flow_rate0_epan = rbext_epan      / flow_rbext_rjpb[N-1] * 100.

 ; Future backgroud (high end)
 background = max(future)

 fhi_dv_rjpb    = baseline - Lindgen(N) * ( baseline - background ) / (N - 1)
 fhi_bext_rjpb  = 10.*exp(fhi_dv_rjpb*0.1)
 fhi_rbext_rjpb = (fhi_bext_rjpb[0] - fhi_bext_rjpb)

 fhi_rate0_rjpn = rbext_rjpn     / fhi_rbext_rjpb[N-1] * 100.
 fhi_rate0_rjpb = fhi_rbext_rjpb / fhi_rbext_rjpb[N-1] * 100.
 fhi_rate0_epan = rbext_epan     / fhi_rbext_rjpb[N-1] * 100.

 print, Year[0], Year[ddd[0]], '   East     DV,          %'
 print, dv_epan[0], dv_epan[ddd[0]], dv_epan[0] - dv_epan[ddd[0]], rate0_epan[ddd[0]], ' epa'
 print, dv_rjpn[0], dv_rjpn[ddd[0]], dv_rjpn[0] - dv_rjpn[ddd[0]], rate0_rjpn[ddd[0]], ' natural'
 print, dv_rjpb[0], dv_rjpb[ddd[0]], dv_rjpb[0] - dv_rjpb[ddd[0]], rate0_rjpb[ddd[0]], ' backgroud'
 print, bext_rjpb[0]-bext_rjpb[N-1], ' US influence'
 print, fhi_dv_rjpb[0], fhi_dv_rjpb[ddd[0]], fhi_dv_rjpb[0]-fhi_dv_rjpb[ddd[0]], fhi_rate0_rjpb[ddd[0]], 'hi backgroud'
 print, flow_dv_rjpb[0], flow_dv_rjpb[ddd[0]], flow_dv_rjpb[0]-flow_dv_rjpb[ddd[0]], flow_rate0_rjpb[ddd[0]], 'hi backgroud'
 print, dv_rjpb[N-1], fhi_dv_rjpb[N-1], flow_dv_rjpb[N-1], ' backgroud deciview'

 ; plotting

 yrange = [3, 30]

 plot, Year, dv_epan, color=1, xrange=[2004,2064], xstyle=9, $
    ystyle=9, position = pos[*,2], thick=lthick, $
    yrange=yrange, charsize=1.4, line=1, xticklen=0.05

  x   = year
  ylo = fhi_dv_rjpb
  yhi = flow_dv_rjpb
 for nn = 0, n_elements(year)-2 do begin
   xx = [x[nn],x[nn+1],x[nn+1],x[nn]]
   yy = [ylo[nn],ylo[nn+1],yhi[nn+1],yhi[nn]]
   polyfill, xx, yy, color=13
 end

 oplot, Year, dv_epan, color=1, line=1, thick=lthick
 oplot, Year, dv_rjpn, color=1, line=2, thick=lthick
 oplot, Year, dv_rjpb, color=1, line=0, thick=lthick
 plots, [2018, 2018], yrange, color=1, line=0, thick=lthick*ffc

 oplot, Year, fhi_dv_rjpb, color=1, line=0, thick=thin
 oplot, Year, flow_dv_rjpb, color=1, line=0, thick=thin


 x0 = 0.32
 xd = [x0, x0+0.05]
 y0 = 0.13 & dy = 0.03
 y1 = y0-dy
 y2 = y1-dy
 y3 = y2-dy
 plots, xd, [y1,y1], color=1, line=0, thick=lthick, /normal
 plots, xd, [y2,y2], color=1, line=2, thick=lthick, /normal
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


 ;=======================
 ; emission reduction 
 ;=======================
 plot, Year, rate0_epan, color=1, line=1, thick=lthick, $
    Yrange=[0, 100], position = pos[*,3], $
    xrange=[2004,2064], Xstyle=9, ystyle=9, $
    Xtitle='Year', charsize=1.4, xticklen=0.05

  x   = year
  ylo = flow_rate0_rjpb
  yhi = fhi_rate0_rjpb
 for nn = 0, n_elements(year)-2 do begin
   xx = [x[nn],x[nn+1],x[nn+1],x[nn]]
   yy = [ylo[nn]<100,ylo[nn+1]<100,yhi[nn+1]<100,yhi[nn]<100]
   polyfill, xx, yy, color=13
 end

  x   = year
  ylo = flow_rate0_epan
  yhi = fhi_rate0_epan
 for nn = 0, n_elements(year)-2 do begin
   xx = [x[nn],x[nn+1],x[nn+1],x[nn]]
   yy = [ylo[nn]<100,ylo[nn+1]<100,yhi[nn+1]<100,yhi[nn]<100]
   polyfill, xx, yy, color=13, /line_fill, spacing=0.1
 end

  x   = year
  ylo = flow_rate0_rjpn
  yhi = fhi_rate0_rjpn
 for nn = 0, n_elements(year)-2 do begin
   xx = [x[nn],x[nn+1],x[nn+1],x[nn]]
   yy = [ylo[nn]<100,ylo[nn+1]<100,yhi[nn+1]<100,yhi[nn]<100]
   polyfill, xx, yy, color=13, /line_fill, orientation=90, spacing=0.1
 end

 oplot, Year, rate0_epan, color=1, line=1, thick=lthick
 oplot, Year, rate0_rjpn, color=1, line=2, thick=lthick
 oplot, Year, rate0_rjpb, color=1, line=0, thick=lthick
 plots, [2018, 2018], [0., 100], color=1, line=0, thick=lthick*ffc

 oplot, Year, flow_rate0_epan, color=1, line=1, thick=thin
 oplot, Year, flow_rate0_rjpn, color=1, line=2, thick=thin
 oplot, Year, flow_rate0_rjpb, color=1, line=0, thick=thin

 oplot, Year, fhi_rate0_epan, color=1, line=1, thick=thin
 oplot, Year, fhi_rate0_rjpn, color=1, line=2, thick=thin
 oplot, Year, fhi_rate0_rjpb, color=1, line=0, thick=thin


 xyouts, 0.32, 0.9, 'WEST', color=1, alignment=0.5, charsize=1.5, charthick=5,/normal
 xyouts, 0.75, 0.9, 'EAST', color=1, alignment=0.5, charsize=1.5, charthick=5,/normal

 aa = where(rate0_epan ge 100.)
 bb = where(rate0_rjpn ge 100.)
; print, year(aa), year(bb)


; XYOUTS, 0.55, 0.067, '2004', /normal, color=1, alignment=0.5, charsize=1.5
 if (!D.name eq 'PS') then $
   close_device

 
 End
