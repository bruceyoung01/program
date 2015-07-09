 if (!D.name eq 'PS') then $
  open_device, file='us_gridmap.ps', /landscape, /ps, /color

 margin = [0.05,0.05,0.05,0.05]
 multipanel, row=2, col=2, omargin=[0.05,0.,0.05,0.]

 file = '/users/ctm/rjp/Data/MAP/usconus_mask.geos.4x5'
 ctm_get_data, datainfo, file=file

 d4x5 = *(datainfo[0].data)

 plot_region, d4x5, /conti, /sample, position=[0.,0.,1.,1.], margin=margin, $$
 title='4x5'


 file = '/data/ctm/GEOS_2x2.5/EPA_NEI_200411/usa_mask.geos.2x25'
 ctm_get_data, datainfo, file=file

 d2x25 = *(datainfo[0].data)

 plot_region, d2x25, /conti, /sample, position=[0.,0.,1.,1.], margin=margin, $$
 title='2x25'

 file = '/data/geos/GEOS_1x1_NA/EPA_NEI_200411/usa_mask.geos.1x1'
 ctm_get_data, datainfo, file=file

 data = *(datainfo[0].data)
 d1x1 = fltarr(360,181)
  DIM = size(data)

   X1 = datainfo.first[0]-1L
   X2 = X1+DIM[1]-1L
   Y1 = datainfo.first[1]-1L
   Y2 = Y1+DIM[2]-1L
 d1x1[X1:X2,Y1:Y2] = data

 plot_region, d1x1, /conti, /sample, position=[0.,0.,1.,1.], margin=margin, $$
 title='1x1'


 file = '/users/ctm/rjp/Data/MAP/UScont.map_2x25.bin'
 map = fltarr(144,91)
 Openr,il,file,/f77,/get
 readu,il,map
 free_lun,il
 map[*,*] = 0.
 map[22:46, 58:69] = 1.

 plot_region, map, /conti, /sample, position=[0.,0.,1.,1.], margin=margin, $
 title = 'U.S. map used in Park et al. [2004]'

 if (!D.name eq 'PS') then $
  close_device

stop

 file = '/users/ctm/rjp/Data/MAP/UScont.map_1x1.bin'
 map = fltarr(360,181)
 Openr,il,file,/f77,/get
 readu,il,map
 free_lun,il

 plot_region, map, /conti, /sample, position=[0.,0.,1.,1.], margin=margin

 End
