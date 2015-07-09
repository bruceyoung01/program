;
; plot elevation data
;
pro plot_elevation, limit
np = 10800
nl = 5400
rawdata = intarr(np, nl)

openr, 1, '~/idl_lib/ETOPO2.dos.bin'
readu, 1, rawdata
close,1

LatB = limit(0)
LatT = limit(2)
LonR = limit(3)
LonL = limit(1)
nps = (180+LonL)*30.
npe = (180+LonR)*30.
nle = (90-LatB)*30.
nls = (90-LatT)*30.

tmp = fltarr(npe-nps+1, nle-nls+1)
tmp ( 0:npe-nps, 0:nle-nls) = rawdata(nps:npe, nls:nle)

lat = LatT - findgen(nle-nls+1)*0.033-0.1
lon = LonL + findgen(npe-nps+1)*0.033

maxtmp = 3000
mintmp = 0


for i = 0, npe-nps do begin
for j = 0, nle-nls do begin
 if ( tmp(i,j) gt 0 and lon(i) lt limit(3) and lat(j) lt limit(2)) then begin
  if ( tmp(i,j) gt maxtmp) then tmp(i,j) = maxtmp
  if ( tmp(i,j) gt mintmp) then begin
    xyouts, lon(i), lat(j), '.', color = 255-((tmp(i,j)-mintmp)/(maxtmp-mintmp))*250
  endif

 endif
endfor
endfor
END

