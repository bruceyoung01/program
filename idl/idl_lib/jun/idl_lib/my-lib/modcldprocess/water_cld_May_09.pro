;
; processing modis water cloud effective radius, etc.
; 

;pro water_cld_main 
@read_modis_06.pro
@plot_single_gradule.pro
@water_processing_for_ploting.pro
@process_day_time.pro

; input file name
sensor = 'Terra'
DAyS = 509        ; selected day
Dayss = '509'
filedir = '../cld_mexico/' + sensor + '/'
filename = 'filestatistics.txt' 
process_day,  filedir+filename, Nday, AllFileName, StartInx, EndInx,$
DAYNAME, DAYNUM

; some ranges for the plot
mincldopt = 1.0  & maxcldopt = 47.0
mincldreff = 1.0 & maxcldreff = 47.0 
mincldwtph = 0.01  & maxcldwtph = 11.51
mincldfrac = 2. & maxcldfrac = 94 
;region_limit = [24, -110, 38, -90]
region_limit = [10, -115, 45, -75]

; some temporal varialbe for one day
cldopt  =  fltarr(1354, 2030*11L)
cldreff =  fltarr(1354, 2030*11L)
cldwtph =  fltarr(1354, 2030*11L)
cldfrac =  fltarr(1354/5, 2030/5*11.)
cldtemp =  fltarr(1354/5, 2030/5*11.)
flat  =  fltarr(1354/5, 2030/5*11.)
flon  =  fltarr(1354/5, 2030/5*11.)


set_plot,'ps'
device,filename='MODIS_06_' + sensor + '_' + dayss + '.ps',/portrait,xsize=7.5, ysize=9,$
      xoffset=0.5,yoffset=1,/inches, /color, bits=8

;!p.multi = [0, 1, 2]
load_clt, colors

;rea data
for i = 0, Nday-1 do begin
if (  DayNum(i) eq DayS ) then begin 
totnl = 0
totnnl = 0
print, 'file # is ', endinx(i), startinx(i), endinx(i) - startinx(i)  +1

if ( Endinx(i) -  startinx(i) ge 9 ) then endinx(i) = startinx(i) + 1  

for j = startinx(i)+4,  startinx(i)+6 do begin

;for j = 0,   do begin
    
read_modis06_cldopt, Filedir, AllFilename(j), tmpcldopt, tmpcldreff, tmpcldwtph, $
                    tmpcldphase, tmpcldfrac, tmpcldpress, tmpcldtemp, tmpcldsza, tmpflat, tmpflon, np, nl

; for 5km data dimension
 nnp = np/5
 nnl = nl/5

; decide if it should be mearged
LatB = region_limit(0)
LatT = region_limit(2)
LonL = region_limit(1)
LonR = region_limit(3)

;print, 'Lat B = ', LatB, 'LatT = ', LatT, 'LonL  =',  LonL, 'LonR = ', LonR 

result = where ( tmpflat(0:nnp-1, 0:nnl-1) ge LatB and $
                 tmpflat(0:nnp-1, 0:nnl-1) le LatT  and $
		 tmpflon(0:nnp-1, 0:nnl-1) ge LonL and $
		 tmpflon(0:nnp-1, 0:nnl-1) le LonR, count)

if ( count gt 5000 ) then begin
; processessing
water_processing_for_ploting, tmpcldopt, tmpcldreff, tmpcldwtph,$
tmpcldphase, tmpcldpress, tmpcldtemp, np, nl, $
nnp, nnl

print, 'merge 1 '

; merge
cldopt(0:np-1, totnl:totnl+nl-1)  = TEMPORARY (tmpcldopt(0:np-1,0:nl-1))
cldreff(0:np-1, totnl:totnl+nl-1) = TEMPORARY (tmpcldreff(0:np-1, 0:nl-1)) 
cldwtph(0:np-1, totnl:totnl+nl-1) = TEMPORARY (tmpcldwtph(0:np-1, 0:nl-1))
cldtemp(0:nnp-1, totnnl:totnnl+nnl-1) = TEMPORARY (tmpcldtemp(0:nnp-1, 0:nnl-1))
cldfrac(0:nnp-1, totnnl:totnnl+nnl-1) = TEMPORARY (tmpcldfrac(0:nnp-1, 0:nnl-1))
flat(0:nnp-1, totnnl:totnnl+nnl-1) = TEMPORARY (tmpflat(0:nnp-1, 0:nnl-1))
flon(0:nnp-1, totnnl:totnnl+nnl-1) = TEMPORARY (tmpflon(0:nnp-1, 0:nnl-1))
totnl = totnl+nl
totnnl = totnnl+nnl


;totnl = nl
;totnnl = nnl

endif
endfor

; write output data for reprocessing
;openw, 1, Dayname+'_cloud.dat'
;writeu, cldopt(0:np-1, 0:totnl-1), cldreff(0:np-1,  0:totnl-1), $
;        cldwtph(0:np-1, 0:totnl-1),  


; do plotting
!p.multi = 0
print, 'Dayname is ', Dayname(i)
print, 'totnl = ', totnl
if ( totnl gt 0 ) then begin
plot_cldopt, cldopt(0:np-1, 0:totnl-1), cldreff(0:np-1, 0:totnl-1),$
             cldwtph(0:np-1, 0:totnl-1), cldfrac(0:nnp-1, 0:totnnl-1), $
	     flat(0:nnp-1, 0:totnnl-1), flon(0:nnp-1, 0:totnnl-1), $
             np, totnl, nnp, totnnl, maxcldopt, mincldopt, $
             maxcldreff, mincldreff, maxcldwtph,  mincldwtph, $
             maxcldfrac, mincldfrac,  region_limit, colors, DAYNAME(i)
endif

totnl = 0
totnnl =0 

endif
!p.multi=0
endfor

device, /close
print, 'Prom is over !!!'

end



