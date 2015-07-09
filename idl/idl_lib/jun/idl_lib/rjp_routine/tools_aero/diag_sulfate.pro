  pro diag_sulfate, File=file, region=region, Saveout=saveout, $
      tau0=tau0, results=results, prodloss=prodloss

;+
; pro diag_sulf, File=file, region=region, /Saveout
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
            'SO2-BIOF', $      ; Biofuel
            'SO2-EV-$', $      ;* SO2 eruptive volcanic
            'SO2-NV-$', $      ; SO2 non-eruptive volcano
            'SO4-AN-$', $      ; Anthropogenic SO4
            'DMS-BIOG', $      ; DMS
            'SO2-SHIP'  ]      ; SHIP emission

    For ND = 0, N_elements(Diag)-1 do begin

      For N = 0, N_elements(File)-1 do begin
        CTM_Get_Data, Datainfo, File=file[N], Diag[ND], tau0=tau0

        If N_elements(Datainfo) gt 0 then begin
           If N_elements(Dinfo) eq 0 then $
              Dinfo = Datainfo else Dinfo = [Dinfo, Datainfo]

           Undefine, Datainfo
        end

        if (kill eq 1) then Undefine, tau0
      Endfor

      Data = 0.
      For D = 0, N_elements(Dinfo)-1 do Data = Data + *(Dinfo[D].data)

      If ND eq 0 then begin
         N_SO2 = Long(Dinfo[0].tracer - 200L)
         ; Find uniq tau0 and tau1
         UTAU0    = Dinfo.tau0
         UTAU0    = Utau0[uniq(Utau0, sort(Utau0))]
         UTAU1    = Dinfo.tau1
         UTAU1    = Utau1[uniq(Utau1, sort(Utau1))]

         Time     = tau2yymmdd(Utau0)
      Endif

      Undefine, Dinfo
      Data = region_only(Data, region=region)

      Name = exchar(Diag[ND],'-','_')
      If ND eq 0 then Results = create_struct(Name, Data) $
      else            Results = create_struct(Results, Name, Data)

      Undefine, Data
      Undefine, Name

    Endfor

      TAG       = TAG_NAMES(Results)
      SO2SRC_an = total(Results.SO2_AN_$ ) * 1.e-9
      SO2SRC_AC = total(Results.SO2_AC_$ ) * 1.e-9
      SO2SRC_bm = total(Results.SO2_BIOB)                    * 1.e-9 ; Tg S/yr
      SO2SRC_bf = total(Results.SO2_BIOF)                    * 1.e-9 ; Tg S/yr
      SO2SRC_vo = total(Results.SO2_EV_$ + Results.SO2_NV_$) * 1.e-9 ; Tg S/yr
      SO4SRC_an = total(Results.SO4_AN_$)                    * 1.e-9 ; Tg S/yr
      DMSSRC_oc = total(Results.DMS_BIOG)                    * 1.e-9 ; Tg S/yr

      ck = where(TAG eq 'SO2_SHIP')
      if ck[0] ne -1 then SO2SRC_sh = total(Results.SO2_SHIP) * 1.e-9 $
      else SO2SRC_sh = 0.

      TOTEMS = SO2SRC_an + SO2SRC_bm + SO2SRC_vo + SO4SRC_an + DMSSRC_oc + $
               SO2SRC_bf + SO2SRC_sh + SO2SRC_ac


      Undefine, Dinfo

    ;2) Dry deposition information

      dryflx = get_flux( 'DRYD-FLX', file=file, region=region )

      SO2DRYDEP = total(dryflx.SO2DFDRYD_FLX  * dryflx.dfac) * 32.e-12  ; Tg S/yr
      SO4DRYDEP = total(dryflx.SO4DFDRYD_FLX * dryflx.dfac) * 32.e-12  ; Tg S/yr
      MSADRYDEP = total(dryflx.MSADFDRYD_FLX * dryflx.dfac) * 32.e-12  ; Tg S/yr
      H2O2DRYDEP= total(dryflx.H2O2DFDRYD_FLX * dryflx.dfac) * 34.e-12 ; Tg H2O2/yr
      Undefine, dryflx

    ;3) WET deposition information
      dlsflx = get_flux('WETDLS-$', file=file, tau0=tau0, region=region)
      dcvflx = get_flux('WETDCV-$', file=file, tau0=tau0, region=region)

      SO2WETDEP = total(dlsflx.SO2WETDLS_$ + dcvflx.SO2WETDCV_$) * dcvflx.wfac * 32./64. * 1.e-9 ; Tg S/yr
      SO4WETDEP = total(dlsflx.SO4WETDLS_$ + dcvflx.SO4WETDCV_$) * dcvflx.wfac * 32./96. * 1.e-9 ; Tg S/yr
      MSAWETDEP = total(dlsflx.MSAWETDLS_$ + dcvflx.MSAWETDCV_$) * dcvflx.wfac * 32./96. * 1.e-9 ; Tg S/yr
      H2O2WETDEP = total(dlsflx.H2O2WETDLS_$ + dcvflx.H2O2WETDCV_$) * dcvflx.wfac * 1.e-9 ; Tg H2O2/yr

      TOTLOSS = SO2DRYDEP + SO4DRYDEP + MSADRYDEP + SO2WETDEP + SO4WETDEP + MSAWETDEP

      Undefine, dlsflx
      Undefine, dcvflx

    ;4) chemical prouction information
    If Keyword_set(prodloss) then begin

      Results   = get_flux('PL-SUL=$', file=file, region=region, tau0=tau0)

      Ndata     = float(N_elements(Results.tau))
      SO2DMSOH  = total(Results.SO2DMSPL_SUL_$) * Ndata * 1.e-9 ; Tg S/yr
      SO2DMSNO3 = total(Results.SO2NO3PL_SUL_$) * Ndata * 1.e-9 ; Tg S/yr
      SO2TOTAL  = SO2DMSOH + SO2DMSNO3
      MSADMS    = total(Results.MSADMSPL_SUL_$) * Ndata * 1.e-9

      SO4AIR    = total(Results.SO4gasPL_SUL_$) * Ndata * 1.e-9 ; Tg S/yr
      SO4AQU1   = total(Results.SO4aq1PL_SUL_$) * Ndata * 1.e-9 ; Tg S/yr
      SO4AQU2   = total(Results.SO4aq2PL_SUL_$) * Ndata * 1.e-9 ; Tg S/yr

      ; lwc calculation is not correct
       LWC       = 0.
       LWC       = Results.LH2O2PL_SUL_$ * Results.vfac * 1000. ; kg water
       LWC       = Total(LWC) * 1.e-9 ; Tg water


      If SO2TOTAL EQ 0. THEN BEGIN
         PL = GET_FLUX('PORL-L=$', FILE=FILE, TAU0=TAU0, region=region) ; molec/cm3/s
         Ndata    = float(N_elements(PL.tau))
         SO2TOTAL = total(PL.PSO2PORL_L_$ * PL.CFAC) * 32.E-12  ; Tg S
         SO4AIR   = TOTAL(PL.LSO2PORL_L_$ * PL.CFAC) * 32.E-12  ; Tg S
      end


      SO4TOTAL  = SO4AIR + SO4AQU1 + SO4AQU2

      Undefine, results
      Undefine, PL
    endif

    ;4) burden information
      Burden = get_burden( file=file, region=region )

      Nday    = burden.nday
      DMSBURD = total(burden.DMS[*,*,0:19]) * 32.e-12
      SO2BURD = total(burden.SO2[*,*,0:19]) * 32.e-12
      SO4BURD = total(burden.SO4[*,*,0:19]) * 32.e-12
      MSABURD = total(burden.MSA[*,*,0:19]) * 32.e-12
      H2O2BURD= total(burden.H2O2[*,*,0:19])* 34.e-12

      Undefine, Dinfo

  Period = '('
  For N = 0, N_elements(Time.month)-1 do $
    Period = Period + strtrim(Mon_str(Time.month[N]-1))+' '
  Period = Period+')'

  format = '(a27, 2F7.2)'

  If N_elements(region) ne 0 then $
 print, 'Regional Budget for '+Region
 print, '---------------------------------------------------------------'
 print, '	  Budget Component	   GEOS-CHEM    for ' + Period
 print, '---------------------------------------------------------------'
 print, 'Total Emission, Tg S       ', TOTEMS, format=format
 print, ' SO2 anthropogenic       : ', SO2SRC_an, SO2SRC_an/TOTEMS*100., format=format
 print, ' SO2 aircraft            : ', SO2SRC_ac, SO2SRC_ac/TOTEMS*100., format=format
 print, ' SO2 biomass burning     : ', SO2SRC_bm, SO2SRC_bm/TOTEMS*100., format=format
 print, ' SO2 biofuel use         : ', SO2SRC_bf, SO2SRC_bf/TOTEMS*100., format=format
 print, ' SO2 volcanic            : ', SO2SRC_vo, SO2SRC_vo/TOTEMS*100., format=format
 print, ' Sulfate anthropogenic   : ', SO4SRC_an, SO4SRC_an/TOTEMS*100., format=format
 print, ' DMS oceanic             : ', DMSSRC_oc, DMSSRC_oc/TOTEMS*100., format=format
 print, ' SHIP emission           : ', SO2SRC_sh, SO2SRC_sh/TOTEMS*100., format=format
 print, ' '
 print, 'Total Deposition, Tg S     ', TOTLOSS, format=format
 print, ' SO2 Dry deposition      : ', SO2DRYDEP, SO2DRYDEP/TOTLOSS*100., format=format
 print, ' SO2 Wet deposition      : ', SO2WETDEP, SO2WETDEP/TOTLOSS*100., format=format
 print, ' Sulfate Dry deposition  : ', SO4DRYDEP, SO4DRYDEP/TOTLOSS*100., format=format
 print, ' Sulfate Wet deposition  : ', SO4WETDEP, SO4WETDEP/TOTLOSS*100., format=format
 print, ' MSA Dry deposition      : ', MSADRYDEP, MSADRYDEP/TOTLOSS*100., format=format
 print, ' MSA Wet deposition      : ', MSAWETDEP, MSAWETDEP/TOTLOSS*100., format=format
 print, ' H2O2 Dry deposition     : ', H2O2DRYDEP, format=format
 print, ' H2O2 Wet deposition     : ', H2O2WETDEP, format=format
 print, ' '

