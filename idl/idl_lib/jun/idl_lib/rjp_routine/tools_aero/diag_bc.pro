  pro diag_bc, File=file, region=region, Saveout=saveout, $
      tau0=tau0, results=results

;+
;  pro diag_bc, File=file, region=region, Saveout=saveout, $
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
            'BC-BIOF']

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

      BCSRC_an = total(Results.BC_ANTH) * 1.e-9
      BCSRC_bm = total(Results.BC_BIOB) * 1.e-9 ; Tg /yr
      BCSRC_bf = total(Results.BC_BIOF) * 1.e-9 ; Tg /yr

      TOTEMS_BC = BCSRC_an + BCSRC_bm + BCSRC_bf 

    ;2) Dry deposition information

      dryflx = get_flux( 'DRYD-FLX', file=file, tau0=tau0, region=region )

      BCDRYDEP = total( ( dryflx.BCPIDFDRYD_FLX + dryflx.BCPODFDRYD_FLX ) $
                       * dryflx.dfac ) * 12.E-12  ; Tg C/yr

    ;3) WET deposition information    
      dlsflx = get_flux('WETDLS-$', file=file, tau0=tau0, region=region)
      dcvflx = get_flux('WETDCV-$', file=file, tau0=tau0, region=region)

      BCWETDEP = total(dlsflx.BCPIWETDLS_$ + dcvflx.BCPIWETDCV_$) $
               * dcvflx.wfac * 1.e-09 ; Tg C/yr

      TOTLOSS_BC = BCDRYDEP + BCWETDEP

    ;4) burden information
      Burden = get_burden( file=file, tau0=tau0, region=region )

      BCPIBURD = total(burden.BCPI[*,*,0:19]) * 12.e-12
      BCPOBURD = total(burden.BCPO[*,*,0:19]) * 12.e-12
      BCBURD   = BCPIBURD+BCPOBURD

      Nday = burden.nday
      Time = burden.time
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
 print, 'Total BC Emission, Tg C   ', TOTEMS_BC, format=format
 print, ' BC fossil fuel         : ', BCSRC_an, BCSRC_an/TOTEMS_BC*100., format=format
 print, ' BC biomass burning     : ', BCSRC_bm, BCSRC_bm/TOTEMS_BC*100., format=format
 print, ' BC biofuel use         : ', BCSRC_bf, BCSRC_bf/TOTEMS_BC*100., format=format
 print, ' '
 print, 'Total BC Deposition, Tg   ', TOTLOSS_BC, format=format
 print, ' BC Dry deposition      : ', BCDRYDEP, BCDRYDEP/TOTLOSS_BC*100., format=format
 print, ' BC Wet deposition      : ', BCWETDEP, BCWETDEP/TOTLOSS_BC*100., format=format
 print, ' '
 print, 'Burden, Tg C              '
 print, ' BC                     : ', BCBURD, BCPIBURD/BCBURD*100., format=format
 print, ' '
 print, 'Life time, days
 print, ' BC                     : ', BCBURD/(BCDRYDEP+BCWETDEP)*Nday, format=format
 print, '-----------------------------------------------------'


 ctm_cleanup
end


