pro map_plot, data, lon=lon, lat=lat, min=min, max=max, position=position, $
    cbar=cbar, nogxlabel=nogxlabel, nogylabel=nogylabel, cbposition=cbposition, $
    ndiv=ndiv, cformat=cformat

 if n_elements(min) eq 0 then min = min(data)
 if n_elements(max) eq 0 then max = max(data)
 if n_elements(position) eq 0 then position = [0.1,0.2,0.9,0.9]
 if n_elements(cbposition) eq 0 then  begin
     dx = position[2]-position[2]*0.8
     CBPosition = [position[0]+dx,position[1]-0.05,position[2]*0.8,position[1]-0.03]
 end
 if n_elements(ndiv) eq 0 then ndiv = 6
 if n_elements(cformat) eq 0 then cformat='(F4.1)'

 @define_plot_size

 C      = Myct_defaults()
 Bottom = C.Bottom
; Bottom = 1.
 Ncolor = 255L-Bottom

 colors = bytscl( data, Min=Min, Max=Max, Top = Ncolor) + Bottom

  ;========================
  limit = [25., -130., 50., -60.]
  LatRange = [ Limit[0], Limit[2] ]
  LonRange = [ Limit[1], Limit[3] ]

  ;---- observation----
  map_set, 0, 0, color=1, /contine, limit=limit, /usa, position=position, /noerase

  Map_Labels, LatLabel, LonLabel,              $
         Lats=Lats,         LatRange=LatRange,     $
         Lons=Lons,         LonRange=LonRange,     $
         NormLats=NormLats, NormLons=NormLons,     $
         /MapGrid,          _EXTRA=e

  if keyword_set(nogylabel) eq 0 then $
  XYOutS, NormLats[0,*], NormLats[1,*], LatLabel, $
          Align=1.0, Color=1, /Normal, charsize=charsize, charthick=charthick

  if keyword_set(nogxlabel) eq 0 then $
  XYOutS, NormLons[0,*], NormLons[1,*], LonLabel, $
          Align=0.5, Color=1, /Normal, charsize=charsize, charthick=charthick


  plots, lon, Lat, color=colors, psym=8, symsize=symsize

  if keyword_set(cbar) then begin
     ;------colorbar---------------

     ColorBar, Max=max,     Min=min,    NColors=Ncolor,     $
     	      Bottom=BOTTOM,   Color=C.Black,  Position=CBPosition, $
     		Unit=Unit,       Divisions=Ndiv, Log=Log,             $
	      Format=cFormat,   Charsize=charsize,       $
     	      C_Colors=CC_Colors, C_Levels=C_Levels, Charthick=charthick, _EXTRA=e

  end


  end
