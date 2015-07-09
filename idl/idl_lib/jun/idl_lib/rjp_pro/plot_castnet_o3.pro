 function month_mean, Dinfo

  jday = Dinfo[0].jday

  Nsite= n_elements(Dinfo)

  jmon = jday2month(jday)

  mm   = jmon(uniq(jmon)) & time=mm
  nmon = n_elements(mm)

  ntag = n_tags(dinfo)
  name = tag_names(dinfo)

  For D = 0, ntag - 1 do begin
      fld = dinfo.(D)
      dim = size(fld)
      if dim[0] eq 1 then newfld = fld else begin
         newfld = fltarr(dim[2],12)

         For N = 0, dim[2]-1L do begin

             For M = 0, nmon  - 1L do begin
                 p = where(jmon eq mm[M])  ; search for the same month

                 if p[0] eq -1 then begin
                    newfld[N, mm[M]-1L] = -999.
                    goto, jump
                 end

                 s = reform(fld[P, N])    ; sample data for the same month
                 p = where(s gt 0.)       ; remove missing data

                 if p[0] eq -1 then begin
                    newfld[N, mm[M]-1L] = -999.
                    goto, jump
                 end

                 newfld[N, mm[M]-1L] = mean(s[p]) ; taking mean

                 jump:
             end
         end
      end

      if D eq 0 then newinfo = create_struct(name[d], newfld) else $
         newinfo = create_struct(newinfo, name[d], newfld)

  end

 return, newinfo

 end

;=================================================================
 function sync, obs, sim

   for D = 0, n_elements(sim)-1 do begin
       P = where(sim[D].siteid eq obs.siteid)

       if P[0] ne -1 then begin
          if n_elements(newdata) eq 0 then $
             newdata = sim(D) else $
             newdata = [newdata, sim(D)]
       end
   end

   return, newdata
 end

;=============================================================

 pro corr, imp

     mon = jday2month(imp[0].jday)
     jj  = where(mon ge 6 and mon le 8)

     Jday = imp[0].jday

     Rarr = 0.
     LON  = 0.
     LAT  = 0.
     ID   = 0.

     For D = 0, N_elements(imp)-1 do begin

       X = imp[D].omc[jj]
       Y = imp[D].k[jj]

       ; remove missing data
       p = where(x lt 0. or y lt 0., complement=c)

       if c[0] eq -1 then goto, jump
       if imp[d].lat lt 25. then goto, jump

       X = X[c]
       Y = Y[c]

       rma   = lsqfitgm(X, Y)
       slope = rma[0]
       const = rma[1]
       R     = rma[2]
       Rarr  = [Rarr, R]
       Lon   = [Lon, imp[D].lon]
       Lat   = [Lat, imp[D].lat]
       ID    = [ID, D]

       jump:
     End

  Rarr = Rarr[1:*]
  Lon  = Lon[1:*]
  Lat  = Lat[1:*]
  ID   = ID[1:*]

  @define_plot_size

 !P.multi=[0,2,2,0,0]

  Pos = cposition(2,2,xoffset=[0.1,0.1],yoffset=[0.1,0.1], $
        xgap=0.02,ygap=0.15,order=0)

  Mindata = 0.
  Maxdata = 1.

  C      = Myct_defaults()
  Bottom = C.Bottom
  Ncolor = 255L-Bottom
  Ndiv   = 7
  Format = '(F4.1)'
  Unit   = 'R'
  csfac  = 1.2

  C_colors = bytscl( Rarr, Min=Mindata, Max=Maxdata, $
      	         Top = Ncolor) + Bottom

  ;========================
  limit = [25., -130., 50., -60.]
  LatRange = [ Limit[0], Limit[2] ]
  LonRange = [ Limit[1], Limit[3] ]

  ;---- observation----
  map_set, 0, 0, color=1, /contine, limit=limit, /usa,$
    position=pos[*,0]

  Map_Labels, LatLabel, LonLabel,              $
         Lats=Lats,         LatRange=LatRange,     $
         Lons=Lons,         LonRange=LonRange,     $
         NormLats=NormLats, NormLons=NormLons,     $
         /MapGrid,          _EXTRA=e

  XYOutS, NormLats[0,*], NormLats[1,*], LatLabel, $
          Align=1.0, Color=1, /Normal, charsize=csfac, charthick=charthick

  XYOutS, NormLons[0,*], NormLons[1,*], LonLabel, $
          Align=0.5, Color=1, /Normal, charsize=csfac, charthick=charthick


  plots, lon, Lat, color=c_colors, psym=8, symsize=symsize

  ;---- observation----

  q = where(rarr ge 0.7, complement=s)

  map_set, 0, 0, color=1, /contine, limit=limit, /usa,$
    position=pos[*,1], /noerase

  Map_Labels, LatLabel, LonLabel,              $
         Lats=Lats,         LatRange=LatRange,     $
         Lons=Lons,         LonRange=LonRange,     $
         NormLats=NormLats, NormLons=NormLons,     $
         /MapGrid,          _EXTRA=e

