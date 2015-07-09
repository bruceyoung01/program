function barw,x0=x0

x=[0,0]
y=[0,0]

loadct,27
ncolor=220
plot,x,y,yrange=[0,ncolor],xrange=[0,ncolor],ymargin=[25,8],background=4,ystyle=1

x0=180
yb=indgen(ncolor+1)
xb=replicate(x0,ncolor+1)
color=findgen(ncolor+1)

plots,xb,yb,color=color,thick=40

fd=[1,3,5,7,9,11,13]
o3s=string(fd,format='(i2)')
bar_o3=((fd-0.0)/(21.4950-0.0))*320


loadct,26
for i=0,6 do xyouts,x0-8,bar_o3(i),o3s(i),charsize=1.1,color=0
xyouts,x0-11,40,'Water Vapor (g/kg)',orientation=90,charsize=1.1,color=0

return,color
stop
end
