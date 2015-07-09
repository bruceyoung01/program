  pro diag_nh4, File=file, region=region, Saveout=saveout, $
      tau0=tau0, results=results

;+
; pro diag_sulf_v02, File=file, region=region, /Saveout
;-

  if n_elements(file) eq 0 then file=pickfile()
  if n_elements(tau0) ne 0 then kill = 0 else kill = 1

   Mon_str = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec']
   MW_N    = 14E-3
;===============================================================================
;  Sulfate
;===============================================================================
    ;1) the emission information
    Diag = ['NH3-ANTH', $      ;* SO2 anthropogenic
            'NH3-NATU', $      ; Aircraft
            'NH3-BIOB', $      ; Biomass
            'NH3-BIOF'  ]      ; DMS

    For ND = 0, N_elements(Diag)-1 do begin

      For N = 0, N_elements(File)-1 do begin
        CTM_Get_Data, Datainfo, File=file[N], Diag[ND], tau0=tau0
        If N eq 0 then Dinfo = Datainfo else Dinfo = [Dinfo, Datainfo]
        Undefine, Datainfo
        if (kill eq 1) then Undefine, tau0
      Endfor
    
      Data = 0.
      For D = 0, N_elements(Dinfo)-1 do Data = Data + *(Dinfo[D].data) 

      If ND eq 0 then N_NH3 = Long(Dinfo[0].tracer - 200L)

      Undefine, Dinfo
      Data = region_only(Data, region=region)

      Name = exchar(Diag[ND],'-','_')
      If ND eq 0 then Results = create_struct(Name, Data) $
      else            Results = create_struct(Results, Name, Data)
 
      Undefine, Data
      Undefine, Name

    Endfor

      NH3SRC_an = total(Results.NH3_ANTH) * 14. / 17. * 1.e-9
      NH3SRC_na = total(Results.NH3_NATU) * 14. / 17. * 1.e-9 ; Tg N/yr
      NH3SRC_bb = total(Results.NH3_BIOB) * 14. / 17. * 1.e-9 ; Tg N/yr
      NH3SRC_bf = total(Results.NH3_BIOF) * 14. / 17. * 1.e-9 ; Tg N/yr

      TOTEMS = NH3SRC_an + NH3SRC_na + NH3SRC_bb + NH3SRC_bf

    ;2) Dry deposition information
    Tracers = Lindgen(2) + 7100L + N_NH3

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
         DFAC     = Area_cm2 / 6.022D23 * Nday * 86400. * MW_N ; kg N/yr
      Endif

      Data = 0.
      For D = 0, N_elements(Dinfo)-1 do Data = Data + *(Dinfo[D].data)
      Data = region_only(Data, region=region)
      Data = Data * float(DFac) / float(N_elements(Dinfo))
      Results = create_struct(Results, Dinfo[0].tracername, Data)
      Undefine, Dinfo
      Undefine, Data
    End

      NH3DRYDEP = total(Results.NH3df) * 1.e-9  ; Tg N/yr
      NH4DRYDEP = total(Results.NH4df) * 1.e-9  ; Tg N/yr


    ;3) WET deposition information
    ;           NH3, NH4
    Tracers = Lindgen(2) + 3300L + N_NH3
    Diag    = ['WETDLS-$', 'WETDCV-$']
    Mw      = [17.E-3, 18E-3]

    For ND0 = 0, N_elements(Tracers)-1 do begin
    For ND1 = 0, N_elements(Diag)-1    do begin
      
      For N = 0, N_elements(File)-1 do begin
        CTM_Get_Data, Datainfo, File=file[N], Diag[ND1], tracer=Tracers[ND0], tau0=tau0
        If N eq 0 then Dinfo = Datainfo else Dinfo = [Dinfo, Datainfo]
        Undefine, Datainfo
        if (kill eq 1) then Undefine, tau0
      Endfor

      WFAC = Nday*86400.*MW_N/Mw[ND0]

      Data = 0.
      For D = 0, N_elements(Dinfo)-1 do Data = Data + *(Dinfo[D].data)
      Data = region_only(Data, region=region)

      Data = Data * Wfac / float(N_elements(Dinfo))
      Name = Dinfo[0].tracername+exchar(Diag[ND1],'-','_')
      Results = create_struct(Results, Name, Data)
      Undefine, Data
    End
    End

      NH3WETDEP = total(Results.NH3WETDLS_$ + Results.NH3WETDCV_$) * 1.e-9 ; Tg N/yr
      NH4WETDEP = total(Results.NH4WETDLS_$ + Results.NH4WETDCV_$) * 1.e-9 ; Tg N/yr

