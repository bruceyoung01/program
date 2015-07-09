;
; read ihop soil data
;

;read text file procedure
pro read_text, inf, nouseLN, totdata
    nouse = ' '
    openr, 1, inf
    for i = 0, nouseLN-1 do begin
       readf, 1, nouse
    endfor
       readf, 1, totdata
    close,1
  end


;
; Main begins
;

; read ihop soild data
  inf = 'IHOPSP10S1H.txt'
  nouseL = 4
  snp = 28
  snl = 2200
  snz = 6
  totdata = fltarr(snp, snl)
  read_text, inf, nouseL, totdata
  
; convert to variaibles, i represetns ihop
  smm = totdata(6, 0:snl-1)
  sdd = totdata(7, 0:snl-1)
  shh = fix(totdata(8, 0:snl-1)/10000.) + $
        (totdata(8, 0:snl-1)- $
	fix(totdata(8, 0:snl-1)/10000.) $
	*10000.)/100./60.
  soilV = totdata(10:15, 0:snl-1)
  soilT = totdata(16:21, 0:snl-1)
  SoilW = totdata(22:27, 0:snl-1)
  depth = [7.5, 15, 22.5, 37.5, 60,90] 
  

; plot figure 
  set_plot, 'ps'
  device, filename = 'soil.ps', xoffset = 0.5,$
    yoffset=10.5, xsize = 10, ysize = 7.5, /color, bits = 8, $
    /inches, /landscape

;set color table

   r=bytarr(64) & g=r & b=r

   r(0:63)=[0,238,221,204,187,170,153,136,119,102,85,68,51,34,17,0,0,0,0,$
           0,0,0,0,0,7,15,23,31,38,46,54,62,86,110,134,158,182,206,$
           230,255,255,255,255,255,255,255,255,255,255,255,255,255,255,255,$
           255,255,255,255,255,255,255,255,255,255]

   g(0:63)=[0,238,221,204,187,170,153,136,119,102,85,68,51,34,17,0,0,0,0,$
           0,0,0,0,0,28,56,84,112,140,168,196,224,227,231,235,239,243,247,$
           251,255,249,243,237,232,226,220,214,209,182,156,130,104,78,52,$
           26,0,0,0,0,0,0,0,0,0]

   b(0:63)=[0,238,221,204,187,170,153,136,119,102,85,68,51,34,17,0,0,36,$
           72,109,145,182,218,255,223,191,159,127,95,63,31,0,0,0,0,0,0,0,$
           0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,31,63,95,127,159,191,223,255]

   tvlct,r,g,b
   p1 = [0.1, 0.2, 0.88,  0.8] 
   p2 = [0.9, 0.2, 0.93, 0.8] 

; plot soil moisture of volume fraction, temperature, and water
      
  date = findgen(10) + 16
  month = fltarr(10) + 6
  nday =10 
  nvar = 2  ;3 variables to be plotted: volume, temperature, water
  varmin = [12,   18,    0 ]
  varmax = [60,  32,  500 ]
  levels = [24,  28,  20] 
  Vname = ['!6Soil Moisture Volume Fraction (%)', 'Soil Temperature (!uo!nC)', $
           'Soil Water Potential']
  xname = ['06/16', '06/18', '06/20', '06/22', '06/24']  	   
  
  for i = 0, nvar -1 do begin
    
    ; passing the right array
    if i eq 0 then tmpzz = soilV
    if i eq 1 then tmpzz = soilT
    if i eq 2 then tmpzz = soilW
    zz = fltarr(snl, snz)
    obst = fltarr(snl)
   
   ; set right coordinate
    ymin = varmin(i)  & ymax = varmax(i)
    
    kk = 0   ; index of how many datapoints 
             ; are collected during the time period
	     

    ; find the right data in the right time period
    for k = 0, snl - 1 do begin
      if ( smm(k) eq month(0) and sdd(k) ge date(0) and $
          sdd(k) le  date(nday-1) ) then begin
	  
	  ; using only valid profiles
	  ValidN = 0
	  for kkk = 0, snz-1 do begin
	    if ( soilV(kkk, k ) ge 0 and soilT(kkk,k) ge 0 $
	          and soilW(kkk,k) ge 0 ) then validN = VAlidN+1
	  endfor

	  if ( ValidN eq snz ) then  begin 
             zz(kk, 0:snz-1 ) = tmpzz( 0:snz-1, k)
	     obst(kk) = smm(k)*100 + sdd(k) + shh(k)/24.
	     kk = kk + 1
	  endif   
	 print, 'find one'
      endif  
    endfor
    
    
    ; plot contour
    nlevel = levels(i)
    i_colors=16+(findgen(nlevel)+1)*1.5
    i_labels=1+(-1)^(findgen(nlevel))/2.
    i_levels=ymin+findgen(nlevel+1)*(ymax - ymin)/nlevel
    bar_labels = string(i_levels, format="(f4.1)")
    
    contour, zz(0:kk-1, 0:snz-1), obst(0:kk-1)+0.06, depth(0:snz-1),$
    	/fill, c_colors = i_colors, xstyle=1, ystyle=1, $
	color=16, xrange = [616, 624], yrange = [100,0],$
	min_value = 0, max_value= ymax, $
	levels = i_levels, xticks = 4, xminor=2, $
	xthick=3, ythick=3, xtitle = 'UTC Time, 2002', $
	ytitle = vname(i), charthick=3, charsize = 1.2,$
	xtickname = xname, position = p1, $
	C_CHARSIZE=1.2,	c_charthick=3
	
    contour, zz(0:kk-1, 0:snz-1), obst(0:kk-1)+0.06, depth(0:snz-1), $
    	xstyle=1, ystyle=1, $
	color=16, xrange = [616, 624], yrange = [100, 0],$
	/overplot, c_labels = i_labels, min_value = 0, $
	levels = i_levels, xticks = 2, xminor=2,$
	xthick=3, ythick=3, xtitle = 'UTC Time, 2002', $
	ytitle = vname(i), charthick=3, charsize = 1.2,$
	xtickname = xname, position = p1,$
	C_CHARSIZE=1.2,c_charthick=3, max_value= ymax


    ; plot color bars
    for jj = 0, nlevel-1 do begin
     xa = p2(0)
     xb = p2(2)
     ya = p2(1)
     yb = p2(3)
     dy = (yb-ya)/(nlevel)
     print, dy, nlevel, ya+jj*dy
     xxx = [xa, xb, xb, xa, xa]
     yyy= [ya+jj*dy, ya+jj*dy, ya+jj*dy+dy, ya+jj*dy+dy, ya+jj*dy]
    polyfill, xxx, yyy, $
            color = 16+(jj+1)*1.5, /normal
    print, xxx, yyy 
     
     if ( jj/2*2 eq jj ) then begin
       plots, [xb, xb+0.01], [ya+jj*dy, ya+jj*dy], color=16, /normal 
       xyouts, xb+0.02, ya+jj*dy-0.01,  + bar_labels(jj), charthick=3,$
       CHARSIZE=1.2, /normal
     endif
   endfor

     ;plot last mark
      plots, [xb, xb+0.01], [ya+jj*dy, ya+jj*dy], color=16, /normal 
      xyouts, xb+0.02, ya+jj*dy,  + bar_labels(jj), charthick=3,$
      CHARSIZE=1.2, /normal


	


  endfor
  
  device, /close
  end
 		  
    
    
  

  	
   




