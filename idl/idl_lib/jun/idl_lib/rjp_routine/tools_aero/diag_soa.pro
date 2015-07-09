  function diag_soa, File=file, region=region, Saveout=saveout, $
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
    Diag = ['OC-ALPH', $      ;* SO2 anthropogenic
            'OC-LIMO', $      ; Aircraft
            'OC-TERP', $
            'OC-ALCO', $
            'OC-SESQ', $
            'OC-BIOG'  ]      ; Biomass

    For ND = 0, N_elements(Diag)-1 do begin

      For N = 0, N_elements(File)-1 do begin
        CTM_Get_Data, Datainfo, File=file[N], Diag[ND], tau0=tau0
        If N eq 0 then Dinfo = Datainfo else Dinfo = [Dinfo, Datainfo]
        Undefine, Datainfo
        if (kill eq 1) then Undefine, tau0
      Endfor
    
      Data = 0.
      For D = 0, N_elements(Dinfo)-1 do Data = Data + *(Dinfo[D].data) 

      If ND eq 0 then NALPH = Long(Dinfo[0].tracer - 6100L)

      Data = region_only(Data, region=region)

      Name = exchar(Diag[ND],'-','_')
      If ND eq 0 then Results = create_struct(Name, Data) $
      else            Results = create_struct(Results, Name, Data)
 
      Undefine, Dinfo
      Undefine, Data
      Undefine, Name

    Endfor

      ALPHSRC = total(Results.OC_ALPH) * 1.e-9
      LIMOSRC = total(Results.OC_LIMO) * 1.e-9 ; Tg /yr
      TERPSRC = total(Results.OC_TERP) * 1.e-9 
      ALCOSRC = total(Results.OC_ALCO) * 1.e-9 ; Tg /yr
      SESQSRC = total(Results.OC_SESQ) * 1.e-9
      BIOGSRC = total(Results.OC_BIOG) * 1.e-9 
      ORVCSRC = SESQSRC * 180.165 / (0.05 * 204.3546)

    ;2) Dry deposition information
    Tracers = Lindgen(9) + 7100L + NALPH
    Mw = [136.23,136.23,142.00, $
          150.00,160.00,220.00,150.00,160.00,220.00]
    Mw = Mw * 1.e-3 ; kg/mole

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
         Area_m2  = CTM_BOXSIZE( GridInfo, /GEOS, /m2 )
         Nday     = 0.
         For N    = 0, N_elements(Dinfo)-1 do $
             Nday = Nday + float(Dinfo[N].tau1-Dinfo[N].tau0)/24.
         Time     = tau2yymmdd(Dinfo.tau0)
      Endif

      DFAC  = Area_cm2 / 6.022D23 * Nday * 86400. * Mw[ND] ; kg/yr
      Data  = 0.
      For D = 0, N_elements(Dinfo)-1 do Data = Data + *(Dinfo[D].data)
      Data = region_only(Data, region=region)
      Data = Data * float(DFac) / float(N_elements(Dinfo))
      Results = create_struct(Results, Dinfo[0].tracername, Data)
      Undefine, Dinfo
      Undefine, Data
    End

      ALPHDDEP = total(Results.ALPHDF) * 1.e-9
      LIMODDEP = total(Results.LIMODF) * 1.e-9 ; Tg /yr
      ALCODDEP = total(Results.ALCODF) * 1.e-9 ; Tg /yr
      SOG1DDEP = TOTAL(RESULTS.SOG1DF) * 1.E-9
      SOG2DDEP = TOTAL(RESULTS.SOG2DF) * 1.E-9
      SOG3DDEP = TOTAL(RESULTS.SOG3DF) * 1.E-9
      SOA1DDEP = TOTAL(RESULTS.SOA1DF) * 1.E-9
      SOA2DDEP = TOTAL(RESULTS.SOA2DF) * 1.E-9
      SOA3DDEP = TOTAL(RESULTS.SOA3DF) * 1.E-9
    ;3) WET deposition information
    ;           EC   
    Tracers = Lindgen(9) + 200L + NALPH
    Diag    = ['WETDLS-$', 'WETDCV-$']

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

      ALPHWDEP = total(Results.ALPHWETDLS_$ + Results.ALPHWETDCV_$) * 1.e-9
      LIMOWDEP = total(Results.LIMOWETDLS_$ + Results.LIMOWETDCV_$) * 1.e-9 ; Tg /yr
