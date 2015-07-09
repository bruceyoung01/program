  pro diag_dryd, File=file, region=region, Saveout=saveout, $
      tau0=tau0, results=results

;+
; pro diag_sulf_v02, File=file, region=region, /Saveout
;-

  if n_elements(file) eq 0 then file=pickfile()
  if n_elements(tau0) ne 0 then kill = 0 else kill = 1

   Mon_str = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec']

    ;2) Dry deposition information
;    Tracers = Lindgen(3) + 7100L + N_SO2

;    For ND = 0, N_elements(Tracers)-1 do begin

      For N = 0, N_elements(File)-1 do begin
        CTM_Get_Data, Datainfo, File=file[N], 'DRYD-FLX' ;, tracer=Tracers[ND], tau0=tau0
        If N eq 0 then Dinfo = Datainfo else Dinfo = [Dinfo, Datainfo]
        Undefine, Datainfo
        if (kill eq 1) then Undefine, tau0
      Endfor

;      If ND eq 0 then begin
         ; extract Modelinfo and Gridinfo
         GetModelAndGridInfo, DInfo[0], ModelInfo, GridInfo
         ; Grid = CTM_Grid( CTM_type('GEOS3_30L',res=4) )
         Volume   = CTM_BOXSIZE( GridInfo, /GEOS, /Volume, /m3 )
         Area_cm2 = CTM_BOXSIZE( GridInfo, /GEOS, /cm2 )
         Nday     = float(Dinfo[0].tau1-Dinfo[0].tau0)/24.

;         For N    = 0, N_elements(Dinfo)-1 do $
;             Nday = Nday + float(Dinfo[N].tau1-Dinfo[N].tau0)/24.
         Time     = tau2yymmdd(Dinfo.tau0)
         DFAC     = Area_cm2 / 6.022D23 * Nday * 86400. ; moles/time, * 32D-3 ; kg S/yr
;      Endif

      Data = 0.
      For D = 0, N_elements(Dinfo)-1 do begin
          Data = *(Dinfo[D].data)
          Data = region_only(Data, region=region)
          Data = Data * float(DFac)
          If D eq 0 then Results = create_struct(Dinfo[D].tracername, Data) else $
                         Results = create_struct(Results, Dinfo[D].tracername, Data)
          Undefine, Data
      Endfor

;    End
          Undefine, Dinfo

 End
