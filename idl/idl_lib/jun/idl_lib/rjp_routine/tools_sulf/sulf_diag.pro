  pro sulf_diag, File=file, Diag, Plot=plot

  if n_elements(file) eq 0 then file=pickfile()

  if (!D.name eq 'PS') then begin
    open_device, filename='out.ps', /ps,  /portrait, /color
  endif

  if n_elements(Diag) eq 0 then Diag = 'EMIS'

  if Keyword_set(plot) then  multipanel, row=4, col=2

   Diag = strupcase(Diag)


     Case Diag of
          'EMIS' : begin
                   Kind = ['SO2-AN-$','SO2-AC-$','SO2-BIOB','SO2-NV-$', $
                           'SO2-EV-$','SO4-AN-$','DMS-BIOG']

                   Gnum = [252,252,252,252,252,253,251]  ; SO2, SO4, DMS

                   comment = ['SO2 anthropogenic     : ', $
                              'SO2 aircraft          : ', $
                              'SO2 biomass burning   : ', $
                              'SO2 volcanic (NErup)  : ', $
                              'SO2 volcanic (Erup)   : ', $
                              'Sulfate anthropogenic : ', $
                              'DMS oceanic           : '  ]
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
          'DEPO' : begin
                   Kind = ['DRYD-FLX','WETDCV-$','WETDLS-$',$
                           'DRYD-FLX','WETDCV-$','WETDLS-$',$
                           'DRYD-FLX','WETDCV-$','WETDLS-$' ]                   
                   Gnum = [7151,3351,3351, $
                           7152,3352,3352, $
                           7153,3353,3353  ]
                   Comment = ['SO2 dry-deposition       : ', $
                              'SO2 wet-deposition(CONV) : ', $
                              'SO2 wet-deposition(RAIN) : ', $
                              'SO4 dry-deposition       : ', $
                              'SO4 wet-deposition(CONV) : ', $
                              'SO4 wet-deposition(RAIN) : ', $
                              'MSA dry-deposition       : ', $
                              'MSA wet-deposition(CONV) : ', $
                              'MSA wet-deposition(RAIN) : ']         
                   weight = 12. ; average over year
                   spy = 3600.*24.*365.
                   fac = [12.,spy*32./64.,spy*32./64., $
                          12.,spy*32./96.,spy*32./96., $
                          12.,spy*32./96.,spy*32./96.]
                   end
          'BURD' : begin
                   Kind = Replicate('IJ-AVG-$',4)
                   Gnum = Indgen(4) + 51
                   Comment = ['DMS burden : ','SO2 burden : ', $
                              'SO4 burden : ','MSA burden : ']
                   fac  = 32.e-12
                   end                              
     Endcase

     Summary = Strarr(N_elements(Kind))

  
    For In = 0, N_elements(Kind)-1 do begin

        category = Kind(In)
        tracer   = Gnum(In)

      IF (DIAG eq 'BURD') then begin
      
;         tau = nymd2tau(Lindgen(12)*100L+900101L)
      
           for i = 0, 11L do begin
              tau0 = nymd2tau(900101L+100L*i)
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

        read_ctm_data,file=file,tb=900101L,tf=910101L,weight=weight,     $
        Avgdata=avgdata,Xmid=xmid,ymid=ymid,zmid=zmid,category=category, $
        tracer=tracer
   
        tot = strtrim(total(Avgdata)*1.e-9*fac(In),1)
        ndm = n_elements(size(Avgdata,/dim))

        case ndm of
              2 : fld = Avgdata
              3 : fld = total(Avgdata,3)
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

        Summary(In) = comment(In)+tot+' Tg S/yr'

    endfor

    Print, ' '
    Print, '******* Diagnostics for '+Diag+' *********'
    for in = 0, n_elements(Kind)-1 do print, Summary(In)
    Print, ' '
   
   ; Quit

  if (!D.name eq 'PS') then close_device

  end
