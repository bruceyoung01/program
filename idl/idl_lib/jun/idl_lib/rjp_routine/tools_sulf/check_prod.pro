  pro check_prod, file=file, Plot=plot

  if n_elements(file) eq 0 then file=pickfile()

  if (!D.name eq 'PS') then begin
    open_device, filename='out.ps', /ps,  /portrait, /color
  endif

  if keyword_set(plot) then  multipanel, row=3, col=2

  emscate = ['PORL-L=$']

;           dms+oh,dms+no3,so2_dms,msa_dms,so4_gas,so4_aq,so4_so2
  emstrac = [2251,2252,2253,2254,2255,2256,2257] 
  comment = ['SO2 production from DMS+OH  : ', $
             'SO2 production from DMS+NO3 : ', $
             'SO2 production total        : ', $
             'MSA production from DMS     : ', $
             'SO4 production from gas rea : ', $
             'SO4 production from aqu rea : ', $
             'SO4 production total        : ' ]
  
  for ic = 0, n_elements(emscate)-1 do begin

    category = emscate[ic]

  for i = 0, n_elements(emstrac)-1 do begin

    tracer   = emstrac[i]

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
  
   if keyword_set(plot) then begin
   Tvmap, fld, Xax, Yax, $
   /Countries, /Coasts, /Grid, /Sample, Min_Valid=1e-20, $
   /CBar, Divisions=3, Title=category+', '+tot+' Tg/yr',unit='S kg/yr'
;   margin=[0.03,0.04,0.01,0.04]
   endif

   print, comment(i)+tot+' Tg S/yr'
 endfor

 endfor
   
   ; Quit

  if (!D.name eq 'PS') then close_device

  end
