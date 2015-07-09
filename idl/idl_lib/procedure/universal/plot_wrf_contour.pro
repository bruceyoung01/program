  Pro plot_wrf_contour, $
      aod, lat, lon, $
      maxaod=maxaod, $
      minaod=minaod, $
      region_limit=region_limit, $
      color=color, $
      ncolor=ncolor, $
      bottom=bottom, $
      nag=nag, $
      position=position, $
      China=China, $
      USA=USA, $
      Isotropic=Isotropic, $
      no_grid=no_grid, $
      londel=londel, $
      latdel=latdel, $
      title = title, $
      unit = unit
   
; Next steps
;  (1) plot 
;  (2) locate and format the colorbar
;  (3) add China, USA keywords
;  

  ;====================================================================
  ; Initialization
  ;====================================================================
  ; Check size of aod
  size_aod = size(aod)
  if ( size_aod[0] ne 2 ) then begin
    print, ' Aod is not 2-diemnisonal, program stopped!'
  endif
  np = size_aod[1]
  nl = size_aod[2]

  ; On/Off keywords
  China      = Keyword_Set( China      )  
  USA        = Keyword_Set( USA        )
  Isotropic  = Keyword_Set( Isotropic  )
  No_Grid    = Keyword_Set( No_Grid    )

  ; Keyword Default
  if ( N_Elements( maxaod        ) eq 0 ) then maxaod        = 1.0
  if ( N_Elements( minaod        ) eq 0 ) then minaod        = 0.0
  if ( N_Elements( region_limit  ) eq 0 ) then region_limit  = [-90,-180,90,180]
  if ( N_Elements( ncolor        ) eq 0 ) then ncolor        = !MYCT.NCOLORS
  if ( N_Elements( color         ) eq 0 ) then color         = !MYCT.BLACK
  if ( N_Elements( bottom        ) eq 0 ) then bottom        = !MYCT.BOTTOM
  if ( N_Elements( nag           ) eq 0 ) then nag           = 4
  if ( N_Elements( position      ) eq 0 ) then position      = [0.2,0.3,0.8,0.7]
  if ( N_Elements( londel        ) eq 0 ) then londel        = 10
  if ( N_Elements( latdel        ) eq 0 ) then latdel        = 10
  if ( N_Elements( cb_Divisions  ) eq 0 ) then cb_Divisions  = 7
  if ( N_Elements( title  )        eq 0 ) then title         = 'title'   
  if ( N_Elements( unit  )         eq 0 ) then unit          = 'unit'   

  ;====================================================================
  ; Start Mapping
  ;====================================================================
  xl  = region_limit(1)
  xr  = region_limit(3)
  ybb = region_limit(0)
  ytt = region_limit(2)
  xcenter = 0

;  MAP_SET, /lambert, 30, 115, $ 
;           MLINETHICK=1, $
;           LIMIT=region_limit, $
;           /noerase, color=color, $
 ;          position = position, $
 ;          /label, isotropic=isotropic

  ;====================================================================
  ; Plot the variable
  ;====================================================================
  result = where (aod lt 0, count)
  if ( count gt 0 ) then aod(result) = -1.
;  minresult = where ( aod lt minaod and aod ge -1, mincount)
  minresult = where ( aod lt minaod, mincount)
  maxresult = where ( aod ge maxaod , maxcount)
  
  ; Transfer the aod value to the color index
  color_aod = bottom + (aod-minaod) / (maxaod-minaod) * (ncolor-3) 
  if (mincount gt 0 ) then color_aod(minresult) = !MYCT.WHITE 
  if (maxcount gt 0 ) then color_aod(maxresult) = bottom + ncolor-2
  
; magnified the array
;  color_aod = congrid(color_aod, nag*np, nag*nl)
;  lat       = congrid(lat, nag*np, nag*nl, /interp)
;  lon       = congrid(lon, nag*np, nag*nl, /interp)

  ; Plot the image over map
  ; color_imagemap, color_aod, lat, lon, /current

levels = findgen(ncolor)+1
ccolors = findgen(ncolor+1)
ccolors(1:ncolor) = bottom + ccolors(1:ncolor)
ccolors(0) = !MYCT.WHITE

contour, color_aod, lon, lat,                          $
         /irregular, nlevels = ncolor,                 $
         xrange = [xl, xr], yrange = [ybb, ytt],/fill, $
         levels = levels, c_colors = ccolors,          $
         xstyle = 1, ystyle = 1,                       $
         color  = !MYCT.BLACK, position = position,    $
         xtitle = '!6Longitude (deg) ',                $
         ytitle = 'Latitude (deg) ',                   $
         xthick =3, xticks = 5, xminor = 5,            $
         ythick =3, charsize = 1.2, charthick = 3,     $
         title  = Title

  ; Overlay the map
  mapposition = position
  mapposition[1] = position[1]
  mapposition[3] = position[3] 

  MAP_SET, $
           MLINETHICK=1, $
           LIMIT=region_limit, $
           /noerase, color=color, $
           position = mapposition, $
           usa=usa

  MAP_CONTINENTS, /countries, color = 1

  MAP_GRID, $
            no_grid=no_grid, $
            glinestyle=1, color=color, $
            londel=londel, latdel=latdel, $
            position = mapposition ;/box_axis


  ; Plot China Map
  if ( China ) then plot_china, color, 0.5

  ; plot colorbar
  cb_position = position
  cb_position[1] = position[1] - 0.1
  cb_position[3] = position[1] - 0.08
  colorbar, bottom=bottom, ncolors=ncolor, color=color, $
            Min=minaod, max=maxaod, position=cb_position, $
            Divisions=cb_Divisions, /TRIANGLE, Unit= unit 

  ; End of routine
  End
