
  m = 4
  n = 22

  dir1 = '/home/bruce/program/idl/arslab4/'
  filename1 = 'MOD14.A2003004.1520.005.2007252222235.hdf.txt.dat'
   
  ft = FLTARR(m, n) 
  OPENR, lun, dir1+filename1, /get_lun
  READF, lun, ft

  print, ft(3,0:n-1)
  set_plot, 'ps'
  device, filename =filename1 + '.ps', /portrait, xsize = 7.5, ysize=9, $
          xoffset = 0.5, yoffset = 1, /inches, /color, bits=8

  plot, ft(2,0:n-1), ft(3,0:n-1),psym = 5, color =1, $
        xtitle = 'Fire Number', ytitle = 'Land Surface Temperature (K)', $
        xrange = [15,23], yrange = [270, 310]
        position = [0.2,0.2,0.8,0.6]

device, /close
end
