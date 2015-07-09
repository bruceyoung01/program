 function goes_retrieve, files=files, diag=diag, tracer=tracer

 if n_elements(files) eq 0 then return, -1
 if n_elements(diag) eq 0 then diag='ij-avg-$'

 for d = 0, n_elements(files)-1 do begin
   ctm_get_data, datainfo, diag, file=files[D], tracer=tracer
   if d eq 0 then array = *(datainfo.data) else $
   array = array + *(datainfo.data)
 end

 return, array/float(N_elements(files))

 end

;===================================================================

 function rd_driver, mm, spec=spec, lev=lev

 if n_elements(mm) eq 0 then return, -1
 if n_elements(spec) eq 0 then return, -1
 if n_elements(lev) eq 0 then lev=0

 std = '/users/ctm/rjp/Asim/icartt/output/emis_trop/'
 sen = '/users/ctm/rjp/Asim/icartt_nofire/output/wo_all_trop/'
 
 fi_std = collect(std+'ctm.bpch.2004'+mm+'*')
 fi_sen = collect(sen+'ctm.bpch.2004'+mm+'*')

 ctm_tracerinfo, spec, name=name, index=index
 tracer = min(index)
 diag   = 'ij-avg-$'

 c_std = goes_retrieve( files=fi_std, diag=diag, tracer=tracer)
 c_sen = goes_retrieve( files=fi_sen, diag=diag, tracer=tracer)

 return, {mm:mm, spec:spec, std:c_std[*,*,lev], sen:c_sen[*,*,lev]}
 
 end

;==================================================================

 function rd_gc, lev=lev

  mm = ['06','07','08']
  sp = ['co','ox']

  for n = 0, n_elements(sp)-1 do begin    
  for m = 0, n_elements(mm)-1 do begin
     out = rd_driver( mm[m], spec=sp[n], lev=lev )
     if n_elements(str) eq 0 then str = out else str = [str, out]
  end
  end

  return, str

 end

;===================================================================
  @define_plot_size

  modelinfo = ctm_type('GEOS4_30L',res=2)
  gridinfo  = ctm_grid(modelinfo)
  IMX = gridinfo.imx
  JMX = gridinfo.jmx
  lev = 7 ; 500 mb

 if n_elements(str) eq 0 then str = rd_gc(lev=lev)
 if n_elements(std) eq 0 then std = rd_model_us()
 if n_elements(sen) eq 0 then sen = rd_model_us(/nofire)

 if !D.name eq 'PS' then $
   open_device, file='co_o3_model.ps', /color, /ps, /landscape


 Jday = std[0].jday
 mon  = jday2month(Jday)
 jj   = where(mon ge 7 and mon le 8)

 idco = where(str.spec eq 'co')
 idox = where(str.spec eq 'ox')


 co_dif = str[idco].std-str[idco].sen
 ox_dif = str[idox].std-str[idox].sen

 ; plotting begins
 omargin = [0.00,0.05,0.05,0.05]
 margin  = [0.12,0.05,0.,0.05]
 multipanel, row=2, col=2, omargin=omargin
 
 fld = total(co_dif[*,*,1:2],3)/2.
 fus = region_only(fld, region='USCONT')
 sid = where(fus ge 10.)

 plot_region, fld, /sample, /cbar, divis=5, $
  maxdata=40, margin=margin, charthick=charthick, $
  cbposition=[0.2,0.1,0.8,0.2], unit='[ppbv]'

 xyouts, 0.42, 0.87, '(a)', color=1, /normal, $
  charsize=charsize, charthick=dcharthick
 xyouts, 0.42, 0.62, '!4D!3CO', color=0, /normal, $
  charsize=charsize, charthick=dcharthick

 MULTIPANEL,position=pos

 ID    = std.id
 p     = mwhere(sid, ID)
 array = composite(std[p].co, /first)    

yrange = [120,250]
 ytitle = 'Concentrations (ppbv)'
 xtitle = 'Julian day of year 2004'

 pos = [pos[0], pos[1]*1.1, pos[2], pos[3]]
 plot, jday, array.mean, color=1, line=0,          $
    xstyle=1, xrange=xrange,                        $
    yrange=yrange, symsize=symsize, thick=dthick,   $
    ystyle=1, charthick=charthick,                  $
    ytitle=ytitle, position=pos, charsize=charsize, $
    xtitle=xtitle, Yticks=YTicks, yminor=1

 array = composite(sen[p].co, /first)    
 oplot, jday, array.mean, color=2, line=0, thick=dthick

 xyouts, 0.65, 0.87, 'CO', color=1, /normal, $
  charsize=charsize, charthick=dcharthick
 xyouts, 0.90, 0.87, '(b)', color=1, /normal, $
  charsize=charsize, charthick=dcharthick


 multipanel, /advance, /noerase

;;ox

 mindata = 0
 maxdata = 6
 fld = total(ox_dif[*,*,1:2],3)/2.
 fus = region_only(fld, region='USCONT')
 sid = where(fus ge 2.)

 plot_region, fld, /sample, /cbar, divis=4, $
  maxdata=maxdata, mindata=mindata,  margin=margin, cbformat='(i2)', $
  cbposition=[0.2,0.1,0.8,0.2], unit='[ppbv]', charthick=charthick

 xyouts, 0.42, 0.425, '(c)', color=1, /normal, $
  charsize=charsize, charthick=dcharthick
 xyouts, 0.42, 0.17, '!4D!3O!d3!n', color=0, /normal, $
  charsize=charsize, charthick=dcharthick


 MULTIPANEL,position=pos

 ID    = std.id
 p     = mwhere(sid, ID)
 array = composite(std[p].ox, /first)    

 yrange = [20,60]
 ytitle = 'Concentrations (ppbv)'
 xtitle = 'Julian day of year 2004'

 pos = [pos[0], pos[1]+0.05, pos[2], pos[3]]
 plot, jday, array.mean, color=1, line=0,          $
    xstyle=1, xrange=xrange,                        $
    yrange=yrange, symsize=symsize, thick=dthick,   $
    ystyle=1, charthick=charthick,                  $
    ytitle=ytitle, position=pos, charsize=charsize, $
    xtitle=xtitle, Yticks=YTicks, yminor=1

 array = composite(sen[p].ox, /first)    
 oplot, jday, array.mean, color=2, line=0, thick=dthick

 xyouts, 0.65, 0.425, 'O!d3!n', color=1, /normal, $
  charsize=charsize, charthick=dcharthick
 xyouts, 0.90, 0.425, '(d)', color=1, /normal, $
  charsize=charsize, charthick=dcharthick

  if !D.name eq 'PS' then close_device

 end
