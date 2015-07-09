 pro read_vars, file, NV, varstr


  OpenR, unit, file, /get_lun

  charline = '' & comment = ''

  readf, unit, NH
  readf, unit, NV   &  NV=fix(Nv)         ;# of variables

  varstr = StrArr(NV)

  for i = 0, NV-1 do begin
    readf, unit, charline
    headstr = StrTrim ( StrSplit ( StrTrim(charline,2), ',', /extract ), 2 )
    varstr(i) = headstr(0)
  endfor

  free_lun,  unit

 end

;-----------------------------------------------------------------

 function get_data, file=file, off=off

  if n_elements(file) eq 0 then return, 0
  if n_elements(off)  eq 0 then off = 4L

  read_vars, file, NV, names

  readdata, file, data, names_void, delim=',', /autoskip, $
      /noheader, cols=NV-off, $
      /quiet

  qdata = transpose(data)
  
  out   = create_struct('siteid', names[0], 'LON', float(Names[1]), $
                      'LAT', float(names[2]), 'ELEV', float(Names[3]))

  For D = off, N_elements(names)-1 do $
      out = create_struct(out, Names[D], Float(qdata[*,D-off]))


 return, out

 end

;-----------------------------------------------------------------

 function recon_struct, data, date, nofile

   nofile = -1.
   info = improve_siteinfo()
   n = where(data.siteid eq info.siteid)

   YYMMDD0 = Long(data.year)*10000L+101L
   NDAY = fltarr(N_elements(date))
   for d = 0, N_elements(date)-1 do begin
     YYMMDD  = Long(data.year)*10000L+Long(date[d])
     dtau    = nymd2tau(YYMMDD)-nymd2tau(YYMMDD0)
     NDAY[d] = dtau/24. + 1.
   end

   if n[0] ne -1 then begin
      out = create_struct('SITEID', info.siteid[n[0]], $
                          'NAME',   info.name[n[0]],   $
                          'STATE',  info.state[n[0]],  $
                          'LON',    info.lon[n[0]],    $
                          'LAT',    info.lat[n[0]],    $
                          'ELEV',   info.elev[n[0]],   $
                          'YEAR',   data.year      ,   $
                          'DATE',   date           ,   $
                          'JDAY',   NDAY               )
   end else begin
      nofile = 1.
      return, -1.
   end
      
   TAG = TAG_NAMES(DATA)
   For D = 0, N_Tags(data)-1 do begin

     if TAG[D] eq 'DATE' then goto, jump

     FLD = DATA.(D)
     if n_elements(FLD) gt 1 then begin
        NEW = Replicate(-999.,N_ELEMENTS(date))

        For N = 0, N_ELEMENTS(FLD)-1 do begin
            P = where(data.date[N] eq date)
            if P[0] ne -1 then begin
               NEW[P[0]] = FLD[N]
            end else begin
               print, 'result is wrong'
               stop
            end
        End           

        out = create_struct(out, TAG[D], NEW)
     end

     jump:
   end
   
   return, out
 end

;=============================================================

 function make_annual, monthdata, summer=summer

 ; compute annual mean using monthly mean data for 1997-2002
 avg = fltarr(6)
 For D = 0L, N_elements(avg)-1L do begin
    is = D*12L
    ie = (D+1)*12L -1L
    if keyword_set(summer) then begin
      is = is + 5L
      ie = ie - 4L
    end
    avg[D] = mean(monthdata[is:ie])
 End

 return, avg

 end

;=============================================================

 function retrieve, dir

 if n_elements(dir) eq 0 then return, -1

    files = collect(dir+'MODEL_at_*_4x5.txt')

    For D = 0, N_elements(files)-1 do begin
       out = get_data(file=files[D])

       if N_elements(out.yymm) lt 72 then goto, jump

       if D eq 0 then Data=out else data = [data, out]

       jump: undefine, out
    End

   return, data
 end
;=============================================================

; Begins here
 @define_plot_size

 if n_elements(clim) eq 0 then begin

   clim = retrieve('./out_season/')
   west = retrieve('./out_westerling/')

 end

  if !D.name eq 'PS' then $
    open_device, file='OC_west_44.ps', /color, /ps, /portrait


 multipanel, row=1, col=2
 Pos = cposition(1,2,xoffset=[0.15,0.1],yoffset=[0.1,0.1], $
        xgap=0.1,ygap=0.1,order=0)


 id  = where(clim.lon lt -100.)
 fld = composite(clim[id].oc_obs)

 obs = composite(clim[id].oc_obs, /first)
 sim = composite(clim[id].oc_sim, /first)
 new = composite(west[id].oc_sim, /first)

 plot, indgen(72)+1L, obs.mean, color=1, yrange=[0., 6], $
       psym=-1, xstyle=1, xrange=[1,72], xtickinterval=12, pos=pos[*,0], $
       charsize=charsize, charthick=charthick, thick=thick, $
       xtitle='Julian month from Jan. 1997', ytitle='OC concentration [ug/m3]', $
       title='Monthly mean conc. for 1997-2002!C at 44 IMPROVE sites in the west (Lon <-100.)'
 oplot,indgen(72)+1L, sim.mean, color=2, thick=thick
 oplot,indgen(72)+1L, new.mean, color=4, thick=thick

 xval = [3,8]
 plots, xval, [5.1,5.1], psym=-1., thick=thick, color=1
 plots, xval, [4.6,4.6], line=0, thick=thick, color=2
 plots, xval, [4.1,4.1], line=0, thick=thick, color=4
 xyouts, 10, 5, 'IMPROVE', color=1, charsize=charsize, charthick=charthick
 xyouts, 10, 4.5, 'GEOS-Chem (Clim.)', color=1, charsize=charsize, charthick=charthick
 xyouts, 10, 4.0, 'GEOS-Chem!C (Westerling)', color=1, charsize=charsize, charthick=charthick


 obs_ann = make_annual( obs.mean, /summer )
 sim_ann = make_annual( sim.mean, /summer )
 new_ann = make_annual( new.mean, /summer )

 plot, indgen(6)+1997L, obs_ann, color=1, psym=-1, xstyle=2, pos=pos[*,1], $
       charsize=charsize, charthick=charthick, thick=thick, $
       xtitle='Year', ytitle='OC concentration [ug/m3]', $
       title='Seasonal mean conc. for the summer'
 oplot, indgen(6)+1997L, sim_ann, color=2, thick=thick
 oplot, indgen(6)+1997L, new_ann, color=4, thick=thick

 halt

 erase
 mapplot, fld.mean, clim[id], /cbar, unit='ug/m3', $
  title='Observed annual OC conc. for 1997-2002', pos=pos[*,0]
  if !D.name eq 'PS' then close_device

End
