; nmax=500L   ;max number of sites (actually, instruments)
; imax=365L*24L
nmax=500L   ;max number of sites (actually, instruments)
imax=366L*5L
vmax=100L

odir='./Output/'
odir_image='./Output/'
;otimes=[2000,2001,2002,2003,2004]
otimes=[2004]

ifile='./Dec0704_daily_all_epaspec_data.csv'
siteinfofile='./Header_Information_of_epaspec_data.csv'
label='PM25_Spec'
statsfil='pm25_spec_'

sitecount=lonarr(nmax)
siteid=strarr(nmax)
sitename=strarr(nmax)
sitestate=strarr(nmax)
sitelon=fltarr(nmax)
sitelat=fltarr(nmax)
gmtoff=fltarr(nmax)
sitepop=lonarr(nmax)
sitesize=lonarr(nmax)
sitereg=strarr(nmax)
sitemsacode=strarr(nmax)
sitemsadesc=strarr(nmax)
sitemsapop=strarr(nmax)

data=-999.+fltarr(nmax,imax,vmax)
year=fltarr(nmax,imax)
jday=fltarr(nmax,imax)
gmt =fltarr(nmax,imax)
qualflags=['']

;read site/timezone lookup table
nwxp=0L
dum=' '
close,1
openr,1,'./state_county_timezone_table.dat'
readf,1,nwxp
state_county_code=strarr(nwxp)
utc_offset=fltarr(nwxp)
wxpsitename=strarr(nwxp)
wxppop=lonarr(nwxp)
wxpsize=lonarr(nwxp)
epareg=strarr(nwxp)
readf,1,dum
for n=0,nwxp-1 do begin
  readf,1,dum
  dum=strcompress(dum)
  readline=str_sep(strtrim(dum,2),' ')
  state_county_code(n)=readline(0)
  utc_offset(n)=float(readline(1))
  wxpsitename(n)=readline(4)+' '+readline(5)
  wxppop(n)=round(float(readline(6)))
  wxpsize(n)=round(float(readline(7)))
  epareg(n)=readline(8)
endfor
close,1

;read EPA site info file (lat, lon, msa)
maxsite=20000L
openr,1,siteinfofile
readf,1,dum
siteinfonames=str_sep(strtrim(dum,2),',')
psite=where(siteinfonames eq 'airs_site_code')
psite=psite(0)
ppoc=where(siteinfonames eq 'POC')
ppoc=ppoc(0)
plon=where(siteinfonames eq 'LONGITUDE')
plon=plon(0)
plat=where(siteinfonames eq 'LATITUDE')
plat=plat(0)
pmsa=where(siteinfonames eq 'MSA')
pmsa=pmsa(0)
pmsaname=where(siteinfonames eq 'MSA_NAME')
pmsaname=pmsaname(0)
infositeid=strarr(maxsite)
infolon=fltarr(maxsite)
infolat=fltarr(maxsite)
infomsa=strarr(maxsite)
infomsaname=strarr(maxsite)
ninfo=0L
while not eof(1) do begin
  readf,1,dum
  ; Remove commas that are text rather than delimiters
  checkquotes:
  quotes1=strpos(dum,'"')
  if quotes1 gt -1 then begin
    strput,dum,' ',quotes1
    quotes2=strpos(dum,'"',quotes1)
    if quotes2 eq -1 then stop,'problem with quoted string in input'
    strput,dum,' ',quotes2
    temp=strmid(dum,quotes1,quotes2-quotes1+1)
    checkcomma:
    comma=strpos(temp,',')
    if comma gt -1 then begin
      strput,temp,' ',comma
      goto,checkcomma
    endif
    strput,dum,temp,quotes1
    goto,checkquotes
  endif
  dataline=str_sep(strtrim(dum,2),',')
  dataline=strtrim(dataline,2)
  dataline=strcompress(dataline)
  infositeid(ninfo)=dataline(psite)+'-'+dataline(ppoc)
  infolon(ninfo)=dataline(plon)
  infolat(ninfo)=dataline(plat)
  infomsa(ninfo)=dataline(pmsa)
  infomsaname(ninfo)=dataline(pmsaname)
  ninfo=ninfo+1L
endwhile
close,1
infositeid=infositeid(0:ninfo-1)
infolon=infolon(0:ninfo-1)
infolat=infolat(0:ninfo-1)
infomsa=infomsa(0:ninfo-1)
infomsaname=infomsaname(0:ninfo-1)
ulist=uniq(infositeid)
infositeid=infositeid(ulist)
infolon=infolon(ulist)
infolat=infolat(ulist)
infomsa=infomsa(ulist)
infomsaname=infomsaname(ulist)
ninfo=n_elements(ulist)

