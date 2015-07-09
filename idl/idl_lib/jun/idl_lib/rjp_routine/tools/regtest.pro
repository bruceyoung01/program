

pro regtest,data,header,npp=npp,rad=rad,ts=ts

  ;  readdata,'test.dat',data,names,delim=' '

    spec = [ 'CH3I' ]
    if (keyword_set(NPP)) then $
        spec = [ spec, 'NPP' ]
    if (keyword_set(RAD)) then $
        spec = [ spec, 'RAD' ]
    if (keyword_set(TS)) then $
        spec = [ spec, 'TS' ]

    if (n_elements(spec) eq 1) then begin
        spec = [ spec, 'NPP', 'RAD' ]
        print,'No X flags given, use NPP and RAD !'
    endif


    si = make_selection(header,spec)

    if (min(si) lt 0) then begin
       print,'*** Cannot find a species!'
       return
    endif

    y= reform(data[si[0],*])
    x= data[ [si[1:*]], * ]
    weights=replicate(1.,n_elements(y))
    res=regress(x,y,weights,yfit,const, $
         /relative_weight,sigma,ftest,r,rmul,chisq,status)

    print,'---------------------------'
    print,'Fit of ',spec[0],' versus ',spec[1:*],format='(9A)'

    print,'const=',const,format='(A12,E12.4)'
    print,'res (coeff.)=',transpose(res),format='(A12,3E12.4)'
    print,'sigma=',sigma ,format='(A12,3E12.4)'
    print,'rmul=',rmul,format='(A12,E12.4)'
    print,'r=',r,format='(A12,3E12.4)'
    print,'chisq=',chisq,format='(A12,E12.4)'
    print,'ftest=',ftest,format='(A12,E12.4)'
 ;  if (n_elements(status) gt 0) then $
 ;  print,'status=',status


    nplots = n_elements(spec)-1

    multipanel,nplots,pos=p
    for i=0,nplots-1 do begin
       plot,x[i,*],y,color=1,psym=sym(1),pos=p
       oplot,x[i,*],yfit,color=2,psym=sym(11)

       multipanel,/advance,pos=p,/noerase
    endfor


    multipanel,/off

    return
end

