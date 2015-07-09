;
; processing modis water cloud effective radius, etc.
; 

;pro water_cld_main 
;@read_modis_06.pro
;@plot_single_gradule.pro
;@water_processing.pro
;@process_day_time.pro

; input file name
;filedir = '../cld_mexico/Terra/'
sensor = 'Aqua'
filedir = '../cld_mexico/' + sensor + '/'

filename = 'filestatistics.txt' 
process_day,  filedir+filename, Nday, AllFileName, StartInx, EndInx, $
              DAYNAME, DAYNUM
STOP
; some ranges for the plot
mincldopt = 1.0  & maxcldopt = 47.0
mincldreff = 1.0 & maxcldreff = 24.0
mincldwtph = 0.01 & maxcldwtph = 0.95 
mincldfrac = 2. & maxcldfrac = 94 
region_limit = [0, -120, 40, -70]

; some temporal varialbe for one day
LatB = -10
LatT = 60
LonL = -120
LonR = -50
GridSize=0.5
NLon = (LonR - LonL)/GridSize+1
NLat = (LatT - LatB)/GridSize+1 

gcldopt  =  fltarr(NLon, NLat)
gcldreff =  fltarr(NLon, NLat)
gcldreffn =  fltarr(NLon, NLat)
gcldreffavg =  fltarr(NLon, NLat)
gcldoptavg =  fltarr(NLon, NLat)
gcldwtph =  fltarr(NLon, NLat)
gcldwtphavg =  fltarr(NLon, NLat)
gflat  =  fltarr(NLon, NLat)
gflon  =  fltarr(NLon, NLat)

for i = 0, NLon-1 do begin
 for j = 0, NLat-1 do begin
    Gflat(i,j) = j * GridSize + LatB
    Gflon(i,j) = i * GridSize + LonL
 endfor
endfor 


; plot start at the end
set_plot,'ps'
device,filename=sensor + 'average.ps',/portrait,xsize=7.5, ysize=9,$
      xoffset=0.5,yoffset=1,/inches, /color, bits=8

;!p.multi = [0, 1, 2]
load_clt, colors

;rea data
for i = 0, Nday-1 do begin
;for i = 0, 0 do begin

;for i = 10, 18  do begin
totnl = 0
totnnl = 0

if (daynum(i) ge 421 and daynum(i) le 522) then begin  

for j = startinx(i), Endinx(i) do begin

read_modis06_cldopt, Filedir, AllFilename(j), tmpcldopt, tmpcldreff, tmpcldwtph, $
                    tmpcldphase, tmpcldfrac, cldpress, tmpflat, tmpflon, np, nl

; for 5km data dimension
 nnp = np/5
 nnl = nl/5

; processessing
water_processing, tmpcldopt, tmpcldreff, tmpcldwtph, tmpcldphase,$
                cldpress, np, nl, nnp, nnl 

; congrid tmplat, tmplon
  tmpflat = congrid(tmpflat, np, nl, /interp)
  tmpflon = congrid(tmpflon, np, nl, /interp)

; monthly averages
;grid_sum, tmpcldopt, tmpflat, tmpflon, np, nl, gcldopt, $
;          glat, glon, gcldoptn 

 grid_sum, tmpcldreff, tmpcldwtph, tmpcldopt, tmpflat, tmpflon, np, nl,  gcldreff, $
           gcldwtph, gcldopt, gcldreffn, latb, latt, lonl, lonr, gridsize

endfor
endif
endfor


;openr, 1, 'Reff_AVG_' + SENSOR +'average.dat'
;readu, 1,  gcldreff, gcldwtph, gcldopt, gcldreffn, gcldreffavg, gflat, gflon
;close, 1

print, 'max gcldreffn = ', max(gcldreffn)

;
; start to plot
;
title = 'Monthly Mean Cloud REFF'
; legend coordinate     
      xa = 0.125       &   ya = 0.9
      dx = 0.05      &   dy = 0.00
      ddx = 0.0      &   ddy = 0.015
      dddx = 0.05    &   dddy = -0.035
     dirinx = 0     &   extrachar='!4l!6m '


;color_contour_uneven, flat, flon, tmp, tmpgeo, ymax, ymin, $
;             intervals, 12,  [10, -115,   45 , -65],  $
;             xa, dx, ddx, dddx,  $
;             ya, dy, ddy, dddy, dirinx, extrachar, title 

; do averaging
for i = 0, nlon-1 do begin
for j = 0, nlat-1 do begin
  if ( gcldreffn(i, j) gt 0 ) then begin
    gcldreffavg(i, j) = gcldreff(i, j) / gcldreffn(i, j)
    gcldoptavg(i, j) = gcldopt(i, j) / gcldreffn(i, j)
    gcldwtphavg(i, j) = gcldwtph(i, j) / gcldreffn(i, j)
  endif
endfor
endfor

color_grid, nlon, nlat, gflat, gflon,  gcldreffavg, -1, $
                 29, 5, 12, [10, -115,   45 , -65],  $
             xa, dx, ddx, dddx,  $
             ya, dy, ddy, dddy, dirinx,   extrachar, title

color_grid, nlon, nlat, gflat, gflon,  gcldoptavg, -1, $
                 29, 5, 12, [10, -115,   45 , -65],  $
             xa, dx, ddx, dddx,  $
             ya, dy, ddy, dddy, dirinx,   ' ', 'TAU' 

color_grid, nlon, nlat, gflat, gflon,  gcldwtphavg, -1, $
                 6, 0, 12, [10, -115,   45 , -65],  $
             xa, dx, ddx, dddx,  $
             ya, dy, ddy, dddy, dirinx,  ' ', 'Liquid Path' 

color_grid, nlon, nlat, gflat, gflon,  gcldreffn, -1, $
                 30000, 4, 12, [10, -115,   45 , -65],  $
             xa, dx, ddx, dddx,  $
             ya, dy, ddy, dddy, dirinx,   ' ', ' Number' 

;color_contour, gflat, gflon, gcldreffavg, -1.,  29, 5, $
;             12,  [10, -115,   45 , -65],  $
;	     xa, dx, ddx, dddx,  $
;	     ya, dy, ddy, dddy, dirinx,$
;	     extrachar, title


;color_contour, gflat, gflon, gcldreffn, -1.,   30000, 4, $
;             12,  [10, -115,   45 , -65],  $
;	     xa, dx, ddx, dddx,  $
;	     ya, dy, ddy, dddy, dirinx,$
;	     extrachar, title

device, /close


;  output
openw, 1, 'Reff_AVG_' + SENSOR +'average.dat'
writeu, 1,  gcldreffn, gcldreffavg, gcldoptavg, gcldwtphavg, gflat, gflon
close, 1


end


