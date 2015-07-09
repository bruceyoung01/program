 ; Plotting the location of IMPROVE sites
; Pro Plotsites, obs=obs, ps=ps

  if n_elements(obs) eq 0 then begin
    obs    = get_improve_daily( 2004L )
  endif


  @define_plot_size

  siteid = obs.siteid
  sot    = sort(siteid)
  siteid = siteid(sot)
  state  = obs(sot).state
  elev   = obs(sot).elev

  !P.multi=[0,1,1,0,0]
   Pos = cposition(1,1,xoffset=[0.01,0.01],yoffset=[0.53,0.01], $
         xgap=0.15,ygap=0.12,order=0)

 if !D.name eq 'PS' then $
    Open_device, file='sitemap.ps', /ps, /landscape, /color

   map_set, 0, 0, color=1, limit = [25., -130., 50., -60.], position=pos
   map_continents, color=0, /fill_continent
   map_continents, color=1, /continent, /usa, /coast, /countri

   xpos = 0.01
   n    = -1

   for i = 0, N_elements(siteid)-1 do begin

    n = n + 1    
    strin = strtrim(i,2)+'.'+strtrim(siteid[i],2)+'('+strtrim(state[i],2)+')' ;$
;          + strmid(strtrim(elev[i],2),0,5)
    ypos = 0.97-(n*0.025)

    xyouts, xpos, ypos, strin , color=1, /normal, $
      charsize=charsize*0.55, charthick=charthick

    xyouts, obs(i).lon, obs(i).lat, $
    strtrim(i,2), color=1, alignment=0.5, charsize=charsize*0.7, $
    charthick=charthick

;    plots, obs(i).lon, obs(i).lat, color=1, psym=8, symsize=symsize


    if ypos lt 0.5 then begin
       xpos = xpos + 0.11
       n = -1
    end

   end

 if !D.name eq 'PS' then close_device

 End
