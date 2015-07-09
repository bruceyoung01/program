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
fsmall = intarr(np, nl*nz)

; filenames
totnl = 0
for k = statinx, endinx do begin
  print, infile(k)
;  Latfile = '../data/'+ Infile(k) + '.Latitude'
;  Lonfile = '../data/' + Infile(k) + '.Longitude'
;  Aotfile = '../data/' + Infile(k)+'.Optical_Depth_Land_And_Ocean' 
  Latfile = '../2003/'+ Infile(k) + '.Latitude'
  Lonfile = '../2003/' + Infile(k) + '.Longitude'
  Aotfile = '../2003/' + Infile(k)+'.Optical_Depth_Land_And_Ocean' 
  Smallfile = '../2003/'+ infile(k) + '.Optical_Depth_Ratio_Small_Land_And_Ocean' 
 
; get file size
  openr, 1, Aotfile
  FLength = fstat(1)
  nl = flength.size/np/2
  close,1

  print, 'nl = ', nl
  
; set tmp array
  tmplat = fltarr(np, nl)
  tmplon = fltarr(np, nl)
  Onetau = intarr(np, nl)
  OneSmall = intarr(np,nl)
  

; read lat lon tau
  fread, Aotfile, Onetau
  fread, Latfile, tmplat
  fread, Lonfile, tmplon
  fread, smallfile, onesmall
 
  
; assign to total data
  flat(0:np-1, totnl: totnl+ nl-1 ) = $
     tmplat(0:np-1, 0:nl-1)
     
  flon(0:np-1, totnl: totnl+ nl-1 ) = $
     tmplon(0:np-1, 0:nl-1)
 
  ftau(0:np-1, totnl: totnl+ nl-1 ) = $
     Onetau(0:np-1, 0:nl-1)
  
  fsmall(0:np-1, totnl: totnl+ nl-1 ) = $
     Onesmall(0:np-1, 0:nl-1)

  totnl = totnl+nl

endfor

; starting plot.  


  ; adjust region limit
        tmptau = ftau/1000.*fsmall/1000.
		

  ; find tau max, min	
	result = where (ftau lt 0  , count)
	if ( count gt 0 ) then tmptau(result) = 0.
        minvalue = 0.05
        minresult = where ( tmptau lt minvalue, mincount)
        maxvalue = 0.95
        maxresult = where ( tmptau ge maxvalue , maxcount)

  ; set up color levels
        N_levels = 45
        tmptau = 17 + (tmptau - minvalue)/(maxvalue - minvalue) * $
	             N_levels
         
       ; tau gt0 and lt 0.05
	if (mincount gt 0 ) then tmptau(minresult)=16

       ; tau gt 0.95 	 
	if (maxcount gt 0 ) then tmptau(maxresult) = 17+N_levels+1
	
       ; cloud or glint
         tmptau(result) = 8	
	
       barticks = minvalue + (findgen(N_levels+1))*(maxvalue-minvalue)/(n_levels)

	nx = 1L
	
    ; adjust lat and lon
       result = where(tmplat ge 80 or tmplat lt -80, count)
       if count gt 0 then tmplat(result) = 0
       
       result = where(tmplon gt 170 or tmplat lt -170, count)	
       if count gt 0 then tmplon(result) = 0
    
    ; congrid
        mag = 6.
	
	
	
       tmptmptau = congrid(tmptau,mag*np,mag*totnl)
       tmplat =  congrid(flat, mag*np, mag*totnl, /interp )
       tmplon =  congrid(flon, mag*np, mag*totnl, /interp)

       color_imagemap,tmptmptau, tmplat, tmplon, /current, missing = 0
       	  

end

;
; procedure for eset legent
;

pro set_legent, colors

;set table legend
	 minvalue = 0.05
         maxvalue = 0.95
         N_levels = 45
 	
       barticks = minvalue + (findgen(N_levels+1))*(maxvalue-minvalue)/(n_levels)
 ;set table legend
      xa = 0.83
      dx = -0.01
      ya = 0.91
      dy = 0.025
       i = 0
         x = [xa-dx, xa + dx, xa + dx]
         y = [ya+dy/2, ya, ya+dy]
         polyfill, y, x, color=colors(n_levels-i), /normal

       for i = 1, n_levels do begin
         j= n_levels-i
         x = [xa+(i*dx), xa+i*dx+dx,xa+i*dx+dx,xa+(i*dx) ]
         y = [ya, ya, ya+dy, ya+dy]
         polyfill, y, x, color=colors(n_levels-i+1), /normal
       endfor

        i = n_levels+1
        x = [xa+i*dx, xa+i*dx+2*dx,  xa+i*dx]
        y = [ya, ya+dy/2, ya+dy]
         polyfill, y, x, color=colors(n_levels-i+1), /normal

       for i = 0, n_levels, 5 do begin
        xyouts,  ya+dy, xa+(i*dx)+dx*1.5,'!6'+string(barticks(n_levels-i), format='(f6.2)'),$
           color=16,/normal, charsize=1.5, charthick=5
        xyouts, ya+dy,xa+(i*dx)+dx*1.5, '!6-', charsize=1, /normal, color=16, charthick=5
        endfor

