
 function id_find, fld

;  Rcri = 0.7
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

  C       = 1

  CASE C of
     0 : begin
         mindata = 0.
         maxdata = 1.
         end
     1 : begin
         mindata = 20.
         maxdata = 120.
         end
     2 : begin
         mindata = -0.5
         maxdata = 0.5
         end
  END

  cfac    = 1.

  cbformat='(F6.1)'
  Names   = Tag_names(fld01)

  Ndiv    = 5

  meanvalue = 1

  ID = id_find(fld01)
  fld = fld01.(C)[ID]
  print, quantile(fld,[0.1,0.5,0.9]), mean(fld,/nan), format='(4F8.2)'
  mapplot, fld, imp01[ID], mindata=mindata, maxdata=maxdata, pos=pos[*,0], $
   cfac=cfac,cbformat=cbformat, /nogxlabel, comment='2001', discrete=discrete, ndiv=ndiv, $
   meanvalue=meanvalue

  ID = id_find(fld02)
  fld = fld02.(C)[ID]
  print, quantile(fld,[0.1,0.5,0.9]), mean(fld,/nan), format='(4F8.2)'
  mapplot, fld, imp02[ID], mindata=mindata, maxdata=maxdata, pos=pos[*,1], $
   cfac=cfac,cbformat=cbformat, /nogylabel, /nogxlabel, comment='2002', discrete=discrete, ndiv=ndiv, $
   meanvalue=meanvalue

  ID = id_find(fld03)
  fld = fld03.(C)[ID]
  print, quantile(fld,[0.1,0.5,0.9]), mean(fld,/nan), format='(4F8.2)'
  mapplot, fld, imp03[ID], mindata=mindata, maxdata=maxdata, pos=pos[*,2], $
   cfac=cfac,cbformat=cbformat, comment='2003', discrete=discrete, ndiv=ndiv, $
   meanvalue=meanvalue

  ID = id_find(fld04)
  fld = fld04.(C)[ID]
  print, quantile(fld,[0.1,0.5,0.9]), mean(fld,/nan), format='(4F8.2)'
  mapplot, fld, imp04[ID], mindata=mindata, maxdata=maxdata, pos=pos[*,3], $
   cfac=cfac,cbformat=cbformat, /nogylabel, comment='2004', discrete=discrete, ndiv=ndiv, $
   meanvalue=meanvalue

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

  ; colorbar
  CBPosition = [0.2,0.1,0.8,0.15]
  ColorBar, Max=maxdata,     Min=mindata,    NColors=Ncolor,     $
    	   Bottom=BOTTOM,   Color=C.Black,  Position=CBPosition, $
    	   Unit=Unit,       Divisions=Ndiv, Log=Log,             $
         Format=CBFormat, Charsize=charsize,       $
         C_Colors=CC_Colors, C_Levels=C_Levels, Charthick=charthick, _EXTRA=e


 end

;======================================================================================

 pro plot_site, str, pos=pos

  COMMON SHARE, RCRI, MONTH
  @define_plot_size
  
  spec  = ['KNON','CARB']
  fld   = comp_corr( str, spec, month=month )

  Jday = str[0].jday
  mon  = jday2month(Jday)

  jj   = -1.
  For D = 0, N_elements(month)-1 do jj = [jj, where( mon eq month[D] ) ]
  jj   = jj[1:*]

  ID = id_find(fld)

  xrange = [0.,0.1]
  yrange = [0.,10.]
  mindata = 0.
  maxdata = 120.
  For D = 0, N_elements(ID)-1 do begin

    erase

    X = str[ID[D]].KNON[JJ]
    Y = str[ID[D]].CARB[JJ]

    mapplot, fld.slope[ID[D]], str[ID[D]], pos=pos[*,0], mindata=mindata, maxdata=maxdata, $
       /cbar, ndiv=4, cfac=2
    scatter, X, Y, pos=pos[*,1], xrange=xrange, yrange=yrange

    halt
  End

 End

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
  month= [1,2,12]

  multipanel, row=2, col=2

  Pos = cposition(2,2,xoffset=[0.1,0.1],yoffset=[0.2,0.2], $
        xgap=0.02,ygap=0.04,order=0)

  if !D.name eq 'PS' then $
    open_device, file='test_k_bf.ps', /color, /ps, /landscape

    plot_corr, dat01, dat02, dat03, dat04, pos=pos, /discrete
;    plot_site, dat04, pos=pos

  if !D.name eq 'PS' then close_device

End
