pro plot_3d_ctmout,ttag=ttag,gas=gas,out=out,pout=pout,ohavg=ohavg, $
    ilmm=ilmm,ijmm=ijmm

if n_elements(ttag) eq 0 then ttag = ' '

;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
; Control parameter for drawing
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
thick = 2.0
chsize = 1.6
np = n_elements(pout)
fn = intarr(2)
for i = 0, np-1 do begin
 if pout(i) eq 1000. then fn(0) = i
 if pout(i) eq  500. then fn(1) = i
end

;######################################################################
; You do not need to touch on below this
;######################################################################

POH = REVERSE(pout)
;loadct, 39

set_plot, 'ps'
device, file='outconc.ps', xoffset=1.5, yoffset=1.5, xsize= 18, ysize = 24
sec = 0.0

upos = [0.05, 0.55, 0.95, 0.95]
lpos = [0.05, 0.05, 0.95, 0.45]
p1 = strtrim(string(fix(pout(fn(0)))),1)
p2 = strtrim(string(fix(pout(fn(1)))),1)
tag1 = ',  Averaged for '+ttag+' at '+p1+' mb'
tag2 = ',  Averaged for '+ttag+' at '+p2+' mb'

ic = n_elements(gas)
gasname = gas
gasname(1) = 'NOx'

lat = -90.+findgen(ijmm)*(180./(ijmm-1))
lon = -180.+findgen(ilmm)*(360./ilmm)

;; Contour levels
 ohlev =[1.,5.,10.,15.,20.,25.]  		& loh = indgen(n_elements(ohlev)) & loh(*) = 1
 noxlev_s = [1,10,100,1000,5000,10000] 	& lnox_s = indgen(n_elements(noxlev_s)) & lnox_s(*) = 1
 noxlev_u = [1,10,20,50,100] 			& lnox_u = indgen(n_elements(noxlev_u)) & lnox_u(*) = 1
 n2olev_s = [1,5,10,15,20,25] 		& ln2o_s = indgen(n_elements(n2olev_s)) & ln2o_s(*) = 1
 n2olev_u = [1,5,10,15,20,25] 		& ln2o_u = indgen(n_elements(n2olev_u)) & ln2o_u(*) = 1
 hnolev_s = [10,100,500,1000,5000]		& lhno_s = indgen(n_elements(hnolev_s)) & lhno_s(*) = 1
 hnolev_u = [10,50,100,200,500,1000]	& lhno_u = indgen(n_elements(hnolev_u)) & lhno_u(*) = 1
 panlev_s = [10,100,500,1000,5000]		& lpan_s = indgen(n_elements(panlev_s)) & lpan_s(*) = 1
 panlev_u = [10,50,100,200,500]		& lpan_u = indgen(n_elements(panlev_u)) & lpan_u(*) = 1
 colev_s  = [30,50,70,100,200,400]		& lco_s  = indgen(n_elements(colev_s))  & lco_s(*)  = 1
 colev_u  = [30,50,70,100,200]		& lco_u  = indgen(n_elements(colev_u))  & lco_u(*)  = 1
 o3lev_s  = [10,20,30,40,50,60,70,80] 	& lo3_s  = indgen(n_elements(o3lev_s))  & lo3_s(*)  = 1
 o3lev_u  = [20,30,40,50,60,70]		& lo3_u  = indgen(n_elements(o3lev_u))  & lo3_u(*)  = 1
 isolev_s = [1,10,100,1000,5000,10000] 	& liso_s = indgen(n_elements(isolev_s)) & liso_s(*) = 1
 isolev_u = [1,10,20,50,100]			& liso_u = indgen(n_elements(isolev_u)) & liso_u(*) = 1

for i = 0, ic-1 do begin
 if (gas(i) eq 'NO')   then ino = i
 if (gas(i) eq 'NO2')  then ino2 = i
 if (gas(i) eq 'HNO3') then ihno3 = i
 if (gas(i) eq 'O3')   then io3 = i
 if (gas(i) eq 'CO')   then ico = i
 if (gas(i) eq 'CH3CO3NO2') then ipan = i
 if (gas(i) eq 'ISOP') then iisop = i
END

;; OH plot
 contour, ohavg/1.e5,lat,poh, /follow, nlevels=6, yrange=[1000.,0.],$
 pos = [0.1, 0.55, 0.9, 0.95],c_labels=loh,levels=ohlev, xrange=[-80.,80], $
 title='OH/1.e5, Zonal average for '+ttag, ytitle = 'Pressure/mb', $
 xtitle = 'Latitude', c_colors=color_index(nlevels), xstyle=1,ystyle=1,c_thick=thick, $
 charsize = chsize

 out(*,*,*,ino2) = out(*,*,*,ino)+out(*,*,*,ino2)
