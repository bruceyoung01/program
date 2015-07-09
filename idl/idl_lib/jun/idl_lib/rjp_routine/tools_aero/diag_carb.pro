  pro diag_carb, File=file, region=region, Saveout=saveout, $
      tau0=tau0, results=results

;+
;  pro diag_carb, File=file, region=region, Saveout=saveout, $
;      tau0=tau0, results=results
;-

  if n_elements(file) eq 0 then file=pickfile()
  if n_elements(tau0) ne 0 then kill = 0 else kill = 1

   Mon_str = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec']
;===============================================================================
;  Sulfate
;===============================================================================
    ;1) the emission information
    Diag = ['BC-ANTH', $      ;* SO2 anthropogenic
            'BC-BIOB', $      ; Aircraft
            'BC-BIOF', $      ; Biomass
            'OC-ANTH', $      ; Biofuel
            'OC-BIOB', $      ;* SO2 eruptive volcanic
            'OC-BIOF', $      ; SO2 non-eruptive volcano
            'OC-BIOG'  ]      ; Anthropogenic SO4

    For ND = 0, N_elements(Diag)-1 do begin

      For N = 0, N_elements(File)-1 do begin
        CTM_Get_Data, Datainfo, File=file[N], Diag[ND], tau0=tau0
        If N eq 0 then Dinfo = Datainfo else Dinfo = [Dinfo, Datainfo]
        Undefine, Datainfo
        if (kill eq 1) then Undefine, tau0
      Endfor
    
      Data = 0.
      For D = 0, N_elements(Dinfo)-1 do Data = Data + *(Dinfo[D].data) 

      If ND eq 0 then N_EC = Long(Dinfo[0].tracer - 5400L)
      If ND eq 3 then N_OC = Long(Dinfo[0].tracer - 5400L)

      Undefine, Dinfo
      Data = region_only(Data, region=region)

      Name = exchar(Diag[ND],'-','_')
      If ND eq 0 then Results = create_struct(Name, Data) $
      else            Results = create_struct(Results, Name, Data)
 
      Undefine, Data
      Undefine, Name

    Endfor

      ECSRC_an = total(Results.BC_ANTH) * 1.e-9
      ECSRC_bm = total(Results.BC_BIOB) * 1.e-9 ; Tg /yr
      ECSRC_bf = total(Results.BC_BIOF) * 1.e-9 ; Tg /yr
      OCSRC_an = total(Results.OC_ANTH) * 1.e-9 ; Tg /yr
      OCSRC_bm = total(Results.OC_BIOB) * 1.e-9 ; Tg /yr
      OCSRC_bf = total(Results.OC_BIOF) * 1.e-9 ; Tg /yr
      OCSRC_bg = TOTAL(RESULTS.OC_BIOG) * 1.E-9

      TOTEMS_EC = ECSRC_an + ECSRC_bm + ECSRC_bf 
      TOTEMS_OC = OCSRC_an + OCSRC_bm + OCSRC_bf + OCSRC_bg

    ;2) Dry deposition information
    Tracers = Lindgen(4) + 7100L + N_EC

    For ND = 0, N_elements(Tracers)-1 do begin

      For N = 0, N_elements(File)-1 do begin
        CTM_Get_Data, Datainfo, File=file[N], 'DRYD-FLX', tracer=Tracers[ND], tau0=tau0
        If N eq 0 then Dinfo = Datainfo else Dinfo = [Dinfo, Datainfo]
        Undefine, Datainfo
        if (kill eq 1) then Undefine, tau0
      Endfor

      If ND eq 0 then begin
         ; extract Modelinfo and Gridinfo
         GetModelAndGridInfo, DInfo[0], ModelInfo, GridInfo
         ; Grid = CTM_Grid( CTM_type('GEOS3_30L',res=4) )
         Volume   = CTM_BOXSIZE( GridInfo, /GEOS, /Volume, /m3 )
         Area_cm2 = CTM_BOXSIZE( GridInfo, /GEOS, /cm2 )
         Nday     = 0.
         For N    = 0, N_elements(Dinfo)-1 do $
             Nday = Nday + float(Dinfo[N].tau1-Dinfo[N].tau0)/24.
         Time     = tau2yymmdd(Dinfo.tau0)
         DFAC     = Area_cm2 / 6.022D23 * Nday * 86400. * 12D-3 ; kg C/yr
      Endif

      Data = 0.
      For D = 0, N_elements(Dinfo)-1 do Data = Data + *(Dinfo[D].data)
      Data = region_only(Data, region=region)
      Data = Data * float(DFac) / float(N_elements(Dinfo))
      Results = create_struct(Results, Dinfo[0].tracername, Data)
      Undefine, Dinfo
      Undefine, Data
    End

      ECDRYDEP = total(Results.ECPIdf+Results.ECPOdf) * 1.e-9  ; Tg S/yr
      OCDRYDEP = total(Results.OCPIdf+Results.OCPOdf) * 1.e-9  ; Tg S/yr

    ;3) WET deposition information
    ;           EC    OC
    Tracers = Lindgen(2) + 3300L + N_EC
    Diag    = ['WETDLS-$', 'WETDCV-$']
    Mw      = [12.]

    For ND0 = 0, N_elements(Tracers)-1 do begin
    For ND1 = 0, N_elements(Diag)-1    do begin
      
      For N = 0, N_elements(File)-1 do begin
        CTM_Get_Data, Datainfo, File=file[N], Diag[ND1], tracer=Tracers[ND0], tau0=tau0
        If N eq 0 then Dinfo = Datainfo else Dinfo = [Dinfo, Datainfo]
        Undefine, Datainfo
        if (kill eq 1) then Undefine, tau0
      Endfor

      WFAC = Nday*86400.

      Data = 0.
      For D = 0, N_elements(Dinfo)-1 do Data = Data + *(Dinfo[D].data)
      Data = region_only(Data, region=region)

      Data = Data * Wfac / float(N_elements(Dinfo))
      Name = Dinfo[0].tracername+exchar(Diag[ND1],'-','_')
      Results = create_struct(Results, Name, Data)
      Undefine, Data
    End
    End

      ECWETDEP = total(Results.ECPIWETDLS_$ + Results.ECPIWETDCV_$) * 1.e-9 ; Tg C/yr
      OCWETDEP = total(Results.OCPIWETDLS_$ + Results.OCPIWETDCV_$) * 1.e-9 ; Tg C/yr

      TOTLOSS_EC = ECDRYDEP + ECWETDEP
      TOTLOSS_OC = OCDRYDEP + OCWETDEP

 ; Retrieve air density

      For N = 0, N_elements(File)-1 do begin
        CTM_Get_Data, Datainfo, File=file[N], 'BXHGHT-$', tracer=2002, tau0=tau0
        If N_elements(Datainfo) eq 0 then goto, Jump1

        If N eq 0 then AirdInfo = Datainfo else AirDinfo = [AirDinfo, Datainfo]
        Undefine, Datainfo
        if (kill eq 1) then Undefine, tau0
      Endfor

