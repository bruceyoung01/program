;  pro diag_source, File=file, region=region, Saveout=saveout, $
;      tau0=tau0, results=results

  region = 'UScont'

  if n_elements(file) eq 0 then file=pickfile(filter = '/users/ctm/rjp/Asim/')
  if n_elements(tau0) ne 0 then kill = 0 else kill = 1

   Mon_str = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec']
;===============================================================================
;  Sulfate
;===============================================================================
    ;1) the emission information
    Diag = ['SO2-AN-$', $      ;* SO2 anthropogenic
            'SO2-AC-$', $      ; Aircraft
            'SO2-BIOB', $      ; Biomass
            'SO2-BIOF', $      ; Biofuel
            'SO2-EV-$', $      ;* SO2 eruptive volcanic
            'SO2-NV-$', $      ; SO2 non-eruptive volcano
            'SO4-AN-$', $      ; Anthropogenic SO4
            'DMS-BIOG', $      ; DMS
            'SO2-SHIP'  ]      ; SHIP emission

    For ND = 0, N_elements(Diag)-1 do begin

      For N = 0, N_elements(File)-1 do begin
        CTM_Get_Data, Datainfo, File=file[N], Diag[ND], tau0=tau0
        If N eq 0 then Dinfo = Datainfo else Dinfo = [Dinfo, Datainfo]
        Undefine, Datainfo
        if (kill eq 1) then Undefine, tau0
      Endfor
    
      Data = 0.
      For D = 0, N_elements(Dinfo)-1 do Data = Data + *(Dinfo[D].data) 

      If ND eq 0 then begin
         N_SO2 = Long(Dinfo[0].tracer - 200L)
         Time     = tau2yymmdd(Dinfo.tau0)
      end

      Undefine, Dinfo
      Data = region_only(Data, region=region)

      Name = exchar(Diag[ND],'-','_')
      If ND eq 0 then Results = create_struct(Name, Data) $
      else            Results = create_struct(Results, Name, Data)
 
      Undefine, Data
      Undefine, Name

    Endfor

      SO2SRC_an = total(Results.SO2_AN_$ + Results.SO2_AC_$) * 1.e-9
      SO2SRC_bm = total(Results.SO2_BIOB)                    * 1.e-9 ; Tg S/yr
      SO2SRC_bf = total(Results.SO2_BIOF)                    * 1.e-9 ; Tg S/yr
      SO2SRC_vo = total(Results.SO2_EV_$ + Results.SO2_NV_$) * 1.e-9 ; Tg S/yr
      SO4SRC_an = total(Results.SO4_AN_$)                    * 1.e-9 ; Tg S/yr
      DMSSRC_oc = total(Results.DMS_BIOG)                    * 1.e-9 ; Tg S/yr
      SO2SRC_sh = total(Results.SO2_SHIP)                    * 1.e-9 ; Tg S/yr

      TOTSULF = SO2SRC_an + SO2SRC_bm + SO2SRC_vo + SO4SRC_an + DMSSRC_oc + $
                SO2SRC_bf + SO2SRC_sh

;===============================================================================
;  NOx
;===============================================================================
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

;===============================================================================
;  NH3
;===============================================================================
    ;1) the emission information
    Diag = ['NH3-ANTH', $     ;* SO2 anthropogenic
            'NH3-BIOB', $     ; Aircraft
            'NH3-NATU', $
            'NH3-BIOF'  ]     ; Biomass

    For ND = 0, N_elements(Diag)-1 do begin

      For N = 0, N_elements(File)-1 do begin
        CTM_Get_Data, Datainfo, File=file[N], Diag[ND], tau0=tau0
        If N eq 0 then Dinfo = Datainfo else Dinfo = [Dinfo, Datainfo]
        Undefine, Datainfo
        if (kill eq 1) then Undefine, tau0
      Endfor
    
      Data = 0.
      For D = 0, N_elements(Dinfo)-1 do Data = Data + *(Dinfo[D].data) 

      Undefine, Dinfo
      Data = region_only(Data, region=region)

      Name = exchar(Diag[ND],'-','_')
      If ND eq 0 then Results = create_struct(Name, Data) $
      else            Results = create_struct(Results, Name, Data)
 
      Undefine, Data
      Undefine, Name

    Endfor

      NH3SRC_an = total(Results.NH3_ANTH) * 1.e-9
      NH3SRC_nt = total(Results.NH3_NATU) * 1.e-9
      NH3SRC_bm = total(Results.NH3_BIOB) * 1.e-9 ; Tg N/yr
      NH3SRC_bf = total(Results.NH3_BIOF) * 1.e-9 ; Tg N/yr

      TOTNH3 = NH3SRC_an + NH3SRC_nt + NH3SRC_bm + NH3SRC_bf

