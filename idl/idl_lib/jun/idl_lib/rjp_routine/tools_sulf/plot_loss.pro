 multipanel, /off
 erase

  file = '../ctm.bpch'
  cate = ['WETDLS-$','WETDCV-$']
  mtracer = [3352]

 array = fltarr(46,20,3)
        ModelInfo = CTM_TYPE( 'GEOS1', res=4 )
        GridInfo  = CTM_GRID( ModelInfo )
        Aream2   = CTM_BOXSIZE( GridInfo, /GEOS, /m2)
;
;        ModelInfo = CTM_TYPE( 'GEOS1', res=4 )
;        GridInfo  = CTM_GRID( ModelInfo )
;        VolumeCm3 = CTM_BOXSIZE( GridInfo, /GEOS, /Volume, /cm3 )

 for i = 0, n_elements(cate)-1 do begin

  tracer = mtracer(0)
  category = cate(i)
  read_ctm_data,file=file,tb=900101L,tf=910101L,weight=12.,tracer=tracer, $
  Avgdata=avgdata,Xmid=xmid,ymid=ymid,zmid=zmid,category=category

; Avgdata has a unit kg/s
; convert from kg(so4)/s to mg(S)/m2/yr

  Avgdata = Avgdata*32./96.*1.e6
  tsum  = total(Avgdata,3)/Aream2
  zonal = total(tsum,1)*365.25*3600.*24./72.

  if i eq 0 then plot, Ymid, zonal, color=1, line=i $
  else oplot, Ymid, zonal, color=1, line=i

;   Tvplot, zonal, Ymid, Zmid, /FContour, /C_line,$
;   yrange=[1000.,100.], ystyle=1, xstyle=1, title=spec,$
;   ytitle='Pressure(mb)', xtitle='Latitude',margin=[0.05,0.02,0.02,0.03]
;   C_levels=[-1.4,-1.2,-1.0,-0.8,-0.6,-0.4,-0.2,0.,0.1],/cbar

 endfor

  stop

  fac = fltarr(46,20)
  fac(*,*) = 0.
  for i = 0, 45 do begin
  for j = 0, 19 do begin
    tot = array(i,j,1)+array(i,j,2)
    if tot ne 0 then fac(i,j) = array(i,j,1)/tot
  endfor
  endfor

   level = findgen(11)*0.1
   Tvplot, fac , Ymid, Zmid, /FContour,/C_LINES, ncolors=150, $
   yrange=[1000.,100.], ystyle=1, xstyle=1,  title=spec, $
   ytitle='Pressure(mb)', xtitle='Latitude',margin=[0.05,0.02,0.02,0.03],$
   C_levels=level,/cbar


  end
