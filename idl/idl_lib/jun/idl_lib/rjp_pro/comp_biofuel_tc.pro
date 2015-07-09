
 function id_find, fld


  R    = fld.r  ; correlation
  ID   = where( R ge 0.7 ) 

;  ID   = Lindgen(N_elements(fld.r))

  return, id

 end

;==============================================================


 pro plot2d, month, str, specname, pos=pos, cbar=cbar, $
     mindata=mindata, maxdata=maxdata, cbformat=cbformat, $
     nogxlabel=nogxlabel, nogylabel=nogylabel, comment=comment

  specname = strupcase(specname)
  NAMES    = tag_names(str)
  N        = where(NAMES eq specname)

  if N eq -1 then message, 'there is no matched species', specname

  Jday = str[0].jday
  mon  = jday2month(Jday)

  jj   = -1.
  For D = 0, N_elements(month)-1 do jj = [jj, where( mon eq month[D] ) ]
  jj   = jj[1:*]

  data = str.(N)[jj]
  
  data = composite(data)
  fld  = data.mean

  mapplot, fld, str, mindata=mindata, maxdata=maxdata, pos=pos, $
   cfac=cfac,cbformat=cbformat, comment=comment,          $
   discrete=discrete, ndiv=ndiv, cbar=cbar, nogxlabel=nogxlabel, $
   nogylabel=nogylabel

 end

;==============================================================================
 function process, month, str, specname, bkgn=bkgn

  specname = strupcase(specname)
  NAMES    = tag_names(str)
  N        = where(NAMES eq specname)

  if N[0] eq -1 then message, 'there is no matched species', specname

  Jday = str[0].jday
  mon  = jday2month(Jday)

  jj   = -1.
  For D = 0, N_elements(month)-1 do jj = [jj, where( mon eq month[D] ) ]
  jj   = jj[1:*]

  data = str.(N)[jj]
;  data = composite(data)

  return, data

end

;==============================================================================
 function find_min, str, specname

  specname = strupcase(specname)
  NAMES    = tag_names(str)
  N        = where(NAMES eq specname)

  if N[0] eq -1 then message, 'there is no matched species', specname

  Jday = str[0].jday
  mon  = jday2month(Jday)

  bkgn = fltarr(N_elements(str))

  ; Search for the lowest values
  For D = 0, N_elements(str)-1 do begin
     D_KN = str[D].(N)
     M_KN = daily2monthly( D_KN, jday, Undef='NaN' )
;     bkgn[D] = min(M_KN, /NaN)                ; choose min value
    bkgn[D] = mean((m_kn(sort(m_kn)))[0:2])  ; choose mean of three smallest values

  End

  return, bkgn

end

;==============================================================================

 pro plot_min_max

  COMMON SHARE, dat, mdat

  @define_plot_size

  multipanel, col=2, row=1 
  Pos = cposition(2,1,xoffset=[0.1,0.1],yoffset=[0.35,0.35], $
        xgap=0.02,ygap=0.02,order=0)



  if !D.name eq 'PS' then $
    open_device, file='nsk_min_max.ps', /color, /ps, /landscape

  winter = [1,2,12]
  summer = [6,7,8]
  others = [3,4,5,9,10,11]

  corr = comp_corr( dat, ['KNON','CARB'], month=winter )

  C       = 1
  mindata = 10.
  maxdata = 130
  ndiv    = 7

  cbformat='(I3)'
  Names   = Tag_names(corr)

  ID = id_find(corr)

  XYOuts, 0.5, 0.85, Names[C], color=1, /normal, alignment=0.5, $
    charsize=charsize, charthick=charthick

  format  = '(f5.3)'
  limit   = [25., -127., 50., -60.]

  data      = corr.(C)[ID]
  nogylabel = 1
  position  = pos[*,0]
  cbar      = 1
  mapplot, data, dat[ID], mindata=mindata, maxdata=maxdata, pos=position,   $
   cfac=cfac,cbformat=cbformat, comment=comment, limit=limit,           $
   ndiv=ndiv, nogxlabel=nogxlabel, nogylabel=nogylabel, commsize=1.2,   $
   cbar=cbar

stop
;  xyouts, 0.12, 0.4, '(a)', /normal, color=1, charsize=charsize, charthick=charthick

    x = position[0]
    y = position[3]+0.01
    str = string(mean(data[idw],/nan),format=format)
    xyouts, x, y, str, color=1, charsize=charsize, /normal, alignment=0, $
    charthick=charthick

    x = position[2]
    y = position[3]+0.01
    str = string(mean(data[ide],/nan),format=format)
    xyouts, x, y, str, color=1, charsize=charsize, /normal, alignment=1, $
    charthick=charthick

  nsk_ibf = fld.mean
;  save, filename='nsk_bf.sav', nsk_ibf

  fld = composite(bkg, /first)
  print, quantile(fld.mean,[0.1,0.5,0.9])
  comment = '(a)!CBackground'
  data    = fld.mean
  nogylabel=0
  position = pos[*,0]
  mapplot, data, dat, mindata=mindata, maxdata=maxdata, pos=position, $
   cfac=cfac,cbformat=cbformat, comment=comment, limit=limit,           $
   ndiv=ndiv, nogxlabel=nogxlabel, nogylabel=nogylabel, commsize=1.2


