 pro extract_model_site,  $
     file,                $
     Category,            $
     Tracer=Tracer,       $
     file_aird=file_aird, $
     file_pres=file_pres, $
     Modelinfo=Modelinfo, $
     Siteinfo=Siteinfo,   $
     Fldinfo=Fldinfo

     If N_elements(file) eq 0 then return
     If N_elements(Category) eq 0 then CAtegory = 'IJ-AVG-$'
     If N_elements(Modelinfo) eq 0 then return
     If N_elements(Siteinfo)  eq 0 then return
     If N_elements(file_aird) eq 0 then file_aird = file
     If N_elements(file_pres) eq 0 then file_pres = file

     First = 1L

   ; Use the siteinfo and synchronize the location between 
   ; the observation and calculation and return the calculation
   ; at observation sites only as a vector.
      Latv = fltarr(N_elements(siteinfo.siteid))
      Lonv = Latv
      Loc  = Latv                ; index of model layer sampled 
      Lop  = Loc                 ; index of model pressure sampled

   ; Retriev met fields first
      CTM_Get_Data, AirdInfo, 'BXHGHT-$', Filename=file_aird, tracer=2002 ; Air mass [kg]
      CTM_Get_Data, PresInfo, 'PS-PTOP',  Filename=file_pres, tracer=1
      CTM_Get_Data, HgtInfo,  'BXHGHT-$', Filename=file, tracer=2001      ; Box height [m]
   ; Retrieve model coordinate and some constants for unit conversion
      GridInfo = CTM_GRID( MOdelInfo )
      Area_M2  = CTM_BoxSize( GridInfo, /GEOS, /m2 )

