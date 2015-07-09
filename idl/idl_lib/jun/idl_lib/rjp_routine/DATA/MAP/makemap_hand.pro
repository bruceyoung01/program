
  res = 2

  click_map, ctm_grid(ctm_type('geos3',res=res)), limit=[10.,-170.,80.,-60.],idmap=idmap, $
   /countries


  write_bpch, idmap, filename='canada_alaska_mask.geos.2x25', $
      ngas=2L, unit='unitless', $
      category='LANDMAP', tau0=nymd2tau(19850101L), $
      tau1=nymd2tau(19850101L), append=append


End
