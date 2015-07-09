; function read_sulf, region=region

;  pro diag_source, File=file, region=region, Saveout=saveout, $
;      tau0=tau0, results=results

  if n_elements(file) eq 0 then file=pickfile(filter = '/as2/priv/ICARTT/bpch/')
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

      TOTEMS = SO2SRC_an + SO2SRC_bm + SO2SRC_vo + SO4SRC_an + DMSSRC_oc + $
                SO2SRC_bf + SO2SRC_sh

      ANTHSO2 = total(Results.SO2_AN_$, 3)   $
              + total(Results.SO2_AC_$, 3)   $
              + total(Results.SO4_AN_$, 3)   $
              + Results.SO2_BIOF             $
              + Results.SO2_SHIP

 format = '(a27, 2F10.5)'

 print, 'Total Emission, Tg S       ', TOTEMS, format=format
 print, ' SO2 anthropogenic       : ', SO2SRC_an, SO2SRC_an/TOTEMS*100., format=format
 print, ' SO2 biomass burning     : ', SO2SRC_bm, SO2SRC_bm/TOTEMS*100., format=format
 print, ' SO2 biofuel use         : ', SO2SRC_bf, SO2SRC_bf/TOTEMS*100., format=format
 print, ' SO2 volcanic            : ', SO2SRC_vo, SO2SRC_vo/TOTEMS*100., format=format
 print, ' Sulfate anthropogenic   : ', SO4SRC_an, SO4SRC_an/TOTEMS*100., format=format
 print, ' DMS oceanic             : ', DMSSRC_oc, DMSSRC_oc/TOTEMS*100., format=format
 print, ' SO2 ship                : ', SO2SRC_sh, SO2SRC_sh/TOTEMS*100., format=format

end


