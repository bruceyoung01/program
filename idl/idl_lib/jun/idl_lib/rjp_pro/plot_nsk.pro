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
  data = composite(data)

  return, data.mean

end

;==============================================================================
 function find_min, month, str, specname, ng

  if n_elements(ng) eq 0 then ng = 2

  specname = strupcase(specname)
  NAMES    = tag_names(str)
  N        = where(NAMES eq specname)

  if N[0] eq -1 then message, 'there is no matched species', specname

  Jday = str[0].jday
  mon  = jday2month(Jday)

  jj   = -1.
  For D = 0, N_elements(month)-1 do jj = [jj, where( mon eq month[D] ) ]
  jj   = jj[1:*]

  bkgn = fltarr(N_elements(str))
  slop = bkgn
  corr = bkgn

  ; Search for the lowest values
  For D = 0, N_elements(str)-1 do begin
     D_KN = str[D].(N)[jj]
     M_KN = daily2monthly(D_KN, Jday)
     M_KN = chk_negative(M_KN)
     isot = sort(m_kn)

    Rstat = comp_corr( str[D], ['KNON','CARB'], month=isot[0:ng]+1L )
  bkgn[D] = mean((m_kn(isot))[0:ng], /NaN)  ; choose mean of three smallest values
  slop[D] = Rstat.slope[0]
  corr[D] = Rstat.R[0]
  End

  return, {dat:bkgn, corr:corr, slop:slop}

end

;==============================================================================

 pro plot_knon_each_year

  COMMON SHARE, dat01, dat02, dat03, dat04, nsk_ibf

  @define_plot_size

  multipanel, col=2, row=4 
  Pos = cposition(2,4,xoffset=[0.1,0.1],yoffset=[0.35,0.35], $
        xgap=0.02,ygap=0.02,order=0)

  spec   = 'KNON'

  if !D.name eq 'PS' then $
    open_device, file=spec + '.01-04_conc.ps', /color, /ps, /portrait

  winter = [1,2,12]
  summer = [6,7,8]

  mindata = 0.
  maxdata = 0.05
  cbformat = '(F5.2)'
  ndiv    = 6

  comment = '2001'
  plot2d, winter, dat01, spec, pos=pos[*,0], mindata=mindata, $
      maxdata=maxdata, /nogxlabel, comment=comment
  plot2d, summer, dat01, spec, pos=pos[*,1], mindata=mindata, $
      maxdata=maxdata, /nogylabel, /nogxlabel, comment=comment

  comment = '2002'
  plot2d, winter, dat02, spec, pos=pos[*,2], mindata=mindata, $
      maxdata=maxdata, /nogxlabel, comment=comment
  plot2d, summer, dat02, spec, pos=pos[*,3], mindata=mindata, $
      maxdata=maxdata, /nogylabel, /nogxlabel, comment=comment

  comment = '2003'
  plot2d, winter, dat03, spec, pos=pos[*,4], mindata=mindata, $
      maxdata=maxdata, /nogxlabel, comment=comment
  plot2d, summer, dat03, spec, pos=pos[*,5], mindata=mindata, $
      maxdata=maxdata, /nogylabel, /nogxlabel, comment=comment

  comment = '2004'
  plot2d, winter, dat04, spec, pos=pos[*,6], mindata=mindata, $
      maxdata=maxdata, /nogxlabel, comment=comment
  plot2d, summer, dat04, spec, pos=pos[*,7], mindata=mindata, $
      maxdata=maxdata, /nogylabel, /nogxlabel, comment=comment

  xyouts, 0.3, 0.91, 'WINTER', alignment=0.5, color=1, /normal, $
     charsize=charsize, charthick=charthick
  xyouts, 0.7, 0.91, 'SUMMER', alignment=0.5, color=1, /normal, $
     charsize=charsize, charthick=charthick

  xyouts, 0.5, 0.95, 'ns-K concentrations in the United States', $
     alignment=0.5, color=1, /normal, $
     charsize=charsize, charthick=charthick

  c_shift = 0
  C      = Myct_defaults()
  Bottom = C.Bottom + c_shift
  Ncolor = 255L-Bottom

     dx = (pos[2,0]-pos[0,1])*0.1
     dy = 0.03
     CBPosition = [pos[0,0]+dx,pos[1,7]-dy*2,pos[2,1]-dx,pos[1,7]-dy]
     ColorBar, Max=maxdata,     Min=mindata,    NColors=Ncolor,        $
       	   Bottom=BOTTOM,   Color=C.Black,  Position=CBPosition,   $
       	   Unit=Unit,       Divisions=Ndiv, Log=Log,               $
	         Format=CBFormat, Charsize=csfac,                        $
    	         C_Colors=CC_Colors, C_Levels=C_Levels, Charthick=charthick

  if !D.name eq 'PS' then close_device

 end

