      
  function AIRQNT, ps=ps, temp=temp, gridinfo=gridinfo, P3D=P3D

     if n_elements(ps) eq 0 then return, -1
     if n_elements(temp) eq 0 then return, -1

     g0       =   9.8d0    
     Rd       = 287.0d0      
     Rdg0     =   Rd / g0
     g0_100   = 100d0 / g0
     Area     = CTM_BoxSize( GridInfo, /GEOS, /m2 )
     ptop     = min(gridinfo.pedge)

     ; AIRMW : Molecular weight of air [28.97 g/mole]
     AIRMW    =  28.97d-3

     Ndim   = size(temp,/dim)
     AIRDEN = fltarr(ndim[0],ndim[1],ndim[2])
     P3D    = AIRDEN

     for L = 0, 15 do begin
     for J = 0, ndim[1]-1L do begin
     for I = 0, ndim[0]-1L do begin

         ; Grid box surface area [m2]
         AREA_M2 = AREA(I,J)

         if ps(i,j) le 0. then goto, jump  
         if temp(i,j,l) le 0. then goto, jump
          
         ; Pressure at bottom edge of grid box [hPa]
         P1   = (ps(i,j)-ptop)*gridinfo.sigedge[L]+ptop

         ; Pressure at top edge of grid box [hPa]
         P2   = (ps(i,j)-ptop)*gridinfo.sigedge[L+1]+ptop

         ; Pressure difference between top & bottom edges [hPa]
         DELP = P1 - P2

         P3D[I,J,L] = 0.5 * (P1 + P2)
         ;===========================================================
         ; BXHEIGHT is the height (Delta-Z) of grid box (I,J,L) 
         ; in meters. 
         ;
         ; The formula for BXHEIGHT is just the hydrostatic eqn.  
         ; Rd = 287 J/K/kg is the value for the ideal gas constant
         ; R for air (M.W = 0.02897 kg/mol),  or 
         ; Rd = 8.31 J/(mol*K) / 0.02897 kg/mol. 
         ;===========================================================
         BXHEIGHT = Rdg0 * TEMP(I,J,L) * ALOG( P1 / P2 )
         AIRVOL   = BXHEIGHT * AREA_M2

         ;===========================================================
         ; AD = (dry) mass of air in grid box (I,J,L) in kg, 
         ; given by:        
         ;
         ;  Mass    Pressure        100      1        Surface area 
         ;        = difference   *  ---  *  ---   *   of grid box 
         ;          in grid box      1       g          AREA_M2
         ;
         ;   kg         mb          Pa      s^2           m^2
         ;  ----  =    ----      * ----  * -----  *      -----
         ;    1          1          mb       m             1
         ;===========================================================
         AD = DELP * G0_100 * AREA_M2 / AIRMW  ; Airmass in mole

         ;===========================================================
         ; AIRDEN = density of air (AD / AIRVOL) in mole / m^3 
         ;===========================================================

         AIRDEN(I,J,L) = AD / AIRVOL

         jump:
      END
      END
      END

      Return, Airden

  END