;  XYOutS, NormLats[0,*], NormLats[1,*], LatLabel, $
;          Align=1.0, Color=1, /Normal, charsize=csfac, charthick=charthick

  XYOutS, NormLons[0,*], NormLons[1,*], LonLabel, $
          Align=0.5, Color=1, /Normal, charsize=csfac, charthick=charthick


  plots, lon[q], Lat[q], color=c_colors[q], psym=8, symsize=symsize

  ; colorbar
  dx = pos[2,0]-pos[2,0]*0.8
  CBPosition = [pos[0,0]+dx,pos[1,0]-0.06,pos[2,1]-dx,pos[1,0]-0.03]
  ColorBar, Max=maxdata,     Min=mindata,    NColors=Ncolor,     $
    	      Bottom=BOTTOM,   Color=C.Black,  Position=CBPosition, $
    		Unit=Unit,       Divisions=Ndiv, Log=Log,             $
	      Format=Format,   Charsize=csfac,       $
    	      C_Colors=CC_Colors, C_Levels=C_Levels, Charthick=charthick, _EXTRA=e


  yrange = [0., 6]
  array = composite(imp[id[s]].omc, /first)

  ytitle = 'OMC Concentration (!4l!3g m!u-3!n)'
  xtitle = 'Julian day of year 2004'
  plot, jday, array.mean, color=1, xstyle=1, xrange=[0.,365.], $
    yrange=yrange, psym=-2, symsize=symsize, thick=thin,              $
    ystyle=8, charthick=charthick,    $
    ytitle=ytitle, position=pos[*,2], charsize=charsize, $
    xtitle=xtitle, Yticks=6, yminor=1

  oplot, [jday[min(jj)],jday[min(jj)]], yrange, color=1
  oplot, [jday[max(jj)],jday[max(jj)]], yrange, color=1
  xyouts, 15, 5, 'R < 0.7', color=1, charsize=charsize, $
   charthick=charthick

  ylabel = strarr(6)
  ylabel[*] = ' '

  Axis, YAxis=1, Yrange=[0.,0.1], /Save, Yticks=5, $
   color=2, charsize=charsize, charthick=charthick, $
   ytickname=Ylabel, yminor=1

  array = composite(imp[id[s]].k, /first)
  oplot, jday, array.mean, color=2, psym=4


  ; 2nd plot

  array = composite(imp[id[q]].omc, /first)

  ylabel = strarr(7)
  ylabel[*] = ' '
  plot, jday, array.mean, color=1, psym=-2, symsize=symsize, thick=thin,  $
    xstyle=1, xrange=[0.,365.], $
    ystyle=8, yrange=yrange, YTicks=6, ytickname=Ylabel, $
    charthick=charthick,  position=pos[*,3],             $
    xtitle=xtitle, charsize=charsize, yminor=1

  oplot, [jday[min(jj)],jday[min(jj)]], yrange, color=1
  oplot, [jday[max(jj)],jday[max(jj)]], yrange, color=1
  xyouts, 15, 5, 'R > 0.7', color=1, charsize=charsize, $
   charthick=charthick

  Axis, YAxis=1, Yrange=[0.,0.1], /Save, ytitle='K Concentration (!4l!3g m!u-3!n)', $
   color=2, charsize=charsize, charthick=charthick, yminor=1
  array = composite(imp[id[q]].k, /first)
  oplot, jday, array.mean, color=2, psym=4


 end
