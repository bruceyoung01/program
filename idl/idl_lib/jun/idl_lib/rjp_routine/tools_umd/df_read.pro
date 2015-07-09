function df_read,texp,field,date,time,doplev=doplev $
	,fcst=fcst,forecast=forecast,grid=grid,indir=indir,special=special $
	,lon=lon,lat=lat,plev=plev,badval=badval,err=err,quiet=quiet $
	,cubic=cubic,thplev=thplev,theta=theta,field_units=field_units $
	,fname=fname,audit=audit,field_sym=field_sym,mon_mean=mon_mean
;+
; NAME:
;	df_read
; PURPOSE:
;	reads in data from df files (uses nmdr3d)
; CATEGORY:
;	df i/o utility
; CALLING SEQUENCE:
;	arr = df_read,texp,field,date,time,doplev=doplev $
;	,fcst=fcst,forecast=forecast,grid=grid,indir=indir,special=special $
;	,lon=lon,lat=lat,plev=plev,badval=badval,err=err,quiet=quiet $
;	,cubic=cubic,thplev=thplev,theta=theta,field_units=field_units $
;	,fname=fname,audit=audit,field_sym=field_sym,mon_mean=mon_mean
; INPUT PARAMETERS:
;	exp	= experiment number or 'nmc'
;	field	= type of data to access
;	date	= beginning date - form:  yymmdd
;	time	= beginning hour for sequence ( default is 00 UTZ)
; OPTIONAL INPUT PARAMETERS:
; KEYWORDS (INPUT):
;	doplev	= limit what pressures to return (default all)
;	fcst	= what hour forecast fields (0 is analysis - default)
;	forecast= forecast string in df filenames - needed for FH6 files, otherwise
;		  the first guess will be accessed
;	grid	= resolution desired - default is first one in ls
;	indir	= directory where input df files can be found 
;		  (default: $ASMDAT)
;	special = special string in df filenames (ie 'FG')
;	quiet   = don't print informational messages
;	theta   = have program return data on a theta surface 
;	cubic   = use cubic spline for interp to theta
;	thplev  = pressure of theta surface
; KEYWORDS (OUTPUT):
;	lon	= longitude points of output grid
;	lat	= latitude points of output grid
;	plev	= pressure levels of output grid
;	field_units= string indicating units of field (ie meters per second)g
;	badval	= missing data flag
;	err	= return code
; OUTPUT PARAMETERS:
; OPTIONAL OUTPUT PARAMETERS:
; COMMON BLOCKS:
;	None
; SIDE EFFECTS:
;	None known
; RESTRICTIONS:
;	None known.
; PROCEDURE:
;	Convoluted
; REQUIRED ROUTINES:
;	nmcr3d, uars_typconv, t_to_pottemp, asm_on_theta
; MODIFICATION HISTORY:
;	Stephen D. Steenrod - April 1993, written
;-

err = 0
if(n_params() lt 4) then begin
  print,'arr = df_read,texp,field,date,time,doplev=doplev $'
  print,',fcst=fcst,forecast=forecast,grid=grid,indir=indir,special=special $'
  print,',lon=lon,lat=lat,plev=plev,badval=badval,err=err,quiet=quiet $'
  print,',cubic=cubic,thplev=thplev,theta=theta,field_units=field_units $'
  print,',fname=fname,audit=audit,field_sym=field_sym,mon_mean=mon_mean'
  return,0
 end

exp = strupcase(texp)
if(n_elements(indir) eq 0) then dir = ''  else dir = indir+'/'
if(n_elements(fcst) eq 0) then fcst = 0
if(n_elements(forecast) ne 0) then fcst = forecast
if(n_elements(mon_mean) eq 0) then mon_mean = 0
if(n_elements(special) ne 0) then tspecial = special
;... set default grid
if(n_elements(grid) eq 0) then begin
  case exp of
   'NMC': grid = 'GG5X2'
   'UKMO': grid = 'GG3%75X2%5'
   else: $
      if((date ge 991101 and date le 1000000) or (date ge 19991101)) then $
        grid = 'GG1X1' $
       else $
        grid = 'GG2%5X2'
   endcase
 end


;... read in one record to set up space
dffld = uars_typconv(field)

;if(long(date) ge 1000000 or long(date) le 10000) then begin
;  print,'ERROR in date specification in df_read.pro: ', date
;  help,date
;  err = -2
;  return,0
; end