mon=['JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC']
jdaystart=[0.,31.,59.,90.,120.,151.,181.,212.,243.,273.,304.,334.]
jdaystart_ly=[0.,31.,60.,91.,121.,152.,182.,213.,244.,274.,305.,335.]

; Process data file one line at a time
;
n=-1L
instring=' '
close,1
openr,1,ifile
readf,1,instring
print,instring
varname_tmp=str_sep(instring,',')
varname=varname_tmp(4:n_elements(varname_tmp)-1)
nvar=n_elements(varname)
while not eof(1) do begin
  readf,1,instring
  dataline=str_sep(strtrim(instring,2),',')
  var=str_sep(instring,',')
  var=var(4:n_elements(var)-1)
  dataline=strtrim(dataline,2)
  ;Check for new designation of Dade County FL as Miami-Dade
  miamidade=strpos(strmid(dataline(1),0,5),'12086')
  if miamidade gt -1 then begin
    temp=dataline(1)
    strput,temp,'12025'
    dataline(1)=temp
  endif
  thisid=dataline(1)+'-'+dataline(2)  ; id = state/county/site + monitor
  pos=where(siteid eq thisid,count)
  case 1 of
    count eq 0: begin
      n=n+1L
      if n eq nmax then stop,'increase nmax'
      m=n
      siteid(n)=thisid
      ;
      ; Get adjustment to GMT
      thiscounty=strmid(thisid,0,5)
      gpoint=where(state_county_code eq thiscounty,cg)
      if cg eq 1 then begin
        gmtoff(n)=utc_offset(gpoint(0))
        sitename(n)=wxpsitename(gpoint(0))
        sitestate(n)=strmid(sitename(n),0,2)
        sitepop(n)=wxppop(gpoint(0))
        sitesize(n)=wxpsize(gpoint(0))
        sitereg(n)=epareg(gpoint(0))
      endif else begin
        stop,'No match in state_county_timezone_table.dat, '+thiscounty
      endelse
      ;
      ; Get MSA
      mpoint=where(infositeid eq thisid,cg)
      if cg eq 1 then begin
        sitelon(n)=infolon(mpoint(0))
        sitelat(n)=infolat(mpoint(0))
        sitemsacode(n)=infomsa(mpoint(0))
        sitemsadesc(n)=infomsaname(mpoint(0))
        sitemsapop(n)=-999
      endif else begin
        ;stop,'No match in site info file, '+thiscounty
        sitelon(n)=-999
        sitelat(n)=-999
        sitemsacode(n)=-999
        sitemsadesc(n)=-999
        sitemsapop(n)=-999
      endelse
;
      print,fix(n),' ',thisid,sitelon(n),sitelat(n),fix(gmtoff(n)),$
       ' ',sitename(n),' ',sitemsacode(n)
    end
    count eq 1: begin
      m=pos(0)
      ;
      ; Diagnostic check: FYI, determine whether datafiles are grouped by site 
      ; in case a future datafile is too large for all records to fit in core
      ;
      if m ne n then print,'records for site not grouped, ',siteid(m),m,n
    end
    else: stop,'multiple matches found in site table'
  endcase

  i=sitecount(m)
  sitecount(m)=sitecount(m)+1L
  date_split=str_sep(dataline(3),'/')
  tday=date_split(1)
  tmon=date_split(0)
  tyr =date_split(2)
  ;thr =strmid(dataline(3),10,2)
  ;tmin=strmid(dataline(3),13,2)
  vyr =round(float(tyr))
  vday=float(tday)
  ;vhr =float(thr)
  ;vmin=float(tmin)
  ;mindex=where(mon eq tmon)
  ;mindex=mindex(0)
  mindex=long(tmon)-1L
  if vyr mod 4 eq 0 then begin
    day=vday+jdaystart_ly(mindex)
    daymax=366.
  endif else begin
    day=vday+jdaystart(mindex)
    daymax=365.
  endelse
  ;time=vhr+vmin/60.
  time=12.
 
  for ivar=0,nvar-1 do begin
   if ivar eq 1 or ivar eq nvar-1 then begin
    data(m,i,ivar)=0.
   endif else begin 
    data(m,i,ivar)=float(var(ivar))
   endelse
  endfor
  ;if dataline(5) ne '' then begin
  ;  data(m,i)=float(dataline(4))
  ;  ; Check qualifier flags
  ;  if dataline(3) ne '' then begin
  ;    checkit=where(qualflags eq dataline(3),countit)
  ;    if countit eq 0 then qualflags=[qualflags,dataline(3)]
  ;  endif
  ;endif

  fvyr=float(vyr)
  timegmt=time-gmtoff(m)
  case 1 of
    timegmt ge 24.: begin
      gmt(m,i)=timegmt-24.
      day=day+1.
      if day gt daymax then begin
        day=day-daymax
        fvyr=fvyr+1.
      endif
    end
    timegmt lt 0.: begin
      gmt(m,i)=timegmt+24.
      day=day-1.
      if day lt 1. then begin
        day=day+365.
        fvyr=fvyr-1.
        test=round(fvyr) mod 4
        if test eq 0 then day=day+1.
      endif
    end
    else: gmt(m,i)=timegmt
  endcase
  year(m,i)=fvyr
  jday(m,i)=day
