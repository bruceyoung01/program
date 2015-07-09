
 function id_find, fld

  COMMON SHARE, RCRI, MONTH

  R    = fld.r  ; correlation
  ID   = where( R ge Rcri ) 

;  ID   = Lindgen(N_elements(fld.r))

  return, id

 end

;==============================================================

 pro plot_corr, imp01, imp02, imp03, imp04, pos=pos, discrete=discrete

  COMMON SHARE, RCRI, MONTH
  @define_plot_size
  
  spec  =   ['KNON','CARB']

  fld01 = comp_corr( imp01, spec, month=month )
  fld02 = comp_corr( imp02, spec, month=month )
  fld03 = comp_corr( imp03, spec, month=month )
  fld04 = comp_corr( imp04, spec, month=month )

  mindata = 10
  maxdata = 130
  cfac    = 1.
  C       = 1
  cbformat='(I3)'
  Names   = Tag_names(fld01)

  Ndiv    = 6

  ID = id_find(fld01)
  fld = fld01.(C)[ID]
  print, quantile(fld,[0.1,0.5,0.9])
  mapplot, fld, imp01[ID], mindata=mindata, maxdata=maxdata, pos=pos[*,0], $
   cfac=cfac,cbformat=cbformat, /nogxlabel, comment='2001', discrete=discrete, ndiv=ndiv

  ID = id_find(fld02)
  fld = fld02.(C)[ID]
  print, quantile(fld,[0.1,0.5,0.9])
  mapplot, fld, imp02[ID], mindata=mindata, maxdata=maxdata, pos=pos[*,1], $
   cfac=cfac,cbformat=cbformat, /nogylabel, /nogxlabel, comment='2002', discrete=discrete, ndiv=ndiv

  ID = id_find(fld03)
  fld = fld03.(C)[ID]
  print, quantile(fld,[0.1,0.5,0.9])
  mapplot, fld, imp03[ID], mindata=mindata, maxdata=maxdata, pos=pos[*,2], $
   cfac=cfac,cbformat=cbformat, comment='2003', discrete=discrete, ndiv=ndiv

  ID = id_find(fld04)
  fld = fld04.(C)[ID]
  print, quantile(fld,[0.1,0.5,0.9])
  mapplot, fld, imp04[ID], mindata=mindata, maxdata=maxdata, pos=pos[*,3], $
   cfac=cfac,cbformat=cbformat, /nogylabel, comment='2004', discrete=discrete, ndiv=ndiv

  XYOuts, 0.5, 0.85, Names[C], color=1, /normal, alignment=0.5, $
    charsize=charsize, charthick=charthick

  C      = Myct_defaults()
  Bottom = C.Bottom
  Ncolor = 255L-Bottom

  if keyword_set(discrete) then begin
  CC_COLORS = Fix((INDGEN(NDIV)+0.5) * (NCOLOR)/(NDIV)+BOTTOM)
  C_Levels  = Findgen(NDIV)*(maxdata-mindata)/float(Ndiv) + mindata
;  print, cc_colors
  end

  xyouts, 0.77, 0.08, 'd[TC]/d[ns-K]', color=1, /normal, charsize=charsize*0.9, $
  charthick=charthick

  ; colorbar
  CBPosition = [0.18,0.1,0.76,0.15]
  ColorBar, Max=maxdata,     Min=mindata,    NColors=Ncolor,     $
    	   Bottom=BOTTOM,   Color=C.Black,  Position=CBPosition, $
    	   Unit=Unit,       Divisions=Ndiv, Log=Log,             $
         Format=CBFormat, Charsize=charsize,       $
         C_Colors=CC_Colors, C_Levels=C_Levels, Charthick=charthick, _EXTRA=e


 end



;==============================================================
  COMMON SHARE, RCRI, MONTH

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

  RCRI = 0.7

  month=[1,2,12]

  multipanel, row=2, col=2

  Pos = cposition(2,2,xoffset=[0.1,0.1],yoffset=[0.2,0.2], $
        xgap=0.02,ygap=0.02,order=0)

  if !D.name eq 'PS' then $
    open_device, file='fig03.ps', /color, /ps, /landscape

    plot_corr, imp01, imp02, imp03, imp04, pos=pos, /discrete

  if !D.name eq 'PS' then close_device

End
