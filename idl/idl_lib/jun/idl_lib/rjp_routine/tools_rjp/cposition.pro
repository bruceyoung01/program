function cposition, nxfig, nyfig, xoffset=xoffset, yoffset=yoffset, $
         xgap=xgap, ygap=ygap, order=order

; Calculate the position of multiple plots, for example post stamp plots...
; Xoffset[0] = left & Xoffset[1] = right
; Yoffset[0] = top & Yoffset[1] = bottom
; order = 0 , row major, order = 1, column major

 if (n_elements(nxfig) eq 0 ) then nxfig = 1
 if (n_elements(nyfig) eq 0 ) then nyfig = 1
 if (n_elements(nfig)  eq 0 ) then nfig = 1
 if (n_elements(xoffset) eq 0 ) then xoffset = [0.1,0.1]
 if (n_elements(yoffset) eq 0 ) then yoffset = [0.1,0.1]
 if (n_elements(xgap) eq 0 ) then xgap = 0.
 if (n_elements(ygap) eq 0 ) then ygap = 0.
 if (n_elements(order) eq 0 ) then order = 0


; width of each figures
 xwid = (1.0-(xoffset[0]+xoffset[1])-(nxfig-1)*xgap)/float(nxfig)
 ywid = (1.0-(yoffset[0]+yoffset[1])-(nyfig-1)*ygap)/float(nyfig)

 xp = fltarr(nxfig) & yp = fltarr(nyfig)
 xp(0) = xoffset[0] & yp(0) = 1.0-yoffset[0]
 for i = 1, nxfig-1 do xp(i) = xp(i-1)+xwid+xgap
 for i = 1, nyfig-1 do yp(i) = yp(i-1)-ywid-ygap
 fac = 1.0
 
  Cpos = fltarr(4)

 for nf = 0, (nxfig*nyfig)-1 do begin

  if order eq 0 then begin
     nx = nf mod nxfig
     ny = nf / nxfig
  end else begin
     nx = nf / nyfig
     ny = nf mod nyfig
  end

  Cpos = [[Cpos],[xp(nx),yp(ny)-fac*ywid,xp(nx)+fac*xwid,yp(ny)]]

 endfor

  Cpos = reform(Cpos[*,1:*])

return, Cpos

end
