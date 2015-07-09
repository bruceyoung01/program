  if (!D.name eq 'PS') then begin
  open_device, filename='nh3_nh4_nit.ps', /ps, /color,  /landscape
  endif

  multipanel, row=4, col=3
  gas = ['NH3','NH4','NO3']

  ; Plot data w/ TVMAP
  Plev = [1000., 894., 468., 231.]
  
  for iz = 0, n_elements(Plev)-1 do begin

    category = 'IJ-AVG-$'
;    tracer   = trac[ic]

  for ic = 0, n_elements(gas)-1 do begin
      spec = gas[ic]
      file = '../ctm.bpch'
      read_ctm_data,file=file,spec=spec,tb=900101L,tf=910101L,weight=12., $
      Avgdata=avgdata,Xmid=xmid,ymid=ymid,zmid=zmid,category=category
      
      diff = abs(Zmid-Plev[iz])
      loc  = where(min(diff) eq diff)
      index = loc(0)
      Press = strtrim(Zmid(index),1)

;   avg  = total(AvgData(*,*,index))/float(N_elements(AvgData(*,*,index)))
;   avg  = strtrim(avg,1)

;   TvMap, AvgData(*,*,index), XMid, YMid, $
;      /Countries, /Coasts, /Grid, /Sample, Min_Valid=1e-20, $
;      /CBar, Divisions=6, Title=spec+',  '+Press+'(mb),  '+Avg+'(pptv)', $
;      mindata=0., maxdata=5000.

   case spec of 
    'DMS' : levels=[1.,2.5,5.,10.,25.,50.]
    'SO2' : levels=[0.,20.,50.,100.,200.,500.,1000.]
    'SO4' : levels=[0.,30.,50.,100.,200.,300.,400.,500.]
    'MSA' : levels=[0.5,1.,1.5,2.,2.5,3.,3.5]
    'NH3' : levels=[0.,20.,50.,100.,200.,500.,1000.]
    'NH4' : levels=[0.,30.,50.,100.,200.,300.,400.,500.,600.,700.,800.]
    'NO3' : levels=[0.,30.,50.,100.,200.,300.,400.,500.]
     else : Undefine, levels
   endcase

   suface = Avgdata(*,*,index)
   tavg   = strtrim(mean(reform(Avgdata(*,*,index),n_elements(Avgdata(*,*,index)))),1)

   levels = [0,1,3,10,30,100,300,1000,3000,10000,30000]

   case iz of
       n_elements(Plev)-1 : begin        
       Tvmap, suface, Xmid, Ymid, /FContour, ncolors=200, $
       ystyle=1, xstyle=1, C_levels=levels, /conti, csfac=0.6, $
       TCsFac = 1.2, margin=[0.03,0.04,0.01,0.03], $
       title=Press+'(mb), '+tavg+'(pptv)', /cbar
       end
   else : begin
       Tvmap, suface, Xmid, Ymid, /FContour, ncolors=200, $
       ystyle=1, xstyle=1, C_levels=levels, /conti, csfac=0.6, $
       TCsFac = 1.2, margin=[0.03,0.02,0.01,0.03],$
       title=Press+'(mb), '+tavg+'(pptv)'
       end
   endcase

 endfor

 endfor
   
   ; Quit

 if (!D.name eq 'PS') then close_device

  end
