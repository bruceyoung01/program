; $Id: plot_ships_3_models_4_months.pro,v 1.2 2003/12/08 19:35:00 bmy Exp $
pro plot_ships_3_models_4_months, ext1, ext2, ext3, title,psname

; For a given set of stations compares CO surface data from cmdl (black
; solid line) with surface data from 3 geos models


!X.OMARGIN=[4,2] 
!Y.OMARGIN=[2,2]
!X.THICK=4
!Y.THICK=4
!P.CHARTHICK=2.5
!P.THICK=2.5

Species='CO'

filest=''
filest='/users/trop/iam/netCDF/CO.ships' ;input data about stations
;PRINT filest
openr, usta, filest, /get_lun
iname_sta=''
ititle_sta=''
ipref_sta=''

mmonth = strarr(12)
mmonth=['JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC']



open_device, olddevice,/ps,/color,filename=psname ;color plot

; Specify directory with surface data 

            pre = '/users/trop/iam/cmdl/newdata/'

; Define arrays for storing data
geos_data=fltarr(13,12)
geos2_data=fltarr(13,12)
geos3_data=fltarr(13,12)
cmdl_data=fltarr(13,12)
cmdl_std=fltarr(13,12)

; --- read station & indice ---

; Set max_sta parameter

max_sta=13


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
;print usta
for i=0,max_sta-1 do begin
    readf,usta, iname_sta,                  $
                ilol, ilor, ilad, ilau,          $
                imonth , iH, iyear, ititle_sta,         $
                format='(a6,31x,i4,1x,i4,1x,i4,1x,i4,1x,i4,1x,i4,1x,i2,1x,a25)'
    ;;print      iname_sta,                  $
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


nrow=2
ncol=2
!P.Multi = [0,nrow,ncol,1,0]

; ---  open files ---

ncount=0

; --- loop for stations ---
for k = 1, max_sta do begin

ncount=ncount+1
 ;print 'STATION : ', k
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
;;print comean
cmdl_data(12-kk,*)= comean
cmdl_std(12-kk,*)= costd

; Read data from geos model
   co=fltarr(12)
   name_geos=name_sta(kk)+ext1

   ; Now read NAME_GEOS from temp/ directory (bmy, 8/13/03)
   name_geos = 'temp/' + name_geos

   openr,ix, name_geos
        for j = 1,12 do begin  ;12 levels 
            jx = j - 1
            readf, ix, fco
            co[jx]=fco
        endfor

   close,ix
geos_data(12-kk,*)= co

; Read data from geos2 model
 
   name_geos2=name_sta(kk)+ext2

   ; Now read NAME_GEOS2 from temp/ directory (bmy, 8/13/03)
   name_geos2 = 'temp/' + name_geos2

   openr,ix, name_geos2
        for j = 1,12 do begin  ;12 levels 
            jx = j - 1
            readf, ix, fco
            co[jx]=fco
        endfor

   close,ix
geos2_data(12-kk,*)= co

; Read data from geos3 model

   name_geos3=name_sta(kk)+ext3

   ; Now read NAME_GEOS3 from temp/ directory (bmy, 8/13/03)
   name_geos3 = 'temp/' + name_geos3

   openr,ix, name_geos3
        for j = 1,12 do begin  ;12 levels 
            jx = j - 1
            readf, ix, fco
            co[jx]=fco
        endfor

   close,ix
geos3_data(12-kk,*)= co


endfor
; Define the range for y axis

loval=0
highval=250 

; -- plot observed data --

     plot, findgen(13)+1, cmdl_data(*,0), xstyle=1,ystyle=1,$
        title=ltitle,linestyle=0,psym=-5,symsize=0.6, $
        xticks=14, min_val=-900, xrange=[0,14],yrange=[loval,highval],$
        charsize=1.5, xmargin=[3,1], ymargin=[1.5,1],color=1,$
        xtickname=[' ','30S',' ','20S',' ','10S',' ','0',' ','10N',' ','20N',' ','30N',' ']

; Now plot standard deviations
 
      for w = 0, 11 do begin
           errbar = [cmdl_data(w,0)-cmdl_std(w,0),cmdl_data(w,0)+cmdl_std(w,0)]
          oplot,  [w+1,w+1],errbar,$
                 linestyle=0,color=1
       endfor

   oplot, findgen(13)+1,geos_data(*,0),linestyle=1,color=2
   oplot, findgen(13)+1,geos_data(*,0),linestyle=1,psym=2,symsize=0.3,color=2   
   oplot, findgen(13)+1,geos2_data(*,0),linestyle=2,color=3
   oplot,findgen(13)+1,geos2_data(*,0),linestyle=2,psym=2,symsize=0.3,color=3

   oplot, findgen(13)+1,geos3_data(*,0),linestyle=3,color=4
   oplot, findgen(13)+1,geos3_data(*,0),linestyle=3,psym=2,symsize=0.3,color=4 

          ;------------------------------------------------------------------
          ; Prior to 9/23/03:
          ;xyouts,-80,220, mmonth[0], charsize = 1.2, /data, color=1
          ;------------------------------------------------------------------
          xyouts, 1, highval-50, mmonth[0], charsize = 1.2, /data, color=1

