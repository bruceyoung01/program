Pro plot_wrfchem, $
      aod, lat, lon, $
      maxaod=maxaod, $
      minaod=minaod, $
      region_limit=region_limit, $
      color=color, $
      nlev=nlev, $
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
      unit = unit, $
      botclrinx   = botclrinx, $     ; bottom and top triangle color index
      topclrinx    = topclrinx, $
      cb_nticks = cb_nticks   
   
; Next steps
;  (1) plot 
;  (2) locate and format the colorbar
;  (3) add China, USA keywords
;  

  ; if nlev is specified. then you have to define your own botclrinx, 
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
  if ( N_Elements( nlev        )   eq 0 ) then nlev        =  !MYCT.NCOLORS-2
  if ( N_Elements( color         ) eq 0 ) then color         = !MYCT.BLACK
  if ( N_Elements( bottom        ) eq 0 ) then bottom        = !MYCT.BOTTOM+1
  if ( N_Elements( nag           ) eq 0 ) then nag           = 4
  if ( N_Elements( position      ) eq 0 ) then position      = [0.2,0.3,0.8,0.7]
  if ( N_Elements( londel        ) eq 0 ) then londel        = 10
  if ( N_Elements( latdel        ) eq 0 ) then latdel        = 10
  if ( N_Elements( cb_nticks  )    eq 0 ) then cb_nticks  = 5   
  if ( N_Elements( title  )        eq 0 ) then title         = ' '   
  if ( N_Elements( unit  )         eq 0 ) then unit         = ' '   
  if ( N_Elements( botclrinx  )    eq 0 ) then botclrinx    = !MYCT.BOTTOM  
  if ( N_Elements( topclrinx  )    eq 0 ) then topclrinx    = bottom+nlev   

  ; note the nlay + bottom should no larger than ncolors
   if (bottom+nlev gt bottom+!myct.ncolors-1) then begin
    print, 'number of colors less than number of levels, increase ncolors'
    stop
   endif


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

;  if ( count gt 0 ) then aod(result) = -1.
;  minresult = where ( aod lt minaod and aod ge -1, mincount)
  minresult = where ( aod lt minaod, mincount)
  maxresult = where ( aod ge maxaod , maxcount)
  
  ; Transfer the aod value to the color index
  color_aod = bottom + (aod-minaod) / (maxaod-minaod) * nlev 
  if (mincount gt 0 ) then color_aod(minresult) = bottom-1 
  if (maxcount gt 0 ) then color_aod(maxresult) = bottom+nlev+1 

; magnified the array
;  color_aod = congrid(color_aod, nag*np, nag*nl)
;  lat       = congrid(lat, nag*np, nag*nl, /interp)
;  lon       = congrid(lon, nag*np, nag*nl, /interp)

  ; Plot the image over map
  ; color_imagemap, color_aod, lat, lon, /current

; level is in values, and should be in ascending order
levels = findgen(nlev+2) 
levels(0)=bottom-1
levels(1:nlev) = bottom + (levels(1:nlev)-1)
levels(nlev+1) = bottom+nlev+1 

; color is not necessary in ascending order
ccolors = findgen(nlev+2)-1
ccolors(1:nlev) = bottom + ccolors(1:nlev)
ccolors(0) = botclrinx 
ccolors(nlev+1) = topclrinx 

contour, color_aod,   lon, $
        lat, /irregular, $
        xrange=[xl, xr], yrange=[ybb, ytt],  /fill, $
        levels=levels,$  
        c_colors=ccolors,xstyle=1, ystyle=1,$
        color=!MYCT.BLACK, position= position, $
        xtitle = '!6Longitude (deg) ', $
        ytitle='Latitude (deg) ', $
        xthick=3,xticks = 5, xminor = 5,$
       ythick=3, charsize=1.2, charthick=1, $
       title = Title 

;contour, color_aod,   lon, $
;        lat, /irregular, $
;        xrange=[xl, xr], yrange=[ybb, ytt],  $
;        levels=levels,$  
;        xstyle=1, ystyle=1,$
;        color=!MYCT.BLACK, position= position, $
;        xthick=3,xticks = 5, xminor = 5,$
;       ythick=3, charsize=1.2, charthick=1, /overplot,  

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

  MAP_GRID, $
            no_grid=no_grid, $
            glinestyle=1, color=color, $
            londel=londel, latdel=latdel, $
            position = mapposition ;/box_axis


 ; ; Plot China Map
 ; if ( China ) then plot_china, color, 0.5
  

  ; plot colorbar
  cb_position = position
  cb_position[1] = position[1] - 0.1
  cb_position[3] = position[1] - 0.08
  colorbar, bottom=bottom, ncolors=nlev, color=color, $
            Min=minaod, max=maxaod, position=cb_position, $
            Divisions=cb_nticks, /TRIANGLE, Unit= unit, $
            BOTOUTOFRANGE = botclrinx, TOPOUTOFRANGE=topclrinx 
           


  ; End of routine
  End
