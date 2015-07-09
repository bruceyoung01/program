;  pro diag_source, File=file, region=region, Saveout=saveout, $
;      tau0=tau0, results=results

;  region = 'UScont'

  file = '/users/ctm/rjp/Asim/run_v7-02-01_NA_nested_1x1/STDNEW_2001_01-12.1x1.bpch'
  if n_elements(file) eq 0 then file=pickfile(filter = '/users/ctm/rjp/Asim/')
  if n_elements(tau0) ne 0 then kill = 0 else kill = 1

   Mon_str = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec']

;===============================================================================
;  NH3
;===============================================================================
    ;1) the emission information
    Diag = ['NH3-ANTH', $     ;* SO2 anthropogenic
            'NH3-BIOB', $     ; Aircraft
            'NH3-NATU', $
            'NH3-BIOF'  ]     ; Biomass

    For ND = 0, N_elements(Diag)-1 do begin

      For N = 0, N_elements(File)-1 do begin
        CTM_Get_Data, Datainfo, File=file[N], Diag[ND], tau0=tau0
        If N eq 0 then Dinfo = Datainfo else Dinfo = [Dinfo, Datainfo]
        Undefine, Datainfo
        if (kill eq 1) then Undefine, tau0
      Endfor

      If ND eq 0 then begin
         ThisDatainfo = Dinfo[0]
         FIRST = ThisDatainfo.FIRST - 1L ; IDL index
         GetModelAndGridInfo, ThisDatainfo, ModelInfo, GridInfo
         DIM  = ThisDatainfo.Dim
         Xmid = Gridinfo.xmid[First[0]:First[0]+Dim[0]-1L]
         Ymid = Gridinfo.Ymid[First[1]:First[1]+Dim[1]-1L]
      endif
    
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

      NH3SRC_an = total(Results.NH3_ANTH) * 1.e-9
      NH3SRC_nt = total(Results.NH3_NATU) * 1.e-9
      NH3SRC_bm = total(Results.NH3_BIOB) * 1.e-9 ; Tg N/yr
      NH3SRC_bf = total(Results.NH3_BIOF) * 1.e-9 ; Tg N/yr

      TOTNH3 = NH3SRC_an + NH3SRC_nt + NH3SRC_bm + NH3SRC_bf

      if n_elements(mapsrc) eq 0 then mapsrc = fltarr(101,51,4)
      srctype = ['anthro','natural','biomass','biofuel']

      mapsrc[*,*,0] = Results.NH3_ANTH
      mapsrc[*,*,1] = Results.NH3_NATU
      mapsrc[*,*,2] = Results.NH3_BIOB
      mapsrc[*,*,3] = Results.NH3_BIOF

      multipanel, 1
      For D = 0, 3 do begin
          tvmap, mapsrc[*,*,d], xmid, ymid, /conti, /coast, $
                 /us, /sample, /countries, title=srctype[d], $
                 /cbar, divis=5
          halt
      Endfor


  If N_elements(region) ne 0 then $
 print, 'Regional Budget for '+Region
 print, '---------------------------------------------------------------'
 print, '	  Budget Component	   GEOS-CHEM    for '
 print, '---------------------------------------------------------------'
 print, 'Total NH3 Emission, Tg N   ', TOTNH3
 print, ' NH3 anthropogenic       : ', NH3SRC_an, NH3SRC_an/TOTNH3*100.
 print, ' NH3 biofuel use         : ', NH3SRC_bf, NH3SRC_bf/TOTNH3*100.
 print, ' NH3 biomass burning     : ', NH3SRC_bm, NH3SRC_bm/TOTNH3*100.
 print, ' NH3 natural sources     : ', NH3SRC_nt, NH3SRC_nt/TOTNH3*100.
 print, ' '

 ctm_cleanup

end


