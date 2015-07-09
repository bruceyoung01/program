
;=============================================================================

  function AIRQNT, ps=ps, temp=temp, gridinfo=gridinfo, P3D=P3D

     if n_elements(ps) eq 0 then return, -1
     if n_elements(temp) eq 0 then return, -1

     g0       =   9.8d0    
     Rd       = 287.0d0      
     Rdg0     =   Rd / g0
     g0_100   = 100d0 / g0
     Area     = CTM_BoxSize( GridInfo, /GEOS, /m2 )

     ; Molecules air / kg air    
     XNumolAir = 6.022d23 / 28.97d-3

     ; AIRMW : Molecular weight of air [28.97 g/mole]
     AIRMW    =  28.97d-3

     Ndim     = size(temp,/dim)
     AIRDEN   = fltarr(ndim[0],ndim[1],ndim[2])
     P3D      = AIRDEN

     for J = 0, ndim[1]-1L do begin
     for I = 0, ndim[0]-1L do begin

         ; Grid box surface area [m2]
         AREA_M2 = AREA(I,J)

         if ps(i,j) le 0. then goto, jump  
         if temp(i,j,l) le 0. then goto, jump
          
         pedge = get_pedge( ps[I,J], modelinfo=modelinfo )

         for L = 0, 15 do begin

            ; Pressure at bottom edge of grid box [hPa]
            P1   = pedge[L] 

            ; Pressure at top edge of grid box [hPa]
            P2   = pedge[L+1]

            ; Pressure difference between top & bottom edges [hPa]
            DELP = P1 - P2


            P3D[I,J,L] = (P1 + P2) * 0.5
            
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

;--------------------------------------------------------------------------

 PRO READ_MODEL_at_site,  $
     FILE,                $
     CATEGORY,            $
     TRACER=TRACER,       $
     FILE_AIRD=FILE_AIRD, $
     FILE_PRES=FILE_PRES, $
     YYMM=YYMM,           $               
     MODELINFO=MODELINFO, $
     GridInfo=Gridinfo,   $
     CALC=CALC,           $
     OBS=OBS,             $
     FIXZ=FIXZ,           $
     LEV=LEV

     If N_elements(file) eq 0 then return
     If N_elements(YYMM) eq 0 then return
     If N_elements(Category) eq 0 then CAtegory = 'IJ-AVG-$'
;     If N_elements(Modelinfo) eq 0 then return
     If N_elements(file_aird) eq 0 then file_aird = file
     If N_elements(file_pres) eq 0 then file_pres = file
     if N_elements(LEV)       eq 0 then LEV = 0L

     First = 1L

   ; Basic dimension should be same for each category
     NMON  = N_elements(YYMM)
     Mon   = YYMM-(YYMM/100L)*100L
     Year  = YYMM/100L
     Year  = Year[0]
     SITEID= OBS.SITEID
     NSITE = N_ELEMENTS(SITEID)

   ; Retriev met fields first
     CTM_Get_Data, AirdInfo, 'BXHGHT-$', Filename=file_aird, tracer=2004
     CTM_Get_Data, PresInfo, 'PS-PTOP',  Filename=file_pres, tracer=1

   ; Retrieve model coordinate and some constants for unit conversion
   ; Get MODELINFO and GRIDINFO structures, assume that
   ; all data blocks in the punch file are on the same grid
   ; (which is 99.999999999% true for most cases)
      GetModelAndGridInfo, PresInfo[0], ModelInfo, GridInfo

