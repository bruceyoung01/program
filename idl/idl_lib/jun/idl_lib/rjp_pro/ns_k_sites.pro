;==============================================================================

 @define_plot_size

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

  if !D.name eq 'PS' then $
    open_device, file='nsK_sites_season.ps', /color, /ps, /landscape


  spec     = 'KNON'
  specname = strupcase(spec)
  NAMES    = tag_names(imp01)
  N        = where(NAMES eq specname)

;  multipanel, row=2, col=4
  Pos = cposition(4,2,xoffset=[0.1,0.1],yoffset=[0.1,0.1], $
        xgap=0.015,ygap=0.15,order=0)

  str = dat01

  jday = str[0].jday
  ID  = where(str.lon gt -135.)
  mindata = 0.
  maxdata = 0.1
  cbformat = '(F5.3)'
  cfac    = 3.

  ID = sort(str.lon)

  ID = [132,131,0,109]
  ytitle='ns-K (!4l!3g m!u-3!n)'
  null  =' '

  ytag   = ['0','0.02','0.04','0.06','0.08','0.1']
  ynull  = [' ',' ',' ',' ',' ',' ']
 
  xlabel = ['6',' ','18',' ','30',' ','42',' ']
  names = ['Yosemite, CA', 'Yellowstone, WY', $
           'Acadia, ME', 'Sipsy Wild., AL']
  erase
  For D = 0, N_elements(ID)-1 do begin

    data = str[ID[D]].(N)
    tser = daily2monthly( data, jday, Undef='NaN' )
    pk   = where(data le 0.)
    if pk[0] ne -1 then data[pk] = 'NaN'
    fld  = mean(data, /NaN)

    thisDat = str[ID[D]]
    siteID  = names[D]
    title = siteID+'!C(' $
          + strmid(strtrim(round(thisDat.lat),2),0,4) + 'N, '  $
          + strmid(strtrim(round(thisDat.lon),2),1,4) + 'W)'

    if D eq 0 then begin
       ytitle=ytitle 
       ylabel=ytag
    end else begin
       ytitle=null
       ylabel=ynull
    end
    
    position = pos[*,D]

    data = dat01[ID[D]].(N)
    tser = daily2monthly( data, jday, Undef='NaN' )
    
    data = dat02[ID[D]].(N)
    tser = [tser, daily2monthly( data, jday, Undef='NaN' )]

    data = dat03[ID[D]].(N)
    tser = [tser, daily2monthly( data, jday, Undef='NaN' )]

    data = dat04[ID[D]].(N)
    tser = [tser, daily2monthly( data, jday, Undef='NaN' )]


    plot, indgen(48)+1L, tser, color=1, pos=position, xstyle=1, psym=-1, $
       yrange = [mindata, maxdata], thick=dthick,  xminor=1, $
       xticklen=0.03, xrange=[1,48], xtickinterval=6, xtitle='month', $
       charthick=charthick, xcharsize=charsize, ytitle=ytitle, $
       YTickName=ylabel, yticks=n_elements(ylabel)-1, ycharsize=charsize, $
       XTickName=xlabel, xticks=n_elements(xlabel)-1
       
    xyouts, 24, 0.085, title, color=1, charsize=charsize, charthick=charthick, $
       alignment=0.5
    print, title

  End

  if !D.name eq 'PS' then close_device

end
