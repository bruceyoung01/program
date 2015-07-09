
 us = readmap(file='UScont.map_2x25.txt',res=2)
 canada = readmap(file='Canada.map_2x25.txt',res=2)
 mexico = readmap(file='C.America.map_2x25.txt', res=2)

 multipanel, row=2, col=2
 plot_region, us+canada+mexico, maxdata=2, /sample, /cbar
 plot_region, us, maxdata=2, /sample,/cbar
 plot_region, canada, maxdata=2, /sample,/cbar
 plot_region, mexico, maxdata=2, /sample, /cbar

 world = us*10. + canada*20. + mexico*30.

 openw,il,'us_cad_mex.map_2x25.bin',/f77,/get
 writeu,il,world
 free_lun, il

 end