; -- plot observed data --

     plot, findgen(13)+1, cmdl_data(*,3), xstyle=1,ystyle=1,$
        title=ltitle,linestyle=0,psym=-5,symsize=0.6, $
        xticks=14, min_val=-900, xrange=[0,14],yrange=[loval,highval],$
        charsize=1.5, xmargin=[3,1], ymargin=[1.5,1],color=1,$
        xtickname=[' ','30S',' ','20S',' ','10S',' ','0',' ','10N',' ','20N',' ','30N',' ']

; Now plot standard deviations
 
      for w = 0, 11 do begin
           errbar = [cmdl_data(w,3)-cmdl_std(w,3),cmdl_data(w,3)+cmdl_std(w,3)]
          oplot,  [w+1,w+1],errbar,$
                 linestyle=0,color=1
       endfor

   oplot, findgen(13)+1,geos_data(*,3),linestyle=1,color=2
   oplot,findgen(13)+1,geos_data(*,3),linestyle=1,psym=2,symsize=0.3,color=2  

   oplot, findgen(13)+1,geos2_data(*,3),linestyle=2,color=3
   oplot, findgen(13)+1,geos2_data(*,3),linestyle=2,psym=2,symsize=0.3,color=3 

   oplot, findgen(13)+1,geos3_data(*,3),linestyle=3,color=4
   oplot, findgen(13)+1,geos3_data(*,3),linestyle=3,psym=2,symsize=0.3,color=4 

          ;------------------------------------------------------------------
          ; Prior to 9/23/03:
          ;xyouts,-80,220, mmonth[3], charsize = 1.2, /data, color=1
          ;------------------------------------------------------------------
          xyouts, 1, highval-50, mmonth[3], charsize = 1.2, /data, color=1

; -- plot observed data --

     plot, findgen(13)+1, cmdl_data(*,6), xstyle=1,ystyle=1,$
        title=ltitle,linestyle=0,psym=-5,symsize=0.6, $
        xticks=14, min_val=-900, xrange=[0,14],yrange=[loval,highval],$
        charsize=1.5, xmargin=[3,1], ymargin=[1.5,1],color=1,$
        xtickname=[' ','30S',' ','20S',' ','10S',' ','0',' ','10N',' ','20N',' ','30N',' ']

; Now plot standard deviations
 
      for w = 0, 11 do begin
           errbar = [cmdl_data(w,6)-cmdl_std(w,6),cmdl_data(w,6)+cmdl_std(w,6)]
          oplot,  [w+1,w+1],errbar,$
                 linestyle=0,color=1
       endfor

   oplot, findgen(13)+1,geos_data(*,6),linestyle=1,color=2
   oplot, findgen(13)+1,geos_data(*,6),linestyle=1,psym=2,symsize=0.3,color=2  

   oplot, findgen(13)+1,geos2_data(*,6),linestyle=2,color=3
   oplot, findgen(13)+1,geos2_data(*,6),linestyle=2,psym=2,symsize=0.3,color=3 

   oplot, findgen(13)+1,geos3_data(*,6),linestyle=3,color=4
   oplot, findgen(13)+1,geos3_data(*,6),linestyle=3,psym=2,symsize=0.3,color=4 
   
          ;-------------------------------------------------------------------
          ; Prior to 9/23/03:
          ;xyouts,-80,220, mmonth[6], charsize = 1.2, /data, color=1
          ;-------------------------------------------------------------------
          xyouts, 1, highval-50, mmonth[6], charsize = 1.2, /data, color=1

; -- plot observed data --

loval=0
highval=250
     plot, findgen(13)+1, cmdl_data(*,9), xstyle=1,ystyle=1,$
        title=ltitle,linestyle=0,psym=-5,symsize=0.6, $
        xticks=14, min_val=-900, xrange=[0,14],yrange=[loval,highval],$
        charsize=1.5, xmargin=[3,1], ymargin=[1.5,1],color=1,$
        xtickname=[' ','30S',' ','20S',' ','10S',' ','0',' ','10N',' ','20N',' ','30N',' ']

; Now plot standard deviations
 
      for w = 0, 11 do begin
           errbar = [cmdl_data(w,9)-cmdl_std(w,9),cmdl_data(w,9)+cmdl_std(w,9)]
          oplot,  [w+1,w+1],errbar,$
                 linestyle=0,color=1
       endfor

   oplot, findgen(13)+1,geos_data(*,9),linestyle=1,color=2
   oplot, findgen(13)+1,geos_data(*,9),linestyle=1,psym=2,symsize=0.3,color=2  

   oplot, findgen(13)+1,geos2_data(*,9),linestyle=2,color=3
   oplot, findgen(13)+1,geos2_data(*,9),linestyle=2,psym=2,symsize=0.3,color=3 

   oplot, findgen(13)+1,geos3_data(*,9),linestyle=3,color=4
   oplot, findgen(13)+1,geos3_data(*,9),linestyle=3,psym=2,symsize=0.3,color=4 

          ;----------------------------------------------------------------------
          ; Prior to 9/23/03:
          ;xyouts,-80,220, mmonth[9], charsize = 1.2, /data, color=1
          ;----------------------------------------------------------------------
          xyouts, 1, highval-50, mmonth[9], charsize = 1.2, /data, color=1

xyouts, 0.04, 0.5, 'CO (ppb)', /normal, align=0.5, orientation=90, $
  charsize=1.2,color=1
xyouts, 0.5, 0.94, title, /normal, align=0.5, charsize=1.2,color=1
close_device, /TIMESTAMP

close, /all

end


