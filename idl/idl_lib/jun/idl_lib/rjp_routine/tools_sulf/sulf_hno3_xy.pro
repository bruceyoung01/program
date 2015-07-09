  if (!D.name eq 'PS') then begin
  open_device, filename='out.ps', /ps, /color,  /portrait
  endif

  multipanel, row=4, col=2

  ; Plot data w/ TVMAP
  Plev = [959., 894., 468., 231.]
 

; Retrive the data file from the binary punch files 
    category = 'IJ-AVG-$'

      spec = 'SO4'
      file = '../ctm.bpch'
      read_ctm_data,file=file,spec=spec,tb=900101L,tf=910101L,weight=12., $
      Avgdata=sulfate,Xmid=xmid,ymid=ymid,zmid=zmid,category=category

      spec = 'HNO3'
      file = '/users/ctm/rjp/Data/Chem/NO3_H2O2_HNO3.4x5.bpch'
      read_ctm_data,file=file,spec=spec,tb=850101L,tf=860101L,weight=12., $
      Avgdata=nitric_acid,Xmid=xmid,ymid=ymid,zmid=zmid,category=category

      
  for iz = 0, n_elements(Plev)-1 do begin

      diff = abs(Zmid-Plev[iz])
      loc  = where(min(diff) eq diff)
      index = loc(0)
      Press = strtrim(Zmid(index),1)

  for ic = 0, 1 do begin

   case ic of
      1 : suface = sulfate(*,*,index)
      0 : suface = nitric_acid(*,*,index)*1.e12
   endcase

   tavg   = strtrim(mean(reform(suface,n_elements(suface))),1)

   levels = [0,1,3,10,30,100,300,1000,3000,10000,30000]

   case iz of
       n_elements(Plev)-1 : begin        
       Tvmap, suface, Xmid, Ymid, /FContour, ncolors=200, $
       ystyle=1, xstyle=1, C_levels=levels, /conti, csfac=0.8, $
       TCsFac = 1.2, margin=[0.03,0.04,0.01,0.03], /C_LINES, $
       title=Press+'(mb), '+tavg+'(pptv)', /cbar
       end
   else : begin
       Tvmap, suface, Xmid, Ymid, /FContour, ncolors=200, $
       ystyle=1, xstyle=1, C_levels=levels, /conti, csfac=0.8, $
       TCsFac = 1.2, margin=[0.03,0.02,0.01,0.03], /C_LINES,$
       title=Press+'(mb), '+tavg+'(pptv)'
       end
   endcase

 endfor

 endfor
   
   ; Quit

 if (!D.name eq 'PS') then close_device

  end
