
 file = 'usa_mask.geos.1x1'
 ctm_get_data, datainfo, file=file
 idmap = *(datainfo.data)

 click_map, ctm_type('geos3',res=1), limit=[10.,-130.,60.,-60.],idmap=idmap

  write_bpch, idmap, filename='usa_mask.geos.1x1', $
      ngas=2L, unit='unitless', $
      category='LANDMAP', tau0=nymd2tau(19850101L), $
      tau1=nymd2tau(19850101L), append=append


 End
