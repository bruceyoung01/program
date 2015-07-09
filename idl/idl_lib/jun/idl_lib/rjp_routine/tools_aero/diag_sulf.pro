  pro diag_sulf, File=file, region=region, Saveout=saveout, $
      tau0=tau0, results=results

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

      If ND eq 0 then N_SO2 = Long(Dinfo[0].tracer - 400L)

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

      TOTEMS = SO2SRC_an + SO2SRC_bm + SO2SRC_vo + SO4SRC_an + DMSSRC_oc + $
               SO2SRC_bf

    ;2) Dry deposition information
    Tracers = Lindgen(3) + 7100L + N_SO2

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
    Tracers = Lindgen(3) + 200L + N_SO2
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

    Case N_SO2 of 
        26 : Tracers = [6501L,6502L,6503L,6504L,6505L,6506L,6507L]
        53 : Tracers = [5651L,5652L,5653L,5654L,5655L,5656L,5657L]   
    End

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

      SO2DMSOH  = total(Results.SO2OH ) * 1.e-9 ; Tg S/yr
      SO2DMSNO3 = total(Results.SO2NO3) * 1.e-9 ; Tg S/yr
      SO2TOTAL  = SO2DMSOH + SO2DMSNO3
      MSADMS    = total(Results.MSADMS) * 1.e-9 

      SO4AIR    = total(Results.SO4gas) * 1.e-9 ; Tg S/yr
      SO4AQU1   = total(Results.SO4aq1) * 1.e-9 ; Tg S/yr
      SO4AQU2   = total(Results.SO4aq2) * 1.e-9 ; Tg S/yr

      SO4TOTAL = SO4AIR + SO4AQU1 + SO4AQU2

 ; Retrieve air density

      For N = 0, N_elements(File)-1 do begin
        CTM_Get_Data, Datainfo, File=file[N], 'BXHGHT-$', tracer=2004, tau0=tau0
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
      AD[*,*,*,D] = *(Airdinfo[D].Data) / 6.022D23 * Volume ; mole

    ; Burden information

    Tracers = Lindgen(4) + N_SO2 - 1L
    For ND = 0, N_elements(Tracers)-1 do begin

      For N = 0, N_elements(File)-1 do begin
        CTM_Get_Data, Datainfo, File=file[N], 'IJ-24H-$', tracer=Tracers[ND], tau0=tau0
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

      DMSBURD = total(Results.DMS[*,*,0:19]) * 32.e-12
      SO2BURD = total(Results.SO2[*,*,0:19]) * 32.e-12
      SO4BURD = total(Results.SO4[*,*,0:19]) * 32.e-12
      MSABURD = total(Results.MSA[*,*,0:19]) * 32.e-12

  Period = '('
  For N = 0, N_elements(Time.month)-1 do $
    Period = Period + strtrim(Mon_str(Time.month[N]-1))+' '
  Period = Period+')'

  format = '(a27, 2F7.2)'
  If N_elements(region) ne 0 then $
 print, 'Regional Budget for '+Region
 print, '---------------------------------------------------------------'
 print, 'Budget Component GEOS-CHEM for ' + Period
 print, '---------------------------------------------------------------'
 print, 'Total Emission, Tg S       ', TOTEMS, format=format
 print, ' SO2 anthropogenic       : ', SO2SRC_an, SO2SRC_an/TOTEMS*100., format=format
 print, ' SO2 biomass burning     : ', SO2SRC_bm, SO2SRC_bm/TOTEMS*100., format=format
 print, ' SO2 biofuel use         : ', SO2SRC_bf, SO2SRC_bf/TOTEMS*100., format=format
 print, ' SO2 volcanic            : ', SO2SRC_vo, SO2SRC_vo/TOTEMS*100., format=format
 print, ' Sulfate anthropogenic   : ', SO4SRC_an, SO4SRC_an/TOTEMS*100., format=format
 print, ' DMS oceanic             : ', DMSSRC_oc, DMSSRC_oc/TOTEMS*100., format=format
 print, ' '
 print, 'Total Deposition, Tg S     ', TOTLOSS, format=format
 print, ' SO2 Dry deposition      : ', SO2DRYDEP, SO2DRYDEP/TOTLOSS*100., format=format
 print, ' SO2 Wet deposition      : ', SO2WETDEP, SO2WETDEP/TOTLOSS*100., format=format
 print, ' Sulfate Dry deposition  : ', SO4DRYDEP, SO4DRYDEP/TOTLOSS*100., format=format
 print, ' Sulfate Wet deposition  : ', SO4WETDEP, SO4WETDEP/TOTLOSS*100., format=format
 print, ' MSA Dry deposition      : ', MSADRYDEP, MSADRYDEP/TOTLOSS*100., format=format
 print, ' MSA Wet deposition      : ', MSAWETDEP, MSAWETDEP/TOTLOSS*100., format=format
 print, ' '
 print, 'SO2 production Tg S        ', SO2TOTAL, format=format
 print, ' from DMS + OH           : ', SO2DMSOH,  SO2DMSOH/SO2TOTAL*100., format=format
 print, ' from DMS + NO3          : ', SO2DMSNO3, SO2DMSNO3/SO2TOTAL*100., format=format
 print, ' '
 print, 'Sulfate production, Tg S   ', SO4TOTAL, format=format
 print, ' In-air                  : ', SO4AIR,    SO4AIR/SO4TOTAL*100., format=format
 print, ' In-cloud with H2O2      : ', SO4AQU1,   SO4AQU1/SO4TOTAL*100., format=format
 print, ' In-cloud with O3        : ', SO4AQU2,   SO4AQU2/SO4TOTAL*100., format=format
 print, ' '
 print, 'Burden, Tg S               '
 print, ' SO2                     : ', SO2BURD, format=format
 print, ' Sulfate                 : ', SO4BURD, format=format
 print, ' DMS                     : ', DMSBURD, format=format
 print, ' MSA                     : ', MSABURD, format=format
 print, ' '
 print, 'Life time, days
 print, ' SO2 (deposition)        : ', SO2BURD/(SO2DRYDEP+SO2WETDEP)*Nday, format=format
 print, ' SO2 (chemistry)         : ', SO2BURD/(SO4TOTAL)*Nday, format=format
 print, ' Sulfate (deposition)    : ', SO4BURD/(SO4DRYDEP+SO4WETDEP)*Nday, format=format
 print, ' DMS (chemistry)         : ', DMSBURD/(SO2TOTAL)*Nday, format=format
 print, ' MSA (deposition)        : ', MSABURD/(MSADRYDEP+MSAWETDEP)*Nday, format=format
 print, ' '
; print, 'Loss frequency, /day       '
; print, ' SO2 in-air oxidation    : ', SO4AIR/(SO2BURD*Nday)
; print, ' SO2 in-cloud oxidation  : ', (SO4AQU1+SO4AQU2)/(SO2BURD*Nday)
; print, ' SO2 dry deposition      : ', SO2DRYDEP/(SO2BURD*Nday)
; print, ' SO2 wet deposition      : ', SO2WETDEP/(SO2BURD*Nday)
; print, ' Sulfate dry deposition  : ', SO4DRYDEP/(SO4BURD*Nday)
; print, ' Sulfate wet scavenging  : ', SO4WETDEP/(SO4BURD*Nday)
 print, '-----------------------------------------------------'

 ctm_cleanup

end


