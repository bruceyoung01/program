 function avg_over_site, data

 ; sort out missing data
 p   = where(data lt 0.)
 if p[0] ne -1 then data[p] = 'NaN'

 ndim=size(data)
 if ndim[0] eq 1 then return, {mean:data, std:Replicate(0.,n_elements(data))}

 avg = fltarr(ndim[3]) 
 std = avg
 ict = -1L

 ; annual mean for Jun-Aug
 for j = 0, ndim[3]-1 do begin
   ict = ict + 1L
   sample   = reform(data[*,5:7,j])
   nfinite  = n_elements(where(finite(sample) gt 0)) 
   avg[ict] = mean(sample,/NaN)
   if nfinite eq 1 then  std[ict] = 'NaN' $
   else  std[ict] = stddev(sample,/NaN) 

   if avg[ict] eq 0. then avg[ict] = 'NaN'
 end

 return, {mean:avg,std:std}

 end

;=======================================================
@define_plot_size

 if n_elements(imp) eq 0 then begin
;    missing = ['ARCH','ISRO','RMHQ']
;    obs = improve_datainfo(year=1988L) 
;    m   = search_index(missing, obs.siteid, COMPLEMENT=COMPLEMENT) 
;    sitename = obs.siteid[COMPLEMENT]

    sitename = ['ACAD','BADL','BAND','BIBE','BRCA','BRID','CANY','CHIR', $
                'CRLA','EVER','GLAC','GRCA','GRSA','GRSM','GUMO','JARB', $
                'LAVO','MEVE','MORA','PEFO','PINN','PORE','REDW','SAGO', $ 
                'SAGU','SHEN','TONT','VOYA','WASH','WEMI','YELL','YOSE']

    Years = Lindgen(17)+1988L

    For D = 0, N_elements(Years)-1L do begin
      str = improve_datainfo(year=Years[D], sitename=sitename)
      If D eq 0 then imp = str else imp = [imp, str]
      undefine, str
    End

    lon = obs.lon
    lat = obs.lat


     map_set, 0, 0, color=1, /contine, limit = [25., -140., 50., -60.], /usa
     plots, lon, lat, color=2, psym=8, symsize=symsize


 endif

 sites = ['GLAC','LAVO','YELL']
 id    = search_index(sites, sitename)
; id    = indgen(n_elements(sitename))

 so4 = avg_over_site(imp.so4[id,*])
 oc  = avg_over_site(imp.oc[id,*])
 k   = imp.k[id,*] - imp.fe[id,*]*0.6
 nsk = avg_over_site(k)
 fm  = avg_over_site(imp.fm[id,*])

 fac   = 60.
 xyear = findgen(17)+1988L
 plot,  xyear, fm.mean, color=1, xstyle=1, thick=dthick, yrange=[3.,8.]
; oplot, xyear, oc.mean, color=2, thick=dthick
; oplot, xyear, nsk.mean*fac, color=4, thick=dthick

 end
