pro getpress,date,dat,pressures=plev,press,datsrf,err,hemis=hemis,mask=mask $
    ,linear=linear,prs=pr,more=more, old=old, source=source,lat=lat         $
    ,lon=lon,sequence=sequence, grid=grid, format=format,forecast=forecast  $
    ,special=specialcode, carefull=carefull, bad=bad
 
      

;+
; NAME:
;   getpress
; PURPOSE:
;   interpolates a 3D data field (on pressure surfaces) to an arbitrary pressure sfc
; CATEGORY:
;   nmc, interpolation
; CALLING SEQUENCE:
;   getpress,date,dat,plev,press,datsrf,err,hemis
;     (or, for multiple inteprolations, )
;   getpress,date,dat,plev,press,datsrf,err,hemis,prs=pr
;   getpress,date, dat2, plev,press, datsrf2, err,hemis,prs=pr,/more
; INPUTS:
;   date = 'yymmdd' date string
;   dat = 3D (longitude, latitude, pressure) array of data
;     **OR**
;       if dat is a string, then it is used as a dtype code for nmcread
;       to read an NMC data array to be interpolated.
;       And then the variable dat is replaced by the data array dat.
;   press = value (or vector of values) of the pressure 
;           surface onto which dat is to be interpolated.
; OPTIONAL INPUT PARAMETERS:
; KEYWORD PARAMETERS:
;   plev = vector of pressure levels of dat.  The default is a vector
;          of the standard pressure levels from stdplev.  The length
;          of this vector must corrspond to the thrid dimension of dat.
;   hemis = 0 for global, -1 for Southern hemisphere, +1 for Northern hem.
;          default is curhem().
;   mask = value to be placed at gridpoint for which interpolation is not
;          possible.  default is 0.
;   /linear = flag specifiying that linear interpolation is to be done
;          instead of cubic splines.  Note: this is quick and dirty,
;          and hence is risky.
;   prs = the array of pressure values to be used. If /more is NOT set, then
;         pls is created and filled in with values from the vector plevs
;         (above), and pls is returned as output.  If /more IS set, then
;         this step is skipped (i.e., assumed already to have been done
;         in a previous call) and plevs is ignored.
;   /more = if set, then the array thetas is INPUT and used instead of
;           used and OUTPUT.
;   /old     = obsolete and ignored
;   source   = the source of the data:
;               'NMC' = NMC data 
;   sequence = sequence code string (this indicates, for example, which
;               run of a model is desired-'CLEAR' versus 'CLOUDY', for example.)
;               default is '00'.
;   grid     = the grid code for the file desired (default: no grid code)
;   format   = the format_field
;   forecast = the number-of-hours-in-advance of a forecast (0=analysis, not
;              forecast)
;   /carefull = if set, then the vertical interpolation will be done one gridpoint at
;              a time, with bad-data flags accounted for.
;   bad = bad-data flag for the data array, if supplied
; OUTPUTS:
;   datsrf = the data from dat interpolated to the theta surface.
;            (if press is a vector, then datsrf will be a 3D array, with
;            the third dimension correspondinf to elements of press.)
;   err = 0 if all went well.  ne 0 if error in reading nmc data
; OPTIONAL OUTPUT PARAMETERS:
;   dat: if the input dat is a string, the output dat is an NMC data array.
; COMMON BLOCKS:
; SIDE EFFECTS:
; RESTRICTIONS:
; PROCEDURE:
;    a spline interpolation is done using log-pressure as the independent 
;    variable.
; REQUIRED ROUTINES:
;    curhem, spline3d, splprep3d, nmctrd, stdplev, nmcread, linear3d
; MODIFICATION HISTORY: 
;    idlv2 (lrl) 9007??
;    lrlait 910218 added linear flag
;    lrlait adapted getpress from gettheta
;    pan    910612 added nmcread keywords
;    $Header: //getpress.pro,v 1.12 1997/01/24 13:43:58 lait Exp $
;-

if n_elements(plev) eq 0 then plev = stdplev(0)
if n_elements(mask) eq 0 then mask = 0.
if n_elements(hemis) eq 0 then hemis = curhem(0)
if n_elements(linear) eq 0 then linear = 0

nopad = 1
if keyword_set(carefull) then nopad=0

; if a string data code is specified, get the data
sz1 = size(dat)
if sz1(n_elements(sz1)-2) eq 7 then begin
   dtype = dat
;;   nmcread,dtype,date,hemis,dat,lon,lat,plev,err,gotp
   nmcread,dtype,date,hemis,dat,lon,lat,plev,err,gotp,source=source   $
          , sequence=sequence, grid=grid,format=format,forecast=forecast      $
          , special=specialcode,file=fname,nopad=nopad,bad=bad
   if err lt 0 then begin
      message,' cannot get data for '+dtype+' on '+date
      return
   endif
endif

if keyword_set(carefull) then begin

      zp = alog(1000.0/ plev )
      zpress = alog(1000.0/press)

      sz = size(dat)
      datsrf = fltarr(sz(1),sz(2)) + mask
      for jj=0,sz(2)-1 do begin
         for ii=0,sz(1)-1 do begin
             zzz = zp
             ddd = reform(dat(ii,jj,*))
             ok = where(ddd ne bad)
             if ok(0) ne -1 then begin
                zzz = zzz(ok)
                ddd = ddd(ok)
                if (zpress ge min(zzz)) and (zpress le max(zzz)) then begin
                   if not linear then begin
                      splprep1d,ddd,zzz,100000,100000,y2
                      spline1d,ddd,zzz,y2,zpress,dval,ddat_dz,mask
                   endif else begin
                      up = min( where( zzz ge zpress) )
                      dn = max( where( zzz le zpress) )
                      if up eq dn then begin
                         dval = ddd(up)
                      endif else begin
                         dval = (zpress-zzz(dn))/(zzz(up)-zzz(dn))*(ddd(up)-ddd(dn)) + ddd(dn)
                      endelse
                   endelse

                   datsrf(ii,jj) = dval

                endif
             endif
         endfor
      endfor

endif else begin

   if not keyword_set(more) then begin
      sz1 = size(dat)
      prs = make_array( size=sz1, /float )
      layer = prs(*,*,0)
      npl = n_elements(plev)
      for i = 0, npl-1 do prs(0,0,i) = layer + alog(1000./plev(i))
   endif

   ; interpolate dat directly onto the theta surface
   if not linear then begin
      splprep3d,dat,prs,100000,100000,y2
      spline3d,dat,prs,y2,alog(1000./press),datsrf,mask
   endif else begin
      linear3d,dat,prs,alog(1000./press),datsrf,mask  ; ,/fast
   endelse

endelse

end
