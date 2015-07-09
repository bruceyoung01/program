 pro get_data, file, year=year,  $
          SiteV = siteV, $
          so4v  = so4V,  $
          no3v  = no3V,  $
          ocv   = ocV,   $
          lacv  = lacV,  $
          soilv = soilV, $
          amsv  = amsV,  $
          amnv  = amnV,  $
          frhv  = frhV

    Openr,il, file, /get

;    Header = ''
;    readf, il, Header

    Site  = ''
    Code  = 'Code'
    SiteV = strarr(12)
    So4v  = replicate(-999.,12)
    No3v  = so4v
    ocv   = so4v
    lacv  = so4v
    soilv = so4v
    amsv  = so4v
    amnv  = so4v
    fmassv= so4v
    frhv  = so4v

    time   = 1L
    icount = -1L    
    while (not eof(il)) do begin
      readf, il, Site, time, so4, no3, oc, lac, soil, ams, amn, frh, $
      format='(A4,I7,8f9.3)'

      Yr = Time/100L     
      if (Year eq Yr) then begin
          icount        = icount + 1L
          if icount ge 12 then begin
             print, 'Two many data'
             stop
          endif
          SiteV[icount] = site
          so4v[icount]  = so4
          no3v[icount]  = no3
          ocv [icount]  = oc
          lacv[icount]  = lac
          soilv[icount] = soil
          amsv[icount]  = ams
          amnv[icount]  = amn
          frhv[icount]  = frh
;          fmassv[icount,mon-1] = fmass
      endif

    endwhile

    free_lun,il

 end


 function imp_dinfo, year=year, SiteName=SiteName, plotmap=plotmap


    IF N_elements(year) eq 0 then return, 0

    If !D.Name eq 'WIN' then DIR = 'D:\Data\IMPROVE\Raw_data\' else $
        DIR = '/users/ctm/rjp/Data/IMPROVE/Raw_data/MONTH/'

    spawn, 'ls '+DIR+'*.txt', files

    Info = improve_siteinfo()
    
    Lon  = fltarr(N_elements(Files))
    Lat  = Lon
    Elev = Lon
    Name = strarr(N_elements(Files))
    State= Name
    SITE = Name
    Infosite = strmid(Info.site,0,4)

    so4  = fltarr(N_elements(Files), 12)
    no3  = so4
    oc   = so4
    ec   = so4
    soil = so4
    ams  = so4
    amn  = so4
    frh  = so4

    ICT = -1L

    For D = 0, N_elements(Files) - 1 do begin

        file = files[D]
;        print, '---Read IMPROVE AEROSOL data from '+file
        get_data, file, year=year,  $
          SiteV = siteV, $
          so4v  = so4V,  $
          no3v  = no3V,  $
          ocv   = ocV,   $
          lacv  = lacV,  $
          soilv = soilV, $
          amsv  = amsV,  $
          amnv  = amnV,  $
          frhv  = frhV
 
       ip = where(siteV[0] eq infosite)
       if ip[0] ne -1 then begin
 
          ict = ict + 1L
          Site(ict) = siteV[0]
          Lon(ict)  = info.lon(ip[0])
          Lat(ict)  = info.lat(ip[0])
          Elev(ict) = info.elev(ip[0])
          Name(ict) = info.name(ip[0])
          State(ict)= info.state(ip[0])
          so4[ict,*] = so4v
          no3[ict,*] = no3v
          oc[ ict,*] = ocv
          ec[ ict,*] = lacv
          soil[ict,*] = soilv
          ams[ict,*] = amsv
          amn[ict,*] = amnv
          frh[ict,*] = frhv
       end
    endfor

    
    Obs_mon = {Siteid:site[0:ict],   $
               name:name[0:ict],     $
               state:state[0:ict],   $
               Lon:Lon[0:ict],       $
               Lat:Lat[0:ict],       $
               Elev:Elev[0:ict],     $
               so4:so4[0:ict,*],     $
               no3:no3[0:ict,*],     $
               oc:oc[0:ict,*],       $
               ec:ec[0:ict,*],       $
               soil:soil[0:ict,*],   $
               ams:ams[0:ict,*],     $
               amn:amn[0:ict,*],     $
               frh:frh[0:ict,*]      }

    Return, Obs_mon

    end
