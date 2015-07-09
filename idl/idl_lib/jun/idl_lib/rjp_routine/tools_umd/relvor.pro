function relvor, u, v, lat=lat, lon=lon, uy=uy, vx=vx, f=f	$
		,absolute=absolute ,bad=bad

;+
;NAME:
;	RELVOR
;PURPOSE:
;	Calculates relative vorticity from a lat/lon grid.
;CATEGORY:
;	geophysics.
;CALLING SEQUENCE:
;	X = NMC_RELVOR(U,V ,lat=lat,lon=lon,uy=uy,vx=vx,absolute=absolute)
;
;INPUTS:
;	U		= (3-d array) Zonal 
;	V		= (3-d array) Meridional wind.
;KEYWORD INPUTS:
;	lat	 = latitude vector  - default = -90,90 by N (where
;			N is the second dimension of u
;	lon      = longitude vector - defualt = 0,355 by M (where
;			M is the first dimension of u
;	absolute = returns absolute vorticity instead of relative vorticity
;	bad	 = bad data value
;OUTPUTS:
;	RVOR		= (2-d array) Relative vorticity from U and V.
;KEYWORD OUTPUTS:
;	UY	= (3-d array) Array of u derivarive in 'y' direction
;	VX	= (3-d array) Array of v derivarive in 'x' direction
;	f	= (3-d array) Array of planetary vorticity
;SIDE EFFECTS:
;	None.
;RESTRICTIONS:
;	Data must be on a regular lat/lon grid, cyclic lons (otherwis
;		lon-endpoints will be wrong
;PROCEDURE:
;	Straightforward.  
;REQUIRED ROUTINES:
;	difkind, deriv_array
;REVISION HISTORY:
;	Written, PAN 10/15/92 
;-

if n_elements(bad) eq 0 then bad = -99999.

;** figure the size
  ss=size(u)
  if ss(0) ne 3 then begin
     print,' zonal wind array is dimensioned wrong'
     return,bad
  endif
  tt=size(v)
  if tt(0) ne 3 then begin
     print,' meridional wind array is dimensioned wrong'
     return,bad
  endif
  tt = ss - tt
  oo = where(tt ne 0)
  if oo(0) ne -1 then begin
     print,' meridional and zonal arrays are dimensioned differently'
     return,bad
  endif

  if n_elements(lat) eq 0 then lat = -90. + findgen(ss(2)) * 180. / (ss(2)-1.)
  if n_elements(lon) eq 0 then lon = findgen(ss(1)) * 360. / ss(1)

;** calculate the longitude delta
  ll = lon - shift(lon,1)
  ll = ll(1:n_elements(ll)-1)
  dl = difkind(ll)
  if n_elements(dl) ne 1 then begin
    print,'  lons may be irregular'
    return,bad
  endif
  dlamba = dl(0)

;** calculate the latitude delta
  ll = lat - shift(lat,1)
  ll = ll(1:n_elements(ll)-1)
  dl = difkind(ll)
  if n_elements(dl) ne 1 then begin
    print,'  lats may be irregular'
    return,bad
  endif
  dphi = dl(0)

;** set a few params
  a0 = 40000e3/2./!pi
  dx = dlamba/!radeg*a0
  dy = dphi  /!radeg*a0
  f0 = 4. * !pi / 86400.

;** set up trig functions with same dims as u and v
  cs = cos(lat/!radeg)
  cs = rebin(transpose(rebin(cs,ss(2),ss(1))),ss(1),ss(2),ss(3))
  sn = sin(lat/!radeg)
  sn = rebin(transpose(rebin(sn,ss(2),ss(1))),ss(1),ss(2),ss(3))
  tn = tan(lat/!radeg)
  tn = rebin(transpose(rebin(tn,ss(2),ss(1))),ss(1),ss(2),ss(3))
  llat = rebin(transpose(rebin(lat,ss(2),ss(1))),ss(1),ss(2),ss(3))

;** planetary vorticity
  f  = f0 * sn

;** calculate uy
  uy = deriv_array( u, 1, bad=bad )
  oo = where(uy ne bad)
  if oo(0) ne -1 then uy(oo)=uy(oo)/dy

;** calculate vx
  vx=v
  vb = shift(v,1,0,0)
  vf = shift(v,-1,0,0)
  ;** good forward and good backward
  oo = where( (vf ne bad) and (vb ne bad) )
  if oo(0) ne -1 then vx(oo) = (vf(oo) - vb(oo)) /2.
  ;** good forward and bad backward
  oo = where( (vf ne bad) and (v ne bad) and (vb eq bad) )
  if oo(0) ne -1 then vx(oo) = vf(oo) - v(oo)
  ;** good backward and bad forward
  oo = where( (vf eq bad) and (v ne bad) and (vb ne bad) )
  if oo(0) ne -1 then vx(oo) = v(oo) - vb(oo)
  oo = where (v eq bad)
  if oo(0) ne -1 then vx(oo) = bad
  oo = where (vx ne bad)
  if oo(0) ne -1 then vx(oo) = vx(oo)/dx/cs(oo)

;** calculate vorticity
  x = vx - uy + u * tn /a0
  oo = where( (vx eq bad) or (uy eq bad) or (u eq bad) )
  if oo(0) ne -1 then x(oo) = bad

;** polar point correction, determined from the average of the
;**	vorticity over the polar cap. See Pedlosky P.23
  ;** zonal wind average (dimensioned the same as U)
  ua =rebin(reform(avg(u,0),1,ss(2),ss(3)),ss(1),ss(2),ss(3))
  ;** zonal winds greater than 400 m/s are garbage
  oo = where(abs(ua) gt 400)
  if oo(0) ne -1 then ua(oo) = bad
  nlat = (!pi/2. - dy /a0) ;** latitude of point next to pole
  factor = cos(nlat)/(1.0-sin(nlat))/a0 ;** ratio circum/area
  oo = where( abs(ua) ge 400. )
  x0 = sgn(llat) * ua * factor
  if oo(0) ne -1 then x0(oo) = bad
  x0np = shift(x0,0,1,0)
  x0sp = shift(x0,0,-1,0)
  oo = where(llat eq -90.)
  if oo(0) ne -1 then x(oo) = x0sp(oo)
  oo = where(llat eq 90.)
  if oo(0) ne -1 then x(oo) = x0np(oo)

  absv = x + f
  oo = where(x eq bad)
  if oo(0) ne -1 then absv(oo) = bad

  if n_elements(absolute) ne 0 then x = absv

return,x
end
