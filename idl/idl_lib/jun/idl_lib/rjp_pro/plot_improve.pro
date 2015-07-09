
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

;========================================================================

 function make_matrix, fld, str

  if n_elements(fld) eq 0 then return, -1
  if n_elements(str) eq 0 then return, -1

  data      = transpose(fld) ; convert to [site, time]
  dim       = size(data, /dim)
  data      = make_zero(data, val='NaN')
  avg       = fltarr(dim[0])
  For D = 0, dim[0]-1 do avg[D] = mean(data[D,*], /NaN)

  ; Filling missing data with mean value
  For D = 0, dim[0]-1 do begin
      sample = reform(Data[D,*])
      p = where(finite(sample) eq 0)
      if p[0] ne -1 then sample[p] = avg[D]
      Data[D,*] = sample
  End

  modelinfo = ctm_type('GEOS4_30L',res=2)
  gridinfo  = ctm_grid( modelinfo )
  ij        = ij_find(obs=str, modelinfo=modelinfo)
  index     = ij.i+ij.j*gridinfo.imx
  ii        = sort(index)
  jj        = uniq(index[ii])
  mij       = index[ii[jj]]

  array     = fltarr(N_elements(mij), dim[1]) ; on model grid [grid, time]
  div       = fltarr(N_elements(mij))

  For D = 0, N_elements(index)-1L do begin
      K = index[D]
      M = where(MIJ eq K)
      array[M,*] = array[M,*] + Data[D,*]
      div[M]     = div[M] + 1.
  End

  For D = 0, N_elements(div)-1 do array[D,*] = array[D,*] / div[D]

  ; test
;  t = fltarr(144L*91L)
;  for i = 0, n_elements(mij)-1 do t[mij[i]] = array[i,5]
;  t = reform(t, 144, 91)
;  plotongrid, reform(fld[5,*]), str, array=q

  return, {array:array, ij:mij}

end

;========================================================================

 pro ploteof, eof, ij=ij, NoM=NoM, Jday=Jday

  multipanel, row=NoM, col=2

  margin = [0.01,0.05,0.01,0.05]

  IMX  = 144L
  JMX  = 91L  
  Fd2d = Replicate(-999., IMX*JMX)
  sign = Replicate(1., NoM)

  sign = [1.,1.,-1.]
  for mm = 0, NoM-1 do begin

   MODE     = Reform(Eof.mode(mm,*)*sign(mm))
   FD2D[IJ] = MODE
   maxdata  = max(mode)
   mindata  = min(mode)

   FD2D = Reform(FD2D, IMX, JMX)

   Plot_region, FD2D, /sample, /cbar, divis=4, margin=margin, $
    min_valid=mindata, mindata=mindata, maxdata=maxdata
   
   print, eof.variance[mm], ' % explaned'
;   xyouts, -120., 55., eof.variance(mm), color=1

    aa = max(abs(eof.time(*,*)))
    MULTIPANEL,Position=p,margin=0.04    ; get current plot position
    temp = Reform(Eof.time(mm,*)*sign(mm))
;   Plot, jday, temp/aa, color=1, position=p, xticks=12, $
;   xstyle=1,xrange=[1.,365.],yrange=[-1.,1.]

   Plot, jday, temp/aa, color=1, position=p, $
   xstyle=1, yrange=[-1.,1.]

   Oplot, [1.,365.],[0.0,0.0], color=1
;   print, STDDEV(temp/aa), '1 sigma of time series'

;   if mm eq 0 then oplot, jday, Eof.time(1,*)/aa, color=4

;   xyouts, 1., 1.1, var(mm), color=1, alignment=0.

;   Axis, XAxis=1, Xticks=10, Xminor=12, XRange

    MULTIPANEL,/Advance,/NoErase ; go to next panel
  endfor

 end

;======================================================================

  @load

  @define_plot_size

  ; site selection in states
  q = 0.
  state = ['ND','SD','WI','MN','MI','OH','IN','IL','IA']
  for i = 0, n_elements(state)-1 do begin
      t = where(imp.state eq state[i])
      if t[0] ne -1 then  q = [q, t]
  end
  state_id = q[1:*]


  ; site selection with correlation coefficient between KNON and OMC
  Rarr = imp.r_knon_omc[2]  ; correlation coefficient
  Lon  = imp.Lon
  Lat  = imp.lat

  Rcri = 0.7 & CR = strtrim(string(Rcri, format='(F3.1)'),2)

  corr_id = where(rarr ge Rcri)


 ; Plotting begins

  multipanel, row=2, col=2

  Pos = cposition(2,2,xoffset=[0.1,0.1],yoffset=[0.1,0.1], $
        xgap=0.1,ygap=0.15,order=1)

  if !D.name eq 'PS' then $
    open_device, file='omc_tseries.ps', /color, /ps, /landscape


    id  = corr_id

    fld = imp[id].r_knon_omc[2]
    mindata = 0.
    maxdata = 1.

    mapplot, fld, imp[id], pos=pos[*,0], mindata=mindata, maxdata=maxdata
;    plotongrid, fld, imp[id], mindata=mindata, maxdata=maxdata

stop

    fld = imp[id].r_ec_omc[2]
    mindata = 0.
    maxdata = 20.

    mapplot, fld, imp[id], pos=pos[*,2], mindata=mindata, maxdata=maxdata
;    plotongrid, fld, imp[id], mindata=mindata, maxdata=maxdata

stop


    mon = jday2month(imp[0].jday)
    jj  = where(mon ge 7 and mon le 8)


   for d = 0, n_elements(q)-1 do begin
    id = q[d]
    erase
    mapplot, fld, imp[id], pos=pos[*,0], mindata=mindata, maxdata=maxdata
    tseries, imp[id], pos=pos[*,1], yrange=[0.,10]

    ; omc vs k
    x = imp[id].knon[jj]   & y = imp[id].omc[jj] 
    scatter, X, Y, pos=pos[*,2], xrange=[0.,0.1]

    ; bc vs omc
    x = imp[id].ec[jj]  & y = imp[id].omc[jj]
    scatter, X, Y, pos=pos[*,3], xrange=[0.,0.1]

    halt
   end

;===========================================================================
;  EOF analysis
;===========================================================================
;    mon = jday2month(imp[0].jday)
;    jj  = where(mon ge 1 and mon le 12)
;
;    id  = indgen(N_elements(imp))
;    id  = q
;    NoM = 3
;    fld = imp[id].no3[jj]
;    data = make_matrix( fld, imp[id] )
;    eof  = ctm_eof(array=data.array, m=NoM, /anomal)
;    ploteof, eof, ij=data.ij, NoM=NoM, Jday=imp[0].Jday[jj]
;============================================================================


  if !D.name eq 'PS' then close_device


  End
