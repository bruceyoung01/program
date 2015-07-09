  if n_elements(file) eq 0 then file = pickfile()

  if (!D.name eq 'PS') then begin
  open_device, filename='out.ps', /ps,  /color, /portrait
  endif

  multipanel, row=4,col=2
  gas = ['SO2','SO4','DMS','MSA']
  djf = [901201L,900101L,900201L]
  jja = [900601L,900701L,900801L]

;  undefine, gas

  cate = ['IJ-AVG-$']
  

  ; Plot data w/ TVMAP
  Plev = [500.]
  
  for ic = 0, 3 do begin

    category = 'IJ-AVG-$'

  for i = 0, 1 do begin
  Undefine, Avgdata
  spec = gas[ic]

  case i of
      0 : begin
          tau = djf 
          ytitle=spec
          end
      1 : begin
          tau = jja 
          ytitle=''
          end
  endcase


  read_ctm_data,file=file,spec=spec,tb=tau,weight=3., $
  Avgdata=avgdata,Xmid=xmid,ymid=ymid,zmid=zmid,category=category
    
   diff = abs(Zmid-Plev[0])
   loc  = where(min(diff) eq diff)
   index = loc(0)
   Press = strtrim(Zmid(index),1)
   print, index

;   TvMap, AvgData(*,*,index), XMid, YMid, $
;      /Countries, /Coasts, /Grid, /Sample, Min_Valid=1e-20, $
;      /CBar, Divisions=6, Title=spec+',  '+Press+'(mb),  '+Avg+'(pptv)', $
;      mindata=0., maxdata=5000.

  if index eq 0 then begin
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
  endif else begin
   case spec of 
    'DMS' : levels=[0.,2.,5.,20.,50.,70.,85.]
    'SO2' : levels=[0.,20.,50.,200.,500.,2000.,6497.]
    'SO4' : levels=[0.,20.,50.,100.,200.,500.,653.]
    'MSA' : levels=[0.,2.,3.,4.,6.,8.,11.]
    'NH3' : levels=[0.,20.,50.,100.,200.,500.,1000.]
    'NH4' : levels=[0.,30.,50.,100.,200.,300.,400.,500.,600.,700.,800.]
    'NO3' : levels=[0.,30.,50.,100.,200.,300.,400.,500.]
     else : Undefine, levels
   endcase
  endelse

   suface = Avgdata(*,*,index)

;   MULTIPANEL,Position=p,margin=0.01

   Tvmap, suface, Xmid, Ymid, /FContour,/C_LINES, ncolors=200, $
   ystyle=1, xstyle=1, C_levels=levels, /conti, /cbar, csfac=0.8, $
   TCsFac = 2.0, margin=[0.06,0.02,0.0,0.03],ytitle=ytitle
   
 endfor

 endfor


   Charsize = 1.5
   Cthick   = 4.0
   xyouts, 0.27, 0.98, 'DJF', /normal, color=1, charsize=Charsize, $
   alignment=0.5, charthick=Cthick

   xyouts, 0.77, 0.98, 'JJA', /normal, color=1, charsize=Charsize, $
   alignment=0.5, charthick=Cthick

   xyouts, 0.02, 0.89, 'SO!d2!n', /normal, color=1, charsize=Charsize, $
   alignment=0.5, charthick=Cthick, orientation=90.

   xyouts, 0.02, 0.63, 'SO!d4!n', /normal, color=1, charsize=Charsize, $
   alignment=0.5, charthick=Cthick, orientation=90.

   xyouts, 0.02, 0.39, 'DMS', /normal, color=1, charsize=Charsize, $
   alignment=0.5, charthick=Cthick, orientation=90.

   xyouts, 0.02, 0.15, 'MSA', /normal, color=1, charsize=Charsize, $
   alignment=0.5, charthick=Cthick, orientation=90.

   
   ; Quit

 if (!D.name eq 'PS') then close_device

  end
