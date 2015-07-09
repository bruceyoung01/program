;
; make a circle
;
@plot_wrfchem.pro
nl = 180
np = 360
aot = fltarr(np, nl)
lat = fltarr(np, nl)
lon = fltarr(np, nl)
for i = 0, np-1 do begin
 for j = 0, nl-1 do begin
   lat(i,j)  = -90. + j
   lon(i,j) = -180. + i
   aot(i,j) = sqrt(lat(i,j)^2 + lon(i,j)^2)+1
 endfor
endfor

; comapre the following use of color table wit different tuning parameter 
;Myct, /WhGrYlRd  
;Myct, /WhGrYlRd, ncolors=100 
;Myct, /WhGrYlRd, ncolors=100, range=[0.2, 0.8] 
;Myct, /WhGrYlRd, ncolors=100, range=[0.2, 0.8], saturation=1.0 
;Myct, /WhGrYlRd, ncolors=100, range=[0.2, 0.8], saturation=0.5 
;Myct, /WhGrYlRd, ncolors=100, range=[0.2, 0.8], saturation=0.2 
;Myct, /WhGrYlRd, ncolors=50 
;Myct, 27, ncolors=120
;Myct, /dial, /verbose 
;plot_wrfchem, aot, lat, lon, maxaod=90., minaod=0., cb_nticks=10.

; the middle is white color, and so the
; bottom color index can set as black, or bottom
;Myct, /DIFF, /Verbose 
;compare below using botclrinx and not usinb botclrinx  
;plot_wrfchem, aot-100, lat, lon, maxaod=90., minaod=-90, cb_nticks=10.
;plot_wrfchem, aot-100, lat, lon, maxaod=90., minaod=-90, cb_nticks=10.,$
;botclrinx=!myct.white, topclrinx=!myct.white

; NOTE if define you own nlev, then ncolor will be at least = nlev+2 
; level tells # of intervals, so say, 9 intervals need to have 11 colors 
; to seperate them.

;Myct, /BuYlRd, /Verbose, ncolor=100
;Myct, /modspec, /Verbose, ncolor=100, range=[0.2, 0.8], saturation=3
;Myct, /modspec, /Verbose, ncolor=100, saturation=1
; 
;Myct, /diff, /Verbose, ncolor=11, saturation=3, value=0.5
Myct, /diff, /Verbose, ncolor=11, saturation=1.5
plot_wrfchem, aot-100, lat, lon, maxaod=90., minaod=-90, cb_nticks=10, nlev=9


end






