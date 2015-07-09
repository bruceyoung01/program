;
;purpose: plot ncep reanlysis data
;


; read data
pro read_ncar, rinf, rngeo, rlat, rlon, np, nl, ng, nv   
; starting is from (lat: 90,lon: 0)
;inpf = 'ncar060218.dat'

rngeo = fltarr(nv, ng*np, ng*nl)
tmp = fltarr(np,nl) 

openr, 1, rinf 
for k = 0, nv-1 do begin
for i = 0, nl-1 do begin
  for j = 0, np-1 do begin
    readf, 1, a
    tmp(j,i) = a/10.
    rlat(j,i) = 90-i*2.5
    rlon(j,i) = j*2.5
     if (rlon(j,i) gt 180 ) then rlon(j,i) = rlon(j,i)-360. 
  endfor
 endfor
 ;rngeo(k, 0:np*ng-1, 0:nl*ng-1) = $
 ;      smooth(  congrid(tmp, np*ng, nl*ng,  /interp), 1)
rngeo(k, 0:np*ng-1, 0:nl*ng-1) = $
         congrid(tmp, np*ng, nl*ng,  /interp)

endfor
close,1

rlat = congrid(rlat, np*ng, nl*ng, /interp)
rlon= congrid(rlon, np*ng, nl*ng, /interp)


end

; read dump data from revu in

pro read_revu ,geo, infile, U, V, lat, lon,np, nl, nv
  nouse = ' '

  tmpgeo = fltarr(np,nl)
  openr, 1, infile
  for k = 0, nv-1 do begin
    readf, 1, nouse
    readf, 1, tmpgeo
    U(k,0:np-1, 0:nl-1 ) = tmpgeo(0:np-1,0:nl-1)
  endfor
  for k = 0, nv-1 do begin
    readf, 1, nouse
    readf, 1, tmpgeo
    V(k,0:np-1, 0:nl-1 ) = tmpgeo(0:np-1,0:nl-1)
  endfor

  for k = 0, nv-1 do begin
    readf, 1, nouse
    readf, 1, tmpgeo
    geo(k,0:np-1, 0:nl-1 ) = tmpgeo(0:np-1,0:nl-1)
  endfor
 
    readf, 1, nouse
    readf, 1, lon

    readf, 1, nouse
    readf, 1, lat
  
  close,1
end

  infile ='20020603.dmp' 
  np = 100
  nl = 40
  nv = 11

  ; levels are in
  ;1000,925,850,700,500,400,300,250,200,150,100

  geo = fltarr(nv, np, nl)
  lat = fltarr(np,nl)
  lon = fltarr(np,nl)
  U = fltarr(nv,np,nl)
  V = fltarr(nv, np,nl)
 read_revu ,geo, infile, U, V, lat, lon,np, nl, nv
 
 ; read direclty form NCEP data
  rnp = 144 
  rnl = 73
  ng = 3
  rnv = 4  ; 1000, 850, 700, 500mb
  rngeo = fltarr(rnp, rnl)
  rlat = fltarr(rnp, rnl)
  rlon = fltarr(rnp, rnl)
  rinf = '2002-09-11-1800_hgt.dat'
  read_ncar, rinf, rngeo,  rlat, rlon, rnp, rnl,ng, rnv

 ; study area 
  lats = 27
  late = 35
  lons = -90
  lone = -70
  
set_plot, 'ps'
device, filename='geo.ps', xoffset=0.5, yoffset=0.5, xsize=7, ysize=10,$
        /inches 
map_set,/continent, position = [0.10, 0.2, 0.95, 0.65], $
        limit = [lats, lons, late, lone],/USA

nnv = 0
contour, geo(nnv, 0:np-1, 0:nl-1), lon, lat, position = [0.10, 0.2, 0.95, 0.65], $
        xrange=[lons, lone], yrange=[lats, late], xstyle=1, $
	ystyle=1, /noerase,c_labels=(fltarr(15)+1),/irregular,$
        levels = 116+findgen(10)*2, c_charthick=3, c_thick=3	


  lats = 20
  late = 40 
  lons = -110
  lone = -70
map_set,/continent, position = [0.10, 0.2, 0.95, 0.65], $
        limit = [lats, lons, late, lone],/USA
contour, rngeo(2, ng*rnp/2:ng*rnp-1, 0:ng*rnl-1), rlon(ng*rnp/2:ng*rnp-1, 0:ng*rnl-1), $
        rlat(ng*rnp/2:ng*rnp-1, 0:ng*rnl-1), xrange=[lons, lone], $
	yrange=[lats, late], xstyle=1,  ystyle=1, /noerase,$
	c_labels=(fltarr(20)+1),/irregular,$
        nlevels =20,  c_charthick=3,$
	c_thick=3, position = [0.10, 0.2, 0.95, 0.65],$
	levels = 310+findgen(20)*1



; the following is used to plot vector.
;nag = 0.1 

;for i = 0, np-1,2 do begin
; for j = 0, nl-1,2 do begin
;     if ( lon(i,j) lt lone and lon(i,j) gt lons and $
 ;         lat(i,j) gt lats and lat(i,j) lt late ) then begin 
 ;    absV = sqrt(U(nnv, i, j)^0.5+V(nnv, i,j)^0.5) 
 ;    arrow, lon(i,j), lat(i,j), lon(i,j)+nag*U(nnv, i, j), $
 ;         lat(i,j)+nag*V(nnv, i, j), hsize=80, /data
 ;    endif 	  
     ;  velo,tmpU*10, tmpV*10, llon, llat, length = 3, xrange = [lons, lone], $
     ;        yrange= [lats, late], position = [0.10, 0.2, 0.95, 0.65] 
;endfor
;endfor

 ;      velo,tmpU*10, tmpV*10, length = 3,  position = [0.10, 0.2, 0.95, 0.65] 
device, /close
end
