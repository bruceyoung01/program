;
; processing modis water cloud effective radius, etc.
; 

;pro water_cld_main 
@read_modis_06.pro
@plot_single_gradule.pro
@water_processing.pro
@process_day_time.pro

; input file name
;filedir = '../cld_mexico/Terra/'
sensor = 'Aqua'
filedir = '../cld_mexico/' + sensor + '/'

filename = 'filestatistics.txt' 
process_day,  filedir+filename, Nday, AllFileName, StartInx, EndInx, $
              DAYNAME, DAYNUM
print, 'day name is', daynum
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

gcldoptday  =  fltarr(NLon, NLat)
gcldreffday =  fltarr(NLon, NLat)
gcldreffnday =  fltarr(NLon, NLat)
gcldreffavgday =  fltarr(NLon, NLat)
gcldoptavgday =  fltarr(NLon, NLat)
gcldwtphday =  fltarr(NLon, NLat)
gcldwtphavgday =  fltarr(NLon, NLat)

gcldoptnight  =  fltarr(NLon, NLat)
gcldreffnight =  fltarr(NLon, NLat)
gcldreffnnight =  fltarr(NLon, NLat)
gcldreffavgnight =  fltarr(NLon, NLat)
gcldoptavgnight =  fltarr(NLon, NLat)
gcldwtphnight =  fltarr(NLon, NLat)
gcldwtphavgnight =  fltarr(NLon, NLat)

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
device,filename=sensor + 'average_daily_icecldonly.ps',/portrait,xsize=7.5, ysize=9,$
      xoffset=0.5,yoffset=1,/inches, /color, bits=8

;!p.multi = [0, 1, 2]
load_clt, colors

;read data
for i = 0, Nday-1 do begin
;for i = 19, 19 do begin

gcldreffnday = 0.0
gcldreffnnight = 0.0
gcldoptday  =  fltarr(NLon, NLat)
gcldreffday =  fltarr(NLon, NLat)
gcldreffnday =  fltarr(NLon, NLat)
gcldreffavgday =  fltarr(NLon, NLat)
gcldoptavgday =  fltarr(NLon, NLat)
gcldwtphday =  fltarr(NLon, NLat)
gcldwtphavgday =  fltarr(NLon, NLat)

gcldoptnight  =  fltarr(NLon, NLat)
gcldreffnight =  fltarr(NLon, NLat)
gcldreffnnight =  fltarr(NLon, NLat)
gcldreffavgnight =  fltarr(NLon, NLat)
gcldoptavgnight =  fltarr(NLon, NLat)
gcldwtphnight =  fltarr(NLon, NLat)
gcldwtphavgnight =  fltarr(NLon, NLat)


;for i = 10, 18  do begin
totnl = 0
totnnl = 0

for j = startinx(i), Endinx(i) do begin
;for j = startinx(i), startinx(i)+6 do begin

read_modis06_cldopt, Filedir, AllFilename(j), tmpcldopt, tmpcldreff, tmpcldwtph, $
                    tmpcldphase, tmpcldfrac, tmpcldpress, tmpcldtemp, $
		    tmpcldsza, tmpflat, tmpflon, np, nl


result = where ( tmpcldreff gt 0, count)
;print, 'count = ', count 
;if count gt 1000 then stop
print, 'nl = ', nl
; for 5km data dimension
 nnp = np/5
 nnl = nl/5

; processessing
water_processing, tmpcldopt, tmpcldreff, tmpcldwtph, tmpcldphase,$
                tmpcldpress, tmpcldtemp, np, nl, nnp, nnl 

; congrid tmplat, tmplon
  tmpflat = congrid(tmpflat, np, nl, /interp)
  tmpflon = congrid(tmpflon, np, nl, /interp)

; monthly averages
;grid_sum, tmpcldopt, tmpflat, tmpflon, np, nl, gcldopt, $
;          glat, glon, gcldoptn 

if (tmpcldsza(np/10, nl/10) gt 0 ) then begin  ; daytime 
 grid_sum, tmpcldreff, tmpcldwtph, tmpcldopt, tmpflat, tmpflon, np, nl,$
 gcldreffday, gcldwtphday, gcldoptday, gcldreffnday, latb, latt, lonl, lonr, gridsize