if(long(date) lt 1000000) then $
  if(long(date) ge 580000) then date = '19'+strtrim(date,2) $
   else date = '20'+strtrim(date,2)

if(n_elements(theta) ne 0) then $
  return,asm_on_theta(texp,field,date,time,theta,fcst=fcst,grid=grid $
    ,special=special,dir=indir,cubic=cubic,badval=badval,thplev=thplev $
    ,lon=lon,lat=lat,err=err) $
 else begin

   strdate = strtrim(date,2)
   ymstr = '/Y'+strmid(strdate,0,4)+'/M'+strmid(strdate,4,2)+'/'
;... get rid of 4 digit year
   strdate = strmid(strdate,2,6)

   ttime = string(time,'(i2.2)')
   pretime = 'I'

;... set up parameters for 'nmcr3d'
   case strlowcase(exp) of
     'nmc': begin
        source = 'nmc'
        exp = '01'
        ttime = '12'
        if(dir ne '') then dir = dir+'/'+grid+'/'+ymstr $
         else dir = getenv('NMCDAT')+'/'+grid+'/'+ymstr
        end
     'ukmo': begin
        source = 'ukm'
        exp = '01'
        ttime = '12'
        if(dir ne '') then dir = dir+'/'+grid+'/'+ymstr $
         else dir = getenv('UKMDAT')+'/'+grid+'/'+ymstr
        end
     'ctm': begin
        source = 'sgc'
        exp = '01'
;        if(dir ne '') then dir = dir+dffld+ymstr $
;          else dir = '/science/chemtran/data/'+dffld+ymstr
        if(dir ne '') then dir = dir+ymstr $
          else dir = '/science/chemtran/data/'+ymstr
        end
     'gsmm': begin
        source = 'sgc'
        exp = ''
        special = '*'+ttime+'00'
        ttime = 'XX'
        pretime = 'N'
        if(dir ne '') then dir = dir+ymstr $
          else dir = '/science/gsmm/data/'+ymstr
        end
     'sgc': begin
        source = 'sgc'
        exp = '01'
        if(dir ne '') then dir = dir+dffld+ymstr $
          else dir = '/science/chemtran/data/'+dffld+ymstr
        end
     'cdb': begin
        source = 'cdb'
        exp = ''
;        if(n_elements(special) eq 0) then special = 'SCLEAR'
;        if(n_elements(grid) eq 0) then grid = 'GG5X2'
        if(dir ne '') then dir = dir+dffld+ymstr $
          else dir = '/science/radiation/data/'+ymstr
        end
     else: begin
        source = 'asm'
        if(dir eq '') then dir = getenv('ASMDAT')+'/'+grid+'/'+ymstr $
          else dir = dir+'/'+grid+'/'+ymstr
     endcase
    end
   
   if(mon_mean ne 0) then begin
     pretime = 'D'
     strdate = strmid(strdate,0,4)
     date = strmid(strdate,0,4)+'00'
     ttime = ''
    end

   chckfn = dir+dffld+pretime+strdate+ttime+'*'+grid+'*'+exp+'*'
   spawn,'ls '+chckfn,newfn

;   check,chckfn
;   check,newfn
;   print,newfn
;stop
;... patch in old convention that 6 hour forecast is first guess
;   if(fcst eq 6) then begin
;     fcst = 0
;     special = 'FG'
;    end

;... if a list of file exists, find the correct one
   if(newfn(0) ne '') then begin

     witch = 0
     if(n_elements(newfn) eq 1) then begin
       dum1 = strpos(newfn(0),'_F',0)
       dum2 = strpos(newfn(0),'_',dum1+1)
       if(dum2 le 0 ) then dum2 = strpos(newfn(0),'.',dum1+1)
       if(dum1 gt 0) then forecast = strmid(newfn(0),dum1+1,dum2-dum1-1) $
         else forecast = ''
;... find special value
       dum1 = strpos(newfn(0),'_S',0)
       dum2 = strpos(newfn(0),'_',dum1+1)
       if(dum2 le 0 ) then dum2 = strpos(newfn(0),'.',dum1+1)
       if(dum1 gt 0) then special = strmid(newfn(0),dum1+2,dum2-dum1-2) $
         else special = ''
