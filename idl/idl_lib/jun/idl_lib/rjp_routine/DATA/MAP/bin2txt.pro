 Region = 'US'
 RES    = 4
 CASE RES of 
     2 : dxdy = '2x25'
     4 : dxdy = '4x5'
     1 : dxdy = '1x1'
 END

 OutType = CTM_Type( 'GEOS3', Resolution=RES )
 OutGrid = CTM_Grid( OutType, /No_vertical )

 File = Region+'.map_'+dxdy

 map = fltarr(OutGrid.imx,Outgrid.jmx)

; MODELINFO, GRIDINFO structures, and surface areas for new grid

 openr,il,File+'.bin',/f77,/get
 readu,il,map
 free_lun, il

 openw,il,File+'.txt',/get
 for j = 0, Outgrid.jmx-1L  do begin
 for i = 0, OutGrid.imx-1L do begin
   printf, il, i+1, j+1, map[i,j], outgrid.xmid[i], outgrid.ymid[j], $
      format = '(2I4,F4.1,2F7.1)'
 endfor
 endfor

 free_lun, il

 end
  