endif else begin
 grid_sum, tmpcldreff, tmpcldwtph, tmpcldopt, tmpflat, tmpflon, np, nl,$
 gcldreffnight, gcldwtphnight, gcldoptnight, gcldreffnnight, latb, latt, lonl, lonr, gridsize
endelse  
endfor


;openr, 1, 'Reff_AVG_' + SENSOR +'average.dat'
;openr, 1, 'Reff_AVG_' + SENSOR +'average.dat'
;readu, 1,  gcldreff, gcldwtph, gcldopt, gcldreffn, gcldreffavg, gflat, gflon
;close, 1

print, 'max gcldreffnday = ', max(gcldreffnday)
print, 'max gcldreffnnight = ', max(gcldreffnnight)

;
; start to plot
;
title = Dayname(i) 
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
for ii = 0, nlon-1 do begin
for jj = 0, nlat-1 do begin
  if ( gcldreffnday(ii, jj) gt 0 ) then begin
    gcldreffavgday(ii, jj) = gcldreffday(ii, jj) / gcldreffnday(ii, jj)
    gcldoptavgday(ii, jj) = gcldoptday(ii, jj) / gcldreffnday(ii, jj)
    gcldwtphavgday(ii, jj) = gcldwtphday(ii, jj) / gcldreffnday(ii, jj)
  endif
  if ( gcldreffnnight(ii, jj) gt 0 ) then begin
    gcldreffavgnight(ii, jj) = gcldreffnight(ii, jj) / gcldreffnnight(ii, jj)
    gcldoptavgnight(ii, jj) = gcldoptnight(ii, jj) / gcldreffnnight(ii, jj)
    gcldwtphavgnight(ii, jj) = gcldwtphnight(ii, jj) / gcldreffnnight(ii, jj)
  endif
endfor
endfor


color_grid, nlon, nlat, gflat, gflon,  gcldreffavgday, -1, $
                 30, 0, 12, [10, -115,   45 , -65],  $
             xa, dx, ddx, dddx,  $
             ya, dy, ddy, dddy, dirinx,   extrachar, title

color_grid, nlon, nlat, gflat, gflon,  gcldoptavgday, -1, $
                 30, 0, 12, [10, -115,   45 , -65],  $
             xa, dx, ddx, dddx,  $
             ya, dy, ddy, dddy, dirinx,   ' ', 'TAU' 

color_grid, nlon, nlat, gflat, gflon,  gcldwtphavgday, -1, $
                 6, 0, 12, [10, -115,   45 , -65],  $
             xa, dx, ddx, dddx,  $
             ya, dy, ddy, dddy, dirinx,  ' ', 'Liquid Path' 

color_grid, nlon, nlat, gflat, gflon,  gcldreffnday, -1, $
                 1000, 4, 12, [10, -115,   45 , -65],  $
             xa, dx, ddx, dddx,  $
             ya, dy, ddy, dddy, dirinx,   ' ', ' Number' 

if ( max(gcldreffnnight) gt 0 ) then begin
color_grid, nlon, nlat, gflat, gflon,  gcldreffavgnight, -1, $
                 29, 5, 12, [10, -115,   45 , -65],  $
             xa, dx, ddx, dddx,  $
             ya, dy, ddy, dddy, dirinx,   extrachar, title

color_grid, nlon, nlat, gflat, gflon,  gcldoptavgnight, -1, $
                 29, 5, 12, [10, -115,   45 , -65],  $
             xa, dx, ddx, dddx,  $
             ya, dy, ddy, dddy, dirinx,   ' ', 'TAU' 

color_grid, nlon, nlat, gflat, gflon,  gcldwtphavgnight, -1, $
                 6, 0, 12, [10, -115,   45 , -65],  $
             xa, dx, ddx, dddx,  $
             ya, dy, ddy, dddy, dirinx,  ' ', 'Liquid Path' 

color_grid, nlon, nlat, gflat, gflon,  gcldreffnnight, -1, $
                 30000, 4, 12, [10, -115,   45 , -65],  $
             xa, dx, ddx, dddx,  $
             ya, dy, ddy, dddy, dirinx,   ' ', ' Number' 
endif


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

;device, /close


;  output

openw, 6, SENSOR + '_'+ string(daynum(i), format='(I3)') + '_icecld.dat'
writeu, 6,  gcldreffnday, gcldreffavgday, gcldoptavgday, gcldwtphavgday, gflat, gflon
close, 6
endfor

device, /close

stop
end