;===================================================================================

 function find_ijl, obs=obs, P3D=P3D, Modelinfo=Modelinfo, fixz=fixz, $
          offset=offset

   if N_elements(obs) eq 0 then return, -1
   if N_elements(Modelinfo) eq 0 then return, -1
   if (N_elements(P3D) eq 0) and (N_elements(fixz) eq 0) then return, -1

      GridInfo = CTM_GRID( MOdelInfo )

   ; Use the observations and synchronize the location between 
   ; the observation and calculation and return the calculation
   ; at observation sites only as a vector.
      NSITE = N_ELEMENTS(OBS.SITEID)
      Latv  = fltarr(NSITE)
      Lonv  = Latv
      Loc   = Latv
      Lop   = Loc

      INDEX_I = REPLICATE(0L, NSITE)
      INDEX_J = INDEX_I
      INDEX_L = INDEX_I

        I0    = OFFSET[0]
        J0    = OFFSET[1]
        L0    = OFFSET[2]

        XMID  = gridinfo.xmid(I0:*)
        YMID  = gridinfo.ymid(J0:*)

      for is = 0, N_ELEMENTS(OBS.SITEID)-1 do begin
          CTM_INDEX, ModelInfo, I, J, center = [Obs.lat(is),Obs.lon(is)], $
                     /non_interactive

          ; Correction for offset
          I1 = I-1-I0
          J1 = J-1-J0

          If N_elements(Fixz) eq 0 then begin
             Pr = Reform(P3D(I1,J1,*))
             if Total(Pr) le 0 then begin
                print, 'something wrong with data'
                stop
             end

             PZ = PtZ(Pr)
             Ht = obs.elev(is)/1000.
             DZ = ABS(PZ - Ht)
             iz = where(Min(DZ) eq Dz)
             Loc(is) = iz[0]
             Lop(is) = P3D(I1,J1,iz[0])
             if (dz[iz[0]] gt 1.) then print, Ht, PZ[iz[0]], Lop[is], obs.siteid[is]
           end else iz = fixz

          INDEX_I[IS] = I1
          INDEX_J[IS] = J1
          INDEX_L[IS] = IZ[0]

          Latv(is)    = ymid(J1)
          Lonv(is)    = xmid(I1)

          err_x = ABS(Lonv(is)-Obs.lon(is))
          err_y = ABS(Latv(is)-Obs.lat(is))

          ; Error check for finding ij
          if (err_x gt GridInfo.di*0.5) or (err_y gt Gridinfo.dj*0.5) then begin
              print, err_x, err_y, dz[iz[0]], obs.siteid[is]
              stop
          endif
          
      endfor

   return, {I:INDEX_I, J:INDEX_J, L:INDEX_L, LATV:Latv, LONV:Lonv, $
            LOC:Loc, LOP:Lop}

 end

;--------------------------------------------------------------------------

 function  EXTRACT_MODEL,       $
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
;      A_M2     = CTM_BoxSize( GridInfo, /GEOS, /m2 )
;      Volume   = CTM_BOXSIZE( GridInfo, /GEOS, /Volume, /m3 )
      If STRMID(MODELINFO.NAME,0,5) eq 'GEOS4' THEN $
        SIGMA = GRIDINFO.ETAMID                ELSE $
        SIGMA = GRIDINFO.SIGMID
      If STRMID(MODELINFO.NAME,0,5) eq 'GEOS4' THEN $
        SIGEDGE = GRIDINFO.ETAEDGE             ELSE $
        SIGEDGE = GRIDINFO.SIGEDGE 

      ; Molecules air / kg air    
        XNumolAir = 6.022d23 / 28.97d-3

      ; G0_100 is 100 / the gravity constant 
        G0_100 =  100e0 / 9.81e0

      ; Compute thickness of each sigma level
;        L      = LMX + 1
;        DSig   = SIGEDGE[0:L-1] - $
;                ( Shift( SIGEDGE, -1 ) )[0:L-2]

 
      ; Basic dimension should be same for each category
        NSITE = N_ELEMENTS(OBS.SITEID)

       ; Retrieve met fields first
        CTM_Get_Data, PresInfo, 'PS-PTOP',  File=FILE, tracer=901  ; hpa
        Ctm_get_Data, TempInfo, 'DAO-3D-$', File=FILE, tracer=1703 ; K
        Ctm_get_Data, RHInfo,   'DAO-3D-$', File=FILE, tracer=1711 ; %
        Ctm_get_Data, AIRDInfo, 'TIME-SER', File=FILE, tracer=1222 ; molec/cm3

