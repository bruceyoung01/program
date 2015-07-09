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

  if Rstat.R[0] ge 0.7 then begin
     slop[D] = Rstat.slope[0]
     corr[D] = Rstat.R[0]
  end else begin
     slop[D] = 'NaN'
     corr[D] = 'NaN'
  end

  End

  return, {dat:bkgn, corr:corr, slop:slop}

end


;==========================================================================

 pro plot_min_max

  COMMON SHARE, dat01, dat02, dat03, dat04, nsk_ibf

  @define_plot_size

  multipanel, col=2, row=2 
  Pos = cposition(2,2,xoffset=[0.1,0.1],yoffset=[0.05,0.15], $
        xgap=0.02,ygap=0.15,order=0)

  spec   = 'KNON'

  if !D.name eq 'PS' then $
    open_device, file='carb_min_max.ps', /color, /ps, /landscape

  summer = [6,7,8]
  annual = indgen(12)+1L
  others = [1,2,3,4,5,9,10,11,12]
  winter = [1,2,12]
  spring = [3,4,5]
  autumn = [9,10,11]

  cbformat = '(F7.3)'
  ndiv    = 6

  dat = fltarr(n_elements(dat01), 4)
  bkg = dat
  cor = dat
  slp = dat

  a        = find_min( others, dat01, spec )
  b        = find_min( others, dat02, spec )
  c        = find_min( others, dat03, spec )
  d        = find_min( others, dat04, spec )

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

  idw = where(dat01.lon le -95.)
  ide = where(dat01.lon gt -95.) 

  format  = '(f5.3)'
  limit   = [25., -127., 50., -60.]

  fld = composite(bkg, /first)
  print, quantile(fld.mean,[0.1,0.5,0.9])
  comment = '(a) IND BF'
  mindata = 0. & maxdata = 0.05
  data    = fld.mean
  mapplot, data, dat01, mindata=mindata, maxdata=maxdata, pos=pos[*,0], $
   cfac=cfac,cbformat=cbformat, comment=comment, limit=limit,           $
   ndiv=ndiv, nogxlabel=nogxlabel, nogylabel=nogylabel, commsize=1.2, $
   /meanvalue, /cbar

  fld = composite(cor, /first)
  print, quantile(fld.mean,[0.1,0.5,0.9])
  comment = 'R'
  mindata = 0. & maxdata = 1.
  data    = fld.mean
  mapplot, data, dat01, mindata=mindata, maxdata=maxdata, pos=pos[*,1], $
   cfac=cfac,cbformat=cbformat, comment=comment, limit=limit,           $
   ndiv=ndiv, nogxlabel=nogxlabel, /nogylabel, commsize=1.2, /meanvalu, /cbar

  fld = composite(slp, /first)
  print, quantile(fld.mean,[0.1,0.5,0.9])
  comment = 'Ratio'
  mindata = 0. & maxdata = 100.
  data    = fld.mean
  mapplot, data, dat01, mindata=mindata, maxdata=maxdata, pos=pos[*,2], $
   cfac=cfac,cbformat=cbformat, comment=comment, limit=limit,           $
   ndiv=ndiv, nogxlabel=nogxlabel, /nogylabel, commsize=1.2, /meanvalu, /cbar

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

  plot_min_max

End
