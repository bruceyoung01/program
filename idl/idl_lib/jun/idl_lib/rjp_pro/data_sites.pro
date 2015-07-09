 pro datafind,            $
     Data,                $
     YYMM=YYMM,           $               
     Modelinfo=Modelinfo, $
     calc=calc,           $
     obs=obs,             $
     fixz=fixz

     If N_elements(Data) eq 0 then return
     If N_elements(YYMM) eq 0 then return
     If N_elements(Modelinfo) eq 0 then return

    file_pres = '~rjp/Asim/data/ps-ptop_2x25_1998.bpch'

     First = 1L

   ; Basic dimension should be same for each category
     Nmon = N_elements(YYMM)
     Mon  = YYMM-(YYMM/100L)*100L
     Year = YYMM/100L
     Year = Year[0]

   ; Use the observations and synchronize the location between 
   ; the observation and calculation and return the calculation
   ; at observation sites only as a vector.
      Latv = fltarr(N_elements(Obs.siteid))
      Lonv = Latv
      Loc  = Latv
      Lop  = Loc

   ; Retriev met fields first
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

       For ik = 0, Nmon-1 do begin

          tau0  = nymd2tau( YYMM(ik)*100L + 1L, 0L )

          N     = where( tau0[0] eq PresInfo.tau0 )
          Press = *(PresInfo[N].Data) 
          ptop  = gridinfo.pedge[LMX]
          P3D   = fltarr(IMX,JMX,LMX)

           ; 3D pressure fields
           for izk = 0, lmx-1L do $
               P3D(*,*,izk) = (Press-ptop)*gridinfo.sigmid(izk)+ptop
             
           Undefine, Press
           Undefine, Volume

          ; Read the observations and synchronize the location between 
          ; the observation and calculation and return the calculation
          ; at observation sites only as a vector.

          IF First eq 1L then begin

             INDEX_I = REPLICATE(0L,N_ELEMENTS(OBS.SITEID))
             INDEX_J = INDEX_I
             INDEX_L = INDEX_I

             for is = 0, N_elements(Obs.siteid)-1 do begin
                CTM_INDEX, ModelInfo, I, J, center = [Obs.lat(is),Obs.lon(is)], $
                /non_interactive

                PZ = P3D(I-1,J-1,*)
                PZ = PtZ(Pz)
                Ht = obs.elev(is)/1000.
                DZ = ABS(PZ - Ht)
                iz = where(Min(DZ) eq Dz)
                if n_elements(fixz) ne 0 then iz = fixz
                Loc(is) = iz
                Lop(is) = P3D(I-1,J-1,iz)
                INDEX_I[IS] = I-1
                INDEX_J[IS] = J-1
                INDEX_L[IS] = IZ[0]
                Latv(is)    = gridinfo.ymid(j-1)
                Lonv(is)    = gridinfo.xmid(i-1)
             endfor
             First = 0L
          ENDIF

          If ik eq 0 then $
              Conc = Fltarr( N_elements(Obs.siteid), Nmon )


          for is = 0, N_elements(Obs.siteid)-1 do begin
              I = INDEX_I[IS]
              J = INDEX_J[IS]
              L = INDEX_L[IS]
              Conc[is,ik] = Data[I,J,L,IK]
          endfor ; is
      Endfor ; ik

      result = create_struct( 'model', conc )         
      Calc   = Create_struct( result,                $
                            'siteid',Obs.siteid,   $
                            'lon',lonv,        $
                            'lat',latv,        $
                            'loc',loc,         $
                            'lop',lop,         $
                            'time',YYMM        )

      Undefine, PresInfo

   end


 function usonly, fd2d

   USFLAG = fltarr(144,91)    
   Openr,il,'/users/ctm/rjp/Data/MAP/UScont.map_2x25.bin',/f77,/get
    readu,il,usflag
   free_lun,il

   for t = 0, 11 do begin
   for j = 0, 90 do begin
   for i = 0, 143 do begin
     if usflag(i,j) ne 1. then fd2d(i,j,*) = -1.
   endfor
   endfor
   endfor

  return, fd2d

 end


 pro Bext, conc=conc, fac=fac

