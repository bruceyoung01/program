  pro check_depo, file=file, Plot=plot

  if n_elements(file) eq 0 then file=pickfile()

  if (!D.name eq 'PS') then begin
    open_device, filename='out.ps', /ps,  /portrait, /color
  endif

  if keyword_set(plot) then  multipanel, row=3, col=1

  depcate = [Replicate('DRYD-FLX',3),Replicate('WETDCV-$',4),$
             Replicate('WETDLS-$',4)]

  deptrac = [7151,7152,7153,3351,3352,3353,3354, $
             3351,3352,3353,3354]  ; SO2, SO4, MSA

  comment = ['SO2 dry deposition    ', $
             'Sulfate dry deposition', $
             'MSA dry deposition    ']
  

  for in = 0, n_elements(depcate)-1 do begin

    category = depcate[in]
      tracer = deptrac[in]

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

;   print, comment(in)+' : '+tot+'Tg S/yr'

   Undefine, Avgdata

 endfor
   
   ; Quit

  if (!D.name eq 'PS') then close_device

  end