;      TERPWDEP = total(Results.TERPWETDLS_$ + Results.TERPWETDCV_$) * 1.e-9 
      ALCOWDEP = total(Results.ALCOWETDLS_$ + Results.ALCOWETDCV_$) * 1.e-9 ; Tg /yr
;      SESQWDEP = total(Results.SESQWETDLS_$ + Results.SESQWETDCV_$) * 1.e-9
      SOG1WDEP = total(Results.SOG1WETDLS_$ + Results.SOG1WETDCV_$) * 1.e-9
      SOG2WDEP = total(Results.SOG2WETDLS_$ + Results.SOG2WETDCV_$) * 1.e-9 ; Tg /yr
      SOG3WDEP = total(Results.SOG3WETDLS_$ + Results.SOG3WETDCV_$) * 1.e-9 ; Tg /yr
      SOA1WDEP = total(Results.SOA1WETDLS_$ + Results.SOA1WETDCV_$) * 1.e-9 
      SOA2WDEP = total(Results.SOA2WETDLS_$ + Results.SOA2WETDCV_$) * 1.e-9
      SOA3WDEP = total(Results.SOA3WETDLS_$ + Results.SOA3WETDCV_$) * 1.e-9


    ;1) the SOA chemical production [kg]
    Diag = 'PL-OC=$'
    Tracers = Lindgen(3) + 6100L + NALPH + 6L

    For ND = 0, N_elements(Tracers)-1 do begin

      For N = 0, N_elements(File)-1 do begin
        CTM_Get_Data, Datainfo, File=file[N], Diag, tracer=Tracers[ND], tau0=tau0
        If N eq 0 then Dinfo = Datainfo else Dinfo = [Dinfo, Datainfo]
        Undefine, Datainfo
        if (kill eq 1) then Undefine, tau0
      Endfor

      Data  = 0.
      For D = 0, N_elements(Dinfo)-1 do Data = Data + *(Dinfo[D].data) ; kg
      Data = region_only(Data, region=region)
      Results = create_struct(Results, Dinfo[0].tracername+'CH', Data)
      Undefine, Dinfo
      Undefine, Data
    End

      SOA1CHEM = total(Results.SOA1CH) * 1.e-9
      SOA2CHEM = total(Results.SOA2CH) * 1.e-9 ; Tg /yr
      SOA3CHEM = total(Results.SOA3CH) * 1.e-9 ; Tg /yr

      SOA1REAC = ALPHSRC + LIMOSRC + TERPSRC - (ALPHDDEP + LIMODDEP) $
               - (ALPHWDEP + LIMOWDEP)
      SOA2REAC = ALCOSRC - ALCODDEP - ALCOWDEP
      SOA3REAC = SESQSRC 

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
             Else: return, -1
         End
         file_aird = '/users/ctm/rjp/Asim/data/aird_'+DXDY+'_'+Year+'.bpch'
         file_aird = findfile(file_aird)
      
         If file_aird[0] ne '' then begin
            CTM_Get_Data, AirdInfo, 'BXHGHT-$', File=file_aird[0], tracer=2004, tau0=tau0
         end else begin
            Print, 'No Airdensity data'
            Return, -1
         End

      Endif

;      If N_elements(Heightinfo) eq 0 then $
;         CTM_GET_DATA, Heightinfo, file = '~rjp/Asim/data/bxhght_4x5_2001.bpch'
         
;      AD = FLTARR(Gridinfo.imx,Gridinfo.jmx,Gridinfo.lmx,N_elements(airdinfo))
;      For D = 0, N_elements(Airdinfo)-1 do $
;      AD[*,*,*,D] = *(Airdinfo[D].Data) / 6.022D23 * Volume ; mole

    ; Burden information

    Tracers = Lindgen(9) + NALPH
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

      Dim  = size(*(Dinfo[0].data),/dim)
      Data = 0.

         For D = 0, N_elements(Dinfo)-1 do begin
             P = where(Dinfo[D].tau0 eq Airdinfo.tau0)
