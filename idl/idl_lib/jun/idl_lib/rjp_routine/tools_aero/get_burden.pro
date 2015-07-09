 function get_burden, file=file, region=region, tau0=tau0

   if N_elements(file) eq 0 then file = pickfile()
   if n_elements(tau0) ne 0 then kill = 0 else kill = 1

    ; Retrieve air mass (kg) in gridbox
      For N = 0, N_elements(File)-1 do begin
        CTM_Get_Data, Datainfo, File=file[N], 'BXHGHT-$', tracer=2002, tau0=tau0
        If N_elements(Datainfo) eq 0 then $
        message, 'no air mass info available'

        If N eq 0 then AirdInfo = Datainfo else AirDinfo = [AirDinfo, Datainfo]
        Undefine, Datainfo
        if (kill eq 1) then Undefine, tau0
      Endfor

      ; extract Modelinfo and Gridinfo
      GetModelAndGridInfo, Airdinfo[0], ModelInfo, GridInfo

      AD = FLTARR(airdinfo[0].dim[0],airdinfo[0].dim[1],airdinfo[0].dim[2],N_elements(airdinfo))
      For D = 0, N_elements(Airdinfo)-1 do $
      AD[*,*,*,D] = *(Airdinfo[D].Data) / 28.96E-3 ; mole

    ; Burden information
      For N = 0, N_elements(File)-1 do begin
        CTM_Get_Data, Datainfo, 'IJ-24H-$', File=file[N], tau0=tau0
        If N_elements(Datainfo) eq 0 then $
        CTM_Get_Data, Datainfo, 'IJ-AVG-$', File=file[N], tau0=tau0

        If N eq 0 then Dinfo = Datainfo else Dinfo = [Dinfo, Datainfo]
        Undefine, Datainfo
        if (kill eq 1) then Undefine, tau0
      Endfor

      ; Find uniq tau0 and tau1
      UTAU0    = Dinfo.tau0
      UTAU0    = Utau0[uniq(Utau0, sort(Utau0))]
      UTAU1    = Dinfo.tau1
      UTAU1    = Utau1[uniq(Utau1, sort(Utau1))]

      Time     = tau2yymmdd(Utau0)

      Nday = 0
      For N    = 0, N_elements(UTAU0)-1 do $
        Nday = Nday + float(Utau1[N]-Utau0[N])/24.

      TRACER   = Dinfo.tracer
      TRACER   = TRACER[UNIQ(tracer, sort(tracer))]

      Results = create_struct('TIME', TIME, 'Nday', Nday, 'TRACER', TRACER)

      For N = 0, N_elements(Tracer)-1 do begin

         Data = 0.
         P    = where(Dinfo.Tracer eq Tracer[N])
         If P[0] eq -1 then message, 'something wrong with tracer: BURDEN'
         unit = Dinfo[P[0]].unit  

         case strmid(unit,0,3) of 
            'ppb' : fac = 1.E-9 
            'ppt' : fac = 1.E-12
            'v/v' : fac = 1.
            else  : fac = 1.
         end

         For D = 0, N_elements(P)-1 do $
             Data = Data + (*(Dinfo[P[D]].data) * AD[*,*,*,D] * fac) ; mole

         Data = region_only(Data, region=region)
         Data = Data / float(N_elements(P))

         Results = create_struct(Results, Dinfo[P[0]].tracername, Data)

         Undefine, Data
      Endfor

 Undefine, Dinfo
 Undefine, Tracer

 Return, Results

 end
  
