lon = fltarr(360)
lat = fltarr(181)

file = '/data/eos1/stone/GCTM/ctm_stret_tranonly/stretgrid.lon.lat_f77b'
openr,il,file,/f77,/swap_endian,/get
readu,il,lon,lat
free_lun,il

 dlat = lat(1:180)-lat(0:179)
 dlon = lon(1:359)-lon(0:358)

 ix1 = min(where(dlon eq min(dlon)))
 ix2 = max(where(dlon eq min(dlon)))
 iy1 = min(where(dlat eq min(dlat)))
 iy2 = max(where(dlat eq min(dlat)))

 newlon = lon(ix1:ix2)
 dx = 2
 for i = ix1-dx, 0, -dx do newlon = [newlon,lon[i]]
 for i = ix2+dx, 359, dx do newlon = [newlon,lon[i]]

 im1 = n_elements(newlon)
 newlon = newlon(sort(newlon))
 newdlon = newlon(1:im1-1)-newlon(0:im1-2)

 plot, dlon, yrange = [0.,5.]
 oplot, newdlon


end
