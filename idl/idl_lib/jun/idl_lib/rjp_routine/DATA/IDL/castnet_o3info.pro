
 function castnet_o3info, year=year, SiteName=SiteName, plotmap=plotmap

 ; so2
 ; so4
 ; no3
 ; nh4
 ; hno3
 ; o3   
 ; units are all ug/m3 except for ozone (ppb)

    if N_elements(year) eq 0 then return, 0

    Info = castnet_siteinfo()

    If !D.Name eq 'WIN' then DIR = '.\CASTNET\' else $
       DIR = '/users/ctm/rjp/Data/CASTNET/O3_hourly/'

    files = collect(DIR+'*.csv')

    print, '---Read CASTNET met and o3 data'

    For D = 0, N_elements(files)-1 do begin

       Openr,il,files[d], /get

    Site  = ''
    Code  = 'Code'
    SiteV = strarr(200)
    So2v  = fltarr(200,12)
    so4v  = so2v
    no3v  = so4v
    nh4v  = so4v
    hno3v = so4v
    o3v   = so4v

    icount = -1L    
    while (not eof(il)) do begin
;      readf, il, Site, mon, so2, so4, no3, nh4, hno3, o3, $
;      format='(A6,I3,6f9.3)'

      readf, il, Site, mon, so2, so4, no3, nh4, hno3, $
      format='(A6,I3,5f9.3)'
      o3 = -999.

      ip = where(site eq info.site_id)
      if ip[0] eq -1L then goto, jump1
      if info.longitude[ip[0]] lt -130. then goto, jump1

      if N_elements(SiteName) eq 0 then begin
         if (Site ne Code) then begin
            icount = icount + 1L
            Code  = Site
         endif
         loc = icount
      end else begin
         loc = where(Site eq SiteName) 
      end
      
      if (loc(0) ne -1) then begin
          SiteV[loc[0]]        = site
          so2v[ loc[0], mon-1] = so2
          no3v[ loc[0], mon-1] = no3
          so4v[ loc[0], mon-1] = so4
          nh4v[ loc[0], mon-1] = nh4
          hno3v[loc[0], mon-1] = hno3
          o3v[  loc[0], mon-1] = o3
      endif

      jump1:
    endwhile
    free_lun,il

    if N_elements(SiteName) eq 0 then Nsite = icount+1 $
    else Nsite = N_elements(SiteName)

    siteV  = siteV[0:Nsite-1]
    so4v   = so4v[ 0:Nsite-1, *]
    no3v   = no3v[ 0:Nsite-1, *]
    so2v   = so2v[ 0:Nsite-1, *] 
    nh4v   = nh4v[ 0:Nsite-1, *]
    hno3v  = hno3v[0:Nsite-1, *]
    o3v    = o3v[  0:Nsite-1, *]
    
    Lon  = fltarr(Nsite)
    Lat  = Lon
    Elev = Lon
    SO2  = Fltarr(Nsite, 12)
    NO3  = SO2
    SO4  = SO2
    NH4  = SO2
    HNO3 = SO2
    O3   = SO2

    ict = -1L
    for ic = 0, Nsite-1 do begin
        ip = where(siteV(ic) eq info.site_id)
        if ip(0) ne -1 then begin
           ict = ict + 1L
           SO2[ ict, *] = SO2V[ ic, *]
           SO4[ ict, *] = SO4V[ ic, *]
           NO3[ ict, *] = NO3V[ ic, *]
           NH4[ ict, *] = NH4V[ ic, *]
           HNO3[ict, *] = HNO3v[ic, *]
           O3[  ict, *] = O3V[  ic, *]
           Lon[ict]     = float(info.longitude(ip[0]))
           Lat[ict]     = float(info.latitude(ip[0]))
           Elev[ict]    = float(info.elevation(ip[0]))
        end else $
        print, 'NO matching information has been found for', SiteV[ic]
    endfor

    SO2  = SO2[ 0:ict, *]
    SO4  = SO4[ 0:ict, *]
    NH4  = NH4[ 0:ict, *]
    NO3  = NO3[ 0:ict, *]
    HNO3 = HNO3[0:ict, *]
     O3  = O3[  0:ict, *]
    LON  = LON[0:ict]
    LAT  = LAT[0:ict]
    ELEV = ELEV[0:ict]

    Obs_mon = {siteid:siteV, Lon:Lon, Lat:Lat, Elev:Elev, $
               so4:so4, no3:no3, so2:so2, nh4:nh4, hno3:hno3, o3:o3}

    Return, Obs_mon

    end
