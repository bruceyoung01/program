;========================================
 function id_find, str

 lat   = str.lat
 lon   = str.lon
 state = str.state

 ID    = indgen(n_elements(str))
; ID    = where(lat gt 40. and lon le -95.)

 NW = ['WA','OR']
 NO = ['CA']
 

 return, id

 end

;=========================================

 pro process, str, spec, data=data, time=time

  NAMES  = tag_names(str)
  SN     = where(names eq spec)
  IF SN[0] eq -1 then stop

  Jday   = str[0].jday
  ID     = id_find( str )
  Data   = str[ID].(SN)
  array  = composite(Data, /first)

  ; daily
  time   = jday
  data   = array.mean

  ; monthly
  time   = indgen(12)+1L
  data   = daily2monthly(array.mean, jday)

 return

 end

;==============================================================

 if N_elements(imp01) eq 0 then begin

    restore, filename='/users/ctm/rjp/Data/IMPROVE/Raw_data/daily_2001.sav'
    restore, filename='/users/ctm/rjp/Data/IMPROVE/Raw_data/daily_2002.sav'
    restore, filename='/users/ctm/rjp/Data/IMPROVE/Raw_data/daily_2003.sav'
    restore, filename='/users/ctm/rjp/Data/IMPROVE/Raw_data/daily_2004.sav'

    imp01 = knon( imp01 )
    imp02 = knon( imp02 )
    imp03 = knon( imp03 )
    imp04 = knon( imp04 )

  end


  multipanel, row=1, col=1

  Pos = cposition(1,1,xoffset=[0.15,0.1],yoffset=[0.15,0.15], $
        xgap=0.15,ygap=0.15,order=1)

  if !D.name eq 'PS' then $
    open_device, file='tc_interannual.ps', /color, /ps, /landscape



  SPEC   = 'CARB'

  @define_plot_size
;  xrange = [150, 240]
  xrange = [1,12]
  yrange = [0.,3]
  ytitle = 'TC [!4l!3gC m!u-3!n]'
  xtitle = 'Month'
  XTicks = 11
  Xminor = 1
  Xtickname = ['J','F','M','A','M','J', $
               'J','A','S','O','N','D']

  process, imp01, spec, data=data, time=time
  plot, time, data, color=1, line=0, position=pos,         $
        thick=dthick, symsize=symsize,                     $
        xstyle=2, xrange=xrange, xtitle=xtitle,            $
        XTicks=Xticks, Xminor=Xminor, Xtickname=Xtickname, $
        ystyle=1, yrange=yrange, ytitle=ytitle,            $
        Yticks=YTicks, yminor=1,                           $
        charthick=charthick, charsize=charsize,            $
        title=title

  process, imp02, spec, data=data, time=time
  oplot, time, data, color=2, line=0, thick=dthick


  process, imp03, spec, data=data, time=time
  oplot, time, data, color=3, line=0, thick=dthick

  process, imp04, spec, data=data, time=time
  oplot, time, data, color=4, line=0, thick=dthick

  dx   = (!x.crange[1]-!y.crange[0])*0.07
  dy   = (!y.crange[1]-!y.crange[0])*0.07
  xlab = [!x.crange[0]+dx*2,!x.crange[0]+dx*3]
  ylab = [!y.crange[1],!y.crange[1]]
  
  legend = ['2001','2002','2003','2004']
  for i = 0, n_elements(legend)-1 do $
    xyouts, xlab[0], ylab[1]-dy*(i+1.2), legend[i], color=1, alignment=1, $
    charsize=charsize, charthick=charthick

  for i = 0, n_elements(legend)-1 do $
    plots, xlab, ylab-dy*(i+1), color=i+1, line=0, thick=dthick

  if !D.name eq 'PS' then close_device

End
