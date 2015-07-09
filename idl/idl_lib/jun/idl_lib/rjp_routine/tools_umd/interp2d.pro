function interp2d,datain,xout,yout,xin,yin,badval=badval $
	,xwrap=xwrap,ywrap=ywrap,not_grid=not_grid
;+
; NAME:
;	interp2d
; PURPOSE:
;	Interpolate to given ordinates and absissa using input
;	two-dimensional data and ordinates and absissa
; CATEGORY:
;	General Utility
; CALLING SEQUENCE:
;	dataout = interp2d(datain,xout,yout,xin,yin,badval=badval
;		,xwrap=xwrap,ywrap=ywrap)
; INPUT PARAMETERS:
;	datain	= input data to be used for interpolation (1-D or 2-D)
;	xout	= output data ordinates to interpolate to
;	yout	= output data absissa to interpolate to
; OPTIONAL INPUT PARAMETERS:
;	xin	= input data ordinates to be used for interpolation
;		  should be single valued - does NOT have to be ordered
;	yin	= input data absissa to be used for interpolation
;		  should be single valued - does NOT have to be ordered
; KEYWORD PARAMETERS:
;	badval	= bad data point value, no interpolation done if points
;		  with this value are to be used in interpolation
;		  also if xout points are outside of range of xin,
;		  output array points set to this value
;	xwrap	= data is wrapped in the x direction
;	ywrap	= data is wrapped in the y direction
;	not_grid= output data is NOT to be a grid
; OUTPUT PARAMETERS:
;	dataout	= array of interpolated output value
; OPTIONAL OUTPUT PARAMETERS:
; COMMON BLOCKS:
;	None
; SIDE EFFECTS:
;	None known.
; RESTRICTIONS:
;	input indices must be monotonic
; PROCEDURE:
;	bilinear interpolation/extrapolation
; REQUIRED ROUTINES:
;	None
; MODIFICATION HISTORY:
;	Stephen D. Steenrod - December 1993 - written
;-

sz = size(datain)
if(n_elements(xin) eq 0) then xin = findgen(sz(1))
if(n_elements(yin) eq 0) then yin = findgen(sz(2))
if(n_elements(xwrap) eq 0) then xwrap = 0
if(n_elements(ywrap) eq 0) then ywrap = 0
if(n_elements(not_grid) eq 0) then not_grid = 0
szo = [0,n_elements(xout),n_elements(yout)]

if(xwrap) then begin
      datat = fltarr(sz(1)+2,sz(2))
   for n=0,sz(2)-1 do datat(*,n) = [datain(sz(1)-1,n),datain(*,n),datain(0,n)]
   xt = [xin(0)-(xin(1)-xin(0)),xin(*),xin(sz(1)-1)+(xin(sz(1)-1)-xin(sz(1)-2))]
   yt = yin
   sz(1) = sz(1)+2
   end $
 else begin
   datat = datain
   xt = xin
   yt = yin
  end

if(ywrap) then begin
  sz = size(datat)
  datayt = fltarr(sz(1),sz(2)+2)
  for n=0,sz(1)-1 do datayt(n,*) = [datat(n,sz(2)-1),reform(datat(n,*)),datat(n,0)]
  yt = [yin(0)-(yin(1)-yin(0)),yin(*),yin(sz(2)-1)+(yin(sz(2)-1)-yin(sz(2)-2))]
  datat = datayt
  sz(2) = sz(2)+2
 end

;... set up default xin and yin
sz = size(datat)

;... set up indices for x interpolation
x1 = intarr(szo(1))
for n=0,szo(1)-1 do begin
 
  aaa = where( (xout(n) le xt(1:*) and xout(n) gt xt(0:sz(1)-2)) or $
	(xout(n) ge xt(1:*) and xout(n) lt xt(0:sz(1)-2)) )
  x1(n) = aaa	
  if(x1(n) eq -1) then if(xout(n) ge max(xt)) then $
	x1(n) = where(max(xt) eq xt) else x1(n) = where(min(xt) eq xt)
 end
;... find if at end of array
ind = where(x1 ge sz(1)-1,cnt)
if(cnt gt 0) then x1(ind) = sz(1)-2
x2 = x1+1
xs = xout-xt(x1)
dx = xt(x2)-xt(x1)

;... set up indices for y interpolation
y1 = intarr(szo(2))
for n=0,szo(2)-1 do begin
  y1(n) = where( (yout(n) le yt(1:*) and yout(n) gt yt(0:sz(2)-2)) or $
	(yout(n) ge yt(1:*) and yout(n) lt yt(0:sz(2)-2)) )
	
  if(y1(n) eq -1) then if(yout(n) ge max(yt)) then $
	y1(n) = where(max(yt) eq yt) else y1(n) = where(min(yt) eq yt)
 end
;... find if at end of array
ind = where(y1 ge sz(2)-1,cnt)
if(cnt gt 0) then y1(ind) = sz(2)-2
y2 = y1+1
ys = yout-yt(y1)
dy = yt(y2)-yt(y1)

;.... set up indice arrays
if(not_grid) then begin
  ind11 = x1+(y1*sz(1))
  ind12 = x1+(y2*sz(1))
  ind21 = x2+(y1*sz(1))
  ind22 = x2+(y2*sz(1))
  dx2d = dx
  xs2d = xs
  dy2d = dy
  ys2d = ys
  end $
 else begin
   one = fltarr(max([szo(1),szo(2)]))+1
   ind11 = x1#one(0:szo(2)-1)+one(0:szo(1)-1)#(y1*sz(1))
   ind12 = x1#one(0:szo(2)-1)+one(0:szo(1)-1)#(y2*sz(1))
   ind21 = x2#one(0:szo(2)-1)+one(0:szo(1)-1)#(y1*sz(1))
   ind22 = x2#one(0:szo(2)-1)+one(0:szo(1)-1)#(y2*sz(1))

   ind11 = reform(ind11,szo(1)*szo(2))
   ind12 = reform(ind12,szo(1)*szo(2))
   ind21 = reform(ind21,szo(1)*szo(2))
   ind22 = reform(ind22,szo(1)*szo(2))

   dx2d = dx#one(0:szo(2)-1)
   dx2d = reform(dx2d,szo(1)*szo(2))
   xs2d = xs#one(0:szo(2)-1)
   xs2d = reform(xs2d,szo(1)*szo(2))
   dy2d = one(0:szo(1)-1)#dy
   dy2d = reform(dy2d,szo(1)*szo(2))
   ys2d = one(0:szo(1)-1)#ys
   ys2d = reform(ys2d,szo(1)*szo(2))
 end

a = datat(ind11)*(dx2d*dy2d-dy2d*xs2d-dx2d*ys2d+xs2d*ys2d) $
  +datat(ind21)*(dy2d*xs2d-ys2d*xs2d) $
  +datat(ind12)*(dx2d*ys2d-ys2d*xs2d) $
  +datat(ind22)*ys2d*xs2d

a = a/(dx2d*dy2d)

;... check for badvals
if(n_elements(badval) ne 0) then begin
  ind = where(datat(ind11) eq badval or datat(ind21) eq badval or $
     datat(ind12) eq badval or datat(ind22) eq badval,cnt)
  if(cnt gt 0) then a(ind) = badval
 end
if(not_grid) then return,a $
 else return,reform(a,szo(1),szo(2))
end
