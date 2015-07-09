; purpose: read MODIS04 tau and plot for ACE ASIA regions
;           also using color_image.pro

;pro for reading
  pro fread, Infile, ch
    openr, 1, Infile
    readu, 1, ch
    close,1
   end

;; pro for ploting begin
pro plot_modis,  colors, Infile, statinx, endinx

nz = endinx - statinx + 2
np = 135L
nl = 203L 

flat = fltarr(np, nl*nz)
flon = fltarr(np, nl*nz)
ftau = intarr(np, nl*nz)


; filenames
totnl = 0
for k = statinx, endinx do begin
  print, infile(k)
  read_modis04_aeropt, '', infile(k), Onetau, smfrac, $
                     tmplat, tmplon, np, nl

  print, 'nl = ', nl

  
; assign to total data
  flat(0:np-1, totnl : totnl +nl-1) = $
     tmplat(0:np-1, 0:nl-1)
     
  flon(0:np-1, totnl: totnl+nl-1)  = $
     tmplon(0:np-1, 0:nl-1)
 
  ftau(0:np-1, totnl: totnl+nl-1) = $
     Onetau(0:np-1, 0:nl-1)

; total lines
   totnl = totnl + nl

endfor

; starting plot.  


  ; adjust region limit
        tmptau = ftau
		
; scale the tau
  tmptau = tmptau/1000.


  ; find tau max, min	
	result = where (ftau lt 0  , count)
	if ( count gt 0 ) then tmptau(result) = 0.
        minvalue = 0.04
        minresult = where ( tmptau lt minvalue, mincount)
        maxvalue = 1
        maxresult = where ( tmptau ge maxvalue , maxcount)

  ; set up color levels
        N_levels = 46
        tmptau = 17 + (tmptau - minvalue)/(maxvalue - minvalue) * $
	             (N_levels-1)
         
       ; tau gt0 and lt 0.04
	if (mincount gt 0 ) then tmptau(minresult)=16

       ; tau gt 1.0 	 
	if (maxcount gt 0 ) then tmptau(maxresult) = 17+N_levels
	
       ; cloud or glint
         tmptau(result) = 8	
	
       barticks = minvalue + (findgen(N_levels+1))*(maxvalue-minvalue)/(n_levels)

	nx = 1L
	
    
    ; congrid
        mag = 6.
	print, nz, 'totnl = ', totnl/203
       tmptmptau = congrid(tmptau(0:np-1, 0:totnl-1),mag*np,mag*totnl)
       tmplat =  congrid(flat(0:np-1, 0:totnl-1), mag*np, mag*totnl, /interp )
       tmplon =  congrid(flon(0:np-1, 0:totnl-1), mag*np, mag*totnl, /interp)


      result = where ( abs(tmplat) gt 90, count)
      if ( count gt 0 ) then tmplat(result) = 0
      
      result = where( abs(tmplon) gt 180, count)
      if ( count gt 0 ) then tmplon(result) = 0
      
       color_imagemap,tmptmptau, tmplat, tmplon, /current, missing = 0
       	  


end

;
; procedure for eset legent
;

pro set_legent, colors

;set table legend
	 minvalue = 0.04
         maxvalue = 1
        N_levels = 46
 	
       barticks = minvalue + (findgen(N_levels+1))*(maxvalue-minvalue)/(n_levels)

      xa = 0.83
      dx = -0.01
      ya = 0.91
      dy = 0.025
       i = 0
         x = [xa, xa + dx, xa + dx]
         y = [ya+dy/2, ya, ya+dy]
         polyfill, y, x, color=colors(i), /normal

       for i = 1, n_levels do begin
         x = [xa+(i*dx), xa+i*dx+dx,xa+i*dx+dx,xa+(i*dx) ]
         y = [ya, ya, ya+dy, ya+dy]
         polyfill, y, x, color=colors(i), /normal
       endfor

        i = n_levels+1
        x = [xa+i*dx, xa+i*dx+dx,  xa+i*dx]
        y = [ya, ya+dy/2, ya+dy]
         polyfill, y, x, color=colors(i), /normal

       for i = 0, n_levels, 4 do begin
        xyouts,  ya+dy, xa+(i*dx)+dx*1.5,'!6'+string(barticks(i), format='(f6.2)'),$
           color=16,/normal, charsize=1.5, charthick=5
        xyouts, ya+dy,xa+(i*dx)+dx*1.5, '!6-', charsize=1, /normal, color=16, charthick=5
        endfor
		
