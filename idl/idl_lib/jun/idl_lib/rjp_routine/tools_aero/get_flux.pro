 function get_flux, Diag, file=file, region=region, tau0=tau0

 if N_elements(file) eq 0 then file = pickfile()
 if N_elements(Diag) eq 0 then return, -1
 if n_elements(tau0) ne 0 then kill = 0 else kill = 1

    For N = 0, N_elements(File)-1 do begin
       CTM_Get_Data, Datainfo, File=file[N], Diag, tau0=tau0
       ; Check validity of datainfo
       if N_elements(Datainfo) eq 0 then return, -1
       If N eq 0 then Dinfo = Datainfo else Dinfo = [Dinfo, Datainfo]
       Undefine, Datainfo

       CTM_Get_Data, Datainfo, File=file[N], 'BXHGHT-$', tracer=2002, tau0=tau0
       If N_elements(Datainfo) eq 0 then  message, 'no air mass info available'
       If N eq 0 then massInfo = Datainfo else massinfo = [massinfo, Datainfo]
       Undefine, Datainfo

       CTM_Get_Data, Datainfo, File=file[N], 'BXHGHT-$', tracer=2004, tau0=tau0
       If N_elements(Datainfo) eq 0 then  message, 'no air density info available'
       If N eq 0 then airdInfo = Datainfo else airdinfo = [AirDinfo, Datainfo]
       Undefine, Datainfo

       if (kill eq 1) then Undefine, tau0
    Endfor

    AD = FLTARR(airdinfo[0].dim[0],airdinfo[0].dim[1],airdinfo[0].dim[2],N_elements(airdinfo))
    For D = 0, N_elements(Airdinfo)-1 do begin
      density = *(airdinfo[D].data)  ; #/m3
      mass    = *(massinfo[D].data)  ; kg
      AD[*,*,*,D] = 1.E6 * mass / (density * 28.96E-3) ; conversion factor from molec/cm3 to mole
    End

    OFFSET = DINFO[0].FIRST - 1L
    DIM    = DINFO[0].DIM - 1L
    X1     = OFFSET[0]
    X2     = X1 + DIM[0] 
    Y1     = OFFSET[1]
    Y2     = Y1 + DIM[1] 
    Z1     = OFFSET[2]
    Z2     = Z1 + DIM[2] 

    ; extract Modelinfo and Gridinfo
    GetModelAndGridInfo, DInfo[0], ModelInfo, GridInfo

    Vol_m3   = CTM_BOXSIZE( GridInfo, /GEOS, /Volume, /M3 )
    Area_cm2 = CTM_BOXSIZE( GridInfo, /GEOS, /cm2 )
    Nday     = 0.

    ; Find uniq tau0 and tau1
    UTAU0    = Dinfo.tau0
    UTAU0    = Utau0[uniq(Utau0, sort(Utau0))]
    UTAU1    = Dinfo.tau1
    UTAU1    = Utau1[uniq(Utau1, sort(Utau1))]

    For N    = 0, N_elements(UTAU0)-1 do $
        Nday = Nday + float(Utau1[N]-Utau0[N])/24.

    Time     = tau2yymmdd(Utau0)
    ; conversion factor for dry deposition
    DFAC     = Area_cm2[X1:X2,Y1:Y2] / 6.022D23 * Nday * 86400. ; mole/yr
    ; conversion factor for wet deposition
    WFAC     = Nday * 86400.                                    ; mole/yr
    ; CONVERSION FACTOR FOR CHEMICAL PROD/LOSS (#/CM3 SEC) to mole/yr               
    CFAC     = NDAY * 86400. * AD                              

    ; Grid volume (m3)
    VFAC     = vol_m3

    TRACER   = Dinfo.tracer
    TRACER   = TRACER[UNIQ(tracer, sort(tracer))]

    Results = create_struct('TIME', Time, 'TAU', Utau0, 'Nday', Nday, $
                            'DFAC', DFAC, 'WFAC', WFAC, 'CFAC', CFAC, $
                            'VFAC', VFAC, 'TRACER', TRACER)

    For N = 0, N_elements(Tracer)-1 do begin
       Data = 0.
       P    = where(Dinfo.Tracer eq Tracer[N])
       If P[0] eq -1 then message, 'something wrong with tracer: '+Diag

       If N_elements(P) ne N_elements(UTAU0) then $
       message, 'Number of data afo time does not match: '+Diag

       For D = 0, N_elements(P)-1 do Data = Data + *(Dinfo[P[D]].data)
       Data = region_only(Data, region=region)

       Data = Data / float(N_elements(P))
       
       Name = Dinfo[P[0]].tracername+Diag
       Name = exchar(Name,'-','_')
       Name = exchar(Name,'=','_')

       Results = create_struct(Results, Name, Data)
       Undefine, Data
    End

 Undefine, Dinfo
 Undefine, Tracer

 Return, Results

 end
  
