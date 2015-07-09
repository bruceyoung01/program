  grid  = ctm_grid(ctm_type('geos4',res=2))
  idmap = Replicate(0.,grid.imx, grid.jmx)

  EA_LON  = [50., 95.]
  EA_LAT  = [5.,  35.]
  EA_I    = where( grid.xmid ge EA_LON[0] and grid.xmid le EA_LON[1] )
  EA_J    = where( grid.ymid ge EA_LAT[0] and grid.ymid le EA_LAT[1] )

  i0 = min(ea_i) & i1 = max(ea_i)
  j0 = min(ea_j) & j1 = max(ea_j)

  idmap[i0:i1,j0:j1] = 1.  ; 20% reduction

  tvmap, idmap, /conti, /cbar, divis=4, /sample

  write_bpch, idmap, filename='./mask/SR3SA_mask.geos.2x25', $
      ngas=2L, unit='unitless', $
      category='LANDMAP', tau0=nymd2tau(20010101L), $
      tau1=nymd2tau(20010201L), append=append

  end
