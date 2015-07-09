 pro readmodel_profile,              $
                file,                $
                Category,            $
                file_aird=file_aird, $
                file_pres=file_pres, $
                YYMM=YYMM,           $               
                Modelinfo=Modelinfo, $
                calc=calc,           $
                obs=obs,             $
                all=all,             $
                ug=ug

     If N_elements(file) eq 0 then return
     If N_elements(YYMM) eq 0 then return
     If N_elements(Category) eq 0 then CAtegory = 'IJ-AVG-$'
     If N_elements(Modelinfo) eq 0 then return
     If N_elements(file_aird) eq 0 then file_aird = file
     If N_elements(file_pres) eq 0 then file_pres = file

   ; Basic dimension should be same for each category
     Nmon = N_elements(YYMM)
     Mon  = YYMM-(YYMM/100L)*100L
     Year = YYMM/100L
     Year = Year[0]

   ; Use the observations and synchronize the location between 
   ; the observation and calculation and return the calculation
   ; at observation sites only as a vector.
      Latv = fltarr(N_elements(Obs.lat))
      Lonv = Latv
      Loc  = Latv
      Lop  = Loc

   ; Retriev met fields first
      CTM_Get_Data, AirdInfo, 'BXHGHT-$', Filename=file_aird, tracer=2004
      CTM_Get_Data, PresInfo, 'PS-PTOP',  Filename=file_pres, tracer=1

   ; Retrieve model coordinate and some constants for unit conversion
      GridInfo = CTM_GRID( MOdelInfo )
      A_M2     = CTM_BoxSize( GridInfo, /GEOS, /m2 )
      Volume   = CTM_BOXSIZE( GridInfo, /GEOS, /Volume, /m3 )

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

     FOR ICAT = 0, N_ELEMENTS(CATEGORY)-1 DO BEGIN

       Case STRUPCASE(Category[icat]) of
         'IJ-AVG-$' : begin
                      TAG = 'CONC'   ; pptv
                      unit= 'pptv'
                      If keyword_set(UG) then unit = 'ug/m3'
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
                      return
                      end
       ENDCASE

     ; Retrieve all tracer information together
       CTM_Get_Data, DataInfo, Category[icat], Filename=File

       For ik = 0, Nmon-1 do begin
          tau0 = nymd2tau( YYMM(ik)*100L + 1L, 0L )

             N     = where( tau0[0] eq PresInfo.tau0 )
             Press = *(PresInfo[N].Data) 
             ptop  = gridinfo.pedge[LMX]
             P3D   = fltarr(IMX,JMX,LMX)

           If keyword_set(UG) then begin
             AD = Fltarr( IMX, JMX, LMX )
             IF ( N_elements(AirdInfo) ne 0 ) THEN BEGIN
                  N     = where( tau0[0] eq AirdInfo.tau0 )
                  AD    = *(AirdInfo[N].Data) / 6.022D23 ; mole/m3
             ENDIF ELSE BEGIN
               for L = 0L, LMX - 1L do begin
                  ; Compute air mass [mole/m3]
                AD[*,*,L] = Press[*,*] * DSIG[L] * G0_100 * A_M2[*,*] $
                          * XNumolAir / Volume[*,*,L] / 6.022d23
               endfor
             END
           ENDIF

           ; 3D pressure fields
           for izk = 0, lmx-1L do $
               P3D(*,*,izk) = (Press-ptop)*gridinfo.sigmid(izk)+ptop
             
           Undefine, Press
           Undefine, Volume

          M = where( tau0[0] eq Datainfo.tau0 )
;          If ik eq 0 then $
;              Conc = Fltarr( N_elements(M),Nmon,N_elements(Obs.siteid) )
          If Ik eq 0 then Conc = Fltarr( N_elements(M), N_elements(Obs.day) )
          
          if ik eq 0 then SAVE = fltarr(IMX,JMX,NMON,N_elements(M)) 

          Store = fltarr(IMX,JMX,LMX,N_elements(M))

          for ic = 0, N_elements(M)-1 do begin
               N = M[ic]
               C = *(DataInfo[N].Data) 
               U = Strmid(Datainfo[N].unit,0,3)
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
                          If keyword_set(UG) then begin
;                          Store[0:DI,0:DJ,0:DL,ic] = C * AD[0:DI,0:DJ,0:DL] * c_fac * 1.e+6 
                           For IZ = 0, DL DO Store[0:DI,0:DJ,IZ,ic] = C[*,*,IZ] * AD[0:DI,0:DJ,0] * c_fac * 1.e+6
                          end else Store[*,*,*,ic] = C * 1.e+3    
                    ;      SAVE[*,*,ik,ic] = Store[*,*,0,ic]
                          end
                 'WDLS' : SAVE[*,*,ik,ic] = total(C,3)/A_M2 
                 'WDCV' : SAVE[*,*,ik,ic] = total(C,3)/A_M2 
                 'DRYD' : SAVE[*,*,ik,ic] = C/A_M2
                 ELSE   : print, 'CATAGORY DOES NOT MATCH'
               ENDCASE

              Undefine, C
          endfor
;              Undefine, AD

          ; Read the observations and synchronize the location between 
          ; the observation and calculation and return the calculation
          ; at observation sites only as a vector.

          for is = 0, N_elements(Obs.day)-1 do begin

           if Obs.mon[is] eq Mon[ik] then begin
             CTM_INDEX, ModelInfo, I, J, center = [Obs.lat(is),Obs.lon(is)], $
             /non_interactive

             PZ = P3D(I-1,J-1,*)
             Ht = obs.prs(is)
             DZ = ABS(PZ - Ht)               
             iz = where(Min(DZ) eq Dz)
             Loc(is) = iz
             Lop(is) = P3D(I-1,J-1,iz)

             for ic = 0, N_elements(M)-1 do begin
               if TAG eq 'CONC' then $
               Conc[ic,is] = Store[I-1,J-1,IZ,IC] else $
               Conc[ic,is] = SAVE[I-1,J-1,IK,IC]
               Latv(is)    = gridinfo.ymid(j-1)
               Lonv(is)    = gridinfo.xmid(i-1)
             endfor
           endif

          endfor
          Undefine, Store
      Endfor  ; ik

        For ic = 0, N_elements(M)-1 do begin
            ip = M[ic]
            newname = datainfo[ip].tracername+'_'+TAG
            avalue  = reform(conc[ic,*])
   
            if N_elements(result) eq 0 then $
               result = create_struct( newname, avalue ) $
            else $
               result = create_struct( result, newname, avalue )

            If keyword_set(all) then begin
               newname = datainfo[ip].tracername+'_'+TAG+'_globe'
               avalue  = reform(SAVE[*,*,*,ic])
               result = create_struct( result, newname, avalue )
            endif

        Endfor

        Undefine, DataInfo

        newname = TAG+'_unit'
        result  = create_struct( result, newname, unit )

     ENDFOR ; ICAT
          
      Calc = Create_struct( result,            $
                            'lon',lonv,        $
                            'lat',latv,        $
                            'lev',loc,         $
                            'prs',lop,         $
                            'time',YYMM        )

      Undefine, PresInfo
;      Undefine, AirdInfo

   end
