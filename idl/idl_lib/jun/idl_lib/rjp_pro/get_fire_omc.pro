
;============================================================================
 pro plotongrid, fld, str, pos=pos, mindata=mindata, maxdata=maxdata, $
  array=array

  if n_elements(fld) eq 0 then return
  if n_elements(str) eq 0 then return
  if n_elements(fld) ne n_elements(str) then $
     message, 'dimensions mismatched'

  @define_plot_size

  modelinfo = ctm_type('GEOS4_30L',res=2)
  gridinfo  = ctm_grid( modelinfo )
  array     = fltarr(gridinfo.imx*gridinfo.jmx)
  div       = array
  ij        = ij_find(obs=str, modelinfo=modelinfo)

  P         = where(fld gt 0.)

  For D = 0, N_elements(P)-1L do begin
      K = P[D]
      M = ij.i[K]+ij.j[K]*gridinfo.imx

      array[M] = array[M] + FLD[K]
      div[M]   = div[M] + 1.
  End

  P = where(div gt 0.)
  array[P] = array[P] / div[P]

  array = reform(array, gridinfo.imx, gridinfo.jmx)

  plot_region, array, /sample, min_valid=1.e-10, /cbar, $
   divis=4, maxdata=maxdata, mindata=mindata, position=pos

 end

;======================================================================

  @load

  @define_plot_size


  ; site selection with correlation coefficient between KNON and OMC
  Rarr = imp.r_knon_omc[2]  ; correlation coefficient
  Lon  = imp.Lon
  Lat  = imp.lat

  Rcri = 0.7 & CR = strtrim(string(Rcri, format='(F3.1)'),2)

  corr_id = where(rarr ge Rcri)

  mon = jday2month(imp[0].jday)
  jj  = where(mon ge 7 and mon le 8)

 ; Plotting begins

  multipanel, row=2, col=2

  Pos = cposition(2,2,xoffset=[0.1,0.1],yoffset=[0.1,0.1], $
        xgap=0.1,ygap=0.15,order=0)

  if !D.name eq 'PS' then $
    open_device, file='omc_tseries.ps', /color, /ps, /landscape

    ID = indgen(n_elements(imp))

    mindata = 0.
    maxdata = 1.

    fld = imp[id].r_knon_omc[2]
    mapplot, fld, imp[ID], pos=pos[*,0], mindata=mindata, maxdata=maxdata

    mindata = 0.
    maxdata = 2.

    fld = imp[id].r_knon_omc[1]
    mapplot, fld, imp[ID], pos=pos[*,1], mindata=mindata, maxdata=maxdata, $
    unit='intercept'

    mindata = 0.
    maxdata = 5.

    array = composite(imp[id].omc[jj])
    fld   = array.mean
    mapplot, fld, imp[id], pos=pos[*,2], mindata=mindata, maxdata=maxdata, $
    missing=0., unit='[!4l!3g m!u-3!n]'


    inter = imp[id].r_knon_omc[1]
    inter = make_zero(inter, val='0')
    array = composite(imp[id].omc[jj])
    fld   = array.mean-inter

    mapplot, fld, imp[id], pos=pos[*,3], mindata=mindata, maxdata=maxdata, $
    missing=0., unit='[!4l!3g m!u-3!n]'

stop

   for d = 0, n_elements(corr_id)-1 do begin
    ID = corr_id[D]
    erase
    fld = imp[id].r_knon_omc[2]
    mapplot, fld, imp[ID], pos=pos[*,0], mindata=mindata, maxdata=maxdata
    tseries, imp[id], pos=pos[*,1], yrange=[0.,10]

    ; omc vs k
    x = imp[id].knon[jj]   & y = imp[id].omc[jj] 
    scatter, X, Y, pos=pos[*,2], xrange=[0.,0.1]

    ; bc vs omc
    x = imp[id].ec[jj]  & y = imp[id].omc[jj]
    scatter, X, Y, pos=pos[*,3], xrange=[0.,0.1]

    halt
   end


;    plotongrid, fld, imp[id], mindata=mindata, maxdata=maxdata


  if !D.name eq 'PS' then close_device


  End
