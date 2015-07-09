;============================================================================

 pro tseries, imp, pos=pos, yrange=yrange, xrange=xrange

  if n_elements(yrange) eq 0 then yrange=[0.,10.]
  if n_elements(xrange) eq 0 then xrange=[1.,365.]

  Jday = imp[0].jday
  mon  = jday2month(Jday)
  jj   = where(mon ge 7 and mon le 8)

  tau0 = nymd2tau(20040101L)
  ddd  = [20040709L,20040711L,20040720L,20040721L,20040722L,20040725L]
  ddd  = (nymd2tau(ddd) - tau0[0])/24L + 1L

;======================================================================
;  Plotting begins here
;======================================================================

  @define_plot_size
  
  YTicks  = yrange[1]
  xrange  = [Jday[min(jj)], Jday[max(jj)]]

  ; geos-chem simulation of omc 
;  fac    = 1.4
;  Model  = (gc.ocpi+gc.ocpo)*fac + gc.soa1+gc.soa2+gc.soa3
;  M_jday = gc[0].jday 

  ; improve observations
  Data  = imp.omc
  array = composite(Data, /first)

;  ytitle = 'OMC Concentration (!4l!3g m!u-3!n)'
  xtitle = 'Julian day of year 2004'

  plot, jday, array.mean, color=1, xstyle=1, xrange=xrange, $
    yrange=yrange, psym=-8, symsize=symsize, thick=thin,              $
    ystyle=1, charthick=charthick,    $
    ytitle=ytitle, position=pos, charsize=charsize, $
    xtitle=xtitle, Yticks=YTicks, yminor=1

  Data  = imp.ec*10.
  array = composite(Data, /first)
;  oplot, jday, array.mean, color=2, psym=-2

;  array = composite(Model[*,q], /first)
;  oplot, m_jday, array.mean, color=4, line=2, thick=dthick

;  oplot, [jday[min(jj)],jday[min(jj)]], ocrange, color=1
;  oplot, [jday[max(jj)],jday[max(jj)]], ocrange, color=1

;  xyouts, 15, 5, 'R < '+CR, color=1, charsize=charsize, $
;   charthick=charthick

 ; potassium

  ylabel = strarr(YTicks+1)
  ylabel[*] = ' '

;  Axis, YAxis=1, Yrange=ocrange*0.01, /Save, Yticks=YTicks, $
;   color=2, charsize=charsize, charthick=charthick, $
;   ytickname=Ylabel, yminor=1

  ; nonsoil potassium
  data  = (imp.k - (imp.fe*0.6))*100.
  array = composite(data, /first)
  oplot, jday, array.mean, color=2, psym=4


 end

;============================================================================
 pro plotongrid, fld, str, pos=pos, mindata=mindata, maxdata=maxdata, $
  array=array

  if n_elements(fld) eq 0 then return
  if n_elements(str) eq 0 then return
  if n_elements(fld) ne n_elements(str) then $
     message, 'dimensions mismatched'

  @define_plot_size

  modelinfo = ctm_type('GEOS4_30L',res=2)
  gridinfo  = ctm_grid( modelinfo )
  array     = fltarr(gridinfo.imx*gridinfo.jmx)
  div       = array
  ij        = ij_find(obs=str, modelinfo=modelinfo)

  P         = where(fld gt 0.)

  For D = 0, N_elements(P)-1L do begin
      K = P[D]
      M = ij.i[K]+ij.j[K]*gridinfo.imx

      array[M] = array[M] + FLD[K]
      div[M]   = div[M] + 1.
  End

  P = where(div gt 0.)
  array[P] = array[P] / div[P]

  array = reform(array, gridinfo.imx, gridinfo.jmx)

  plot_region, array, /sample, min_valid=1.e-10, /cbar, $
   divis=4, maxdata=maxdata, mindata=mindata, position=pos

 end

;========================================================================

 function make_matrix, fld, str

  if n_elements(fld) eq 0 then return, -1
  if n_elements(str) eq 0 then return, -1

  data      = transpose(fld) ; convert to [site, time]
  dim       = size(data, /dim)
  data      = make_zero(data, val='NaN')
  avg       = fltarr(dim[0])
  For D = 0, dim[0]-1 do avg[D] = mean(data[D,*], /NaN)

  ; Filling missing data with mean value
  For D = 0, dim[0]-1 do begin
      sample = reform(Data[D,*])
      p = where(finite(sample) eq 0)
      if p[0] ne -1 then sample[p] = avg[D]
      Data[D,*] = sample
  End

  modelinfo = ctm_type('GEOS4_30L',res=2)
  gridinfo  = ctm_grid( modelinfo )
  ij        = ij_find(obs=str, modelinfo=modelinfo)
  index     = ij.i+ij.j*gridinfo.imx
  ii        = sort(index)
  jj        = uniq(index[ii])
  mij       = index[ii[jj]]

  array     = fltarr(N_elements(mij), dim[1]) ; on model grid [grid, time]
  div       = fltarr(N_elements(mij))

  For D = 0, N_elements(index)-1L do begin
      K = index[D]
      M = where(MIJ eq K)
      array[M,*] = array[M,*] + Data[D,*]
      div[M]     = div[M] + 1.
  End

  For D = 0, N_elements(div)-1 do array[D,*] = array[D,*] / div[D]

  ; test
