;  pro diag_source, File=file, region=region, Saveout=saveout, $
;      tau0=tau0, results=results

   Undefine, region
;  region = 'NAMERICA'
;  region = 'US'
  region = 'MEXICO'
;  region = 'CANADA'

  if n_elements(file) eq 0 then file=pickfile(filter = '/users/ctm/rjp/Asim/')
  if n_elements(tau0) ne 0 then kill = 0 else kill = 1

   Mon_str = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec']
;===============================================================================
;  Sulfate
;===============================================================================
    ;1) the emission information in units of molecule/cm2/s

    Diag = ['NOX-AN-$', $      ;* NOX anthropogenic
            'NOX-AC-$', $      ; Aircraft
            'NOX-BIOB', $      ; Biomass
            'NOX-BIOF', $      ; Biofuel
            'NOX-LI-$', $      ;* NOX eruptive volcanic
            'NOX-SOIL', $      ; NOX non-eruptive volcano
            'NOX-FERT', $      ; Anthropogenic SO4
            'NOX-STRT'  ]      ; DMS

    WFAC = 86400.*14.E-3/6.022E23  ; unit conversion factor to kg N/month

    For ND = 0, N_elements(Diag)-1 do begin

      For N = 0, N_elements(File)-1 do begin
        CTM_Get_Data, Datainfo, File=file[N], Diag[ND], tau0=tau0
        If N eq 0 then Dinfo = Datainfo else Dinfo = [Dinfo, Datainfo]
        Undefine, Datainfo
        if (kill eq 1) then Undefine, tau0
      Endfor

      If ND eq 0 then begin
         ThisDatainfo = Dinfo[0]
         FIRST = ThisDatainfo.FIRST - 1L ; IDL index
         GetModelAndGridInfo, ThisDatainfo, ModelInfo, GridInfo
         DIM  = ThisDatainfo.Dim
         N_NOX = Long(ThisDatainfo.tracer - 100L)
         Time  = tau2yymmdd(Dinfo.tau0)

         Xmid = Gridinfo.xmid[First[0]:First[0]+Dim[0]-1L]
         Ymid = Gridinfo.Ymid[First[1]:First[1]+Dim[1]-1L]
         Area = CTM_BOXSIZE( GridInfo, /GEOS, /cm2 )
         A_cm2= Area[First[0]:First[0]+Dim[0]-1L, First[1]:First[1]+Dim[1]-1L] 
      endif

      Data = 0.
      For D = 0, N_elements(Dinfo)-1 do begin
          Nday = float(Dinfo[N].tau1-Dinfo[N].tau0)/24.
          Data = Data + *(Dinfo[D].data) * WFAC * Nday ; kg N/cm2
      End

      chk = size(Data)
      if chk[0] eq 3 then Data = total(Data, 3) * A_cm2 else $
      Data = Data * A_cm2

      Undefine, Dinfo
      Data = region_only(Data, region=region)

      Name = exchar(Diag[ND],'-','_')
      If ND eq 0 then Results = create_struct(Name, Data) $
      else            Results = create_struct(Results, Name, Data)
 
      Undefine, Data
      Undefine, Name

    Endfor


      NOXSRC_an = total(Results.NOX_AN_$) * 1.e-9   ; Tg N/yr
      NOXSRC_ac = total(Results.NOX_AC_$) * 1.e-9
      NOXSRC_bm = total(Results.NOX_BIOB)                    * 1.e-9 ; Tg N/yr
      NOXSRC_bf = total(Results.NOX_BIOF)                    * 1.e-9 ; Tg N/yr
      NOXSRC_li = total(Results.NOX_LI_$)                    * 1.e-9 ; Tg S/yr
      NOXSRC_sl = total(Results.NOX_SOIL)                    * 1.e-9 ; Tg S/yr
      NOXSRC_ft = total(Results.NOX_FERT)                    * 1.e-9 ; Tg S/yr
      NOXSRC_st = total(Results.NOX_STRT)                    * 1.e-9 ; Tg S/yr

      TOTNOX = NOXSRC_an + NOXSRC_ac + NOXSRC_bm + NOXSRC_bf + NOXSRC_li $
             + NOXSRC_sl + NOXSRC_ft + NOXSRC_st


      if n_elements(mapsrc) eq 0 then mapsrc = fltarr(101,51,8)
      srctype = ['fossil','aircraft','biomass','biofuel', $
                 'light','soil','fert','strat']

      mapsrc[*,*,0] = Results.NOX_AN_$
      mapsrc[*,*,1] = Results.NOX_AC_$
      mapsrc[*,*,2] = Results.NOX_BIOB
      mapsrc[*,*,3] = Results.NOX_BIOF
      mapsrc[*,*,4] = Results.NOX_LI_$ 
      mapsrc[*,*,5] = Results.NOX_SOIL
      mapsrc[*,*,6] = Results.NOX_FERT
      mapsrc[*,*,7] = Results.NOX_STRT

      For D = 0, 7 do begin
          tvmap, mapsrc[*,*,d], xmid, ymid, /conti, /coast, $
                 /us, /sample, /countries, title=srctype[d], $
                 /cbar, divis=5
          halt
      Endfor

  Period = '('
  For N = 0, N_elements(Time.month)-1 do $
    Period = Period + strtrim(Mon_str(Time.month[N]-1))+' '
  Period = Period+')'

  If N_elements(region) ne 0 then $
 print, 'Regional Budget for '+Region
 print, '---------------------------------------------------------------'
 print, '	  Budget Component	   GEOS-CHEM    for ' + Period
 print, '---------------------------------------------------------------'
 print, 'Total Emission, Tg N       ', TOTNOX
 print, ' NOX anthropogenic       : ', NOXSRC_an, NOXSRC_an/TOTNOX*100.
 print, ' NOX aircraft            : ', NOXSRC_ac, NOXSRC_ac/TOTNOX*100.
 print, ' NOX biofuel use         : ', NOXSRC_bf, NOXSRC_bf/TOTNOX*100.
 print, ' NOX fertilizer          : ', NOXSRC_ft, NOXSRC_ft/TOTNOX*100.
 print, ' NOX biomass burning     : ', NOXSRC_bm, NOXSRC_bm/TOTNOX*100.
 print, ' NOX lightning           : ', NOXSRC_li, NOXSRC_li/TOTNOX*100.
 print, ' NOX soil                : ', NOXSRC_sl, NOXSRC_sl/TOTNOX*100.
 print, ' NOX stratosphere        : ', NOXSRC_st, NOXSRC_st/TOTNOX*100.
 print, ' '

 Heap_gc

end


