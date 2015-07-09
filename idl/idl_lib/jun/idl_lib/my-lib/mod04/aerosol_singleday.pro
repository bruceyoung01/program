;
; processing modis water cloud effective radius, etc.
; 

;pro water_cld_main 
@read_modis_04.pro
@plot_single_gradule_mod04.pro
@../subpro/process_day_time.pro
@../subpro/color_imagemap.pro 

; input file name
filedir = '../'
filename = 'MOD04_L2.A2008009.1350.005.2008010115754.hdf'

; some ranges for the plot
minaeropt = 0.0  & maxaeropt = 1.0
minsmfrac = 0. & maxsmfrac = 1.0 
yc = -2.6
xc = -60.05
xx = 6
yy = 6
region_limit = [yc-yy/2, xc-xx/2., yc+yy/2, xc+xx/2. ]


set_plot,'ps'
device,filename=strmid(filename, 0, 22)+'.ps', /portrait,xsize=7.5, ysize=9,$
      xoffset=0.5,yoffset=1,/inches, /color, bits=8

!p.multi = [0, 1, 2]

load_clt, colors

read_modis04_aeropt, Filedir, filename, aeropt, smfrac, $
                     flat, flon, np, nl

; decide if it should be mearged
LatB = region_limit(0)
LatT = region_limit(2)
LonL = region_limit(1)
LonR = region_limit(3)

!p.multi = [0, 2, 1]

; coordinate for ploting 
  xa = 0.07 & xb = 0.40 & ya = 0.65  & yb = 0.9
  dx = -0.0070 & ddx = -0.005 &  dy = +0.008 & ddy=0.005

plot_mod04_opt, aeropt, maxaeropt,  minaeropt, flat, flon, np, nl, $
              region_limit, colors, xa, xb, ya, yb, dx, dy, ddx, ddy,$
              'Aerosol Optical Depth (@0.55!4l!6m)!c' + strmid(filename, 0, 22)
plots, -60.05, -2.6, psym=sym(6,3),  symsize=2, color=63, /data          

;delx = 0.48
;load_clt, colors
;plot_mod04_opt,  smfrac,  maxsmfrac,  minsmfrac, flat, flon, np, nl, $
;              region_limit, colors, xa+delx, xb+delx, ya, yb, dx, dy, ddx, ddy,$
;              'Aerosol Optical Depth Ratio Small', strmid(filename, 0, 22)


device, /close
print, 'Prom is over !!!'

end