;      GetInfo, DataInfo[0], ModelInfo, GridInfo
      IMX = GridInfo.IMX
      JMX = GridInfo.JMX
      LMX = GridInfo.LMX

      ; Molecules air / kg air    
        XNumolAir = 6.022d23 / 28.97d-3

      ; G0_100 is 100 / the gravity constant 
        G0_100 =  100e0 / 9.81e0

      ; Compute thickness of each sigma level
        L      = LMX + 1
        DSig   = GridInfo.SIGEDGE[0:L-1] - $
                ( Shift( GridInfo.SIGEDGE, -1 ) )[0:L-2]

       Case STRUPCASE(Category) of
         'IJ-AVG-$' : begin
                      TAG = 'CONC'      ; mole/m3
                      unit= 'umole/m3'
                      end
         'WETDLS-$' : begin
                      TAG = 'WDLS'      ; kg/s
                      unit = 'kg/m2/s'
                      end
         'WETDCV-$' : begin
                      TAG = 'WDCV'      ; kg/s
                      unit = 'kg/m2/s' 
                      end
         'DRYD-FLX' : begin
                      TAG = 'DRYD'      ; kg/ts
                      unit = 'kg/m2/ts'
                      end
         'PL-SUL=$' : begin
                      TAG = 'PLS4'
                      unit = 'kg S'
                      end
         ELSE       : begin
                      print, CATEGORY
                      TAG = exchar(CATEGORY,'-','_')
                      end
       ENDCASE

     ; Retrieve all tracer information together
       CTM_Get_Data, DataInfo, Category, Filename=File, Tracer=Tracer

       Conc = Fltarr( N_elements(siteinfo.siteid), N_elements(Datainfo) )      
       TIME = Fltarr( N_elements(Datainfo) )   

       For D = 0, N_Elements(Datainfo)-1 do begin

             tau0  = datainfo[D].tau0
             N     = where( tau0 eq PresInfo.tau0 )
             Press = *(PresInfo[N].Data) 
             ptop  = gridinfo.pedge[LMX]
             P3D   = fltarr(IMX,JMX,LMX)

             N     = where( tau0 eq HgtInfo.tau0 )
             Hgt   = *(HgtInfo[N].Data)
             Vol   = fltarr(IMX,JMX,LMX)  ; Box volume
             for L = 0L, LMX - 1L do $
                 Vol[*,*,L] = Area_M2[*,*] * Hgt[*,*,L]

           If TAG eq 'CONC' then begin
             Airmass = Fltarr( IMX, JMX, LMX )  ; [kg]

             IF ( N_elements(AirdInfo) ne 0 ) THEN BEGIN
                  N              = where( tau0 eq AirdInfo.tau0 )
                  Airmass[*,*,*] = *(AirdInfo[N].Data) / Vol / 28.97d-3 ; mole/m3

             ENDIF ELSE BEGIN
               for L = 0L, LMX - 1L do begin
                  ; Compute air mass [mole/m3]
                  Airmass[*,*,L] = Press[*,*] * DSIG[L] * G0_100 * A_M2[*,*] $
                          * XNumolAir / Vol[*,*,L] / 6.022d23
               endfor
             END
           ENDIF

           ; 3D pressure fields
           FOR IZK = 0, LMX-1L DO $
               P3D(*,*,IZK) = (PRESS-PTOP)*GRIDINFO.SIGMID(IZK)+PTOP
             
           Undefine, Press
           Undefine, Vol
    
           SAVE = fltarr(IMX,JMX) 

           if TAG eq 'CONC' then Store = fltarr(IMX,JMX,LMX)

           C = *(DataInfo[D].Data)
           S = Datainfo[D].tracername
           U = Strmid(Datainfo[D].unit,0,3)

           CASE U of
              'ppb' : c_fac = 1.E-9
              'v/v' : c_fac = 1.
              else  : begin
                         print, U
                         c_fac = 1.
                         unit = U
                      end
           END

           DIM_D = Size(C)
              
           CASE TAG of
                'CONC' : begin
                          DI    = Dim_D[1]-1L
                          DJ    = Dim_D[2]-1L
                          DL    = Dim_D[3]-1L
                          If S eq 'O3' then Store[0:DI,0:DJ,0:DL] = C   else  $  ; ppb
                          Store[0:DI,0:DJ,0:DL] = C * Airmass[0:DI,0:DJ,0:DL] * c_fac * 1.e+6  ; ppbv -> v/v -> umole/m3
                          SAVE[*,*] = Reform(Store[*,*,0])                      ; Surface concentration
                          end
                 'WDLS' : SAVE[*,*] = total(C,3)/A_M2 
                 'WDCV' : SAVE[*,*] = total(C,3)/A_M2 
                 'DRYD' : SAVE[*,*] = C/A_M2
                 'PLS4' : SAVE[*,*] = total(C[*,*,0:8],3)/A_M2
                 ELSE   : begin
                          if DIM_D[0] eq 2 then SAVE[*,*] = C/A_M2
                          if DIM_D[0] eq 3 then SAVE[*,*] = total(C,3)/A_M2
                          end
           ENDCASE

              Undefine, C
              Undefine, Airmass

          ; Read the observations and synchronize the location between 
          ; the observation and calculation and return the calculation
          ; at observation sites only as a vector.

          IF First eq 1L then begin

             INDEX_I = REPLICATE(0L,N_ELEMENTS(SITEINFO.SITEID))
             INDEX_J = INDEX_I
             INDEX_L = INDEX_I

             FOR IS = 0, N_ELEMENTS(SITEINFO.SITEID)-1 DO BEGIN
                CTM_INDEX, MODELINFO, I, J, CENTER = [SITEINFO.LAT(IS),SITEINFO.LON(IS)], $
                /NON_INTERACTIVE

                PZ = Reform(P3D[I-1,J-1,*])  ; Profile of pressure at particular point
                PZ = PtZ(Pz)                 ; Conversion from press to altitude (std atmosphere)
                Ht = SITEINFO.elev(is)/1000. ; Conversion of observation altitude at site (m -> km)
                DZ = ABS(PZ - Ht)            ; Difference between model and observation height
                iz = where(Min(DZ) eq Dz)    ; Find minimum different which is the model layer
                if n_elements(fixz) ne 0 then iz = fixz
                Loc(is) = iz[0]
                Lop(is) = P3D(I-1,J-1,iz)
                INDEX_I[IS] = I-1
                INDEX_J[IS] = J-1
                INDEX_L[IS] = IZ[0]
                Latv(is)    = gridinfo.ymid(j-1)
                Lonv(is)    = gridinfo.xmid(i-1)
             ENDFOR

             First = 0L
          ENDIF

          for is = 0, N_elements(SITEINFO.SITEID)-1 do begin
              I = INDEX_I[IS]
              J = INDEX_J[IS]
              L = INDEX_L[IS]
              if TAG eq 'CONC' then $
                  Conc[is,D] = Store[I,J,L] else  Conc[is,D] = SAVE[I,J]
          endfor ; is

          Undefine, Store

          TIME[D] = Long(tau0)

      Endfor  ; Datainfo

      species = datainfo[0].tracername
      CUnit   = TAG+'_unit'
      
      Fldinfo = Create_struct( 'tracername', species,      $
                               TAG,   conc,                $
                               'TAU', TIME,                $
                               CUnit,   unit,              $
                               'siteid',siteinfo.siteid,   $
                               'lon', lonv,        $
                               'lat', latv,        $
                               'loc', loc,         $
                               'lop', lop          )

      Undefine, DataInfo
      UNDEFINE, SAVE
      Undefine, PresInfo
      Undefine, AirdInfo

   end
