
   @./colorbar.pro

   SET_PLOT,'X'
   WINDOW,1

   loadct, 40, ncolor = 80, bottom = 20

   bar_levels = (indgen(7) - 3)*5
   bar_names = strtrim(bar_levels,1)

   colorbar, bottom = 20, ncolors = 80,$
             ndivisions = 7, ticknames = bar_names, $
             position = [0.2,0.22, 0.8, 0.24], color = 20

   END
