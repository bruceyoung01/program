
 function id_find, fld

;  Rcri = 0.7
  COMMON SHARE, RCRI, MONTH

  R    = fld.r  ; correlation
  ID   = where( R ge Rcri ) 

;  ID   = Lindgen(N_elements(fld.r))

  return, id

 end

;================================================================

 function make_states, fld, str

  COMMON SHARE, RCRI, MONTH

  ; at individual sites
  R    = fld.r  ; correlation
  slope= chk_negative( fld.slope )
  const= fld.const

  ID   = where( R ge Rcri )

  state_50 = ['AK','WA','OR','CA','NV','ID','MT','UT','AZ','WY', $
              'CO','NM','ND','SD','NE','KS','OK','TX','MN','IA', $
              'MO','AR','LA','WI','IL','MS','MI','IN','OH','KY', $
              'WV','TN','AL','GA','FL','ME','VT','NH','MA','RI', $
              'CT','NJ','NY','PA','DE','DC','MD','VA','NC','SC'  ]

            ; there are total of 48 states in the contiguous US
  slope_50 = Replicate('-999.', 50)

  For D = 0, 49 do begin
      p = where(str[ID].state eq state_50[D])
      if p[0] ne -1 then slope_50[D] = mean(slope[ID[p]],/NaN)
  End
 
 return, {state:state_50, slope:slope_50}

 end

;================================================================

 pro process, fld, str, ID=ID, data=data, conc=conc, sp=sp, clim=clim, $
              div=div

  COMMON SHARE, RCRI, MONTH

  restore, filename='nsk_ibf.sav'

  R    = fld.r  ; correlation

  slope= fld.slope
  const= fld.const

  Jday = str[0].jday
  mon  = jday2month(Jday)

  ; Selecting data for given months
  jj   = -1.
  For N = 0, N_elements(month)-1 do jj = [jj, where( mon eq month[N] ) ]
  jj   = jj[1:*]

  Fire = Replicate(0., n_elements(str))
  Conc = Fire
  ffac = Fire
  ID   = -1L
  DIV  = Fire

  For D = 0, N_elements(str)-1 do begin
      Info = str[D]
      Dat  = 0.

      CARB = Info.CARB[jj]  
      CARB = chk_negative( CARB )
      CONC[D] = mean(CARB, /NaN)

      KNON = Info.KNON[jj]
      KNON = chk_negative(KNON) 

      fin  = where(finite(KNON) eq 1)
      If fin[0] eq -1 then goto, jump

      KAVG = mean(KNON, /NaN)

      ; Biofuel contribution
      D_KN = Info.KNON
      D_KN = chk_negative(D_KN)
      M_KN = daily2monthly( D_KN, jday, Undef='NaN' )

;     B_KN = 0.                             ; No biofuel contribution
;     B_KN = min(M_KN, /NaN)                ; choose min value
      B_KN = mean((m_kn(sort(m_kn)))[0:2])  ; choose mean of three smallest values

      If R[D] ge Rcri then begin

         ratio = slope[D]

      End else begin

;         goto, jump
         ; assign state and year specific values
         p = where(sp.state eq info.state)
         ratio = sp.slope[p]

         ; if state year specific value does not exist then 
         ; use climatological value
;         if ratio lt 0. then goto, jump
         if ratio lt 0. then ratio = clim.slope[p]

         ; state climatological value is still nonexistaent then exit
         if ratio lt 0. then goto, jump

      end

;         Dat   = (KAVG - B_KN) * ratio[0]   
         Dat   = (KAVG - nsk_ibf[D]) * ratio[0]   
;         Dat   = KAVG * ratio[0]
;         print, b_kn, nsk_ibf[D], str[d].siteid

        ; impose low limit constraint
         dat   = dat < conc[D]


      if Dat lt 0. then goto, jump
      if finite(Dat) ne 1 then goto, jump 

         Fire[D] = Dat
         ffac[D] = ratio
         DIV[D]  = 1.
         ID  = [ID, D]

      jump:

