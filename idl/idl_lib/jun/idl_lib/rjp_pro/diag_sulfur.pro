;  pro diag_source, File=file, region=region, Saveout=saveout, $
;      tau0=tau0, results=results

   Undefine, region
;  region = 'NAMERICA'
;  region = 'UScont'
;  region = 'MEXICO'
  region = 'CANADA'

  file = '/users/ctm/rjp/Asim/run_v7-02-01_NA_nested_1x1/STDNEW_2001_01-12.1x1.bpch'
  file = '/users/ctm/rjp/Asim/run_v7-02-01_NA_nested_1x1/NOUSNEW_2001_01-12.1x1.bpch'

  if n_elements(file) eq 0 then file=pickfile(filter = '/users/ctm/rjp/Asim/')
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

      chk = size(Data)
      if chk[0] eq 3 then Data = total(Data, 3)

      If ND eq 0 then begin
         N_SO2 = Long(Dinfo[0].tracer - 200L)
         Time     = tau2yymmdd(Dinfo.tau0)
      end

      If ND eq 0 then begin
         ThisDatainfo = Dinfo[0]
         FIRST = ThisDatainfo.FIRST - 1L ; IDL index
         GetModelAndGridInfo, ThisDatainfo, ModelInfo, GridInfo
         DIM  = ThisDatainfo.Dim
         Xmid = Gridinfo.xmid[First[0]:First[0]+Dim[0]-1L]
         Ymid = Gridinfo.Ymid[First[1]:First[1]+Dim[1]-1L]
      endif

      Undefine, Dinfo
      Data = region_only(Data, region=region)

      Name = exchar(Diag[ND],'-','_')
      If ND eq 0 then Results = create_struct(Name, Data) $
      else            Results = create_struct(Results, Name, Data)
 
      Undefine, Data
      Undefine, Name

    Endfor

      SO2SRC_an = total(Results.SO2_AN_$) * 1.e-9
      SO2SRC_ac = total(Results.SO2_AC_$) * 1.e-9
      SO2SRC_bm = total(Results.SO2_BIOB)                    * 1.e-9 ; Tg S/yr
      SO2SRC_bf = total(Results.SO2_BIOF)                    * 1.e-9 ; Tg S/yr
      SO2SRC_vo = total(Results.SO2_EV_$ + Results.SO2_NV_$) * 1.e-9 ; Tg S/yr
      SO4SRC_an = total(Results.SO4_AN_$)                    * 1.e-9 ; Tg S/yr
      DMSSRC_oc = total(Results.DMS_BIOG)                    * 1.e-9 ; Tg S/yr
      SO2SRC_sh = total(Results.SO2_SHIP)                    * 1.e-9 ; Tg S/yr

      TOTSULF = SO2SRC_an + SO2SRC_bm + SO2SRC_vo + SO4SRC_an + DMSSRC_oc + $
                SO2SRC_bf + SO2SRC_sh + SO2SRC_ac


      if n_elements(mapsrc) eq 0 then mapsrc = fltarr(101,51,8)
      srctype = ['fossil','aircraft','biomass','biofuel', $
                 'volcano','direct','ocean','ship']

      mapsrc[*,*,0] = Results.SO2_AN_$
      mapsrc[*,*,1] = Results.SO2_AC_$
      mapsrc[*,*,2] = Results.SO2_BIOB
      mapsrc[*,*,3] = Results.SO2_BIOF
      mapsrc[*,*,4] = Results.SO2_EV_$ + Results.SO2_NV_$
      mapsrc[*,*,5] = Results.SO4_AN_$
      mapsrc[*,*,6] = Results.DMS_BIOG
      mapsrc[*,*,7] = Results.SO2_SHIP

      anthsrc = (Results.SO2_AN_$ + Results.SO4_AN_$ + Results.SO2_AC_$ + Results.SO2_BIOF + Results.SO2_SHIP) ; Kg S/yr

      For D = 0, 7 do begin
          tvmap, mapsrc[*,*,d], xmid, ymid, /conti, /coast, $
                 /us, /sample, /countries, title=srctype[d], $
                 /cbar, divis=5
          halt
      Endfor

          tvmap, anthsrc, xmid, ymid, /conti, /coast, $
                 /us, /sample, /countries,  $
                 /cbar, divis=5


  Period = '('
  For N = 0, N_elements(Time.month)-1 do $
    Period = Period + strtrim(Mon_str(Time.month[N]-1))+' '
  Period = Period+')'

  If N_elements(region) ne 0 then $
 print, 'Regional Budget for '+Region
 print, '---------------------------------------------------------------'
 print, '	  Budget Component	   GEOS-CHEM    for ' + Period
 print, '---------------------------------------------------------------'
 print, 'Total Emission, Tg S       ', TOTSULF
 print, ' SO2 anthropogenic       : ', SO2SRC_an, SO2SRC_an/TOTSULF*100.
 print, ' SO2 aircraft            : ', SO2SRC_ac, SO2SRC_ac/TOTSULF*100.
 print, ' SO2 biomass burning     : ', SO2SRC_bm, SO2SRC_bm/TOTSULF*100.
 print, ' SO2 biofuel use         : ', SO2SRC_bf, SO2SRC_bf/TOTSULF*100.
 print, ' SO2 volcanic            : ', SO2SRC_vo, SO2SRC_vo/TOTSULF*100.
 print, ' Sulfate anthropogenic   : ', SO4SRC_an, SO4SRC_an/TOTSULF*100.
 print, ' DMS oceanic             : ', DMSSRC_oc, DMSSRC_oc/TOTSULF*100.
 print, ' SHIP emission           : ', SO2SRC_sh, SO2SRC_sh/TOTSULF*100.
 print, ' '

 Heap_gc

end


