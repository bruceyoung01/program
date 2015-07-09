  pro carb_diag, File=file, Diag, time=time, Plot=plot

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
                   Kind = ['BLKC-SR$','ORGC-SR$']

                   Gnum = [Replicate(5493,2)]  ; Carbon

                   comment = ['Black Carbon       : ', $ 
                              'Organic Carbon     : ']

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
          'WETD' : begin
                   Kind = ['WETDCV-$','WETDLS-$', $
                           'WETDCV-$','WETDLS-$'  ]               
                   Gnum = [3391,3391, $
                           3392,3392  ]
                   Comment = ['BC wet-deposition(CONV) : ', $
                              'BC wet-deposition(RAIN) : ', $
                              'OC wet-deposition(CONV) : ', $
                              'OC wet-deposition(RAIN) : '  ]

                   weight = 12. ; average over year
                   spy = 3600.*24.*365.
                   fac = [Replicate(spy,12)]
                   end
          'DRYD' : begin
                   Kind = Replicate('DRYD-FLX',4)
                   Gnum = [7191,7193,7192,7194]
                   Comment = ['BC Hydrophilic dry-deposition: ', $
                              'BC Hydrophobic dry-deposition: ', $
                              'OC Hydrophilic dry-deposition: ', $
                              'OC Hydrophobic dry-deposition: '  ]
                   weight = 1. ; Sum over the year
                   fac    = [Replicate(1.,N_elements(Kind))]
                   end
          'BURD' : begin
                   Kind = Replicate('IJ-AVG-$',4)
                   Gnum = [91,93,92,94]
                   Comment = ['BC(Hydrophilic) burden : ', $
                              'BC(Hydrophobic) burden : ', $
                              'OC(Hydrophilic) burden : ', $
                              'OC(Hydrophobic) burden : ']
                   fac  = 12.e-12
                   end                              
     Endcase

     Summary = ' '
  
    For In = 0, N_elements(Kind)-1 do begin

        category = Kind(In)
        tracer   = Gnum(In)

      IF (DIAG eq 'BURD') then begin
      
;         tau = nymd2tau(Lindgen(12)*100L+900101L)
      
           for ik = 0, 11L do begin
              tau0 = nymd2tau(20000101L+100L*ik)
              data = ctm_burden('IJ-AVG-$',Filename=file, $
                                 Tracer=tracer, Tau0=tau0, Ptau0=tau0)
              if ik eq 0 then $
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

        Summary = [Summary,comment(In)+tot+' Tg/yr']
        wait, 4
    endfor

    Print, ' '
    Print, '******* Diagnostics for '+Diag+' *********'
    for in = 1, n_elements(Kind) do print, Summary(In)
    Print, ' '
   
   ; Quit

  if (!D.name eq 'PS') then close_device

  end
