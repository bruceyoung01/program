  pro sulf_yz_plot, file=file

  if n_elements(file) eq 0 then file = pickfile()

  if (!D.name eq 'PS') then begin
  open_device, filename='out.ps', /ps,  /landscape
  endif

  multipanel, row=2, col=2
  gas = ['SO2','SO4','DMS','MSA']
;  undefine, gas

  cate = ['IJ-AVG-$']
  

  ; Plot data w/ TVMAP
  Plev = [1000., 894., 468., 201.]
  
  for ic = 0, 3 do begin

    category = cate[0]
;    tracer   = trac[ic]

  for i = 0, 0 do begin
  Undefine, Avgdata
  spec = gas[ic]
  read_ctm_data,file=file,spec=spec,tb=900101L,tf=910101L,weight=12., $
  Avgdata=avgdata,Xmid=xmid,ymid=ymid,zmid=zmid,category=category
    
;   diff = abs(Zmid-Plev[iz])
;   loc  = where(min(diff) eq diff)
;   index = loc(0)
;   Press = strtrim(Zmid(index),1)
;   avg  = total(AvgData(*,*,index))/float(N_elements(AvgData(*,*,index)))
;   avg  = strtrim(avg,1)

;   TvMap, AvgData(*,*,index), XMid, YMid, $
;      /Countries, /Coasts, /Grid, /Sample, Min_Valid=1e-20, $
;      /CBar, Divisions=6, Title=spec+',  '+Press+'(mb),  '+Avg+'(pptv)', $
;      mindata=0., maxdata=5000.

   case spec of 
    'DMS' : levels=[1.,2.5,5.,10.,25.,50.]
    'SO2' : levels=[0.,20.,50.,100.,200.,500.,1000.]
    'SO4' : levels=[0.,30.,50.,100.,200.,300.,400.,500.,600.]
    'MSA' : levels=[0.5,1.,1.5,2.,2.5,3.,3.5,4.]
    'NH3' : levels=[0.,20.,50.,100.,200.,500.,1000.]
    'NH4' : levels=[0.,30.,50.,100.,200.,300.,400.,500.,600.,700.,800.]
    'NO3' : levels=[0.,30.,50.,100.,200.,300.,400.,500.]
     else : Undefine, levels
   endcase

   zonal = total(AvgData,1)/float(n_elements(Xmid))

   Tvplot, zonal, Ymid, Zmid, /Contour, C_colors=1, $
   yrange=[1000.,100.], ystyle=1, xstyle=1, C_levels=levels, title=spec,$
   ytitle='Pressure(mb)', xtitle='Latitude',margin=[0.05,0.03,0.02,0.07]

 endfor

 endfor
   
   ; Quit

 if (!D.name eq 'PS') then close_device

  end
