; read state boundary
pro plot_us, colorinx = colorinx, fillinx = fillinx, $
             range = range

if not keyword_set(range) then range = [-90, -180, 90, 180]
         
 nl = 18067
 np = 2
nstate = 0
openr, 1, './US/allstates.ovl'
 while  not eof(1)  do begin
 bnd = fltarr(np, nl)
 readf, 1, lon, lat
 i = 0
 if ( lon ne 999.9 ) then begin
 WHILE lon NE 909.9 DO BEGIN
    bnd[0,i] = lon
    bnd[1,i] = lat
    ReadF, 1, lon, lat
    i = i + 1
  ENDWHILE
numpts = i
bnd = reform(bnd(0:np-1, 0:numpts-1))

if keyword_set(range) then begin ; for range option
   tmplat = reform(bnd(1, *))
   tmplon = reform(bnd(0, *))
   result = where(tmplat ge range(0) and $
                  tmplat le range(2) and $
                  tmplon ge range(1) and $
                  tmplon le range(3), count)
   if count gt 0 then begin
     bnd =reform(bnd(*, result)) 
     if ( fillinx eq 1 ) then begin
       PolyFill, bnd[0,*], bnd[1,*], Color = colorinx
     endif else begin
       plots, bnd[0,*], bnd[1,0:*], Color = colorinx
      endelse
   endif
endif else begin  ; for no range option
if ( fillinx eq 1 ) then begin
 PolyFill, bnd[0,*], bnd[1,*], Color = colorinx
endif else begin
 plots, bnd[0,*], bnd[1,0:*], Color = colorinx
endelse
endelse

endif
endwhile
close,1
end

