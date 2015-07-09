  pro diag_carb_tag, File=file

  if n_elements(file) eq 0 then file=pickfile()

    CTM_Get_Data, DataInfo, Filename=File

; ; First go through the emission information

  ;1) BC anthropogenic

      P = where(Datainfo.category eq 'BLKC-SR$')
      Data = 0.
      For D = 0, N_elements(P)-1 do Data = Data + *(Datainfo[P[D]].data)
      ECSRC_an = total(Data[*,*,0]) * 1.e-9
      ECSRC_bm = total(Data[*,*,1]) * 1.e-9
      ECSRC_bf = total(Data[*,*,2]) * 1.e-9
      TOTEMSEC = ECSRC_AN+ECSRC_BM+ECSRC_BF

      P = where(Datainfo.category eq 'ORGC-SR$')
      Data = 0.
      For D = 0, N_elements(P)-1 do Data = Data + *(Datainfo[P[D]].data)
      OCSRC_an = total(Data[*,*,0]) * 1.e-9
      OCSRC_bm = total(Data[*,*,1]) * 1.e-9
      OCSRC_bf = total(Data[*,*,2]) * 1.e-9
      OCSRC_bg = total(Data[*,*,3]) * 1.e-9
      TOTEMSOC = OCSRC_AN+OCSRC_BM+OCSRC_BF+OCSRC_BG
       
 print, '--------------------------------------------------'
 print, '     Budget Component         GEOS-CHEM           '
 print, '--------------------------------------------------'
 print, 'Total Emission, Tg C/yr ', TOTEMSOC, TOTEMSEC
 print, ' Fossil fuel         :  ', OCSRC_an, ECSRC_AN
 print, ' Biomass burning     :  ', OCSRC_bm, ECSRC_BM
 print, ' Biofuel             :  ', OCSRC_bf, ECSRC_BF
 print, ' Vegetation          :  ', OCSRC_bg

 Undefine, Datainfo

  end