;===============================================================================
;  BC/OC
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

      If ND eq 0 then N_BC = Long(Dinfo[0].tracer - 6100L)
      If ND eq 3 then N_OC = Long(Dinfo[0].tracer - 6100L)

      Undefine, Dinfo
      Data = region_only(Data, region=region)

      Name = exchar(Diag[ND],'-','_')
      If ND eq 0 then Results = create_struct(Name, Data) $
      else            Results = create_struct(Results, Name, Data)
 
      Undefine, Data
      Undefine, Name

    Endfor

      BCSRC_an = total(Results.BC_ANTH) * 1.e-9
      BCSRC_bm = total(Results.BC_BIOB) * 1.e-9 ; Tg /yr
      BCSRC_bf = total(Results.BC_BIOF) * 1.e-9 ; Tg /yr
      OCSRC_an = total(Results.OC_ANTH) * 1.e-9 ; Tg /yr
      OCSRC_bm = total(Results.OC_BIOB) * 1.e-9 ; Tg /yr
      OCSRC_bf = total(Results.OC_BIOF) * 1.e-9 ; Tg /yr
      OCSRC_bg = TOTAL(RESULTS.OC_BIOG) * 1.E-9

      TOTBC = BCSRC_an + BCSRC_bm + BCSRC_bf 
      TOTOC = OCSRC_an + OCSRC_bm + OCSRC_bf + OCSRC_bg


  Period = '('
  For N = 0, N_elements(Time.month)-1 do $
    Period = Period + strtrim(Mon_str(Time.month[N]-1))+' '
  Period = Period+')'

  If N_elements(region) ne 0 then $
 print, 'Regional Budget for '+Region
 print, '---------------------------------------------------------------'
 print, '	  Budget Component	   GEOS-CHEM    for ' + Period
 print, '---------------------------------------------------------------'
 print, 'Total Sulfur Emission, Tg S', TOTSULF
 print, ' SO2 anthropogenic       : ', SO2SRC_an, SO2SRC_an/TOTSULF*100.
 print, ' SO2 biomass burning     : ', SO2SRC_bm, SO2SRC_bm/TOTSULF*100.
 print, ' SO2 biofuel use         : ', SO2SRC_bf, SO2SRC_bf/TOTSULF*100.
 print, ' SO2 volcanic            : ', SO2SRC_vo, SO2SRC_vo/TOTSULF*100.
 print, ' Sulfate anthropogenic   : ', SO4SRC_an, SO4SRC_an/TOTSULF*100.
 print, ' DMS oceanic             : ', DMSSRC_oc, DMSSRC_oc/TOTSULF*100.
 print, ' SHIP emission           : ', SO2SRC_sh, SO2SRC_sh/TOTSULF*100.
 print, ' '
 print, 'Total NOx Emission, Tg N   ', TOTNOX
 print, ' NOX anthropogenic       : ', NOXSRC_an, NOXSRC_an/TOTNOX*100.
 print, ' NOX aircraft            : ', NOXSRC_ac, NOXSRC_ac/TOTNOX*100.
 print, ' NOX biofuel use         : ', NOXSRC_bf, NOXSRC_bf/TOTNOX*100.
 print, ' NOX fertilizer          : ', NOXSRC_ft, NOXSRC_ft/TOTNOX*100.
 print, ' NOX biomass burning     : ', NOXSRC_bm, NOXSRC_bm/TOTNOX*100.
 print, ' NOX lightning           : ', NOXSRC_li, NOXSRC_li/TOTNOX*100.
 print, ' NOX soil                : ', NOXSRC_sl, NOXSRC_sl/TOTNOX*100.
 print, ' NOX stratosphere        : ', NOXSRC_st, NOXSRC_st/TOTNOX*100.
 print, ' '
 print, 'Total NH3 Emission, Tg N   ', TOTNH3
 print, ' NH3 anthropogenic       : ', NH3SRC_an, NH3SRC_an/TOTNH3*100.
 print, ' NH3 biofuel use         : ', NH3SRC_bf, NH3SRC_bf/TOTNH3*100.
 print, ' NH3 biomass burning     : ', NH3SRC_bm, NH3SRC_bm/TOTNH3*100.
 print, ' NH3 natural sources     : ', NH3SRC_nt, NH3SRC_nt/TOTNH3*100.
 print, ' '
 print, 'Total BC Emission, Tg C   ', TOTBC
 print, ' BC fossil fuel         : ', BCSRC_an, BCSRC_an/TOTBC*100.
 print, ' BC biomass burning     : ', BCSRC_bm, BCSRC_bm/TOTBC*100.
 print, ' BC biofuel use         : ', BCSRC_bf, BCSRC_bf/TOTBC*100.
 print, ' '
 print, 'Total OC Emission, Tg C   ', TOTOC
 print, ' OC fossil fuel         : ', OCSRC_an, OCSRC_an/TOTOC*100.
 print, ' OC biomass burning     : ', OCSRC_bm, OCSRC_bm/TOTOC*100.
 print, ' OC biofuel use         : ', OCSRC_bf, OCSRC_bf/TOTOC*100.
 print, ' OC vegetation          : ', OCSRC_bg, OCSRC_bg/TOTOC*100.
 print, ' '

 ctm_cleanup

end


