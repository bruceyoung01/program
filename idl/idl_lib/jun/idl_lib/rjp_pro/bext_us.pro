function process, fld, obs=obs

  Lat = 0.
  Lon = 0.
  v_avg = 0.
  v_std = 0.

  For D = 0, N_elements(obs.siteid)-1 do begin

      data = reform(fld[*,D])

      data = chk_undefined(reform(fld[*,D]))

      if data[0]          ne -1   and $
         n_elements(data) gt 80.  and $
         obs[D].lat       gt 20.  then begin

         v_avg  = [v_avg, Mean(Data)  ]  ; annual mean
         v_std  = [v_std, STDDEV(Data)]  ; daily std

         lat    = [lat,   obs[d].lat]
         lon    = [lon,   obs[d].lon]   
      end

  End

  obs_avg = v_avg[1:*]
  obs_std = v_std[1:*]
  obs_lat = lat[1:*]
  obs_lon = lon[1:*]

  return, {avg:obs_avg, std:obs_std, $
           lat:obs_lat, lon:obs_lon }

end
;=========================================================================

pro dist_plot, obs, sim, bkg, nat, asi, pos=pos, name=name, noerase=noerase, cbar=cbar

  COMMON SHARE, SPEC, MAXD, MAXP

  @define_plot_size
  @calc_bext

  ; Data selecting 

  obs_base = ammso4_bext+ammno3_bext+ec_bext+omc_bext+soil_bext+cm_bext
  CASE name OF
   'SO4' : obs_fld = ammso4_bext/obs_base
   'NO3' : obs_fld = ammno3_bext/obs_base
   'EC'  : obs_fld = ec_bext/obs_base
   'OMC' : obs_fld = omc_bext/obs_base
   'CARB': obs_fld = (omc_bext + ec_bext)/obs_base
   'IOA' : obs_fld = ammso4_bext+ammno3_bext
   'SOIL': obs_fld = (soil_bext+cm_bext)/obs_base
   'ALL4': obs_fld = ammso4_bext+ammno3_bext+ec_bext+omc_bext
   'ALL' : obs_fld = (ammso4_bext+ammno3_bext+ec_bext+omc_bext+soil_bext+cm_bext)/obs_base
  END

  fld = process( obs_fld, obs=obs )

  Min_avg = 0.
  Max_avg = 1.

  C      = Myct_defaults()
  Bottom = C.Bottom
  Ncolor = 255L-Bottom
  Ndiv   = 6
  Format = '(F3.1)'
  Unit   = '%'
  csfac  = 1.2

  C_avg = bytscl( fld.avg, Min=Min_avg, Max=Max_avg, $
      	         Top = Ncolor) + Bottom

  ;=========================
  ; Distribution of mean 
  ;========================
  limit = [25., -130., 50., -60.]
  LatRange = [ Limit[0], Limit[2] ]
  LonRange = [ Limit[1], Limit[3] ]

 
  ;---- observation----
  map_set, 0, 0, color=1, /contine, limit=limit, /usa,$
    position=pos[*,0], noerase=noerase

  Map_Labels, LatLabel, LonLabel,              $
         Lats=Lats,         LatRange=LatRange,     $
         Lons=Lons,         LonRange=LonRange,     $
         NormLats=NormLats, NormLons=NormLons,     $
         /MapGrid,          _EXTRA=e

  XYOutS, NormLats[0,*], NormLats[1,*], LatLabel, $
          Align=1.0, Color=1, /Normal, charsize=csfac, charthick=charthick

  XYOutS, NormLons[0,*], NormLons[1,*], LonLabel, $
          Align=0.5, Color=1, /Normal, charsize=csfac, charthick=charthick


  plots, fld.lon, fld.Lat, color=c_avg, psym=8, symsize=symsize

  if keyword_set(cbar) then  begin
  ; colorbar
  dx = (pos[2,0]-pos[1,0])*0.9
  CBPosition = [pos[0,0],pos[1,0]-0.06,pos[2,0],pos[1,0]-0.03]
  ColorBar, Max=max_avg,     Min=min_avg,    NColors=Ncolor,     $
    	      Bottom=BOTTOM,   Color=C.Black,  Position=CBPosition, $
    		Unit=Unit,       Divisions=Ndiv, Log=Log,             $
	      Format=Format,   Charsize=csfac,       $
    	      C_Colors=CC_Colors, C_Levels=C_Levels, Charthick=charthick, _EXTRA=e

  end

  x1 = 0.5*(pos[0,0]+pos[2,0])
  y1 = pos[3,0]+0.01

  xyouts, x1, y1, name, color=1, charsize=tcharsize, $
   charthick=charthick, /normal, alignment=0.5

  idw = where(fld.lon le -95.)
  ide = where(fld.lon gt -95.) 

  if (!D.name eq 'PS') then goto, jump
  ;1)
  x = pos[0,0]
  str = string(mean(fld.avg[idw]),format='(f4.1)')
  xyouts, x, y1, str, color=1, charsize=charsize, /normal, alignment=0, $
    charthick=charthick

  x = pos[2,0]
  str = string(mean(fld.avg[ide]),format='(f4.1)')
  xyouts, x, y1, str, color=1, charsize=charsize, /normal, alignment=1, $
    charthick=charthick

  jump:

 end

;============================================================================

  @ctl

  spec = 'SO4'
  name = ['SO4','NO3','CARB','SOIL']

  mapid = indgen(135)

  figfile = 'bext_us.ps'

  !P.multi=[0,2,2,0,0]
  Pos = cposition(2,2,xoffset=[0.1,0.15],yoffset=[0.15,0.15], $
        xgap=0.05,ygap=0.15,order=0)
  if !D.name eq 'PS' then $
    open_device, file=figfile, /color, /ps, /landscape


  comment=''

  newpos = fltarr(4,4)
  newpos[*,0:1] = pos[*,0:1]
  newpos[*,2:3] = pos[*,2:3]

  for D = 0, N_elements(name)-1 do begin
  noerase = D < 1
  dist_plot, newobs(mapid), newsim(mapid), newbkg(mapid), newnat(mapid),$
      newasi(mapid), pos=pos[*,D],  name=name[D], noerase=noerase
  end

  print, '==========Mean altitude============'
  print, mean(newobs[mapid].elev), ptz(mean(newsim[mapid].pres))

  xyouts, 0.66, 0.4, comment, color=1, alignment=0., /normal, $
    charsize=charsize, charthick=charthick

 if !D.name eq 'PS' then close_device

End
