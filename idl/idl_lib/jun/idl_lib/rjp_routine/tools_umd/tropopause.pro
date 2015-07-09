pro tropopause,indate,hour,exp,trpps,pttrpps,eptrpps $
	,epval=epval,ptval=ptval,maxplev=maxplev $
	,writedf=writedf,fcst=fcst,b4=b4,special=special $
	,grid=grid,lon=lon,lat=lat,badval=badval,err=err $
	,indir=indir,outdir=outdir
;+
; NAME:
;	tropopause
; PURPOSE:
;	To estimate tropopause pressure from the potential vorticity
;	field and create df file
; CATEGORY:
;	General Utility
; CALLING SEQUENCE:
;	pro tropopause,date,hour,exp,trpps,epval=epval,ptval=ptval $
;		,writedf=writedf,fcst=fcst,b4=b4,special=special,indir=indir $
;		,grid=grid,lon=lon,lat=lat,badval=badval,err=err,outdir=outdir
; INPUT PARAMETERS:
;	date	= Date desired
;	hour	= Hour desired
;	exp	= Experiment (sequence) number ('nmc' allowed)
;	epval	= EPV value to use to determine tropopause (default .25e-5)
;	ptval	= Potential temp value to use to determine tropopause (default 380)
; INPUT KEYWORDS:
;	writedf	= set nonzero to write out df file (only for assim data)
;	fcst	= sent to df_read to determine input files for calculation
;	b4	= sent to df_read to determine input files for calculation
;	special	= sent to df_read to determine input files for calculation
;	indir	= sent to df_read to determine input files for calculation
;	grid	= sent to df_read to determine input files for calculation
;	outdir	= directory to write df file into (/science/asm/data/ is default)
; OUTPUT PARAMETERS:
;	trpps	= 2d array of tropopause pressure
; OUTPUT KEYWORDS:
;	lon	= longitudes of trpps grid
;	lat	= latitudes of trpps grid
;	badval	= bad flag values of trpps grid
;	err	= error return - nonzero is bad
; COMMON BLOCKS:
;	None
; SIDE EFFECTS:
;	None known.
; RESTRICTIONS:
;	None known.
; PROCEDURE:
;	
; REQUIRED ROUTINES:
;	/home/steenrod/idl/df_read.pro /science/execute/nmc_met_fields/nmcw3d
; MODIFICATION HISTORY:
;	Stephen D. Steenrod - May 1993 - written
;	Stephen D. Steenrod - Mar 1996 - upgraded to give better field
;-
;print,'************  This is still under construction...   ************'

if(n_params() lt 2) then begin
  print,'pro tropopause,date,hour,exp,trpps,pttrpps,eptrpps $'
  print,'	,epval=epval,ptval=ptval,maxplev=maxplev $'
  print,'	,writedf=writedf,fcst=fcst,b4=b4,special=special $'
  print,'	,grid=grid,lon=lon,lat=lat,badval=badval,err=err $'
  print,'	,indir=indir,outdir=outdir'
  return
 end

if(n_elements(outdir) eq 0) then outdir = '/science/asm/data/'
if(n_elements(epval) eq 0) then epval = .25e-5
if(n_elements(ptval) eq 0) then ptval = 380
if(n_elements(writedf) eq 0) then writedf = 0
;if(n_elements(b4) eq 0) then fcst = 0 else fcst = 6
if(n_elements(fcst) eq 0) then fcst = 0
if(n_elements(grid) eq 0) then grid='GG1X1'
;if(indate gt 1000000) then date = indate-19000000 else date = indate
;if(indate gt 1000000) then date = indate-1000000 else date = indate
date = indate
;... assume tropopause is between maxplev and minplev
if(n_elements(maxplev) eq 0) then maxplev = 500.
minplev = 10


tfcst = fcst
;... set up parameters for 'nmcread'
if(strlowcase(exp) eq 'nmc') then begin
  dffld = 'EPBL'
  writedf = 0		; not allowed to write out for nmc calculation
  end $
 else dffld = 'EPV_'
if(strlowcase(exp) eq 'ukmo') then writedf = 0
if(strlowcase(exp) eq 'gsmm') then writedf = 0

;... get Temp data
t = df_read(exp,'t',date,hour,lon=lon,lat=lat,plev=tplev,grid=grid $
	,fcst=tfcst,badval=tbadval,special=special,indir=indir,err=err)
if(err ne 0) then begin
  print,'ERROR: reading T: ',date,hour
  print,' T data set probably not found'
  stop
 end
