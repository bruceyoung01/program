   InMap  = 'INDIA.map_1x1.bin'
   OutMap = 'INDIA.map_2x25.bin'

   openr, il, InMap,  /f77, /get
   Oldmap = fltarr(360,180)
   InType = CTM_Type( 'generic', Resolution=1 )
   InGrid = CTM_Grid( InType, /No_vertical )
   readu, il, Oldmap
   free_lun, il


   ; MODELINFO, GRIDINFO structures, and surface areas for new grid
   OutType = CTM_Type( 'GEOS3', Resolution=2 )
   OutGrid = CTM_Grid( OutType, /No_vertical )

   Newmap = CTM_Regrid( Oldmap, InGrid, OutGrid, /No_normalize )

   map = Newmap

   For J = 0, outgrid.jmx-1 do begin
   For I = 0, outgrid.imx-1 do begin
     If map[i,j] gt 0. then Newmap[i,j] = 1. else Newmap[i,j] = 0.
   Endfor
   Endfor

   multipanel, 2
   tvmap, oldmap, /sample, /conti, /cbar
   tvmap, newmap, /sample, /conti, /cbar

   openw,jl,OutMap,/get,/f77
   writeu, jl, Newmap
   free_lun, jl

   End
