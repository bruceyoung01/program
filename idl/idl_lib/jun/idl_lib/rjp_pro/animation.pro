 function readmodel_mass,      $
          file,                $
          Category,            $
          Tracer=Tracer,       $
          file_aird=file_aird, $
          file_pres=file_pres, $
          YYMM=YYMM,           $   
          NLayer=Nlayer,       $            
          Modelinfo=Modelinfo, $
          Column=Column

     If N_elements(file) eq 0 then return, 0
;     If N_elements(YYMM) eq 0 then return, 0
     If N_elements(NLayer) eq 0 then IZ = 0 else IZ = NLayer-1 
     If N_elements(Category) eq 0 then CAtegory = 'IJ-AVG-$'
     If N_elements(Modelinfo) eq 0 then return, 0
     If N_elements(file_aird) eq 0 then file_aird = file
     If N_elements(file_pres) eq 0 then file_pres = file

   ; Retriev met fields first
      CTM_Get_Data, AirdInfo, 'TIME-SER', Filename=file_aird, tracer=1222 ; #/cm3
      CTM_Get_Data, PresInfo, 'PS-PTOP',  Filename=file_pres, tracer=1

   ; Retrieve model coordinate and some constants for unit conversion
      GridInfo = CTM_GRID( MOdelInfo )
      A_M2     = CTM_BoxSize( GridInfo, /GEOS, /m2 )
      Volume   = CTM_BOXSIZE( GridInfo, /GEOS, /Volume, /m3 )
      PTOP     = min(GRIDINFO.PEDGE)

      Thisinfo = PresInfo[0]
      IMX      = Thisinfo.dim[0]
      JMX      = Thisinfo.dim[1]

       ; We need offset index because orginal data are extraced over NA
      OFSET    = thisinfo.First - 1L
      I0       = OFSET[0]
      J0       = OFSET[1]
      I1       = IMX + I0 - 1L
      J1       = JMX + J0 - 1L

