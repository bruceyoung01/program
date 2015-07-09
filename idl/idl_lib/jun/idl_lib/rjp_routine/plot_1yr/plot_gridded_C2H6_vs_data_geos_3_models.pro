pro plot_gridded_C2H6_vs_data_geos_3_models, Species, max_sta,$
        ext1, ext2, ext3, title, psname, nalt1, nalt2, nalt3

; For selected regions from aircraft compains plot data profiles (black
; solid line and profiles from 2 models - with geos and geos_2  
; winds, plotted with linestyles 1 to 2 and colors red and green  
; correspondently


!X.OMARGIN=[10,8] 
!Y.OMARGIN=[8,8]
!P.CHARTHICK=2.5
!P.THICK=2.5
!X.THICK=4
!Y.THICK=4

; File with information about stations

filest=''
filest='/users/trop/iam/netCDF/'+Species+'.stations'
PRINT, filest
openr, usta, filest, /get_lun
iname_sta=''
ititle_sta=''

mmonth = strarr(12)
mmonth=['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec']

scales=[1.5,1.5,1.5,1.5,1.5,2.5,1.5,2.5,1.5,2,2.5,2,1.5,1.5,1.5,1,$
         1,1.5,2.5,1,1,1,1,1,1,1,1,1.5,1,1.5,2,1.5,1.5,1,1,1,1,2,2,2,1.5]

open_device, olddevice,/ps,/color,filename=psname,/portrait

; Specify directory with the data (vertical profiles) 

            pre = '/data/eval/aircraft/data/'+species+'/'
            xtitle = 'C2H6 (ppb)' 

; --- read station & indice ---

name_sta = strarr(max_sta)
month    = fltarr(max_sta)
lol      = fltarr(max_sta)
lor      = fltarr(max_sta)
lad      = fltarr(max_sta)
lau      = fltarr(max_sta)
H        = fltarr(max_sta)
year     = intarr(max_sta)
title_sta = strarr(max_sta)

; Read in information about stations from input file

for i=0,max_sta-1 do begin
    readf,usta, iname_sta,                  $
                ilol, ilor, ilad, ilau,          $
                imonth , iH, iyear, ititle_sta,         $
                format='(a36,1x,i4,1x,i4,1x,i4,1x,i4,1x,i4,1x,i4,1x,i2,1x,a25)'
    ;print,      iname_sta,                  $
    ;            ilol, ilor, ilad, ilau,     $
    ;            imonth , iH, ititle_sta,    $
    ;            format='(a36,1x,i4,1x,i4,1x,i4,1x,i4,1x,i4,1x,i4,1x,i2,1x,a25)'
    name_sta(i) = iname_sta
    month(i)    = imonth
    lol(i)      = ilol
    lor(i)      = ilor
    lad(i)      = ilad
    lau(i)      = ilau
    H(i)        = iH
    year(i)     = iyear
    title_sta(i) = ititle_sta
endfor

; Set number of rows and columns

nrow=4
ncol=4
!P.Multi = [0,nrow,ncol,1,0]

; ---  open files ---

ncount=0

; Loop through the stations

for k = 1, max_sta do begin

ncount=ncount+1
 ;print, 'STATION : ', k
    kk = k-1 
    ix = k
    file=''

    file=pre+strtrim(name_sta(kk),2)
    ;print, ''
    ;print, '---', file 
    ;print, file

; Replace NA with -999.

;    cmd = "sed 's/NA/-999./g' "+file+" > tmpfile"
;    spawn, cmd
;    cmd = "sed 's/NaN/-999./g' tmpfile > tmpfile2"
;    spawn, cmd

    ilun = 99
;    openr,ilun,'tmpfile2';,/get_lun
    openr,ilun,file

    dummy=''
    readf, ilun, dummy

    maxd = 50
    pressure  = fltarr(maxd)
    gtemean   = fltarr(maxd)
    gtemedian = fltarr(maxd)
    gtestd    = fltarr(maxd)
    gtenum    = fltarr(maxd)

; Read data profile

    i = 0
    while (not eof(ilun)) do begin
    i = i + 1
       readf, ilun,                                             $
              ipressure, inum, igtemean, igtemedian, igtestd,   $
              ip10, ip25, ip75, ip90, imin, imax
       ;print, ipressure, inum, igtemean, igtemedian, igtestd
       pressure(i-1)  = ipressure 
       gtenum(i-1)    = inum
       gtemean(i-1)   = igtemean
       gtemedian(i-1) = igtemedian
       gtestd(i-1)    = igtestd
    endwhile


    Hk = i
    ;print, 'value of Hk ', i

    close, ilun
;    spawn, 'rm -f tmpfile'
;    spawn, 'rm -f tmpfile2'


; Station title
    ltitle=''
    ltitle = strtrim(title_sta(kk),2)
 ;print, ltitle

; If median value < 0, replace with -999
    tmp = pressure(0:Hk-1) 
    ind = where(gtemedian(0:Hk-1) lt 0.)    
    if ind(0) ge 0 then $
    tmp(ind) = -999.

    ind2 = where(gtestd(0:Hk-1) lt 0.)

; -- plot observed data --


     if (pressure(0) lt 10) then tmp(0:Hk-1) = 1013*(1.-2.257e-5*(pressure(0:Hk-1)*1.e3))^5.2533  
     yrange = [1000, 100]
     height = 0
     mmm = 230

       highval=scales(k-1)
       loval=0
       ;print,'*****',loval,highval

; Plot medians
      plot, gtemedian(0:Hk-1)/1000, -alog10(tmp), xstyle=1,ystyle=5,$
        title=ltitle,linestyle=0,psym=-5,symsize=0.6, $
        xticks=4, min_val=-900, yrange=[-3,-alog10(200)], xrange=[loval,highval],$
        charsize=1.2, xmargin=[4,3], ymargin=[3,2],color=1


       howfarover=0.8*highval

       howfarover2=highval*0.5

          tempo3=1900+year(kk)
       if year(kk) lt 50 then begin
          tempo3=2000+year(kk)
       endif 
          tempo=string(format='(a3,",",i4)',mmonth(month(kk)-1),tempo3)
        xyouts,howfarover2,-alog10(mmm),tempo,charsize = 0.7, /data,color=1

; Plot means
      oplot, gtemean(0:Hk-1)/1000, -alog10(tmp), $
        linestyle=0,psym=6,symsize=0.2,color=1

      for w = 0, Hk-1 do begin
        if gtestd(w) gt 0. then begin
          errbar = [gtemean(w)-gtestd(w), gtemean(w)+gtestd(w)]
; Plot error bars
          oplot, errbar/1000, [-alog10(tmp(w)),-alog10(tmp(w))],color=1
          nnum=''
          nnum = strtrim(string(gtenum(w),format='(i4)'),2)
          ;nnum = STRCOMPRESS(STRTRIM(gtenum(w),2))
          ;print, nnum
          xyouts,howfarover,-alog10(tmp(w)), nnum, charsize = 0.6,/data,color=1

        endif
      endfor

; -- read geos files --
   xdata=fltarr(14)
   xlevel=fltarr(14)
   A = fltarr(2)
   filef ='' 
   filef =  strtrim(name_sta(kk),2)+ext1

   ; Now read FILEF from temporary directory (bmy, 8/13/03)
   filef = 'temp/' + filef
   ;print,filef

   result = findfile(filef, count = toto)

 
   pressure=fltarr(nalt1) ;geos
   co=fltarr(nalt1)       ;geos

   openr,ix,filef
        for j = 1,nalt1 do begin  ;19 levels 
            jx = j - 1
            readf, ix, fpres, fco,format='(f13.3,f13.4)'
            pressure[jx]=fpres
            co[jx]=fco
        endfor

   close,ix

   zz = fltarr(16)
   ZZ = FINDGEN(16) * (!PI*2./16.)
   USERSYM, COS(zz), SIN(zz);  , /FILL

   ;print, pressure
   ;print, co

; Plot profile from geos model

   oplot,co/2,-alog10(pressure),psym=-8, symsize=0.2,linestyle=1,color=2

; -- read geos_2 files --
   xdata=fltarr(14)
   xlevel=fltarr(14)
   A = fltarr(2)
   filef ='' 
;   filef =  strtrim(name_sta(kk),2)+'.geos.amf'
   filef =  strtrim(name_sta(kk),2)+ext2

   ; Now read FILEF from temporary directory (bmy, 8/13/03)
   filef = 'temp/' + filef
   ;print,filef

   result = findfile(filef, count = toto)

   ;if toto eq 0 then begin
   ;   print, 'NO FILE for : '+ filef
   ;   goto, jump_endloop
   ;endif
 
   pressure=fltarr(nalt2) ;geos_2
   co=fltarr(nalt2)       ;geos_2

   openr,ix,filef
        for j = 1,nalt2 do begin  ;20 levels
            jx = j - 1
            readf, ix, fpres, fco,format='(f13.3,f13.4)'
            pressure[jx]=fpres
            co[jx]=fco
        endfor

   close,ix

   zz = fltarr(26)
   ZZ = FINDGEN(26) * (!PI*2./26.)
   USERSYM, COS(zz), SIN(zz);  , /FILL

   ;print, pressure
   ;print, co

; Plot profile from geos_2 model

   oplot,co/2,-alog10(pressure),psym=-8, symsize=0.2,linestyle=2,color=3

; -- read geos_3 files --
   xdata=fltarr(14)
   xlevel=fltarr(14)
   A = fltarr(2)
   filef ='' 
;   filef =  strtrim(name_sta(kk),2)+'.geos.amf'
   filef =  strtrim(name_sta(kk),2)+ext3

   ; Now read FILEF from temporary directory (bmy, 8/13/03)
   filef = 'temp/' + filef
   ;print,filef

   result = findfile(filef, count = toto)

   ;if toto eq 0 then begin
   ;   print, 'NO FILE for : '+ filef
   ;   goto, jump_endloop
   ;endif
 
   pressure=fltarr(nalt3) ;geos
   co=fltarr(nalt3)       ;geos

   openr,ix,filef
        for j = 1,nalt3 do begin  ;19 levels
            jx = j - 1
            readf, ix, fpres, fco,format='(f13.3,f13.4)'
            pressure[jx]=fpres
            co[jx]=fco
        endfor

   close,ix

   zz = fltarr(16)
   ZZ = FINDGEN(16) * (!PI*2./16.)
   USERSYM, COS(zz), SIN(zz);  , /FILL

   ;print, pressure
   ;print, co

; Plot profile from geos_3 model

   oplot,co/2,-alog10(pressure),psym=-8, symsize=0.2,linestyle=3,color=4

; Put labels on the axes

;if ncount eq nrow*ncol then begin
xyouts, 0.05, 0.5, 'Pressure (hPa)', /normal, align=0.5, orientation=90, charsize=1.2,color=1
xyouts, 0.5, 0.05, 'C2H6 (ppb)', /normal, align=0.5, charsize=1.,color=1
;endif

pres=[1000,800,600,400,200]
logpres=-alog10(pres)
pres1=strtrim(string(pres),2)
pres1[1]=" "
pres2 = replicate(' ',n_elements(pres1))

pres1=strtrim(string(pres),2)
  axis, loval, yaxis=0, yticks=12, yrange=[-3,-alog10(200)],$
      ytickv=logpres, ytickname=pres1,/ystyle,color=1

  axis, highval, yaxis=1, yticks=12, yrange=[-3,-alog10(200)],$
      ytickv=logpres, ytickname=pres2, /ystyle,color=1      
;xyouts, 0.5, 0.96,"GEOS-STRAT for 1997 (2x2.5) - red, GEOS-3 for 2001 (4x5) - green.", /normal, align=0.5, charsize=1.2,color=1
xyouts, 0.5, 0.96,title, /normal, align=0.5, charsize=1.2,color=1

endfor 

close_device, /TIMESTAMP

close, /all

end