;       GetInfo, DataInfo[0], ModelInfo, GridInfo
        Thisinfo = Tempinfo[0]
        IMX      = Thisinfo.dim[0]
        JMX      = Thisinfo.dim[1]
        LMX      = Thisinfo.dim[2]
     
       ; We need offset index because orginal data are extraced over NA
        OFSET    = thisinfo.First - 1L
        I0       = OFSET[0]
        J0       = OFSET[1]
        L0       = OFSET[2]
        I1       = IMX + I0 - 1L
        J1       = JMX + J0 - 1L
        L1       = LMX + L0 - 1L

       ; Find how many taus for met data are present?
        ii       = sort(PresInfo.tau0)
        jj       = uniq(PresInfo[ii].tau0)
        ptau0    = PresInfo[ii[jj]].tau0
        nptime   = n_elements(ptau0)

        PS       = FLTARR( IMX, JMX, NPTIME )
        T3D      = FLTARR( IMX, JMX, LMX, NPTIME )
        P3D      = T3D
        RH       = T3D
        AIRD     = T3D

      ; 3D PRESSURE FIELDS

        PTOP  = GRIDINFO.PEDGE[LMX]

        For D = 0, nptime-1L do begin
           PS[*,*,D]     = *(PresInfo[D].data)
           T3D[*,*,*,D]  = *(tempinfo[D].data)
           RH[*,*,*,D]   = *(rhinfo[D].data)
;           AIRD[*,*,*,D] = AIRQNT( ps=ps[*,*,D], temp=T3D[*,*,*,D],$
;                           gridinfo=gridinfo, P3D=DAT )  ; mole/m3
           AIRD[*,*,*,D] = *(airdinfo[D].data)/6.02E23*1.E6  ; mole/m3

           FOR IZK = 0, LMX-1L DO $
               P3D[*,*,IZK,D] = (PS[*,*,D]-PTOP)*SIGMA(IZK)+PTOP
        End

      ; find the lat, lon, alt index of model for the location of observation
        IF First eq 1L then begin
           index = find_ijl( obs=obs, P3D=P3D[*,*,*,0], Modelinfo=Modelinfo, $
                             fixz=fixz, offset=OFSET )
           First = 0L
        ENDIF

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
        STORE   = FLTARR( IMX, JMX, LMX )

        RHG     = FLTARR( NSITE, NTIME )
        TG      = RHG
        ADG     = RHG
        PG      = RHG
        AVALUE  = RHG
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

              Store[*,*,*] = C   ; ppb
              IC   = WHERE(S EQ TRACERS)             
              IT   = WHERE(TAU0 EQ TIMES)
              PXT  = IT[0]

              if ic[0] eq -1 or it[0] eq -1 then stop
              if names[ic[0]] ne Datainfo[N].tracername then stop

              ; calculate air density
;              pxt0 = locate(tau0, ptau0, cof=cof)
;              pxt  = pxt0[0]
;
;              if pxt lt 0 or pxt gt (nptime-1) then stop

              U = Strmid(Datainfo[N].unit,0,3)
              CASE U of
                    'ppb' : C_FAC = 1.E0  
                    'v/v' : C_FAC = 1.E+9 ; ppbv
                    else  : begin
                            print, U
                            c_fac = 1.
                            unit  = U
                            end
              END

              FOR IS = 0, NSITE-1 DO BEGIN
                 I = INDEX.I[IS]
                 J = INDEX.J[IS]
                 L = INDEX.L[IS]

                 airmass = AIRD[I,J,L,PXT]
                 PRESS3D = P3D[I,J,L,PXT]
                 TEMP3D  = T3D[I,J,L,PXT] 
                 RH3D    = RH[I,J,L,PXT]
                 COND    = STORE[I,J,L]
                 ; Quality check for RH
                 if RH3D gt 100. then RH3D = 100.

                 CONC[IC[0],IS,IT[0]] = COND * C_FAC ; ppbv
                 RHG[IS,IT[0]] = RH3D
                 TG[ IS,IT[0]] = TEMP3D
                 ADG[IS,IT[0]] = airmass
                 PG[IS,IT[0]]  = PRESS3D
              ENDFOR   
        Endfor

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

      ctm_cleanup

      return, calc

   end
