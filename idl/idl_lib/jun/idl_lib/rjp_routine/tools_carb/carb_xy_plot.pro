  file = '/scratch/rjp/run_carb_4x5/ctm.bpch_1st'

  if n_elements(file) eq 0 then file = pickfile()

  if (!D.name eq 'PS') then begin
  open_device, filename='out.ps', /ps,  /color, /portrait
  endif

  multipanel, row=2,col=2

  tracerV = [91,93,92,94]
  specV   = ['BC','BC','OC','OC']
  surface = fltarr(72,46,4)

 for ic = 0, n_elements(tracerV)-1 do begin
    tracer = tracerV(ic)
    spec   = specV(ic)

  for ik = 0, 11L do begin
    tau0 = nymd2tau(20000101L+100L*ik)
    data = ctm_burden('IJ-AVG-$',Filename=file, $
                      Tracer=tracer, Tau0=tau0, Ptau0=tau0, $
                      XMid=XMid, YMid=YMid,  $
                      Cmole=Cmole,area=area)
              if ik eq 0 then $
                   sum = total(Cmole*12.,3)/area  $
              else sum = sum + total(Cmole*12.,3)/area
  endfor
             Avgdata = sum / 12.
             Undefine, sum


;   Tvmap, Avgdata, Xmid, Ymid, /conti, /cbar, divis=7, /sample

   surface(*,*,ic) = avgdata

   case spec of 
    'DMS' : levels=[0.,30.,100.,200.,500.,1000.,1907.]
    'SO2' : levels=[0.,30.,100.,500.,2000.,10000.,87991.]
    'SO4' : levels=[0.,30.,100.,200.,1000.,2000.,5167.]
    'MSA' : levels=[0.,2.,5.,10.,20.,40.,60.]
    'NH3' : levels=[0.,20.,50.,100.,200.,500.,1000.]
    'NH4' : levels=[0.,30.,50.,100.,200.,300.,400.,500.,600.,700.,800.]
    'NO3' : levels=[0.,30.,50.,100.,200.,300.,400.,500.]
     else : Undefine, levels
   endcase

 endfor

;   MULTIPANEL,Position=p,margin=0.01

  multipanel, row=2,col=1

  OC = surface(*,*,2)+surface(*,*,3)
  BC = surface(*,*,0)+surface(*,*,1)

   Tvmap, OC, Xmid, Ymid, /FContour,/C_LINES, ncolors=155, $
   ystyle=1, xstyle=1, /conti, /cbar, csfac=0.8, $
   TCsFac = 2.0, margin=[0.06,0.02,0.03,0.05],ytitle=ytitle, $
   C_levels=[0.,0.001,0.0015,0.002,0.005,0.012,0.03], $
   CBFormat='(f5.3)',title='Column Mass (g m!u-2!n)'

   Tvmap, BC, Xmid, Ymid, /FContour,/C_LINES, ncolors=155, $
   ystyle=1, xstyle=1, /conti, /cbar, csfac=0.8, $
   TCsFac = 2.0, margin=[0.06,0.02,0.03,0.05],ytitle=ytitle, $
   C_levels=[0.,0.00001,0.0001,0.001,0.0014,0.002,0.005], $
   CBFormat='(f5.3)'

   Xyouts, 0.1, 0.97, 'OC  Avg 0.0016', /normal, color=1
   Xyouts, 0.1, 0.47, 'BC  Avg 0.0004', /normal, color=1

      
   ; Quit

 if (!D.name eq 'PS') then close_device

  end