;  t = fltarr(144L*91L)
;  for i = 0, n_elements(mij)-1 do t[mij[i]] = array[i,5]
;  t = reform(t, 144, 91)
;  plotongrid, reform(fld[5,*]), str, array=q

  return, {array:array, ij:mij}

end

;========================================================================

 pro ploteof, eof, ij=ij, NoM=NoM, Jday=Jday

  multipanel, row=NoM, col=2

  margin = [0.01,0.05,0.01,0.05]

  IMX  = 144L
  JMX  = 91L  
  Fd2d = Replicate(-999., IMX*JMX)
  sign = Replicate(1., NoM)

  sign = [1.,1.,-1.]
  for mm = 0, NoM-1 do begin

   MODE     = Reform(Eof.mode(mm,*)*sign(mm))
   FD2D[IJ] = MODE
   maxdata  = max(mode)
   mindata  = min(mode)

   FD2D = Reform(FD2D, IMX, JMX)

   Plot_region, FD2D, /sample, /cbar, divis=4, margin=margin, $
    min_valid=mindata, mindata=mindata, maxdata=maxdata
   
   print, eof.variance[mm], ' % explaned'
;   xyouts, -120., 55., eof.variance(mm), color=1

    aa = max(abs(eof.time(*,*)))
    MULTIPANEL,Position=p,margin=0.04    ; get current plot position
    temp = Reform(Eof.time(mm,*)*sign(mm))
;   Plot, jday, temp/aa, color=1, position=p, xticks=12, $
;   xstyle=1,xrange=[1.,365.],yrange=[-1.,1.]

   Plot, jday, temp/aa, color=1, position=p, $
   xstyle=1, yrange=[-1.,1.]

   Oplot, [1.,365.],[0.0,0.0], color=1
;   print, STDDEV(temp/aa), '1 sigma of time series'

;   if mm eq 0 then oplot, jday, Eof.time(1,*)/aa, color=4

;   xyouts, 1., 1.1, var(mm), color=1, alignment=0.

;   Axis, XAxis=1, Xticks=10, Xminor=12, XRange

    MULTIPANEL,/Advance,/NoErase ; go to next panel
  endfor

 end

;======================================================================

  @load
  @define_plot_size

  ; site selection with correlation coefficient between KNON and OMC
  Rarr = imp.r_knon_carb[2]  ; correlation coefficient
  Lon  = imp.Lon
  Lat  = imp.lat

  Rcri = 0.7 & CR = strtrim(string(Rcri, format='(F3.1)'),2)

  corr_id = where(rarr ge Rcri)

  mon = jday2month(imp[0].jday)
  jj  = where(mon ge 6 and mon le 8)

 ; Plotting begins

  multipanel, row=2, col=2

  Pos = cposition(2,2,xoffset=[0.1,0.1],yoffset=[0.1,0.1], $
        xgap=0.07,ygap=0.15,order=1)

  if !D.name eq 'PS' then $
    open_device, file='tc_nsk_slope.ps', /color, /ps, /landscape

    id  = corr_id

    n1  = where(imp[id].state eq 'MT')
    n   = ID[n1]
    sitename = imp[n].name+', '+imp[n].state
    location = '!C('+strmid(strtrim(round(imp[n].lat),2),0,4) + 'N, '  $
             + strmid(strtrim(round(imp[n].lon),2),1,4) + 'W)'
    title = ' ';sitename+location
    ; omc vs k
    x = imp[n].knon[jj]   & y = imp[n].carb[jj] 
    scatter, X, Y, pos=pos[*,0], xrange=[0.,0.1], yrange=[0.,10.], $
     xtitle='ns-K (!4l!3g m!u-3!n)', $
     ytitle='TC (!4l!3g m!u-3!n)', $
     title = title

    n1  = where(imp[id].state eq 'NM')
    n   = ID[n1]
    sitename = imp[n].name+', '+imp[n].state
    location = '!C('+strmid(strtrim(round(imp[n].lat),2),0,4) + 'N, '  $
             + strmid(strtrim(round(imp[n].lon),2),1,4) + 'W)'
    title = ' ';sitename+location
    ; bc vs omc
    x = imp[n].knon[jj]  & y = imp[n].carb[jj]
    scatter, X, Y, pos=pos[*,2], xrange=[0.,0.1], yrange=[0.,10.], $
     xtitle='ns-K (!4l!3g m!u-3!n)', $
     title = title

  if !D.name eq 'PS' then close_device

stop

    fld = imp[id].r_knon_omc[0]
    mindata = 0.
    maxdata = 100.

    mapplot, fld, imp[id], pos=pos[*,1], mindata=mindata, maxdata=maxdata,$
    cbformat='(I3)', unit=' '


    fld = imp[id].r_ec_omc[0]
    mindata = 0.
    maxdata = 20.

    mapplot, fld, imp[id], pos=pos[*,3], mindata=mindata, maxdata=maxdata, $
    cbformat='(I2)', unit=' '

  if !D.name eq 'PS' then close_device


  End
