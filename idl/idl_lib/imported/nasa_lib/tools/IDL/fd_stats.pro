;-----------------------------------------------------------------------
; NAME:
;        FD_STATS
;
; PURPOSE:
;        Takes sensitivities from global bpch files and outputs values
;        as column data suitable for plotting with MATLAB. 
;
; CATEGORY:
;        dkh tools
; REQUIREMENTS:
;        ctm_xy_print.pro
;-----------------------------------------------------------------------



pro fd_stats

   ; 2nd order fd vs adj
   ctm_xy_print, 'FD-TEST', tracer=[92001,92002],ilun=21, fname='fd_vs_adj.txt'
   
   ; 2nd order fd vs 1st order fd (+)
   ctm_xy_print, 'FD-TEST', tracer=[92001,92004],ilun=21, fname='fd_vs_fd1p.txt'

   ; 2nd order fd vs 1st order fd (+)
   ctm_xy_print, 'FD-TEST', tracer=[92001,92006],ilun=21, fname='fd_vs_fd1n.txt'

end
 
