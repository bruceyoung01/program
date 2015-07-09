Ptype = 'gif'
Ptype = 'ps'

if(Ptype eq 'gif' ) then begin
window,0,xsize=780,ysize=1000
endif

;----- define color table
read_gif,'/disk6/dechang/mkgif/B_P_175.gif',table,rr1,gg1,bb1
;read_gif,'/disk6/dechang/mkgif/BW_65.gif',table,rr1,gg1,bb1

   ; 1-array should be "150" to make GRAY
   rr1(1) = 150
   gg1(1) = 150
   bb1(1) = 150
   ;255 - array should be 255 to make background white
   rr1(255) = 255
   gg1(255) = 255
   bb1(255) = 255
   rr1(254) = 0  
   gg1(254) = 0  
   bb1(254) = 0  
   tvlct,rr1,gg1,bb1
   ; This is for color bar
   table = bytarr(256 ,1)
   FOR i=0,255  DO table(i,*) = i


if(Ptype eq 'ps' ) then begin
set_plot,'ps'
fflname='Test.ps'
print, fflname
device, file=fflname
device, /color,  bits=8
device, /inches, xsize=8.5, ysize=11., xoffset=0., yoffset=0.5
endif

;== Diagram...
!p.position = [ 0.13,0.23,0.48,0.47]

-----


tb  = convect
   FOR j=0,208-1 DO BEGIN 
   FOR i=0,dim-1 DO BEGIN 
   if( tb(j,i) le 0. ) then tb(j,i)=0.
   endfor
   endfor

xlon=x1
ylat=y1

;========================== PLOT ====================================
; FOR CONV RAIN
;erase

;-- for color
t1 = [0.,1.,2.,4.,7.,10.,15.,20.,25.,30.,60.]
c1 = fix( (175-50)/10.*findgen(11) + 50 )
c1 = fix( (175-20)/10.*findgen(11) + 20 )
c1(0)=0 
c1(2)=46
c1(4)=87
c1(5)=100 ; yellow
z1=t1







;==== CONTOURING





;-- FOR BW-50 color/ 10 level
for i=0,10  do begin
 table(i,*) = c1(i)
endfor

ch_z=strarr(11)
ch_z(0:4)  = string( format = ' ( i1   )', z1(0:4))
ch_z(5:10) = string( format = ' ( i2   )', z1(5:10))
ch_z(10) = ' '
ch_z(0)  = ' '

if(Ptype eq 'ps' ) then begin
cobar_ps1 , charsize = 0.8, format = '(I2)', bar=table, $
          title = 'Rainfall Rate (mm/h)', $
          bottom=0, ncolors=9 , color = 254, $
          min =   0, max = 10, divisions = 10, ticmark=ch_z,$
          location = [0.520, 0.455, 0.870, 0.47]
endif
if(Ptype eq 'gif' ) then begin
cobar_gif1 , charsize = 0.7, format = '(I2)', bar=table, $
          title = 'Rainfall Rate (mm/h)', $
          bottom=0, ncolors=9, color = 254, $
          min =   0, max = 10, divisions = 10, ticmark=ch_z, $
          location = [0.520, 0.455, 0.870, 0.47]
endif


if(Ptype eq 'ps' ) then begin
device,/close
endif

if(Ptype eq 'gif' ) then begin
fflname='test.gif'
print, fflname
write_gif, fflname, tvrd(),rr1,gg1,bb1
endif

END