;             Q = where(Dinfo[D].tau0 eq Heightinfo.tau0)
;             if (P[0] ne -1) and (Q[0] ne -1) then begin
;                Hg = *(Heightinfo[Q[0]].data)   ; height in box (m)
;                AD = *(Airdinfo[P[0]].Data) / 6.022D23 * Hg ; mole/m2
             if (P[0] ne -1) then begin
                AD = *(Airdinfo[P[0]].Data) / 6.022D23 * Volume ; mole
                Data = Data + (*(Dinfo[D].data) * AD[0:Dim[0]-1,0:Dim[1]-1,0:Dim[2]-1] * fac) 
             end else Return, -1
         Endfor

      Data = region_only(Data, region=region)
      Data = Data / float(N_elements(Dinfo))
      Results = create_struct(Results, Dinfo[0].tracername, Data)
      Undefine, Dinfo
      Undefine, Data
    Endfor

      ALPHBURD = total(Results.ALPH[*,*,0:19]) * MW[0] * 1.e-9
      LIMOBURD = total(Results.LIMO[*,*,0:19]) * MW[1] * 1.e-9 ; Tg /yr
;      TERPBURD = total(Results.TERP[*,*,0:19]) * MW[2] * 1.e-9 
      ALCOBURD = total(Results.ALCO[*,*,0:19]) * MW[2] * 1.e-9 ; Tg /yr
;      SESQBURD = total(Results.SESQ[*,*,0:19]) * MW[4] * 1.e-9
      SOG1BURD = total(Results.SOG1[*,*,0:19]) * MW[3] * 1.e-9 ; Tg /yr
      SOG2BURD = total(Results.SOG2[*,*,0:19]) * MW[4] * 1.e-9 
      SOG3BURD = total(Results.SOG3[*,*,0:19]) * MW[5] * 1.e-9
      SOA1BURD = total(Results.SOA1[*,*,0:19]) * MW[6] * 1.e-9
      SOA2BURD = total(Results.SOA2[*,*,0:19]) * MW[7] * 1.e-9
      SOA3BURD = total(Results.SOA3[*,*,0:19]) * MW[8] * 1.e-9

  Period = '('
  For N = 0, N_elements(Time.month)-1 do $
    Period = Period + strtrim(Mon_str(Time.month[N]-1))+' '
  Period = Period+')'

  If N_elements(region) ne 0 then $
 print, 'Regional Budget for '+Region
 print, '---------------------------------------------------------------'
 print, '	  Budget Component	   GEOS-CHEM    for ' + Period
 print, '---------------------------------------------------------------'
 print, ' Emissions (Tg/yr)        '
 print, ' ALPH                   : ', ALPHSRC
 print, ' LIMO                   : ', LIMOSRC
 print, ' TERP                   : ', TERPSRC
 print, ' ALCO                   : ', ALCOSRC
 print, ' SESQ                   : ', SESQSRC
 print, ' Total monoterpene      : ', BIOGSRC
 print, ' Total ORVOC            : ', ORVCSRC
 print, ' '
 print, ' Emissions (Tg C/yr)      '
 print, ' ALPH                   : ', BIOGSRC * 0.67 + ORVCSRC * 0.04
 print, ' LIMO                   : ', BIOGSRC * 0.23
 print, ' TERP                   : ', BIOGSRC * 0.03
 print, ' ALCO                   : ', BIOGSRC * 0.07 + ORVCSRC * 0.09
 print, ' SESQ                   : ', ORVCSRC * 0.05
 print, ' '
 print, ' Chemical conversion      '
 print, ' ALPH                   : ', ALPHSRC-ALPHDDEP-ALPHWDEP
 print, ' LIMO                   : ', LIMOSRC-LIMODDEP-LIMOWDEP
 print, ' TERP                   : ', TERPSRC
 print, ' ALCO                   : ', ALCOSRC-ALCODDEP-ALCOWDEP
 print, ' SESQ                   : ', SESQSRC
 print, ' '
 print, ' Dry Deposition, Tg       '
 print, ' ALPH                   : ', ALPHDDEP
 print, ' LIMO                   : ', LIMODDEP
