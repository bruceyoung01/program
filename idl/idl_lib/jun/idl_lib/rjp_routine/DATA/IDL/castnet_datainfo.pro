
 function castnet_datainfo, year=year, SiteName=SiteName, plotmap=plotmap

 ; so2
 ; so4
 ; no3
 ; nh4
 ; hno3
 ; o3   
 ; units are all ug/m3 except for ozone (ppb)

    if N_elements(year) eq 0 then return, 0

    Info  = castnet_siteinfo()
    LON   = float(info.LONGITUDE)
    D     = where(LON ge -130.)
    NSITE = N_elements(D)
    Lon   = float(info.longitude(D))
    Lat   = float(info.latitude(D))
    Elev  = float(info.elevation(D))

    If !D.Name eq 'WIN' then DIR = '.\CASTNET\' else $
       DIR = '/users/ctm/rjp/Data/CASTNET/'

    Cfile = 'castnet_conc_'+strtrim(year,2)+'_month.txt'

    print, '---Read CASTNET AEROSOL data from '+Cfile

    Openr,il, DIR+Cfile, /get

    Site  = ''
    Code  = 'Code'
    SiteV = info.site_id[D]
    So2v  = Replicate(-999.,NSITE,12)
    so4v  = so2v
    no3v  = so4v
    nh4v  = so4v
    hno3v = so4v
    o3v   = so4v

    icount = -1L    
    while (not eof(il)) do begin

      readf, il, Site, mon, so2, so4, no3, nh4, hno3, o3, $
      format='(A6,I3,6f9.3)'
;      o3 = -999.

      ip = where(SiteV eq site)
      if ip[0] eq -1L then goto, jump1
      if info.longitude[ip[0]] lt -130. then goto, jump1
      
         so2v[ ip[0], mon-1] = so2
         no3v[ ip[0], mon-1] = no3
         so4v[ ip[0], mon-1] = so4
         nh4v[ ip[0], mon-1] = nh4
         hno3v[ip[0], mon-1] = hno3
         o3v[  ip[0], mon-1] = o3

      jump1:

    endwhile
    free_lun,il
    
    Obs_mon = {siteid:siteV, Lon:Lon, Lat:Lat, Elev:Elev, $
               so4:so4v, no3:no3v, so2:so2v, nh4:nh4v, hno3:hno3v, o3:o3v}

    Return, Obs_mon

    end
