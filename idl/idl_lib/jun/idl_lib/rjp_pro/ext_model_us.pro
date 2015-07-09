   modelinfo = ctm_type('GEOS4_30L',res=2)
   gridinfo  = ctm_grid(modelinfo)

   lon = gridinfo.xmid#replicate(1.,91)
   lat = replicate(1.,144)#gridinfo.ymid

   lon = region_only(lon, region='USCONT')
   lat = region_only(lat, region='USCONT')

   i   = where(lon ne 0.)
   lon = lon[i]
   lat = lat[i]
   ID  = strtrim(Indgen(N_elements(lon)),2)
   p   = where(strlen(ID) eq 1)
   ID[p] = '00'+id[p]
   p   = where(strlen(ID) eq 2)
   ID[p] = '0'+id[p]
   ELEV= Replicate(0., N_elements(lon))


   obs = create_struct('SITEID', Id,    $ 
                       'LON',    LON,   $
                       'LAT',    LAT,   $
                       'ELEV',   ELEV   )


    Sn      = 0L

;    m_s_dir = '/as2/home/misc/clh/GEOS/rundir_7-02-04_ICARTT/OUT2_full/'

;    m_s_dir = '/users/ctm/rjp/Asim/icartt/timeseries/'
;    odir    = './model_data/'

    m_s_dir = '/users/ctm/rjp/Asim/icartt_nofire/timeseries/'
    odir    = './model_data/'


    confiles = collect(m_s_dir+'ts*.bpch')

    spec = ['TAU','NOx','Ox','CO','HNO3',  $
            'SO2','SO4','NH3','NH4','NIT', $
            'ECPI','ECPO','OCPI','OCPO',   $
            'SOA1','SOA2','SOA3',          $
            'TEMP','PRES','AIRD']

    nspec = n_elements(spec)
    mfile = strarr(n_elements(obs.siteid))

    tracer = [1,2,4,7, $
              26,27,29,30,31, $
              32,34,33,35,42,43,44]

    For d = 0, n_elements(obs.siteid)-1 do begin
       mfile[d] = odir+'hourly_'+obs.siteid[d]+'.txt'
       path = findfile(mfile[d], count=count)
       if count eq 0L then openw, il, mfile[d], /get else goto, jump

       printf, il, nspec+6L, format='(I2)'
       printf, il, nspec+4L, format='(I2)'
       printf, il, obs.siteid[d], format='(A6)'
       printf, il, obs.lon[d],    format='(F8.3)'
       printf, il, obs.lat[d],    format='(F8.3)'
       printf, il, obs.elev[d],   format='(F8.3)'

       FOR n = 0, nspec-1L do $
           printf, il, spec[n], format='(A4)'

       free_lun, il
       jump:
    endfor

   for nn = Sn, n_elements(confiles)-1L do begin

     file   = confiles[nn]
     print, 'processing data for ', file

     out = EXTRACT_timeseries( FILE,                     $
                          CATEGORY,                      $
                          TRACER    =  TRACER,           $
                          MODELINFO =  MODELINFO,        $
                          OBS       =  OBS,              $
                          FIXZ      =  FIXZ            )

     For d = 0, n_elements(obs.siteid)-1 do begin

       path  = findfile(mfile[d], count=count)
       if count eq 1L then openu, il, mfile[d], /get, /append else stop

       for t = 0, n_elements(out.time)-1 do begin

        fac = 1.e-3 * out.ad[d,t]  ; ppbv => umol/m3 (1.e-9 * 1.e+6 * airmass[mole/m3])

        printf, il,  out.time[t],             $
                     out.nox[d,t],            $
                     out.ox[d,t],             $
                     out.co[d,t],             $
                     out.hno3[d,t],           $
                     out.so2[d,t],            $
                     out.so4[d,t]*96.*fac,    $
                     out.nh3[d,t],            $
                     out.nh4[d,t]*18.*fac,    $
                     out.nit[d,t]*62.*fac,    $
                     out.ecpi[d,t]*12.*fac,   $
                     out.ecpo[d,t]*12.*fac,   $
                     out.ocpi[d,t]*12.*fac,   $
                     out.ocpo[d,t]*12.*fac,   $
                     out.soa1[d,t]*150.*fac,  $
                     out.soa2[d,t]*160.*fac,  $
                     out.soa3[d,t]*220.*fac,  $
                     out.t[d,t],              $
                     out.p[d,t],              $
                     out.ad[d,t],             $
                     format='('+strtrim(nspec,2)+'f11.3)'
       end

       free_lun, il
    endfor

   endfor

 End
