;example of plots to make with output data
@ stats_out.pro

;REMEMBER THAT THE OUTPUT FILE (.IDLDAT) IS A DATA STRUCTURE!!!
;to see the contents type "help, spdata, /structure"

;data read directory
dir_data='/home/dpeterson/fire/ams_data/my_routines/subpixel_package/test_data/'

;number of files
nf=30 ;this will change

;define filenames
filenames = strarr(nf)

;Read filenames file
;openr,1, dir_data + 'filenames.txt'
;readf,1,filenames
;close,1

;OUTPUT directory for plots
outdir='/home/dpeterson/fire/ams_data/my_routines/subpixel_package/'


;create some simple plots

;SET UP PS FILE 
;name of the ps file
outfile='sample_plots3'

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
    latb=35
    latt=45
    lonw=-130
    lone=-115

    ;total map limits...expand the boundaries
    latbt=latb-5
    lattt=latt+5
    lonet=lone+10
    lonwt=lonw-10

    ; define region
    region = [LATBt, LONWt, LATTt, LONEt]
    position = [0.1, 0.37, 0.9, 0.7]

    Map_set, /continent, /usa, limit = region, $
      position = position, color = black, $
      /label, latlab = region(1), lonlab = region(0), $
      title = 'MODIS Fire Counts'

    plots, [lonw, lone, lone, lonw, lonw], $ 
	 [latb, latb, latt, latt, latb], color = black, thick=10
    
    ;restore each individual data structure and plot fire locations
    ;go through each file
    	
   ; for ff=0, nf-1 do begin	    
    restore,dir_data+'subpixel_200709080655.idldat'  
	;get lat/lons for only the regional subset
	rdata=where(spdata.flat ge latb and spdata.flat le latt and $
        	 spdata.flon ge lonw and spdata.flon le lone)

	;plot data on map
	plots, spdata.flon(rdata), spdata.flat(rdata), color = 55,psym=sym(1), symsize=.5
   ; endfor


;PLOT 2: compare MODIS FRP to the sub-pixel FRP 
    	 position1 = [0.1, 0.37, 0.9, 0.9]    	
	 title='FRP Comparison'
	 XTITLE = 'MODIS !6FRP!Ip!N (MW)'
	 YTITLE = 'Sub-Pixel !6FRP!If!N (MW)' 
	 range  = [0,1000]
	    PLOT, range, range, YRANGE = range, xrange=range,color=black, $
	    PSYM = 10,title=title,xthick=2, ythick=2,thick=2,$
    		XTITLE = xtitle, YTITLE = ytitle,$
		position=position1, /nodata
		
		
	;BUILD LOOP HERE...as in the above example


    	;now plot using the VZA color scheme and stats output 
	
	;set a variable to collect total output for stats
	totx=fltarr(1000)
	toty=fltarr(1000)
	data0=0.0
	   	
	;restore file
	restore,dir_data+'subpixel_200709080655.idldat' 
		
	    ;plot data 
	    ;result=where(spdata.frp_fire gt 0)
	    xdata=spdata.frp_modis	;(result)
	    ydata=spdata.frp_fire	;(result)
	    zdata=spdata.vza	;(result)
	    
	   	;plot based on VZA
		ipnt=n_elements(xdata)			 	
		for ei=1, ipnt-1 do begin
		if zdata(ei) lt 20 then begin  		
		    ccolor=20
		endif else if zdata(ei) ge 20 and zdata(ei) le 40 then begin
		    ccolor=35			
		endif else if zdata(ei) gt 40 and zdata(ei) le 60 then begin
		    ccolor=50		        	
		endif else if  zdata(ei) gt 60  then begin
	    	    ccolor=55		        	 	
		endif	
		
		;plot data
	        PLOTs,xdata(ei), ydata(ei),color=ccolor,psym=sym(1), symsize=1
		
		endfor	     
	    	    
	    	;collect data for stats
		totx(data0:ipnt-1)=xdata
		toty(data0:ipnt-1)=ydata
		data0=ipnt
		
	;endfor...END LOOP HERE
	
	;add stats to the plot
	;postion for output
	xxp=20
	yyp=950
	r=where(xdata gt 0)	
    	stats_out, xdata(r), ydata(r), xxp, yyp, range, xtitle, ytitle, black
	
		
    	;PLOT 1 TO 1 line	
	     oplot, range,range,color=black,linestyle=2	   
	     
	;legend
	  pcolors=[20,35,50,55]
          thicks= [3,3,3,3]
          symsizes=[1,1,1,1] 
	  psyms=  [sym(1),sym(1),sym(1),sym(1)]
	  txt=['VZA < 20 Deg.', 'VZA = 20 - 40 Deg.','VZA = 41 - 60 Deg.','VZA > 60 Deg.']   
    	    legend, pos=[.62, .46],/norm,psym=psyms, color=pcolors,txt, charsize=1, charthick=3, box=0, $
	    thick=thicks,textcolors=black,symsize=symsizes	     
	    
	    	    

;PLOT 3: compare the MODIS 11um pixel temp to the 11um background temp
	 title='Brightness Temperatures (MODIS Fire Pixels)'
	 XTITLE = 'MODIS 11 um Background Brightness Temp. (K)'
	 YTITLE = 'MODIS 11 um Pixel Brightness Temp. (K)'  
	 range=[280,320]  
	    PLOT, range, range, YRANGE = range, xrange=range,color=black, $
	    PSYM = 10,title=title,xthick=2, ythick=2,thick=2,$
    		XTITLE = xtitle, YTITLE = ytitle,$
		position=position1, /nodata 
	
	
	    ;THIS ONE IS A BIT HARDER
	    ;We need the xyouts command to reflect all data not just one file
	    
	    ;START
	    
	    ;restore 
	    
	    ;plot data
	    xdata=spdata.tb11
	    ydata=spdata.pixt11   	    
	    PLOTs,xdata, ydata,color=black,psym=sym(1), symsize=1
	    
	    ;find cases where the background temp is warmer than the mean pixel temp (modis errors)
	    r=where(xdata gt ydata, count)
	    if count gt 0 then begin
	    ;plot error pixels in yellow
	    PLOTs,xdata(r), ydata(r),color=50,psym=sym(1), symsize=1	
	    xyouts, 303, 284, 'Total MODIS Err: '+ string(n_elements(r), format= '(i2)'),color=black 
	    endif  else begin
	    xyouts, 303, 284, 'Total MODIS Err: '+ '0',color=black
	    endelse
	    
	    ;END
	    
	    
	    ;PLOT 1 TO 1 line	
	     oplot, range,range,color=black,linestyle=2
	    
	    ;bottom caption about errors
	    xyouts, 303, 282, 'Total MODIS Pix: '+ string(n_elements(xdata), format= '(i2)'),color=black





device,/close








end