; basically 3D array (X,Y,T)
  Dim = size(conc,/dim)
  Temp = reform(conc)

  ModelInfo = CTM_TYPE( 'GEOS3_30L', res=2 )
  Grid  = CTM_GRID( ModelInfo )

  ; Applicable for 4 component simulation

  temp = usonly(temp)
  West = fltarr(12) & East = West

  for t = 0, 11 do begin
    Iw  = 0L & ie = 0L
    for i = 0, 143 do begin
    for j = 0, 90 do begin
      if temp(i,j,t) ge 0. then begin
        if grid.xmid(i) le -95. then begin
           West[t] = West[t] + Temp(i,j,t)
           iw  = iw  + 1L
        endif else begin
           East[t] = East[t] + Temp(i,j,t)
           ie  = ie  + 1L
        end
      endif
    endfor
    endfor
     West[t] = West[t] / float(iw)
     East[t] = East[t] / float(ie)
  endfor
  
  print, total(West)*fac/12., total(East)*fac/12., '  West vs East'

  print, iw, ie

 end


 pro EAST, conc=conc, fac=fac

; basically 3D array (X,Y,T)
  Dim = size(conc,/dim)
  Temp = reform(conc)

  ModelInfo = CTM_TYPE( 'GEOS3_30L', res=2 )
  Grid  = CTM_GRID( ModelInfo )

  ; Applicable for 4 component simulation

  temp   = usonly(temp)
  S_East = fltarr(12) & N_east = S_East

  for t = 0, 11 do begin
    Is  = 0L & in = 0L
    for i = 0, 143 do begin
    for j = 0, 90 do begin
      if (temp(i,j,t) ge 0.) and (grid.xmid(i) gt -95.) then begin
        if grid.ymid(j) gt 37. then begin
           N_EAST[t] = N_EAST[t] + Temp(i,j,t)
           in  = in  + 1L
        endif else begin
           S_East[t] = S_East[t] + Temp(i,j,t)
           is  = is  + 1L
        end
      endif
    endfor
    endfor
     N_East[t] = N_east[t] / float(in)
     S_East[t] = S_East[t] / float(is)
  endfor
  
  print, total(N_East)*fac/12., total(S_East)*fac/12., '  N_East vs S_East'

  print, in, is

 end

; ONLY READ BIOGENIC OC

 If N_elements(OC) eq 0 then begin

   Spawn, 'ls ctm.bpch_98*', files

   OC = fltarr(144,91,30,12)

   For D = 0, N_elements(files)-1 do begin

    print, 'processing with files ', files[D]

    ctm_get_data, Datainfo, 'ij-avg-$', file=files[D], tracer=87
    ctm_get_data, airdinfo, 'BXHGHT-$', File=Files[D], tracer=2004
    AD = *(AirdInfo.Data) / 6.022d23 ; mole/m3

    For N = 0, N_elements(Datainfo)-1 do begin
     Data = *(Datainfo[N].data) ; v/v
     Data = Data * AD ; mole/m3

     OC[*,*,*,D] = OC[*,*,*,D] + Data[*,*,*]*12.e6      ; ug/m3 

     Undefine, Data
    Endfor ; N

    Undefine, AD
    Undefine, Datainfo
    Undefine, airdinfo
    ctm_cleanup
   Endfor ; D

;   TEC = Reform(EC[*,*,0,*])
   TOC = Reform(OC[*,*,0,*])

;   print, 'EC'
;   Bext, conc=TEC, fac=0.83

   print, 'OC'
   Bext, conc=TOC, fac=1.11

 Endif

 ;=========================================================================;

  Year = 2001L
  DXDY = '2x25'

 ;=========================================================================;

  CASE DXDY of
   '2x25' : RES = 2
   '4x5'  : RES = 4
  END

  YYMM  = Year*100L + Lindgen(12)+1L

