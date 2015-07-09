
; define array to save lat, lon, u, and v
np = 48
nl = 48
nz = 19
flat = fltarr(np,nl)
flon = fltarr(np,nl)
U = fltarr(np, nl)
V = fltarr(np, nl)

;read lat, lon, u, and v
openr, 1, 'u.dat'
readu, 1, U
close,1

openr, 1, 'v.dat'
readu, 1, V
close,1

openr, 1,  'Lat.dat'
readu, 1, flat
close,1
 
openr, 1,  'Lon.dat'
readu, 1, flon 
close,1



; start to plot
set_plot, 'ps'
device, filename = 'wind.ps', xsize=7, ysize=10, $
        xoffset=0.5, yoffset=0.5, /inches
!p.thick=3
!p.charthick=3
!p.charsize=1.2

; legend coordinate     
      xa = 0.125       &   ya = 0.9
      dx = 0.05      &   dy = 0.00

; region of interest
  region_limit =  [10, -110,   40 , -75]

; position of the figure in the ps file
  position = [0.0775, 0.3075, 0.9035, 0.8725]

; title of the figure
  title = 'Wind Vector'

velo, np, nl, flat, flon, u, v, $
        region_limit,  $
        position, title 


device, /close
end




