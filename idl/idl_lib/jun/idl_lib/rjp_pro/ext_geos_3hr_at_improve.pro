
 function  EXTRACT_timeseries,  $
           FILE,                $
           CATEGORY,            $
           TRACER=TRACER,       $
           MODELINFO=MODELINFO, $
           OBS=OBS,             $
           FIXZ=FIXZ

     If N_elements(file) eq 0 then return, -1
     If N_elements(Category) eq 0 then CAtegory = 'IJ-AVG-$'
     If N_elements(Modelinfo) eq 0 then return, -1

     First = 1L

     ; Retrieve model coordinate and some constants for unit conversion
     GridInfo = CTM_GRID( MOdelInfo )
     Area_M2  = CTM_BoxSize( GridInfo, /GEOS, /m2 )

     ; Basic dimension should be same for each category
     NSITE = N_ELEMENTS(OBS.SITEID)

     ; Retrieve met fields first
     CTM_Get_Data, PresInfo, 'PS-PTOP',  File=FILE, tracer=901  ; hpa
;    Ctm_get_Data, RHInfo,   'DAO-3D-$', File=FILE, tracer=1711 ; %
     Ctm_get_Data, AIRDInfo, 'TIME-SER', File=FILE, tracer=1222 ; molec/cm3

     Thisinfo = PresInfo[0]
     IMX      = Thisinfo.dim[0]
     JMX      = Thisinfo.dim[1]
;     LMX      = Thisinfo.dim[2]
     
     ; We need offset index because orginal data are extraced over NA
     OFSET    = thisinfo.First - 1L
     I0       = OFSET[0]
     J0       = OFSET[1]
     L0       = OFSET[2]
     I1       = IMX + I0 - 1L
     J1       = JMX + J0 - 1L
;     L1       = LMX + L0 - 1L

     ; Find how many taus for met data are present?
     ii      = sort(PresInfo.tau0)
     jj      = uniq(PresInfo[ii].tau0)
     ptau0   = PresInfo[ii[jj]].tau0
     nptime  = n_elements(ptau0)

     RHG     = FLTARR( NSITE, NPTIME )
     TG      = RHG
     ADG     = RHG
     PG      = RHG
     AVALUE  = RHG

     For D = 0, nptime-1L do begin

         PS    = *(PresInfo[D].data)

         ; find the lat, lon, alt index of model for the location of observation
         IF First eq 1L then begin

            index = ij_find( obs=obs, Modelinfo=Modelinfo, offset=OFSET )
            index = l_find(  obs=obs, index=index, PS=PS, Modelinfo=Modelinfo, fixz=fixz )
            First = 0L
         ENDIF

;         Ctm_get_Data, TempInfo, 'DAO-3D-$', File=FILE, tracer=1703, tau0=PTAU0[D] ; K
;         TEMP   = *(tempinfo.data)
;         Undefine, Tempinfo

         FOR IS = 0, NSITE-1 DO BEGIN
             I = INDEX.I[IS]
             J = INDEX.J[IS]
             L = INDEX.L[IS]

