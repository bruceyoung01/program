;example of plots to make with output data

;REMEMBER THAT THE OUTPUT FILE (.IDLDAT) IS A DATA STRUCTURE!!!
;to see the contents type "help, spdata, /structure"

;data read directory
outdir='/research/wang/ljudd/sub_pixel_output/AQUA/'

;restore the data structure...this will need to be a loop for all files
restore,outdir+'subpixel_201109062105.idldat'

;OUTPUT data directory
outdir='/research/wang/ljudd/graphics_output/'


;create some simple plots

;name of the ps file
outfile='sample_plots_texas'

    ; set up ps file
    ps_color, filename = outdir+outfile + '.ps'

    myclrtable, red =red, green=green, blue=blue
    clrinx = findgen(n_elements(red))
    tvlct, red, green, blue

    black = clrinx(16)
    nlevel = 42            ; level of colors

    
    !p.background = clrinx(0) ; white
    !p.thick=3 
    !p.charthick=3
    !p.charsize=1.2 

;PLOT 1: map of fire pixels

    ;region to plot...the limits you used when downloading data
    latb=25
    latt=50
    lonw=-93
    lone=-130

    ;total map limits...expand the boundaries
    latbt=latb-50
    lattt=latt+50
    lonet=lone+50
    lonwt=lonw-50

    ; define region
    region = [LATBt, LONWt, LATTt, LONEt]
    position = [0.1, 0.37, 0.9, 0.7]

    Map_set, /continent, /usa, limit = region, $
      position = position, color = black, $
      /label, latlab = region(1), lonlab = region(0), $
      title = 'MODIS Fire Counts'

    plots, [lonw, lone, lone, lonw, lonw], $ 
	 [latb, latb, latt, latt, latb], color = black, thick=10

    ;get data for only the regional subset
    region=where(spdata.flat ge latb and spdata.flat le latt and $
             spdata.flon ge lonw and spdata.flon le lone)
    plots, spdata.flon(region), spdata.flat(region), color = 55,psym=sym(1), symsize=.5



;PLOT 2: compare MODIS FRP to the sub-pixel FRP 
    	 position1 = [0.1, 0.37, 0.9, 0.9]    	
	 xdata=spdata.frp_modis
	 ydata=spdata.frp_fire
	 title='FRP Comparison'
	 XTITLE = 'MODIS !6FRP!Ip!N (MW)'
	 YTITLE = 'Sub-Pixel !6FRP!If!N (MW)' 
	 range  = [0,1000]
	    PLOT, range, range, YRANGE = range, xrange=range,color=black, $
	    PSYM = 10,title=title,xthick=2, ythick=2,thick=2,$
    		XTITLE = xtitle, YTITLE = ytitle,$
		position=position1, /nodata    	    
	    PLOTs,xdata, ydata,color=black,psym=sym(1), symsize=1
    	    oplot, range,range,color=black,linestyle=2
	    

;PLOT 3: compare the MODIS 11um pixel temp to the 11um background temp
	 xdata=spdata.tb11
	 ydata=spdata.pixt11
	 title='Brightness Temperatures (MODIS Fire Pixels)'
	 XTITLE = 'MODIS 11 um Background Brightness Temp. (K)'
	 YTITLE = 'MODIS 11 um Pixel Brightness Temp. (K)'  
	 range=[280,320]  
	    PLOT, range, range, YRANGE = range, xrange=range,color=black, $
	    PSYM = 10,title=title,xthick=2, ythick=2,thick=2,$
    		XTITLE = xtitle, YTITLE = ytitle,$
		position=position1, /nodata    	    
	    PLOTs,xdata, ydata,color=black,psym=sym(1), symsize=1
	    r=where(xdata gt ydata)
	    if n_elements(r) gt 0 and r(0) gt 0 then begin
	    PLOTs,xdata(r), ydata(r),color=50,psym=sym(1), symsize=1	
	    xyouts, 303, 284, 'Total MODIS Err: '+ string(n_elements(r), format= '(i2)'),color=black 
	    endif  else begin
	    xyouts, 303, 284, 'Total MODIS Err: '+ '0',color=black
	    endelse
	    
	     oplot, range,range,color=black,linestyle=2
	    
	    ;bottom caption about errors
	    xyouts, 303, 282, 'Total MODIS Pix: '+ string(n_elements(xdata), format= '(i2)'),color=black





device,/close








end