;      GridInfo = CTM_GRID( MOdelInfo )
      A_M2     = CTM_BoxSize( GridInfo, /GEOS, /m2 )
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

      RHG      = FLTARR( NSITE, NMON )
      TG       = RHG
      ADG      = RHG
      PG       = RHG

     ; Loop over Category
     FOR ICAT = 0, N_ELEMENTS(CATEGORY)-1 DO BEGIN

          ; Retrieve data information
          CTM_Get_Data, DataInfo, Category[icat], $
                        Filename=File, Tracer=Tracer

          Case STRUPCASE(Category[icat]) of
            'IJ-AVG-$' : begin
                         TAG = 'CONC'   ; mole/m3
                         unit= Datainfo[0].unit
                         end
            'IJ-24H-$' : begin
                         TAG = 'CONC'   ; mole/m3
                         unit= Datainfo[0].unit
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


          Thisinfo = Datainfo[0]
          IMX      = Thisinfo.dim[0]
          JMX      = Thisinfo.dim[1]
          LMX      = Thisinfo.dim[2]

          ; LOOP OVER TIME
          FOR IK = 0, NMON-1 DO BEGIN
              TAU0 = NYMD2TAU( YYMM(IK)*100L + 1L, 0L )

              ; FIND THE NUMBER OF MATCHING TRACERS AT TAU0        
              N_TR  = WHERE( TAU0[0] EQ DATAINFO.TAU0 ) 
              NSPEC = N_ELEMENTS(N_TR)

             ; Read the observations and synchronize the location between 
             ; the observation and calculation and return the calculation
             ; at observation sites only as a vector.
              N     = WHERE( TAU0[0] EQ PRESINFO.TAU0 )
              PS    = *(PRESINFO[N].DATA) + PTOP    ; real surface pressure [hPa]

             IF First eq 1L then begin
                index = ij_find( obs=obs, Modelinfo=Modelinfo, offset=OFSET )

                index = l_find(  obs=obs, index=index, PS=PS, Modelinfo=Modelinfo, fixz=fixz )

                First = 0L
             ENDIF

              ; IF we retrive tracer concentrations then need air mass information
              ; for unit conversion from volume to mass concentrations
             IF ( N_ELEMENTS(AIRDINFO) NE 0 ) THEN BEGIN
                 ; if airmass data are archived
                 N     = WHERE( TAU0[0] EQ AIRDINFO.TAU0 )
                 AD    = *(AIRDINFO[N].DATA) / 6.022D23 ; MOLE/M3

                 FOR IS = 0, NSITE-1 DO BEGIN
                     I = INDEX.I[IS]
                     J = INDEX.J[IS]
                     L = INDEX.L[IS]

                     ADG[IS,IK] = AD[I,J,L]  ; Vection of airden at each site
                 ENDFOR

                 UNDEFINE, AD

             ENDIF ELSE BEGIN

                ; if not then we compute it using press and temp
                 FOR IS = 0, NSITE-1 DO BEGIN
                     I = INDEX.I[IS]
                     J = INDEX.J[IS]
                     L = INDEX.L[IS]

                     CTM_Get_Data, TempInfo, 'DAO-3D-$', Filename=file, $
                            tracer=1703, tau0=TAU0[0]
                     TEMP = *(TEMPINFO.data)

                     pedge = get_pedge( ps[I,J], modelinfo=modelinfo )
                     ADG[IS,IK] = get_airden( p1=pedge[L], p2=pedge[L+1], $
                                  temp=temp[I,J,L], Area_m2=Area_m2[I+I0,J+J0] )                    
                 ENDFOR

                       ; COMPUTE AIR MASS [MOLE/M3] USING PRESSURE DATA
;                       AD[*,*,L] = PRESS[*,*] * DSIG[L] * G0_100 * A_M2[*,*] $
;                                 * XNUMOLAIR / VOLUME[*,*,L] / 6.022D23
              END

              UNDEFINE, PS

              IF IK EQ 0 THEN CONC = FLTARR( NSPEC, NSITE, NMON )

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

                  FOR IS = 0, NSITE-1 DO BEGIN
                       I = INDEX.I[IS]
                       J = INDEX.J[IS]
                       L = INDEX.L[IS]

                     CASE TAG of
                       'CONC' : CONC[IC,IS,IK] = C[I,J,L] ; ppb
                       'WDLS' : CONC[IC,IS,IK] = total(C[I,J,*],3)/A_M2[I+I0,J+J0]
                       'WDCV' : CONC[IC,IS,IK] = total(C[I,J,*],3)/A_M2[I+I0,J+J0]
                       'DRYD' : CONC[IC,IS,IK] = C[I,J]/A_M2[I+I0,J+J0]
                       'PLS4' : CONC[IC,IS,IK] = total(C[I,J,0:8],3)/A_M2[I+I0,J+J0]
                     ENDCASE

                  Endfor

                 UNDEFINE, C
              ENDFOR ; do spec             

           Endfor ; do month


           FOR IC = 0, NSPEC-1 DO BEGIN
               IP = N_TR[IC]
               NEWNAME = DATAINFO[IP].TRACERNAME+'_'+TAG
               AVALUE  = REFORM(CONC[IC,*,*])
   
               IF N_ELEMENTS(RESULT) EQ 0 THEN $
                  RESULT = CREATE_STRUCT( NEWNAME, AVALUE ) $
               ELSE $
                  RESULT = CREATE_STRUCT( RESULT, NEWNAME, AVALUE )

           ENDFOR

           Undefine, DataInfo
           UNDEFINE, SAVE

           NEWNAME = TAG+'_UNIT'
           RESULT = CREATE_STRUCT( RESULT, NEWNAME, UNIT )

     ENDFOR ; ICAT
          
      Calc = Create_struct( result,                  $
                            'AD', ADG,               $
                            'siteid',SITEID,         $
                            'lon',index.lonv,        $
                            'lat',index.latv,        $
                            'loc',index.loc,         $
                            'lop',index.lop,         $
                            'time',YYMM,             $
                            'offset', ofset         )

      Undefine, PresInfo
      Undefine, AirdInfo

   end