If Keyword_set(prodloss) then begin

 print, 'SO2 production Tg S        ', SO2TOTAL, format=format
 print, ' from DMS + OH           : ', SO2DMSOH,  SO2DMSOH/SO2TOTAL*100., format=format
 print, ' from DMS + NO3          : ', SO2DMSNO3, SO2DMSNO3/SO2TOTAL*100., format=format
 print, ' '
 print, 'Sulfate production, Tg S   ', SO4TOTAL, format=format
 print, ' In-air                  : ', SO4AIR,    SO4AIR/SO4TOTAL*100., format=format
 print, ' In-cloud with H2O2      : ', SO4AQU1,   SO4AQU1/SO4TOTAL*100., format=format
 print, ' In-cloud with O3        : ', SO4AQU2,   SO4AQU2/SO4TOTAL*100., format=format
 print, ' LWC (Tg water)          : ', LWC;, format=format
 print, ' '
endif

 print, 'Burden, Tg S               '
 print, ' SO2                     : ', SO2BURD, format=format
 print, ' Sulfate                 : ', SO4BURD, format=format
 print, ' DMS                     : ', DMSBURD, format=format
 print, ' MSA                     : ', MSABURD, format=format
 print, ' H2O2                    : ', H2O2BURD, format=format
 print, ' '
 print, 'Life time, days
if keyword_set(prodloss) then $
 print, ' SO2                     : ', SO2BURD/(SO2DRYDEP+SO2WETDEP+SO4TOTAL)*Nday, format=format
 print, ' SO2 (deposition)        : ', SO2BURD/(SO2DRYDEP+SO2WETDEP)*Nday, format=format
if keyword_set(prodloss) then $
 print, ' SO2 (chemistry)         : ', SO2BURD/(SO4TOTAL)*Nday, format=format
 print, ' Sulfate (deposition)    : ', SO4BURD/(SO4DRYDEP+SO4WETDEP)*Nday, format=format
if keyword_set(prodloss) then $
 print, ' DMS (chemistry)         : ', DMSBURD/(SO2TOTAL)*Nday, format=format
 print, ' MSA (deposition)        : ', MSABURD/(MSADRYDEP+MSAWETDEP)*Nday, format=format
 print, ' H2O2 (deposition)       : ', H2O2BURD/(H2O2DRYDEP+H2O2WETDEP)*Nday, format=format
 print, ' '
 print, '-----------------------------------------------------'

 ctm_cleanup
end