;... find grid value
       dum1 = strpos(newfn(0),'_G',0)
       dum2 = strpos(newfn(0),'_',dum1(0)+1)
       if(dum2 le 0 ) then dum2 = strpos(newfn(0),'.',dum1+1)
       grid = strmid(newfn(0),dum1(0)+1,dum2(0)-dum1(0)-1)
;... find exp number value
       dum1 = strpos(newfn(0),'_E',0)
       dum2 = strpos(newfn(0),'_',dum1(0)+1)
       if(dum2 le 0 ) then dum2 = strpos(newfn(0),'.',dum1+1)
       exp = strmid(newfn(0),dum1(0)+1,dum2(0)-dum1(0)-1)
       end $
;... more that one file qualifies so far... eliminate some?
      else begin
        which = 0
;... find exp number value
        if(strlowcase(exp) eq 'asm') then begin
          dum1 = strpos(newfn(which),'_E',0)
          dum2 = strpos(newfn(which),'_',dum1(0)+1)
          if(dum2 le 0) then dum2 = strpos(newfn(which),'.',dum1+1)
          exp = strmid(newfn(which),dum1(0)+1,dum2(0)-dum1(0)-1)
          end $
         else begin
           dum1 = strpos(newfn,'_E'+exp,0)
           ind = where(dum1 ne -1,cnt)
           if(cnt gt 0) then newfn = newfn(ind(0))
           dum1 = strpos(newfn(0),'_E',0)
           dum2 = strpos(newfn(0),'_',dum1(0)+1)
           if(dum2 le 0) then dum2 = strpos(newfn(0),'.',dum1+1)
           exp = strmid(newfn(0),dum1(0)+1,dum2(0)-dum1(0)-1)
         end
;... find grid value
        if(grid eq '*') then begin
          dum1 = strpos(newfn(witch),'_G',0)
          dum2 = strpos(newfn(witch),'_',dum1(0)+1)
          grid = strmid(newfn(witch),dum1(0)+1,dum2(0)-dum1(0)-1)
          end $
         else begin
           dum1 = strpos(newfn,'_G'+grid,0)
           ind = where(dum1 ne -1,cnt)
           if(cnt gt 0) then newfn = newfn(ind)
         end
;... find value of forecast hour
        if(n_elements(fcst) eq 0) then $
          if(fcst(0) ne 0) then begin
            sdum1 = 'FH'+strtrim(fcst(0),2)+'_'
            dum1 = strpos(newfn,sdum1,0)
            witch = where(dum1 ge 0,cnt)
            if(cnt eq 0) then witch = 0
            dum1 = strpos(newfn(witch),'_F',0)
            dum2 = strpos(newfn(witch),'_',dum1(0)+1)
            forecast = strmid(newfn(witch),dum1(0)+1,dum2(0)-dum1(0)-1)
            fcst = fix(strmid(newfn(witch),dum1(0)+3,dum2(0)-dum1(0)-3))
           end $
          else forecast = ''
;... find special value
        if(n_elements(special) eq '') then begin
          dum1 = strpos(newfn(0),'_S',0)
          dum2 = strpos(newfn(0),'_',dum1+1)
          if(dum2 le 0 ) then dum2 = strpos(newfn(0),'.',dum1+1)
          if(dum1 gt 0) then special = strmid(newfn(0),dum1+2,dum2-dum1-2) $
            else special = ''
          end $
         else begin
           dum1 = strpos(newfn,'_S'+special,0)
           ind = where(dum1 ne -1,cnt)
           if(cnt gt 0) then newfn = newfn(ind)
         end
;         stop
       end

;... if texp input with '_' then reassign exp to texp
     dum2 = strpos(texp,'_',0)
     if(dum2 ne -1) then begin
       if(strmid(texp,dum2+1,1) eq 'S') then $
         if(n_elements(tspecial) eq 0) then special = '' $
           else special = tspecial
       exp = texp
      endif

