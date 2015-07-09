;======================================================================

  @load

  @define_plot_size


  ; site selection with correlation coefficient between KNON and OMC
  Rarr = imp.r_knon_omc[2]  ; correlation coefficient
  Lon  = imp.Lon
  Lat  = imp.lat

  Rcri = 0.7 & CR = strtrim(string(Rcri, format='(F3.1)'),2)


 ; Plotting begins

  multipanel, row=2, col=2

  Pos = cposition(2,2,xoffset=[0.1,0.1],yoffset=[0.1,0.1], $
        xgap=0.1,ygap=0.15,order=1)

  if !D.name eq 'PS' then $
    open_device, file='omc_tseries.ps', /color, /ps, /landscape


  ; correlation coefficient
    mindata = 0.
    maxdata = 1.

    id  = indgen(n_elements(imp))
    fld = imp[id].r_knon_omc[2]
    mapplot, fld, imp[id], pos=pos[*,0], mindata=mindata, maxdata=maxdata
    tseries, imp[id], pos=pos[*,1], yrange=[0.,6], /legend

    id  =  where(rarr ge 0.7)
    fld = imp[id].r_knon_omc[2]
    mapplot, fld, imp[id], pos=pos[*,2], mindata=mindata, maxdata=maxdata
    tseries, imp[id], pos=pos[*,3], yrange=[0.,6]

    
  if !D.name eq 'PS' then close_device


  End
