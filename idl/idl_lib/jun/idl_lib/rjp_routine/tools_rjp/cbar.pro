pro cbar, pos=pos,Clevel=level,VERTICAL=vertical,RIGHT=right,format=format

 if n_elements(level) eq 0 then return
 if n_elements(format) eq 0 then format = 1
 if n_elements(charsize) eq 0 then charsize=1.4

 ncolors = n_elements(level)
 ctable = indgen(ncolors)
 cnot = strtrim(string(level),1)

 ic = strpos(cnot,'.')+format
 for i = 0, ncolors-1 do cnot(i) = strmid(cnot(i),0,ic(i))
 

IF KEYWORD_SET(vertical) THEN BEGIN

 if n_elements(pos) eq 0 then begin
   pos = !p.position 
   pos = [pos(2)+0.01,pos(1),pos(2)+0.04,pos(3)]
 end
   dx = (pos(2)-pos(0))
   dy = (pos(3)-pos(1))/ncolors
   yinc = findgen(ncolors)
   xinc = fltarr(ncolors)

ENDIF ELSE BEGIN

 IF N_ELEMENTS(pos) EQ 0 THEN begin
   pos = !p.position
   pos = [pos(0),pos(1)-0.04,pos(2),pos(1)-0.01]
 endif

   dx = (pos(2)-pos(0))/ncolors
   dy = (pos(3)-pos(1))
   yinc = fltarr(ncolors)
   xinc = findgen(ncolors)

 ENDELSE

 for i = 0, ncolors-1 do begin
   x0 = pos(0)+dx*xinc(i)
   x1 = pos(0)+dx*xinc(i)
   x2 = pos(0)+dx*(xinc(i)+1)
   x3 = pos(0)+dx*(xinc(i)+1)

   y0 = pos(1)+dy*yinc(i)
   y1 = pos(1)+dy*(yinc(i)+1)
   y2 = pos(1)+dy*(yinc(i)+1)
   y3 = pos(1)+dy*yinc(i)

   xcoord = [x0,x1,x2,x3,x0]
   ycoord = [y0,y1,y2,y3,y0]

   polyfill, xcoord, ycoord, color=ctable(i),/normal
   plots, xcoord, ycoord,/normal, color=!p.color

   if KEYWORD_SET(vertical) THEN begin
      xyouts,x0+0.04,y0,cnot(i),/normal, color=!p.color
   endif else begin
      xyouts,x0,y0-0.03,cnot(i),/normal,alignment=0.5,color=!p.color
   endelse
 end

end
