  pro diag_omc, File=file, region=region, Saveout=saveout, $
      tau0=tau0, results=results

;+
;  pro diag_omc, File=file, region=region, Saveout=saveout, $
;      tau0=tau0, results=results
;-

  if n_elements(file) eq 0 then file=pickfile()
  if n_elements(tau0) ne 0 then kill = 0 else kill = 1

   Mon_str = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec']
;===============================================================================
;  Sulfate
;===============================================================================
    ;1) the emission information
    Diag = ['OC-ANTH', $     
            'OC-BIOB', $     
            'OC-BIOF', $     
            'OC-ALPH', $     
            'OC-LIMO', $     
            'OC-TERP', $
            'OC-ALCO', $
            'OC-SESQ', $
            'OC-BIOG'  ]      ; vegetation

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

      OCSRC_an = total(Results.OC_ANTH) * 1.e-9 ; Tg /yr
      OCSRC_bm = total(Results.OC_BIOB) * 1.e-9 ; Tg /yr
      OCSRC_bf = total(Results.OC_BIOF) * 1.e-9 ; Tg /yr
      OCSRC_bg = TOTAL(RESULTS.OC_BIOG) * 1.E-9

      ALPHSRC = total(Results.OC_ALPH) * 1.e-9
      LIMOSRC = total(Results.OC_LIMO) * 1.e-9 ; Tg /yr
      TERPSRC = total(Results.OC_TERP) * 1.e-9 
      ALCOSRC = total(Results.OC_ALCO) * 1.e-9 ; Tg /yr
      SESQSRC = total(Results.OC_SESQ) * 1.e-9
      BIOGSRC = total(Results.OC_BIOG) * 1.e-9 

      TOTTERP = LIMOSRC * 120.11 / (136.2364 * 0.23)  ; Tg C/yr
      ORVCSRC = SESQSRC * 180.165 / (0.05 * 204.3546) ; Tg C/yr

      TOTEMS_POA = OCSRC_an + OCSRC_bm + OCSRC_bf 
      TOTEMS_HC  = TOTTERP + ORVCSRC*0.18 

    ;2) Dry deposition information

      dryflx = get_flux( 'DRYD-FLX', file=file, region=region )

      OCDRYDEP = total( ( dryflx.OCPIDFDRYD_FLX + dryflx.OCPODFDRYD_FLX ) $
                       * dryflx.dfac ) * 12.E-12  ; Tg C/yr

    ;3) WET deposition information    
      dlsflx = get_flux('WETDLS-$', file=file, region=region, tau0=tau0)
      dcvflx = get_flux('WETDCV-$', file=file, region=region, tau0=tau0)

      OCWETDEP = total(dlsflx.OCPIWETDLS_$ + dcvflx.OCPIWETDCV_$) $
               * dcvflx.wfac * 1.e-09 ; Tg C/yr

      TOTLOSS_OC = OCDRYDEP + OCWETDEP

    ;4) burden information
      Burden = get_burden( file=file, region=region )

      OCPIBURD = total(burden.OCPI[*,*,0:19]) * 12.e-12
      OCPOBURD = total(burden.OCPO[*,*,0:19]) * 12.e-12
      OCBURD   = OCPIBURD+OCPOBURD

      Nday = burden.nday

  Period = '('
  For N = 0, N_elements(burden.Time.month)-1 do $
    Period = Period + strtrim(Mon_str(burden.Time.month[N]-1))+' '
  Period = Period+')'

  format = '(a27, 2F7.2)'

  If N_elements(region) ne 0 then $
 print, 'Regional Budget for '+Region
 print, '---------------------------------------------------------------'
 print, '	  Budget Component	   GEOS-CHEM    for ' + Period
 print, '---------------------------------------------------------------'
 print, 'Total POA Emission, Tg C   ', TOTEMS_POA , format=format
 print, ' OC fossil fuel         : ', OCSRC_an, OCSRC_an/TOTEMS_POA *100., format=format
 print, ' OC biomass burning     : ', OCSRC_bm, OCSRC_bm/TOTEMS_POA *100., format=format
 print, ' OC biofuel use         : ', OCSRC_bf, OCSRC_bf/TOTEMS_POA *100., format=format
 print, ' OC vegetation          : ', OCSRC_bg, OCSRC_bg/TOTEMS_POA *100., format=format
 print, ' '
 print, ' Parent HC emissions for SOA (Tg/yr)'
 print, ' ALPH                   : ', ALPHSRC, format=format
 print, ' LIMO                   : ', LIMOSRC, format=format
 print, ' TERP                   : ', TERPSRC, format=format
 print, ' ALCO                   : ', ALCOSRC, format=format
 print, ' SESQ                   : ', SESQSRC, format=format
 print, ' '
 print, ' Total monoterpene      : ', TOTTERP, format=format
 print, ' 18% of ORVOC           : ', 0.18*ORVCSRC, format=format
 print, ' Total ORVOC            : ', ORVCSRC, format=format
 print, ' '
 print, ' HC emissions (Tg C/yr) : ', TOTEMS_HC, format=format
 print, ' ALPH                   : ', TOTTERP * 0.67 + ORVCSRC * 0.04, format=format
 print, ' LIMO                   : ', TOTTERP * 0.23, format=format
 print, ' TERP                   : ', TOTTERP * 0.03, format=format
 print, ' ALCO                   : ', TOTTERP * 0.07 + ORVCSRC * 0.09, format=format
 print, ' SESQ                   : ', ORVCSRC * 0.05, format=format
 print, ' '
 print, 'Total OC Deposition, Tg   ', TOTLOSS_OC, format=format
 print, ' OC Dry deposition      : ', OCDRYDEP, OCDRYDEP/TOTLOSS_OC*100., format=format
 print, ' OC Wet deposition      : ', OCWETDEP, OCWETDEP/TOTLOSS_OC*100., format=format
 print, ' '
 print, 'Burden, Tg C              '
 print, ' OC                     : ', OCBURD, OCPIBURD/OCBURD*100., format=format
 print, ' '
 print, 'Life time, days
 print, ' OC                     : ', OCBURD/(OCDRYDEP+OCWETDEP)*Nday, format=format
 print, '-----------------------------------------------------'

 ctm_cleanup

end


