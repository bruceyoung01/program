;
; processing modis water cloud effective radius, etc.
; 

;pro water_cld_main 
@read_modis_06.pro
@plot_single_gradule_mod06.pro
@../subpro/color_imagemap.pro
@water_processing_for_ploting.pro
@process_day_time.pro

; input file name
filedir = '../'
filename = 'MOD06_L2.A2008009.1350.005.2008010121718.hdf'

; some ranges for the plot
mincldopt = 1.0  & maxcldopt = 47.0
mincldreff = 1.0 & maxcldreff = 47.0
mincldwtph = 0.01  & maxcldwtph = 11.51
mincldfrac = 2. & maxcldfrac = 94 
yc = -2.6
xc = -60.05
xx = 6
yy = 6
region_limit = [yc-yy/2, xc-xx/2., yc+yy/2, xc+xx/2. ]


set_plot,'ps'
device,filename=strmid(filename, 0, 22)+'.ps', /portrait,xsize=7.5, ysize=9,$
      xoffset=0.5,yoffset=1,/inches, /color, bits=8

;!p.multi = [0, 1, 2]
load_clt, colors

read_modis06_cldopt, Filedir, filename, cldopt, cldreff, cldwtph, $
                    cldphase, cldfrac, cldpress, cldtemp, cldsza, flat, flon, np, nl

; for 5km data dimension
 nnp = np/5
 nnl = nl/5

; decide if it should be mearged
LatB = region_limit(0)
LatT = region_limit(2)
LonL = region_limit(1)
LonR = region_limit(3)

water_processing_for_ploting, cldopt, cldreff, cldwtph,$
cldphase, cldpress, cldtemp, np, nl, $
nnp, nnl

print, 'merge 1 '


; write output data for reprocessing
;openw, 1, Dayname+'_cloud.dat'
;writeu, cldopt(0:np-1, 0:totnl-1), cldreff(0:np-1,  0:totnl-1), $
;        cldwtph(0:np-1, 0:totnl-1),  


; do plotting
!p.multi = 0

plot_cldopt, cldopt(0:np-1, 0:nl-1), cldreff(0:np-1, 0:nl-1),$
             cldwtph(0:np-1, 0:nl-1), cldfrac(0:nnp-1, 0:nnl-1), $
	     flat(0:nnp-1, 0:nnl-1), flon(0:nnp-1, 0:nnl-1), $
             np, nl, nnp, nnl, maxcldopt, mincldopt, $
             maxcldreff, mincldreff, maxcldwtph,  mincldwtph, $
             maxcldfrac, mincldfrac,  region_limit, colors, strmid(filename, 0, 22) 



device, /close
print, 'Prom is over !!!'

end



