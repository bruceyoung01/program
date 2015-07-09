  pro check_emis, file=file, Plot=plot

  if n_elements(file) eq 0 then file=pickfile()

  if (!D.name eq 'PS') then begin
    open_device, filename='out.ps', /ps,  /portrait, /color
  endif

  if Keyword_set(plot) then multipanel, row=4, col=2

  emscate = ['SO2-AN-$','SO2-AC-$','SO2-BIOB','SO2-NV-$', $
             'SO2-EV-$','SO4-AN-$','DMS-BIOG']

  emstrac = [252,252,252,252,252,253,251]  ; DMS, SO2, SO4

  comment = ['SO2 anthropogenic    ', $
             'SO2 aircraft         ', $
             'SO2 biomass burning  ', $
             'SO2 volcanic (NErup) ', $
             'SO2 volcanic (Erup)  ', $
             'Sulfate anthropogenic', $
             'DMS oceanic          '  ]

  for ic = 0, 6 do begin

    category = emscate[ic]
    tracer   = emstrac[ic]

      read_ctm_data,file=file,tb=900101L,tf=910101L,weight=1., $
      Avgdata=avgdata,Xmid=xmid,ymid=ymid,zmid=zmid,category=category,$
      tracer=tracer
   
;   zonal = total(AvgData,1)/float(n_elements(Xmid))
;  Avgdata is the averaged emmision in kg/s
;  so to get the total multiply by 3600.*24.*365.25*1.e-9 for Tg/yr

   tot = strtrim(total(Avgdata)*1.e-9,1)
   ndm = n_elements(size(Avgdata,/dim))

   case ndm of
     2 : fld = Avgdata
     3 : fld = total(Avgdata,3)
   else: print, 'something goes wrong'
   endcase

   Xax = xmid
   Yax = ymid

   if Keyword_set(plot) then begin
      Tvmap, fld, Xax, Yax, $
      /Countries, /Coasts, /Grid, /Sample, Min_Valid=1e-20, $
      /CBar, Divisions=3, Title=category+', '+tot+' Tg/yr',unit='S kg/yr'
;   margin=[0.03,0.04,0.01,0.04]
   endif

   print, comment(ic)+' : '+tot+' Tg S/yr'

 endfor
   
   ; Quit

  if (!D.name eq 'PS') then close_device

  end
