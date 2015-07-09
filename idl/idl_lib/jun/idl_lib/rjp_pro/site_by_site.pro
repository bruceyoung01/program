;==============================================================================

 @define_plot_size

 if N_elements(imp01) eq 0 then begin

    restore, filename='/users/ctm/rjp/Data/IMPROVE/Raw_data/daily_2001.sav'
    restore, filename='/users/ctm/rjp/Data/IMPROVE/Raw_data/daily_2002.sav'
    restore, filename='/users/ctm/rjp/Data/IMPROVE/Raw_data/daily_2003.sav'
    restore, filename='/users/ctm/rjp/Data/IMPROVE/Raw_data/daily_2004.sav'
    restore, filename='nsk_ibf.sav'

    imp01 = knon( imp01 )
    imp02 = knon( imp02 )
    imp03 = knon( imp03 )
    imp04 = knon( imp04 )

    dat02 = sync( imp01, imp02 )
    dat01 = sync( dat02, imp01 )
    dat03 = sync( dat01, imp03 )
    dat04 = sync( dat01, imp04 )
  end

  if !D.name eq 'PS' then $
    open_device, file='KNON_sites_season.ps', /color, /ps, /portrait


  spec     = 'KNON'
  specname = strupcase(spec)
  NAMES    = tag_names(imp01)
  N        = where(NAMES eq specname)

  multipanel, row=2, col=1
  Pos = cposition(1,2,xoffset=[0.15,0.1],yoffset=[0.1,0.1], $
        xgap=0.1,ygap=0.15,order=0)

  str = dat01

  jday = str[0].jday
  ID  = where(str.lon gt -135.)
  mindata = 0.
  maxdata = 0.1
  cbformat = '(F5.3)'
  cfac    = 3.

  ID = sort(str.lon)

;  ID = [1,2]

  For D = 0, N_elements(ID)-1 do begin

    erase

    data = str[ID[D]].(N)
    tser = daily2monthly( data, jday, Undef='NaN' )
    pk   = where(data le 0.)
    if pk[0] ne -1 then data[pk] = 'NaN'
    fld  = mean(data, /NaN)

    thisDat = str[ID[D]]
    siteID  = thisDat.siteid
    title = siteID+'!C(' $
          + strmid(strtrim(round(thisDat.lat),2),0,4) + 'N, '  $
          + strmid(strtrim(round(thisDat.lon),2),1,4) + 'W)'

;    newpos = [pos[0,0], pos[1,0], pos[2,1], pos[3,0]]
    newpos = pos[*,0]
    mapplot, fld, str[ID[D]], mindata=mindata, maxdata=maxdata*0.3, pos=newpos, $
     cfac=cfac,cbformat=cbformat, comment=comment,          $
     discrete=discrete, ndiv=ndiv, /cbar, nogxlabel=nogxlabel, $
     nogylabel=nogylabel, unit='ug/m3', title=title

    data = dat01[ID[D]].(N)
    tser = daily2monthly( data, jday, Undef='NaN' )
    
    data = dat02[ID[D]].(N)
    tser = [tser, daily2monthly( data, jday, Undef='NaN' )]

    data = dat03[ID[D]].(N)
    tser = [tser, daily2monthly( data, jday, Undef='NaN' )]

    data = dat04[ID[D]].(N)
    tser = [tser, daily2monthly( data, jday, Undef='NaN' )]

    tser = tser-nsk_ibf[ID[D]]
    plot, indgen(48)+1L, tser, color=1, pos=pos[*,1], xstyle=1, psym=-1, $
       yrange = [mindata, maxdata], thick=dthick,  xminor=6, $
       xticklen=0.05, xrange=[1,48], xtickinterval=6, xtitle='month', $
       charthick=charthick, charsize=charsize, ytitle='nsK Conc. (ug/m3)'

;    qqnorm, tser, position=pos[*,3], yrange=[mindata, maxdata], xrange=[-3,3], $
;       psym=1, nogylab=nogylab, ylab=ylab, xlab=xlab, nogxlab=nogxlab, /qline

     halt
  End

  if !D.name eq 'PS' then close_device

end