end

; Main begins
set_plot,'ps'
   device,filename='MODIS04_2003_aqua.ps',/portrait,xsize=7.5, ysize=9,$
   xoffset=0.5,yoffset=1,/inches, /color, bits=8

	!p.font=0

 ;set color table
 
r=bytarr(64) & g = r & b =r
 r(0:63)=[255,238,221,204,187,170,153,136,119,102,85,68,51,34,17,0,0,0,0,$
           0,0,0,0,0,7,15,23,31,38,46,54,62,86,110,134,158,182,206,$
           230,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,$
       255,255,255,255,255,255,255,255,255,255]

      g(0:63)=[255,238,221,204,187,170,153,136,119,102,85,68,51,34,17,0,0,0,0,$
           0,0,0,0,0,28,56,84,112,140,168,196,224,227,231,235,239,243,247,$
           251,255,249,243,237,232,226,220,214,209,182,156,130,104,78,52,$
           26,0,0,0,0,0,0,0,0,0]

      b(0:63)=[255,238,221,204,187,170,153,136,119,102,85,68,51,34,17,0,0,36,$
           72,109,145,182,218,255,223,191,159,127,95,63,31,0,0,0,0,0,0,0,$
           0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,31,63,95,127,159,191,223,255]

;colors = [ 0, 25,   36,  50,  65,  85,  115,  135,  160, 173,  180, 195, 210, 225]/5+16
colors = indgen(48) +16
tvlct, r, g, b


; read AOT file
Infile = strarr(5000)
oneline = ' '
i = 0

filedir = ' '
filename = 'listoffilenames.txt '
process_day,  filedir+filename, Nday, AllFileName, StartInx, EndInx,$
DAYNAME, DAYNUM

; start to plot
	region_limit = [10, -110, 45, -65]
	startinx = 0                    ; starting file inx = 0
	 xcenter = -85


for i = 0, NDAY-1 do begin
		 
    ;  start mapping 	
	 map_set, 0, xcenter, latdel = 5, londel = 5,  /continent, $
        /grid, charsize=1, mlinethick = 4, color=16,con_color=16,$
        /mer, limit = region_limit,glinethick = 4,glinestyle=0,$
        /label, latlab = region_limit(1), lonlab = region_limit(0),$
	lonalign=0,latalign=1.5,xmargin=[1.5,0.5],ymargin=[0.5,1.5],$
	title= DayName + ' Julian Day:'+ $
		string(DayNum, format='(I3)'), $
	position=[0.05, 0.31, 0.85, 0.87], /usa
          
	   plot_modis,  colors, allfilename, startinx(i), endinx(i) 
   	   
   
   
	 map_set, 0, xcenter, latdel = 5, londel = 5,  /continent, $
        /grid, charsize=1, mlinethick = 4, color=16,con_color=16,$
        /mer, limit = region_limit,glinethick = 4,glinestyle=16,$
        /label, latlab = region_limit(1), lonlab = region_limit(0),$
	lonalign=0,latalign=1.5,xmargin=[1.5,0.5],ymargin=[0.5,1.5],$
	/noerase, position=[0.05, 0.31, 0.85, 0.87], $
	title= DayName + ' Julian Day:'+ $
		string(DayNum, format='(I3)'), $
        position=[0.05, 0.31, 0.85, 0.87], /usa

     	set_legent, colors
    
   endfor		
  device, /close	
end
