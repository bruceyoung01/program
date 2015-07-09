 ctncode = lonarr(360,180)
 Openr,il,'/users/ctm/rjp/Data/biofuel/rmy/newcountry.codes.1x1.Jun15',/Get
 Readf,il,ctncode
 Free_lun,il

 gridinfo = ctm_grid(ctm_type('generic',res=1))

 map = fltarr(360,180) ; generic 1x1 emission grid.

; North America
  for j = 0, 179 do begin
  for i = 0, 359 do begin
    if ( ( gridinfo.xmid[i] ge -180. and gridinfo.xmid[i] le -120. ) or $
       ( gridinfo.xmid[i] ge 130.  and gridinfo.xmid[i] le 180. )  and $
       gridinfo.ymid[j] ge 35. and gridinfo.ymid[j] le 65. and $
        ctncode[i,j] eq 0 ) then map[i,j] = 1. 
  endfor
  endfor

 tvmap, map, /conti, /cbar


  openw,il,'N.Pacific.map_1x1.bin', /get, /f77
  writeu,il,map
  free_lun,il


 End
