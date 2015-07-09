 function ij_find, obs=obs, Modelinfo=Modelinfo, offset=offset

   if N_elements(obs) eq 0 then return, -1
   if N_elements(Modelinfo) eq 0 then return, -1
   if n_elements(offset) eq 0 then offset = [0L, 0L]

      GridInfo = CTM_GRID( MOdelInfo )

     ; Use the observations and synchronize the location between 
     ; the observation and calculation and return the calculation
     ; at observation sites only as a vector.
      SITEID= OBS.SITEID
      NSITE = N_ELEMENTS(SITEID)
      Latv  = fltarr(NSITE)
      Lonv  = Latv

      INDEX_I = REPLICATE(0L, NSITE)
      INDEX_J = INDEX_I

        I0    = OFFSET[0]
        J0    = OFFSET[1]

        XMID  = gridinfo.xmid(I0:*)
        YMID  = gridinfo.ymid(J0:*)

         LAT  = OBS.LAT
         LON  = OBS.LON

      for is = 0, N_ELEMENTS(SITEID)-1 do begin
          CTM_INDEX, ModelInfo, I, J, center = [lat[is], lon[is]], $
                     /non_interactive
          ; Correction for offset
          I1 = I-1-I0
          J1 = J-1-J0

          INDEX_I[IS] = I1
          INDEX_J[IS] = J1

          Latv(is)    = ymid(J1)
          Lonv(is)    = xmid(I1)

          err_x = ABS(Lonv(is)-lon(is))
          err_y = ABS(Latv(is)-lat(is))

          ; Error check for finding ij
          if (err_x gt GridInfo.di*0.5) or (err_y gt Gridinfo.dj*0.5) then begin
              print, err_x, err_y, dz[iz[0]], SITEID[is]
              stop
          endif

      endfor

   return, { I:INDEX_I, J:INDEX_J, LATV:Latv, LONV:Lonv }

 end

