 function find_ijl, obs=obs, P3D=P3D, Modelinfo=Modelinfo, fixz=fixz, offset=offset

   if N_elements(obs) eq 0 then return, -1
   if N_elements(Modelinfo) eq 0 then return, -1
   if N_elements(P3D) eq 0 then return, -1

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
          INDEX_I[IS] = I1
          INDEX_J[IS] = J1
          INDEX_L[IS] = IZ[0]
          if N_elements(fixz) ne 0 then INDEX_L[IS] = fixz
          Latv(is)    = ymid(J1)
          Lonv(is)    = xmid(I1)

          err_x = ABS(Lonv(is)-Obs.lon(is))
          err_y = ABS(Latv(is)-Obs.lat(is))

          ; Error check for finding ij
          if (err_x gt GridInfo.di*0.5) or (err_y gt Gridinfo.dj*0.5) then begin
              print, err_x, err_y, dz[iz[0]], obs.siteid[is]
              stop
          endif
          if (dz[iz[0]] gt 1.) then print, Ht, PZ[iz[0]], Lop[is], obs.siteid[is]

      endfor

   return, {I:INDEX_I, J:INDEX_J, L:INDEX_L, LATV:Latv, LONV:Lonv, $
            LOC:Loc, LOP:Lop}

 end

;--------------------------------------------------------------------------

 PRO READ_MODEL,          $
     FILE,                $
     CATEGORY,            $
     TRACER=TRACER,       $
     FILE_AIRD=FILE_AIRD, $
     FILE_PRES=FILE_PRES, $
     YYMM=YYMM,           $               
     MODELINFO=MODELINFO, $
     CALC=CALC,           $
     OBS=OBS,             $
     FIXZ=FIXZ,           $
     ALL=ALL

     If N_elements(file) eq 0 then return
     If N_elements(YYMM) eq 0 then return
     If N_elements(Category) eq 0 then CAtegory = 'IJ-AVG-$'
     If N_elements(Modelinfo) eq 0 then return
     If N_elements(file_aird) eq 0 then file_aird = file
     If N_elements(file_pres) eq 0 then file_pres = file

     First = 1L

   ; Basic dimension should be same for each category
     Nmon  = N_elements(YYMM)
     Mon   = YYMM-(YYMM/100L)*100L
     Year  = YYMM/100L
     Year  = Year[0]
     NSITE = N_ELEMENTS(OBS.SITEID)

   ; Retriev met fields first
      CTM_Get_Data, AirdInfo, 'BXHGHT-$', Filename=file_aird, tracer=2004
      CTM_Get_Data, PresInfo, 'PS-PTOP',  Filename=file_pres, tracer=1

   ; Retrieve model coordinate and some constants for unit conversion
      GridInfo = CTM_GRID( MOdelInfo )
      A_M2     = CTM_BoxSize( GridInfo, /GEOS, /m2 )
      Volume   = CTM_BOXSIZE( GridInfo, /GEOS, /Volume, /m3 )
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

