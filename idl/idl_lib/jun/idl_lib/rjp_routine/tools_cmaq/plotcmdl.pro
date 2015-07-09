pro plotcmdl, co, imon

;+
;-

if n_elements(co) eq 0 then print, 'no values for co', return
dim = size(co)
ilmm = dim(1) & ijmm = dim(2) & ikmm = dim(3)

 set_plot,'ps'
 device,filename='co_cmdl.ps',xoffset=1.5,yoffset=1.5,xsize=18, ysize=23 

 case imon of
1 : tag = ' [JAN]'
2 : tag = ' [FEB]'
3 : tag = ' [MAR]'
4 : tag = ' [APR]'
5 : tag = ' [MAY]'
6 : tag = ' [JUN]'
7 : tag = ' [JUL]'
8 : tag = ' [AUG]'
9 : tag = ' [SEP]'
10: tag = ' [OCT]'
11: tag = ' [NOV]'
12: tag = ' [DEC]'
 else : tag = '    '
 endcase

!p.multi=[0,2,5]

 list = ['altmm.co', 'ascmm.co', 'balmm.co', 'bmemm.co', 'bmwmm.co', $
         'brwmm.co', 'bscmm.co', 'cbamm.co', 'cgomm.co', 'chrmm.co', $
         'cmomm.co', 'eicmm.co', 'gmimm.co', 'gozmm.co', 'hunmm.co', $
         'icemm.co', 'itnmm.co', 'izomm.co', 'keymm.co', 'kummm.co', $
         'lefmm.co', 'mbcmm.co', 'mhdmm.co', 'midmm.co', 'mlomm.co', $
         'nwrmm.co', 'psamm.co', 'qpcmm.co', 'rpbmm.co', 'seymm.co', $
         'shmmm.co', 'smomm.co', 'spomm.co', 'syomm.co', $
         'tapmm.co', 'utamm.co', 'uummm.co', 'zepmm.co' ]


 std = ''
 dx = 360./ilmm & dy = 180./(ijmm-1)
 dir = '/data/eos3/stone/data/cmdl/month/'

for n = 0 , 3 do begin
; window, n, xsize=600, ysize=800

for k = 0 , 9 do begin
 i = k+n*10
 if i ge n_elements(list) then goto, jump

cmdl_co = rdcmdl(file=dir+list(i),time=time,imon=imon,lat=lat,lon=lon)

plot,time,cmdl_co,title=list(i)+tag,yrange=[10,400],charsize=1.5,xstyle=2

 xx = (lon(0)+180.)/dx & yy = (lat(0)+90.)/dy
 ix = fix(xx) & iy = fix(yy)
 if (xx-ix) ge 0.5 then ix = ix+1
 if (yy-iy) ge 0.5 then iy = iy+1

xyouts,(min(time)+max(time))/2,350,strtrim(string( -90.+(iy*dy)),1)+', '+strtrim(string(lat),1), size=0.7
xyouts,(min(time)+max(time))/2,320,strtrim(string(-180.+(ix*dx)),1)+', '+strtrim(string(lon),1), size=0.7

;readf,ilun,std,clat,clon,jan,feb, format='(a3,1x,f6,1x,f7,1x,f6,1x,f6)'
;readf,jlun,std,clat,clon,jan_z,feb_z, format='(a3,1x,f6,1x,f7,1x,f6,1x,f6)'

calco = cmdl_co & calco(*) = co(ix,iy,ikmm-1)*1.e9  ; change parameter !!
calco_z = cmdl_co & calco_z(*) = 1.e9*total(co(ix,iy,ikmm-3:ikmm-1))/3 

avecmdl   = moment(cmdl_co)
avecalco  = moment(calco)
avecalco_z= moment(calco_z)
diff1 = 100.*(avecalco(0)-avecmdl(0))/avecmdl(0)
diff2 = 100.*(avecalco_z(0)-avecmdl(0))/avecmdl(0)

xyouts, min(time), 350, strtrim(string(diff1),1), size=0.7
xyouts, min(time), 320, strtrim(string(diff2),1), size=0.7


oplot, time, calco, psym=4
oplot, time, calco_z, psym=7
end
end

jump : print, i

 device, /close
 set_plot,'x'

return
end

