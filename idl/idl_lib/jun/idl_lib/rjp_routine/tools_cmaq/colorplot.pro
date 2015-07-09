pro colorplot,fd,xf,yf,Level=level,Pos=pos,Vertical=vertical,Noerase=noerase,Title=title,$
    twait=twait


if n_elements(POS) eq 0 then pos = [0.15,0.2,0.85,0.85]
if n_elements(title) eq 0 then title=''
 dim = size(fd)

if n_elements(xf) eq 0 then xf = findgen(dim(1))
if n_elements(yf) eq 0 then yf = findgen(dim(2))
if n_elements(twait) eq 0 then twait = 0.

if n_elements(level) eq 0 then begin
 inc = (max(fd)-min(fd))/10.
 level = fltarr(11)
 for i = 0, 10 do begin
  level[i] = min(fd)+float(i)*inc
 end
 nl = n_elements(level)
endif else begin
 nl = n_elements(level)
end

loadct, 0
loadct, 4, ncolors=nl+1, bottom=0
loadct_rjp, ncolors=nl+1
device, decomposed=0
ctable = indgen(nl)+1

!p.position = pos

contour,fd,xf,yf,/cell_fill,c_colors=ctable,levels=level, $
xstyle=1,ystyle=1,/normal;,background=!p.color,color=!p.background

if KEYWORD_SET(vertical) then begin
 cbar, clevel=level,/vertical
endif else begin
 cbar, clevel=level
endelse

wait, twait

end