Jump1:

      IF N_elements(AirdInfo) eq 0 then begin

         Year      = strtrim(time.year[0],2)
         CASE Gridinfo.IMX of
              72 : DXDY = '4x5'
             144 : DXDY = '2x25'
             Else: return
         End
         file_aird = '/users/ctm/rjp/Asim/data/aird_'+DXDY+'_'+Year+'.bpch'
         file_aird = findfile(file_aird)
      
         If file_aird[0] ne '' then begin
            CTM_Get_Data, AirdInfo, 'BXHGHT-$', File=file_aird[0], tracer=2004, tau0=tau0
         end else begin
            Print, 'No Airdensity data'
            Return
         End

      Endif
         
      AD = FLTARR(Gridinfo.imx,Gridinfo.jmx,Gridinfo.lmx,N_elements(airdinfo))
      For D = 0, N_elements(Airdinfo)-1 do $
;      AD[*,*,*,D] = *(Airdinfo[D].Data) / 6.022D23 * Volume ; mole
      AD[*,*,*,D] = *(Airdinfo[D].Data) / 28.96E-3 ; mole

    ; Burden information

    Tracers = Lindgen(4) + N_EC
    For ND = 0, N_elements(Tracers)-1 do begin

      For N = 0, N_elements(File)-1 do begin
        CTM_Get_Data, Datainfo, File=file[N], 'IJ-AVG-$', tracer=Tracers[ND], tau0=tau0
        If N eq 0 then Dinfo = Datainfo else Dinfo = [Dinfo, Datainfo]
        Undefine, Datainfo
        if (kill eq 1) then Undefine, tau0
      Endfor
      
      unit = Dinfo[0].unit  
      case strmid(unit,0,3) of 
         'ppb' : fac = 1.E-9 
         'ppt' : fac = 1.E-12
         'v/v' : fac = 1.
         else  : fac = 1.
      end

      Data = 0.
      For D = 0, N_elements(Dinfo)-1 do $
          Data = Data + (*(Dinfo[D].data) * AD[*,*,*,D] * fac) ; mole
      Data = region_only(Data, region=region)
      Data = Data / float(N_elements(Dinfo))
      Results = create_struct(Results, Dinfo[0].tracername, Data)
      Undefine, Dinfo
      Undefine, Data
    Endfor

      ECPIBURD = total(Results.ECPI[*,*,0:19]) * 12.e-12
      ECPOBURD = total(Results.ECPO[*,*,0:19]) * 12.e-12
      ECBURD   = ECPIBURD+ECPOBURD
      OCPIBURD = total(Results.OCPI[*,*,0:19]) * 12.e-12
      OCPOBURD = total(Results.OCPO[*,*,0:19]) * 12.e-12
      OCBURD   = OCPIBURD+OCPOBURD

  Period = '('
  For N = 0, N_elements(Time.month)-1 do $
    Period = Period + strtrim(Mon_str(Time.month[N]-1))+' '
  Period = Period+')'

  If N_elements(region) ne 0 then $
 print, 'Regional Budget for '+Region
 print, '---------------------------------------------------------------'
 print, '	  Budget Component	   GEOS-CHEM    for ' + Period
 print, '---------------------------------------------------------------'
 print, 'Total EC Emission, Tg C   ', TOTEMS_EC
 print, ' EC fossil fuel         : ', ECSRC_an, ECSRC_an/TOTEMS_EC*100.
 print, ' EC biomass burning     : ', ECSRC_bm, ECSRC_bm/TOTEMS_EC*100.
 print, ' EC biofuel use         : ', ECSRC_bf, ECSRC_bf/TOTEMS_EC*100.
 print, ' '
 print, 'Total OC Emission, Tg C   ', TOTEMS_OC
 print, ' OC fossil fuel         : ', OCSRC_an, OCSRC_an/TOTEMS_OC*100.
 print, ' OC biomass burning     : ', OCSRC_bm, OCSRC_bm/TOTEMS_OC*100.
 print, ' OC biofuel use         : ', OCSRC_bf, OCSRC_bf/TOTEMS_OC*100.
 print, ' OC vegetation          : ', OCSRC_bg, OCSRC_bg/TOTEMS_OC*100.
 print, ' '
 print, 'Total EC Deposition, Tg   ', TOTLOSS_EC
 print, ' EC Dry deposition      : ', ECDRYDEP, ECDRYDEP/TOTLOSS_EC*100.
 print, ' EC Wet deposition      : ', ECWETDEP, ECWETDEP/TOTLOSS_EC*100.
 print, ' '
 print, 'Total OC Deposition, Tg   ', TOTLOSS_OC
 print, ' OC Dry deposition      : ', OCDRYDEP, OCDRYDEP/TOTLOSS_OC*100.
 print, ' OC Wet deposition      : ', OCWETDEP, OCWETDEP/TOTLOSS_OC*100.
 print, ' '
 print, 'Burden, Tg C              '
 print, ' EC                     : ', ECBURD, ECPIBURD/ECBURD*100.
 print, ' OC                     : ', OCBURD, OCPIBURD/OCBURD*100.
 print, ' '
 print, 'Life time, days
 print, ' EC                     : ', ECBURD/(ECDRYDEP+ECWETDEP)*Nday
 print, ' OC                     : ', OCBURD/(OCDRYDEP+OCWETDEP)*Nday
 print, ' '
 print, 'Loss frequency, /day      '
 print, ' EC dry deposition      : ', ECDRYDEP/ECBURD/Nday
 print, ' EC wet processes       : ', ECWETDEP/ECBURD/Nday
 print, ' OC dry deposition      : ', OCDRYDEP/OCBURD/Nday
 print, ' OC wet scavenging      : ', OCWETDEP/OCBURD/Nday
 print, '                      '
 print, '-----------------------------------------------------'

 If Keyword_set(Saveout) then begin

  Openw, Ilun, 'Diag_carb.txt', /Get

  If N_elements(region) ne 0 then $
 printf, ilun, 'Regional Budget for '+Region
 printf, ilun, '--------------------------------------------------'
 printf, ilun, '     Budget Component         GEOS-CHEM           '
 printf, ilun, '--------------------------------------------------'
 printf, ilun, 'Total EC Emission, Tg C   ', TOTEMS_EC
 printf, ilun, ' EC fossil fuel         : ', ECSRC_an, ECSRC_an/TOTEMS_EC*100.
 printf, ilun, ' EC biomass burning     : ', ECSRC_bm, ECSRC_bm/TOTEMS_EC*100.
 printf, ilun, ' EC biofuel use         : ', ECSRC_bf, ECSRC_bf/TOTEMS_EC*100.
 printf, ilun, ' '
 printf, ilun, 'Total OC Emission, Tg C   ', TOTEMS_OC
 printf, ilun, ' OC fossil fuel         : ', OCSRC_an, OCSRC_an/TOTEMS_OC*100.
 printf, ilun, ' OC biomass burning     : ', OCSRC_bm, OCSRC_bm/TOTEMS_OC*100.
 printf, ilun, ' OC biofuel use         : ', OCSRC_bf, OCSRC_bf/TOTEMS_OC*100.
 printf, ilun, ' OC vegetation          : ', OCSRC_bg, OCSRC_bg/TOTEMS_OC*100.
 printf, ilun, ' '
 printf, ilun, 'Total EC Deposition, Tg   ', TOTLOSS_EC
 printf, ilun, ' EC Dry deposition      : ', ECDRYDEP, ECDRYDEP/TOTLOSS_EC*100.
 printf, ilun, ' EC Wet deposition      : ', ECWETDEP, ECWETDEP/TOTLOSS_EC*100.
 printf, ilun, ' '
 printf, ilun, 'Total OC Deposition, Tg   ', TOTLOSS_OC
 printf, ilun, ' OC Dry deposition      : ', OCDRYDEP, OCDRYDEP/TOTLOSS_OC*100.
 printf, ilun, ' OC Wet deposition      : ', OCWETDEP, OCWETDEP/TOTLOSS_OC*100.
 printf, ilun, ' '
 printf, ilun, 'Burden, Tg C              '
 printf, ilun, ' EC                     : ', ECBURD, ECPIBURD/ECBURD*100.
 printf, ilun, ' OC                     : ', OCBURD, OCPIBURD/OCBURD*100.
 printf, ilun, ' '
 printf, ilun, 'Life time, days
 printf, ilun, ' EC                     : ', ECBURD/(ECDRYDEP+ECWETDEP)*Nday
 printf, ilun, ' OC                     : ', OCBURD/(OCDRYDEP+OCWETDEP)*Nday
 printf, ilun, ' '
 printf, ilun, 'Loss frequency, /day      '
 printf, ilun, ' EC dry deposition      : ', ECDRYDEP/ECBURD/Nday
 printf, ilun, ' EC wet processes       : ', ECWETDEP/ECBURD/Nday
 printf, ilun, ' OC dry deposition      : ', OCDRYDEP/OCBURD/Nday
 printf, ilun, ' OC wet scavenging      : ', OCWETDEP/OCBURD/Nday
 printf, ilun, '                      '
 printf, ilun, '-----------------------------------------------------'

 free_lun, ilun

 Endif

 Heap_gc
end


