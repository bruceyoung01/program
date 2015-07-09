
 pro plot2ps, refPro=refPro, gxout=gxout, eps=eps, xsize=xsize, ysize=ysize
     device, file=tag+gfile, xsize=18, ysize=26, xoffset=1.5, yoffset=1.5, /encapsulated

 if n_elements(refPro) eq 0 then return
 if n_elements(gxout) eq 0 then gxout = 'graph.ps'
 if n_elements(xsize) eq 0 then xsize = 18
 if n_elements(ysize) eq 0 then ysize = 26
 if n_elements(xoffset) eq 0 then xoffset = 1.5
 if n_elements(yoffset) eq 0 then yoffset = 1.5
    ieps = 0
 if Keyword_set(eps) then ieps = 1


 set_plot, 'ps'

 device, file=gxout, xsize=xsize, ysize=ysize, xoffset=1.5, yoffset=1.5, encapsulated=ieps
 
 call_procedure, refPro

 device, /close

 set_plot, 'X'

 return
 end
