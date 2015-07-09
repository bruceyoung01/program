  pro test_dust, File=file, Diag, time=time, Plot=plot

  if n_elements(file) eq 0 then file=pickfile()

  if (!D.name eq 'PS') then begin
    open_device, filename='out.ps', /ps,  /portrait, /color
  endif

  if n_elements(Diag) eq 0 then Diag = 'EMIS'

  if n_elements(time) eq 0 then return
;  Time is 1d vector containg starting and ending value.
     Tb = time[0]
     Tf = time[1]

  if Keyword_set(plot) then  multipanel, row=6, col=2

   Diag = strupcase(Diag)


     Case Diag of
          'EMIS' : begin
                   Kind = ['DUST-SR$']

                   Gnum = [5491]  ; Dust

                   comment = ['Dust source        : ']

                   weight = 1.  ; Sum over year
                   fac    = [Replicate(1.,N_elements(Kind))]
                   end
          'PROD' : begin
                   Kind = [Replicate('PORL-L=$',7)]
                   Gnum = Indgen(7)+2251
                   comment = ['SO2 production from DMS+OH  : ', $
                              'SO2 production from DMS+NO3 : ', $
                              'SO2 production total        : ', $
                              'MSA production from DMS     : ', $
                              'SO4 production from gas rea : ', $
                              'SO4 production from aqu rea : ', $
                              'SO4 production total        : ' ]
                   weight = 1. ; sum over year
                   fac    = [Replicate(1.,N_elements(Kind))]
                   end
          'DRYD' : begin
                   Kind = Replicate('DRYD-VEL',4)                   
                   Gnum = [7291,7292,7293,7294]
                   Comment = ['Dust1 dry-deposition : ', $
                              'Dust2 dry-deposition : ', $
                              'Dust3 dry-deposition : ', $
                              'Dust4 dry-deposition : '  ] 
                   weight = 1. ; sum over the year
                   fac    = Replicate(1.,N_elements(Kind))
                   end
          'WETD' : begin
                   Kind = [Replicate('WETDCV-$',4), $
                           Replicate('WETDLS-$',4)  ]
                   Gnum = [3391,3392,3393,3394, $
                           3391,3392,3393,3394]

                   Comment = ['DUST1 wet-deposition(CONV) : ', $
                              'DUST2 wet-deposition(CONV) : ', $
                              'DUST3 wet-deposition(CONV) : ', $
                              'DUST4 wet-deposition(CONV) : ', $
                              'DUST1 wet-deposition(RAIN) : ', $
                              'DUST2 wet-deposition(RAIN) : ', $
                              'DUST3 wet-deposition(RAIN) : ', $
                              'DUST4 wet-deposition(RAIN) : '  ]
                   weight = 12. ; Average over the year
                   spy = 3600.*24.*365.
                   fac = Replicate(spy,8)
                   end
          'BURD' : begin
                   Kind = Replicate('IJ-AVG-$',4)
                   Gnum = Indgen(4) + 91
                   Comment = ['DUST1 burden : ','DUST2 burden : ', $
                              'DUST3 burden : ','DUST4 burden : ']
                   fac  = 29.e-12
                   end                              
     Endcase

     Summary = Strarr(N_elements(Kind))

  
    For In = 0, N_elements(Kind)-1 do begin

        category = Kind(In)
        tracer   = Gnum(In)

      IF (DIAG eq 'BURD') then begin
      
;         tau = nymd2tau(Lindgen(12)*100L+900101L)
      
           for i = 0, 11L do begin
              tau0 = nymd2tau(20000101L+100L*i)
              data = ctm_burden('IJ-AVG-$',Filename=file, $
                                 Tracer=tracer, Tau0=tau0, Ptau0=tau0)
              if i eq 0 then $
                   sum = data  $
              else sum = sum + data 
           endfor
              sum = sum / 12.
              tot = strtrim(sum*fac,1)
              Undefine, sum

      end else begin

        read_ctm_data,file=file,tb=Tb,tf=Tf,weight=weight,     $
        Avgdata=avgdata,Xmid=xmid,ymid=ymid,zmid=zmid,         $
        category=category,tracer=tracer
   
        tot = strtrim(total(Avgdata)*1.e-9*fac(In),1)
        ndm = n_elements(size(Avgdata,/dim))
        dim = size(Avgdata,/dim)

        case ndm of
              2 : fld = Avgdata
              3 : begin
                  fld = total(Avgdata,3)
                  subtot = strarr(dim(2))
                  for kkk = 0, dim(2)-1 do $
                  subtot(kkk) = strtrim(total(Avgdata(*,*,kkk))*1.e-9,1)
                  print, subtot
                  end
            else: print, 'something goes wrong'
        endcase

        if Keyword_set(plot) then begin
           Xax = xmid
           Yax = ymid 
           Tvmap, fld, Xax, Yax, $
           /Countries, /Coasts, /Grid, /Sample, Min_Valid=1e-20, $
           /CBar, Divisions=3, Title=category+', '+tot+' Tg/yr', $
           unit='S kg/yr'
           ;   margin=[0.03,0.04,0.01,0.04]
        endif
     endelse

        Summary(In) = comment(In)+tot+' Tg/yr'

    endfor

    Print, ' '
    Print, '******* Diagnostics for '+Diag+' *********'
    for in = 0, n_elements(Kind)-1 do print, Summary(In)
    Print, ' '
   
   ; Quit

  if (!D.name eq 'PS') then close_device

  end