;      if str[d].siteid eq 'LAVO1' then begin
;         print, n_elements(knon)
;         for ppp = 0, n_elements(dat)-1 do print, dat[ppp], carb[ppp]
;         stop
;      end

  End

  ID   = ID[1:*]
  Data = Fire
;  Data = ffac

  return

 end


;==============================================================

 function comp_clim, sp01,sp02,sp03,sp04

 fld   = fltarr(50,4)
 fld[*,0] = sp01.slope
 fld[*,1] = sp02.slope
 fld[*,2] = sp03.slope
 fld[*,3] = sp04.slope

 slope = Replicate(-999.,50)
 for D = 0, 49 do begin
     A = reform(fld[D,*])
     P = where(A gt 0.)
     IF P[0] ne -1 then slope[D] = total(A[P])/float(N_elements(P))
 end

 return, {slope:slope, state:sp01.state}

 end

;===============================================================

 pro eastwest, data, id, str

  COMMON SHARE, RCRI, MONTH

 if n_elements(str) eq 0 then return
 if n_elements(id)  eq 0 then return

 lon = str[id].lon
 tlon= str.lon

 Jday = str[0].jday
 mon  = jday2month(Jday)

 jj   = -1.
 For N = 0, N_elements(month)-1 do jj = [jj, where( mon eq month[N] ) ]
 jj   = jj[1:*]

 carb = str.carb[jj]
 resu = composite(carb)
 cavg = resu.mean


 w  = where(lon lt -95., complement=e)
 tw = where(tlon lt -95., complement=te)

 print, '===================================='
 print, '    US,     WEST,     EAST '
 print, mean(cavg), mean(cavg[tw]), mean(cavg[te]), '  TC conc'

 print, mean(data), mean(data[w]),  mean(data[e])

 print, total(data)/float(n_elements(str)),   $
        total(data[w])/float(n_elements(tw)), $
        total(data[e])/float(n_elements(te)), $
        ' BM TC weighted'

 print, n_elements(cavg), n_elements(tw), n_elements(te), '  # sites'

 end

;==============================================================
pro site_draw, str, pos=pos

  @define_plot_size
  cfac    = 1.
   ; Define Usersymbol
  A = FINDGEN(33) * (!PI*2/32.)
  USERSYM, COS(A), SIN(A)
  limit = [25., -130., 50., -60.]

  map_set, 0, 0, color=1, /contine, limit=limit, /usa,$
    position=pos, /noerase
  plots, str.lon, str.Lat, color=1, psym=8, symsize=symsize*cfac

end
;==============================================================
 pro display, id, fld, conc, str


 lon = str[id].lon
 lat = str[id].lat
 name= str[id].name
 state=str[id].state 
 siteid=str[id].siteid
 nong =conc[id]

 ; northeast
; p = where(lon gt -80. and lat gt 38.)

 ; westcoast
 p = where(lon lt -115.)

 ; states
; p = where(state eq 'NM')

 chk, fld[p]
 chk, state[p]

 for d = 0, n_elements(p)-1 do $
  print, fld[p[d]], nong[p[d]], name[p[d]], state[p[d]], lon[p[d]], lat[p[d]], siteid[p[d]]


 end

;==============================================================

 pro plot_fire_carb, imp01, imp02, imp03, imp04, pos=pos, discrete=discrete

  COMMON SHARE, RCRI, MONTH
  @define_plot_size

  fld01 = comp_corr( imp01, ['KNON','CARB'], month=month )
  fld02 = comp_corr( imp02, ['KNON','CARB'], month=month )
  fld03 = comp_corr( imp03, ['KNON','CARB'], month=month )
  fld04 = comp_corr( imp04, ['KNON','CARB'], month=month )

; concentrations
  c_levels = [0.0,0.2,0.4,0.6,0.8,1.0,1.5,2.0,3.0,4.0]
  c_levels = [0.0,0.2,0.4,0.6,0.8,1.0,1.5,2.0,3.0]
  mindata = 0 
  maxdata = 2.
  Ndiv    = 10
  if n_elements(c_levels) ne 0 then ndiv = n_elements(c_levels)

  c_shift = 5
  C      = Myct_defaults()
  Bottom = C.Bottom + c_shift
  Ncolor = 255L-Bottom

  if keyword_set(discrete) then begin
     if N_elements(C_Levels) eq 0 then $
     C_Levels  = Findgen(NDIV)*(maxdata-mindata)/float(Ndiv) + mindata
     CC_COLORS = Fix((INDGEN(NDIV)+0.5) * (NCOLOR)/NDIV + BOTTOM)
