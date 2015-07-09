;Amy Gehring
;METR465 
;Homework 3 Problem 1

PRO hw3p1

;************************************NEW CODE*************************************

So=1368. ;solar constant in Wm^-2
day=FINDGEN(365)+1
F=FLTARR(365,181)
;latn=FLTARR(365)
;lats=FLTARR(365)
y=FLTARR(181)
;tnight=FLTARR(365)

FOR i=0, 180 DO BEGIN

	lat=(i-90.)*!dtor
 	y[i]=(i-90)
	
	FOR j=0, 364 DO BEGIN

	delta=-23.45*!dtor*cos((day[j]+10.)/365*2*!pi)
	delta2=-23.45*cos((day[j]+10.)/365*2*!pi)
	ar=1.+0.034*cos(((day[j]-3.)/365.)*2.*!pi)
	tnight=90-abs(delta2)
			
			if (y[i] GE tnight) then begin
				if (delta GE 0.0) then begin
					H = !pi
				endif else begin
					H = 0.0
				endelse
			endif else if (abs(y[i]) GE tnight) then begin
				if (delta LE 0.0) then begin
					H = !pi
				endif else begin
					H = 0.0
				endelse
			endif else begin
				H = acos(-tan(lat)*tan(delta))
			endelse

			Q = (So/!pi) * ar * (H*sin(lat)*sin(delta) + cos(lat)*cos(delta)*sin(H))
			F[j,i] = Q

ENDFOR
ENDFOR
	
print, delta

set_plot, 'ps'
device, filename='hw3p1.ps', xoffset=0.5, yoffset=0.5, $
	xsize=7.5, ysize=9, /inches, /color

  r=bytarr(64) & g=r & b=r

r(0:63)=[255,238,221,204,187,170,153,136,119,102,85,68,51,34,17,0,100,0,0,$
           0,0,0,0,0,7,15,23,31,38,46,54,62,86,110,134,158,182,206,$
           230,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,$
           255,255,255,255,255,255,255,255,255,255]

g(0:63)=[255,238,221,204,187,170,153,136,119,102,85,68,51,34,17,0,100,0,0,$
           0,0,0,0,0,28,56,84,112,140,168,196,224,227,231,235,239,243,247,$
           251,255,249,243,237,232,226,220,214,209,182,156,130,104,78,52,$
           26,0,0,0,0,0,0,0,0,0]

b(0:63)=[255,238,221,204,187,170,153,136,119,102,85,68,51,34,17,0, 100,36,$
           72,109,145,182,218,255,223,191,159,127,95,63,31,0,0,0,0,0,0,0,$
           0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,31,63,95,127,159,191,223,255]

        tvlct,r,g,b

 bar_labels = ['0','50', '100', '150', '200', '250', '300', $
               '350', '400', '450', '500']
  i_colors=16+findgen(12)*4

  
  i_labels=findgen(12)

 i_levels = [0, 0.01, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50]*1.0e6
	
	contour, F, day, y, levels = [0,50,100,150,200,250,300,350,400,450,500], /FOLLOW,  $
		XRANGE = [1,365], xstyle = 1, $
		YRANGE = [-90,90], ystyle = 1, $
		XTITLE = 'Julian Day (day)', $
		YTITLE = 'Latitude(deg)', $
		Title = '24-Hour Averaged Instantaneous Solar Irradiance', Subtitle = 'Amy Gehring', $
		/fill, c_colors=i_colors, color=15, $
		position=[0.2,0.4,0.8,0.9], $
		charthick=3, thick=3, xthick=3, ythick=3


		contour, F, day, y, levels = [0,50,100,150,200,250,300,350,400,450,500], /FOLLOW,  $
		XRANGE = [1,365], xstyle = 1, $
		YRANGE = [-90,90], ystyle = 1, $
		XTITLE = 'Julian Day (day)', $
		YTITLE = 'Latitude(deg)', $
		Title = '24-Hour Averaged Instantaneous Solar Irradiance', Subtitle = 'Amy Gehring', $
		color=15,$
		/overplot,charthick=5,c_annotation=levels,$
		position=[0.2,0.4,0.8,0.9]

   for j=0,10 do begin
        i = j
        x=0.23+0.025*[2*i, 2*(i+1), 2*(i+1), 2*i]
         y=0.27+0.05*[0,0,1,1]
         polyfill,x,y,color=4*(j)+16 ,/normal
        endfor


   for i = 1,10  do begin

         xyouts, 0.195 + 0.025*(2*i+1), 0.26, bar_labels(i),/normal, $
	   charsize = 0.7, color=15, charthick=3
        endfor

         xyouts, 0.17+0.025*10, 0.23, 'Unit: Wm!u-2!n',$
	    charsize=1, charthick=3,/normal, color=15

device, /CLOSE


END                                         