;     Correct for evaporated amount in wet deposition
      EVAPORATE = NH3DRYDEP + NH4DRYDEP + NH3WETDEP + NH4WETDEP - TOTEMS

      IF EVAPORATE GT 0 then begin
      NH3WETDEP = NH3WETDEP - (EVAPORATE * NH3WETDEP / (NH3WETDEP + NH4WETDEP))
      NH4WETDEP = NH4WETDEP - (EVAPORATE * NH4WETDEP / (NH3WETDEP + NH4WETDEP))
      endif

      TOTLOSS = NH3DRYDEP + NH4DRYDEP + NH3WETDEP + NH4WETDEP

 ; Chemical conversion is computed as a residual of total emission after
 ; the deposition

      NH4TOTAL = TOTEMS - (NH3DRYDEP + NH3WETDEP)

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
      AD[*,*,*,D] = *(Airdinfo[D].Data) / 6.022D23 * Volume  ; mole

    ; Burden information

    Tracers = Lindgen(2) + N_NH3
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

      NH3BURD = total(Results.NH3[*,*,0:19]) * MW_N * 1.e-9
      NH4BURD = total(Results.NH4[*,*,0:19]) * MW_N * 1.e-9

  Period = '('
  For N = 0, N_elements(Time.month)-1 do $
    Period = Period + strtrim(Mon_str(Time.month[N]-1))+' '
  Period = Period+')'

  If N_elements(region) ne 0 then $
 print, 'Regional Budget for '+Region
 print, '---------------------------------------------------------------'
 print, '	  Budget Component	   GEOS-CHEM    for ' + Period
 print, '---------------------------------------------------------------'
 print, 'Total Emission, Tg N       ', TOTEMS
 print, ' NH3 anthropogenic       : ', NH3SRC_an, NH3SRC_an/TOTEMS*100.
 print, ' NH3 natural             : ', NH3SRC_na, NH3SRC_na/TOTEMS*100.
 print, ' NH3 biomass burning     : ', NH3SRC_bb, NH3SRC_bb/TOTEMS*100.
 print, ' NH3 biofuel use         : ', NH3SRC_bf, NH3SRC_bf/TOTEMS*100.
 print, ' '
 print, 'Total Deposition, Tg N     ', TOTLOSS
 print, ' NH3 Dry deposition      : ', NH3DRYDEP, NH3DRYDEP/TOTLOSS*100.
 print, ' NH3 Wet deposition      : ', NH3WETDEP, NH3WETDEP/TOTLOSS*100.
 print, ' Ammonium Dry deposition : ', NH4DRYDEP, NH4DRYDEP/TOTLOSS*100.
 print, ' Ammonium Wet deposition : ', NH4WETDEP, NH4WETDEP/TOTLOSS*100.
 print, ' '
 print, 'Ammonium production, Tg N  ', NH4TOTAL
 print, ' '
 print, 'Burden, Tg N               '
 print, ' NH3                     : ', NH3BURD
 print, ' Ammonium                : ', NH4BURD
 print, ' '
 print, 'Life time, days
 print, ' NH3                     : ', NH3BURD/(NH3DRYDEP+NH3WETDEP+NH4TOTAL)*Nday
 print, ' Ammonium                : ', NH4BURD/(NH4DRYDEP+NH4WETDEP)*Nday
 print, ' '
 print, 'Loss frequency, /day       '
 print, ' NH3 dry deposition      : ', NH3DRYDEP/NH3BURD/Nday
; print, ' NH3 in-air oxidation    : ', SO4AIR/SO2BURD/Nday
; print, ' NH3 wet processes       : ', (SO4AQU1+SO4AQU2+SO2WETDEP)/SO2BURD/Nday
 print, ' Ammonium dry deposition : ', NH4DRYDEP/NH4BURD/Nday
 print, ' Ammonium wet scavenging : ', NH4WETDEP/NH4BURD/Nday
 print, '-----------------------------------------------------'

 If Keyword_set(Saveout) then begin

  Openw, Il, 'Diag_nh3.txt', /Get

  If N_elements(region) ne 0 then $
 printf,il, 'Regional Budget for '+Region
 printf,il, '---------------------------------------------------------------'
 printf,il, '	  Budget Component	   GEOS-CHEM    for ' + Period
 printf,il, '---------------------------------------------------------------'
 printf,il, 'Total Emission, Tg N       ', TOTEMS
 printf,il, ' NH3 anthropogenic       : ', NH3SRC_an, NH3SRC_an/TOTEMS*100.
 printf,il, ' NH3 natural             : ', NH3SRC_na, NH3SRC_na/TOTEMS*100.
 printf,il, ' NH3 biomass burning     : ', NH3SRC_bb, NH3SRC_bb/TOTEMS*100.
 printf,il, ' NH3 biofuel use         : ', NH3SRC_bf, NH3SRC_bf/TOTEMS*100.
 printf,il, ' '
 printf,il, 'Total Deposition, Tg N     ', TOTLOSS
 printf,il, ' NH3 Dry deposition      : ', NH3DRYDEP, NH3DRYDEP/TOTLOSS*100.
 printf,il, ' NH3 Wet deposition      : ', NH3WETDEP, NH3WETDEP/TOTLOSS*100.
 printf,il, ' Ammonium Dry deposition : ', NH4DRYDEP, NH4DRYDEP/TOTLOSS*100.
 printf,il, ' Ammonium Wet deposition : ', NH4WETDEP, NH4WETDEP/TOTLOSS*100.
 printf,il, ' '
 printf,il, 'Ammonium production, Tg N  ', NH4TOTAL
 printf,il, ' '
 printf,il, 'Burden, Tg N               '
 printf,il, ' NH3                     : ', NH3BURD
 printf,il, ' Ammonium                : ', NH4BURD
 printf,il, ' '
 printf,il, 'Life time, days
 printf,il, ' NH3                     : ', NH3BURD/(NH3DRYDEP+NH3WETDEP+NH4TOTAL)*Nday
 printf,il, ' Ammonium                : ', NH4BURD/(NH4DRYDEP+NH4WETDEP)*Nday
 printf,il, ' '
 printf,il, 'Loss frequency, /day       '
 printf,il, ' NH3 dry deposition      : ', NH3DRYDEP/NH3BURD/Nday
; print, ' NH3 in-air oxidation    : ', SO4AIR/SO2BURD/Nday
; print, ' NH3 wet processes       : ', (SO4AQU1+SO4AQU2+SO2WETDEP)/SO2BURD/Nday
 printf,il, ' Ammonium dry deposition : ', NH4DRYDEP/NH4BURD/Nday
 printf,il, ' Ammonium wet scavenging : ', NH4WETDEP/NH4BURD/Nday
 printf,il, '-----------------------------------------------------'
 free_lun, il

 Endif

 Heap_gc
end