; print, ' TERP                   : ', TERPDDEP
 print, ' ALCO                   : ', ALCODDEP
; print, ' SESQ                   : ', SESQDDEP
 print, ' SOG1                   : ', SOG1DDEP
 print, ' SOG2                   : ', SOG2DDEP
 print, ' SOG3                   : ', SOG3DDEP
 print, ' SOA1                   : ', SOA1DDEP
 print, ' SOA2                   : ', SOA2DDEP
 print, ' SOA3                   : ', SOA3DDEP
 print, ' '
 print, ' Wet Deposition, Tg       '
 print, ' ALPH                   : ', ALPHWDEP
 print, ' LIMO                   : ', LIMOWDEP
; print, ' TERP                   : ', TERPWDEP
 print, ' ALCO                   : ', ALCOWDEP
; print, ' SESQ                   : ', SESQWDEP
 print, ' SOG1                   : ', SOG1WDEP
 print, ' SOG2                   : ', SOG2WDEP
 print, ' SOG3                   : ', SOG3WDEP
 print, ' SOA1                   : ', SOA1WDEP
 print, ' SOA2                   : ', SOA2WDEP
 print, ' SOA3                   : ', SOA3WDEP
 print, '  '
 print, ' Burden, Tg                '
 print, ' ALPH                   : ', ALPHBURD
 print, ' LIMO                   : ', LIMOBURD
; print, ' TERP                   : ', TERPBURD
 print, ' ALCO                   : ', ALCOBURD
; print, ' SESQ                   : ', SESQBURD
 print, ' SOG1                   : ', SOG1BURD
 print, ' SOG2                   : ', SOG2BURD
 print, ' SOG3                   : ', SOG3BURD
 print, ' SOA1                   : ', SOA1BURD
 print, ' SOA2                   : ', SOA2BURD
 print, ' SOA3                   : ', SOA3BURD
 print, ' '
 print, ' SOA production (kg)                 '
 print, ' ALPH+LIMO+TERP         : ', SOA1CHEM 
 print, ' ALCO                   : ', SOA2CHEM 
 print, ' SESQ                   : ', SOA3CHEM 
 print, ' '
 print, ' SOA Yield (%)                      '
 print, ' ALPH+LIMO+TERP         : ', SOA1CHEM / (SOA1REAC) * 100.    
 print, ' ALCO                   : ', SOA2CHEM / (SOA2REAC) * 100.    
 print, ' SESQ                   : ', SOA3CHEM / (SOA3REAC) * 100.    
 print, ' '
 print, ' Life time against deposition, days '
 print, ' ALPH                   : ', ALPHBURD/(ALPHDDEP+ALPHWDEP)*Nday
 print, ' LIMO                   : ', LIMOBURD/(LIMODDEP+LIMOWDEP)*Nday
; print, ' TERP                   : ', TERPBURD/(TERPDDEP+TERPWDEP)*Nday
 print, ' ALCO                   : ', ALCOBURD/(ALCODDEP+ALCOWDEP)*Nday
; print, ' SESQ                   : ', SESQBURD/(SESQDDEP+SESQWDEP)*Nday
 print, ' SOG1                   : ', SOG1BURD/(SOG1DDEP+SOG1WDEP)*Nday
 print, ' SOG2                   : ', SOG2BURD/(SOG2DDEP+SOG2WDEP)*Nday
 print, ' SOG3                   : ', SOG3BURD/(SOG3DDEP+SOG3WDEP)*Nday
 print, ' SOA1                   : ', SOA1BURD/(SOA1DDEP+SOA1WDEP)*Nday
 print, ' SOA2                   : ', SOA2BURD/(SOA2DDEP+SOA2WDEP)*Nday
 print, ' SOA3                   : ', SOA3BURD/(SOA3DDEP+SOA3WDEP)*Nday
 print, ' '
 print, '-----------------------------------------------------'

 Heap_gc

 return, 0

end

