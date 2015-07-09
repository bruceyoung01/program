

 pro map_tseries, imp, gc, gc2, pos=pos, ytitle=ytitle, title=title, $
  plotsize=plotsize

  @define_plot_size

  if n_elements(plotsize) eq 0 then plotsize=symsize

  mon = jday2month(imp[0].jday)
  jj  = where(mon ge 7 and mon le 8)

  Jday = imp[0].jday

  Rarr = imp.r_k_omc
  Lon  = imp.Lon
  Lat  = imp.lat

  tau0= nymd2tau(20040101L)
  ddd = [20040709L,20040711L,20040720L,20040721L,20040722L,20040725L]
  ddd = (nymd2tau(ddd) - tau0[0])/24L + 1L

 ;============================================
 ; 1) Map plot of correlations
 ;============================================
  Rcri    = 0.8 & CR = strtrim(string(Rcri, format='(F3.1)'),2)


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

  map_set, 0, 0, color=1, /contine, limit=limit, /usa,$
    position=pos[*,0], /noerase

  Map_Labels, LatLabel, LonLabel,              $
         Lats=Lats,         LatRange=LatRange,     $
         Lons=Lons,         LonRange=LonRange,     $
         NormLats=NormLats, NormLons=NormLons,     $
         /MapGrid,          _EXTRA=e

  XYOutS, NormLats[0,*], NormLats[1,*], LatLabel, $
          Align=1.0, Color=1, /Normal, charsize=csfac, charthick=charthick

  XYOutS, NormLons[0,*], NormLons[1,*], LonLabel, $
          Align=0.5, Color=1, /Normal, charsize=csfac, charthick=charthick


  ; Sites with R is higher than Rcri
  plots, lon, Lat, color=c_colors, psym=8, symsize=plotsize

  ; colorbar
  dx = (pos[2,0]-pos[0,0])*0.1
  CBPosition = [pos[0,0]+dx,pos[1,0]-0.06,pos[2,0]-dx,pos[1,0]-0.03]
  ColorBar, Max=maxdata,     Min=mindata,    NColors=Ncolor,     $
    	      Bottom=BOTTOM,   Color=C.Black,  Position=CBPosition, $
    		Unit=Unit,       Divisions=Ndiv, Log=Log,             $
	      Format=Format,   Charsize=csfac,       $
    	      C_Colors=CC_Colors, C_Levels=C_Levels, Charthick=charthick, _EXTRA=e

 ;============================================
 ; 1-1) Plot time series aerosol concentrations 
 ;============================================
  ocrange = [0, 10]
  YTicks  = ocrange[1]
  xrange  = [Jday[min(jj)], Jday[max(jj)]]
  xrange  = [180, Jday[max(jj)]]

  ; improve observations
  Data   = imp.omc
  array  = composite(Data, /first)

  xtitle = 'Julian day of year 2004'
  plot, jday, array.mean, color=1, xstyle=1, xrange=xrange,   $
    yrange=ocrange, psym=-8, symsize=symsize, thick=thin,     $
    ystyle=1, charthick=charthick,                            $
    ytitle=ytitle, position=pos[*,1], charsize=charsize,      $
    xtitle=xtitle, Yticks=Yticks, yminor=1, title=title


  Data  = imp.ec*10.
  array = composite(Data, /first)
  oplot, jday, array.mean, color=2, psym=-2

  ; geos-chem simulation of omc 
  fac    = 1.4
  Model  = (gc.ocpi+gc.ocpo)*fac + gc.soa1+gc.soa2+gc.soa3
  M_jday = gc[0].jday

  array = composite(Model, /first)
  oplot, m_jday, array.mean, color=2, line=0, thick=dthick

  ; geos-chem sensitivity simulation of omc 
  Model  = (gc2.ocpi+gc2.ocpo)*fac + gc2.soa1+gc2.soa2+gc2.soa3
  M_jday = gc2[0].jday

  array = composite(Model, /first)
  oplot, m_jday, array.mean, color=4, line=0, thick=dthick


; vertical line for JJA
  oplot, [jday[min(jj)],jday[min(jj)]], ocrange, color=1
  oplot, [jday[max(jj)],jday[max(jj)]], ocrange, color=1

;  xyouts, 15, 5, 'R < '+CR, color=1, charsize=charsize, $
;   charthick=charthick

 ; potassium

;  ylabel = strarr(YTicks+1)
;  ylabel[*] = ' '

;  Axis, YAxis=1, Yrange=ocrange*0.01, /Save, Yticks=Yticks, $
;   color=2, charsize=charsize, charthick=charthick, $
;   ytickname=Ylabel, yminor=1

  data  = (imp.k - (imp.fe*0.6))*100.
  array = composite(data, /first)
  oplot, jday, array.mean, color=2, psym=4

 end


;======================================================================
  @define_plot_size


   if n_elements(imp) eq 0 then begin
      imp   = get_improve_daily( 2004L )
      imp   = k_corr( imp, 'OMC' )
      imp   = k_corr( imp, 'EC' )
      imp_m = month_mean( imp )
      gc    = rd_gc()
      gc    = sync( imp, gc )
      gc2   = rd_gc(/nofire)
      gc2   = sync( imp, gc2 )
   end


  Rarr = imp.r_k_omc
  Lon  = imp.Lon
  Lat  = imp.lat

  Rcri = 0.5 & CR = strtrim(string(Rcri, format='(F3.1)'),2)
  q    = where(rarr ge Rcri and lat ge 30. and lon gt -120., complement=s)
;  q    = where(rarr lt 0.3 and lat ge 40. and lon gt -90., complement=s)

  q = 0.
  state = ['ND','SD','WI','MN','MI','OH','IN','IL','IA']
  for i = 0, n_elements(state)-1 do begin
      t = where(imp.state eq state[i])
      if t[0] ne -1 then  q = [q, t]
  end
  q = q[1:*]

  q    = where(rarr ge Rcri and lat ge 30. and lon gt -90., complement=s)


  if !D.name eq 'PS' then $
    open_device, file='omc_tseries.ps', /color, /ps, /landscape

    !P.multi=[0,2,2,0,0]

    Pos = cposition(2,2,xoffset=[0.1,0.1],yoffset=[0.1,0.1], $
        xgap=0.1,ygap=0.15,order=1)

    ytitle = 'Concentration (!4l!3g m!u-3!n)'

    id = q
    For D = 0, N_elements(id)-1 do begin
       map_tseries, imp[id], gc[id], gc2[id], pos=pos[*,0:1], ytitle=ytitle

       CR1 = string(imp[id[d]].r_k_omc, format='(F3.1)')
       CR2 = string(imp[id[d]].r_k_ec, format='(F3.1)')

       title = 'R = '+strtrim(CR1,2)+','+strtrim(CR2,2)
       map_tseries, imp[id[d]], gc[id[d]], gc2[id[d]],  $
          pos=pos[*,2:3], ytitle=' ', title=title, plotsize=3
 
       halt
       erase
    end
    
  if !D.name eq 'PS' then close_device


  End
