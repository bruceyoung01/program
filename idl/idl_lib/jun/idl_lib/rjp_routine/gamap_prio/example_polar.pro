; $Id: example_polar.pro,v 1.1.1.1 2003/10/22 18:06:04 bmy Exp $

pro example_polar,title=title,ps=Do_PS,_EXTRA=e


    ; produce a 4-panel polar plot for
    ; Ox, CO, PAN, and NOx with GAMAP

    ; requires some user interaction, but sets
    ; GAMAP into "nice" mode for each plot
    ; Choose plot type filled contour for best results


    ; set multipanel environment for 4 plots
    multipanel,nplots=4,omargin=[0.2,0.0,0.2,0.08],margin=[0.,0.10]

    ; set device to postscript if desired
    open_device,ps=Do_PS,/color,/landscape


    ; reload colortable if postscript device
    if (!D.name eq 'PS') then $
       myct,27,range=[0.1,0.8],sat=0.97,val=1.25


    ; set font
    xyouts,0,0,'!6',/norm

    ; first call to GAMAP : Ox
    gamap,/nofile,'IJ-AVG-$',tracer=2,title='Ox',/polar, $
         c_level=findgen(11)*10,skip=2,/cell_fill,_EXTRA=e

    ; second call to GAMAP : CO
    gamap,/nofile,'IJ-AVG-$',tracer=4,title='CO',/polar, $
         c_level=findgen(8)*50,skip=2,/cell_fill,_EXTRA=e

    ; third call to GAMAP : PAN
    gamap,/nofile,'IJ-AVG-$',tracer=3,title='PAN',/polar, $
         c_level=[0.1,0.3,1.,3.,10,30,100,300,1000,3000,10000,30000],  $
         skip=4,/cell_fill,unit='pptv',_EXTRA=e

    ; fourth call to GAMAP : NOx
    gamap,/nofile,'IJ-AVG-$',tracer=1,title='NOx',/polar, $
         c_level=[0.001,0.003,0.01,0.03,0.1,0.3,1.,3.,10.,30.],  $
         skip=4,cbform='(f14.3)',/cell_fill,_EXTRA=e



    ; global title
    if (n_elements(title) eq 0) then begin
       title = 'GEOS CTM results for March 1994' +  $
         '!C!C layer 2 (~0.5 km)'
    endif

    xyouts,0.5,0.98,title,/norm,color=1,charsize=1.5,align=0.5

    
    ; close device and turn multipanel environment off
    close_device
    multipanel,/off

    return
end


