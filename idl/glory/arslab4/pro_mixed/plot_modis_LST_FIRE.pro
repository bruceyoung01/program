@/home/bruce/idl/Williwaw/task/superior/MOD11T/set_legend.pro
@/home/bruce/program/idl/arslab4/color_contour.pro
@/home/bruce/idl/Williwaw/task/superior/MOD11T/modis_lst_lat_lon.pro
@/home/bruce/program/idl/arslab4/sub_read_mod11.pro
@/home/bruce/program/idl/arslab4/sub_read_mod14.pro


 
filedir   = '/home/bruce/data/modis/arslab4/mod11/2000/'
filename  = 'MOD11_L2.A2000069.1705.005.2006259135542.hdf'

filedir1  = '/home/bruce/data/modis/arslab4/mod14/2000/'
filename1 = 'MOD14.A2000069.1705.005.2008236002348.hdf'
date = float( strmid(filename, 11, 7) )
output = strmid(filename, 0, 22) 

sub_read_mod11, filedir, filename, np, nl, rlat, rlon, lst

sub_read_mod14, filedir1, filename1, nfire, lat, lon, fire_sample, fire_line



; define the max and min for your color bar 
; make your own choice here
maxvalue= 320
minvalue= 260

; color bar coordinate
    xa = 0.125       &   ya = 0.9
      dx = 0.05      &   dy = 0.00
      ddx = 0.0      &   ddy = 0.03
      dddx = 0.05    &   dddy = -0.047
      dirinx = 0     &   extrachar=' K'
; color bar levels
n_levels = 12

;labelformat
FORMAT = '(f6.2)' 

; region
;region = [min(rlat)-2, min(rlon)-2, max(rlat)+2, max(rlon)+2]
;region =[45.2, -93, 50.5, -83]
region =[10, -115, 45, -65]


; title
title = 'MODIS LAND SURFACE TEMPERATURE ' 

set_plot, 'ps'
device, filename = output + '.ps', xsize=7, ysize=10, $
        xoffset=0.5, yoffset=0.5, /inches,/color, bits = 8
!p.thick=3 
!p.charthick=3
!p.charsize=1.2 
 
rlat = congrid(rlat, np, nl, /interp)
rlon = congrid(rlon, np, nl, /interp)

color_contour, rlat, rlon, lst, maxvalue, minvalue, $
                  N_Levels , region, $
                  xa, dx, ddx, dddx, $
                  ya, dy, ddy, dddy, FORMAT, dirinx, extrachar, title

MyCt, /Verbose, /WhGrYlRd 
plots, lon, lat, symsize = 0.5, psym = sym(1), color = 1
device, /close
END