;; Nox plot
 map_set,0.,0.,/cyl,/continents,/grid,pos=upos,title=gasname(ino2)+tag1,con_color=46,charsize=chsize
 contour, out(*,*,fn(0),ino2)*1.e12,lon,lat,/follow,/overplot,nlevels=6,pos=upos,c_labels=lnox_s, $
 levels=noxlev_s, c_colors=color_index(nlevels),xstyle=1,ystyle=1,c_thick=thick

 map_set,0.,0.,/cyl,/continents,/grid,pos=lpos,title=gasname(ino2)+tag2,con_color=46,charsize=chsize,/noerase
 contour, out(*,*,fn(1),ino2)*1.e12,lon,lat,/follow,/overplot,nlevels=5,pos=lpos,c_labels=lnox_u, $
 levels=noxlev_u,c_colors=color_index(nlevels),xstyle=1,ystyle=1,c_thick=thick


;; Hno3 plot
 map_set,0.,0.,/cyl,/continents,/grid,pos=upos,title=gasname(ihno3)+tag1,con_color=46,charsize=chsize
 contour, out(*,*,fn(0),ihno3)*1.e12,lon,lat,/follow,/overplot,nlevels=5,pos=upos,c_labels=lhno_s, $
 levels=hnolev_s,c_colors=color_index(nlevels),xstyle=1,ystyle=1,c_thick=thick

 map_set,0.,0.,/cyl,/continents,/grid,pos=lpos,title=gasname(ihno3)+tag2,con_color=46,charsize=chsize,/noerase
 contour, out(*,*,fn(1),ihno3)*1.e12,lon,lat,/follow,/overplot,nlevels=6,pos=lpos,c_labels=lhno_u, $
 levels=hnolev_u,c_colors=color_index(nlevels),xstyle=1,ystyle=1,c_thick=thick


;; PAN plot
 map_set,0.,0.,/cyl,/continents,/grid,pos=upos,title=gasname(ipan)+tag1,con_color=46,charsize=chsize
 contour, out(*,*,fn(0),ipan)*1.e12,lon,lat,/follow,/overplot,nlevels=5,pos=upos,c_labels=lpan_s, $
 levels=panlev_s,c_colors=color_index(nlevels),xstyle=1,ystyle=1,c_thick=thick

 map_set,0.,0.,/cyl,/continents,/grid,pos=lpos,title=gasname(ipan)+tag2,con_color=46,charsize=chsize,/noerase
 contour, out(*,*,fn(1),ipan)*1.e12,lon,lat,/follow,/overplot,nlevels=5,pos=lpos,c_labels=lpan_u, $
 levels=panlev_u, c_colors=color_index(nlevels),xstyle=1,ystyle=1,c_thick=thick
 

;; CO plot
 map_set,0.,0.,/cyl,/continents,/grid,pos=upos,title=gasname(ico)+tag1,con_color=46,charsize=chsize
 contour, out(*,*,fn(0),ico)*1.e9,lon,lat,/follow,/overplot,nlevels=6,pos=upos,c_labels=lco_s, $
 levels=colev_s, c_colors=color_index(nlevels),xstyle=1,ystyle=1,c_thick=thick

 map_set,0.,0.,/cyl,/continents,/grid,pos=lpos,title=gasname(ico)+tag2,con_color=46,charsize=chsize,/noerase
 contour, out(*,*,fn(1),ico)*1.e9,lon,lat,/follow,/overplot,nlevels=5,pos=lpos,c_labels=lco_u, $
 levels=colev_u, c_colors=color_index(nlevels),xstyle=1,ystyle=1,c_thick=thick
 

;; O3 plot
 map_set,0.,0.,/cyl,/continents,/grid,pos=upos,title=gasname(io3)+tag1,con_color=46,charsize=chsize
 contour, out(*,*,fn(0),io3)*1.e9,lon,lat,/follow,/overplot,nlevels=8,pos=upos,c_labels=lo3_s, $
 levels=o3lev_s,c_colors=color_index(nlevels),xstyle=1,ystyle=1,c_thick=thick

 map_set,0.,0.,/cyl,/continents,/grid,pos=lpos,title=gasname(io3)+tag2,con_color=46,charsize=chsize,/noerase
 contour, out(*,*,fn(1),io3)*1.e9,lon,lat,/follow,/overplot,nlevels=6,pos=lpos,c_labels=lo3_u, $
 levels=o3lev_u,c_colors=color_index(nlevels),xstyle=1,ystyle=1,c_thick=thick

;; ISOP PLOT
 map_set,0.,0.,/cyl,/continents,/grid,pos=upos,title=gasname(iisop)+tag1,con_color=46,charsize=chsize
 contour, out(*,*,fn(0),iisop)*1.e12,lon,lat,/follow,/overplot,nlevels=6,pos=upos,c_labels=liso_s, $
 levels=isolev_s, c_colors=color_index(nlevels),xstyle=1,ystyle=1,c_thick=thick

 map_set,0.,0.,/cyl,/continents,/grid,pos=lpos,title=gasname(iisop)+tag2,con_color=46,charsize=chsize,/noerase
 contour, out(*,*,fn(1),iisop)*1.e12,lon,lat,/follow,/overplot,nlevels=5,pos=lpos,c_labels=liso_u, $
 levels=isolev_u,c_colors=color_index(nlevels),xstyle=1,ystyle=1,c_thick=thick

device,/close
set_plot,'X'

return
end

