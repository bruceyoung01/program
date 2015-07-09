  pro d_full_nh4, File=file, region=region, Saveout=saveout, $
      tau0=tau0, results=results

;+
; pro diag_sulf_v02, File=file, region=region, /Saveout
;-

  if n_elements(file) eq 0 then file=pickfile()

   Mon_str = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec']
;===============================================================================
;  Sulfate
;===============================================================================
    ;1) the emission information
    Diag = ['NH3-ANTH', $      ; Others
            'NH3-BIOB', $      ; Biomass
            'NH3-BIOF'  ]      ; Biofuel

    For ND = 0, N_elements(Diag)-1 do begin

      For N = 0, N_elements(File)-1 do begin
        CTM_Get_Data, Datainfo, File=file[N], Diag[ND], tau0=tau0
        If N eq 0 then Dinfo = Datainfo else Dinfo = [Dinfo, Datainfo]
        Undefine, Datainfo
        Undefine, tau0
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

      NH3SRC_an = total(Results.NH3_ANTH) * 14. / 17. * 1.e-9 ; Tg N/yr
      NH3SRC_bb = total(Results.NH3_BIOB) * 14. / 17. * 1.e-9 ; Tg N/yr
      NH3SRC_bf = total(Results.NH3_BIOF) * 14. / 17. * 1.e-9 ; Tg N/yr

      TOTEMS = NH3SRC_AN + NH3SRC_BB + NH3SRC_BF

    ;2) Dry deposition information
    Tracers = [7129L, 7130L]

    For ND = 0, N_elements(Tracers)-1 do begin

      For N = 0, N_elements(File)-1 do begin
        CTM_Get_Data, Datainfo, File=file[N], 'DRYD-FLX', tracer=Tracers[ND], tau0=tau0
        If N eq 0 then Dinfo = Datainfo else Dinfo = [Dinfo, Datainfo]
        Undefine, Datainfo
        Undefine, tau0
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
         DFAC     = Area_cm2 / 6.022D23 * Nday * 86400. * 14D-3 ; kg N/yr
      Endif

      Data = 0.
      For D = 0, N_elements(Dinfo)-1 do Data = Data + *(Dinfo[D].data)
      Data = region_only(Data, region=region)
      Data = Data * float(DFac) / float(N_elements(Dinfo))
      Results = create_struct(Results, Dinfo[0].tracername, Data)
      Undefine, Dinfo
      Undefine, Data
    End

      NH3DRYDEP = total(Results.NH3df) * 1.e-9  ; Tg S/yr
      NH4DRYDEP = total(Results.NH4df) * 1.e-9  ; Tg S/yr

    ;3) WET deposition information
    ;           NH3    NH4
    Tracers = [3329L, 3330L]
    Diag    = ['WETDLS-$', 'WETDCV-$']
    Mw      = [17., 18.]
    MwN     = 14.

    For ND0 = 0, N_elements(Tracers)-1 do begin
    For ND1 = 0, N_elements(Diag)-1    do begin
      
      For N = 0, N_elements(File)-1 do begin
        CTM_Get_Data, Datainfo, File=file[N], Diag[ND1], tracer=Tracers[ND0], tau0=tau0
        If N eq 0 then Dinfo = Datainfo else Dinfo = [Dinfo, Datainfo]
        Undefine, Datainfo
        Undefine, tau0
      Endfor

      WFAC = Nday * 86400. * MwN / Mw[ND0]

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

      TOTLOSS = NH3DRYDEP + NH4DRYDEP + NH3WETDEP + NH4WETDEP

 ; Retrieve air density
      Year      = strtrim(time.year[0],2)
      file_aird = '/users/ctm/rjp/Asim/data/aird_4x5_'+Year+'.bpch'
      file_aird = findfile(file_aird)
      If file_aird[0] ne '' then begin
         CTM_Get_Data, AirdInfo, 'BXHGHT-$', File=file_aird[0], tracer=2004, tau0=tau0
         AD = FLTARR(Gridinfo.imx,Gridinfo.jmx,Gridinfo.lmx,N_elements(airdinfo))
         For D = 0, N_elements(AirdInfo)-1 do $
         AD[*,*,*,D] = *(AirdInfo[D].Data) / 6.022D23 * Volume * 1.D-9 ; mole
      end else begin

        For N = 0, N_elements(File)-1 do begin
          CTM_Get_Data, Datainfo, File=file[N], 'BXHGHT-$', tracer=2004, tau0=tau0
          If N eq 0 then Airdinfo = Datainfo else Airdinfo = [Airdinfo, Datainfo]
          Undefine, Datainfo
          Undefine, tau0
        Endfor

         AD = FLTARR(Gridinfo.imx,Gridinfo.jmx,Gridinfo.lmx,N_elements(airdinfo))
         For D = 0, N_elements(Airdinfo)-1 do $
         AD[*,*,*,D] = *(Airdinfo[D].Data) / 6.022D23 * Volume * 1.D-9 ; mole
      end

    ; Burden information

    Tracers = [29L,30L]
    For ND = 0, N_elements(Tracers)-1 do begin

      For N = 0, N_elements(File)-1 do begin
        CTM_Get_Data, Datainfo, File=file[N], 'IJ-AVG-$', tracer=Tracers[ND], tau0=tau0
        If N eq 0 then Dinfo = Datainfo else Dinfo = [Dinfo, Datainfo]
        Undefine, Datainfo
        Undefine, tau0
      Endfor

      Data = 0.
      For D = 0, N_elements(Dinfo)-1 do Data = Data + (*(Dinfo[D].data) * AD[*,*,*,D]) ; mole
      Data = region_only(Data, region=region)
      Data = Data / float(N_elements(Dinfo))
      Results = create_struct(Results, Dinfo[0].tracername, Data)
      Undefine, Dinfo
      Undefine, Data
    Endfor

      NH3BURD = total(Results.NH3) * 14.e-12
      NH4BURD = total(Results.NH4) * 14.e-12

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
 print, ' NH3 biomass burning     : ', NH3SRC_bb, NH3SRC_bb/TOTEMS*100.
 print, ' NH3 biofuel burning     : ', NH3SRC_bf, NH3SRC_bf/TOTEMS*100.
 print, ' '
 print, 'Total Deposition, Tg N     ', TOTLOSS
 print, ' NH3 Dry deposition      : ', NH3DRYDEP, NH3DRYDEP/TOTLOSS*100.
 print, ' NH3 Wet deposition      : ', NH3WETDEP, NH3WETDEP/TOTLOSS*100.
 print, ' Ammonium Dry deposition : ', NH4DRYDEP, NH4DRYDEP/TOTLOSS*100.
 print, ' Ammonium Wet deposition : ', NH4WETDEP, NH4WETDEP/TOTLOSS*100.
 print, ' '
 print, 'Burden, Tg N               '
 print, ' NH3                     : ', NH3BURD
 print, ' Ammonium                : ', NH4BURD
 print, '-----------------------------------------------------'

 If Keyword_set(Saveout) then begin

  Openw, Ilun, 'Diag_nh4.txt', /Get

  If N_elements(region) ne 0 then $
 printf, ilun, 'Regional Budget for '+Region
 printf, ilun, '--------------------------------------------------'
 printf, ilun, '     Budget Component         GEOS-CHEM           '
 printf, ilun, '--------------------------------------------------'
 printf, ilun, 'Total Emission, Tg N       ', TOTEMS
 printf, ilun, ' NH3 anthropogenic       : ', NH3SRC_an, NH3SRC_an/TOTEMS*100.
 printf, ilun, ' NH3 biomass burning     : ', NH3SRC_bb, NH3SRC_bb/TOTEMS*100.
 printf, ilun, ' NH3 biofuel burning     : ', NH3SRC_bf, NH3SRC_bf/TOTEMS*100.
 printf, ilun, ' '
 printf, ilun, 'Total Deposition, Tg N     ', TOTLOSS
 printf, ilun, ' NH3 Dry deposition      : ', NH3DRYDEP, NH3DRYDEP/TOTLOSS*100.
 printf, ilun, ' NH3 Wet deposition      : ', NH3WETDEP, NH3WETDEP/TOTLOSS*100.
 printf, ilun, ' Ammonium Dry deposition : ', NH4DRYDEP, NH4DRYDEP/TOTLOSS*100.
 printf, ilun, ' Ammonium Wet deposition : ', NH4WETDEP, NH4WETDEP/TOTLOSS*100.
 printf, ilun, ' '
 printf, ilun, 'Burden, Tg N               '
 printf, ilun, ' NH3                     : ', NH3BURD
 printf, ilun, ' Ammonium                : ', NH4BURD
 printf, ilun, '-----------------------------------------------------'
 free_lun, ilun

 Endif

 Heap_gc
end


