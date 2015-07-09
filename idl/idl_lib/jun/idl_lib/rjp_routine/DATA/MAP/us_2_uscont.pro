
file = 'US.map_1x1.bin'
ofile= 'UScont.map_1x1.bin'

  Modelinfo = CTM_TYPE('GEOS3_30L', RES=1)
  Gridinfo  = CTM_GRID(MODELINFO)

   map = fltarr(360,181)

   Openr,il,file,/f77,/get
   readu,il,map
   free_lun,il

   newmap = map

   For J = 0, Gridinfo.jmx-1 do begin
   For I = 0, Gridinfo.imx-1 do begin
      
       if Gridinfo.xmid[I] le -130. then newmap[I,J] = 0.
       if Gridinfo.xmid[I] ge -60.  then newmap[I,J] = 0.
       if Gridinfo.ymid[j] le 20.   then newmap[I,J] = 0.

   End
   End

   multipanel, row=2, col=1

   tvmap, map, /conti, maxdata=2, /cbar, divis=4, /sample,/grid
   tvmap, newmap, /conti, maxdata=2, /cbar, divis=4, /sample,/grid

   Openw,il,ofile,/f77,/get
   writeu,il,newmap
   free_lun,il

end