;==========================================================================

 pro plot_min_max

  COMMON SHARE, dat01, dat02, dat03, dat04, nsk_ibf

  @define_plot_size

  multipanel, col=2, row=1 
  Pos = cposition(2,1,xoffset=[0.1,0.1],yoffset=[0.35,0.35], $
        xgap=0.02,ygap=0.02,order=0)

  spec   = 'KNON'

  if !D.name eq 'PS' then $
    open_device, file='carb_min_max.ps', /color, /ps, /landscape

  winter = [1,2,12]
  summer = [6,7,8]
  annual = indgen(12)+1L

  mindata = 0.
  maxdata = 100.
  cbformat = '(F6.2)'
  ndiv    = 6

  dat = fltarr(n_elements(dat01), 4)
  bkg = dat
  cor = dat
  slp = dat

  dat[*,0] = chk_negative(chk_zero(process( winter, dat01, spec )))
  dat[*,1] = chk_negative(chk_zero(process( winter, dat02, spec )))
  dat[*,2] = chk_negative(chk_zero(process( winter, dat03, spec )))
  dat[*,3] = chk_negative(chk_zero(process( winter, dat04, spec )))

  a        = find_min( annual, dat01, spec )
  b        = find_min( annual, dat02, spec )
  c        = find_min( annual, dat03, spec )
  d        = find_min( annual, dat04, spec )

  bkg[*,0] = a.dat
  bkg[*,1] = b.dat
  bkg[*,2] = c.dat
  bkg[*,3] = d.dat

  cor[*,0] = a.corr
  cor[*,1] = b.corr
  cor[*,2] = c.corr
  cor[*,3] = d.corr

  slp[*,0] = a.slop
  slp[*,1] = b.slop
  slp[*,2] = c.slop
  slp[*,3] = d.slop

  cor      = chk_negative(cor)
  slp      = chk_negative(slp)

;  bkg[*,0] = chk_negative(chk_zero(process( annual, dat01, spec )))
;  bkg[*,1] = chk_negative(chk_zero(process( annual, dat02, spec )))
;  bkg[*,2] = chk_negative(chk_zero(process( annual, dat03, spec )))
;  bkg[*,3] = chk_negative(chk_zero(process( annual, dat04, spec )))

  idw = where(dat01.lon le -95.)
  ide = where(dat01.lon gt -95.) 

  format  = '(f5.3)'
  limit   = [25., -127., 50., -60.]

  fld = composite(dat, /first)
  print, quantile(fld.mean,[0.1,0.5,0.9])
  comment = '(a) Winter'
  data    = fld.mean
  mapplot, data, dat01, mindata=mindata, maxdata=maxdata, pos=pos[*,0], $
   cfac=cfac,cbformat=cbformat, comment=comment, limit=limit,           $
   ndiv=ndiv, nogxlabel=nogxlabel, nogylabel=nogylabel, commsize=1.2, $
   /meanvalue

;  save, filename='nsk_bf.sav', nsk_ibf

  fld = composite(slp, /first)
  print, quantile(fld.mean,[0.1,0.5,0.9])
  comment = '(b) summer'
  data    = fld.mean
  mapplot, data, dat01, mindata=mindata, maxdata=maxdata, pos=pos[*,1], $
   cfac=cfac,cbformat=cbformat, comment=comment, limit=limit,           $
   ndiv=ndiv, nogxlabel=nogxlabel, /nogylabel, commsize=1.2, /meanvalu


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

 pro plot_knon_min_max, mdat

  COMMON SHARE, dat01, dat02, dat03, dat04, nsk_ibf

  @define_plot_size

  multipanel, col=2, row=2 
  Pos = cposition(2,2,xoffset=[0.1,0.1],yoffset=[0.1,0.2], $
        xgap=0.02,ygap=0.07,order=0)

  spec   = 'KNON'

  if !D.name eq 'PS' then $
    open_device, file='nsk_burns.ps', /color, /ps, /landscape

  winter = [1,2,12]
  summer = [6,7,8]
  others = [3,4,5,9,10,11]

  mindata = 0.
  maxdata = 0.05
  cbformat = '(F5.2)'
  ndiv    = 6

  val_djf = chk_negative(chk_zero(process( winter, mdat, spec ))) - nsk_ibf

  val_res = find_min( winter, mdat, spec, 3 ) - nsk_ibf

  val_pre = val_djf - val_res

  val_oth = chk_negative(chk_zero(process( others, mdat, spec ))) - nsk_ibf 

  idw = where(dat01.lon le -95.)
  ide = where(dat01.lon gt -95.) 

  format  = '(f5.3)'
  limit   = [25., -127., 50., -60.]


  ;=================================================
  ; Background ns-K concentrations
  ;=================================================
