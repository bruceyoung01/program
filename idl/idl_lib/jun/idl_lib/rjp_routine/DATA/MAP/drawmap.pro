  NewGrid = CTM_Grid( CTM_Type( 'GEOS1', Res=4 ), /No_Vertical )

;  panel, 1
  map_set, 0, 0, color=1, /contine
  Map_continents, /usa, color=1, /coast, /countries

  For i = 0, NewGrid.imx do begin
    plots, Replicate(newgrid.xedge[i], N_elements(newgrid.yedge)), $
    newgrid.yedge, color=4
  Endfor

  For j = 0, NewGrid.jmx do begin
    plots, newgrid.xedge, Replicate(newgrid.yedge[j],N_elements(newgrid.xedge)), $
    color=4
  Endfor

  Icount = 0L
  For i = 0, NewGrid.imx-1 do begin
    Xyouts, Newgrid.xmid[i], Newgrid.ymid[Newgrid.jmx-1], strtrim(I+1L,2), color=1, $
    alignment=0.5, charsize=1.0
  Endfor

  For j = 0, NewGrid.jmx-1 do begin
    Xyouts, newgrid.Xmid[0], Newgrid.ymid[j], strtrim(j+1L,2), color=1, $
    alignment=0.5, charsize=1.0
  Endfor

  stop



  panel, 2
  map_set, 0, 0, color=1, /contine , limit = [20., -130., 55., -60.], /usa
  For i = 0, NewGrid.imx do begin
    plots, Replicate(newgrid.xedge[i], N_elements(newgrid.yedge)), $
    newgrid.yedge, color=4
  Endfor
  For j = 0, NewGrid.jmx do begin
    plots, newgrid.xedge, Replicate(newgrid.yedge[j],N_elements(newgrid.xedge)), $
    color=4
  Endfor

  Icount = 0L
  For j = 0, NewGrid.jmx-1 do begin
  For i = 0, NewGrid.imx-1 do begin
    Icount = Icount + 1L
    Xyouts, Newgrid.xmid[i], Newgrid.ymid[j], strtrim(j,2), color=1,$
    alignment=0.5, charsize=1.0
  Endfor
  Endfor

 End