endwhile

close,1

nsites=n+1L
maxtimes=max(sitecount)
print,'Number of sites: ',nsites
print,'Max number of times: ',maxtimes
;print,'Kept data for quality flags: ',qualflags

map_set,/contin,/usa,limit=[18,-160,52,-67],title=label+' Monitor Locations'
!psym=2
oplot,sitelon,sitelat
!psym=0

set_plot,'ps'
device,/landscape,filename=odir_image+label+'_sites.ps'
map_set,/contin,/usa,limit=[18,-160,52,-67],title=label+' Monitor Locations'
!psym=2
oplot,sitelon,sitelat
!psym=0
device,/close
set_plot,'x'

sitecount=sitecount(0:n)
siteid=siteid(0:n)
sitelon=sitelon(0:n)
sitelat=sitelat(0:n)
gmtoff=gmtoff(0:n)
sitename=sitename(0:n)
sitestate=sitestate(0:n)
sitepop=sitepop(0:n)
sitesize=sitesize(0:n)
sitereg=sitereg(0:n)
sitemsacode=sitemsacode(0:n)
sitemsadesc=sitemsadesc(0:n)
sitemsapop=sitemsapop(0:n)
data=data(0:n,0:maxtimes-1,0:nvar-1)
year=year(0:n,0:maxtimes-1)
jday=jday(0:n,0:maxtimes-1)
gmt = gmt(0:n,0:maxtimes-1)


; Write out datafiles site by site within each timeperiod grouping

nperiods=n_elements(otimes)
for j=0,nperiods-1 do begin
  nsitesthisyear=0L
  for m=0,n do begin
    thistime=where(year(m,*) eq otimes(j),count)
    if count gt 0 then nsitesthisyear=nsitesthisyear+1L
  endfor
  if nsitesthisyear eq 0 then goto,none_this_year
  close,12
  openw,12,odir+statsfil+strtrim(otimes(j),2)+'_sites.txt'
  printf,12,nsitesthisyear
  printf,12,format='(7x,"Site Longitude  Latitude",7x,"Pop",6x,"Size  St",10x,"County    #good Reg MSA   MSA_Pop MSA_desc")'
;
  oname='_'+label+'_'+strtrim(otimes(j),2)+'_EPA.dat'
  for m=0,n do begin
    thistime=where(year(m,*) eq otimes(j),count)
    if count gt 0 then begin
      test=where(data(m,thistime,*) gt -999.,counttest)
      printf,12,format='(a11,2f10.4,2i10,a20,i9,1x,a2,1x,a4,i10,a45)', $
       siteid(m),sitelon(m),sitelat(m),sitepop(m),sitesize(m), $
       sitename(m),counttest, $
       sitereg(m),sitemsacode(m),long(sitemsapop(m)),strtrim(sitemsadesc(m),2)
      ofile=odir+siteid(m)+'_'+sitestate(m)+oname
      close,11
      openw,11,ofile
      printf,11,siteid(m)
      printf,11,sitename(m)
      printf,11,gmtoff(m),',',sitepop(m),',',sitesize(m),',',' ',',',sitereg(m)
      printf,11,sitemsacode(m),',',sitemsapop(m),',',' ',',',strtrim(sitemsadesc(m),2)
      printf,11,sitelon(m),',',sitelat(m)
      printf,11,count
      for ivar=0,75-1 do printf,11,varname(ivar)
      for ii=0,count-1 do begin
        i=thistime(ii)
        printf,11,format='(f10.2,",",f10.2,",",f10.2,75(",",f10.4))',year(m,i),jday(m,i),gmt(m,i),data(m,i,*)
       endfor
      close,11
    endif
  endfor
  none_this_year:
endfor
close,12
end