;      GetInfo, DataInfo[0], ModelInfo, GridInfo
;      IMX = GridInfo.IMX
;      JMX = GridInfo.JMX
;      LMX = GridInfo.LMX

        Thisinfo = AirdInfo[0]
        IMX = Thisinfo.dim[0]
        JMX = Thisinfo.dim[1]
        LMX = Thisinfo.dim[2]

       ; We need offset index because orginal data are extraced over NA
        OFSET = thisinfo.First - 1L
        I0    = OFSET[0]
        J0    = OFSET[1]
        L0    = OFSET[2]
        I1    = IMX + I0 - 1L
        J1    = JMX + J0 - 1L
        L1    = LMX + L0 - 1L

      ; Compute thickness of each sigma level
        L      = LMX + 1
        DSig   = SIGEDGE[0:L-1] - $
                ( Shift( SIGEDGE, -1 ) )[0:L-2]

     ; Loop over Category
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
            'PL-SUL=$' : begin
                         TAG = 'PLS4'
                         unit = 'kg S'
                         end
            ELSE       : begin
                         print, CATEGORY[ICAT]
                         TAG = exchar(CATEGORY[ICAT],'-','_')
                         TAG = exchar(TAG,'=','_')
                         end
          ENDCASE

          ; Retrieve data information
          CTM_Get_Data, DataInfo, Category[icat], $
                        Filename=File, Tracer=Tracer

          ; LOOP OVER TIME
          FOR IK = 0, NMON-1 DO BEGIN
              TAU0 = NYMD2TAU( YYMM(IK)*100L + 1L, 0L )

              ; FIND THE NUMBER OF MATCHING TRACERS AT TAU0        
              N_TR  = WHERE( TAU0[0] EQ DATAINFO.TAU0 ) 
              NSPEC = N_ELEMENTS(N_TR)

              ; 3D PRESSURE FIELDS
              N     = WHERE( TAU0[0] EQ PRESINFO.TAU0 )
              PRESS = *(PRESINFO[N].DATA) 
              PTOP  = GRIDINFO.PEDGE[LMX]
              P3D   = FLTARR(IMX,JMX,LMX)        
              FOR IZK = 0, LMX-1L DO $
                  P3D(*,*,IZK) = (PRESS-PTOP)*SIGMA(IZK)+PTOP

             ; Read the observations and synchronize the location between 
             ; the observation and calculation and return the calculation
             ; at observation sites only as a vector.
             IF First eq 1L then begin
                index = find_ijl( obs=obs, P3D=P3D, Modelinfo=Modelinfo, fixz=fixz, $
                        offset=OFSET )
                First = 0L
             ENDIF

              ; IF we retrive tracer concentrations then need air mass information
              ; for unit conversion from volume to mass concentrations
              IF TAG EQ 'CONC' THEN BEGIN
                 AD = FLTARR( IMX, JMX, LMX )
                 IF ( N_ELEMENTS(AIRDINFO) NE 0 ) THEN BEGIN
                     N     = WHERE( TAU0[0] EQ AIRDINFO.TAU0 )
                     AD    = *(AIRDINFO[N].DATA) / 6.022D23 ; MOLE/M3
                 ENDIF ELSE BEGIN

                   FOR L = 0L, LMX - 1L DO BEGIN
                       ; COMPUTE AIR MASS [MOLE/M3] USING PRESSURE DATA
                       AD[*,*,L] = PRESS[*,*] * DSIG[L] * G0_100 * A_M2[*,*] $
                                 * XNUMOLAIR / VOLUME[*,*,L] / 6.022D23
                   ENDFOR
                 END

                 STORE = FLTARR( IMX, JMX, LMX, NSPEC )
              ENDIF

              UNDEFINE, PRESS
              UNDEFINE, VOLUME
              UNDEFINE, P3D

              IF IK EQ 0 THEN BEGIN
                 CONC = FLTARR( NSPEC, NSITE, NMON )
                 SAVE = FLTARR( IMX, JMX, NMON, NSPEC ) 
              END

              ; Loop over tracers
              FOR IC = 0, NSPEC-1 DO BEGIN
                  N = N_TR[ic]
                  
                  U = Strmid(Datainfo[N].unit,0,3)
                  CASE U of
                    'ppb' : C_FAC = 1.E-3 ; 1.E-9 * 1.E+6, ppb => umole
                    'v/v' : C_FAC = 1.E+6 ; 1.E+6
                    else  : begin
                            print, U
                            c_fac = 1.
                            unit  = U
                            end
                  END

                  C     = *(DataInfo[N].Data)
                  DIM1  = Size(C)
                  S     = Datainfo[N].tracername
                  DIM0  = DataInfo[N].First - 1L
                  I0    = DIM0[0]
                  J0    = DIM0[1]
                  L0    = DIM0[2]
                  I1    = Dim1[1] + I0 - 1L
                  J1    = Dim1[2] + J0 - 1L
                  L1    = Dim1[3] + L0 - 1L

                  CASE TAG of
                    'CONC' : begin
                               If S eq 'O3' then $
                                  Store[*,*,*,IC] = C  else  $  ; ppb
                                  Store[*,*,*,ic] = C * AD[*,*,*] * C_FAC  ; ppbv -> v/v * umole
                                  SAVE[*,*,ik,ic] = Store[*,*,0,ic]         ; Surface concentration
                             end
                    'WDLS' : SAVE[*,*,ik,ic] = total(C,3)/A_M2[I0:I1,J0:J1]
                    'WDCV' : SAVE[*,*,ik,ic] = total(C,3)/A_M2[I0:I1,J0:J1] 
                    'DRYD' : SAVE[*,*,ik,ic] = C/A_M2[I0:I1,J0:J1]
                    'PLS4' : SAVE[*,*,ik,ic] = total(C[*,*,0:8],3)/A_M2[I0:I1,J0:J1]
                    ELSE   : begin
                             if DIM1[0] eq 2 then SAVE[*,*,ik,ic] = C          ; /A_M2[I0:I1,J0:J1]
                             if DIM1[0] eq 3 then SAVE[*,*,ik,ic] = total(C,3) ; /A_M2[I0:I1,J0:J1]
                             end
                  ENDCASE

                 UNDEFINE, C
              ENDFOR
             
              UNDEFINE, AD


              FOR IS = 0, NSITE-1 DO BEGIN
                 I = INDEX.I[IS]
                 J = INDEX.J[IS]
                 L = INDEX.L[IS]
                 IF N_ELEMENTS(FIXZ) NE 0 THEN L = FIXZ
              
                 FOR IC = 0, NSPEC-1 DO BEGIN
                   IF TAG EQ 'CONC' THEN $
                      CONC[IC,IS,IK] = STORE[I,J,L,IC] ELSE $
                      CONC[IC,IS,IK] = SAVE[I,J,IK,IC]
                 ENDFOR  ; IC
              ENDFOR     ; IS

              Undefine, Store
           Endfor


           FOR IC = 0, NSPEC-1 DO BEGIN
               IP = N_TR[IC]
               NEWNAME = DATAINFO[IP].TRACERNAME+'_'+TAG
               AVALUE  = REFORM(CONC[IC,*,*])
   
               IF N_ELEMENTS(RESULT) EQ 0 THEN $
                  RESULT = CREATE_STRUCT( NEWNAME, AVALUE ) $
               ELSE $
                  RESULT = CREATE_STRUCT( RESULT, NEWNAME, AVALUE )

               IF KEYWORD_SET(ALL) THEN BEGIN
                  NEWNAME = DATAINFO[IP].TRACERNAME+'_'+TAG+'_GLOBE'
                  AVALUE  = REFORM(SAVE[*,*,*,IC])
                  RESULT  = CREATE_STRUCT( RESULT, NEWNAME, AVALUE )
               ENDIF

           ENDFOR

           Undefine, DataInfo
           UNDEFINE, SAVE

           NEWNAME = TAG+'_UNIT'
           RESULT = CREATE_STRUCT( RESULT, NEWNAME, UNIT )

     ENDFOR ; ICAT
          
      Calc = Create_struct( result,                $
                            'siteid',Obs.siteid,   $
                            'lon',index.lonv,        $
                            'lat',index.latv,        $
                            'loc',index.loc,         $
                            'lop',index.lop,         $
                            'time',YYMM,             $
                            'offset', ofset         )

      Undefine, PresInfo
      Undefine, AirdInfo

   end
