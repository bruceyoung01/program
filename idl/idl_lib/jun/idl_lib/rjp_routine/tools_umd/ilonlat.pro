function ilonlat,lon=lon,lat=lat,lowres=lowres,ilat=ilat

if n_elements(lowres) eq 0 then lowres = 0
if n_elements(lon) eq 0 then lon = [0] 
if n_elements(lat) eq 0 then lat = [0] 

case lowres of
1:    begin
      ilmm = 72 & ijmm = 46
      end 
else: begin
      ilmm = 144 & ijmm = 91
      end
endcase 
press = grid(loncen=loncen,latcen=latcen,ilmm=ilmm,ijmm=ijmm) 
 
 num = size(lon) & num = num(1) 

ilon = lonarr(num) & ilat = ilon 
for i=0,num-1 do begin
   aa = where(loncen+360./(ilmm*2.) gt lon(i),count) 
   if (count ne 0) then ilon(i) = aa(0) else ilon(i) = 0 
   aa = where(latcen+180./((ijmm-1)*2.) gt lat(i),count)
   if (count ne 0) then ilat(i) = aa(0) else ilat(i) = ijmm-1 
endfor   

return,ilon 
end 
