
;--------------------------------------------------------------------

 function ratio, data, conc

  dim = size(conc)
  ratio = fltarr(dim[1])

  for d = 0, dim[1]-1 do begin
      a = reform(data[d,*])
      p = where(a eq -999.)
      if p[0] ne -1 then a[p] = 'NaN'
      ratio[d] = mean(a,/NaN)/mean(conc[d,*])
  end
  
 return, ratio

 end

;------------------------------------------------------------------

 function month_mean, Dinfo=Dinfo, spec=spec, time=time, sot=sot, $
    badsite=badsite, ID=ID, LON=LON, LAT=LAT

 if n_elements(badsite) eq 0 then badsite = ' '

 case spec of 
   'SO4' : if n_elements(sot) ne 0 then Data = Dinfo.so4[sot] $
           else Data = Dinfo.so4
   'OMC' : if n_elements(sot) ne 0 then Data = Dinfo.omc[sot] $
           else Data = Dinfo.omc
   'NO3' : Data = Dinfo.no3
   'NIT' : if n_elements(sot) ne 0 then Data = Dinfo.nit[sot] $
           else Data = Dinfo.nit
   'EC'  : if n_elements(sot) ne 0 then Data = Dinfo.ec[sot] $
           else Data = Dinfo.ec
   'SOIL' : Data = Dinfo.soil
   'DUST' : if n_elements(sot) ne 0 then Data = Dinfo.DST1[sot] + Dinfo.DST2[sot]*0.38 $
           else Data = Dinfo.DST1 + Dinfo.DST2*0.38
 end
            
 if n_elements(sot) ne 0 then jday = Dinfo[0].jday[sot] $
 else jday = Dinfo[0].jday

 Nsite= n_elements(Dinfo)

 jmon = tau2month(jday)
 mm   = jmon(uniq(jmon)) & time=mm
 nmon = n_elements(mm)
 mobs = fltarr(Nsite, nmon)
 ID   = ' '
 Lon  = -999.
 Lat  = -999.
 For D = 0, Nsite - 1L do begin
     p = where(Dinfo[D].siteid eq badsite)
     if p[0] ne -1 then begin
        mobs[D, *] = -999.
        goto, bad
     end
    For M = 0, nmon  - 1L do begin
        p = where(jmon eq mm[M])  ; search for the same month

        if p[0] eq -1 then begin
           mobs[D, mm[M]-1L] = -999.
           goto, jump
        end

        s = reform(Data[P, D])    ; sample data for the same month
        p = where(s gt 0.)        ; remove missing data

        if p[0] eq -1 then begin
           mobs[D, mm[M]-1L] = -999.
           goto, jump
        end

        mobs[D, mm[M]-1L] = mean(s[p]) ; taking mean

        jump:
    end

    ID  = [ID, Dinfo[D].siteid]
    LON = [Lon, Dinfo[D].lon]
    Lat = [Lat, Dinfo[D].lat]
    bad:
 end

 ID = ID[1:*]
 LON= LON[1:*]
 LAT= LAT[1:*]

 return, mobs

 end

;-------------------------------------------------------------------

 ;=========================================================================;
  @define_plot_size

  ospec = 'SO4'
  mspec = 'SO4'
 range = [0., 10.]
  Year   = 2001L
  CYear = Strtrim(Year,2)
  RES    = 1
; badsite = ['BRIG1','AGTI1','PORE1']
; badsite = 'DEVA1'
  Comment = '1x1 Nested NA run for 2001'
 ;=========================================================================;

 if n_elements(obs) eq 0 then begin
    obs    = get_improve_dayly()
    sim    = get_model_day_improve(res=1)
    bkg    = get_model_day_improve(res=11)
    nat    = get_model_day_improve(res=111)
    asi    = get_model_day_improve(res=1111)
    newsim = syncro( sim, obs )
    newbkg = syncro( bkg, obs )
    newnat = syncro( nat, obs )
    newasi = syncro( asi, obs )
    newobs = group( obs , ID=ID )
 endif

  CASE RES of
  11 : DXDY = '1x1'
   1 : DXDY = '1x1'
   2 : DXDY = '2x25'
   4 : DXDY = '4x5' 
  END

 MTYPE  = 'GEOS3_30L'
 Modelinfo = CTM_TYPE(MTYPE, RES=RES)

; Plotsites, obs=improve_Obs, /ps

 if (!D.NAME eq 'PS') then $
    Open_device, file=OSPEC+'_IMPR_'+DXDY+'_season_'+CYEAR+'.ps', /PS, /landscape

  sot  = Long(obs[0].jday)-1L

  bdlon = -95.
  bdlat = 35.

  bad = ['MEVE1','PEFO1']

  idnw = where(obs.lon le bdlon and obs.lat gt bdlat)
  idne = where(obs.lon gt bdlon and obs.lat gt bdlat)
  idsw = where(obs.lon le bdlon and obs.lat le bdlat)
  idse = where(obs.lon gt bdlon and obs.lat le bdlat)

  m   = search_index(bad, obs[idnw].siteid, COMPLEMENT=id) 

  xx = where(obs.lon gt -85. and obs.lat gt 40.)  

  impr = obs[xx]
  geos = sim[xx]

  data = month_mean(Dinfo=impr, spec=ospec, time=time, badsite=badsite, ID=SITE, $
         LON=LON, LAT=LAT)

  conc = month_mean(Dinfo=sim[xx], spec=mspec, badsite=badsite)
  sam1 = month_mean(Dinfo=bkg[xx], spec=mspec, badsite=badsite)
  sam2 = month_mean(Dinfo=asi[xx], spec=mspec, badsite=badsite)
  cana = sam1 - sam2
  nong = conc - cana

; conc = month_mean(Dinfo=sim, spec=spec, sot=sot, time=mon)
 ratio= ratio(data, conc)

 Unit = ' [!4l!3g/m!u3!n]'

  scatter_season, 'IMPROVE', $
                  Modelinfo=Modelinfo, data=data, conc=nong, range=range, $
                  time=time, lat=lat, lon=lon, spec=ospec,                $
                  /subgridoff, bdlon=[-160.,-95.,-50.], Unit=Unit,        $
                  /regress

;  scatter_annual, 'IMPROVE', $
;                  Modelinfo=Modelinfo, data=data, conc=conc, range=range, $
;                  time=time, lat=lat, lon=lon, spec=ospec,                $
;                  ID=site, bdlon=[-160.,-95.,-50.], Unit=Unit, /regress,  $
;                  /check_bias


  xyouts, 0.95, 0.98, Comment, /normal, color=1, charsize=charsize, $
          charthick=charthick, alignment=1.

  if (!D.NAME eq 'PS') then Close_device

end
