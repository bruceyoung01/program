;;;== START PROGRAM

;== Define color
r=intarr(256)
g=intarr(256)
b=intarr(256)
for i=0,255 do begin
        r(i)=i
        g(i)=i
        b(i)=i
endfor
r(0)=255
g(0)=255
b(0)=255

r(2)=255
g(2)=0  
b(2)=0  

r(3)=0  
g(3)=0  
b(3)=255

tvlct,r,g,b


;== Select plot type
Ptype = 'gif'
;Ptype = 'ps'

if(Ptype eq 'ps' ) then begin
set_plot,'ps'
fflname='track.ps'
device, file=fflname
device, /color,  bits=8
device, /inches, xsize=8.5, ysize=11., xoffset=0., yoffset=0.5
!p.position = [ 0.20,0.30,0.80,0.70]
endif

;if(Ptype eq 'gif' ) then begin
;window,0,xsize=780,ysize=1000
;!p.position = [ 0.20,0.30,0.80,0.70]
;endif


;== Input data ( Lat/Lon/SLP)
x1=[-61.6, -62.4, -63.6, -71.6, $
    -71.6                       ]
y1=[ 15.8,  17.6,  18.0,  18.4, $
     18.6                       ]
p1=[1008.33, 1008.51, 1010.60, 1012.02, 1012.53]
cp1 = string(format = '(f6.1 )', p1)


;== Map
map_set,0,0,limit=[10,-80,30,-55],/continent,/usa, latdel=5, londel=5,$
            title='Sample of title',$
            charsize=.9, /advance,/grid,/isotropic,color=1


oplot, x1,y1, color=2,thick=1.0,noclip=0
oplot, x1,y1, psym=2, symsize=0.9,color=2
xyouts,x1,y1-1.,cp1,charsize=0.7, color=3,alignment=0.5,/data

map_set,0,0,limit=[10,-80,30,-55],/continent,/usa, latdel=5, londel=5,$
            charsize=.9, /noerase,/grid,/isotropic,color=1,$
            label=2,lonlab=10.2,latlab=-55.5


if(Ptype eq 'ps' ) then begin
device,/close
endif
if(Ptype eq 'gif' ) then begin
fflname='track.gif'
write_gif, fflname, tvrd(),r,g,b
endif



END
;;;== END of program ..
