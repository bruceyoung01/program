; $Id: comp_interp_geos_vs_data.pro,v 1.2 2003/12/08 19:34:53 bmy Exp $
pro comp_interp_geos_vs_data, Species,max_sta,ext


; File with information about stations

filest=''
filest=Species+'.stations'
;PRINT, filest
openr, usta, filest, /get_lun
iname_sta=''
ititle_sta=''

; Specify directory with the data (vertical profiles) 

            pre = '/data/eval/aircraft/data/'+species+'/'

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
    ;;print,      iname_sta,                  $
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

; ---  open files ---

ncount=0

; Name for output file
  fileout = 'All.regions.statistics.'+species+ext
  iunit = 50
  openw,iunit,fileout
     printf, iunit, 'region month model bias1 bias2 bias3 bias4 bias5 bias6 bias7 bias8 bias9 bias10 bias11 bias12 bias13 bias14 bias15 bias16 bias17 bias18 range1 range2 range3 range4 range5 range6 range7 range8 range9 range10 range11 range12 range13 range14 range15 range16 range17 range18'

; Loop through the stations

for k = 1, max_sta do begin

ncount=ncount+1
 ;print, 'STATION : ', k
    kk = k-1 
    ix = k
    file=''

    file=pre+strtrim(name_sta(kk),2)
    ;;print, ''
    ;;print, '---', file 
    ;;print, file

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
    gtemin    = fltarr(maxd)
    gtemax    = fltarr(maxd)

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
       gtemin(i-1)    = imin
       gtemax(i-1)    = imax

if (species eq 'PAN' or species eq 'C2H6' or species eq 'HNO3' or species eq 'C3H8' or species eq 'NO') then begin
       gtemean(i-1)   = igtemean/1000
       gtemedian(i-1) = igtemedian/1000
       gtestd(i-1)    = igtestd/1000
       gtemin(i-1)    = imin/1000
       gtemax(i-1)    = imax/1000
endif
    endwhile


    Hk = i
    ;;print, 'value of Hk ', i

    close, ilun
;    spawn, 'rm -f tmpfile'
;    spawn, 'rm -f tmpfile2'


; Station title
    ltitle=''
    ltitle = strtrim(title_sta(kk),2)
 ;;print, ltitle

; If median value < 0, replace with -999
    tmp = pressure(0:Hk-1) 
    ind = where(gtemedian(0:Hk-1) lt 0.)    
    if ind(0) ge 0 then $
    tmp(ind) = -999.

    ind2 = where(gtestd(0:Hk-1) lt 0.)

; -- read geos files --
   xdata=fltarr(18)
   xlevel=fltarr(18)
   A = fltarr(2)
   filef ='' 
   filef =  strtrim(name_sta(kk),2)+ext
   
   ; Now read FILEF from temp/ directory (bmy, 8/13/03)
   filef = 'temp/' + filef
   ;;print,filef

   result = findfile(filef, count = toto)

   pressure=fltarr(18) ;geos
   co_geos=fltarr(18)       ;geos
  
   openr,ix,filef
        for j = 1,18 do begin 
            jx = j - 1
            readf, ix, fpres, fco,format='(f13.3,f13.4)'
            pressure[jx]=fpres
            co_geos[jx]=fco
        endfor

   close,ix

   zz = fltarr(16)
   ZZ = FINDGEN(16) * (!PI*2./16.)
   USERSYM, COS(zz), SIN(zz);  , /FILL

   ;;print, pressure
   ;;print, co_geos


; Now calculate mean bias for geos model

bias_geos=fltarr(18)
bias_geos=[-999.0,-999.0,-999.0,-999.0,-999.0,-999.0,-999.0,-999.0,-999.0,-999.0,-999.0,-999.0,-999.0,-999.0,-999.0,-999.0,-999.0,-999.0]
range_geos=fltarr(18)
range_geos=[-999,-999,-999,-999,-999,-999,-999,-999,-999,-999,-999,-999,-999,-999,-999,-999,-999,-999]

for j=0,Hk-1 do begin
if (gtemedian[j] gt 0) then begin 
bias_geos[j]=(co_geos[j]-gtemedian[j])/gtemedian[j]*100
endif
;print, bias_geos[j],co_geos[j],gtemedian[j] 
if ((co_geos[j] ge gtemin[j]) and (co_geos[j] le gtemax[j])) then begin
range_geos[j]=1
endif else begin
range_geos[j]=0
endelse

endfor

;;print, bias_geos,format='(18(f7.2,2x))'
;;print, range_geos,format='(18(f7.2,2x))'
    printf, iunit, name_sta(kk),month(kk),'geos',bias_geos,range_geos,format='(a27,1x,i2,1x,a6,1x,18(f7.2,1x),18(i4,1x))'



endfor 

close, /all

end


