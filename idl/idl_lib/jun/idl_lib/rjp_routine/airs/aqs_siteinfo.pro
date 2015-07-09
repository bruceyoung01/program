 function aqs_siteinfo

 Openr, il, 'epa_aqs_siteinfo.txt', /get

 a = 'x'
 id = 'x'
 y  = 0.
 x  = 0.
 h  = 0.
 lat= 0.
 lon= 0.
 alt= 0.

 while (not eof(il)) do begin
    readf, il, a, y, x, h, format='(1x,a9,3f10.4)'
    id = [id, a]
    lat= [lat,y]
    lon= [lon,x]
    alt= [alt,h]
 end
 free_lun, il

 return, {siteid:id[1:*],lat:lat[1:*],lon:lon[1:*],elev:alt[1:*]}
 
 end
 