;     print, cc_colors
  end

  sp01 = make_states( fld01, imp01 )
  sp02 = make_states( fld02, imp02 )
  sp03 = make_states( fld03, imp03 )
  sp04 = make_states( fld04, imp04 )
  clim = comp_clim( sp01,sp02,sp03,sp04 )

  idw = where(imp01.lon le -95.)
  ide = where(imp01.lon gt -95.) 

  ; year 2001
  process, fld01, imp01, ID=ID, data=data, conc=conc, sp=sp01, clim=clim, div=div
  fld = data
  num = div
  ; year 2002
  process, fld02, imp02, ID=ID, data=data, conc=conc, sp=sp02, clim=clim, div=div
  fld = fld + data
  num = num + div
  ; year 2003
  process, fld03, imp03, ID=ID, data=data, conc=conc, sp=sp03, clim=clim, div=div
  fld = fld + data
  num = num + div
  ; year 2004
  process, fld04, imp04, ID=ID, data=data, conc=conc, sp=sp04, clim=clim, div=div
  fld = fld + data
  num = num + div


  id  = where(num ne 0.)
  fld[id] = fld[id] / num[id]

  position = pos[*,0]

  mapplot, fld[id], imp01[ID], mindata=mindata, maxdata=maxdata, pos=position, $
   cfac=cfac,cbformat=cbformat, /nogxlabel, comment=' ', $
   discrete=discrete, ndiv=ndiv, c_shift=c_shift, c_levels=c_levels

    format  = '(f4.2)'

    x = position[0]
    y = position[3]+0.01
    str = string(mean(fld[idw],/nan),format=format)
    xyouts, x, y, str, color=1, charsize=charsize, /normal, alignment=0, $
    charthick=charthick

    x = position[2]
    y = position[3]+0.01
    str = string(mean(fld[ide],/nan),format=format)
    xyouts, x, y, str, color=1, charsize=charsize, /normal, alignment=1, $
    charthick=charthick

;  Unit   = 'TC, !4l!3gC m!u-3!n'
  ; colorbar
  ; colorbar
  dx  = 0.02
  dy  = 0.02
  CBPosition = [position[0]+dx,position[1]-dy*3,position[2]-dx,position[1]-dy]
  cbformat='(F5.1)'

  xyouts, position[2]-5*dx, position[1]-6*dy, 'TC, !4l!3gC m!u-3!n', color=1, /normal, $
  charsize=charsize, charthick=charthick

  ColorBar, Max=maxdata,  Min=mindata,    NColors=Ncolor,     $
    	   Bottom=BOTTOM,   Color=C.Black,  Position=CBPosition, $
    	   Unit=Unit,       Divisions=Ndiv, Log=Log,             $
         Format=CBFormat, Charsize=charsize,       $
         C_Colors=CC_Colors, C_Levels=C_Levels, Charthick=charthick, $
         min_valid=1.e-5,  _EXTRA=e


 end


;==============================================================

 pro plot_biof_carb, imp01, imp02, imp03, imp04, pos=pos, discrete=discrete

  COMMON SHARE, RCRI, MONTH
  @define_plot_size

  fld01 = comp_corr( imp01, ['KNON','CARB'], month=month )
  fld02 = comp_corr( imp02, ['KNON','CARB'], month=month )
  fld03 = comp_corr( imp03, ['KNON','CARB'], month=month )
  fld04 = comp_corr( imp04, ['KNON','CARB'], month=month )

