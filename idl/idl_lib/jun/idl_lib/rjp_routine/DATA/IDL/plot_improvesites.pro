; Pro plot_improvesites

@define_plot_size

   Info = improve_siteinfo()

 ; Plotting the location of IMPROVE sites
   multipanel, 1
   Nsite = N_elements(info.site)

   map_set, 0, 0, color=1, /contine, limit = [25., -130., 50., -60.],/usa

   for i = 0, Nsite-1 do begin
     plots, info.lon(i), info.lat(i), psym=8, symsize=symsize, color=1
;     xyouts, info.lon(i)+1., info.lat(i), $
;     info.site[i], color=1, alignment=0.5, charsize=charsize*0.5, $
;     charthick=charthick
   end

 End
