Pro load_aqi_color 
red   = intarr(15)
green = intarr(15)
blue  = intarr(15)
;         0    1   2     3     4    5   6    7   8    9    10   11   12    13   14
;red   = [0,  255, 0,   200,   0,   0, 145,  10, 20, 175, 100, 170,  255, 200, 255]
;green = [0,    0, 220,   0, 240,   0, 90,  150, 150, 10,  30, 170,  100, 200, 255]
;blue  = [0,    0, 255, 180,   0, 255,  10,  30, 250, 80, 200, 10,   220, 200, 255]
        ;   blue green  YELLO ORANGE RED PURPLE Maroon     
;red   = [0,   0,   0, 255, 255,    255,  153, 76, 255]
red   = [0,   0,   0, 255, 255,    255,  153, 76, 255]
green = [0,   0, 228, 185, 126,      0,    0,  0, 255]
blue  = [0, 255,   0,   0,   0,      0,   76, 38, 255]

        ;  good moderate ....

TVLCT, red, green, blue
END 


Pro set_aqi_legend, xa, dx, ddx, ya, dy, ddy
   AQIcategory = ['Very!cGood', 'Good', 'Light', $
                  'Light!cModerate', 'Moderate', $
                  'Moderate!cHeavy', 'Heavy']  
   for i = 0, 6 do begin
   ; plots, xa+ i*dx, ya-i*dy, color=i+1, psym=sym(1, 1), symsize=1.5, /normal
    polyfill, [xa+i*dx, xa+ i*dx+dx, xa+ i*dx+dx, xa+i*dx, xa+i*dx], $
           [ya, ya, ya+dy, ya+dy, ya], $
           color=i+1,  /normal
   
    if ( i ne 3 and i ne 5 and i ne 0) then begin 
    xyouts, xa+i*dx+dx/2., ya+dy/3, AQIcategory(i), color=8, $
           /normal, align=0.5, charsize=0.95, charthick=3
    endif else begin
    xyouts, xa+i*dx+dx/2., ya+dy/2, AQIcategory(i), color=8, $
           /normal, align=0.5, charsize=1.0, charthick=3
    endelse 

   endfor
   
End 