;        GETMODELANDGRIDINFO, Thisinfo, MODELINFO, GRIDINFO

      Xmid = gridinfo.xmid[I0:I1]
      ymid = gridinfo.ymid[J0:J1]


     TIME = 0L
     FOR ICAT = 0, N_ELEMENTS(CATEGORY)-1 DO BEGIN

       Case STRUPCASE(Category[icat]) of
         'IJ-AVG-$' : begin
                      TAG = 'CONC'   ; mole/m3
                      unit= 'umole/m3'
                      end
         'IJ-24H-$' : begin
                      TAG = 'CONC'   ; mole/m3
                      unit= 'umole/m3'
                      end
         'WETDLS-$' : begin
                      TAG = 'WDLS'   ; kg/s
                      unit = 'kg/m2/s'
                      end
         'WETDCV-$' : begin
                      TAG = 'WDCV'   ; kg/s
                      unit = 'kg/m2/s' 
                      end
         'DRYD-FLX' : begin
                      TAG = 'DRYD'   ; kg/ts
                      unit = 'kg/m2/ts'
                      end
         ELSE       : begin
                      print, 'CATAGORY DOES NOT MATCH'
                      return, 0
                      end
       ENDCASE

     ; Retrieve all tracer information together
       CTM_Get_Data, DataInfo, Category[icat], $
                     Filename=File, Tracer=Tracer

       Thisinfo = Datainfo[0]
       IMX      = Thisinfo.dim[0]
       JMX      = Thisinfo.dim[1]
       LMX      = Thisinfo.dim[2]

       ikount = -1L
       SNAME  = ' '


      ; Basic dimension should be same for each category
       IF N_ELEMENTS(YYMM) EQ 0 THEN BEGIN
         ; Find how many taus are present in datainfo array?
          ii      = sort(Datainfo.tau0)
          jj      = uniq(Datainfo[ii].tau0)
          times   = Datainfo[ii[jj]].tau0
          ntime   = n_elements(times)
       end else begin
          ntime = N_elements(YYMM)
          times = NYMD2TAU( YYMM*100L + 1L, 0L )
       end

       ; LOOP OVER TIME
       FOR IK = 0, ntime-1 DO BEGIN

           ; FIND THE NUMBER OF MATCHING TRACERS AT TAU0      
           M = where( times[ik] eq Datainfo.tau0 )
           if M[0] eq -1 then goto, Jump

           if ICAT eq 0 then Time = [Time, times[ik]]

           ikount = ikount + 1L

           ; initialize save array, 2D with time for M different tracers
           if ikount eq 0 then SAVE   = fltarr(IMX,JMX,ntime,N_elements(M))

           ; 3d array for M different tracers
           Store  = fltarr(IMX,JMX,LMX,N_elements(M))

           IF TAG EQ 'CONC' THEN BEGIN

             ; IF we retrive tracer concentrations then need air mass information
             ; for unit conversion from volume to mass concentrations
             IF ( N_ELEMENTS(AIRDINFO) NE 0 ) THEN BEGIN
                N   = where( times[ik] eq AirdInfo.tau0 )
                AD  = *(AirdInfo[N].Data) * 1.E6 / 6.022D23 ; mole/m3

                if N[0] eq -1 then begin
                   print, 'No appropriate AD info can be found'
                   return, 0
                endif

             ENDIF ELSE BEGIN

                ; if not then we compute it using press and temp
                CTM_Get_Data, TempInfo, 'DAO-3D-$', Filename=file, $
                            tracer=1703, tau0=times[ik]
                TEMP = *(TEMPINFO.data)
                AD   = FLTARR(IMX,JMX,LMX)

                N    = WHERE( times[ik] EQ PRESINFO.TAU0 )
                PS   = *(PRESINFO[N].DATA) + PTOP    ; real surface pressure [hPa]

                FOR J = 0, JMX-1 DO BEGIN
                FOR I = 0, IMX-1 DO BEGIN
                   PEDGE = GET_PEDGE( PS[I,J], MODELINFO=MODELINFO )

                   FOR L = 0, LMX-1 DO $
                   AD[I,J,L] = GET_AIRDEN( P1=PEDGE[L], P2=PEDGE[L+1], $
                               TEMP=TEMP[I,J,L], AREA_M2=A_M2[I+I0,J+J0] ) 
                ENDFOR
                ENDFOR
             END
           ENDIF ; IF 'CONC'
           
           Icount = -1L
           for ic = 0, N_elements(M)-1 do begin ; number of species

               N = M[ic]

               if N_elements(Tracer) ne 0 then begin
                  Chk = where(datainfo[N].tracer eq Tracer)
                  if Chk[0] eq -1 then goto, Jump_spec
               end
               icount = icount + 1L

               C = *(DataInfo[N].Data)           ; ppbv
               U = Strmid(Datainfo[N].unit,0,3)
               if ikount eq 0 then Sname = [Sname, datainfo[N].tracername+'_'+TAG]
               CASE U of
                 'ppb' : c_fac = 1.E-9
                 'v/v' : c_fac = 1.
                 else  : begin
                         print, 'Not recognizable unit'
                         end
               END
              
               CASE TAG of
                 'CONC' : begin
                             if keyword_set(column) then begin
                                Store[*,*,*,icount] = C * AD * c_fac * volume ; ppbv -> v/v -> mole
                                SAVE[*,*,ikount,icount] = Total(Store[*,*,*,icount],3) ; Total Colume concentration (mole)
                             end else begin
                                Store[*,*,*,icount] = C * AD * c_fac * 1.e+6  ; ppbv -> v/v -> umole/m3
                                SAVE[*,*,ikount,icount] = Store[*,*,iz,icount]         ; Surface concentration
                             end
                          end
                 'WDLS' : SAVE[*,*,ikount,icount] = total(C,3)/A_M2 
                 'WDCV' : SAVE[*,*,ikount,icount] = total(C,3)/A_M2 
                 'DRYD' : SAVE[*,*,ikount,icount] = C/A_M2
                 ELSE   : print, 'CATAGORY DOES NOT MATCH'
               ENDCASE

              Undefine, C

              Jump_spec:
          endfor
              Undefine, AD
              Undefine, Store

       Jump:
      Endfor ; ntime-1 do begin

      If N_elements(SNAME) ge 2 then SNAME = SNAME[1:*]  else print, SNAME

      If N_elements(SNAME) ne (icount+1L) then begin
         print, N_elements(SNAME), icount+1L
         return, 0
      endif

      For nc = 0, icount do begin
          avalue = reform(SAVE[*,*,0:ikount,nc])

          if N_elements(result) eq 0 then $
             result = create_struct( sname[nc], avalue ) $
          else $
             result = create_struct( result, sname[nc], avalue )
      Endfor

      Undefine, DataInfo

      newname = TAG+'_unit'
      result  = create_struct( result, newname, unit )

     ENDFOR ; ICAT
          
      TIME = TIME[1:*]
      if N_elements(TIME) ne (ikount+1L) then begin
         print, N_elements(TIME),  ikount+1L
         return, 0
      endif

      Calc = Create_struct( result, 'time', time[0:ikount], 'xmid', xmid, 'ymid', ymid, $
             'FIRST', OFSET  )

      Undefine, PresInfo
      Undefine, AirdInfo
      CTM_cleanup

    Return, Calc

   end

