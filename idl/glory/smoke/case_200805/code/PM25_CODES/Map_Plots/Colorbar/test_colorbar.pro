
   @./colorbar.pro

   loadct, 32, ncolors=80, bottom=20

   SET_PLOT, 'PS' 
   DEVICE, file = 'ctables.ps', xsize = 6, ysize =4,$
              /inches, /color, BITS=8
   COLORBAR, NCOLORS=80, BOTTOM=20, POSITION=[0.1, 0.1, 0.9, 0.15]

   DEVICE, /close
  
   END