;... make scalars
     forecast = fcst(0)
     grid = grid(0)
     date = strtrim(date,2)
     if(strupcase(source) eq 'CDB') then begin
     
       err = 999
       n = 0
       while(err ne 0 and n lt 2) do begin
       err = nmcr3d(dir,dffld,source,strdate+ttime,arr $
        ,badval,dims,grid=grid,unit=unit,audit=audit $
        ,special=special,avespec=pretime,sup1=sup1 $
        ,dim_q=dimq,dim_u=dimu,dim0=lon,dim1=lat,dim2=plev,fname=fname)
         if(err ne 0) then wait,5
         n = n+1
        end
       end $
      else begin
       err = 999
       n = 0
       while(err ne 0 and n lt 2) do begin
         err = nmcr3d(dir,dffld,source,strdate+ttime,arr $
	   ,badval,dims,grid=grid,fore=forecast,seq=exp,unit=unit $
	   ,special=special,avespec=pretime,sup1=sup1,audit=audit $
	   ,dim_q=dimq,dim_u=dimu,dim0=lon,dim1=lat,dim2=plev,fname=fname)
         if(err ne 0) then wait,5
         n = n+1
        end
      end
     if(err ne 0) then begin
       print,'Used: ',dir+'/'+fname
       return,err
      end
     if(not keyword_set(quiet)) then print,'Used: ',dir+'/'+fname
  
;... fix up mechanistic model data plevs and lats to my convention
     if(strlowcase(texp) eq 'gsmm') then begin
       plev = plev*sup1(0)/100.
       ind = where(lon lt 0,cnt)
       if(cnt gt 0) then lon(ind) = lon(ind)+360
       if(lat(0) gt lat(1)) then begin
         lat = reverse(lat)
         arr = reverse(arr,2)
        end
      end

;... limit number of plevs returned
   case n_elements(doplev) of
     0: ind = indgen(n_elements(plev))
     1: ind = where(doplev eq plev)
     else: ind = in(doplev,plev)
     end
   if(ind(0) eq -1) then return,-998
   arr = arr(*,*,ind)
   plev = plev(ind)

;... some of the epv for assim was not created correctly - fix
     if(strlowcase(dffld) eq 'epv_') then begin
       wind = where(abs(arr) gt 1 and arr ne badval,wcnt)
       if(wcnt gt 0) then arr(wind) = badval
      end

     if(strlowcase(field) eq 'mepv' or strlowcase(field) eq 'mepbl') then begin
       if(not keyword_set(quiet)) then print,'Converting to modified potential vorticity'
       theta0 = 500
       if(strlowcase(source) eq 'ctm' or strlowcase(source) eq 'sgc') then $
         dir = '/science/chemtran/data/'+'T___'+ymstr
       err = 999
       n = 0
       while(err ne 0 and n lt 2) do begin
         err = nmcr3d(dir,'T___',source,strdate+ttime,temp,tbadval,audit=audit $
	   ,tdims,grid=grid,fore=forecast,seq=exp,unit=unit,special=special $
	   ,dim_q=dimq,dim_u=dimu,dim0=tlon,dim1=tlat,dim2=tplev,fname=fname)
         if(err ne 0) then wait,5
         n = n+1
        end
       if(not keyword_set(quiet)) then print,'Used: ',dir+'/'+fname

;... limit number of plevs returned
       case n_elements(doplev) of
         0: ind = indgen(n_elements(tplev))
         1: ind = where(doplev eq tplev)
         else: ind = in(doplev,tplev)
         end
       if(ind(0) eq -1) then return,-998
       temp = temp(*,*,ind)
       tplev = tplev(ind)

       sz = size(arr)
       sz2 = size(temp)
       ind = where(sz ne sz2,cnt)
       if(cnt eq 0) then nl = sz(3)  else stop,'Dims of temp and epv do not match'
       temp = t_to_pottemp(temp,tplev,badval=tbadval)
       ind = where(temp eq tbadval or arr eq badval,cnt)
       arr = arr*((temp/theta0)^(-9./2.))
       if(cnt gt 0) then arr(ind) = badval
      end
     end $
    else begin
      print,'ERROR: : ',source,exp,field,strdate,time
      print,' Data set probably not found in ',chckfn
; stop
      err = 999
      return,999
    end
;df_trans_var,num=dimq(0),sh=sh0,lo=lo0
;df_trans_var,num=dimq(1),sh=sh1,lo=lo1
;df_trans_var,num=dimq(2),sh=sh2,lo=lo2
;df_trans_unit,num=dimu(0),na=na0
;df_trans_unit,num=dimu(1),na=na1
;df_trans_unit,num=dimu(2),na=na2
df_trans_unit,num=unit,na=field_units,symb=field_sym
;stop
   return,arr
  end
end