; Observations are in ug/m3
  if N_elements(improve_Obs) eq 0 then $
     improve_Obs  = improve_datainfo(year=2001)

  if N_elements(OCconc) eq 0 then begin

     Modelinfo = CTM_TYPE('GEOS3_30L', RES=RES)

;     Data = EC * 0.83
;     datafind,  Data, YYMM=YYMM,      $
;                Modelinfo=Modelinfo,  $
;                calc= ECconc,           $
;                obs = Improve_obs

     Data = OC * 1.11
     datafind,  Data, YYMM=YYMM,      $
                Modelinfo=Modelinfo,  $
                calc= OCconc,           $
                obs = Improve_obs, fixz = 0L

  endif


   print, 'Biogenic OC in the United States'
   Bext, conc=TOC, fac=1.11

   print, 'Biogenic OC in the EAST'
   EAST, conc=TOC, fac=1.11

  stop

  SITE = ['ACAD','BIBE','GRSM','GRCA','MORA']
  ID = -1
  For D = 0, N_elements(SITE)-1 do $
      ID = [ID, where(improve_obs.siteid eq SITE[D])]
 
  ID = ID[1:*]

  For D = 0, N_elements(ID)-1 do begin

;    Annual = total(ECconc.model[ID[D],*])/12.
;    print, improve_obs.siteid[ID[D]], $
;           annual, ECconc.model[ID[D],*], 'EC biomass(ug/m3)', format='(A4, 13F8.3, A25)'

    Annual = total(OCconc.model[ID[D],*])/12.
    print, improve_obs.siteid[ID[D]], $
           annual, OCconc.model[ID[D],*], 'OC biogenic(ug/m3)', format='(A4, 13F8.3, A25)'
  end

  annual_toc = total(toc,3)/12.
 

    C = MYCT_Defaults()
   if ( N_Elements( BLACK  ) eq 0 ) then BLACK = C.BLACK
   if ( N_Elements( Bottom  ) eq 0 ) then Bottom  = C.BOTTOM
   if ( N_Elements( NColors ) eq 0 ) then NColors = C.NCOLORS
   if ( N_Elements( CBar      ) eq 0 ) then CBar      = 0
   if ( N_Elements( CBColor   ) eq 0 ) then CBColor   = BLACK
   if ( N_Elements( Divisions ) eq 0 ) then Divisions = 2
   if ( N_Elements( CBUnit    ) eq 0 ) then CBUnit    = ''


 if (!D.name eq 'PS') then $
    open_device, file='biogenic_conc_oc.ps', /ps, /color, $
     /portrait, xsize=7.5, ysize=10. 

  multipanel, row=1, col=1

  plot_region, annual_toc, /conti, /sample, divis=4, /rjpmap, $
    title='Annual mean biogenic OC concentrations', $
    Data=Data

  For D = 0, N_elements(SITE)-1 do $
      xyouts, improve_obs.lon[ID[D]], improve_obs.lat[ID[D]], $
              site[D], color=1, alignment=0.5


    CBMin = Min(Data)
    CBMax = Max(Data)
    CBUnit = '!4l!3g m!u-3!n'
    CBPosition = [ 0.20, 0.10, 0.80, 0.12 ]
   
    ColorBar, Max=CBMax,        Min=CBMin,           NColors=NColors,     $
              Bottom=Bottom,    Color=CBColor,       Position=CBPosition, $
              Unit=CBUnit,      Divisions=4,         Log=Log,             $
              Format=CBFormat,  Charsize=csfac,       $
              C_Colors=CC_Colors, C_Levels=C_Levels,  _EXTRA=e


 if (!D.name eq 'PS') then close_device
 

 
 End
