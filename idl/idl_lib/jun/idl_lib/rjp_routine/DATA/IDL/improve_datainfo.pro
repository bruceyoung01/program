
 function improve_datainfo, year=year, SiteName=SiteName, plotmap=plotmap

;   so4 = ammonium sulfate mass - (micrograms per cubic meter)
;   no3 = ammonium nitrate mass - (micrograms per cubic meter)
;    oc = organics mass - (micrograms per cubic meter)
;   lac = light absorbing carbon mass - (micrograms per cubic meter)
; fmass = reconstructed fine mass - (micrograms per cubic meter)

    if N_elements(year) eq 0 then return, 0

    If !D.Name eq 'WIN' then DIR = 'D:\Data\IMPROVE\Raw_data\' else $
        DIR = '/users/ctm/rjp/Data/IMPROVE/Raw_data/'

    file = DIR+'IMPROVE_monthly_'+strtrim(year,2)+'.txt'

    print, '---Read IMPROVE AEROSOL data from '+file


    Info = improve_siteinfo() 
    Infosite = strmid(Info.siteid,0,4)

    Openr,il, file, /get

    Site  = ''
    Code  = 'Code'
    SiteV = strarr(200)
    So4v  = fltarr(200,12)
    No3v  = so4v
    ocv   = so4v
    lacv  = so4v
    soilv = so4v
    kv    = so4v
    fev   = so4v
    fmv   = so4v
    cmv   = so4v

    icount = -1L    
    while (not eof(il)) do begin
      readf, il, Site, mon, so4, no3, oc, lac, soil, k, fe, fm, $
      format='(A4,I3,8f9.3)'

      ip = where(infosite eq site)
      if ip[0] eq -1L then goto, jump1
      if info.lon[ip[0]] lt -130. then goto, jump1

      if N_elements(SiteName) eq 0 then begin
         if (Site ne Code) then begin
            icount = icount + 1L
            Code  = Site
         endif
         loc = icount
      end else begin
         loc = where(SiteName eq Site) 
      end
      
      if (loc(0) ne -1) then begin
          SiteV[loc[0]]       = site
          so4v[loc[0],mon-1]  = so4
          no3v[loc[0],mon-1]  = no3
          ocv [loc[0],mon-1]  = oc
          lacv[loc[0],mon-1]  = lac
          soilv[loc[0],mon-1] = soil
          kv[loc[0],mon-1]    = k
          fev[loc[0],mon-1]   = fe
          fmv[loc[0],mon-1]   = fm
      endif

      jump1:
    endwhile
    free_lun,il

    if N_elements(SiteName) eq 0 then Nsite = icount+1 $
    else Nsite = N_elements(SiteName)

    siteV  = siteV[0:Nsite-1]
    so4v   = so4v[0:Nsite-1,*]
    no3v   = no3v[0:Nsite-1,*]
    ocv    = ocv[0:Nsite-1,*] 
    lacv   = lacv[0:Nsite-1,*]
    soilv  = soilv[0:Nsite-1,*]
    kv     = kv[0:Nsite-1,*]
    fev    = fev[0:Nsite-1,*]
    fmv    = fmv[0:Nsite-1,*]

    Info = improve_siteinfo()
    
    Lon  = fltarr(Nsite)
    Lat  = Lon
    Elev = Lon
    Name = strarr(Nsite)
    State= Name

    Infosite = strmid(Info.siteid,0,4)
    for ic = 0, Nsite-1 do begin
        ip = where(siteV(ic) eq infosite)
       Lon(ic)  = info.lon(ip[0])
       Lat(ic)  = info.lat(ip[0])
       Elev(ic) = info.elev(ip[0])
       Name(ic) = info.name(ip[0])
       State(ic)= info.state(ip[0])
    endfor


    if Keyword_set(plotmap) then begin
     map_set, 0, 0, color=1, /contine, limit = [0., -180., 90., 0.],/usa
     plots, lon, lat, color=10, psym=2
    endif

    Obs_mon = {Siteid:siteV, name:name, state:state, $
               Lon:Lon, Lat:Lat, Elev:Elev,          $
               so4:so4v, no3:no3v, oc:ocv, ec:lacv,  $
               soil:soilv, k:kv, fe:fev, fm:fmv}

    Return, Obs_mon

    end
