 multipanel, /off

  file = '../ctm.bpch'
  category = 'PORL-L=$'

  mtracer = [2252,2254,2255]

 array = fltarr(46,20,3)
 boxh  = fltarr(72,46,20)

 openr,il,'boxheight.bpch',/f77,/get
 readu,il,boxh
 free_lun,il

 
  read_ctm_data,file=file,spec='SO4',tb=900101L,tf=910101L,weight=1., $
  Avgdata=so4ems,Xmid=xmid,ymid=ymid,zmid=zmid,category='SO4-AN-$'

        ModelInfo = CTM_TYPE( 'GEOS1', res=4 )
        GridInfo = CTM_GRID( ModelInfo )
        Aream2   = CTM_BOXSIZE( GridInfo, /GEOS, /m2)

  
  so4ems = total(so4ems,3)/Aream2 * 1.e6

 for i = 0, n_elements(mtracer)-1 do begin

  tracer = mtracer(i)
  read_ctm_data,file=file,tb=900101L,tf=910101L,weight=1.,tracer=tracer, $
  Avgdata=avgdata,Xmid=xmid,ymid=ymid,zmid=zmid,category=category

; Avgdata has a unit kg/cm3/yr
; convert from kg(so4)/cm3/yr to kg(S)/cm2/yr

  Avgdata = Avgdata*boxh*32./96.*1.e10
  zonal = total(total(Avgdata,3),1)/72.
  
  if i eq 0 then plot, Ymid, zonal+total(so4ems,1)/72., color=1, line=i, yrange=[0.,300.] $
  else oplot, Ymid, zonal, color=1, line=i

;   Tvplot, zonal, Ymid, Zmid, /Contour, C_colors=1, $
;   yrange=[1000.,100.], ystyle=1, xstyle=1, C_levels=levels, title=spec,$
;   ytitle='Pressure(mb)', xtitle='Latitude',margin=[0.05,0.02,0.02,0.03]

;  array(*,*,i) = zonal
 endfor

  oplot, Ymid, total(so4ems,1)/72., color=1, line=4

  fac = fltarr(46,20)
  fac(*,*) = 0.
  for i = 0, 45 do begin
  for j = 0, 19 do begin
    tot = array(i,j,1)+array(i,j,2)
    if tot ne 0 then fac(i,j) = array(i,j,1)/tot
  endfor
  endfor

;   level = findgen(11)*0.1
;   Tvplot, fac , Ymid, Zmid, /FContour,/C_LINES, ncolors=150, $
;   yrange=[1000.,100.], ystyle=1, xstyle=1,  title=spec, $
;   ytitle='Pressure(mb)', xtitle='Latitude',margin=[0.05,0.02,0.02,0.03],$
;   C_levels=level,/cbar


  end
