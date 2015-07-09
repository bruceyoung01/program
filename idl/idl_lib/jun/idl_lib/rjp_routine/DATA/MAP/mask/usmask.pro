  map_1x1 = readmap(file='UScont.map_1x1.bin', res=1)


  write_bpch, map_1x1, filename='usa_mask.geos.1x1', $
      ngas=2L, unit='unitless', $
      category='LANDMAP', tau0=nymd2tau(19850101L), $
      tau1=nymd2tau(19850101L), append=append

