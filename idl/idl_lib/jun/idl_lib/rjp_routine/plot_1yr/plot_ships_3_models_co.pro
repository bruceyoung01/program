; $Id: plot_ships_3_models_co.pro,v 1.2 2003/12/08 19:35:00 bmy Exp $
pro plot_ships_3_models_co,ext1,ext2,ext3,title,psname


!X.OMARGIN=[8,6] 
!Y.OMARGIN=[6,6]
!X.THICK=4
!Y.THICK=4
!P.CHARTHICK=2.5
!P.THICK=2.5

Species='CO'

filest=''
filest='/users/trop/iam/netCDF/CO.ships' ;input data about stations
;PRINT, filest
openr, usta, filest, /get_lun
iname_sta=''
ititle_sta=''
ipref_sta=''

mmonth = strarr(12)
mmonth=['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec']


open_device, olddevice,/ps,/color,filename=psname ;color plot

; Specify directory with surface data 

            pre = '/users/trop/iam/cmdl/newdata/'

; --- read station & indice ---

; Set max_sta parameter

max_sta=13   ;test

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
;print, usta
for i=0,max_sta-1 do begin
    readf,usta, iname_sta,                  $
                ilol, ilor, ilad, ilau,          $
                imonth , iH, iyear, ititle_sta,         $
                format='(a6,31x,i4,1x,i4,1x,i4,1x,i4,1x,i4,1x,i4,1x,i2,1x,a25)'
    ;;print,      iname_sta,                  $
    ;            ilol, ilor, ilad, ilau,     $
    ;            imonth , iH, ititle_sta,    $
    ;            format='(a6,31x,i4,1x,i4,1x,i4,1x,i4,1x,i4,1x,i4,1x,i2,1x,a25)'
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


nrow=4
ncol=4
!P.Multi = [0,nrow,ncol,1,0]

; ---  open files ---

ncount=0

; --- loop for stations ---
for k = 1, max_sta do begin

ncount=ncount+1
 ;print, 'STATION : ', k
    kk = k-1 
    ix = k
    file=''

    file=pre+name_sta(kk)+'.mn'

    ilun = k+50
    openr,ilun,file

    maxd = 12
    comean   = fltarr(maxd)
    comedian = fltarr(maxd)
    costd    = fltarr(maxd)
    conum    = fltarr(maxd)
    comin    = fltarr(maxd)
    comax    = fltarr(maxd)

 for i=0,11 do begin
       readf,ilun,                                             $
              icomean, icostd,inum, icomin, icomax,icomedian    
       conum(i)    = inum
       comean(i)   = icomean
       comedian(i) = icomedian
       costd(i)    = icostd
       comin(i)    =icomin
       comax(i)    =icomax
 endfor
    close, ilun
;;print, comean

; Create station title

    ltitle=''
    ltitle = strtrim(title_sta(kk),2)

; Read data from first geos model
   co=fltarr(12)
   name_geos=name_sta(kk)+ext1
   
   ; Now read NAME_GEOS file from /temp directory (bmy, 8/13/03)
   name_geos = 'temp/' + name_geos

   openr,ix, name_geos
        for j = 1,12 do begin  ;12 levels 
            jx = j - 1
            readf, ix, fco
            co[jx]=fco
        endfor

   close,ix


; Define the range for y axis

loval=0 
if  min([comean,co]) gt 70 then begin loval=50
endif
if  min([comean,co]) gt 120 then begin loval=100
endif
if  min([comean,co]) gt 170 then begin loval=150
endif
if  min([comean,co]) gt 220 then begin loval=200
endif

highval=100
if  max([comean,co]) gt 80 then begin highval=150
endif
if  kk eq 12 then begin highval=100
endif

if  max([comean,co]) gt 130 then begin highval=200
endif
if  max([comean,co]) gt 180 then begin highval=250
endif
if  max([comean,co]) gt 230 then begin highval=300
endif
if  max([comean,co]) gt 280 then begin highval=350
endif
if  max([comean,co]) gt 330 then begin highval=400
endif

if name_sta[kk] eq "BAL" then begin highval=400
endif

if name_sta[kk] eq "STM" then begin highval=300
endif

if name_sta[kk] eq "TAP" then begin highval=500
endif

if name_sta[kk] eq "WLG" then begin highval=500
endif

if name_sta[kk] eq "NWR" then begin highval=300
endif

; -- plot observed data --

     plot, findgen(12)+1, comean, xstyle=1,ystyle=1,$
        title=ltitle,linestyle=0,psym=-5,symsize=0.6, $
        xticks=13, min_val=-900, xrange=[0,13],yrange=[loval,highval],$
        charsize=1.5, xmargin=[3,2], ymargin=[3,1],color=1,$
         xtickname=[' ','J','F','M','A','M','J','J','A','S','O','N','D',' ']

; Now plot standard deviations
 
      for w = 0, 11 do begin
           errbar = [comean[w]-costd[w], comean[w]+costd[w]]
          oplot,  [w+1,w+1],errbar,$
                 linestyle=0,color=1
       endfor


   oplot, findgen(12)+1,co,linestyle=1,color=2
   oplot, findgen(12)+1,co,linestyle=1,psym=2,symsize=0.3,color=2   



; Read data from second geos model

   name_geos_2=name_sta(kk)+ext2

   ; Now read NAME_GEOS file from /temp directory (bmy, 8/13/03)
   name_geos_2 = 'temp/' + name_geos_2

   openr,ix, name_geos_2
        for j = 1,12 do begin  ;12 levels 
            jx = j - 1
            readf, ix, fco
            co[jx]=fco
        endfor

   close,ix


   oplot, findgen(12)+1,co,linestyle=2,color=3
   oplot, findgen(12)+1,co,linestyle=2,psym=2,symsize=0.3,color=3   

; Read data from third geos model

   name_geos_3=name_sta(kk)+ext3

   ; Now read NAME_GEOS file from /temp directory (bmy, 8/13/03)
   name_geos_3 = 'temp/' + name_geos_3

   openr,ix, name_geos_3
        for j = 1,12 do begin  ;12 levels 
            jx = j - 1
            readf, ix, fco
            co[jx]=fco
        endfor

   close,ix


   oplot, findgen(12)+1,co,linestyle=3,color=4
   oplot, findgen(12)+1,co,linestyle=3,psym=2,symsize=0.3,color=4   


xyouts, 0.04, 0.5, 'CO (ppb)', /normal, align=0.5, orientation=90, $
  charsize=1.2,color=1
xyouts, 0.5, 0.96, title, /normal, align=0.5, charsize=1.2,color=1
endfor

close_device, /TIMESTAMP

close, /all

end


