;  $id: fd_vs_adj.pro
;  xxu, 2/17/10

   PRO fd_vs_adj

;  fd_vs_adj filenames generated from "fs_stats"

   fname_2nd = 'fd_vs_adj.txt'
   fname_1ne = 'fd_vs_fd1n.txt'
   fname_1ps = 'fd_vs_fd1p.txt'

;  read data fron those files

   readcol, fname_2nd, adj1,fd1, FORMAT = 'F,F'
   readcol, fname_1ne, adj2,fd2, FORMAT = 'F,F'
   readcol, fname_1ps, adj3,fd3, FORMAT = 'F,F'

;  scatter plot

   SET_PLOT, 'PS'
   DEVICE, FILENAME='./fd_vs_adj.ps', $
           XSIZE=8.5, YSIZE=10, $
           XOFFSET=0.5, YOFFSET=0.5,$
           /INCHES,/color,BITS=8

   minx = min(adj1)
   maxx = max(adj1)

   minx = minx - 0.1*abs(minx)
   maxx = maxx + 0.1*abs(minx)

   PLOT, adj1, fd1, /nodata, color=1, $
         xrange = [minx,maxx], xstyle = 1, $
         yrange = [minx,maxx], ystyle = 1, $
         xtitle = '!6Adjoint Sensitivity [kg/grid]', $
         ytitle = '!6Finite Difference Sensitivity', $
         position = [0.3,0.4,0.7,0.7] 

   OPLOT, adj2, fd2, color = 2, psym=sym(6), symsize = 0.7
   OPLOT, adj3, fd3, color = 4, psym=sym(6), symsize = 0.7
   OPLOT, adj1, fd1, color = 1, psym=sym(6), symsize = 0.7

  
   DEVICE, /CLOSE


   END
