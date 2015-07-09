pro whisker,fd,htpts=htpts,htmax=htmax,xtitle=xtitle,title=title,$
 charsize=charsize,charthick=charthick,dzz=dzz,amean=amean,a10=a10,$
 a90=a90,amed=amed,amax=amax,amin=amin,xrange=xrange,yrange=yrange

if n_elements(title) eq 0 then title = ''
if n_elements(charsize) eq 0 then charsize = 1.
if n_elements(charthick) eq 0 then charthick=2.5
if n_elements(dzz) eq 0 then dzz = 0.2

if n_elements(xtitle) eq 0 then xtitle = ''
if n_elements(htpts) eq 0 then $
htpts = [   0.0486189,0.232722,0.580608,      1.06656,      1.65927,      2.35223,$
      3.14641,      4.02160,      4.97460,      6.00573,      7.12128, 8.32696,$
      9.57337,      10.8161,      12.0748,      13.3766,      14.7248,16.0988,$
      17.4705,      18.8360,      20.1905,      21.5289,      22.8453,24.6766,$
      28.1070,      36.1014]
      
ikmm = size(htpts) & ikmm = ikmm(1) 
if n_elements(htmax) eq  0 then htmax = htpts(ikmm-1) 
 
amean = fltarr(ikmm) & a10 = amean & a90 = amean & amed = amean
amax = amean & amin = amean 

for ik=0,ikmm-1 do begin
   fd1 = reform(fd(ik,*))
   mean = stat(fd1,nobs=nobs,min=min,max=max,std=std,med=med,$
    q90=q90,range=range,q10=q10)
   amean(ik) = mean
   a10(ik) = q10
   a90(ik) = q90
   amed(ik) = med
   amax(ik) = max
   amin(ik) = min
endfor 

aa = where(htpts gt htmax,count) 
if (count gt 0) then ikmax = aa(0) -1 else ikmax = ikmm 
amaxx = max(amax(0:ikmax)) 
aminn = min(amin(0:ikmax))

if n_elements(yrange) eq 0 then yrange = [0.,htmax] 
if n_elements(xrange) eq 0 then xrange = [aminn,amaxx] 
plot,amed,htpts,psym=2,yrange=yrange,xrange=xrange,xstyle=1,$
 ytitle = 'Height (km)', xtitle =xtitle,charsize=charsize,charthick=charthick,$
 ticklen=-0.01,title=title
dhtpts = htpts - shift(htpts,-1)   
for ik=0,ikmax do begin
   plots,amean(ik),htpts(ik)-dhtpts(ik)*dzz,psym=0
   plots,amean(ik),htpts(ik)+dhtpts(ik)*dzz,psym=0,/continue
endfor

for ik=0,ikmax do begin
   plots,a90(ik),htpts(ik),psym=0
   plots,amax(ik),htpts(ik),psym=0,/continue
endfor

for ik=0,ikmax do begin
   plots,amin(ik),htpts(ik),psym=0
   plots,a10(ik),htpts(ik),psym=0,/continue
endfor

for ik=0,ikmax do begin
   plots,a10(ik),htpts(ik)+dhtpts(ik)*dzz,psym=0
   plots,a90(ik),htpts(ik)+dhtpts(ik)*dzz,psym=0,/continue
endfor

for ik=0,ikmax do begin
   plots,a10(ik),htpts(ik)-dhtpts(ik)*dzz,psym=0
   plots,a90(ik),htpts(ik)-dhtpts(ik)*dzz,psym=0,/continue
endfor

for ik=0,ikmax do begin
   plots,a10(ik),htpts(ik)-dhtpts(ik)*dzz,psym=0
   plots,a10(ik),htpts(ik)+dhtpts(ik)*dzz,psym=0,/continue
endfor
for ik=0,ikmax do begin
   plots,a90(ik),htpts(ik)-dhtpts(ik)*dzz,psym=0
   plots,a90(ik),htpts(ik)+dhtpts(ik)*dzz,psym=0,/continue
endfor

return
end 
