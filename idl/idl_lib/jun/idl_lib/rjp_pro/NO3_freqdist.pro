;=======================================================================

 if n_elements(obs) eq 0 then begin
    sim = get_model_day_improve()
    obs = get_improve_dayly()
 newsim = syncro( sim, obs )

 endif

 spec = 'NO3'

 W = Where(obs.lon le -95.)
 E = Where(obs.lon gt -95.)

 Undefine, yrangee
 Undefine, yrangew


 soil = makevector(obs.soil)
 na   = makevector(obs.na)

 id   = where(na lt 0.5)

 no3o = makevector(obs.no3)
 no3o = no3o[id]
 no3s = makevector(newsim.nit)
 no3s = no3s[id]

          d1W = chk_undefined(no3o)
          d2W = chk_undefined(no3s)

          d1E = chk_undefined(makevector(obs.no3))
          d2E = chk_undefined(makevector(newsim.nit))

          MinDw=0.0001
          MinDe=0.0001
          MaxDw=3.
          MaxDe=3.
          yrangew = [0.,3]
          yrangee = [0.,3]


 Xtitle=Spec+' [!4l!3g m!u-3!n]'
 p = 0.80

 @define_plot_size
 if !D.name eq 'PS' then $
   open_device, file=spec+'_dist.ps', /color, /ps, /portrait,  $
      xoffset=0.5, yoffset=0.5, xsize=7, ysize=10.

 !P.multi=[0,1,2,0,0]

 Pos = cposition(1,2,xoffset=[0.1,0.1],yoffset=[0.05,0.1], $
       xgap=0.1,ygap=0.12,order=0)

 Nbins = 500.
 
;====Observation at IMPROVE (black solid) in West====
 o = histo( d1w, p, MinD=MinDw, MaxD=MaxDw, Nbins=Nbins, pos=Pos[*,0], $
        color=1, line=0, Xtitle=Xtitle, $
        Title=Spec+' at IMPROVE in the West (<95!uo!nW)', $
        yrange=yrangew )
 ; Simulation (blue dotted)
 s = histo( d2w, p, MinD=MinDw, MaxD=MaxDw, Nbins=Nbins,  /Oplot, $
        color=4, line=1 )

;=======Label=========
 xrange=[MaxDw*0.25,MaxDw*0.35]
 yval  = max(yrangew[1])*0.8
 dy    = max(yrangew[1])/8.
 plots, xrange, [yval,yval]-1*dy, color=1, line=0, thick=thick
 plots, xrange, [yval,yval]-2*dy, color=4, line=1, thick=thick

 xyouts, xrange[1]*1.1, yval, '(Mean, Median)', color=1, $
         charsize=charsize, charthick=charthick

  string='Observations ('+string(o.mean,format='(f4.2)')+$
         ', '+string(o.median,format='(f4.2)')+')'
  xyouts, xrange[1]*1.1, yval-dy, string, color=1, charthick=charthick,$
          charsize=charsize

  string='Model ('+string(s.mean,format='(f4.2)')+$
         ', '+string(s.median,format='(f4.2)')+')'
  xyouts, xrange[1]*1.1, yval-2*dy, string, color=1, charthick=charthick,$
          charsize=charsize

;=====Observation at IMPROVE (black solid) in East=======
 o = histo( d1e, p, MinD=MinDe, MaxD=MaxDe, Nbins=Nbins, pos=Pos[*,1], $
        color=1, line=0, Xtitle=Xtitle, $
        Title=Spec+' at IMPROVE in the East (>95!uo!nW)', $
        Yrange=Yrangee )

 ; Simulation (blue dotted)
 s = histo( d2e, p, MinD=MinDe, MaxD=MaxDe, Nbins=Nbins,  /Oplot, $
        color=4, line=1 )

;=======Label=========
 xrange=[MaxDe*0.25,MaxDe*0.35]
 yval  = max(yrangee[1])*0.8
 dy    = max(yrangee[1])/8.
 plots, xrange, [yval,yval]-1*dy, color=1, line=0, thick=thick
 plots, xrange, [yval,yval]-2*dy, color=4, line=1, thick=thick

 xyouts, xrange[1]*1.1, yval, '(Mean, Median)', color=1, $
         charsize=charsize, charthick=charthick


  string='Observations ('+string(o.mean,format='(f4.2)')+$
         ', '+string(o.median,format='(f4.2)')+')'
  xyouts, xrange[1]*1.1, yval-dy, string, color=1, charthick=charthick,$
          charsize=charsize

  string='Model ('+string(s.mean,format='(f4.2)')+$
         ', '+string(s.median,format='(f4.2)')+')'
  xyouts, xrange[1]*1.1, yval-2*dy, string, color=1, charthick=charthick,$
          charsize=charsize


 if !D.name eq 'PS' then close_device

 End