;             TG[IS,D]  = temp[I,J,L]                
             TG[IS,D]  = 0.

             pedge     = get_pedge( ps[I,J], modelinfo=modelinfo )
             PG[IS,D]  = (pedge[L] + pedge[L+1])*0.5

             IF ( N_ELEMENTS(AIRDINFO) NE 0 ) THEN BEGIN
                ; if airmass data are archived
                N   = WHERE( PTAU0[0] EQ AIRDINFO.TAU0 )
                AD  = *(AIRDINFO[N[0]].DATA) * 1.E6 / 6.022E23 ; FROM #/CM3 TO MOLE/M3
                ADG[IS,D] = AD[I,J,L]  ; Vector of airden at each site
             END ELSE BEGIN 
                ; there are not airmass data available then we have to compuate it

                ADG[IS,D] = get_airden( p1=pedge[L], p2=pedge[L+1], $
                            temp=TG[IS,D], Area_m2=Area_m2[I+I0,J+J0] ) 
             END
         ENDFOR

            Undefine, AD
        End

      ; Retrieve all data (ij-avg-$) information
        CTM_Get_Data, DataInfo, Filename=File, 'IJ-AVG-$', TRACER=TRACER
 
        Thisinfo = Datainfo[0]
        IMX      = Thisinfo.dim[0]
        JMX      = Thisinfo.dim[1]
        LMX      = Thisinfo.dim[2]

      ; Find how many taus are present?
        ii      = sort(Datainfo.tau0)
        jj      = uniq(Datainfo[ii].tau0)
        times   = Datainfo[ii[jj]].tau0
        ntime   = n_elements(times)

      ; Find how many tracers are present?
        ii      = sort(Datainfo.tracer)
        jj      = uniq(Datainfo[ii].tracer)
        tracers = Datainfo[ii[jj]].tracer
        nspec   = n_elements(tracers)

      ; Store tracername as string
        names   = Datainfo[ii[jj]].tracername

        CONC    = FLTARR( NSPEC, NSITE, Ntime )
        PXT     = -1.


      ; LOOP OVER Datainfo
        FOR N = 0, N_ELEMENTS(DATAINFO)-1 DO BEGIN

             C     = *(DataInfo[N].Data)
             CDIM  = Size(C)

             ; dimension check between press and conc
             if cdim[1] ne IMX or cdim[2] ne JMX then begin
                print, 'something wrong with dimension'
                stop
             endif

              TAU0 = Datainfo[N].tau0
              S    = Datainfo[N].tracer
              DIM0 = DataInfo[N].First - 1L
              I0   = DIM0[0]
              J0   = DIM0[1]
              L0   = DIM0[2]
              I1   = CDim[1] + I0 - 1L
              J1   = CDim[2] + J0 - 1L
              L1   = CDim[3] + L0 - 1L

              IC   = WHERE(S EQ TRACERS)             
              IT   = WHERE(TAU0 EQ TIMES)
              PXT  = IT[0]

              if ic[0] eq -1 or it[0] eq -1 then stop
              if names[ic[0]] ne Datainfo[N].tracername then stop

              U = Strmid(Datainfo[N].unit,0,3)

              FOR IS = 0, NSITE-1 DO BEGIN
                 I = INDEX.I[IS]
                 J = INDEX.J[IS]
                 L = INDEX.L[IS]

                 CONC[IC[0],IS,IT[0]] = C[I,J,L]  ; ppbv
              ENDFOR   
        Endfor

        Undefine, C
        Undefine, Datainfo

        FOR IC = 0, NSPEC-1 DO BEGIN
            NEWNAME = names[ic]
            AVALUE[*,*] = CONC[IC,*,*]
   
            IF N_ELEMENTS(RESULT) EQ 0 THEN $
               RESULT = CREATE_STRUCT( NEWNAME, AVALUE ) $
            ELSE $
               RESULT = CREATE_STRUCT( RESULT, NEWNAME, AVALUE )
        ENDFOR
          
      Calc = Create_struct( result,                $
                            'RH', RHG,             $
                            'T',  TG,              $
                            'AD', ADG,             $
                            'P',  PG,              $
                            'siteid',Obs.siteid,   $
                            'lon',index.lonv,      $
                            'lat',index.latv,      $
                            'loc',index.loc,       $
                            'lop',index.lop,       $
                            'time',times            )

      Undefine, CONC
      ctm_cleanup

      return, calc

   end

;=======================================================================

   modelinfo = ctm_type('GEOS4_30L',res=2)


   info = improve_siteinfo()

   ; choose all sites with longitude smaller then -130
    LON    = float(info.LON)
    LAT    = float(info.lat)
    D      = where(LON ge -130. and LAT ge 24.)

   obs = create_struct('SITEID', info.siteid[D],       $ 
                       'NAME',   info.name[D],         $
                       'STATE',  info.state[D],        $
                       'LON',    float(info.LON[D]),   $
                       'LAT',    float(info.LAT[D]),   $
                       'ELEV',   float(info.ELEV[D])   )
    Sn      = 0L


   ; IMPROVE
    m_s_dir = '/users/ctm/rjp/Asim/icartt/Run_v7-04-03/timeseries/out_pbl_nowet/'
;    m_s_dir = '/users/ctm/rjp/Asim/icartt/Run_v7-04-03_nofire/timeseries/'
    odir    = './geos_test/'



    confiles = collect(m_s_dir+'ts*.bpch')

    spec = ['TAU','NOx','Ox','CO','HNO3',  $
            'SO2','SO4','NH3','NH4','NIT', $
            'ECPI','ECPO','OCPI','OCPO',   $
            'SOA1','SOA2','SOA3',          $
            'TEMP','PRES','AIRD']

    nspec = n_elements(spec)
    mfile = strarr(n_elements(obs.siteid))

;    tracer = [1,2,4,7, $
;              26,27,29,30,31, $
;              32,34,33,35,42,43,44]

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
                     out.bcpi[d,t]*12.*fac,   $
                     out.bcpo[d,t]*12.*fac,   $
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