;  nsk_ibf = fld.mean
;  save, filename='nsk_bf.sav', nsk_ibf

  data = nsk_ibf
  print, quantile(data,[0.1,0.5,0.9])
;  comment = '(a)!CBackground'
  comment = '(a) Ind_bf'

  nogylabel = 0
  position  = pos[*,0]
  mapplot, data, dat01, mindata=mindata, maxdata=maxdata, pos=position, $
   cfac=cfac,cbformat=cbformat, comment=comment, limit=limit,           $
   ndiv=ndiv, nogxlabel=nogxlabel, nogylabel=nogylabel, commsize=1.2

  l_str = string(mean(data[idw],/nan),format=format)
  r_str = string(mean(data[ide],/nan),format=format)
  print_number, l_str, r_str, position=position

  ;==================================================
  ; residential biofuel concentration
  ;==================================================

  data = val_res
  print, quantile(data,[0.1,0.5,0.9])
  comment = '(b) Res_bf!Cdjf'
  nogylabel = 1
  position  = pos[*,1]

  mapplot, data, dat01, mindata=mindata, maxdata=maxdata, pos=position, $
   cfac=cfac,cbformat=cbformat, comment=comment, limit=limit,           $
   ndiv=ndiv, nogxlabel=nogxlabel, nogylabel=nogylabel, commsize=1.2

  l_str = string(mean(data[idw],/nan),format=format)
  r_str = string(mean(data[ide],/nan),format=format)
  print_number, l_str, r_str, position=position


  ;==================================================
  ; spring/fall time concentration
  ;==================================================

  data = val_oth
  print, quantile(data,[0.1,0.5,0.9])
  comment = '(c) pre. burn!Cspring/fall'

  nogylabel = 0
  position  = pos[*,2]

  mapplot, data, dat01, mindata=mindata, maxdata=maxdata, pos=position, $
   cfac=cfac,cbformat=cbformat, comment=comment, limit=limit,           $
   ndiv=ndiv, nogxlabel=nogxlabel, nogylabel=nogylabel, commsize=1.2

  l_str = string(mean(data[idw],/nan),format=format)
  r_str = string(mean(data[ide],/nan),format=format)
  print_number, l_str, r_str, position=position

  ;==================================================
  ; Prescribed burning concentration
  ;==================================================

  data = val_pre
  print, quantile(data,[0.1,0.5,0.9])
  comment = '(d) pre. burn!Cdjf'
  nogylabel = 1
  position  = pos[*,3]

  mapplot, data, dat01, mindata=mindata, maxdata=maxdata, pos=position, $
   cfac=cfac,cbformat=cbformat, comment=comment, limit=limit,           $
   ndiv=ndiv, nogxlabel=nogxlabel, nogylabel=nogylabel, commsize=1.2

  l_str = string(mean(data[idw],/nan),format=format)
  r_str = string(mean(data[ide],/nan),format=format)
  print_number, l_str, r_str, position=position


  ;==================================================
  ; Color bar
  ;==================================================

  c_shift = 0
  C      = Myct_defaults()
  Bottom = C.Bottom + c_shift
  Ncolor = 255L-Bottom
  UNIT   = '!4l!3g m!u-3!n'
  CBPosition = [0.25,0.10,0.75,0.15]
     ColorBar, Max=maxdata,     Min=mindata,    NColors=Ncolor,        $
       	   Bottom=BOTTOM,   Color=C.Black,  Position=CBPosition,   $
       	   Unit=Unit,       Divisions=Ndiv, Log=Log,               $
	         Format=CBFormat, Charsize=csfac,                        $
    	         C_Colors=CC_Colors, C_Levels=C_Levels, Charthick=charthick

  if !D.name eq 'PS' then close_device

 
  end

;==============================================================================


 @define_plot_size

  COMMON SHARE, dat01, dat02, dat03, dat04, nsk_ibf

 if N_elements(dat01) eq 0 then begin

    restore, filename='./datasav/nsk_ibf.sav'

    restore, filename='./datasav/daily_2001.sav'
    restore, filename='./datasav/daily_2002.sav'
    restore, filename='./datasav/daily_2003.sav'
    restore, filename='./datasav/daily_2004.sav'

    restore, filename='./datasav/monthly_2001-2004.sav'
  end


;  plot_min_max
  plot_knon_min_max, mdat

;  plot_carb_min_max

End