end

; Main begins
set_plot,'ps'
   device,filename='Qiwen.ps',/portrait,xsize=7.5, ysize=9,$
   xoffset=0.5,yoffset=1,/inches, /color, bits=8

;	!p.font=0

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

;openr, 1, '../data/terra_file_statis.txt'
openr, 1, '../MODIS_QiWen/terra_file_statis.txt'
;openr, 1, '../2003/aqua_file_statis.txt'


while ( not eof(1) ) do begin
readf, 1, oneline
infile(i) = oneline
i = i +1
endwhile
close,1
;stop
Nfile = i  

;Days = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
Days= [0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334, 365]
NM = 12    ; total 12 months per year

; start to plot
;	region_limit = [20, -95, 40, -65]
	 region_limit = [10,  80, 45, -125]
;region_limit = [28, -95, 38, -80]
	
startinx = 0	
for i = 0, Nfile-2 do begin

;startf =721 
;startinx = startf
;endf =728 

;startf = 943
;startinx = startf
;endf = 943


;for i = startf, endf do begin
	
    ; from file name to julian day
	OneF = InFile(i)                        ; current day
	JulianD = fix (strmid (OneF, 14, 3))
	
	NxF = InFile(i+1)                       ; next day
	NxJD = fix ( strmid ( NxF, 14, 3))
	
    ; get the month correct
	for k = 0, NM-1 do begin
	if ( JulianD ge Days(k)+1 and JulianD lt Days(k+1)+1 ) then begin
		Month = string ( k+1, format = '(I2)')
		Day = string (JulianD - Days(k), format = '(I2)')  
	endif
	endfor
	
    ; judget if on the same day
       if ( JulianD ne NxJD  ) then begin
	; if ( JulianD gt 0  ) then begin		
		 
    ;  start mapping
        xl = region_limit(1)
	xr = region_limit(3)
	yb = region_limit(0)
	yt = region_limit(2)
	 xcenter = 0
	!p.multi=[0, 1, 2]
	 	
	plot, [xl, xr], [yb, yt], /nodata, xrange=[xl, xr], $
             yrange=[yb, yt], xtitle = '!6Longitude (deg) ', $
             ytitle='Latitude (deg) ', $
             position= [0.0475, 0.3075, 0.8535, 0.8725], color=15, xthick=3,$
             ythick=3, charsize=1.2, charthick=3, xstyle=1, ystyle=1,$
	     xticks=5, xminor=5

	;map_set, 0, xcenter, latdel = 5, londel = 10,  /continent, $
        ;/grid, charsize=1, mlinethick = 4, color=16,con_color=16,$
        ;/mer, limit = region_limit,glinethick = 4,glinestyle=0,$
        ;/noborder, /CYLINDRICAL,  position=[0.05, 0.31, 0.85, 0.87],$
	;/noerase, /usa, $
	
	
		
	xyouts, 0.13, 0.92, '      MODIS/TERRA AOT!C' + $
	      Month + ' ' + Day+ ' 2003,' + '  Julian Day:'+ $
	      string(JulianD, format='(I3)') , charsize=2.0,$
	      charthick=5, /normal, color=16
	

	; no grid 
	map_set, 0, xcenter,  /continent, $
        /grid, charsize=1, mlinethick = 4, color=16,con_color=16,$
        /mer, limit = region_limit,$
        /noborder, /CYLINDRICAL,  position=[0.05, 0.31, 0.85, 0.87],$
	/noerase, /usa
	
	
	   plot_modis,   colors, Infile, StartInx, i
   	   
	
	map_set, 0, xcenter,  /continent, $
        /grid, charsize=1, mlinethick = 4, color=16,con_color=16,$
        /mer, limit = region_limit,$
        /noborder, /CYLINDRICAL,  position=[0.05, 0.31, 0.85, 0.87],$
	/noerase, /usa
	      
	oplot, [xl, xr], [yb, yb], thick=5, color=15
        oplot, [xl, xr], [yt, yt], thick=5, color=15
        oplot, [xl, xl], [yt, yt], thick=5, color=15
        oplot, [xr, xr], [yb, yb], thick=5, color=15

     	set_legent, colors
    
     ; set start inx as the next file
        print, startinx, i
	startinx = i+1;	
       endif 
   endfor		
  device, /close	
end
