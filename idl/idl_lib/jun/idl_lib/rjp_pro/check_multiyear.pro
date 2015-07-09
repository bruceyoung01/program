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

    dat02 = sync( imp01, imp02 )
    dat01 = sync( dat02, imp01 )
    dat03 = sync( dat01, imp03 )
    dat04 = sync( dat01, imp04 )
  end
  
  multipanel, row=2, col=1

  Pos = cposition(1,2,xoffset=[0.1,0.1],yoffset=[0.1,0.1], $
        xgap=0.1,ygap=0.15,order=1)

  if !D.name eq 'PS' then $
    open_device, file='omc_2001vs2004.ps', /color, /ps, /portrait

  month = [6,7,8]
  Jday = dat01[0].jday
  mon  = jday2month(Jday)

  jj   = -1.
  For N = 0, N_elements(month)-1 do jj = [jj, where( mon eq month[N] ) ]
  jj   = jj[1:*]

  spec = 'OMC'
  xrange=[0.,5]
  yrange=[0.,5]

  d_omc_01 = composite(dat01.omc)
  d_omc_04 = composite(dat04.omc)
  aaa = chk_zero(d_omc_01.mean)
  bbb = chk_zero(d_omc_04.mean)

  title='OMC at 134 IMPROVE sites: 2001 vs. 2004'
  xtitle='Concentration (!4l!3g m!u-3!n) for 2001'
  ytitle='Concentration (!4l!3g m!u-3!n) for 2004'
  scatter, aaa, bbb, title=title, xtitle=xtitle, $
    ytitle=ytitle, pos=pos[*,0], xrange=xrange, yrange=yrange


  ; northeast
  m = where(dat01.lon gt -85. and dat01.lat gt 40.) 
  d_omc_01 = composite(dat01[m].omc)
  d_omc_04 = composite(dat04[m].omc)
  aaa = chk_zero(d_omc_01.mean)
  bbb = chk_zero(d_omc_04.mean)

  title='OMC at 13 IMPROVE sites in NE: 2001 vs. 2004'
  xtitle='Concentration (!4l!3g m!u-3!n) for 2001'
  ytitle='Concentration (!4l!3g m!u-3!n) for 2004'
  scatter, aaa, bbb, title=title, xtitle=xtitle, $
    ytitle=ytitle, pos=pos[*,1], xrange=xrange, yrange=yrange

  if !D.name eq 'PS' then close_device

End