;======================================================================

  @define_plot_size


   if n_elements(cas) eq 0 then begin
      cas = cast_o3_daily(year=2004L, /aft) ; daily mean conc
;      cas_m = month_mean( cas )

      base = rd_gc('./data_castnet/out_trop/*_aft.txt')
      base = sync(cas, base)

      nofire= rd_gc('./data_castnet/out_nofire/*_aft.txt')
      nofire=sync(cas, nofire)
   end

  if !D.name eq 'PS' then $
    open_device, file='o3_tseries.ps', /color, /ps, /landscape


    idw = where(cas.lon lt -95. and cas.lat gt 35.)
    ide = where(cas.lon gt -95. and cas.lat lt 35.)

    @define_plot_size

    id = where(cas.lat gt 40.)
    Jday = cas[0].jday
    mon  = jday2month(Jday)
    jj   = where(mon ge 6 and mon le 8)

    multipanel, col=2, row=1 
    Pos = cposition(2,1,xoffset=[0.1,0.1],yoffset=[0.35,0.35], $
        xgap=0.1,ygap=0.02,order=0)


  tau0 = nymd2tau(20040101L)
  ddd  = [160L,180L,200L,220L,240L]
  nymd = tau2yymmdd((ddd - 1L) * 24L + tau0[0])
  ttt  = strtrim(nymd.month,2) + '/' + strtrim(nymd.day,2)
  xlabel = ttt
  yrange = [0.,70.]
  xrange = [Jday[min(jj)], Jday[max(jj)]]

    mindata = 0.
    maxdata = 40.
    cbformat = '(I3)'
    ndiv    = 6
    cfac    = 2


    id = [59]

    dat = cas[id].o3[jj]
    fld = composite(dat)
    print, quantile(fld.mean,[0.1,0.5,0.9])
    comment = ' '
    data    = fld.mean

  for d = 0, n_elements(id)-1 do begin
    erase

    print, id[d], cas[id[d]].siteid
    title = cas[id[d]].name+', '+cas[id[d]].state; +strtrim(id[d])

    str  = cas[id[d]]
    dat  = cas[id[d]].o3[jj]
    data = mean(dat[*],/nan)

    mapplot, data, str, mindata=mindata, maxdata=maxdata, pos=pos[*,0],    $
    cfac=cfac,cbformat=cbformat, comment=comment, limit=limit,             $
    ndiv=ndiv, nogxlabel=nogxlabel, nogylabel=nogylabel, commsize=1.2, /cbar, $
    title=title

;    array = composite( dat, /first )
;    data  = array.mean
    data  = reform(dat[*])
    data  = chk_negative(chk_zero(data))
    plot, Jday[jj], data, color=1, psym=-2, pos=pos[*,1],    $
          symsize=symsize, thick=thick, charthick=charthick, $
          xrange=xrange, xtickinterval=20,  xstyle=1,        $
          yrange=yrange, ystyle=1,                           $
          ytitle=ytitle, charsize=charsize, $
          XTickName=xlabel, xticks=n_elements(xlabel)-1

    data  = reform(base[id[d]].ox)
    data  = chk_negative(chk_zero(data))
    jjjj  = base[0].jday

    oplot, jjjj, data, color=4, line=0, thick=dthick

    data  = reform(nofire[id[d]].ox)
    data  = chk_negative(chk_zero(data))
    jjjj  = base[0].jday

    oplot, jjjj, data, color=2, line=0, thick=dthick

    halt
   end


  if !D.name eq 'PS' then close_device

;    YTicks=n_elements(Ylabel-1), ytickname=Ylabel,             $
;    XTicks=n_elements(Xlabel-1), xtickname=xlabel
stop


    corr, imp
    


  End