;=================================================================================

  function retrieve, file=file, spec=spec, title=title, NLayer=Nlayer, $
    yyyy=yyyy, mm=mm, dd=dd

  if n_elements(spec) eq 0 then spec = 'OMC'
  if n_elements(nlayer) eq 0 then nlayer=1

    modelinfo = ctm_type('geos4_30l',res=2)
    gridinfo = ctm_grid(ctm_type('geos4_30l',res=2))
    omc      = fltarr(gridinfo.imx, gridinfo.jmx)
    alt      = gridinfo.pmid[nlayer-1]
    ZZZ      = strtrim(string(alt,format='(f5.1)'),2)

    if spec eq 'OMC' then begin
       tracer = [33,35,42,43,44]
       data  = readmodel_mass(file, 'IJ-AVG-$', TRACER=TRACER, $
                               modelinfo=modelinfo, NLayer=Nlayer)
    end else begin
       ctm_tracerinfo, spec, name=name, index=index
       tracer = min(index)

       ctm_get_data, datainfo, file=file, 'ij-avg-$', tracer=tracer
       dim   = datainfo[0].dim
       first = datainfo[0].first-1L
       conc  = fltarr(dim[0],dim[1],n_elements(datainfo))
       tau0  = datainfo.tau0
       for d = 0, n_elements(datainfo) -1 do begin
           data = *(datainfo[d].data)
           conc[*,*,d] = data[*,*,nlayer-1]
       end

       undefine, datainfo
       
       data = {conc:conc, first:first, time:tau0}   
    end

    case spec of
      'OMC' : conc = (data.ocpi_conc + data.ocpo_conc)*12.*1.4 + $
                     (data.soa1_conc)*150. + $
                     (data.soa2_conc)*160. + $
                     (data.soa3_conc)*220. 
      else  : conc = data.conc
    end

      i0 = data.first
      i1 = size(conc,/dim)-1L

      omc[i0[0]:i0[0]+i1[0],i0[1]:i0[1]+i1[1]]  = total(conc,3)/8.
     
      date = tau2yymmdd(data.time[0])
      yyyy = strtrim(string(date.year,form='(i4)'),2)
      mm   = strtrim(string(date.month,form='(i2)'),2)
      dd   = strtrim(string(date.day,form='(i2)'),2)

      if strlen(mm) eq 1 then mm = '0'+mm
      if strlen(dd) eq 1 then dd = '0'+dd

      title = strtrim(mm+'/'+dd+'/'+yyyy)
      title = '!4D!3'+spec + ' concentrations in '+zzz+' mb '+title

      undefine, conc
      ctm_cleanup

 return, omc

 End


    ;    m_s_dir = '/as2/home/misc/clh/GEOS/rundir_7-02-04_ICARTT/OUT2_full/'
    m_s_dir = '/users/ctm/rjp/Asim/icartt/timeseries/emis_trop/'
    confiles0 = collect(m_s_dir+'ts*.bpch')

    m_s_dir = '/users/ctm/rjp/Asim/icartt_nofire/timeseries/wo_all_trop/'
    confiles1 = collect(m_s_dir+'ts*.bpch')

    limit = [24., -140., 58., -62.]
    mindata = 0
    maxdata = 20.
    multipanel, row=1, col=1
    Nlayer  = 1
    ZZ      = strtrim(nlayer,2)
    spec    = 'Ox'
    unit    = '!4l!3g m!u-3!n'
    unit    = 'ppbv'

    For d = 30, n_elements(confiles0)-1L do begin

      file = confiles0[D]
      omc0 = retrieve( file=file, title=title, spec=spec, NLayer=Nlayer )

      file = confiles1[D]
      omc1 = retrieve( file=file, title=title, spec=spec, NLayer=Nlayer, $
             yyyy=yyyy, mm=mm, dd=dd )

      diff = omc0-omc1
      plot_region, diff, limit=limit, title=title, /cbar, $
         divis=6, mindata=mindata, maxdata=maxdata, unit=unit , $
         cbformat='(F4.1)', /sample


;      plot_region, omc, limit=limit, title=title, /cbar, $
;         divis=5, mindata=mindata, maxdata=maxdata, unit='!4l!3g m!u-3!n', $
;         cbformat='(F4.1)', /sample

       filename = spec+'.'+yyyy+mm+dd+'_'+zz
       ThisFrame = TvRead( FileName=FileName, /BMP )

      wait,1
    Endfor

 End
