 function l_find, obs=obs, index=index, PS=PS, Modelinfo=Modelinfo, fixz=fixz

   if N_elements(obs) eq 0 then return, -1
   if N_elements(Modelinfo) eq 0 then return, -1
   if N_elements(PS) eq 0 then return, -1

      GridInfo = CTM_GRID( MOdelInfo )

   ; Use the observations and synchronize the location between 
   ; the observation and calculation and return the calculation
   ; at observation sites only as a vector.
      SITEID= OBS.SITEID
      NSITE = N_ELEMENTS(index.i)
      Loc   = fltarr(NSITE)
      Lop   = fltarr(NSITE)

      INDEX_L = REPLICATE(0L, NSITE)
         ELEV = OBS.ELEV

      if N_elements(fixz) ne 0 then begin
         INDEX_L[*] = fixz
         goto, skip
      endif

      for is = 0, NSITE - 1 do begin

          I = index.i[is]
          J = index.j[is]

          pedge = get_pedge( ps[i,j], modelinfo=modelinfo )
          press = ((shift(pedge,1))[1:*] + pedge[1:*])*0.5

          if Total(press) le 0 then begin
             print, 'something wrong with data'
             stop
          end

          PZ = PtZ(press)
          Ht = elev[is]/1000.
          DZ = ABS(PZ - Ht)
          iz = where(Min(DZ) eq Dz)
          Loc(is) = iz[0]
          Lop(is) = press(iz[0])

          INDEX_L[IS] = IZ[0]

          if (dz[iz[0]] gt 1.) then print, Ht, PZ[iz[0]], Lop[is], SITEID[is]

      endfor

      skip:

      Index = Create_struct( index,                $
                             'L',INDEX_L, 'LOC',Loc, 'LOP',Lop )

   return, Index

 end