; concentrations
  c_levels = [0.0,0.2,0.4,0.6,0.8,1.0,1.5,2.0,3.0,4.0]
  c_levels = [0.0,0.2,0.4,0.6,0.8,1.0,1.5,2.0]
  mindata = 0 
  maxdata = 2.

  if n_elements(c_levels) ne 0 then ndiv = n_elements(c_levels)

  c_shift = 5
  C      = Myct_defaults()
  Bottom = C.Bottom + c_shift
  Ncolor = 255L-Bottom

  if keyword_set(discrete) then begin
     if N_elements(C_Levels) eq 0 then $
     C_Levels  = Findgen(NDIV)*(maxdata-mindata)/float(Ndiv) + mindata
     CC_COLORS = Fix((INDGEN(NDIV)+0.5) * (NCOLOR)/NDIV + BOTTOM)
;     print, cc_colors
  end

  sp01 = make_states( fld01, imp01 )
  sp02 = make_states( fld02, imp02 )
  sp03 = make_states( fld03, imp03 )
  sp04 = make_states( fld04, imp04 )
  clim = comp_clim( sp01,sp02,sp03,sp04 )

  idw = where(imp01.lon le -95.)
  ide = where(imp01.lon gt -95.) 


  ; year 2001
  process, fld01, imp01, ID=ID, data=data, conc=conc, sp=sp01, clim=clim, div=div
  fld = data
  num = div
  ; year 2002
  process, fld02, imp02, ID=ID, data=data, conc=conc, sp=sp02, clim=clim, div=div
  fld = fld + data
  num = num + div
  ; year 2003
  process, fld03, imp03, ID=ID, data=data, conc=conc, sp=sp03, clim=clim, div=div
  fld = fld + data
  num = num + div
  ; year 2004
  process, fld04, imp04, ID=ID, data=data, conc=conc, sp=sp04, clim=clim, div=div
  fld = fld + data
  num = num + div

  id  = where(num ne 0.)
  fld[id] = fld[id] / num[id]

  position = pos[*,0]

  mapplot, fld[id], imp01[ID], mindata=mindata, maxdata=maxdata, pos=position, $
   cfac=cfac,cbformat=cbformat, /nogxlabel, comment=' ', $
   discrete=discrete, ndiv=ndiv, c_shift=c_shift, c_levels=c_levels

    format  = '(f4.2)'

    x = position[0]
    y = position[3]+0.01
    str = string(mean(fld[idw],/nan),format=format)
    xyouts, x, y, str, color=1, charsize=charsize, /normal, alignment=0, $
    charthick=charthick

    x = position[2]
    y = position[3]+0.01
    str = string(mean(fld[ide],/nan),format=format)
    xyouts, x, y, str, color=1, charsize=charsize, /normal, alignment=1, $
    charthick=charthick

  
;  Unit   = 'TC, !4l!3gC m!u-3!n'
  ; colorbar
  dx  = 0.02
  dy  = 0.02
  CBPosition = [position[0]+dx,position[1]-dy*3,position[2]-dx,position[1]-dy]
  cbformat='(F5.1)'

  xyouts, position[2]-5*dx, position[1]-6*dy, 'TC, !4l!3gC m!u-3!n', color=1, /normal, $
  charsize=charsize, charthick=charthick

  ColorBar, Max=maxdata,  Min=mindata,    NColors=Ncolor,     $
    	   Bottom=BOTTOM,   Color=C.Black,  Position=CBPosition, $
    	   Unit=Unit,       Divisions=Ndiv, Log=Log,             $
         Format=CBFormat, Charsize=charsize,       $
         C_Colors=CC_Colors, C_Levels=C_Levels, Charthick=charthick, $
         min_valid=1.e-5,  _EXTRA=e


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
  month=[6,7,8]
;  month=[1,2,12]

  multipanel, row=1, col=2

  Pos = cposition(2,1,xoffset=[0.1,0.1],yoffset=[0.35,0.3], $
        xgap=0.02,ygap=0.02,order=0)

  if !D.name eq 'PS' then $
    open_device, file='fig06.ps', /color, /ps, /landscape

    plot_fire_carb, dat01, dat02, dat03, dat04, pos=pos[*,0], /discrete
;    plot_biof_carb, dat01, dat02, dat03, dat04, pos=pos[*,1], /discrete

  if !D.name eq 'PS' then close_device

End
