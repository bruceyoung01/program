  pro d_full_pm, File=file, region=region, Saveout=saveout, $
      tau0=tau0, results=results

;+
; pro diag_sulf_v02, File=file, region=region, /Saveout
;-

  if n_elements(file) eq 0 then file=pickfile()
  if n_elements(tau0) ne 0 then kill = 0 else kill = 1

   Mon_str = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec']
;===============================================================================
;  Sulfate
;===============================================================================
    ;1) the emission information
    Diag = ['SO2-AN-$', $      ;* SO2 anthropogenic
            'SO2-AC-$', $      ; Aircraft
            'SO2-BIOB', $      ; Biomass
            'SO2-EV-$', $      ;* SO2 eruptive volcanic
            'SO2-NV-$', $      ; SO2 non-eruptive volcano
            'SO4-AN-$', $      ; Anthropogenic SO4
            'DMS-BIOG'  ]      ; DMS

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

      SO2SRC_an = total(Results.SO2_AN_$ + Results.SO2_AC_$) * 1.e-9
      SO2SRC_bm = total(Results.SO2_BIOB)                    * 1.e-9 ; Tg S/yr
      SO2SRC_vo = total(Results.SO2_EV_$ + Results.SO2_NV_$) * 1.e-9 ; Tg S/yr
      SO4SRC_an = total(Results.SO4_AN_$)                    * 1.e-9 ; Tg S/yr
      DMSSRC_oc = total(Results.DMS_BIOG)                    * 1.e-9 ; Tg S/yr

      TOTEMS = SO2SRC_an + SO2SRC_bm + SO2SRC_vo + SO4SRC_an + DMSSRC_oc

    ;2) Dry deposition information
    Tracers = [7126L, 7127L, 7128L]

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
         DFAC     = Area_cm2 / 6.022D23 * Nday * 86400. * 32D-3 ; kg S/yr
      Endif

      Data = 0.
      For D = 0, N_elements(Dinfo)-1 do Data = Data + *(Dinfo[D].data)
      Data = region_only(Data, region=region)
      Data = Data * float(DFac) / float(N_elements(Dinfo))
      Results = create_struct(Results, Dinfo[0].tracername, Data)
      Undefine, Dinfo
      Undefine, Data
    End

      SO2DRYDEP = total(Results.SO2df) * 1.e-9  ; Tg S/yr
      SO4DRYDEP = total(Results.SO4df) * 1.e-9  ; Tg S/yr
      MSADRYDEP = total(Results.MSAdf) * 1.e-9  ; Tg S/yr


    ;3) WET deposition information
    ;           SO2    SO4    MSA
    Tracers = [3326L, 3327L, 3328L]
    Diag    = ['WETDLS-$', 'WETDCV-$']
    Mw      = [64., 96., 96.]

    For ND0 = 0, N_elements(Tracers)-1 do begin
    For ND1 = 0, N_elements(Diag)-1    do begin
      
      For N = 0, N_elements(File)-1 do begin
        CTM_Get_Data, Datainfo, File=file[N], Diag[ND1], tracer=Tracers[ND0], tau0=tau0
        If N eq 0 then Dinfo = Datainfo else Dinfo = [Dinfo, Datainfo]
        Undefine, Datainfo
        if (kill eq 1) then Undefine, tau0
      Endfor

      WFAC = Nday*86400.*32/Mw[ND0]

      Data = 0.
      For D = 0, N_elements(Dinfo)-1 do Data = Data + *(Dinfo[D].data)
      Data = region_only(Data, region=region)

      Data = Data * Wfac / float(N_elements(Dinfo))
      Name = Dinfo[0].tracername+exchar(Diag[ND1],'-','_')
      Results = create_struct(Results, Name, Data)
      Undefine, Data
    End
    End

      SO2WETDEP = total(Results.SO2WETDLS_$ + Results.SO2WETDCV_$) * 1.e-9 ; Tg S/yr
      SO4WETDEP = total(Results.SO4WETDLS_$ + Results.SO4WETDCV_$) * 1.e-9 ; Tg S/yr
      MSAWETDEP = total(Results.MSAWETDLS_$ + Results.MSAWETDCV_$) * 1.e-9 ; Tg S/yr

      TOTLOSS = SO2DRYDEP + SO4DRYDEP + MSADRYDEP + SO2WETDEP + SO4WETDEP + MSAWETDEP

    ; chemical prouction information

    Tracers = [6501L,6502L,6503L,6504L,6505L,6506L,6507L]
    For ND = 0, N_elements(Tracers)-1 do begin

      For N = 0, N_elements(File)-1 do begin
        CTM_Get_Data, Datainfo, File=file[N], 'PL-SUL=$', tracer=Tracers[ND], tau0=tau0
        If N eq 0 then Dinfo = Datainfo else Dinfo = [Dinfo, Datainfo]
        Undefine, Datainfo
        if (kill eq 1) then Undefine, tau0
      Endfor

      Data = 0.
      For D = 0, N_elements(Dinfo)-1 do Data = Data + *(Dinfo[D].data)
      Data = region_only(Data, region=region)
      Results = create_struct(Results, Dinfo[0].tracername, Data)
      Undefine, Dinfo
      Undefine, Data
    Endfor

      SO2DMSOH  = total(Results.SO2_OH ) * 1.e-9 ; Tg S/yr
      SO2DMSNO3 = total(Results.SO2_NO3) * 1.e-9 ; Tg S/yr
      SO2TOTAL  = SO2DMSOH + SO2DMSNO3
      MSADMS    = total(Results.MSA_DMS) * 1.e-9 

      SO4AIR    = total(Results.SO4_gas) * 1.e-9 ; Tg S/yr
      SO4AQU1   = total(Results.SO4_aq1) * 1.e-9 ; Tg S/yr
      SO4AQU2   = total(Results.SO4_aq2) * 1.e-9 ; Tg S/yr

      SO4TOTAL  = SO4AIR + SO4AQU1 + SO4AQU2

 ; Retrieve air density

      For N = 0, N_elements(File)-1 do begin
        CTM_Get_Data, Datainfo, File=file[N], 'BXHGHT-$', tracer=2004, tau0=tau0
        If N eq 0 then AirdInfo = Datainfo else AirDinfo = [AirDinfo, Datainfo]
        Undefine, Datainfo
        if (kill eq 1) then Undefine, tau0
      Endfor

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
      AD[*,*,*,D] = *(Airdinfo[D].Data) / 6.022D23 * Volume * 1.D-9 ; mole

    ; Burden information

    Tracers = [25L,26L,27L,28L]
    For ND = 0, N_elements(Tracers)-1 do begin

      For N = 0, N_elements(File)-1 do begin
        CTM_Get_Data, Datainfo, File=file[N], 'IJ-AVG-$', tracer=Tracers[ND], tau0=tau0
        If N eq 0 then Dinfo = Datainfo else Dinfo = [Dinfo, Datainfo]
        Undefine, Datainfo
        if (kill eq 1) then Undefine, tau0
      Endfor

      Data = 0.
      For D = 0, N_elements(Dinfo)-1 do Data = Data + (*(Dinfo[D].data) * AD[*,*,*,D]) ; mole
      Data = region_only(Data, region=region)
      Data = Data / float(N_elements(Dinfo))
      Results = create_struct(Results, Dinfo[0].tracername, Data)
      Undefine, Dinfo
      Undefine, Data
    Endfor

      DMSBURD = total(Results.DMS) * 32.e-12
      SO2BURD = total(Results.SO2) * 32.e-12
      SO4BURD = total(Results.SO4) * 32.e-12
      MSABURD = total(Results.MSA) * 32.e-12

  Period = '('
  For N = 0, N_elements(Time.month)-1 do $
    Period = Period + strtrim(Mon_str(Time.month[N]-1))+' '
  Period = Period+')'

  If N_elements(region) ne 0 then $
 print, 'Regional Budget for '+Region
 print, '---------------------------------------------------------------'
 print, '	  Budget Component	   GEOS-CHEM    for ' + Period
 print, '---------------------------------------------------------------'
 print, 'Total Emission, Tg S       ', TOTEMS
 print, ' SO2 anthropogenic       : ', SO2SRC_an, SO2SRC_an/TOTEMS*100.
 print, ' SO2 biomass burning     : ', SO2SRC_bm, SO2SRC_bm/TOTEMS*100.
 print, ' SO2 volcanic            : ', SO2SRC_vo, SO2SRC_vo/TOTEMS*100.
 print, ' Sulfate anthropogenic   : ', SO4SRC_an, SO4SRC_an/TOTEMS*100.
 print, ' DMS oceanic             : ', DMSSRC_oc, DMSSRC_oc/TOTEMS*100.
 print, ' '
 print, 'Total Deposition, Tg S     ', TOTLOSS
 print, ' SO2 Dry deposition      : ', SO2DRYDEP, SO2DRYDEP/TOTLOSS*100.
 print, ' SO2 Wet deposition      : ', SO2WETDEP, SO2WETDEP/TOTLOSS*100.
 print, ' Sulfate Dry deposition  : ', SO4DRYDEP, SO4DRYDEP/TOTLOSS*100.
 print, ' Sulfate Wet deposition  : ', SO4WETDEP, SO4WETDEP/TOTLOSS*100.
 print, ' MSA Dry deposition      : ', MSADRYDEP, MSADRYDEP/TOTLOSS*100.
 print, ' MSA Wet deposition      : ', MSAWETDEP, MSAWETDEP/TOTLOSS*100.
 print, ' '
 print, 'SO2 production Tg S        ', SO2TOTAL
 print, ' from DMS + OH           : ', SO2DMSOH,  SO2DMSOH/SO2TOTAL*100.
 print, ' from DMS + NO3          : ', SO2DMSNO3, SO2DMSNO3/SO2TOTAL*100.
 print, ' '
 print, 'Sulfate production, Tg S   ', SO4TOTAL
 print, ' In-air                  : ', SO4AIR,    SO4AIR/SO4TOTAL*100.
 print, ' In-cloud with H2O2      : ', SO4AQU1,   SO4AQU1/SO4TOTAL*100.
 print, ' In-cloud with O3        : ', SO4AQU2,   SO4AQU2/SO4TOTAL*100.
 print, ' '
 print, 'Burden, Tg S               '
 print, ' SO2                     : ', SO2BURD
 print, ' Sulfate                 : ', SO4BURD
 print, ' DMS                     : ', DMSBURD
 print, ' MSA                     : ', MSABURD
 print, ' '
 print, 'Life time, days
 print, ' SO2                     : ', SO2BURD/(SO2DRYDEP+SO2WETDEP+SO4TOTAL)*Nday
 print, ' Sulfate                 : ', SO4BURD/(SO4DRYDEP+SO4WETDEP)*Nday
 print, ' DMS                     : ', DMSBURD/(SO2TOTAL)*Nday
 print, ' MSA                     : ', MSABURD/(MSADRYDEP+MSAWETDEP)*Nday
 print, ' '
 print, 'Loss frequency, /day       '
 print, ' SO2 dry deposition      : ', SO2DRYDEP/SO2BURD/Nday
 print, ' SO2 in-air oxidation    : ', SO4AIR/SO2BURD/Nday
 print, ' SO2 wet processes       : ', (SO4AQU1+SO4AQU2+SO2WETDEP)/SO2BURD/Nday
 print, ' Sulfate dry deposition  : ', SO4DRYDEP/SO4BURD/Nday
 print, ' Sulfate wet scavenging  : ', SO4WETDEP/SO4BURD/Nday
 print, '-----------------------------------------------------'

 If Keyword_set(Saveout) then begin

  Openw, Ilun, 'Diag_sulf.txt', /Get

  If N_elements(region) ne 0 then $
 printf, ilun, 'Regional Budget for '+Region
 printf, ilun, '--------------------------------------------------'
 printf, ilun, '     Budget Component         GEOS-CHEM           '
 printf, ilun, '--------------------------------------------------'
 printf, ilun, 'Total Emission, Tg S/yr    ', TOTEMS
 printf, ilun, ' SO2 anthropogenic       : ', SO2SRC_an, SO2SRC_an/TOTEMS*100.
 printf, ilun, ' SO2 biomass burning     : ', SO2SRC_bm, SO2SRC_bm/TOTEMS*100.
 printf, ilun, ' SO2 volcanic            : ', SO2SRC_vo, SO2SRC_vo/TOTEMS*100.
 printf, ilun, ' Sulfate anthropogenic   : ', SO4SRC_an, SO4SRC_an/TOTEMS*100.
 printf, ilun, ' DMS oceanic             : ', DMSSRC_oc, DMSSRC_oc/TOTEMS*100.
 printf, ilun, ' '
 printf, ilun, 'Total Deposition, Tg S/yr  ', TOTLOSS
 printf, ilun, ' SO2 Dry deposition      : ', SO2DRYDEP, SO2DRYDEP/TOTLOSS*100.
 printf, ilun, ' SO2 Wet deposition      : ', SO2WETDEP, SO2WETDEP/TOTLOSS*100.
 printf, ilun, ' Sulfate Dry deposition  : ', SO4DRYDEP, SO4DRYDEP/TOTLOSS*100.
 printf, ilun, ' Sulfate Wet deposition  : ', SO4WETDEP, SO4WETDEP/TOTLOSS*100.
 printf, ilun, ' MSA Dry deposition      : ', MSADRYDEP, MSADRYDEP/TOTLOSS*100.
 printf, ilun, ' MSA Wet deposition      : ', MSAWETDEP, MSAWETDEP/TOTLOSS*100.
 printf, ilun, ' '
 printf, ilun, 'SO2 production Tg S/yr     ', SO2TOTAL
 printf, ilun, ' from DMS + OH           : ', SO2DMSOH,  SO2DMSOH/SO2TOTAL*100.
 printf, ilun, ' from DMS + NO3          : ', SO2DMSNO3, SO2DMSNO3/SO2TOTAL*100.
 printf, ilun, ' '
 printf, ilun, 'Sulfate production, Tg S/yr', SO4TOTAL
 printf, ilun, ' In-air                  : ', SO4AIR,    SO4AIR/SO4TOTAL*100.
 printf, ilun, ' In-cloud with H2O2      : ', SO4AQU1,   SO4AQU1/SO4TOTAL*100.
 printf, ilun, ' In-cloud with O3        : ', SO4AQU2,   SO4AQU2/SO4TOTAL*100.
 printf, ilun, ' '
 printf, ilun, 'Burden, Tg S               '
 printf, ilun, ' SO2                     : ', SO2BURD
 printf, ilun, ' Sulfate                 : ', SO4BURD
 printf, ilun, ' DMS                     : ', DMSBURD
 printf, ilun, ' MSA                     : ', MSABURD
 printf, ilun, ' '
 printf, ilun, 'Life time, days
 printf, ilun, ' SO2                     : ', SO2BURD/(SO2DRYDEP+SO2WETDEP+SO4TOTAL)*Nday
 printf, ilun, ' Sulfate                 : ', SO4BURD/(SO4DRYDEP+SO4WETDEP)*Nday
 printf, ilun, ' DMS                     : ', DMSBURD/(SO2TOTAL)*Nday
 printf, ilun, ' MSA                     : ', MSABURD/(MSADRYDEP+MSAWETDEP)*Nday
 printf, ilun, ' '
 printf, ilun, 'Loss frequency, /day       '
 printf, ilun, ' SO2 dry deposition      : ', SO2DRYDEP/SO2BURD/Nday
 printf, ilun, ' SO2 in-air oxidation    : ', SO4AIR/SO2BURD/Nday
 printf, ilun, ' SO2 wet processes       : ', (SO4AQU1+SO4AQU2+SO2WETDEP)/SO2BURD/Nday
 printf, ilun, ' Sulfate dry deposition  : ', SO4DRYDEP/SO4BURD/Nday
 printf, ilun, ' Sulfate wet scavenging  : ', SO4WETDEP/SO4BURD/Nday
 printf, ilun, '-----------------------------------------------------'
 free_lun, ilun

 Endif

 Heap_gc
end