t = t_to_pottemp(t,tplev,badval=tbadval)

;... get EPV data
epv = df_read(exp,dffld,date,hour,lon=lon,lat=lat,plev=plev,grid=grid $
	,fcst=fcst,badval=badval,err=err,special=special,indir=indir)
if(err ne 0) then begin
  print,'ERROR: reading EPV: ',date,hour
  print,' EPV data set probably not found'
  stop
 end
if(tfcst(0) ne fcst(0)) then print, 'In calculation of tropopause pressure' $
  ,' - T and EPV are different forecast hours'
;... assuming data is on regular grid
dvalue0 = [lon(0),lon(1)-lon(0)]
dvalue1 = [lat(0),lat(1)-lat(0)]

h = size(epv)
trpps = fltarr(h(1),h(2))
pttrpps = fltarr(h(1),h(2))
indgd = where(plev le maxplev and plev ge minplev)
tindgd = where(plev le maxplev and plev ge minplev)
plev = plev(indgd)
tplev = tplev(tindgd)

logplev = alog(plev)
logtplev = alog(tplev)
alog100 = alog(100)

for j=0,h(2)-1 do for i=0,h(1)-1 do begin
  temp = abs(reform(epv(i,j,indgd)))
;... take care of some badly calculated values from early files
  ind = where(temp gt 1,cnt)
  if(cnt gt 0) then temp(ind) = badval
;... take care of badvals
  ind = where(temp ne badval,cnt)
  temp = temp(ind)
  tmpplev = plev(ind)
  n = where(temp le epval and temp(1:*) gt epval)
  if(n(0) ge 0) then begin
    y1 = tmpplev(n(0))
    x1 = temp(n(0))
    trpps(i,j) = y1+((tmpplev(n(0)+1)-y1)/(temp(n(0)+1)-x1))* $
	(epval-x1)
    end $
   else trpps(i,j) = badval

;... find pressure of 380K surface
  temp = abs(reform(t(i,j,indgd)))
;... take care of badvals
  ind = where(temp ne tbadval,cnt)
  temp = temp(ind)
  tmpplev = tplev(ind)
  n = where(temp le ptval and temp(1:*) gt ptval)
  if(n(0) ge 0) then begin
    y1 = tmpplev(n(0))
    x1 = temp(n(0))
    pttrpps(i,j) = y1+((tmpplev(n(0)+1)-y1)/(temp(n(0)+1)-x1))* $
	(ptval-x1)
    end $
   else pttrpps(i,j) = badval

 end

;... fix up bad points (usually tropics) using potential temp - 
eptrpps = trpps
ind = where(pttrpps ge trpps,cnt)
if(cnt gt 0) then trpps(ind) = pttrpps(ind)
  
;... write out into df file if desired
if(writedf ne 0) then begin

  deg = 1745355010
  source = 'ASM'
  seq = exp
   
  unittype = 1081593921
  field = 'PTRP'
  dname = ['LON_','LAT_','EPV_']
  dunit = [1745355010,1745355010,1626922240]
  
  daohead,dummy,xdr=xdr
  if(h(1) eq 72 and h(2) eq 46) then grid = 'GG5X4' $
   else if(h(1) eq 144 and h(2) eq 91) then grid = 'GG2%5X2' $
    else if(h(1) eq 72 and h(2) eq 91) then grid = 'GG5X2' $
    else if(h(1) eq 360 and h(2) eq 181) then grid = 'GG1X1' $
     else begin
       print,'Unknown grid dimensions... not 2x2.5 or 4x5 or 2x5'
       print,' the dims are: ',h(1),h(2)
       return
      end

  audit = df_make_audit(task=134218000,audepv)

  trpps = reform(trpps,[h(1),h(2),1])

  if(fcst(0) ne 0) then fore = 'FH'+strtrim(fcst(0),2)
;... call nmcw3d to put data into df
  dir = outdir+'/'+grid+'/Y'+strmid(strtrim(date,2),0,4) $
	+'/M'+strmid(strtrim(date,2),4,2)+'/'
  tpdate = string(date-(1000000*fix(date/1000000)),'(i6.6)')
  err2 = nmcw3d(dir,field,source,tpdate+string(hour,'(i2.2)'),audit,trpps,badval $
	,unittype,dname,dunit,dvalue0,dvalue1,epval,grid=grid $
	,seq=seq,fname=fname,fore=fore,pack_type=1)

  if(not err2) then print,dir+'/'+fname
 end
return
end
