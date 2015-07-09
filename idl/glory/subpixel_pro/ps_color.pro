  
 ; routine used to set color ps
 PRO  ps_color, filename = filename
 set_plot, 'ps'
 device, filename = filename, xoffset=0.5, yoffset=0.5, xsize=7.5, $
         ysize = 10, /inches, /color, bits = 8
 END