;  xyouts, 0.525, 0.4, '(b)', /normal, color=1, charsize=charsize, charthick=charthick

    x = position[0]
    y = position[3]+0.01
    str = string(mean(data[idw],/nan),format=format)
    xyouts, x, y, str, color=1, charsize=charsize, /normal, alignment=0, $
    charthick=charthick

    x = position[2]
    y = position[3]+0.01
    str = string(mean(data[ide],/nan),format=format)
    xyouts, x, y, str, color=1, charsize=charsize, /normal, alignment=1, $
    charthick=charthick

  c_shift = 0
  C      = Myct_defaults()
  Bottom = C.Bottom + c_shift
  Ncolor = 255L-Bottom
  UNIT   = '!4l!3g m!u-3!n'
  CBPosition = [0.25,0.26,0.75,0.31]
     ColorBar, Max=maxdata,     Min=mindata,    NColors=Ncolor,        $
       	   Bottom=BOTTOM,   Color=C.Black,  Position=CBPosition,   $
       	   Unit=Unit,       Divisions=Ndiv, Log=Log,               $
	         Format=CBFormat, Charsize=csfac,                        $
    	         C_Colors=CC_Colors, C_Levels=C_Levels, Charthick=charthick

  if !D.name eq 'PS' then close_device

 
  end


;==============================================================================

 @define_plot_size

  COMMON SHARE, dat, mdat

 if N_elements(imp01) eq 0 then begin

    restore, filename='/users/ctm/rjp/Data/IMPROVE/Raw_data/daily_2001.sav'
    restore, filename='/users/ctm/rjp/Data/IMPROVE/Raw_data/daily_2002.sav'
    restore, filename='/users/ctm/rjp/Data/IMPROVE/Raw_data/daily_2003.sav'
    restore, filename='/users/ctm/rjp/Data/IMPROVE/Raw_data/daily_2004.sav'
    restore, filename='nsk_ibf.sav'

    restore, filename='monthly_2001.sav'
    restore, filename='monthly_2002.sav'
    restore, filename='monthly_2003.sav'
    restore, filename='monthly_2004.sav'

    imp01 = knon( imp01 )
    imp02 = knon( imp02 )
    imp03 = knon( imp03 )
    imp04 = knon( imp04 )

    dat02 = sync( imp01, imp02 )
    dat01 = sync( dat02, imp01 )
    dat03 = sync( dat01, imp03 )
    dat04 = sync( dat01, imp04 )

    dat   = combine(dat01,dat02,dat03,dat04)

    mdat  = combine(d1,d2,d3,d4)
  end


  plot_min_max

stop


  multipanel, row=2, col=2
  Pos = cposition(2,2,xoffset=[0.15,0.1],yoffset=[0.1,0.1], $
        xgap=0.1,ygap=0.15,order=0)

  mindata = 0.
  maxdata = 0.1
  cbformat = '(F5.3)'
  cfac    = 3.

  winter = [1,2,12]
  others = [3,4,5,9,10,11]


  Jday  = mdat[0].jday
  mon   = jday2month(Jday)

  jj    = -1.
  For D = 0, N_elements(winter)-1 do jj = [jj, where( mon eq winter[D] ) ]
  jj    = jj[1:*]

  dat_djf  = mdat.knon[jj] ; [jday, site]


  jj    = -1.
  For D = 0, N_elements(others)-1 do jj = [jj, where( mon eq others[D] ) ]
  jj    = jj[1:*]

  dat_oth  = mdat.knon[jj] ; [jday, site]




  For N = 0, n_elements(mdat)-1L do begin

    erase

    tser     = sort_positive(reform(dat_djf[*,N]-nsk_ibf[N]))
    fld      = mean(tser)
    position = pos[*,0]

    mapplot, fld, dat[N], mindata=mindata, maxdata=maxdata*0.3, pos=position, $
     cfac=cfac,cbformat=cbformat, comment=comment,          $
     discrete=discrete, ndiv=ndiv, /cbar, nogxlabel=nogxlabel, $
     nogylabel=nogylabel, unit='ug/m3', title=title

    if n_elements(tser) ge 3 then mmm = mean((tser(sort(tser)))[0:2]) else mmm = mean(tser)
    print, mean(tser), mmm

    qqnorm, tser, position=pos[*,1], yrange=[mindata, maxdata], xrange=[-3,3], $
          psym=1, nogylab=nogylab, ylab=ylab, xlab=xlab, nogxlab=nogxlab, /qline


    tser     = sort_positive(reform(dat_oth[*,N]-nsk_ibf[N]))
    qqnorm, tser, position=pos[*,2], yrange=[mindata, maxdata], xrange=[-3,3], $
          psym=1, nogylab=nogylab, ylab=ylab, xlab=xlab, nogxlab=nogxlab, /qline


    fld = mdat[N].knon
    plot, indgen(48)+1L, fld, color=1, pos=pos[*,3], xstyle=1, psym=-1, $
       yrange = [mindata, maxdata], thick=dthick,  xminor=6, $
       xticklen=0.05, xrange=[1,48], xtickinterval=6, xtitle='month', $
       charthick=charthick, charsize=charsize, ytitle='nsK Conc. (ug/m3)'


    halt
  end


End
