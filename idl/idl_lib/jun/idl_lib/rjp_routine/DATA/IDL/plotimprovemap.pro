 Pro Plotimprovemap

   Sitename = select_site(nsite=45)
   file_obs = '/users/ctm/rjp/Data/IMPROVE/Raw_data/monthly_avg_1998.txt'
   obs = improve_datainfo(file_obs,SiteName=SiteName)
 ; Plotting the location of IMPROVE sites

   multipanel, 1
   Nsite = N_elements(obs.siteid)
   map_set, 0, 0, color=1, /contine, limit = [25., -130., 50., -60.],/usa
   for i = 0, Nsite-1 do xyouts, obs.lon(i), obs.lat(i), $
    obs.siteid[i], color=1, alignment=0.5, charsize=1.0,charthick=4.0

  ; plots, obs.lon, obs.lat, color=1, psym=2

 End
